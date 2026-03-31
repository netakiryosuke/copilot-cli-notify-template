#!/usr/bin/env bash
# Sends a toast notification on Windows via WSL using PowerShell.
# Usage: notify-windows.sh <title> [message]

TITLE="$1"
MESSAGE="${2:-}"

powershell.exe -Command "
  Add-Type -AssemblyName System.Windows.Forms
  \$n = New-Object System.Windows.Forms.NotifyIcon
  \$n.Icon = [System.Drawing.SystemIcons]::Information
  \$n.Visible = \$true
  \$n.ShowBalloonTip(5000, '$TITLE', '$MESSAGE', [System.Windows.Forms.ToolTipIcon]::Info)
  Start-Sleep -Seconds 6
  \$n.Dispose()
" 2>/dev/null &
