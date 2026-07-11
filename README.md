# copilot-cli-notify-template

GitHub Copilot CLI と Codex CLI の通知をまとめて設定するテンプレートです。Windows トースト通知（WSL）と Slack Incoming Webhook に対応しています。

## 機能

### GitHub Copilot CLI

| フックイベント | 通知内容 |
|---|---|
| `sessionStart` | `ask_user` 呼び出しの監視を開始 |
| `sessionEnd` | 監視を終了 |
| `agentStop` | `✅ Copilot` / タスクが完了しました |
| `subagentStop` | サブエージェント処理完了 |
| `postToolUse` | `git commit` を検知してコミットメッセージを通知 |
| `errorOccurred` | エラー発生 |

`watch-ask-user.sh` はセッションの `events.jsonl` を監視し、`ask_user` の質問を通知します。Copilot のシステム通知では、質問待ち・権限要求も通知できます。

### Codex CLI

Codex のトップレベル `notify` 設定を利用し、エージェントターン完了時に `✅ Codex` / `タスクが完了しました` を通知します。Git リポジトリ内で実行された場合は、最新コミットの短縮 SHA と件名も通知に含めます。

加えて `~/.codex/hooks.json` に次の Codex hooks を設定します。

| Codex event | 通知内容 |
|---|---|
| `PermissionRequest` | `🔐 Codexで許可が必要です` と対象操作 |
| `PostToolUse`（`Bash`） | `git commit` を検知して最新コミットを通知 |
| `SubagentStop` | Codex サブエージェントの完了を通知 |

Codex には「Codexがユーザーへ自由入力の質問を出した」ことだけを通知するイベントはありません。`UserPromptSubmit` はユーザーからCodexへ送ったプロンプトのイベントであるため、このテンプレートでは通知しません。権限要求は `PermissionRequest` で通知します。

Codex hooks は初回導入・変更後に信頼確認が必要です。Codex CLI の `/hooks` で内容を確認して有効化してください。Codex 0.144.1 では hooks は安定機能のため、`features.codex_hooks` の有効化は不要です。

## スクリーンショット

### Windows トースト通知

<img width="586" height="184" alt="image" src="https://github.com/user-attachments/assets/a4600ce8-e0cc-49f6-8ae0-e64783b3deb3" />

### Slack 通知

<img width="527" height="245" alt="image" src="https://github.com/user-attachments/assets/e268cef3-17b2-404d-9505-177f59340fd6" />

## 通知バックエンド

- **Windows トースト通知**: WSL 環境で `powershell.exe` を使用
- **Slack Incoming Webhook**: `SLACK_WEBHOOK_URL` を設定した場合のみ送信

## 要件

| ツール | 用途 |
|---|---|
| `jq` | Slack ペイロードと CLI フックの JSON 処理 |
| `curl` | Slack Webhook への HTTP POST |
| `powershell.exe` | Windows トースト通知（WSL 環境のみ） |

```bash
# Ubuntu / Debian
sudo apt install -y jq curl

# macOS (Homebrew)
brew install jq curl
```

Slack 通知だけを使う場合は `powershell.exe` は不要です。

## セットアップ

```bash
git clone https://github.com/netakiryosuke/copilot-cli-notify-template.git
cd copilot-cli-notify-template
./install.sh                    # Copilot と Codex の両方（デフォルト）
./install.sh --githubcopilot    # Copilot のみ
./install.sh --codex            # Codex のみ
```

インストーラーは以下を行います。

- 共有通知スクリプトを `~/.local/bin/` にコピー
- `githubcopilot/hooks/hooks.json` を `~/.copilot/hooks/hooks.json` にコピー（既存ファイルは確認してから上書き。`-f` で強制上書き）
- Codex用スクリプトを `~/.local/bin/` にコピーし、`~/.codex/hooks.json` をインストール（既存ファイルは確認してから上書き。`-f` で強制上書き）
- `~/.codex/config.toml` がなければ作成し、あれば既存内容を保ったままトップレベルの `notify` 設定を先頭へ追加

既にトップレベルの `notify` 設定がある場合、インストーラーはその設定を変更しません。必要であれば次の設定でCodex完了ハンドラーを指定してください。

```toml
notify = ["bash", "-lc", "~/.local/bin/codex-notify.sh"]
```

### Slack Webhook URL

```bash
# ~/.bashrc または ~/.zshrc に追加
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
```

未設定の場合、Slack 通知は送られません。

## ファイル構成

```
.
├── shared/bin/                 # 両 CLI 共通の通知バックエンド
│   ├── notify.sh
│   ├── notify-windows.sh
│   └── notify-slack.sh
├── githubcopilot/
│   ├── bin/                    # Copilot 固有フックハンドラー
│   └── hooks/hooks.json         # Copilot CLI フック設定
├── codex/
│   ├── bin/                     # Codex の通知ハンドラー
│   ├── config.toml              # Codex 設定テンプレート
│   └── hooks.json               # Codex lifecycle hooks
└── install.sh
```

## カスタマイズ

通知文言は `githubcopilot/hooks/hooks.json` と `codex/hooks.json` / `codex/bin/`、送信先は `shared/bin/notify.sh` で変更できます。
