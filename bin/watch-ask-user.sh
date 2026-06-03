#!/usr/bin/env bash

PGID=$(ps -o pgid= $$ | tr -d ' ')

cleanup() {
    kill -- -"${PGID}" 2>/dev/null || true
}

trap cleanup EXIT TERM INT

sleep 2

JSONL=$(ls -t ~/.copilot/session-state/*/events.jsonl 2>/dev/null | head -1)
[ -z "$JSONL" ] && exit 0

while IFS= read -r q; do
    ~/.local/bin/notify.sh '❓ Copilotから質問' "$q"
done < <(
    tail -F "$JSONL" 2>/dev/null |
    jq --unbuffered -r '
        select(.type == "tool.execution_start" and .data.toolName == "ask_user")
        | .data.arguments.question // "質問があります"
    '
)