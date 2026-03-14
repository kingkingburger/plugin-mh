---
name: youtube-slides
version: 1.0.0
description: "This skill should be used when the user asks to \"유튜브 슬라이드\", \"영상 캡쳐\", \"스크린샷 추출\", \"YouTube slides\", \"영상 프레임 추출\", \"영상 정리 with 캡쳐\", or provides a YouTube URL with capture/screenshot intent. Downloads video, extracts transcript, captures frames at each subtitle segment, and generates markdown + HTML + image folder output."
---

# YouTube Slides

YouTube 영상 → 자막 구간별 프레임 캡쳐 → 마크다운/HTML/이미지 출력.

## 사전 조건

- `yt-dlp` 설치 필요
- `ffmpeg` 설치 필요
- `python3` (3.8+) 설치 필요

## 워크플로우

### 0. 요구사항 명확화 (Clarify Phase)

AskUserQuestion으로 사용자 의도를 확인한다. 이미 명확하게 지정된 항목은 건너뛴다.

```
questions:
  - question: "캡쳐 간격을 어떻게 할까요?"
    header: "캡쳐 간격"
    options:
      - label: "자막 구간별 (기본)"
        description: "각 자막 세그먼트 시작 시점에서 캡쳐"
      - label: "장면 변화 감지"
        description: "ffmpeg scene detect로 화면 변화 시 캡쳐"
      - label: "고정 간격"
        description: "N초마다 캡쳐 (10초, 30초, 1분 등)"
  - question: "영상 전체를 캡쳐할까요, 특정 구간만?"
    header: "캡쳐 범위"
    options:
      - label: "전체 영상"
        description: "처음부터 끝까지 모든 구간"
      - label: "특정 구간만"
        description: "시작~끝 타임스탬프 지정"
```

### 1. 메타데이터 수집

```bash
scripts/extract_metadata.sh "<URL>"
```

추출: title, channel, upload_date, duration, video_id

### 2. 자막 추출

```bash
scripts/extract_transcript.sh "<URL>" "<output_dir>"
```

우선순위: 수동 자막(ko→en) > 자동 생성 자막(ko→en)
출력: JSON3 형식 자막 파일

### 3. 영상 다운로드

```bash
scripts/download_video.sh "<URL>" "<output_dir>"
```

720p 이하로 다운로드 (캡쳐 용도이므로 고해상도 불필요).

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
- `--cookies-from-browser chrome` 옵션 추가
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
