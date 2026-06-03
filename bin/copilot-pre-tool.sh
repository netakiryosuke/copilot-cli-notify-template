#!/usr/bin/env bash
# preToolUse hook: guards dangerous commands and notifies user.
# Reads JSON from stdin as provided by the Copilot CLI hook runtime.
# NOTE: toolArgs is a JSON-encoded string, so we use `fromjson` to parse it.
#
# Dangerous command patterns that require explicit approval.
# Add or remove patterns to customize.
DANGEROUS_PATTERNS=(
  "git push"
  "rm -rf"
  "rm -r"
  "sudo rm"
  "chmod -R 777"
  "dd if="
  "> /dev/sd"
  "mkfs"
  "DROP TABLE"
  "DROP DATABASE"
)

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.toolName // empty')

if [ "$TOOL_NAME" = "bash" ]; then
  COMMAND=$(echo "$INPUT" | jq -r '.toolArgs | fromjson | .command // empty')

  for PATTERN in "${DANGEROUS_PATTERNS[@]}"; do
    if echo "$COMMAND" | grep -qF "$PATTERN"; then
      # Send notification so user knows approval is needed even if away
      ~/.local/bin/notify.sh "⚠️ 要確認: $PATTERN" "Copilotが危険なコマンドを実行しようとしています"

      # Require interactive approval at the terminal
      # If no TTY (non-interactive), block by default for safety
      if [ ! -t 0 ] && [ ! -t 1 ]; then
        echo "[copilot-pre-tool] Non-interactive session: blocked '$PATTERN' for safety." >&2
        exit 1
      fi

      echo ""
      echo "⚠️  Copilot が以下のコマンドを実行しようとしています:"
      echo "   $COMMAND"
      echo ""
      read -r -p "   許可しますか？ [y/N] " answer </dev/tty
      echo ""

      case "$answer" in
        [yY]*)
          echo "[copilot-pre-tool] Approved: $PATTERN"
          exit 0
          ;;
        *)
          echo "[copilot-pre-tool] Denied: $PATTERN" >&2
          exit 1
          ;;
      esac
    fi
  done
fi
