#!/usr/bin/env bash
# notification hook: handles Copilot CLI system notifications.
# Reads JSON from stdin as provided by the Copilot CLI hook runtime.

INPUT=$(cat)

# Log the actual payload for debugging
echo "$INPUT" >> /tmp/copilot-hook-payload.log

NOTIFICATION_TYPE=$(echo "$INPUT" | jq -r '.notification_type // empty')
MESSAGE=$(echo "$INPUT" | jq -r '.message // empty')

case "$NOTIFICATION_TYPE" in
  elicitation_dialog)
    ~/.local/bin/notify.sh '❓ Copilotが質問しています' "$MESSAGE"
    ;;
  permission_prompt)
    ~/.local/bin/notify.sh '🔐 許可が必要です' "$MESSAGE"
    ;;
esac
