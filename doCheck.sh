#!/bin/bash
# npm run check の出力をログファイルと端末に保存するスクリプト

set -e

# ヘルプ表示
show_help() {
  cat << 'EOF'
Usage: ./doCheck.sh [OPTIONS]

npm run check を実行して、出力をログファイルと端末に同時に保存します。

Options:
  -h, --help       このヘルプメッセージを表示して終了
  -l, --log-only   ログファイルのみに保存（端末には出力しない）
  -n, --no-log     ログを保存しない（端末にのみ出力）

Examples:
  ./doCheck.sh              # 通常実行（ログと端末に出力）
  ./doCheck.sh -h           # ヘルプを表示
  ./doCheck.sh -l           # ログのみに保存
  ./doCheck.sh -n           # ログを保存しない

Output:
  ログファイルは ./log/npm-run-check-YYYY-MM-DD-HHMM.log に保存されます。
  例: ./log/npm-run-check-2026-10-02-2325.log
EOF
}

# オプション解析
LOG_FILE=true
CONSOLE_OUTPUT=true

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      show_help
      exit 0
      ;;
    -l|--log-only)
      CONSOLE_OUTPUT=false
      shift
      ;;
    -n|--no-log)
      LOG_FILE=false
      shift
      ;;
    *)
      echo "Unknown option: $1" >&2
      echo "Use -h or --help for help" >&2
      exit 1
      ;;
  esac
done

# ログディレクトリ作成
mkdir -p ./log

# ログファイル名（年-月-日-時分形式）
TIMESTAMP=$(date "+%Y-%m-%d-%H%M")
LOGFILE="./log/npm-run-check-${TIMESTAMP}.log"

# npm run check を実行
if [ "$LOG_FILE" = true ] && [ "$CONSOLE_OUTPUT" = true ]; then
  # ログと端末の両方に出力
  npm run check 2>&1 | tee "$LOGFILE"
  EXIT_CODE=${PIPESTATUS[0]}
  echo ""
  echo "✓ ログファイルに保存されました: $LOGFILE"
elif [ "$LOG_FILE" = true ]; then
  # ログのみに出力
  npm run check > "$LOGFILE" 2>&1
  EXIT_CODE=$?
  echo "✓ ログファイルに保存されました: $LOGFILE"
else
  # 端末のみに出力
  npm run check 2>&1
  EXIT_CODE=$?
fi

exit $EXIT_CODE
