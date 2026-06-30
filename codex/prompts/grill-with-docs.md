# /grill-with-docs — Grill With Docs

`$ARGUMENTS`에 담긴 계획을 집요하게 질문하되, 질문의 기준을 저장소의 기존 언어와 결정 기록에 둔다. 사용자의 답변으로 도메인 용어가 확정되면 `CONTEXT.md`에 반영하고, 되돌리기 어려운 trade-off가 확정되면 ADR 작성을 제안한다.

> Codex CLI 슬래시 커맨드로 호출되거나 자연어로 트리거된다. 가능하면 `request_user_input` 도구를 사용하고, 제공되지 않는 세션에서는 같은 질문을 번호 선택지로 제시한 뒤 답변을 기다린다.

## When to Use

- 사용자가 "grill with docs", "grill-with-docs", "도메인 문서 기준으로 점검", "문서랑 맞춰 질문", "ADR까지 정리"처럼 문서와 함께 계획을 검증하길 원할 때
- 새 기능 계획이 기존 glossary, bounded context, ADR, 코드 현실과 충돌할 가능성이 있을 때
- 단순 명확화보다 domain language 정리가 더 중요한 설계 대화일 때

## Workflow

### 1. Locate Domain Sources

먼저 저장소에서 다음 파일을 찾는다.

- 루트 `CONTEXT-MAP.md`
- 루트 또는 하위 컨텍스트의 `CONTEXT.md`
- 루트 또는 하위 컨텍스트의 `docs/adr/`
- 관련 코드, 테스트, API, schema

`CONTEXT-MAP.md`가 있으면 여러 컨텍스트가 있다고 보고, 사용자 계획이 어느 컨텍스트에 속하는지 먼저 확인한다. 없으면 가장 가까운 `CONTEXT.md`와 `docs/adr/`를 기준으로 삼는다.

### 2. Ask Like `/grill-me`

한 번에 1-3개 질문만 한다. 각 질문에는 추천 답변을 포함한다.

`request_user_input`이 있으면 다음 구조를 사용한다.

- `questions`: 1-3개
- 각 질문의 첫 번째 option은 추천안이며 label 끝에 `(Recommended)`를 붙인다.
- 각 option description에는 도메인 언어, 구현, 문서에 미치는 영향을 한 문장으로 적는다.
- 답변을 받은 뒤 문서나 후속 질문으로 이어간다.

질문이 코드나 문서로 답해질 수 있으면 먼저 탐색한다. 사용자의 발언이 문서나 코드와 충돌하면 그 충돌을 질문의 출발점으로 삼는다.

### 3. Challenge the Language

다음 상황을 즉시 다룬다.

- 사용자가 `CONTEXT.md`의 기존 용어와 다른 의미로 같은 단어를 쓸 때
- "account", "user", "customer", "item", "cancel"처럼 흔한 단어가 여러 모델을 가리킬 수 있을 때
- 코드가 실제로 허용하는 동작과 사용자가 말하는 도메인 규칙이 다를 때
- 특정 관계나 상태 전이가 edge case에서 모호해질 때

질문은 반드시 구체 시나리오를 포함한다. 예를 들어 "부분 취소가 가능하다면 이미 배송된 line item과 결제 환불은 어떤 순서로 처리되나요?"처럼 경계를 드러내는 사례를 만든다.

### 4. Update `CONTEXT.md` Inline

용어가 확정되면 바로 `CONTEXT.md`를 갱신한다. 파일이 없으면 첫 확정 용어가 생겼을 때 생성한다. 구현 세부, API 계약, 데이터베이스 구조, TODO는 넣지 않는다. `CONTEXT.md`는 glossary 전용이다.

형식은 `references/context-format.md`를 따른다.

### 5. Offer ADRs Sparingly

ADR은 다음 세 조건을 모두 만족할 때만 제안한다.

1. 되돌리기 어렵다.
2. 맥락 없이 보면 미래 독자가 놀랄 수 있다.
3. 실제 대안과 trade-off가 있었다.

조건 중 하나라도 부족하면 ADR을 만들지 않는다. ADR이 필요하면 `references/adr-format.md`를 따른다.

## Stop Criteria

- 주요 도메인 용어와 경계가 `CONTEXT.md` 기준으로 정리됐다.
- 구현 결과를 바꾸는 결정과 trade-off가 닫혔다.
- ADR이 필요한 결정과 필요 없는 결정을 구분했다.
- 남은 질문과 문서 변경 사항을 짧게 요약할 수 있다.

## Output

```text
확정된 용어:
- ...

결정:
- ...

문서 변경:
- CONTEXT.md: ...
- ADR: 생성함 / 생성하지 않음

남은 질문:
- 없음 / ...
```

## 참조 파일 위치

이 프롬프트가 언급하는 `references/...` 파일은 plugin-mh 저장소의 `skills/grill-with-docs/references/` 에 있다. Codex CLI에서 사용 시 해당 경로를 직접 Read 하면 된다.
