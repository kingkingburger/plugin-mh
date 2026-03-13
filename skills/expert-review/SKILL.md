---
name: expert-review
version: 0.1.0
description: This skill should be used when the user wants expert reviews on a document, plan, or deliverable. Trigger on "expert-review", "전문가 리뷰", "리뷰 부탁", "expert review", "페르소나 리뷰", "전문가 검토", "3인 리뷰", "리뷰어 추천", "다관점 리뷰", "multi-perspective review". Reads a file, auto-recommends expert personas, runs parallel sub-agent reviews, and synthesizes a unified proposal.
allowed-tools:
  - Read
  - Glob
  - Grep
  - Agent
  - AskUserQuestion
---

# Expert Review - 전문가 페르소나 병렬 리뷰 + 통합 제안

파일을 입력받아 내용을 분석하고, 최적의 전문가 페르소나를 자동 추천한 뒤, 병렬 서브에이전트로 리뷰를 수행하고 통합 제안서를 출력하는 스킬.

## 사용법

```
/expert-review path/to/file.md
/expert-review path/to/file.md --count 5
/expert-review path/to/plan.md --count 2
```

### 옵션

| 옵션 | 기본값 | 설명 |
|------|--------|------|
| `--count` | `3` | 리뷰어 수 (2~5) |
| `--auto` | `false` | 페르소나 확인 단계 생략, 자동 추천으로 바로 진행 |
| `--save` | `true` | 결과를 파일로 저장 |

## 실행 워크플로우

### Step 1: 입력 파싱 및 파일 읽기

1. 파일 경로와 옵션(`--count`, `--auto`, `--save`)을 파싱한다.
2. `Read` 도구로 파일 내용을 읽는다.
3. 파일이 없거나 읽기 실패 시 AskUserQuestion으로 경로 재확인.

### Step 2: 콘텐츠 분석 및 페르소나 추천

파일 내용을 분석하여 **문서 유형**과 **핵심 도메인**을 판별한다.

#### 문서 유형 판별

| 유형 | 시그널 |
|------|--------|
| 기술 설계/아키텍처 | API, 스키마, 시스템 구성도, 인프라 |
| 제품 기획/PRD | 유저 스토리, 요구사항, 스코프, MVP |
| 비즈니스 전략 | 시장, 경쟁, 매출, ROI, KPI |
| 코드/구현 | 함수, 클래스, 테스트, 에러 핸들링 |
| 콘텐츠/문서 | 글, 발표, README, 가이드 |
| 데이터/분석 | 쿼리, 파이프라인, 지표, 대시보드 |

#### 페르소나 추천 로직

문서 유형과 도메인을 기반으로 **`references/persona-catalog.md`**에서 최적의 N명을 선택한다.

**추천 원칙**:
1. **다양성**: 같은 계열의 전문가를 중복 선택하지 않는다 (기술+기술 ✗, 기술+비즈니스+UX ✓)
2. **대항성**: 최소 1명은 비판적 관점을 가진 전문가를 포함한다
3. **적합성**: 문서의 핵심 도메인에 직접 관련된 전문가를 우선 배치한다

### Step 3: 페르소나 확인

`--auto`가 아닌 경우, AskUserQuestion으로 추천된 페르소나를 보여주고 확인/수정을 받는다.

```
questions:
  - question: "다음 전문가 {N}명으로 리뷰를 진행할까요?"
    header: "리뷰어 구성"
    options:
      - label: "이대로 진행 (Recommended)"
        description: "{페르소나1} / {페르소나2} / {페르소나3}"
      - label: "일부 교체"
        description: "교체하고 싶은 페르소나를 알려주세요"
      - label: "전체 변경"
        description: "원하는 전문가 역할을 직접 지정"
    multiSelect: false
```

"일부 교체" 또는 "전체 변경" 선택 시, 추가 AskUserQuestion으로 원하는 역할을 입력받는다.

### Step 4: 병렬 리뷰 실행

확정된 N명의 전문가를 **동시 병렬 Agent**로 스폰한다.

각 에이전트에게 전달하는 프롬프트:

```markdown
## 리뷰 대상
{파일 내용 전문}

## 너의 역할
너는 **{페르소나명}**이다.
{페르소나 설명 - persona-catalog.md에서 로드}

## 지시사항
- 너의 전문 영역 관점에서 이 문서를 리뷰하라.
- 잘된 점(Strengths)과 개선점(Improvements)을 구분하여 제시하라.
- 개선점에는 반드시 **구체적 수정 제안**을 포함하라 (문제만 지적하지 말고 해결책을 제시).
- 놓친 관점이나 빠진 내용이 있다면 지적하라.
- 전체 평가를 A/B/C/D 등급으로 매기고 한 줄 근거를 제시하라.

## 출력 형식
### {페르소나명}의 리뷰

**전체 등급**: {A|B|C|D} - {한 줄 근거}

**잘된 점 (Strengths)**:
1. {구체적 강점 + 해당 부분 인용}
2. {구체적 강점 + 해당 부분 인용}

**개선 제안 (Improvements)**:
1. **[심각도: 높음|중간|낮음]** {문제점} → {구체적 수정 제안}
2. **[심각도: 높음|중간|낮음]** {문제점} → {구체적 수정 제안}

**빠진 관점 (Missing)**:
- {이 문서에서 다뤄지지 않았지만 다뤄져야 할 내용}

**핵심 한 줄 요약**: {이 전문가가 가장 강조하는 포인트}
```

**중요**: 모든 에이전트를 하나의 메시지에서 동시에 스폰하여 병렬 처리한다.

### Step 5: 통합 제안서 작성

모든 리뷰가 수집되면, **별도의 종합 Agent**를 스폰하여 통합 제안서를 작성한다.

종합 에이전트 프롬프트:

```markdown
## 원본 문서
{파일 내용}

## 전문가 리뷰들
{N명의 리뷰 전문}

## 지시사항
너는 전문가 리뷰 통합자다. 다음을 수행하라:

1. **공통 평가**: 모든 리뷰어가 동의하는 강점과 문제점을 추출하라.
2. **충돌 해소**: 리뷰어 간 상충되는 의견이 있으면, 논거의 질을 기반으로 판단하고 근거를 명시하라.
3. **우선순위 정리**: 모든 개선 제안을 심각도 + 빈도 기준으로 정렬하라.
4. **액션 아이템**: 즉시 적용 가능한 구체적 수정 목록을 만들어라.

## 출력 형식
references/report-template.md 형식을 따른다.
```

출력 형식: **`references/report-template.md`** 참조.

### Step 6: 결과 출력 및 저장

1. 화면에 최종 통합 제안서를 출력한다.
2. `--save`가 true(기본값)이면 `reviews/{YYYY-MM-DD}-{filename-slug}.md`에 저장한다.
3. 저장 경로를 사용자에게 알린다.

## 참고 파일

- **`references/persona-catalog.md`** - 전문가 페르소나 카탈로그 및 추천 매핑
- **`references/report-template.md`** - 통합 제안서 출력 템플릿

## 주의사항

1. **토큰 소모**: 5명 리뷰는 토큰을 많이 사용한다. 일반적으로 3명이면 충분.
2. **파일 크기**: 매우 큰 파일(1000줄+)은 핵심 부분만 발췌하여 리뷰할 수 있다. 이 경우 사용자에게 알린다.
3. **결과 저장**: `reviews/` 폴더가 없으면 자동 생성한다.
4. **페르소나 교체**: 사용자가 교체를 원할 때, persona-catalog.md에 없는 역할도 자유롭게 생성 가능하다.
