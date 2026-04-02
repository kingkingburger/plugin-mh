---
name: review-loop
description: 코드 작성 후 자동 리뷰 루프. code-reviewer 에이전트가 평가 → 지적사항 수정 → 재리뷰 반복. Trigger on "review-loop", "리뷰 루프", "리뷰 돌려", "코드 리뷰 루프", "리뷰하고 고쳐", "review and fix".
version: 1.0.0
---

# Review Loop

코드 변경 후 code-reviewer 에이전트로 리뷰 → 수정 → 재리뷰를 APPROVE될 때까지 반복하는 스킬.

## When to Use

- 코드 작성/수정 완료 후 품질 검증이 필요할 때
- "리뷰 루프", "review-loop", "리뷰 돌려", "코드 리뷰 루프" 요청 시
- 사용자가 "고치고 다시 리뷰해" 류의 반복 검증을 요구할 때

## Workflow

### Step 1: 변경 범위 파악

```
git diff --name-only
```

변경된 파일 목록과 변경 목적을 정리한다. 변경 파일이 없으면 사용자에게 확인.

### Step 2: 리뷰 요청 (Round 1)

code-reviewer 에이전트를 소환하여 리뷰를 요청한다.

```
Agent(subagent_type="plugin-mh:code-reviewer")
```

프롬프트에 반드시 포함:
- 변경 목적과 맥락
- 변경된 파일 목록
- 리뷰 포인트 (로직 결함, 엣지케이스, 보안, 성능, 코드 품질)

### Step 3: 리뷰 결과 판단

리뷰어의 verdict를 확인:

- **APPROVE**: 루프 종료. 사용자에게 최종 결과 보고.
- **COMMENT** (LOW/MEDIUM만): 수정 여부를 판단. MEDIUM이 2개 이상이면 수정 후 재리뷰.
- **REQUEST CHANGES** (CRITICAL/HIGH 있음): 반드시 수정 후 재리뷰.

### Step 4: 수정 (Fix)

리뷰어가 지적한 이슈를 severity 높은 순으로 수정한다.

수정 원칙:
- CRITICAL/HIGH는 반드시 수정
- MEDIUM은 합리적이면 수정, 아니면 사유를 남김
- LOW는 선택적
- 수정 후 lint/타입체크/빌드 검증 필수

### Step 5: 재리뷰 (Round N)

수정 완료 후 code-reviewer 에이전트를 다시 소환한다.

프롬프트에 포함:
- 이전 라운드의 지적사항
- 각 지적사항에 대한 수정 내용
- 새로운 변경 파일이 있으면 포함

### Step 6: 반복 또는 종료

- **최소 5라운드 필수.** APPROVE가 나와도 5라운드 전이면 계속 리뷰한다. 이전 라운드에서 못 잡은 이슈가 있을 수 있다.
- 5라운드 이후 APPROVE → 종료. 사용자에게 최종 보고.
- REQUEST CHANGES → Step 4로 돌아감.

## Output Format

```
## Review Loop 결과

### 라운드 요약
| Round | Verdict | CRITICAL | HIGH | MEDIUM | LOW |
|-------|---------|----------|------|--------|-----|
| 1     | REQUEST CHANGES | 0 | 1 | 2 | 1 |
| 2     | APPROVE | 0 | 0 | 0 | 1 |

### 수정 내역
- [HIGH] {파일}:{라인} — {이슈} → {수정 내용}
- [MEDIUM] {파일}:{라인} — {이슈} → {수정 내용}

### 최종 상태
APPROVE — 모든 CRITICAL/HIGH 이슈 해결됨
```

## Constraints

- 리뷰어와 수정자는 반드시 별도 에이전트 (자기 코드 자기 리뷰 금지)
- 수정 후 반드시 lint/타입체크 통과 확인
- 최소 5라운드 필수 — APPROVE가 일찍 나와도 5라운드까지 반복
- 리뷰어의 지적을 무시하지 않음 — 수정하지 않을 경우 사유를 명시
