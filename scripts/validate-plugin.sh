#!/usr/bin/env bash
# Validate plugin-mh metadata, Codex adapter prompts, and guardrail docs.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHECK_INSTALLED=false
errors=()

for arg in "$@"; do
    case "$arg" in
        --installed) CHECK_INSTALLED=true ;;
        -h|--help)
            cat <<EOF
Usage: $(basename "$0") [--installed]

  --installed  Also verify ~/.codex/prompts and ~/.codex/skills contain plugin-mh entries.
EOF
            exit 0
            ;;
        *)
            echo "Unknown option: $arg" >&2
            exit 1
            ;;
    esac
done

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

has_line() {
    local needle="$1"
    shift
    printf '%s\n' "$@" | grep -Fxq "$needle"
}

collect_installed_names() {
    local path="$1"
    local kind="$2"

    if command -v powershell.exe >/dev/null 2>&1; then
        local win_path
        win_path="$(cygpath -w "$path" 2>/dev/null || printf '%s' "$path")"
        if [[ "$kind" == "skill" ]]; then
            CODEX_VALIDATE_PATH="$win_path" powershell.exe -NoProfile -Command \
                '$path = $env:CODEX_VALIDATE_PATH; if (-not (Test-Path -LiteralPath $path)) { exit 3 }; Get-ChildItem -LiteralPath $path -Directory | Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName "SKILL.md") } | Select-Object -ExpandProperty Name | Sort-Object' |
                tr -d '\r'
        else
            CODEX_VALIDATE_PATH="$win_path" powershell.exe -NoProfile -Command \
                '$path = $env:CODEX_VALIDATE_PATH; if (-not (Test-Path -LiteralPath $path)) { exit 3 }; Get-ChildItem -LiteralPath $path -File -Filter "*.md" | Select-Object -ExpandProperty Name | Sort-Object' |
                tr -d '\r'
        fi
    elif [[ "$kind" == "skill" ]]; then
        find -L "$path" -mindepth 1 -maxdepth 1 -type d -exec test -f '{}/SKILL.md' ';' -printf '%f\n' | sort
    else
        find -L "$path" -maxdepth 1 -type f -name '*.md' -printf '%f\n' | sort
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

if [[ "$CHECK_INSTALLED" == true ]]; then
    codex_skills_dir="${CODEX_SKILLS_DIR:-$HOME/.codex/skills}"
    codex_prompts_dir="${CODEX_PROMPTS_DIR:-$HOME/.codex/prompts}"

    if [[ ! -d "$codex_skills_dir" ]]; then
        add_error "Installed Codex skills dir not found: $codex_skills_dir"
        installed_skill_names=()
    else
        mapfile -t installed_skill_names < <(collect_installed_names "$codex_skills_dir" skill)
    fi

    if [[ ! -d "$codex_prompts_dir" ]]; then
        add_error "Installed Codex prompts dir not found: $codex_prompts_dir"
        installed_prompt_names=()
    else
        mapfile -t installed_prompt_names < <(collect_installed_names "$codex_prompts_dir" prompt)
    fi

    for skill in "${skill_dirs[@]}"; do
        skill_name="$(basename "$skill")"
        if ! has_line "$skill_name" "${installed_skill_names[@]}"; then
            add_error "Installed Codex skill missing: $skill_name"
        fi
    done

    for prompt in "${prompt_files[@]}"; do
        prompt_name="$(basename "$prompt")"
        if ! has_line "$prompt_name" "${installed_prompt_names[@]}"; then
            add_error "Installed Codex prompt missing: $prompt_name"
        fi
    done
fi

if [[ "${#errors[@]}" -gt 0 ]]; then
    echo "plugin-mh validation failed:" >&2
    for error in "${errors[@]}"; do
        echo "  - $error" >&2
    done
    exit 1
fi

echo "plugin-mh validation passed."
echo "Skills: ${#skill_dirs[@]} | Agents: ${#agent_files[@]} | Codex prompts: ${#prompt_files[@]} | Guardrails: ${#guardrail_files[@]}"
if [[ "$CHECK_INSTALLED" == true ]]; then
    echo "Installed Codex surface: skills ${#skill_dirs[@]} | prompts ${#prompt_files[@]}"
fi
