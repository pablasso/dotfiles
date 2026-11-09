#!/bin/bash
# Claude Code statusline. Receives session JSON on stdin from Claude Code.
# Renders: model | NN% ctx | git-branch | cwd-basename
set -u

input=$(cat)

model=$(jq -r '.model.display_name // .model.id // "?"' <<<"$input")
pct=$(jq -r '.context_window.used_percentage // 0 | floor' <<<"$input")
cwd=$(jq -r '.workspace.current_dir // .cwd // "."' <<<"$input")
effort=$(jq -r '.effort.level // empty' <<<"$input")

branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
base=$(basename "$cwd")

# Build the line piece by piece; skip empty segments cleanly.
out="$model"
[[ -n $effort ]] && out+=" (${effort})"
out+=" | ${pct}% ctx"
[[ -n $branch ]] && out+=" | ${branch}"
out+=" | ${base}"

printf '%s\n' "$out"
