---
name: grill-me
description: Relentlessly interview the user about a plan or design until the decision tree is clear. Trigger on "grill me", "grill-me", "계획을 까다롭게 질문해줘", "설계 압박 질문", "stress-test my plan". Use before implementation when the user wants pointed planning questions instead of a full spec workflow.
version: 1.0.0
allowed-tools:
  - AskUserQuestion
  - Read
  - Glob
  - Grep
  - Bash
user-invocable: true
---

# Grill Me

사용자의 계획이나 설계를 곧바로 구현하지 말고, 결정 트리가 닫힐 때까지 짧고 날카로운 질문으로 압박한다. 목적은 큰 문서 시스템을 만드는 것이 아니라, 구현 전에 위험한 가정과 선택지를 빠르게 드러내는 것이다.

## When to Use

- 사용자가 "grill me", "grill-me", "계획을 까다롭게 질문해줘", "설계 압박 질문", "stress-test my plan"처럼 계획 검증을 요청할 때
- 구현 전에 요구사항, 설계, 범위, trade-off를 짧게 점검하고 싶을 때
- `/vague`나 `/ouroboros`보다 가벼운 인터뷰가 충분할 때

## Workflow

### 1. Establish the Target

사용자의 원래 계획을 한두 문장으로 재진술하고, 어떤 결정이 아직 열려 있는지 식별한다. 계획이 코드베이스 사실로 확인 가능한 주장에 의존하면 먼저 파일을 탐색한다.

### 2. Ask in Small Batches

한 번에 1-3개 질문만 한다. 각 질문에는 추천 답변을 함께 붙여 사용자가 빠르게 수락, 수정, 거절할 수 있게 한다.

Claude에서는 `AskUserQuestion`을 사용하고, Codex에서는 변환본이 `request_user_input`을 사용한다. 도구가 없는 환경에서는 같은 질문을 번호 선택지로 제시하고 답변을 기다린다.

```
AskUserQuestion:
  questions:
    - question: "{결정을 가르는 구체 질문}"
      header: "{짧은 라벨}"
      options:
        - label: "{추천 선택지} (Recommended)"
          description: "{이 선택지가 만드는 결과와 trade-off}"
        - label: "{대안}"
          description: "{대안의 결과와 trade-off}"
```

질문은 열린 호기심이 아니라 결정을 좁히는 형태여야 한다. "어떻게 하고 싶나요?"보다 "A를 택하면 X가 쉬워지고 Y를 포기합니다. B를 택하면 반대입니다. 어느 쪽인가요?"처럼 묻는다.

### 3. Explore Instead of Asking

다음 항목은 사용자에게 묻기 전에 저장소에서 먼저 확인한다.

- 이미 존재하는 API, 타입, 데이터 모델, 라우팅, 테스트
- 현재 문서나 ADR에 적힌 정책
- 빌드/런타임 제약
- 비슷한 기능의 기존 패턴

확인한 사실과 사용자의 계획이 충돌하면 바로 말하고, 어떤 쪽을 기준으로 삼을지 질문한다.

### 4. Resolve Dependencies

답변을 받을 때마다 후속 결정이 생기면 다음 질문 배치로 이어간다. 이미 답변된 결정에 의존하는 질문을 먼저 던지고, 독립적인 질문은 묶는다.

## Stop Criteria

다음 조건을 모두 만족하면 인터뷰를 멈춘다.

- 구현 결과를 바꾸는 주요 선택지가 닫혔다.
- 남은 불확실성은 구현 중 로컬 판단으로 처리해도 결과가 크게 달라지지 않는다.
- success criteria와 검증 방법이 한 문장 이상으로 설명된다.
- 건드리지 말아야 할 범위가 명확하다.

## Output

마지막에는 짧게 정리한다.

```text
결정:
- ...

가정:
- ...

검증 기준:
- ...

남은 질문:
- 없음 / ...
```
