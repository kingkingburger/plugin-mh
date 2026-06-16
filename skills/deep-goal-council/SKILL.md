---
name: deep-goal-council
description: Use this skill when the user wants a reusable harness for deep goals, long-term direction, or competitive multi-team planning. Trigger on "$deep-goal-council", "/deep-goal-council", "deep-goal-council", "목표가 작다", "단기 목표로 축소된다", "깊은 목표", "장기 방향", "여러 경쟁 팀", "팀들이 경쟁", "최고 책임자", "중간 관리자", "설계자 구현자 감시자", "AI 하네스 역량", "상담 공부 개발 디자인", "소설가 1년 계획", "12주 커리큘럼", "Judge Packet". It builds a council of competing teams that produce 1-year, 12-week, and 7-day proposals for the user to judge. For one-off target uplift use moonshot; for six-layer personal planning use life-plan; for building project documentation/agent systems use harness.
version: 1.0.0
---

# Deep Goal Council

작고 단기적인 목표로 수렴하는 습관을 보정하기 위한 범용 하네스. 같은 입력을 여러 경쟁 팀이 서로 다른 철학으로 해석하고, 사용자는 최종 심사자로서 Judge Packet을 보고 선택한다.

## 핵심 개념

이 스킬 자체가 하네스의 실행 어댑터다. 하네스 본체는 아래 네 가지 계약의 조합으로 정의한다.

- 팀 구조: `references/team-blueprints.md`
- 출력 계약: `references/output-contract.md`
- 표면별 변환: `references/surface-adapters.md`
- 이 SKILL.md의 워크플로우와 완료 기준

## When to Use

- 사용자가 `$deep-goal-council` 또는 `/deep-goal-council`을 명시 호출할 때
- 현재 목표가 너무 작고 단기적이라고 느낄 때
- AI 도구, 에이전트, 하네스 운영 같은 역량을 장기 대표작으로 만들고 싶을 때
- 공부가 튜토리얼 소비로 끝나서 12주 커리큘럼이 필요할 때
- 개발, 디자인, 상담, 글쓰기, 소설가 되기 같은 표면에 공통으로 쓸 수 있는 장기 방향이 필요할 때
- 여러 팀이 서로 경쟁하고 비판한 결과물을 사용자가 직접 심사하고 싶을 때

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

빠진 맥락이 결과를 크게 바꾸면 최대 3개 질문만 한다. 질문 없이 진행 가능하면 `[Assumption]`으로 명시한다.

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

각 팀은 `references/output-contract.md`의 Team Proposal 형식을 따른다. 모든 제안은 반드시 포함한다.

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

## Test Prompts

다음 입력은 이 스킬의 대표 테스트 케이스다.

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

## Reference Routing

- Council 역할과 팀 차이를 설계할 때 `references/team-blueprints.md`를 읽는다.
- 출력 형식을 엄격히 맞출 때 `references/output-contract.md`를 읽는다.
- 상담/공부/개발/디자인/소설 표면에 맞게 바꿀 때 `references/surface-adapters.md`를 읽는다.

## Done Criteria

- 팀들이 서로 다른 철학으로 제안했는가?
- 각 팀에 Sentinel 비판이 포함됐는가?
- 1년 목표가 12주 캠페인과 7일 증거로 내려왔는가?
- 사용자가 심사할 수 있는 비교 매트릭스와 선택 질문이 있는가?
- 하나의 우승안뿐 아니라 혼합안도 제시했는가?
