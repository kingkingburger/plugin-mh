#!/usr/bin/env bash
# plugin-mh - Install Codex slash-command prompts to ~/.codex/prompts/
#
# Default: symlink each codex/prompts/*.md into ~/.codex/prompts/.
#          Repository updates propagate automatically.
# --copy : copy files instead of symlinking.
# --force: overwrite existing files/links.

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
PROMPTS_SRC="$SCRIPT_DIR/prompts"
PROMPTS_DST="$HOME/.codex/prompts"

if [[ ! -d "$PROMPTS_SRC" ]]; then
    echo "Source not found: $PROMPTS_SRC" >&2
    exit 1
fi

mkdir -p "$PROMPTS_DST"

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
            ((skipped++))
            continue
        fi
    fi

    if [[ "$COPY_MODE" == true ]]; then
        if cp "$src" "$dst"; then
            echo "[copy] $name"
            ((installed++))
        else
            echo "[fail] $name" >&2
            ((failed++))
        fi
    else
        if ln -s "$src" "$dst"; then
            echo "[link] $name"
            ((installed++))
        else
            echo "[fail] $name (try --copy as fallback)" >&2
            ((failed++))
        fi
    fi
done

echo
echo "Installed: $installed | Skipped: $skipped | Failed: $failed"
echo "Target:    $PROMPTS_DST"
echo
echo "Restart Codex CLI to activate the following slash commands:"
for src in "$PROMPTS_SRC"/*.md; do
    name="$(basename "$src" .md)"
    echo "  /$name"
done

if [[ $failed -gt 0 ]]; then
    exit 1
fi
