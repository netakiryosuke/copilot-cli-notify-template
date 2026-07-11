#!/usr/bin/env bash
# Dispatches notifications to all configured backends.
# Usage: notify.sh <title> [message]

TITLE="$1"
MESSAGE="${2:-}"

~/.local/bin/notify-windows.sh "$TITLE" "$MESSAGE"
~/.local/bin/notify-slack.sh "$TITLE" "$MESSAGE"
