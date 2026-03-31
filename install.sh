#!/usr/bin/env bash
# Installs the Copilot CLI notification hooks and scripts.
# Run this script from the repository root.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="$HOME/.local/bin"
HOOKS_DIR="$HOME/.copilot/hooks"

echo "==> Creating directories..."
mkdir -p "$BIN_DIR" "$HOOKS_DIR"

echo "==> Copying scripts to $BIN_DIR ..."
cp "$REPO_DIR/bin/notify.sh"            "$BIN_DIR/notify.sh"
cp "$REPO_DIR/bin/notify-windows.sh"    "$BIN_DIR/notify-windows.sh"
cp "$REPO_DIR/bin/notify-slack.sh"      "$BIN_DIR/notify-slack.sh"
cp "$REPO_DIR/bin/copilot-post-tool.sh" "$BIN_DIR/copilot-post-tool.sh"
chmod +x "$BIN_DIR"/notify.sh \
         "$BIN_DIR"/notify-windows.sh \
         "$BIN_DIR"/notify-slack.sh \
         "$BIN_DIR"/copilot-post-tool.sh

echo "==> Installing hooks.json to $HOOKS_DIR ..."
if [ -f "$HOOKS_DIR/hooks.json" ]; then
  echo "    hooks.json already exists — skipping (back it up manually if needed)"
else
  cp "$REPO_DIR/hooks/hooks.json" "$HOOKS_DIR/hooks.json"
fi

echo ""
echo "✅ Installation complete."
echo ""
echo "Next steps:"
echo "  1. (Slack) Export your webhook URL in ~/.bashrc or ~/.zshrc:"
echo '     export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"'
echo "  2. (Windows/WSL) No extra setup needed — uses powershell.exe."
echo "  3. Restart or reload your shell, then start a Copilot CLI session."
