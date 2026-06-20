#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOCAL_HARNESS="${LOCAL_HARNESS:-$HOME/.codex/skills/harness}"
PLUGIN_HARNESS="$ROOT/skills/harness"
CODEX_PROMPT="$ROOT/codex/prompts/harness.md"
CODEX_CATALOG="$ROOT/codex/AGENTS.md"
CLAUDE_CATALOG="$ROOT/CLAUDE.md"
README_CATALOG="$ROOT/README.md"
UPSTREAM_COMMIT="cceac68ea1d0ad198ef4b7b906cd238375836387"

case "${1:-}" in
    contract|sync|regression) ;;
    *)
        echo "usage: $0 contract|sync|regression" >&2
        exit 2
        ;;
esac

fail() {
    echo "FAIL [$1]: $2" >&2
    exit 1
}

assert_file() {
    local path="$1"
    [[ -f "$path" ]] || fail "${2:-file}" "missing file: $path"
}

assert_contains() {
    local path="$1"
    local pattern="$2"
    local label="$3"
    grep -Eq "$pattern" "$path" || fail "$label" "expected pattern '$pattern' in $path"
}

assert_not_contains() {
    local path="$1"
    local pattern="$2"
    local label="$3"
    if grep -Eq "$pattern" "$path"; then
        fail "$label" "unexpected pattern '$pattern' in $path"
    fi
}

required_refs=(
    agent-design-patterns.md
    orchestrator-template.md
    qa-agent-guide.md
    skill-testing-guide.md
    skill-writing-guide.md
    team-examples.md
)

local_refs=(
    work-surface-patterns.md
)

MANIFEST_FILE=upstream-manifest.tsv

resolve_dir() {
    local path="$1"
    (cd "$path" && pwd -P)
}

check_local_source_of_truth() {
    local local_resolved plugin_resolved
    local_resolved="$(resolve_dir "$LOCAL_HARNESS")"
    plugin_resolved="$(resolve_dir "$PLUGIN_HARNESS")"
    [[ "$local_resolved" == "$plugin_resolved" ]] ||
        fail "source of truth" "local harness resolves to $local_resolved, expected $plugin_resolved"
}

check_phase_numbers_unique() {
    local path="$1"
    local label="$2"
    local duplicates
    duplicates="$(
        grep -E '^### Phase [0-9]+:' "$path" |
            sed -E 's/^### Phase ([0-9]+):.*/\1/' |
            sort |
            uniq -d |
            tr '\n' ' '
    )"
    [[ -z "$duplicates" ]] || fail "$label phases" "duplicate Phase number(s): $duplicates"
}

check_reference_set() {
    local harness_dir="$1"
    local label="$2"

    for ref in "${required_refs[@]}"; do
        local path="$harness_dir/references/$ref"
        assert_file "$path" "$label references"
    done
    for ref in "${local_refs[@]}"; do
        local path="$harness_dir/references/$ref"
        assert_file "$path" "$label local references"
    done

    assert_contains "$harness_dir/references/agent-design-patterns.md" "파이프라인|Pipeline" "$label patterns"
    assert_contains "$harness_dir/references/orchestrator-template.md" "TeamCreate" "$label orchestrator"
    assert_contains "$harness_dir/references/skill-testing-guide.md" "With-skill vs Baseline" "$label testing"
    assert_contains "$harness_dir/references/qa-agent-guide.md" "경계면 불일치|Boundary Mismatch" "$label qa"
    assert_contains "$harness_dir/references/work-surface-patterns.md" "기획" "$label planning surface"
    assert_contains "$harness_dir/references/work-surface-patterns.md" "문서작업" "$label documentation surface"
    assert_contains "$harness_dir/references/work-surface-patterns.md" "디자인" "$label design surface"
    assert_file "$harness_dir/references/$MANIFEST_FILE" "$label manifest"
    assert_contains "$harness_dir/references/$MANIFEST_FILE" "$UPSTREAM_COMMIT" "$label manifest commit"
    check_reference_manifest "$harness_dir" "$label"
}

check_reference_manifest() {
    local harness_dir="$1"
    local label="$2"
    local manifest="$harness_dir/references/$MANIFEST_FILE"
    local count=0
    local sha file path actual allowed

    while IFS=$'\t' read -r sha file; do
        sha="${sha%$'\r'}"
        file="${file%$'\r'}"
        [[ -z "${sha:-}" || "$sha" == \#* || "$sha" == "sha256" ]] && continue

        allowed=0
        for ref in "${required_refs[@]}"; do
            [[ "$file" == "$ref" ]] && allowed=1
        done
        [[ "$allowed" -eq 1 ]] || fail "$label manifest" "unexpected manifest file: $file"

        path="$harness_dir/references/$file"
        assert_file "$path" "$label manifest target"
        actual="$(sha256sum "$path" | awk '{print $1}')"
        [[ "$actual" == "$sha" ]] || fail "$label manifest" "checksum mismatch for $file"
        count=$((count + 1))
    done < "$manifest"

    [[ "$count" -eq "${#required_refs[@]}" ]] ||
        fail "$label manifest" "expected ${#required_refs[@]} manifest entries, got $count"
}

check_skill_contract() {
    local skill_file="$1"
    local label="$2"

    assert_file "$skill_file" "$label skill"
    assert_contains "$skill_file" "$UPSTREAM_COMMIT" "$label upstream commit"
    assert_contains "$skill_file" "Agent Team|팀 아키텍처|Team-Architecture" "$label team architecture"
    assert_contains "$skill_file" "작업 표면|Work Surface" "$label work surface model"
    assert_contains "$skill_file" "기획" "$label planning harness"
    assert_contains "$skill_file" "문서작업" "$label documentation harness"
    assert_contains "$skill_file" "디자인" "$label design harness"
    assert_contains "$skill_file" "리서치" "$label research harness"
    assert_contains "$skill_file" "운영" "$label operations harness"
    assert_contains "$skill_file" "개발" "$label development harness"
    assert_contains "$skill_file" "references/work-surface-patterns.md" "$label surface reference pointer"
    assert_contains "$skill_file" "Phase 0: 현황 감사" "$label phase 0 audit"
    assert_contains "$skill_file" "Phase 2: 작업 표면 분석 \\+ 팀 아키텍처 설계" "$label team design phase"
    assert_contains "$skill_file" "Phase 5: 통합 및 오케스트레이션" "$label orchestration phase"
    assert_contains "$skill_file" "Phase 6: 검증 및 테스트" "$label testing phase"
    assert_contains "$skill_file" "Phase 7: 하네스 진화" "$label evolution phase"
    assert_contains "$skill_file" "파이프라인" "$label pipeline pattern"
    assert_contains "$skill_file" "팬아웃/팬인" "$label fanout pattern"
    assert_contains "$skill_file" "전문가 풀" "$label expert pool pattern"
    assert_contains "$skill_file" "생성-검증" "$label producer reviewer pattern"
    assert_contains "$skill_file" "감독자" "$label supervisor pattern"
    assert_contains "$skill_file" "계층적 위임" "$label hierarchical pattern"
    assert_contains "$skill_file" "references/agent-design-patterns.md" "$label patterns pointer"
    assert_contains "$skill_file" "references/orchestrator-template.md" "$label orchestrator pointer"
    assert_contains "$skill_file" "references/skill-testing-guide.md" "$label testing pointer"
    assert_contains "$skill_file" "references/qa-agent-guide.md" "$label qa pointer"
    assert_contains "$skill_file" "Phase 8: 보고" "$label report phase"
    check_phase_numbers_unique "$skill_file" "$label"
}

case "$1" in
    contract)
        check_local_source_of_truth
        check_skill_contract "$LOCAL_HARNESS/SKILL.md" "local harness"
        check_skill_contract "$PLUGIN_HARNESS/SKILL.md" "plugin harness"
        check_reference_set "$LOCAL_HARNESS" "local harness"
        check_reference_set "$PLUGIN_HARNESS" "plugin harness"
        echo "PASS [contract]: harness refresh contract present for local and plugin skills"
        ;;
    sync)
        check_local_source_of_truth
        check_reference_set "$LOCAL_HARNESS" "local harness"
        check_reference_set "$PLUGIN_HARNESS" "plugin harness"

        for ref in "${required_refs[@]}"; do
            cmp -s "$LOCAL_HARNESS/references/$ref" "$PLUGIN_HARNESS/references/$ref" ||
                fail "sync references" "local/plugin reference drift: $ref"
        done

        assert_contains "$CODEX_PROMPT" "$UPSTREAM_COMMIT" "codex upstream commit"
        assert_contains "$CODEX_PROMPT" "Phase 2: 작업 표면 분석 \\+ 팀 아키텍처 설계" "codex team design"
        assert_contains "$CODEX_PROMPT" "Phase 5: 통합 및 오케스트레이션" "codex orchestration"
        assert_contains "$CODEX_PROMPT" "Phase 6: 검증 및 테스트" "codex testing"
        assert_contains "$CODEX_PROMPT" "Phase 7: 하네스 진화" "codex evolution"
        assert_contains "$CODEX_PROMPT" "Phase 8: 보고" "codex report"
        check_phase_numbers_unique "$CODEX_PROMPT" "codex prompt"
        assert_contains "$CODEX_PROMPT" "작업 표면|Work Surface" "codex work surface model"
        assert_contains "$CODEX_PROMPT" "기획" "codex planning harness"
        assert_contains "$CODEX_PROMPT" "문서작업" "codex documentation harness"
        assert_contains "$CODEX_PROMPT" "디자인" "codex design harness"
        assert_contains "$CODEX_PROMPT" "리서치" "codex research harness"
        assert_contains "$CODEX_PROMPT" "운영" "codex operations harness"
        assert_contains "$CODEX_PROMPT" "개발" "codex development harness"
        assert_contains "$CODEX_PROMPT" "references/agent-design-patterns.md" "codex reference pointer"
        assert_contains "$CODEX_CATALOG" "기획" "codex catalog planning trigger"
        assert_contains "$CODEX_CATALOG" "문서작업" "codex catalog documentation trigger"
        assert_contains "$CODEX_CATALOG" "디자인" "codex catalog design trigger"
        assert_contains "$CODEX_CATALOG" "에이전트 팀" "codex catalog team trigger"
        assert_contains "$CODEX_CATALOG" "오케스트레이터" "codex catalog orchestrator trigger"
        assert_contains "$CODEX_CATALOG" "하네스 점검" "codex catalog maintenance trigger"
        assert_contains "$CLAUDE_CATALOG" "기획" "claude catalog planning scope"
        assert_contains "$CLAUDE_CATALOG" "문서작업" "claude catalog documentation scope"
        assert_contains "$CLAUDE_CATALOG" "디자인" "claude catalog design scope"
        assert_contains "$README_CATALOG" "기획" "readme planning scope"
        assert_contains "$README_CATALOG" "문서작업" "readme documentation scope"
        assert_contains "$README_CATALOG" "디자인" "readme design scope"
        assert_contains "$README_CATALOG" "오케스트레이터" "readme catalog orchestrator scope"
        assert_not_contains "$CODEX_PROMPT" "AskUserQuestion|subagent_type|Skill\\(skill=" "codex conversion leaks"
        echo "PASS [sync]: local/plugin references and Codex prompt are synchronized"
        ;;
    regression)
        bash "$ROOT/scripts/validate-plugin.sh"
        if [[ -n "${USER_GLOBAL_BASELINE_SHA:-}" ]]; then
            current_sha="$(sha256sum "$ROOT/codex/user-global-AGENTS.md" | awk '{print $1}')"
            [[ "$current_sha" == "$USER_GLOBAL_BASELINE_SHA" ]] ||
                fail "user global untouched" "codex/user-global-AGENTS.md changed during harness refresh"
        fi
        assert_not_contains "$CODEX_PROMPT" "AskUserQuestion|subagent_type|Skill\\(skill=" "codex conversion leaks"
        assert_contains "$CODEX_PROMPT" "Phase 7: 하네스 진화" "codex harness evolution regression"
        echo "PASS [regression]: plugin validation and adjacent Codex surface remain clean"
        ;;
esac
