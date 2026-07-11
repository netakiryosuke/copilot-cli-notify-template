#!/usr/bin/env bash
# Codex PermissionRequest hook. Codex supplies one JSON object on standard input.

set -u

INPUT=$(cat)
TOOL_NAME='操作'
DETAIL='Codexが許可を求めています'

if command -v jq > /dev/null 2>&1; then
  TOOL_NAME=$(printf '%s' "$INPUT" | jq -r '.tool_name // "操作"' 2>/dev/null || printf '%s' '操作')
  DETAIL=$(printf '%s' "$INPUT" | jq -r '.tool_input.description // .tool_input.command // "Codexが許可を求めています"' 2>/dev/null || printf '%s' 'Codexが許可を求めています')
fi

"$HOME/.local/bin/notify.sh" '🔐 Codexで許可が必要です' "$TOOL_NAME: $DETAIL"
