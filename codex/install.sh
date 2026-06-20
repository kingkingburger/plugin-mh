#!/usr/bin/env bash
set -euo pipefail

COPY_MODE=false
FORCE_MODE=false

for arg in "$@"; do
    case "$arg" in
        --copy)  COPY_MODE=true ;;
        --force) FORCE_MODE=true ;;
        -h|--help)
            cat <<EOF
Usage: $(basename "$0") [--copy] [--force]

  --copy   Copy files instead of creating symlinks
  --force  Overwrite existing files/links
  -h       Show this help
EOF
            exit 0
            ;;
        *)
            echo "Unknown option: $arg" >&2
            exit 1
            ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROMPTS_SRC="$SCRIPT_DIR/prompts"
PROMPTS_DST="$HOME/.codex/prompts"
SKILLS_SRC="$REPO_ROOT/skills"
SKILLS_DST="$HOME/.codex/skills"

if [[ ! -d "$PROMPTS_SRC" ]]; then
    echo "Source not found: $PROMPTS_SRC" >&2
    exit 1
fi

if [[ ! -d "$SKILLS_SRC" ]]; then
    echo "Source not found: $SKILLS_SRC" >&2
    exit 1
fi

mkdir -p "$PROMPTS_DST"
mkdir -p "$SKILLS_DST"

installed=0
skipped=0
failed=0

for src in "$PROMPTS_SRC"/*.md; do
    name="$(basename "$src")"
    dst="$PROMPTS_DST/$name"

    if [[ -e "$dst" || -L "$dst" ]]; then
        if [[ "$FORCE_MODE" == true ]]; then
            rm -f "$dst"
        else
            echo "[skip] $name already exists (use --force to overwrite)"
            ((skipped += 1))
            continue
        fi
    fi

    if [[ "$COPY_MODE" == true ]]; then
        if cp "$src" "$dst"; then
            echo "[copy] $name"
            ((installed += 1))
        else
            echo "[fail] $name" >&2
            ((failed += 1))
        fi
    else
        if ln -s "$src" "$dst"; then
            echo "[link] $name"
            ((installed += 1))
        else
            echo "[fail] $name (try --copy as fallback)" >&2
            ((failed += 1))
        fi
    fi
done

for src in "$SKILLS_SRC"/*; do
    [[ -d "$src" ]] || continue
    name="$(basename "$src")"
    dst="$SKILLS_DST/$name"

    if [[ -e "$dst" || -L "$dst" ]]; then
        if [[ "$FORCE_MODE" == true ]]; then
            if [[ -L "$dst" ]]; then
                rm "$dst"
            else
                echo "[skip] $name is an existing directory; remove it manually or use PowerShell installer" >&2
                ((skipped += 1))
                continue
            fi
        else
            echo "[skip] $name already exists (use --force to overwrite symlinks)"
            ((skipped += 1))
            continue
        fi
    fi

    if [[ "$COPY_MODE" == true ]]; then
        if cp -R "$src" "$dst"; then
            echo "[copy] $name"
            ((installed += 1))
        else
            echo "[fail] $name" >&2
            ((failed += 1))
        fi
    else
        if ln -s "$src" "$dst"; then
            echo "[link] $name"
            ((installed += 1))
        else
            echo "[fail] $name (try --copy as fallback)" >&2
            ((failed += 1))
        fi
    fi
done

echo
echo "Installed: $installed | Skipped: $skipped | Failed: $failed"
echo "Prompts:   $PROMPTS_DST"
echo "Skills:    $SKILLS_DST"
echo
echo "Restart Codex CLI to activate the following slash commands:"
for src in "$PROMPTS_SRC"/*.md; do
    name="$(basename "$src" .md)"
    echo "  /$name"
done

if [[ $failed -gt 0 ]]; then
    exit 1
fi
