# AGENTS.md — plugin-mh 워크플로우 템플릿

> 이 파일은 다른 프로젝트의 사용자가 plugin-mh의 슬래시 커맨드를 활용한 표준 워크플로우를 자기 Codex 환경에 통합할 때 사용하는 **템플릿**이다.
> 사용법: 이 파일을 자신의 프로젝트 루트 `AGENTS.md` 에 통합하거나, 일부를 발췌하여 자기 가이드와 합쳐 사용한다.

## 사전 조건

plugin-mh의 codex 어댑터가 설치되어 있어야 한다:

```bash
# 어디에서든
git clone https://github.com/kingkingburger/plugin-mh ~/repos/plugin-mh
bash ~/repos/plugin-mh/codex/install.sh

# 또는 Windows
.\repos\plugin-mh\codex\install.ps1
```

설치 후 Codex CLI 재시작 → 21개 슬래시 커맨드 활성화.

## 표준 워크플로우 (Spec → Build → Verify → Ship)

```
[모호한 아이디어]
   ↓ /clarify  (또는 /vague /unknown /metamedium)
[명확한 요구사항]
   ↓ /tech-decision  (기술 선택 시)
   ↓ /agent-arena    (다관점 토론 시)
[설계 결정 완료]
   ↓ /ouroboros  (요구→설계→검증 깊이 작업)
   ↓ /harness    (프로젝트 문서 체계 부트스트랩)
[설계 문서]
   ↓ /tdd          (테스트 주도)
   ↓ /ouroboros-run (계획 자동 실행)
[구현 완료]
   ↓ /code-review (단독 빠른 리뷰)
   ↓ /review-loop (체이닝 리뷰)
   ↓ /live-verify (E2E 검증)
[검증 완료]
   ↓ /auto-commit
[Ship]
   ↓ /closing-lite     (가벼운 메모리 누적)
   ↓ /session-closing  (풀 분석 + 액션)
```

## 의도 → 명령어 라우팅

### 사고 정리 (Clarification)
| 사용자 의도 | 명령어 |
|------------|--------|
| 모호한 요청 / 스코프 정리 | `/vague` |
| 전략 사각지대 / 가정 점검 | `/unknown` |
| 같은 방식이 안 먹혀 / 관점 전환 | `/metamedium` |
| 어떤 명확화가 필요한지 모르겠음 | `/clarify` |
| 목표가 너무 보수적 | `/moonshot` |

### 의사결정 / 리뷰
| 사용자 의도 | 명령어 |
|------------|--------|
| 라이브러리·프레임워크 선택 (A vs B) | `/tech-decision` |
| 다관점 페르소나 토론 (3/5/8인) | `/agent-arena` |
| 문서·기획안 다관점 리뷰 | `/expert-review` |
| 코드 리뷰 (단독, 빠름) | `/code-review` |
| 코드 리뷰 (체이닝, 깐깐함) | `/review-loop` |

### 개발
| 사용자 의도 | 명령어 |
|------------|--------|
| 기능 구현 (TDD) | `/tdd` |
| 프로젝트 문서 체계 부트스트랩 | `/harness` |
| 작업 후 자동 커밋·푸시 | `/auto-commit` |
| 실제 동작 E2E 검증 | `/live-verify` |

### 스펙 / 실행
| 사용자 의도 | 명령어 |
|------------|--------|
| 깊이 있는 스펙 (요구→설계→검증) | `/ouroboros` |
| 스펙 문서 자동 실행 (Generator-Evaluator 루프) | `/ouroboros-run` |

### 세션
| 사용자 의도 | 명령어 |
|------------|--------|
| 세션 마무리 — 메모리 누적만 | `/closing-lite` |
| 세션 마무리 — 풀 분석 + 액션 | `/session-closing` |

### 콘텐츠
| 사용자 의도 | 명령어 |
|------------|--------|
| YouTube 영상 요약·번역·퀴즈 | `/youtube-digest` |
| YouTube 영상 자막별 프레임 캡쳐 | `/youtube-slides` |

## 자동 라우팅 트리거

다음 패턴이 사용자 입력에서 보이면 해당 명령어를 우선 제안 또는 실행:

| 입력 패턴 | 제안 명령어 |
|----------|-------------|
| "어떻게", "고민" + 비교 대상 2개+ | `/tech-decision` |
| "모호", "막연", "뭘 원하는지" | `/vague` 또는 `/clarify` |
| "blind spot", "사각지대", "가정" | `/unknown` |
| "다른 방법", "관점 전환" | `/metamedium` |
| "10x", "더 큰 목표" | `/moonshot` |
| "테스트 먼저", "TDD" | `/tdd` |
| "코드 리뷰" | `/code-review` |
| "리뷰 루프", "고치고 다시" | `/review-loop` |
| "실제로 동작", "E2E", "검증" | `/live-verify` |
| "커밋해" 단독 | `/auto-commit` |
| "정리하고 끝", "wrap up" | `/closing-lite` |

## 안티패턴

| 하지 말 것 | 왜 |
|-----------|-----|
| 모호한 요구를 받자마자 코드 작성 시작 | `/clarify` 또는 `/vague` 먼저 — 요구가 굳어진 뒤 작성 |
| 기술 선택을 직감만으로 결정 | `/tech-decision` 으로 다관점 비교 |
| 테스트 없이 코드 작성 | `/tdd` — RED-GREEN-REFACTOR 강제 |
| 리뷰 없이 커밋 | `/code-review` (단독) 또는 `/review-loop` (체이닝) |
| "동작할 것 같다"로 마무리 | `/live-verify` 로 실제 제품 조작 검증 |
| `--no-verify` 로 검증 우회 | 검증이 실패한 데는 이유가 있다 |
| 거대한 기능을 한 번에 구현 | `/ouroboros` 로 분해 → `/ouroboros-run` 으로 story별 실행 |

## 명령어 조합 패턴 (Composite Workflows)

### Pattern 1: 새 기능 구현 (작은~중간 규모)
```
/clarify           → 요구사항 정리
/tech-decision     → (필요 시) 기술 선택
/tdd               → 테스트 우선 구현
/code-review       → 빠른 단독 리뷰
/auto-commit       → 커밋·푸시
```

### Pattern 2: 큰 기능 구현 (스펙부터 검증까지)
```
/ouroboros         → 요구→설계→검증 3단계 깊이 작업
/ouroboros-run     → story별 Generator-Evaluator 자동 실행
/review-loop       → code-reviewer→architect→critic 체이닝 리뷰
/live-verify       → E2E 검증
/auto-commit       → 커밋
/session-closing   → 세션 마무리
```

### Pattern 3: 새 프로젝트 부트스트랩
```
/harness           → AGENTS.md, ARCHITECTURE.md, docs/ 자동 생성
/clarify           → 첫 기능 요구사항 정리
/tech-decision     → 핵심 스택 결정
... (이후 Pattern 1 또는 2)
```

### Pattern 4: 모호한 전략 점검
```
/unknown           → 4분면 분석으로 사각지대 발견
/agent-arena       → 다관점 토론으로 결론 검증
/moonshot          → (필요 시) 목표 상향
```

## 통합 방법

### 옵션 A: 자기 AGENTS.md 에 흡수
이 파일의 "워크플로우", "라우팅", "안티패턴" 섹션을 자기 프로젝트 AGENTS.md 에 복사해서 자기 컨벤션과 합친다.

### 옵션 B: 별도 파일로 두기
이 파일을 그대로 자기 프로젝트 루트의 `PLUGIN_MH_WORKFLOW.md` 등으로 두고, 자기 AGENTS.md에서 `→ PLUGIN_MH_WORKFLOW.md 참조` 한 줄로 연결.

### 옵션 C: 글로벌 적용
이 파일 내용을 `~/.codex/AGENTS.md` 에 통합하면 모든 프로젝트에서 자동 활성화. (단, 프로젝트별 AGENTS.md가 우선됨에 주의.)
