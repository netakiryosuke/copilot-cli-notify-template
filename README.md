# copilot-cli-notify-template

GitHub Copilot CLI のフック機能を使って、タスク完了・エラー発生・コミット時などに通知を送るテンプレートです。

## 機能

| フックイベント | 通知内容 |
|---|---|
| `agentStop` | Copilot タスク完了 |
| `subagentStop` | サブエージェント処理完了 |
| `postToolUse` | `git commit` を検知してコミットメッセージを通知 |
| `errorOccurred` | エラー発生 |

## スクリーンショット

### Windows トースト通知

<img width="586" height="184" alt="image" src="https://github.com/user-attachments/assets/a4600ce8-e0cc-49f6-8ae0-e64783b3deb3" />

### Slack 通知

<img width="527" height="245" alt="image" src="https://github.com/user-attachments/assets/e268cef3-17b2-404d-9505-177f59340fd6" />

## 通知バックエンド

- **Windows トースト通知**（WSL 環境で `powershell.exe` を使用）
- **Slack Incoming Webhook**

## セットアップ

### 1. インストール

```bash
git clone https://github.com/netakiryosuke/copilot-cli-notify-template.git
cd copilot-cli-notify-template
./install.sh
```

`install.sh` は以下を行います：
- `bin/` 以下のスクリプトを `~/.local/bin/` へコピー
- `hooks/hooks.json` を `~/.copilot/hooks/` へコピー（既存ファイルは上書きしない）

### 2. Slack Webhook URL の設定

Slack 通知を使う場合は、Incoming Webhook URL を環境変数に設定してください。

```bash
# ~/.bashrc に追加
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
```

Slack を使わない場合は何も設定しなくて構いません（スキップされます）。

### 3. Windows トースト通知（WSL のみ）

WSL 上から `powershell.exe` が実行できる環境であれば、追加設定なしで動作します。

## ファイル構成

```
.
├── bin/
│   ├── notify.sh               # 通知ディスパッチャー
│   ├── notify-windows.sh       # Windows トースト通知
│   ├── notify-slack.sh         # Slack 通知
│   └── copilot-post-tool.sh    # postToolUse フック
├── hooks/
│   └── hooks.json              # Copilot CLI フック設定
└── install.sh                  # インストールスクリプト
```

## カスタマイズ

`hooks/hooks.json` のメッセージ文言や `bin/notify.sh` のバックエンド呼び出しを編集することで、通知内容や送信先を自由に変更できます。
