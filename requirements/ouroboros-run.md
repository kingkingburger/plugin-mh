# ouroboros-run 요구사항

## Before (Original)
> "ouroboros로 만든 계획을 ralph 형태의 자기참조 루프로 실행하는 새 스킬을 만들려고 함. ouroboros는 계획만, 새 스킬은 실행 담당."

## After (Clarified)

### Goal
ouroboros가 생산한 문서(요구사항/설계/검증)를 입력으로 받아, 설계의 파일별 구현 계획을 story 단위로 분해하고, **3역할 분리(Planner-Generator-Evaluator)** 구조로 순차 구현→검증하는 자기참조 루프 스킬.

### 아키텍처 (harness 패턴 차용)

```
ouroboros 문서 (Planner 역할 — 이미 완료)
  ↓
Phase 0: 문서 감지 + story 분해 → stories.json
  ↓
Story 루프 (순차)
  ┌─────────────────────────────────────────────┐
  │ Generator (sonnet) → story 구현              │
  │   ↓                                          │
  │ Evaluator (opus) → 03-verification.md 기준   │
  │   검증 + acceptance criteria 판정            │
  │   ↓                                          │
  │ FAIL → 피드백 → Generator 재호출 (max 3회)   │
  │ PASS → story.passes = true → 다음 story      │
  └─────────────────────────────────────────────┘
  ↓
전체 완료 후: review-loop 체이닝 (최종 품질 검증)
  ↓
최종 보고
```

### 3역할 분리 원칙 (harness에서 차용)

| 역할 | 담당 | 핵심 규칙 |
|------|------|-----------|
| **Planner** | ouroboros (외부) | "무엇(WHAT)"만 정의. 이미 완료된 문서를 입력으로 받음 |
| **Generator** | sonnet 에이전트 | story 계약에 따라 코드 구현. 스펙 외 판단 금지 |
| **Evaluator** | opus 에이전트 | 03-verification.md 기준으로 깐깐하게 검증. 관대한 평가 금지 |

> "만드는 쪽과 평가하는 쪽을 분리하고, 평가자를 깐깐하게 튜닝하는 것이 품질의 핵심 레버." — harness 설계 근거

### Scope

**포함:**
- ouroboros 문서 자동 감지 (`docs/ouroboros/{date}-{slug}/`)
- 범용 계획 문서 폴백 (사용자 지정 md)
- 02-design.md 파일별 구현 계획 → stories.json 자동 변환
- 03-verification.md → acceptance criteria 매핑
- Generator-Evaluator 피드백 루프 (스프린트당 최대 3회)
- 전체 완료 후 review-loop 체이닝
- JSON 상태 추적 (stories.json, stories[].passes)

**제외:**
- OMC 의존성 (prd.json/state_write/ultrawork)
- 병렬 story 실행
- ouroboros 문서 자체 생성 (이건 ouroboros 스킬의 역할)

### Decisions

| Question | Decision |
|----------|----------|
| 스킬 이름 | `ouroboros-run` |
| 입력 범위 | ouroboros 우선 + 범용 폴백 |
| 실행 단위 | 파일별 구현 계획 → story |
| 검증 방식 | 03-verification 기반 (Evaluator) + review-loop 결합 |
| 의존성 | plugin-mh 독립 |
| 실행 순서 | 순차 실행 |
| 상태 저장 | JSON (stories[].passes) |
| 아키텍처 | harness의 Planner-Generator-Evaluator 3역할 분리 |

### Success Criteria

1. ouroboros 산출물 경로를 자동 감지하여 stories.json으로 변환
2. Generator(sonnet)가 story 계약에 따라 구현
3. Evaluator(opus)가 03-verification.md 기준으로 검증, PASS/FAIL 판정
4. FAIL 시 피드백과 함께 Generator 재호출 (최대 3회)
5. 모든 story PASS 후 review-loop으로 최종 품질 검증
6. 전체 프로세스가 OMC 없이 plugin-mh만으로 동작
