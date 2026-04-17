---
name: clarify
description: Mode router for clarification. Detects the right specialist skill (vague / unknown / metamedium) from user input and delegates. Trigger on mode-neutral keywords only "/clarify", "clarify", "명확히", "어떤 clarify가 필요할지 모르겠어". If the user already used a mode-specific keyword (e.g. "blind spots", "content vs form"), route goes directly to the specialist skill.
version: 2.0.0
allowed-tools:
  - AskUserQuestion
  - Skill
---

# Clarify: Mode Router

명확화 요청을 3개 specialist skill 중 하나로 라우팅한다. 자체 프로토콜을 실행하지 않는다 — 반드시 위임한다.

## Specialist Skills

| Mode | 스킬 | 용도 | 주요 키워드 |
|------|------|------|-------------|
| vague | `plugin-mh:vague` | 모호한 요구사항을 스펙으로 | "요구사항 정리", "뭘 원하는 건지", "spec this out" |
| unknown | `plugin-mh:unknown` | 전략 사각지대 (Known/Unknown 4분면) | "blind spots", "4분면", "가정 점검", "known unknown" |
| metamedium | `plugin-mh:metamedium` | Content vs Form 관점 전환 | "content vs form", "관점 전환", "형식을 바꿔볼까" |

## Workflow

### Step 1 — Detect Mode

사용자 입력에서 mode-specific 키워드를 스캔:

- **vague 키워드 발견** → Step 3(위임)으로 바로 이동
- **unknown 키워드 발견** → Step 3
- **metamedium 키워드 발견** → Step 3
- **mode-neutral 키워드만** ("명확히", "/clarify") → Step 2

### Step 2 — Ask if Ambiguous

```
AskUserQuestion:
  question: "어떤 종류의 명확화가 필요한가요?"
  header: "Mode"
  options:
    - label: "Vague → 요구사항 구체화"
      description: "모호한 요청을 구체적 스펙으로 변환 (hypotheses as options)"
    - label: "Unknown → 사각지대 분석"
      description: "전략/계획의 숨겨진 가정과 블라인드스팟 발견 (4분면)"
    - label: "Metamedium → 관점 전환"
      description: "내용(Content) 최적화 vs 형식(Form) 변경 판단 (Alan Kay)"
  multiSelect: false
```

### Step 3 — Delegate

선택된 mode에 따라 Skill 도구로 위임:

```
Skill(skill="plugin-mh:vague", args="{사용자 원 요청}")
Skill(skill="plugin-mh:unknown", args="{사용자 원 요청}")
Skill(skill="plugin-mh:metamedium", args="{사용자 원 요청}")
```

위임 후 clarify는 종료한다. 실제 프로토콜은 specialist skill이 실행한다.

## When NOT to Use This Skill

사용자가 이미 모드-specific 키워드로 요청했다면 **specialist skill을 직접 호출**하는 것이 빠르다:

- "blind spots" → `/unknown` 직접
- "content vs form" → `/metamedium` 직접
- "요구사항 정리" → `/vague` 직접

clarify는 모드가 불분명한 "/clarify", "명확히" 같은 일반 진입점을 처리하기 위해 존재한다.

## Why a Router Skill?

- **단일 진입점**: 사용자가 어떤 primitive를 써야 할지 모를 때 learning curve 완화
- **DRY**: 3개 모드의 상세 프로토콜은 specialist skill이 단일 소유 (v1의 복제본 제거)
- **Clear ownership**: 각 primitive가 자기 도메인 키워드를 소유, clarify는 라우팅만

## Version History

- v2.0.0: 라우터 전환. 모드별 상세 프로토콜 제거, Skill 도구로 specialist에 위임.
- v1.0.0: 3개 모드(vague/unknown/metamedium)의 프로토콜을 한 파일에 통합 (DRY 위반으로 v2에서 재설계).
