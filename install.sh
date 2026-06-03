#!/usr/bin/env bash
# Installs the Copilot CLI notification hooks and scripts.
# Run this script from the repository root.
#
# Options:
#   -f  Force overwrite of existing hooks.json without prompting

set -euo pipefail

FORCE=false
while getopts "f" opt; do
  case "$opt" in
    f) FORCE=true ;;
    *) echo "Usage: $0 [-f]" >&2; exit 1 ;;
  esac
done

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
cp "$REPO_DIR/bin/copilot-pre-tool.sh"  "$BIN_DIR/copilot-pre-tool.sh"
chmod +x "$BIN_DIR"/notify.sh \
         "$BIN_DIR"/notify-windows.sh \
         "$BIN_DIR"/notify-slack.sh \
         "$BIN_DIR"/copilot-post-tool.sh \
         "$BIN_DIR"/copilot-pre-tool.sh

echo "==> Installing hooks.json to $HOOKS_DIR ..."
HOOKS_DEST="$HOOKS_DIR/hooks.json"
if [ -f "$HOOKS_DEST" ] && [ "$FORCE" = false ]; then
  read -r -p "    hooks.json already exists. Overwrite? [y/N] " answer
  case "$answer" in
    [yY]*) ;;
    *) echo "    Skipped."; SKIP_HOOKS=true ;;
  esac
fi

if [ "${SKIP_HOOKS:-false}" = false ]; then
  cp "$REPO_DIR/hooks/hooks.json" "$HOOKS_DEST"
  echo "    Installed."
fi

echo ""
echo "✅ Installation complete."
echo ""
echo "Next steps:"
echo "  1. (Slack) Export your webhook URL in ~/.bashrc or ~/.zshrc:"
echo '     export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"'
echo "  2. (Windows/WSL) No extra setup needed — uses powershell.exe."
echo "  3. Restart or reload your shell, then start a Copilot CLI session."
