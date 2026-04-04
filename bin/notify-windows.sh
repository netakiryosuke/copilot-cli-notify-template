#!/usr/bin/env bash
# Sends a toast notification on Windows via WSL using PowerShell.
# Usage: notify-windows.sh <title> [message]

NOTIFY_TITLE="$1"
NOTIFY_MESSAGE="${2:-}"

# Pass values via environment variables to avoid PowerShell code injection.
NOTIFY_TITLE="$NOTIFY_TITLE" NOTIFY_MESSAGE="$NOTIFY_MESSAGE" \
powershell.exe -Command "
  Add-Type -AssemblyName System.Windows.Forms
  \$n = New-Object System.Windows.Forms.NotifyIcon
  \$n.Icon = [System.Drawing.SystemIcons]::Information
  \$n.Visible = \$true
  \$n.ShowBalloonTip(5000, \$env:NOTIFY_TITLE, \$env:NOTIFY_MESSAGE, [System.Windows.Forms.ToolTipIcon]::Info)
  Start-Sleep -Seconds 6
  \$n.Dispose()
" 2>/dev/null &
