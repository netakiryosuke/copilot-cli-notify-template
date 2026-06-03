#!/usr/bin/env bash
# postToolUse hook: notifies when Copilot asks the user a question via ask_user.
# NOTE: This fires AFTER the user answers since ask_user bypasses preToolUse hooks.
#       Keep this for awareness notifications (e.g. Slack) even after the fact.
# NOTE: toolArgs is a JSON-encoded string, so we use `fromjson` to parse it.

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.toolName // empty')

if [ "$TOOL_NAME" = "ask_user" ]; then
  QUESTION=$(echo "$INPUT" | jq -r '.toolArgs | fromjson | .question // empty')

  if [ -n "$QUESTION" ]; then
    ~/.local/bin/notify.sh '❓ 質問が必要です' "$QUESTION"
  fi
fi
