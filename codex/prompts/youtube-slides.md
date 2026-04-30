# /youtube-slides — YouTube Slides

YouTube 영상 → 자막 구간별 프레임 캡쳐 → 마크다운/HTML/이미지 출력. 영상을 슬라이드 형태로 정리한다.

> Codex CLI 슬래시 커맨드로 호출되거나 자연어로 트리거된다. `$ARGUMENTS`에 사용자 입력이 주입된다.

## 사전 조건

- `yt-dlp` 설치 필요 (pip install yt-dlp)
- `ffmpeg` 설치 필요
- `python3` (3.8+) 설치 필요

## yt-dlp 실행 가이드 (Windows)

- `yt-dlp`가 PATH에 없을 수 있으므로 **`python -m yt_dlp`로 실행**
- YouTube 봇 인증: `--cookies <cookies.txt 경로>` 필수. 브라우저 확장(Get cookies.txt LOCALLY)으로 내보내기
- `--cookies-from-browser`는 Windows DPAPI 문제로 실패 → cookies.txt 파일 사용
- JS 챌린지 해결: `--remote-components ejs:github` 필수
- Step 2(자막) + Step 3(영상 다운로드)는 **병렬 실행** 가능. Step 3는 백그라운드 실행 권장

## 워크플로우

### 0. 요구사항 명확화 (Clarify Phase)

사용자에게 다음 질문을 제시하고 번호 또는 라벨로 답하게 하세요. 이미 명확하게 지정된 항목은 건너뛴다.

**캡쳐 간격을 어떻게 할까요?**
1. **자막 구간별 (기본)** — 각 자막 세그먼트 시작 시점에서 캡쳐
2. **장면 변화 감지** — ffmpeg scene detect로 화면 변화 시 캡쳐
3. **고정 간격** — N초마다 캡쳐 (10초, 30초, 1분 등)

**영상 전체를 캡쳐할까요, 특정 구간만?**
1. **전체 영상** — 처음부터 끝까지 모든 구간
2. **특정 구간만** — 시작~끝 타임스탬프 지정

### 1. 메타데이터 수집

```bash
python -m yt_dlp --remote-components ejs:github --cookies "<cookies_path>" \
    --skip-download --print "%(title)s|||%(channel)s|||%(upload_date)s|||%(duration_string)s|||%(id)s" "<URL>"
```

추출: title, channel, upload_date, duration, video_id
셸 스크립트: `scripts/extract_metadata.sh "<URL>" --cookies "<cookies_path>"`

### 2. 자막 추출 (Step 3와 병렬 실행 가능)

```bash
python -m yt_dlp --remote-components ejs:github --cookies "<cookies_path>" \
    --skip-download --write-sub --sub-lang "ko,en" --sub-format json3 \
    -o "<output_dir>/source/%(id)s" "<URL>"
# 수동 자막 없으면 --write-auto-sub으로 재시도
```

우선순위: 수동 자막(ko→en) > 자동 생성 자막(ko→en)
출력: JSON3 형식 자막 파일
셸 스크립트: `scripts/extract_transcript.sh "<URL>" "<output_dir>" --cookies "<cookies_path>"`

### 3. 영상 다운로드 (Step 2와 병렬 실행, 백그라운드 실행 권장)

```bash
python -m yt_dlp --remote-components ejs:github --cookies "<cookies_path>" \
    -f "bestvideo[height<=720]+bestaudio/best[height<=720]" \
    --merge-output-format mp4 \
    -o "<output_dir>/source/%(id)s.mp4" "<URL>"
```

720p 이하로 다운로드 (캡쳐 용도이므로 고해상도 불필요).
셸 스크립트: `scripts/download_video.sh "<URL>" "<output_dir>" --cookies "<cookies_path>"`

### 4. 프레임 캡쳐

```bash
uv run python scripts/capture_frames.py "<video_path>" "<subtitle_json3_path>" "<output_dir>" [--min-interval 3]
```

처리:
1. JSON3 자막 파싱 → 타임스탬프 + 텍스트 추출
2. 너무 가까운 구간 병합 (기본 3초 이내)
3. ffmpeg로 각 타임스탬프에서 프레임 캡쳐
4. `segments.json` 매핑 파일 생성

### 5. 출력물 생성

```bash
uv run python scripts/generate_output.py "<output_dir>" --title "TITLE" --url "URL" --channel "CH" --date "DATE" --duration "DUR"
```

3종 출력물:

| 출력 | 파일 | 설명 |
|------|------|------|
| 마크다운 | `slides.md` | 타임스탬프 + 스크립트 + 이미지 경로 |
| HTML | `slides.html` | 시각적 슬라이드 뷰 페이지 |
| 이미지 | `images/` | 프레임 캡쳐 이미지 폴더 |

### 6. 파일 저장

저장 위치: `research/youtube-slides/{video-id}/`

```
research/youtube-slides/{video-id}/
├── slides.md
├── slides.html
├── segments.json
├── images/
│   ├── frame_0000_00-00.jpg
│   ├── frame_0001_00-15.jpg
│   └── ...
└── source/
    ├── {video-id}.mp4
    └── {subtitle}.json3
```

### 7. 결과 보고

완료 후 사용자에게 보고:
- 총 캡쳐 프레임 수
- 출력 디렉토리 경로
- HTML 파일 열기 안내

## 장면 변화 감지 모드 (옵션)

0단계에서 "장면 변화 감지"를 선택한 경우:

```bash
ffmpeg -i <video> -vf "select='gt(scene,0.3)',showinfo" -vsync vfr <output_dir>/images/scene_%04d.jpg
```

이 모드에서는 자막 대신 장면 변화 시점 기준으로 캡쳐하고, 해당 시점의 자막을 매칭한다.

## 고정 간격 모드 (옵션)

0단계에서 "고정 간격"을 선택한 경우:

```bash
ffmpeg -i <video> -vf "fps=1/N" <output_dir>/images/frame_%04d.jpg
```

N초 간격으로 프레임을 추출하고, 각 프레임에 가장 가까운 자막을 매칭한다.

## 참고사항

### 대용량 영상 처리
- 1시간 이상 영상은 자막 구간이 수백 개일 수 있음
- `--min-interval` 값을 높여 캡쳐 수를 조절 (기본 3초 → 10초, 30초)

### 영상 다운로드 실패 시
- `--cookies <cookies.txt>` 옵션 추가 (브라우저 확장으로 내보내기)
- `--cookies-from-browser`는 Windows DPAPI 문제로 실패할 수 있음
- `--remote-components ejs:github` 옵션으로 JS 챌린지 해결
- 지역 제한 영상은 VPN 필요할 수 있음

### 자막 없는 영상
- Whisper 등 외부 STT 도구 사용을 안내
- 자막 없이 고정 간격 캡쳐 모드로 전환 가능

## 리소스

- `scripts/extract_metadata.sh` - 메타데이터 추출
- `scripts/extract_transcript.sh` - 자막 추출
- `scripts/download_video.sh` - 영상 다운로드
- `scripts/capture_frames.py` - 프레임 캡쳐
- `scripts/generate_output.py` - 마크다운/HTML 생성
