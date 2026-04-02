---
name: review-loop
description: 코드 작성 후 3단계 체이닝 리뷰 (code-reviewer → architect → critic). 각 리뷰어가 이전 리뷰를 감시하며 보완. Trigger on "review-loop", "리뷰 루프", "리뷰 돌려", "코드 리뷰 루프", "리뷰하고 고쳐", "review and fix".
version: 2.0.0
---

# Review Loop

코드 변경 후 3명의 리뷰어가 체이닝 방식으로 리뷰한다.
각 리뷰어는 이전 리뷰어의 결과를 받아서 검증·반박·보완한다.
CRITICAL/HIGH 이슈가 있으면 수정 후 다시 체이닝을 돌린다.

```
code-reviewer → architect → critic
     ↓ 결과 전달     ↓ 결과 전달     ↓ 최종 판정
  정확성/품질     설계/구조 검증   사각지대/과잉지적 감시
```

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

### Step 2: 1차 리뷰 — code-reviewer (정확성)

code-reviewer 에이전트를 소환한다.

```
Agent(subagent_type="plugin-mh:code-reviewer")
```

프롬프트:
- 변경 목적과 맥락
- 변경된 파일 목록
- 리뷰 관점: **스펙 충족, 로직 결함, 엣지케이스, 코드 품질, 성능**

code-reviewer의 결과를 `R1_RESULT`로 저장한다.

### Step 3: 2차 리뷰 — architect (설계 검증)

architect 에이전트를 소환한다. **R1_RESULT를 함께 전달한다.**

```
Agent(subagent_type="oh-my-claudecode:architect")
```

프롬프트:
- 변경 목적과 맥락
- 변경된 파일 목록
- **code-reviewer의 리뷰 결과 (R1_RESULT)**
- 리뷰 관점: **아키텍처 적합성, 의존성 방향, 기존 패턴 일관성, 커플링**
- 지시: "code-reviewer의 지적 중 동의하지 않는 부분이 있으면 반박하고, 놓친 설계 이슈를 추가하라"

architect의 결과를 `R2_RESULT`로 저장한다.

### Step 4: 3차 리뷰 — critic (최종 감시)

critic 에이전트를 소환한다. **R1_RESULT + R2_RESULT를 함께 전달한다.**

```
Agent(subagent_type="oh-my-claudecode:critic")
```

프롬프트:
- 변경 목적과 맥락
- 변경된 파일 목록
- **code-reviewer 리뷰 결과 (R1_RESULT)**
- **architect 리뷰 결과 (R2_RESULT)**
- 리뷰 관점: **이전 2명이 놓친 사각지대, 과잉 지적(severity 부풀리기) 감시, 이슈 간 모순 검출**
- 지시: "이전 리뷰어들의 지적을 종합하여 최종 이슈 목록과 verdict를 내려라. 과잉 지적은 severity를 낮추고, 놓친 이슈는 추가하라."

critic의 결과가 최종 판정이다.

### Step 5: 판정 및 수정

critic의 최종 verdict를 확인:

- **APPROVE**: 체이닝 종료. 사용자에게 최종 결과 보고.
- **COMMENT** (LOW/MEDIUM만): MEDIUM 2개 이상이면 수정 후 재체이닝.
- **REQUEST CHANGES** (CRITICAL/HIGH 있음): 반드시 수정 후 재체이닝.

수정 원칙:
- 3명의 리뷰어가 공통으로 지적한 이슈 최우선
- CRITICAL/HIGH는 반드시 수정
- MEDIUM은 2명 이상 동의하면 수정
- 한 명만 지적한 LOW는 선택적
- 리뷰어 간 의견이 충돌하면 critic의 판정을 따름
- 수정 후 lint/타입체크/빌드 검증 필수

### Step 6: 재체이닝 (최소 5회)

- **최소 5회 체이닝 필수.** APPROVE가 나와도 5회 전이면 Step 2부터 다시 돌린다. 이전 체이닝에서 못 잡은 이슈가 다음 체이닝에서 발견될 수 있다.
- REQUEST CHANGES → 수정 후 Step 2부터 다시 체이닝.
- 5회 이후 APPROVE → 종료. 사용자에게 최종 보고.

## Output Format

```
## Review Loop 결과

### 체이닝 요약
| Chain | code-reviewer | architect | critic (최종) |
|-------|---------------|-----------|---------------|
| 1     | REQUEST CHANGES (H:1 M:2) | COMMENT (M:1 추가) | REQUEST CHANGES (H:1 M:2) |
| 2     | APPROVE | APPROVE | APPROVE |

### 리뷰어 간 상호작용
- architect가 code-reviewer의 [MEDIUM] DRY 위반 지적에 동의, severity를 HIGH로 상향
- critic이 code-reviewer의 [LOW] 네이밍 지적을 과잉으로 판단, 제외

### 수정 내역
- [HIGH] {파일}:{라인} — {이슈} → {수정 내용} (code-reviewer + architect 공통 지적)
- [MEDIUM] {파일}:{라인} — {이슈} → {수정 내용} (critic 추가 발견)

### 최종 상태
APPROVE — 3명 리뷰어 전원 동의
```

## Constraints

- 리뷰어와 수정자는 반드시 별도 에이전트 (자기 코드 자기 리뷰 금지)
- 체이닝 순서 고정: code-reviewer → architect → critic (순서 변경 금지)
- 각 리뷰어는 이전 리뷰어의 결과를 반드시 전달받아야 함
- 수정 후 반드시 lint/타입체크 통과 확인
- 리뷰어의 지적을 무시하지 않음 — 수정하지 않을 경우 사유를 명시
- 리뷰어 간 의견 충돌 시 critic의 판정이 최종
