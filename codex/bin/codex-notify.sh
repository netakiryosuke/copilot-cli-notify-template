#!/usr/bin/env bash
# Codex CLI notify handler. Codex supplies a JSON payload on standard input.
# It reports a completed turn and, when available, the latest Git commit.

set -u

INPUT=$(cat)
WORKDIR=""

if command -v jq > /dev/null 2>&1; then
  WORKDIR=$(printf '%s' "$INPUT" | jq -r '.cwd // .workdir // .workspace // empty' 2>/dev/null || true)
fi

if [ -z "$WORKDIR" ] || [ ! -d "$WORKDIR" ]; then
  WORKDIR=$(pwd)
fi

TITLE='✅ Codex'
MESSAGE='タスクが完了しました'

if git -C "$WORKDIR" rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  COMMIT=$(git -C "$WORKDIR" log -1 --format='%h %s' 2>/dev/null || true)
  if [ -n "$COMMIT" ]; then
    MESSAGE="$MESSAGE
最新コミット: $COMMIT"
  else
    MESSAGE="$MESSAGE
Gitコミットはありません"
  fi
fi

"$HOME/.local/bin/notify.sh" "$TITLE" "$MESSAGE"
