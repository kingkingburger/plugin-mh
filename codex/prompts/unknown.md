# /unknown — Unknown: Surface Blind Spots with Known/Unknown Quadrants

전략, 계획, 의사결정 문서에서 숨겨진 가정과 사각지대를 Known/Unknown 4분면 프레임워크와 가설 기반 질문으로 발굴한다. known unknown, 4분면 분석, blind spots, 뭘 놓치고 있지, assumption check 등에서 트리거된다.

> Codex CLI 슬래시 커맨드로 호출되거나 자연어로 트리거된다. `$ARGUMENTS`에 사용자 입력이 주입된다.

## 사용 시나리오

- Strategy or planning documents that need scrutiny
- Decisions with unclear direction or hidden assumptions
- Any situation where "what we don't know" matters more than "what we do know"

For specific requirement clarification (feature requests, bug reports), use `/vague`. For content-vs-form reframing, use `/metamedium`.

## Core Principle: Hypothesis-as-Options

R1/R2/R3의 모든 질문은 번호+라벨 형태로 사용자에게 제시하고 선택하게 하세요 — 절대 자유 텍스트 질문으로 묻지 않는다. 구조화된 형식이 가설-as-옵션을 강제하고 선택 피로를 줄인다.

Present hypotheses as options instead of open questions. The hypotheses ARE the analysis — by designing good options, 80% of the analytical work is done before the user even answers.

```
BAD:  "Why can't you do video content?"           ← open question, high load
GOOD: "Time / Skill gap / No guests / High bar"   ← pick one or more
```

- Each option IS a testable hypothesis about the user's situation
- multiSelect 가능한 질문에는 "(복수 선택 가능)" 표시
- "Other" is always available for out-of-frame answers

## 3-Round Depth Pattern

| Round | Purpose | Questions | Key trait |
|-------|---------|-----------|-----------|
| R1 | Validate draft quadrant | 3-4 | Broad, covers all quadrants |
| R2 | Drill into weak spots | 2-3 | Targeted, follows R1 answers |
| R3 | Nail execution details | 2-3 | Specific, optional |

**Critical**: Generate Round N questions from Round N-1 answers. Never use pre-prepared questions across rounds. Cap total at 7-10 questions.

## Protocol

### Phase 1: Intake

**File provided**: Read and extract goals, components, implicit assumptions, missing elements.

**Topic keyword only**: Start directly with R1 questions to establish scope. The draft in Phase 3 will be rougher but R1 corrects it.

### Phase 2: Context

Gather related context to find Unknown Knowns — assets the user may not realize they have:

- **Glob** for related files: CLAUDE.md, README, decision records, past analyses in the project
- **Read** project context: recent goals, team structure, active initiatives
- **Identify** underutilized assets: existing tools/skills not in use, past projects with reusable patterns, team expertise not leveraged

Items discovered here become UK candidates and options in R1 questions.

### Phase 3: Draft + R1 Questions

Generate an initial 4-quadrant classification. **The draft is intentionally rough** — R1 exists to correct it, not confirm it. Err on the side of classifying uncertain items as KU rather than KK.

Design R1 questions to test quadrant boundaries. **R1 질문을 모두 한 번에 묶어서 제시** (최대 4개):

| Target | Pattern | Example |
|--------|---------|---------|
| KK | "Is this really certain?" | "Primary revenue source?" (options) |
| KU | "Where's the weakest link?" | "Which flywheel connection is weakest?" |
| UK | "What exists but isn't used?" | Based on context findings |
| UU | "What's the biggest fear?" | Risk scenarios as options |

### Phase 4: Deepen + R2 Questions

Analyze R1 answers. Find the most uncertain area and drill in.

**R2 triggers**: compound answers (messy area), unexpected answers (draft wrong), "Other" selected (outside frame).

상세 R2 질문 유형은 `references/question-design.md` 참조.

### Phase 5: Execute + R3 Questions (Optional)

After priorities are set, nail down execution details for top items. Skip if R2 already provides enough detail.

### Phase 6: Playbook Output

Generate a structured 4-quadrant playbook file. 완전한 출력 템플릿은 `references/playbook-template.md` 참조.

**Output structure:**
```
# {Topic}: Known/Unknown Quadrant Analysis

## Current State Diagnosis
## Quadrant Matrix (ASCII with resource %)
## 1. Known Knowns: Systematize (60%)
## 2. Known Unknowns: Design Experiments (25%)
   - Each KU: Diagnosis → Experiment → Success Criteria → Deadline → Promotion Condition
## 3. Unknown Knowns: Leverage (10%)
## 4. Unknown Unknowns: Set Up Antennas (5%)
## Strategic Decision: What to Stop
## Execution Roadmap (week-by-week)
## Core Principles (3-5 decision criteria)
```

**Resource percentages (60/25/10/5) are defaults.** Adjust based on context — e.g., a startup exploring product-market fit may allocate 40% KU and 30% KK.

## Anti-Patterns

- Open questions ("What would you like to do?") — use hypothesis options
- 5+ options per question — causes choice fatigue
- Ignoring R1 answers when designing R2 — performative questioning
- Equal depth on all quadrants — wastes time, loses focus
- No "stop doing" section — adding without subtracting

## Example

**Input**: Growth strategy document

**R1**: Revenue source? → Workshops. Weakest link? → Biz→Knowledge. Blocker? → Skill gap + high bar (복수 선택). Biggest fear? → Execution scattered.

**R2** (driven by "execution scattered"): What to drop? → Product dev. Why no knowledge→content? → No process + no time + hard to abstract. Role clarity? → Unclear.

**R3**: Video format? → Screen recording. Retro blocker? → Don't know what to capture. What content resonated? → Raw discoveries.

**Key discovery**: Abstraction isn't needed — raw insights work better. Collapsed triple bottleneck into 15-minute pipeline.

## Rules

1. **Hypotheses, not questions**: Every option is a testable hypothesis
2. **Answers drive depth**: R2 from R1, R3 from R2
3. **7-10 questions max**: Beyond this is fatigue
4. **Stop > Start**: Always include "what to stop doing"
5. **Promote or kill**: Every KU gets a promotion condition and a kill condition
6. **Raw > Perfect**: Encourage minimum viable experiments, not perfect plans
7. **Draft is disposable**: The initial quadrant is meant to be corrected

---
## 참조 파일 위치
이 프롬프트가 언급하는 `references/...` 파일은 plugin-mh 저장소의 `skills/unknown/references/` 에 있다. Codex CLI에서 사용 시 해당 경로를 직접 Read 하면 된다.
