# /review-loop — Review Loop: Tiered 리뷰 루프

코드 변경 후 Tiered(점층) 방식으로 리뷰한다. 작은 이슈면 1명만, 심각하면 3명 병렬.

> Codex CLI 슬래시 커맨드로 호출되거나 자연어로 트리거된다. `$ARGUMENTS`에 사용자 입력이 주입된다.

```
[Fast Path]
code-reviewer 관점 ──┐
                     ├─ APPROVE/LOW만 → 종료
                     └─ MEDIUM↑ 발견 → [Deep Path]
                                           ├─ architect 관점 ─┐
                                           └─ critic 관점 ────┴─ 최종 판정
                                               (동시 작성)
```

핵심 변경 (v3):
- **Tiered**: 1차는 code-reviewer 관점 단독. 가벼운 변경에서 architect/critic 비용 제거.
- **병렬**: Deep Path 진입 시 architect와 critic 관점을 한 응답에서 동시에 작성.
- **부분 재리뷰**: 재체이닝 시 변경 파일 + 영향받는 호출처만 검토.
- **캡 단축**: 5회 → 3회 (대부분 2회 안에 수렴).

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
첫 사이클에서는 전체 변경 파일이 대상이다.

### Step 2: Fast Path — code-reviewer 관점 리뷰

이 단계에서는 **code-reviewer**처럼 사고하세요.

다음 분석을 직접 수행하세요:
- 변경 목적과 맥락
- 변경된 파일 목록 (1차) 또는 부분 재리뷰 대상 (재체이닝)
- 리뷰 관점: **스펙 충족, 로직 결함, 엣지케이스, 코드 품질, 성능**

결과를 `R1_RESULT`로 저장.

### Step 3: 분기 게이트

R1_RESULT를 분석하여 분기:

- **APPROVE 또는 LOW 이슈만** → Step 6으로 (Fast Path 종료, 즉시 보고).
- **MEDIUM/HIGH/CRITICAL 이슈 1개 이상** → Step 4로 (Deep Path 진입).

이 게이트가 핵심 속도 개선 포인트다. 가벼운 변경에서 architect/critic 분석을 건너뛴다.

### Step 4: Deep Path — architect + critic 관점 동시 작성

**한 응답에서 두 관점을 동시에 작성한다 (병렬).** 각자에게 R1_RESULT를 함께 전달.

두 관점을 한 메시지에서 동시에 작성하세요:

**architect 관점** (이 단계에서는 **architect**처럼 사고하세요):
- 변경 목적과 맥락 + 변경 파일 목록
- **code-reviewer 리뷰 결과 (R1_RESULT)**
- 리뷰 관점: **아키텍처 적합성, 의존성 방향, 기존 패턴 일관성, 커플링**
- 지시: "code-reviewer의 지적 중 동의하지 않는 부분이 있으면 반박하고, 놓친 설계 이슈를 추가하라"

**critic 관점** (이 단계에서는 **critic**처럼 사고하세요):
- 변경 목적과 맥락 + 변경 파일 목록
- **code-reviewer 리뷰 결과 (R1_RESULT)**
- 리뷰 관점: **사각지대 발굴, 과잉 지적(severity 부풀리기) 감시, 이슈 간 모순 검출**
- 지시: "code-reviewer의 지적을 종합 검증하라. 과잉이면 severity를 낮추고, 놓친 이슈는 추가하라. 최종 verdict를 내려라."

병렬 결과를 각각 `R2_ARCH`, `R2_CRITIC`으로 저장.

### Step 5: 최종 판정 통합

critic의 verdict가 최종 판정. 단, architect가 새로 발견한 설계 이슈는 critic verdict에 추가 병합:

- critic이 R1+자기 리뷰 기반으로 verdict 산출
- architect가 발견한 설계 이슈가 critic 결과에 누락됐으면 합침
- 충돌 시 critic 우선

### Step 6: 판정 → 수정 → 재체이닝

판정에 따라 분기:

- **APPROVE**: 종료. 사용자에게 최종 결과 보고.
- **COMMENT (LOW만)**: 종료. 선택적 수정사항만 보고.
- **REQUEST CHANGES (CRITICAL/HIGH 또는 MEDIUM 2개 이상)**: 수정 후 재체이닝.

수정 원칙:
- CRITICAL/HIGH는 반드시 수정
- MEDIUM은 2명 이상 동의하면 수정
- 한 명만 지적한 LOW는 선택적
- 충돌 시 critic 판정 우선
- 수정 후 lint/타입체크/빌드 검증 필수

**재체이닝 범위 (부분 재리뷰)**:
- 수정한 파일 + 그 파일을 import/호출하는 인접 호출처만 대상
- `git diff --name-only HEAD` + Grep으로 호출처 식별
- 인접 호출처가 5개를 넘으면 직접 영향만 (2-hop 금지)
- Step 2부터 다시 시작 (Fast Path → 필요시 Deep Path)

**최대 3회 캡**. 3회 후에도 APPROVE가 안 나오면 현재 상태로 종료하고 미해결 이슈를 보고.

## Output Format

```
## Review Loop 결과

### 체이닝 요약
| Cycle | Path | code-reviewer | architect | critic (최종) |
|-------|------|---------------|-----------|---------------|
| 1     | Deep | REQUEST CHANGES (H:1 M:2) | COMMENT (M:1 추가) | REQUEST CHANGES (H:1 M:2) |
| 2     | Fast | APPROVE | — | — |

### 리뷰어 간 상호작용
- architect가 code-reviewer의 [MEDIUM] DRY 위반 지적에 동의, severity를 HIGH로 상향
- critic이 code-reviewer의 [LOW] 네이밍 지적을 과잉으로 판단, 제외

### 수정 내역
- [HIGH] {파일}:{라인} — {이슈} → {수정 내용} (code-reviewer + architect 공통 지적)
- [MEDIUM] {파일}:{라인} — {이슈} → {수정 내용} (critic 추가 발견)

### 최종 상태
APPROVE — 2 cycle, 1 Deep + 1 Fast
```

## Constraints

- 리뷰어와 수정자는 반드시 별도 관점 (자기 코드 자기 리뷰 금지)
- Fast Path → Deep Path 승급은 일방향 (Deep에서 Fast로 다시 내려가지 않음)
- Deep Path의 architect + critic은 반드시 한 응답에서 동시에 작성 (직렬 금지)
- 재체이닝 시 변경 파일과 인접 호출처만 — 전체 재스캔 금지
- 수정 후 반드시 lint/타입체크 통과 확인
- 리뷰어의 지적을 무시하지 않음 — 수정하지 않을 경우 사유를 명시
- 리뷰어 간 의견 충돌 시 critic의 판정이 최종
- 최대 3 cycle. 초과 시 미해결 이슈 명시하고 종료.
