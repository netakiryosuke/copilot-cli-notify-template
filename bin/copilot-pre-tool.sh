#!/usr/bin/env bash
# preToolUse hook: notifies when Copilot asks the user a question.
# Reads JSON from stdin as provided by the Copilot CLI hook runtime.
# NOTE: toolArgs is a JSON-encoded string, so we use `fromjson` to parse it.

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.toolName // empty')

if [ "$TOOL_NAME" = "ask_user" ]; then
  QUESTION=$(echo "$INPUT" | jq -r '.toolArgs | fromjson | .question // empty')
  ~/.local/bin/notify.sh '❓ Copilotが質問しています' "$QUESTION"
fi
