# /tech-decision — Tech Decision: 기술 의사결정 깊이 탐색

기술적 의사결정을 체계적으로 분석하고 종합적인 결론을 도출한다. 뭐 쓸지 고민, A vs B, 비교 분석, 라이브러리 선택, 아키텍처 결정, 트레이드오프 등에서 트리거된다.

> Codex CLI 슬래시 커맨드로 호출되거나 자연어로 트리거된다. `$ARGUMENTS`에 사용자 입력이 주입된다.

## 핵심 원칙

**두괄식 결과물**: 모든 보고서는 결론을 먼저 제시하고, 그 다음에 근거를 제공한다.

## 사용 시나리오

- 라이브러리/프레임워크 선택 (React vs Vue, Prisma vs TypeORM)
- 아키텍처 패턴 결정 (Monolith vs Microservices, REST vs GraphQL)
- 구현 방식 선택 (Server-side vs Client-side, Polling vs WebSocket)
- 기술 스택 결정 (언어, 데이터베이스, 인프라 등)

## 의사결정 워크플로우

### Phase 1: 문제 정의

의사결정 주제와 맥락을 명확히 한다:

1. **주제 파악**: 무엇을 결정해야 하는가?
2. **옵션 식별**: 비교할 선택지들은 무엇인가?
3. **평가 기준 수립**: 어떤 기준으로 평가할 것인가?
   - 성능, 학습 곡선, 생태계, 유지보수성, 비용 등
   - 프로젝트 특성에 맞는 기준 우선순위 설정
   - 상세 기준은 `references/evaluation-criteria.md` 참조

### Phase 2: 병렬 정보 수집

여러 소스에서 동시에 정보를 수집한다. **반드시 병렬로 수행**:

```
병렬로 다음 작업 수행:

1. 코드베이스 탐색 (codebase-explorer 역할)
   → 이 단계에서는 기존 코드베이스 분석가처럼 사고하세요.
     기존 패턴, 현재 제약사항, 의존성 파악

2. 문서 리서치 (docs-researcher 역할)
   → 이 단계에서는 기술 문서 전문가처럼 사고하세요.
     공식 문서, 가이드, best practices 리서치

3. 커뮤니티 의견 수집
   → WebSearch로 직접 수집:
     "{topic} site:reddit.com"
     "{topic} site:news.ycombinator.com"

4. 다관점 분석
   → /agent-arena 를 활용한 전문가 관점 수집

5. [선택] 최신 라이브러리 문서 조회
   → Context7 MCP가 사용 가능한 경우 활용
```

### Phase 3: 종합 분석

수집된 정보를 바탕으로 tradeoff-analyzer 역할로 분석 수행:

- 이 단계에서는 트레이드오프 분석가처럼 사고하세요.
- 각 옵션별 pros/cons 정리
- 평가 기준별 점수화
- 충돌하는 의견 정리
- 신뢰도 평가 (출처 기반)

### Phase 4: 최종 보고서 생성

decision-synthesizer 역할로 두괄식 종합 보고서 작성. 이 단계에서는 의사결정 종합자처럼 사고하세요.

상세 템플릿: `references/report-template.md`

```markdown
# 기술 의사결정 보고서: [주제]

## 결론 (Executive Summary)
**추천: [Option X]**
[1-2문장 핵심 이유]

## 평가 기준 및 가중치
| 기준 | 가중치 | 설명 |
|------|--------|------|
| 성능 | 30% | ... |
| 학습곡선 | 20% | ... |

## 옵션별 분석

### Option A: [이름]
**장점:**
- [장점 1] (출처: 공식 문서)
- [장점 2] (출처: Reddit r/webdev)

**단점:**
- [단점 1] (출처: HN 토론)

**적합한 경우:** [시나리오]

### Option B: [이름]
...

## 종합 비교
| 기준 | Option A | Option B | Option C |
|------|----------|----------|----------|
| 성능 | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ |
| 학습곡선 | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ |
| **총점** | **X점** | **Y점** | **Z점** |

## 추천 근거
1. [핵심 근거 1 with 출처]
2. [핵심 근거 2 with 출처]
3. [핵심 근거 3 with 출처]

## 리스크 및 주의사항
- [주의점 1]
- [주의점 2]

## 참고 출처
- [출처 목록]
```

## 빠른 실행 가이드

### 1. 간단한 비교 (A vs B)

```
사용자: "React vs Vue 뭐가 나을까?"

실행:
1. docs-researcher + codebase-explorer 역할로 병렬 분석
2. WebSearch (커뮤니티 의견)
3. tradeoff-analyzer 역할로 비교
4. decision-synthesizer 역할로 보고서 작성
```

### 2. 깊은 분석 (복잡한 의사결정)

```
사용자: "우리 프로젝트에 상태관리 라이브러리 뭘 쓸지 고민이야"

실행:
1. codebase-explorer 역할로 현재 상태 분석
2. 병렬 실행:
   - docs-researcher 역할 (Redux, Zustand, Jotai, Recoil 등)
   - WebSearch (커뮤니티 의견)
   - /agent-arena 로 다관점 토론
3. tradeoff-analyzer 역할로 비교
4. decision-synthesizer 역할로 보고서 작성
```

### 3. 아키텍처 결정

```
사용자: "모놀리스 vs 마이크로서비스 어떻게 해야 할까?"

실행:
1. codebase-explorer 역할로 현재 규모/복잡도 분석
2. 병렬 실행:
   - docs-researcher 역할 (각 아키텍처 best practices)
   - /agent-arena 로 아키텍트 관점 토론
3. tradeoff-analyzer 역할로 분석 (팀 규모, 배포 복잡도 등 고려)
4. decision-synthesizer 역할로 보고서 작성
```

## 주의사항

1. **컨텍스트 제공**: 프로젝트 특성, 팀 규모, 기존 기술 스택 등 맥락 정보가 많을수록 정확한 분석 가능
2. **평가 기준 확인**: 사용자에게 중요한 기준이 무엇인지 먼저 확인
3. **신뢰도 표시**: 출처가 불분명하거나 오래된 정보는 명시
4. **결론 먼저**: 항상 두괄식으로 결론부터 제시

---
## 참조 파일 위치
이 프롬프트가 언급하는 `references/...` 파일은 plugin-mh 저장소의 `skills/tech-decision/references/` 에 있다. Codex CLI에서 사용 시 해당 경로를 직접 Read 하면 된다.
