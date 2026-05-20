# /daily-report — Source-Agnostic Work Report

하루 또는 지정 기간의 작업 흔적을 여러 소스에서 수집해 감사 가능한 Markdown 작업 보고서로 정리한다.

> Codex CLI 슬래시 커맨드로 호출되거나 자연어로 트리거된다. `$ARGUMENTS`에 사용자 입력이 주입된다.

이 프롬프트는 Codex 전용 로그 요약기가 아니다. 핵심은 **증거 소스 기반 보고서 작성**이다. Codex, Claude, Cursor, git, 로컬 노트, 터미널 히스토리, 사용자가 지정한 파일을 모두 소스로 다룰 수 있다.

## 원칙

- **도구 비종속**: Codex 로그만 전제하지 말고, 사용자가 지정한 소스와 현재 환경에서 발견 가능한 소스를 함께 본다.
- **증거 우선**: 보고서 끝에 읽은 파일, 로그, git 범위, 노트 경로를 남긴다.
- **추론 표시**: 로그에 없는 내용은 사실처럼 쓰지 말고 "추정" 또는 "근거 부족"으로 표시한다.
- **메모리 비작성 기본값**: memory, harness, project memory에는 쓰지 않는다. 사용자가 명시한 경우에만 별도 작업으로 처리한다.
- **민감정보 보호**: 토큰, 쿠키, API key, 개인 식별정보, 비공개 URL은 요약하거나 마스킹한다.
- **절대 날짜 사용**: "오늘", "어제"는 실행 시점의 로컬 날짜로 해석하고 보고서에는 `YYYY-MM-DD`로 쓴다.

## 입력 해석

`$ARGUMENTS`에서 다음을 추출한다:

| 항목 | 기본값 |
|------|--------|
| 기간 | 현재 로컬 날짜 00:00부터 현재까지 |
| 출력 | 현재 작업공간의 `reports/YYYY-MM-DD-daily-report.md` |
| 언어 | 사용자의 언어. 한국어 요청이면 한국어 |
| 소스 | 명시된 경로 + 현재 repo git + 발견 가능한 agent/conversation logs |
| 저장 범위 | Markdown 보고서만. memory/harness 제외 |

출력 경로가 없으면 합리적인 기본값을 사용한다. 단, 다른 저장소나 개인 노트 경로에 저장해야 하는 맥락이 분명하면 그 경로를 우선한다.

## 소스 수집

### 1. 명시 소스

사용자가 지정한 파일, 디렉토리, repo, 날짜, 로그 종류를 최우선으로 읽는다.

예:
- `D:\reference2\project`
- `C:\Users\<user>\.codex\sessions\YYYY\MM\DD\*.jsonl`
- `~/.claude/projects/...`
- Obsidian/Notion export Markdown
- 수동으로 붙여넣은 로그

### 2. 대화/에이전트 로그

가능한 경우 현재 날짜의 세션 로그를 찾는다.

| 도구 | 흔한 위치 | 처리 |
|------|-----------|------|
| Codex | `~/.codex/sessions/YYYY/MM/DD/*.jsonl` | JSONL을 라인 단위로 파싱해 user/assistant/tool 이벤트 추출 |
| Claude Code | `~/.claude/projects/` 또는 사용자가 지정한 export/log | 프로젝트별 transcript 또는 summary 추출 |
| 기타 에이전트 | 사용자가 지정한 로그 경로 | 파일 형식에 맞춰 처리 |

로그 위치는 환경마다 다르다. 찾지 못하면 "읽지 못한 소스"에 기록하고 다른 증거로 진행한다.

### 3. Git 증거

repo가 있으면 기간 내 활동을 본다:

```bash
git status --short
git log --since="<start>" --until="<end>" --oneline --decorate --all
git diff --stat
git diff --name-only
```

필요하면 변경 파일을 읽어 실제 작업 내용을 확인한다. 여러 repo가 관련되면 repo별로 분리한다.

### 4. 로컬 노트와 작업 목록

사용자가 지정했거나 현재 repo에 명백히 있는 다음 파일을 확인한다:

- `todos/YYYY-MM-DD.md`
- `docs/PLANS.md`
- `reports/`
- `decisions/`
- `docs/`
- 개인 노트 경로가 명시된 경우 해당 경로

## 정규화

수집한 증거를 아래 이벤트 형태로 머릿속에서 정리한다:

```text
time: 가능한 경우 timestamp
source: codex | claude | git | note | manual | other
project: repo/path 이름
actor: user | assistant | tool | git
event: 한 줄 요약
evidence: 파일 경로, 커밋 해시, 로그 라인, 명령 출력 등
confidence: high | medium | low
```

중복 이벤트는 합친다. 예를 들어 대화 로그의 "수정했다"와 git diff의 같은 파일 변경은 하나의 작업 항목으로 묶는다.

## 보고서 구조

기본 Markdown 구조:

```markdown
# Daily Work Report - YYYY-MM-DD

## 1. Executive Summary
- 오늘의 핵심 작업 3~7개
- 전체 상태: 완료 / 진행 중 / 막힘

## 2. Timeline
| Time | Project | Event | Evidence |
|------|---------|-------|----------|

## 3. Work By Project
### {project}
- 목표
- 수행 작업
- 변경 파일 / 산출물
- 현재 상태

## 4. Decisions
| Decision | Reason | Impact | Evidence |
|----------|--------|--------|----------|

## 5. Problems And Resolutions
| Problem | Cause | Resolution | Remaining Risk |
|---------|-------|------------|----------------|

## 6. Files And Artifacts
- 생성/수정/검토한 주요 파일
- 커밋/PR/보고서/노트

## 7. Follow-Ups
- 다음에 해야 할 일
- 확인이 필요한 질문

## 8. Evidence Sources
- 읽은 로그/파일/repo 범위
- 읽지 못한 소스와 이유
```

보고서가 길어져도 `Evidence Sources`는 반드시 포함한다.

## 작성 규칙

- 시간순과 프로젝트별 정리를 모두 제공한다. 둘 중 하나만 있으면 재구성이 어렵다.
- 사용자의 의사결정과 에이전트의 실행을 구분한다.
- 실패, 재시도, 취소, 방향 전환을 누락하지 않는다.
- "아마", "보인다" 같은 표현은 근거가 약할 때만 쓴다.
- 긴 로그를 그대로 붙이지 말고 요약한다. 필요한 경우 짧은 인용만 사용한다.
- 보고서 저장 후, 생성 경로와 읽은 주요 소스 수를 짧게 보고한다.

## 실행 체크리스트

1. 기간과 출력 경로를 정한다.
2. 명시 소스와 현재 repo를 수집한다.
3. 가능한 agent/conversation 로그를 찾는다.
4. git 상태와 기간 내 커밋/변경을 확인한다.
5. 이벤트를 시간순으로 정규화한다.
6. 프로젝트별 작업 내용을 재구성한다.
7. Markdown 보고서를 작성한다.
8. 보고서를 다시 읽고 누락된 `Evidence Sources`와 민감정보를 점검한다.
9. 최종 응답에는 저장 경로, 핵심 요약, 검증/미확인 소스를 말한다.

## 안티패턴

- Codex 전용 로그 위치만 보고 "전체"라고 단정한다.
- memory/harness에 자동 기록한다.
- git diff만 보고 대화에서 내려진 결정과 취소를 버린다.
- 대화 로그만 보고 실제 파일 변경 여부를 확인하지 않는다.
- 읽지 못한 로그를 조용히 생략한다.
- 비밀값이나 개인 정보를 원문 그대로 보고서에 남긴다.
