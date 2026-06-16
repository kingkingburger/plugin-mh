# /deep-goal-council — Deep Goal Council: 경쟁형 장기 목표 하네스

작고 단기적인 목표로 수렴하는 습관을 보정하기 위해, 여러 경쟁 팀이 같은 입력을 서로 다른 철학으로 해석하고 사용자가 심사할 Judge Packet을 만든다.

> Codex CLI 슬래시 커맨드로 호출되거나 자연어로 트리거된다. `$ARGUMENTS`에 사용자 입력이 주입된다.

## 언제 사용하나

- `$deep-goal-council`, `/deep-goal-council`, `deep-goal-council` 호출
- "목표가 작다", "단기 목표로 축소된다", "깊은 목표", "장기 방향"
- "여러 경쟁 팀", "팀들이 경쟁", "설계자/구현자/감시자"
- "AI 하네스 역량", "상담 공부 개발 디자인", "소설가 1년 계획", "12주 커리큘럼"

단일 목표 상향은 `/moonshot`, 6계층 개인 계획은 `/life-plan`, 프로젝트 문서/에이전트 시스템 구축은 `/harness`를 우선 고려한다.

## 입력

사용자 입력:

```text
$ARGUMENTS
```

## Workflow

### Phase 0: 입력 고정

사용자의 현재 입력을 보존하고 작업 표면을 분류한다.

| 표면 | 예시 |
| --- | --- |
| `career` | 개발자로서 AI 하네스 역량을 대표작으로 만들기 |
| `study` | 단기 튜토리얼 소비를 12주 커리큘럼으로 바꾸기 |
| `writing` | 소설가가 되기 위한 1년 장기 계획 |
| `development` | 특정 repo/제품을 장기 역량 축으로 만들기 |
| `design` | 예쁜 화면 모방을 넘어 제품 감각 구축 |
| `counseling` | 작은 목표에 안심하는 패턴을 안전하게 탐색 |

빠진 맥락이 결과를 크게 바꾸면 최대 3개 질문만 자연어 번호 옵션으로 묻는다. 질문 없이 진행 가능하면 `[Assumption]`으로 명시한다.

### Phase 1: Situation Brief

다음 항목을 7문장 안팎으로 정리한다.

- 현재 상태
- 목표가 작아지는 원인 가설
- 제약
- 욕구
- 피하고 싶은 방식
- 시간 지평: 1년 / 12주 / 7일
- 사용자의 심사 기준

### Phase 2: Council 구성

기본은 5팀이다. 입력이 감정적으로 무겁거나 범위가 작으면 3~4팀으로 줄인다.

- `moonshot-team`: 목표를 의도적으로 크게 잡는다.
- `compound-team`: 매주 누적되는 시스템을 설계한다.
- `constraint-breaker-team`: 더 열심히 하기보다 게임판을 바꾼다.
- `craft-team`: 실력, 품질, 정체성 변화를 중심에 둔다.
- `operator-team`: 이번 7일 안에 관찰 가능한 증거를 만든다.

각 팀은 Team Chief, Team Manager, Architect, Operator, Sentinel, Synthesizer 역할을 갖는다. 실제 팀 도구가 없으면 단일 응답 안에서 역할 라운드를 분리한다.

### Phase 3: 팀별 제안

각 팀은 다음을 반드시 포함한다.

- 1년 북극성 목표
- 12주 캠페인
- 7일 첫 증거
- 사용자가 맡아야 할 정체성/역할 전환
- 포기할 작은 목표나 습관
- Sentinel 비판
- 실패 시 회수 전략

### Phase 4: 교차 비판

각 팀은 다른 팀에서 훔칠 강점 1개와 치명적 약점 1개를 제시한다. 비판은 승부가 아니라 사용자의 심사 품질을 높이기 위한 것이다.

### Phase 5: Judge Packet

최종 출력은 사용자가 판단하기 쉽게 만든다.

1. Situation Brief
2. 팀별 제안 요약
3. Cross-Critique
4. 비교 매트릭스: 깊이, 야심, 현실성, 7일 증거 가능성, 정체성 변화, 비용, 리스크
5. 단일 우승 후보 1개
6. 혼합안 후보 1개
7. 사용자가 고를 질문 3개
8. 선택 후 바로 실행할 7일 실험

## 출력 형식

```markdown
# Deep Goal Council Judge Packet

## Situation Brief

## Team Proposals
### moonshot-team
### compound-team
### constraint-breaker-team
### craft-team
### operator-team

## Cross-Critique

## Comparison Matrix
| 팀 | 깊이 | 야심 | 현실성 | 7일 증거 가능성 | 정체성 변화 | 비용 | 주요 리스크 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |

## 단일 우승 후보

## 혼합안 후보

## 사용자가 고를 질문 3개
1.
2.
3.

## 선택 후 7일 실험
```

## 대표 테스트 프롬프트

```text
$deep-goal-council

현재 나는 목표를 너무 작고 단기적으로 잡는 습관이 있다.
AI 도구와 에이전트 하네스를 다루는 역량을 장기적으로 키우고 싶은데,
매번 "오늘 뭐 고칠까", "어떤 문서 하나 만들까" 수준으로 축소된다.

상담, 공부, 개발, 디자인에도 재사용 가능한 방향으로
여러 경쟁 팀이 내 1년/12주/7일 목표를 제안하고,
내가 심사할 수 있는 Judge Packet으로 정리해줘.
```

추가 테스트 주제:

- 개발자로서 1년 안에 AI 하네스/에이전트 운영 역량을 대표작으로 만드는 방향
- 공부 루틴이 단기 튜토리얼 소비로 끝나는 문제를 12주 커리큘럼으로 바꾸기
- 소설가가 되기 위한 1년짜리 장기 계획

## 참조 파일 위치

이 프롬프트가 언급하는 `references/...` 파일은 plugin-mh 저장소의 `skills/deep-goal-council/references/` 에 있다. Codex CLI에서 사용 시 해당 경로를 직접 Read 하면 된다.
