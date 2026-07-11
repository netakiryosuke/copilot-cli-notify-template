#!/usr/bin/env bash
# Installs the GitHub Copilot CLI and Codex CLI notification settings.
# Run this script from the repository root.
#
# Options:
#   --githubcopilot  Install only GitHub Copilot CLI settings
#   --codex          Install only Codex CLI settings
#   -f               Force overwrite of existing hooks.json files
#   -h, --help       Show this help

set -euo pipefail

FORCE=false
INSTALL_GITHUBCOPILOT=false
INSTALL_CODEX=false
SELECTION_MADE=false

usage() {
  cat <<'EOF'
Usage: ./install.sh [OPTIONS]

Install notification settings for GitHub Copilot CLI and/or Codex CLI.
With no CLI selection option, both are installed.

Options:
  --githubcopilot  Install only GitHub Copilot CLI settings
  --codex          Install only Codex CLI settings
  -f               Force overwrite of existing hooks.json files
  -h, --help       Show this help
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --githubcopilot)
      INSTALL_GITHUBCOPILOT=true
      SELECTION_MADE=true
      ;;
    --codex)
      INSTALL_CODEX=true
      SELECTION_MADE=true
      ;;
    -f)
      FORCE=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 1
      ;;
  esac
  shift
done

if [ "$SELECTION_MADE" = false ]; then
  INSTALL_GITHUBCOPILOT=true
  INSTALL_CODEX=true
fi

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="$HOME/.local/bin"
COPILOT_HOOKS_DIR="$HOME/.copilot/hooks"
CODEX_CONFIG_DIR="${CODEX_HOME:-$HOME/.codex}"
CODEX_CONFIG="$CODEX_CONFIG_DIR/config.toml"

echo "==> Creating directories..."
mkdir -p "$BIN_DIR"

echo "==> Copying scripts to $BIN_DIR ..."
cp "$REPO_DIR/shared/bin/notify.sh"         "$BIN_DIR/notify.sh"
cp "$REPO_DIR/shared/bin/notify-windows.sh" "$BIN_DIR/notify-windows.sh"
cp "$REPO_DIR/shared/bin/notify-slack.sh"   "$BIN_DIR/notify-slack.sh"
chmod +x "$BIN_DIR"/notify.sh \
         "$BIN_DIR"/notify-windows.sh \
         "$BIN_DIR"/notify-slack.sh

install_hooks_file() {
  source_file="$1"
  destination_file="$2"
  label="$3"

  if [ -f "$destination_file" ] && [ "$FORCE" = false ]; then
    if ! read -r -p "    $label already exists. Overwrite? [y/N] " answer; then
      answer=""
    fi
    case "$answer" in
      [yY]*) ;;
      *) echo "    Skipped."; return ;;
    esac
  fi

  cp "$source_file" "$destination_file"
  echo "    Installed."
}

if [ "$INSTALL_GITHUBCOPILOT" = true ]; then
  mkdir -p "$COPILOT_HOOKS_DIR"
  cp "$REPO_DIR/githubcopilot/bin/copilot-notification.sh" "$BIN_DIR/copilot-notification.sh"
  cp "$REPO_DIR/githubcopilot/bin/copilot-post-tool.sh" "$BIN_DIR/copilot-post-tool.sh"
  cp "$REPO_DIR/githubcopilot/bin/watch-ask-user.sh" "$BIN_DIR/watch-ask-user.sh"
  chmod +x "$BIN_DIR"/copilot-notification.sh "$BIN_DIR"/copilot-post-tool.sh "$BIN_DIR"/watch-ask-user.sh

  echo "==> Installing GitHub Copilot hooks.json to $COPILOT_HOOKS_DIR ..."
  install_hooks_file "$REPO_DIR/githubcopilot/hooks/hooks.json" "$COPILOT_HOOKS_DIR/hooks.json" "Copilot hooks.json"
fi

if [ "$INSTALL_CODEX" = true ]; then
  mkdir -p "$CODEX_CONFIG_DIR"
  cp "$REPO_DIR/codex/bin/codex-notify.sh" "$BIN_DIR/codex-notify.sh"
  cp "$REPO_DIR/codex/bin/codex-permission-request.sh" "$BIN_DIR/codex-permission-request.sh"
  cp "$REPO_DIR/codex/bin/codex-post-tool.sh" "$BIN_DIR/codex-post-tool.sh"
  cp "$REPO_DIR/codex/bin/codex-subagent-stop.sh" "$BIN_DIR/codex-subagent-stop.sh"
  chmod +x "$BIN_DIR"/codex-notify.sh "$BIN_DIR"/codex-permission-request.sh "$BIN_DIR"/codex-post-tool.sh "$BIN_DIR"/codex-subagent-stop.sh

  echo "==> Configuring Codex completion notification ..."
  CODEX_NOTIFY_LINE='notify = ["bash", "-lc", "~/.local/bin/codex-notify.sh"]'
  if [ ! -f "$CODEX_CONFIG" ]; then
    cp "$REPO_DIR/codex/config.toml" "$CODEX_CONFIG"
    echo "    Created $CODEX_CONFIG."
  elif awk '
  /^[[:space:]]*\[/ { exit }
  /^[[:space:]]*notify[[:space:]]*=/ { found = 1 }
  END { exit !found }
' "$CODEX_CONFIG"; then
    echo "    A top-level notify setting already exists; left unchanged."
  else
    temp_config=$(mktemp "$CODEX_CONFIG_DIR/config.toml.XXXXXX")
    {
      printf '%s\n\n' "$CODEX_NOTIFY_LINE"
      cat "$CODEX_CONFIG"
    } > "$temp_config"
    mv "$temp_config" "$CODEX_CONFIG"
    echo "    Added notify setting to $CODEX_CONFIG."
  fi

  echo "==> Installing Codex hooks.json to $CODEX_CONFIG_DIR ..."
  install_hooks_file "$REPO_DIR/codex/hooks.json" "$CODEX_CONFIG_DIR/hooks.json" "Codex hooks.json"
fi

echo ""
echo "✅ Installation complete."
echo ""
echo "Next steps:"
echo "  1. (Slack) Export your webhook URL in ~/.bashrc or ~/.zshrc:"
echo '     export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"'
echo "  2. (Windows/WSL) No extra setup needed — uses powershell.exe."
echo "  3. Restart or reload your shell, then start a Copilot CLI or Codex session."
