#!/usr/bin/env bash
# Sends a notification to Slack via Incoming Webhook.
# Usage: notify-slack.sh <title> [message]

TITLE="$1"
MESSAGE="${2:-}"

if [ -z "$SLACK_WEBHOOK_URL" ]; then
  exit 0
fi

PAYLOAD=$(jq -n --arg title "$TITLE" --arg message "$MESSAGE" '{
  "blocks": [
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": ("*" + $title + "*\n" + $message)
      }
    }
  ]
}')

curl -s -X POST "$SLACK_WEBHOOK_URL" \
  -H 'Content-type: application/json' \
  -d "$PAYLOAD" > /dev/null &
