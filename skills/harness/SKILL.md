---
name: harness
version: 1.0.0
description: >
  OpenAI의 하네스 엔지니어링 개념을 기반으로 프로젝트의 엔지니어링 문서 체계를 한번에 구축한다.
  인터뷰 → 코드 분석 → 에이전트 병렬 생성으로 AGENTS.md, ARCHITECTURE.md, docs/ 전체 구조를 생성.
  새 프로젝트 부트스트랩, 기존 코드 분석 기반 생성, 기존 문서 보완 모두 지원.
  Trigger on "harness", "하네스", "문서 체계", "엔지니어링 문서", "프로젝트 구조",
  "docs 구조", "harness engineering", "하네스 엔지니어링".
allowed-tools:
  - Agent
  - AskUserQuestion
  - Read
  - Glob
  - Grep
  - Write
  - Edit
  - Bash
---

# Harness Engineering — 프로젝트 하네스 구축

프로젝트의 엔지니어링 문서 체계를 **인터뷰 → 코드 분석 → 에이전트 병렬 생성**으로 한번에 구축하는 스킬.

> **하네스 엔지니어링**: "에이전트가 할 수 있는 것을 제한하고, 해야 할 일을 알려주고,
> 올바르게 수행했는지 검증하고, 오류 시 수정하는 시스템 설계." — OpenAI
>
> 3명의 엔지니어가 5개월간 백만 줄의 코드를 에이전트만으로 작성한 방법론의 핵심은
> **구조화된 문서 체계**에 있다.

## Three Pillars

| 기둥 | 역할 | 이 스킬이 생성하는 것 |
|------|------|---------------------|
| **Context Engineering** | 에이전트에게 프로젝트 맥락 제공 | AGENTS.md, ARCHITECTURE.md, design-docs/, product-specs/ |
| **Architectural Constraints** | 의존성 방향, 계층 규칙, 설계 원칙 정의 | ARCHITECTURE.md, DESIGN.md, SECURITY.md |
| **Entropy Management** | 코드베이스 건강성 유지, 기술 부채 추적 | exec-plans/, tech-debt-tracker.md, RELIABILITY.md |

## 지원 시나리오

| 시나리오 | 동작 |
|---------|------|
| **새 프로젝트** (코드 없음) | 인터뷰 기반 전체 구조 + 초안 생성 |
| **기존 프로젝트** (문서 없음) | 코드 분석 + 인터뷰 → 전체 구조 생성 |
| **기존 프로젝트** (문서 있음) | 기존 문서 분석 → 빈 부분만 보완 |

---

## 생성 구조

```
{project-root}/
├── AGENTS.md
├── ARCHITECTURE.md
└── docs/
    ├── design-docs/
    │   ├── index.md
    │   ├── core-beliefs.md
    │   └── adr/
    │       └── 0001-template.md
    ├── exec-plans/
    │   ├── active/
    │   ├── completed/
    │   └── tech-debt-tracker.md
    ├── product-specs/
    │   ├── index.md
    │   └── (프로젝트별 스펙)
    ├── references/
    ├── generated/
    ├── DESIGN.md
    ├── FRONTEND.md              ← 프론트엔드 프로젝트만
    ├── PLANS.md
    ├── SECURITY.md
    └── RELIABILITY.md
```

---

## 파일 역할 정의

### 루트 파일

| 파일 | 역할 | Pillar | 생성 조건 |
|------|------|--------|-----------|
| `AGENTS.md` | AI 에이전트 행동 지침. 빌드/테스트 명령, 코드 컨벤션, 금지 사항, 일반적인 함정. 에이전트가 실수할 때마다 업데이트하는 **피드백 루프**. 깊은 컨텍스트는 docs/ 하위 문서를 가리키는 포인터로 연결. | Context | 항상 |
| `ARCHITECTURE.md` | 시스템 아키텍처 개요. 컴포넌트 구조(ASCII 다이어그램), 데이터 흐름, 의존성 계층(Types → Config → Repo → Service → Runtime → UI), 기술 스택 선택 이유, 배포 구조. | Constraints | 항상 |

### docs/ 진입점 문서

각 하위 폴더의 개요 겸 진입점. 해당 주제의 전체 그림을 빠르게 파악하는 데 사용.

| 파일 | 역할 | Pillar | 생성 조건 |
|------|------|--------|-----------|
| `docs/DESIGN.md` | 설계 철학, UI/UX 원칙, 디자인 시스템 요약, 코드 스타일 & 네이밍 컨벤션. `design-docs/` 진입점. | Constraints | 항상 |
| `docs/FRONTEND.md` | 프론트엔드 가이드. 컴포넌트 구조, 스타일 컨벤션, 상태 관리 패턴, 빌드 & 번들링 설정. | Constraints | 프론트엔드 있을 때 |
| `docs/PLANS.md` | 로드맵, 마일스톤, 현재 우선순위, 기능 백로그 개요. `exec-plans/` 진입점. | Entropy | 항상 |
| `docs/SECURITY.md` | 보안 정책. 인증/인가 모델, 데이터 보호(전송 중/저장 시), 의존성 보안, 취약점 대응. | Constraints | 항상 |
| `docs/RELIABILITY.md` | 안정성 기준. 에러 처리 전략, 모니터링 & 알림, SLA/SLO, 장애 대응 절차(runbook). | Entropy | 항상 |

### docs/design-docs/ — 설계 문서

| 파일 | 역할 |
|------|------|
| `index.md` | 설계 원칙 목록 & 문서 색인. 새 설계 문서 추가 시 여기에 링크 등록. |
| `core-beliefs.md` | 핵심 기술 철학. "우리가 믿는 것" — 각 원칙에 근거(evidence)와 반례(counter-example) 포함. |
| `adr/0001-template.md` | Architecture Decision Record 템플릿. 맥락-결정-대안-결과 형식으로 아키텍처 결정을 기록. |

### docs/exec-plans/ — 실행 계획

| 항목 | 역할 |
|------|------|
| `active/` | 현재 진행 중인 실행 계획. 마일스톤별 또는 에픽별 계획 문서 저장. |
| `completed/` | 완료된 계획 아카이브. 과거 결정의 맥락을 보존. |
| `tech-debt-tracker.md` | 기술 부채 목록. 영향도 × 수정 난이도 매트릭스로 우선순위 관리. |

### docs/product-specs/ — 제품 스펙

| 항목 | 역할 |
|------|------|
| `index.md` | 제품 비전, 타겟 사용자, 핵심 가치 제안, 성공 지표(KPI). Product Sense 통합 문서. |
| `(프로젝트별 스펙)` | 기능별 PRD, 사용자 시나리오, 수용 기준. 필요 시 추가. |

### docs/references/ — 외부 참조

외부 라이브러리/프레임워크의 참조 문서 저장소.
AI 에이전트에게 기술 스택 컨텍스트를 제공하기 위한 llms.txt 등을 보관.

### docs/generated/ — 자동 생성 문서

코드/스키마에서 자동 추출된 문서. DB 스키마, API 문서, 타입 정의, 의존성 그래프 등.
**수동 편집 금지** — 재생성 시 덮어쓰기됨.

---

## 워크플로우

```
Phase 0: 탐지 & 스캔
  ↓
Phase 1: 적응형 인터뷰 (3-4개 → 필요시 심화)
  ↓
Phase 2: 코드베이스 분석 (기존 프로젝트)
  ↓
Phase 3: 에이전트 병렬 생성
  ↓
Phase 4: 보고
```

### Phase 0: 탐지 & 스캔

프로젝트 상태를 자동 감지한다.

1. **프로젝트 파일 스캔**:
   ```
   Glob: package.json, pyproject.toml, Cargo.toml, go.mod, *.csproj, pom.xml
   Glob: AGENTS.md, ARCHITECTURE.md, docs/**/*.md
   Glob: src/**/*.{ts,tsx,js,jsx,py,go,rs}, app/**/*
   ```

2. **상태 판별**:

   | 신호 | 판별 | 다음 단계 |
   |------|------|----------|
   | 코드 없음 + 문서 없음 | 새 프로젝트 | Phase 1 (전체 인터뷰) |
   | 코드 있음 + 문서 없음 | 기존 프로젝트 | Phase 1 → Phase 2 |
   | 코드 있음 + 문서 있음 | 보완 모드 | Phase 1 (축소) → Phase 2 |

3. **기존 문서 존재 시**: 각 파일을 Read → 빈 섹션/누락 파일 목록 작성

### Phase 1: 적응형 인터뷰

> 가볍게 시작하고, 답변에 따라 필요한 만큼만 심화한다. **총 질문 상한: 8개.**

**Round 1 (항상, 3-4개)**:

```
AskUserQuestion:
questions:
  - question: "이 프로젝트의 핵심 목적은 무엇인가요?"
    header: "목적"
    options:
      - label: "웹 서비스/SaaS"
        description: "사용자에게 서비스를 제공하는 웹 앱"
      - label: "라이브러리/패키지"
        description: "다른 개발자가 사용하는 라이브러리"
      - label: "CLI/데스크탑 앱"
        description: "로컬에서 실행하는 도구"
      - label: "API/백엔드 서비스"
        description: "다른 시스템이 호출하는 서비스"
    multiSelect: false
  - question: "프로젝트의 현재 단계는?"
    header: "단계"
    options:
      - label: "구상 중 (코드 없음)"
        description: "아이디어 단계, 아직 코드 작성 전"
      - label: "초기 개발"
        description: "핵심 기능 구현 중, MVP 전"
      - label: "운영 중"
        description: "이미 사용자가 있는 상태"
      - label: "리팩토링/마이그레이션"
        description: "기존 시스템을 개선하는 중"
    multiSelect: false
  - question: "주요 기술 스택은? (Phase 0에서 감지 실패 시)"
    header: "스택"
    options:
      - label: "감지된 스택이 맞음"
        description: "{Phase 0에서 감지한 기술 스택 나열}"
      - label: "직접 입력"
        description: "Other로 기술 스택을 알려주세요"
    multiSelect: false
```

보완 모드에서는 R1을 축소: "어떤 부분이 부족하다고 느끼나요?" 등 1-2개 질문만.

**Round 2 (조건부, R1 답변 기반)**:

| R1 답변 | R2 질문 방향 |
|---------|-------------|
| 웹 서비스/SaaS | 인증 모델, 배포 환경, 프론트엔드 프레임워크 |
| 라이브러리/패키지 | API 설계 원칙, 지원 환경, 문서화 대상 |
| CLI/데스크탑 | 설치 방식, 플랫폼 지원, 설정 관리 |
| API/백엔드 | 데이터 모델, 인증, 확장성 요구 |
| 운영 중 | 현재 장애 패턴, 모니터링 현황, 기술 부채 |

R2도 AskUserQuestion으로 2-3개 질문.

### Phase 2: 코드베이스 분석

기존 코드가 있을 때만 실행. 에이전트에게 넘길 컨텍스트를 수집한다.

```
Agent:
  subagent_type: "Explore"
  description: "코드베이스 구조 분석"
  prompt: |
    이 프로젝트의 코드베이스를 분석하세요.

    수집할 정보:
    1. 디렉토리 구조 (주요 폴더와 역할)
    2. 진입점 파일 (main, index, app 등)
    3. 기술 스택 & 주요 의존성
    4. 아키텍처 패턴 (MVC, layered, microservices 등)
    5. 데이터 모델/스키마 (있다면)
    6. API 엔드포인트 (있다면)
    7. 테스트 구조 (있다면)
    8. 보안 관련 코드 (인증, 인가)
    9. 설정/환경변수 관리
    10. 의존성 계층 방향

    간결하게 요약하되, 구체적인 파일 경로와 패턴 포함.
```

### Phase 3: 에이전트 병렬 생성

인터뷰 답변 + 코드 분석 결과를 context로 전달하여 **3개 에이전트 그룹을 병렬 실행**한다.

> **보완 규칙**: 파일이 이미 존재하면 Read 후 빈 섹션/누락 내용만 추가. 덮어쓰기 금지 — Edit으로 보완.
>
> **[TBD] 마커**: 확인 불가능한 정보는 `[TBD: 설명]`으로 표시하여 사용자가 후속 채움.

#### Group A: 아키텍처 & 보안 (opus)

```
Agent:
  model: "opus"
  description: "아키텍처 & 보안 문서 생성"
  prompt: |
    ## 역할
    시니어 아키텍트 겸 보안 엔지니어.

    ## 프로젝트 컨텍스트
    {인터뷰 답변 요약}
    {코드 분석 결과}
    {기존 문서 현황}

    ## 생성할 파일

    ### 1. ARCHITECTURE.md
    시스템 아키텍처 개요:
    - 컴포넌트 구조도 (ASCII 다이어그램)
    - 데이터 흐름
    - 의존성 계층 & 방향 (예: Types → Config → Repo → Service → Runtime → UI)
    - 기술 스택 선택 이유
    - 주요 의존성 & 역할
    - 배포 아키텍처 (해당 시)
    - ## 유지보수 가이드 (마지막 섹션)

    ### 2. docs/SECURITY.md
    보안 정책:
    - 인증/인가 모델
    - 데이터 보호 (전송 중/저장 시)
    - 의존성 보안 관리
    - 알려진 위험 & 대응 방안
    - 보안 체크리스트
    - ## 유지보수 가이드

    ## 규칙
    - 코드에서 확인한 사실 기반으로 작성
    - 추측은 [TBD: 설명] 마커로 표시
    - 기존 파일이 있으면 Read 후 빈 부분만 보완 (Edit 사용)
```

#### Group B: 설계 & 프론트엔드 (sonnet)

```
Agent:
  model: "sonnet"
  description: "설계 & 프론트엔드 문서 생성"
  prompt: |
    ## 역할
    설계 리드.

    ## 프로젝트 컨텍스트
    {인터뷰 답변 요약}
    {코드 분석 결과}

    ## 생성할 파일

    ### 1. docs/DESIGN.md
    설계 철학 & 원칙:
    - 핵심 설계 원칙 (3-5개)
    - UI/UX 가이드라인 (해당 시)
    - 디자인 시스템 개요 (해당 시)
    - 코드 스타일 & 네이밍 컨벤션
    - ## 유지보수 가이드

    ### 2. docs/FRONTEND.md (프론트엔드 있을 때만)
    프론트엔드 가이드:
    - 컴포넌트 구조 & 계층
    - 스타일 컨벤션 (CSS/Tailwind/styled 등)
    - 상태 관리 패턴
    - 빌드 & 번들링 설정
    - ## 유지보수 가이드

    ### 3. docs/design-docs/index.md
    설계 원칙 목록 & 문서 색인.

    ### 4. docs/design-docs/core-beliefs.md
    핵심 기술 철학. "우리가 믿는 것" 형식으로 3-7개 원칙.
    각 원칙에 근거(evidence)와 반례(counter-example) 포함.

    ## 규칙
    - 프론트엔드 없으면 docs/FRONTEND.md 생략
    - 기존 파일이 있으면 Read 후 빈 부분만 보완
```

#### Group C: 제품 & 운영 (sonnet)

```
Agent:
  model: "sonnet"
  description: "제품 & 운영 문서 생성"
  prompt: |
    ## 역할
    프로덕트 매니저 겸 SRE.

    ## 프로젝트 컨텍스트
    {인터뷰 답변 요약}
    {코드 분석 결과}

    ## 생성할 파일

    ### 1. AGENTS.md
    AI 에이전트 행동 지침. 이 파일은 **피드백 루프** — 에이전트가 실수할 때마다 업데이트.
    포함할 내용:
    - 프로젝트 개요 (1-2문장)
    - 빌드 & 테스트 명령어
    - 코드 컨벤션 & 스타일
    - 아키텍처 제약 (위반 금지 규칙)
    - 금지 사항 (삭제 금지 파일, 주의 영역)
    - 일반적인 함정 & 해결법
    - 깊은 컨텍스트 포인터 (→ docs/design-docs/, → docs/product-specs/ 등)

    ### 2. docs/PLANS.md
    로드맵 & 우선순위:
    - 현재 마일스톤 & 목표
    - 우선순위 매트릭스
    - 기능 백로그 개요
    - ## 유지보수 가이드

    ### 3. docs/product-specs/index.md
    제품 비전 & 감각 (Product Sense):
    - 제품 비전 (1-2문장)
    - 타겟 사용자 & 페르소나
    - 핵심 가치 제안
    - 성공 지표 (KPI)

    ### 4. docs/RELIABILITY.md
    안정성 & 운영:
    - 에러 처리 전략
    - 모니터링 & 알림 가이드
    - SLA/SLO (해당 시)
    - 장애 대응 절차 (runbook)
    - ## 유지보수 가이드

    ### 5. docs/exec-plans/tech-debt-tracker.md
    기술 부채 추적:
    - 알려진 부채 목록
    - 우선순위 (영향도 × 수정 난이도 매트릭스)
    - 해결 계획 & 타임라인

    ## 규칙
    - AGENTS.md는 에이전트 관점에서 작성 (기계 읽기 최적화)
    - 기존 파일이 있으면 Read 후 빈 부분만 보완
    - 새 프로젝트면 [TBD: 설명]으로 미정 부분 표시
```

#### 직접 생성 (에이전트 불필요)

에이전트 완료 후 직접 Write:

1. `docs/design-docs/adr/0001-template.md` — ADR 템플릿 (`references/adr-template.md` 내용 복사)
2. `docs/exec-plans/active/.gitkeep` — 빈 디렉토리 유지
3. `docs/exec-plans/completed/.gitkeep`
4. `docs/references/.gitkeep`
5. `docs/generated/.gitkeep`

### Phase 4: 보고

모든 생성 완료 후:

1. **생성/수정 파일 목록** — 전체 경로로 출력
2. **Three Pillars 매핑**:
   ```
   Context Engineering:    AGENTS.md, design-docs/, product-specs/
   Architectural Constraints: ARCHITECTURE.md, DESIGN.md, SECURITY.md
   Entropy Management:    PLANS.md, exec-plans/, RELIABILITY.md
   ```
3. **[TBD] 항목 목록** — 사용자가 직접 채워야 할 부분
4. **다음 단계 제안**:
   - "AGENTS.md는 에이전트가 실수할 때마다 업데이트하세요 (피드백 루프)"
   - "docs/references/에 기술 스택별 llms.txt 추가하면 에이전트 컨텍스트 강화"
   - "docs/design-docs/adr/에 아키텍처 결정을 기록하세요"
   - "docs/product-specs/에 기능별 PRD 추가 가능"

---

## 리소스

- `references/adr-template.md` — Architecture Decision Record 템플릿

## 설계 근거

OpenAI "Harness engineering: leveraging Codex in an agent-first world" (2026) 기반:

1. **Repository-first**: 모든 아키텍처 결정이 코드베이스에 있어야 한다. 에이전트가 접근할 수 없는 것은 존재하지 않는 것.
2. **AGENTS.md는 피드백 루프**: 정적 문서가 아니라 매 실패마다 업데이트되는 살아있는 문서. 작은 AGENTS.md → 깊은 소스를 가리키는 포인터 구조.
3. **제약이 생산성**: 에이전트의 해결 공간을 제약할수록 더 생산적. 린팅 규칙과 구조적 테스트가 에이전트를 가르친다.
4. **계획이 새로운 코딩**: 에이전트에게 코드를 쓰게 하기 전에 계획을 검토·승인하라.
5. **엔트로피 관리**: 주기적으로 문서 일관성 확인, 제약 위반 스캔, 패턴 강제화. 코드베이스 건강성은 자동으로 유지되지 않는다.
