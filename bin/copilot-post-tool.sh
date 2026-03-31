#!/usr/bin/env bash
# postToolUse hook: notifies when a git commit is made via Copilot CLI.
# Reads JSON from stdin as provided by the Copilot CLI hook runtime.

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.toolName // empty')

if [ "$TOOL_NAME" = "bash" ]; then
  COMMAND=$(echo "$INPUT" | jq -r '.toolArgs.command // empty')

  if echo "$COMMAND" | grep -q "git commit"; then
    MSG=$(echo "$COMMAND" | grep -oP '(?<=-m ")[^"]+(?=")')
    ~/.local/bin/notify.sh 'コミットしました。' "$MSG"
  fi
fi
