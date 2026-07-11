#!/usr/bin/env bash
# Codex SubagentStop hook. Codex supplies one JSON object on standard input.

set -u

INPUT=$(cat)
AGENT_TYPE='サブエージェント'

if command -v jq > /dev/null 2>&1; then
  AGENT_TYPE=$(printf '%s' "$INPUT" | jq -r '.agent_type // "サブエージェント"' 2>/dev/null || printf '%s' 'サブエージェント')
fi

"$HOME/.local/bin/notify.sh" '🤖 Codexサブエージェント' "$AGENT_TYPE の処理が完了しました"
