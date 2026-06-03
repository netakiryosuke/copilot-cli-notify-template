SESSION_DIR="$HOME/.copilot/session-state"

tail -F "$SESSION_DIR"/*/event.jsonl 2>/dev/null | \
  jq --unbuffered -r '
    select(
      .type == "tool.execution_start" and
      .data.toolName == "ask_user"
    ) | .data.arguments.question // "質問があります"
  ' | while IFS= read -r question; do
    ~/.local/bin/notify.sh '❓ Copilotから質問' "$question"
  done
