#!/usr/bin/env bash
# Sends a notification to Slack via Incoming Webhook.
# Usage: notify-slack.sh <title> [message]
#
# Prerequisites:
#   Set the SLACK_WEBHOOK_URL environment variable (e.g. in ~/.bashrc or ~/.zshrc):
#   export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"

TITLE="$1"
MESSAGE="${2:-}"

if [ -z "$SLACK_WEBHOOK_URL" ]; then
  # Skip silently when the webhook URL is not configured.
  exit 0
fi

# Use Slack Block Kit format for better title/message separation
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
