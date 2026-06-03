#!/usr/bin/env bash
# notification hook: handles Copilot CLI system notifications.
# Reads JSON from stdin as provided by the Copilot CLI hook runtime.
#
# Payload fields:
#   notification_type: "elicitation_dialog" | "permission_prompt" | etc.
#   message: human-readable notification text
#   title: optional short title

INPUT=$(cat)
NOTIFICATION_TYPE=$(echo "$INPUT" | jq -r '.notification_type // empty')
MESSAGE=$(echo "$INPUT" | jq -r '.message // empty')
TITLE=$(echo "$INPUT" | jq -r '.title // empty')

case "$NOTIFICATION_TYPE" in
  elicitation_dialog)
    # ask_user: Copilot is waiting for user input
    DISPLAY_TITLE="${TITLE:-❓ Copilotが質問しています}"
    ~/.local/bin/notify.sh "$DISPLAY_TITLE" "$MESSAGE"
    ;;
  permission_prompt)
    # Copilot is asking for permission to execute a tool
    DISPLAY_TITLE="${TITLE:-🔐 許可が必要です}"
    ~/.local/bin/notify.sh "$DISPLAY_TITLE" "$MESSAGE"
    ;;
esac
