# /skill-manage — Plugin-mh Skill Manifest Sync

plugin-mh의 스킬 추가/삭제/이름변경을 수행하면서 메타데이터 4파일과 다른 SKILL.md 교차참조를 원자적으로 동기화한다.

> Codex CLI 슬래시 커맨드로 호출되거나 자연어로 트리거된다. `$ARGUMENTS`에 사용자 입력이 주입된다.

plugin-mh 저장소 내 스킬을 추가·삭제·이름변경하면서 흩어진 메타데이터를 누락 없이 동기화한다. 이 스킬은 **plugin-mh 전용**이다. 작업 디렉토리가 plugin-mh일 때 동작한다.

## 관리 대상 파일 (Manifest Files)

스킬 목록이 노출되는 4개 파일 + 교차참조:

| 파일 | 업데이트 포인트 |
|------|-----------------|
| `CLAUDE.md` | "스킬 목록 (N개)" 제목 + 테이블 행 |
| `README.md` | 상단 문장의 스킬 개수 + TOC + 카테고리 테이블 + 상세 섹션 |
| `.claude-plugin/marketplace.json` | `plugins[0].description` (개수 + 스킬명 나열) |
| `GUIDE.md` | Marketplace 등록 예시 블록의 "N custom skills" |
| 다른 `skills/*/SKILL.md` | description 트리거 + 본문 교차참조 |

## When to Use

| 요청 | 실행 모드 |
|------|-----------|
| "스킬 삭제해줘", "skill-delete X" | `delete` |
| "새 스킬 만들자", "skill-add X" | `add` |
| "X를 Y로 이름 바꿔줘", "skill-rename X Y" | `rename` |

모드가 불분명하면 사용자에게 물어본다:

**어떤 작업을 수행할까요?**
1. **delete** — 스킬 삭제
2. **add** — 새 스킬 추가
3. **rename** — 스킬 이름 변경

---

## Mode 1: Delete

### Step 1 — 대상 확인

사용자에게 다음 질문을 제시하고 번호 또는 라벨로 답하게 하세요:

**정말 '{skill-name}' 스킬을 삭제할까요?**
1. **예 (파일 삭제 + 메타데이터 동기화)**
2. **아니요**

### Step 2 — 교차참조 사전 스캔
```bash
grep -rn "{skill-name}" skills/ CLAUDE.md README.md GUIDE.md .claude-plugin/
```
결과를 수집하여 체크리스트를 만든다.

### Step 3 — 스킬 디렉토리 삭제
```bash
rm -rf skills/{skill-name}
```

### Step 4 — 메타데이터 4파일 갱신 (병렬 Edit)

1. **CLAUDE.md**
   - "스킬 목록 (N개)" → `N-1`로 변경
   - 해당 행 제거

2. **README.md**
   - 상단 "Claude Code plugin with N custom skills" → `N-1`
   - TOC `  - [{skill}](#{skill}) - ...` 행 제거
   - 카테고리 테이블 행 제거 (Thinking & Strategy / Productivity / Development Quality 등 어느 섹션인지 확인)
   - "### {skill}" 상세 섹션 블록 제거 (다음 `### ` 또는 `---` 전까지)

3. **marketplace.json**
   - `description` 필드의 개수 + 스킬명 리스트 갱신

4. **GUIDE.md**
   - Marketplace 예시의 "N custom skills" → `N-1`, 스킬명 제거

### Step 5 — 다른 SKILL.md 교차참조 정리
Step 2 스캔 결과를 따라 각 파일에서:
- description 필드에서 `/{skill-name}` 또는 해당 스킬명 트리거 제거
- 본문 "다른 스킬 추천" 테이블의 해당 행 제거
- 본문 서술 내 `/{skill-name}` 언급 → 대체 스킬로 변경 or 삭제

**예외**: `docs/plans/YYYY-MM-DD-*.md`는 건드리지 않는다 (frozen historical artifacts).

### Step 6 — 검증
```bash
grep -rn "{skill-name}" skills/ CLAUDE.md README.md GUIDE.md .claude-plugin/
```
결과가 `docs/plans/*` 외에 없으면 성공. 있으면 Step 5 보완.

### Step 7 — 요약 보고
```
삭제 완료: {skill-name}
- 스킬 디렉토리: 삭제됨
- CLAUDE.md: N개 → N-1개, 행 제거
- README.md: 3 위치 갱신 (TOC, 카테고리, 상세)
- marketplace.json: 갱신
- GUIDE.md: 갱신
- 교차참조 정리: {M}개 파일
- 보존된 역사 문서: {if any}
```

---

## Mode 2: Add

### Step 1 — 스킬 정보 수집

사용자에게 다음 질문을 제시하고 번호 또는 라벨로 답하게 하세요:

**새 스킬의 이름은?**
(직접 입력)

**어느 카테고리?**
1. **Thinking & Strategy**
2. **Decision & Research**
3. **Productivity**
4. **Development Quality**
5. **Session & History**
6. **Content & Social**
7. **Utility**

### Step 2 — 스킬 스캐폴드 생성
```bash
mkdir -p skills/{new-skill}
```
`skills/{new-skill}/SKILL.md`에 frontmatter + 섹션 템플릿 작성 (GUIDE.md §2 따름).

### Step 3 — 4파일에 등록
1. **CLAUDE.md**: "스킬 목록 (N개)" → N+1, 테이블 행 추가
2. **README.md**: 상단 N → N+1, TOC 행 추가, 카테고리 테이블 행 추가, 상세 섹션 (최소: heading + 1문장 설명 + Trigger)
3. **marketplace.json**: description 개수 + 스킬명 나열 갱신
4. **GUIDE.md**: 예시 블록 N+1 갱신

### Step 4 — 검증 & 보고
```bash
ls skills/{new-skill}/
grep -c "{new-skill}" README.md CLAUDE.md marketplace.json GUIDE.md
```

---

## Mode 3: Rename

### Step 1 — 대상 확인
old name, new name을 명확히 확정.

### Step 2 — 디렉토리 이동
```bash
mv skills/{old-name} skills/{new-name}
```

### Step 3 — SKILL.md frontmatter 갱신
`name: {old-name}` → `name: {new-name}`
description 내 `/{old-name}` 트리거 → `/{new-name}`

### Step 4 — 전역 교체
```bash
grep -rln "{old-name}" . --include="*.md" --include="*.json" | grep -v "docs/plans/"
```
각 파일에서 `{old-name}` → `{new-name}` 치환. **frozen historical docs(`docs/plans/`)는 제외**.

### Step 5 — 검증
```bash
grep -rn "{old-name}" skills/ CLAUDE.md README.md GUIDE.md .claude-plugin/
```
없어야 한다 (frozen docs 제외).

---

## Commit Convention

이 스킬이 끝나면 자동 커밋을 제안한다:

| 모드 | 커밋 접두사 | 예시 |
|------|-------------|------|
| delete | `삭제:` | `삭제: X 스킬 제거 — {이유}` |
| add | `추가:` | `추가: X 스킬 신규 — {목적}` |
| rename | `수정:` | `수정: X → Y 스킬 이름 변경` |

## Anti-Patterns

- **한 파일만 수정하고 끝내기** — 4파일 + 교차참조 모두 확인 필수
- **frozen historical docs까지 수정** — `docs/plans/YYYY-MM-DD-*.md`는 건드리지 않는다
- **스킬 개수 수동 세기** — `ls skills/ | wc -l` 활용
- **description 필드 누락** — Claude가 트리거 판단하는 유일한 필드이므로 정확해야 함
