#!/usr/bin/env bash
sleep 2
JSONL=$(ls -t ~/.copilot/session-state/*/events.jsonl 2>/dev/null | head -1)
[ -z "$JSONL" ] && exit 0
tail -F "$JSONL" 2>/dev/null | \
  jq --unbuffered -r '
    select(.type == "tool.execution_start" and .data.toolName == "ask_user")
    | .data.arguments.question // "質問があります"
  ' | while IFS= read -r q; do
    ~/.local/bin/notify.sh '❓ Copilotから質問' "$q"
  done
