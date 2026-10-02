#!/bin/bash
# npm run check の出力をログファイルと端末に保存するスクリプト

# ログディレクトリ作成
mkdir -p ./log

# ログファイル名（年-月-日-時分形式）
TIMESTAMP=$(date "+%Y-%m-%d-%H%M")
LOGFILE="./log/npm-run-check-${TIMESTAMP}.log"

# npm run check を実行して、出力をログファイルと端末に同時に保存
npm run check 2>&1 | tee "$LOGFILE"

# 終了コードを保持
EXIT_CODE=${PIPESTATUS[0]}

echo ""
echo "ログファイルに保存されました: $LOGFILE"

exit $EXIT_CODE
