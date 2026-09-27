#!/bin/bash
# Claude Code の PreToolUse フック (Write / Edit)。書き込もうとしている中身に図のフェンスや
# 図のファイルがあれば、描画の skill を読んで点検表を通すよう、Claude に文脈を足す。
# 図の良し悪しは判定しない (思い出させるだけ)。jq が要る。
input=$(cat)
file=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')
text=$(printf '%s' "$input" | jq -r '.tool_input.content // .tool_input.new_string // empty')

hit=""
case "$file" in
  *.kicad_sch|*.fzz|*.tex) hit=1 ;;
esac
if printf '%s' "$text" | grep -qE '^[[:space:]]*(```|~~~)[[:space:]]*(circuit|bread|breadboard|perf|perfboard|copper|circuitikz|tikz)\b'; then
  hit=1
fi
[ -n "$hit" ] || exit 0

jq -n '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    additionalContext: "This edit contains a figure meant for human readers. Before drawing or changing it, load the matching drawing-convention skill (readable-schematic for schematics, breadboard-wiring, perfboard-wiring, copper-board), follow its conventions, render the figure to an image, and go through the skill checklist item by item. Report the checklist result for each figure."
  }
}'
