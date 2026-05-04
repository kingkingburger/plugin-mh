#!/usr/bin/env bash
# Validate plugin-mh metadata, Codex adapter prompts, and guardrail docs.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
errors=()

add_error() {
    errors+=("$1")
}

text_contains() {
    local path="$1"
    local pattern="$2"
    local message="$3"

    if ! grep -Eq "$pattern" "$ROOT/$path"; then
        add_error "$message"
    fi
}

mapfile -t skill_dirs < <(find "$ROOT/skills" -mindepth 1 -maxdepth 1 -type d | sort)
mapfile -t agent_files < <(find "$ROOT/agents" -maxdepth 1 -type f -name '*.md' 2>/dev/null | sort)
mapfile -t prompt_files < <(find "$ROOT/codex/prompts" -maxdepth 1 -type f -name '*.md' | sort)

for skill in "${skill_dirs[@]}"; do
    skill_name="$(basename "$skill")"
    skill_path="$skill/SKILL.md"

    if [[ ! -f "$skill_path" ]]; then
        add_error "Missing SKILL.md: skills/$skill_name"
        continue
    fi

    first_line="$(head -n 1 "$skill_path")"
    if [[ "$first_line" != "---" ]]; then
        add_error "Invalid frontmatter start: skills/$skill_name/SKILL.md"
    fi
done

expected_prompt_count=$((${#skill_dirs[@]} + ${#agent_files[@]}))
if [[ "${#prompt_files[@]}" -ne "$expected_prompt_count" ]]; then
    add_error "Codex prompt count mismatch: expected $expected_prompt_count, got ${#prompt_files[@]}"
fi

banned_patterns=('AskUserQuestion' 'subagent_type' 'Skill\(skill=')
for prompt in "${prompt_files[@]}"; do
    prompt_name="$(basename "$prompt")"
    for pattern in "${banned_patterns[@]}"; do
        if grep -Eq "$pattern" "$prompt"; then
            add_error "Codex-only conversion leak in codex/prompts/$prompt_name: $pattern"
        fi
    done
done

guardrail_files=(
    'guardrails/README.md'
    'guardrails/core.md'
    'guardrails/laws.md'
    'guardrails/languages/typescript.md'
    'guardrails/languages/rust.md'
    'guardrails/languages/python.md'
    'guardrails/workflows/tdd.md'
    'guardrails/workflows/review.md'
)

for file in "${guardrail_files[@]}"; do
    if [[ ! -f "$ROOT/$file" ]]; then
        add_error "Missing guardrail file: $file"
    fi
done

text_contains 'README.md' 'Guardrails' 'README.md does not mention Guardrails'
text_contains 'AGENTS.md' 'guardrails/' 'AGENTS.md does not mention guardrails/'
text_contains 'codex/README.md' 'guardrails/' 'codex/README.md does not mention guardrails/'
text_contains 'guardrails/languages/python.md' '\bty\b' 'Python guardrail does not mention ty'

skill_count="${#skill_dirs[@]}"
text_contains 'README.md' "$skill_count custom skills" "README.md skill count is not $skill_count"
text_contains '.claude-plugin/marketplace.json' "$skill_count custom skills" "marketplace.json skill count is not $skill_count"

for skill in "${skill_dirs[@]}"; do
    skill_name="$(basename "$skill")"
    if ! grep -Eq "^\| $skill_name \|" "$ROOT/CLAUDE.md"; then
        add_error "CLAUDE.md does not list skill: $skill_name"
    fi
done

if [[ "${#errors[@]}" -gt 0 ]]; then
    echo "plugin-mh validation failed:" >&2
    for error in "${errors[@]}"; do
        echo "  - $error" >&2
    done
    exit 1
fi

echo "plugin-mh validation passed."
echo "Skills: ${#skill_dirs[@]} | Agents: ${#agent_files[@]} | Codex prompts: ${#prompt_files[@]} | Guardrails: ${#guardrail_files[@]}"
