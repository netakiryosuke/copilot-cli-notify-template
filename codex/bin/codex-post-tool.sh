#!/usr/bin/env bash
# Codex PostToolUse hook. Notifies only when a Bash tool executed git commit.

set -u

INPUT=$(cat)
COMMAND=''

if command -v jq > /dev/null 2>&1; then
  COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || true)
fi

if printf '%s' "$COMMAND" | grep -Eq 'git([[:space:]]+[^;&|[:space:]]+)*[[:space:]]+commit([[:space:];]|$)'; then
  WORKDIR=$(pwd)
  if command -v jq > /dev/null 2>&1; then
    WORKDIR=$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || pwd)
  fi
  COMMIT=$(git -C "$WORKDIR" log -1 --format='%h %s' 2>/dev/null || true)
  if [ -z "$COMMIT" ]; then
    COMMIT='git commit を検知しました'
  fi
  "$HOME/.local/bin/notify.sh" 'コミットしました。' "$COMMIT"
fi
