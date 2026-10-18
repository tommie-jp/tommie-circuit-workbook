# Glossary and style for the English edition

The Japanese text is the source. The English text is a translation of it: when a fact is wrong, fix the Japanese
file and translate it again. Read this file, `.claude/skills/workbook-writing/SKILL.md` and the `README.md`
section "単位の書き方" before translating. Add a term here the first time you need it.

## Structure of an exercise

Same file name and same order as the Japanese file (`en/<book>/<chapter>/<name>.md`). The front matter keeps every
key of the Japanese file (`book`, `chapter`, `id`, `tier`, `source`, `board`, `tools`, `device`, `era`) with the
same values. Only `title` is English. Add `ja: <hash>` (see "Staleness").
The first heading is `# <id> <title>`.

| Japanese section | English section |
| --- | --- |
| 説明 | Overview |
| 回路図 | Schematic |
| 実体配線図 | Wiring diagram |
| 部品 | Parts |
| 部品表 | Parts list |
| 計器の設定 | Instrument settings |
| 掃引の設定 | Sweep settings |
| 見るべき値 | Values to check |
| 見るべき値 (シミュレーションを実行して得た値) | Values to check (values obtained by running the simulation) |
| 出典 | Sources |
| LTspice での確かめ | Verification with LTspice |
| LTspice での確かめ (対象外) | Verification with LTspice (not applicable) |
| シミュレーションでの確かめ | Verification by simulation |
| シミュレーションでの確かめ (対象外を含む) | Verification by simulation (including items out of scope) |
| プログラムでの確かめ | Verification with the program |
| エミュレータ (picoemu) での確かめ | Verification with the emulator (picoemu) |
| この実験で確かめる式 | Equations checked in this experiment |
| Logic に見えるはずの画面 | Expected Logic screen |
| 画面に見えるはずのもの | What the screen should show |
| 計器の画面 | Instrument screen |
| オシロで見る | Viewing on the oscilloscope |
| 論理図 | Logic diagram |
| ブロック図 | Block diagram |
| 状態遷移図 | State diagram |
| 流れの図 | Flow diagram |
| 動かす | Run it |
| 動かす — PC のシミュレーション | Run it — simulation on a PC |
| 手順 | Procedure |
| 決めたこと | Decisions |
| テストベンチ | Testbench |
| シミュレーションの波形 | Simulated waveforms |
| FPGA に載せるとき | Putting it on the FPGA |
| 合成と配置配線 | Synthesis and place-and-route |
| Pico 2 のプログラム | Pico 2 program |
| Pico 2 のピンの割り当て | Pico 2 pin assignment |
| ブレッドボードの限度の確認 | Checking the limits of the breadboard |
| 確かめていないこと | What has not been checked |

Alerts keep their kind (`> [!WARNING]`, `> [!NOTE]`). "実機で動かしていない" is "not yet tested on hardware".

## Words

| Japanese | English | Note |
| --- | --- | --- |
| 必須 / 入門 / 中級 | Essential / Introductory / Intermediate | the three tiers |
| 冊 / 章 / 題 | book / chapter / exercise | |
| 基板 (総称) | board | generic. Name the real thing when you can |
| ブレッドボード | breadboard | |
| ユニバーサル基板 | perfboard | |
| 銅張り基板 | copper-clad board | |
| FPGA ボード | FPGA board | |
| ピン (部品の足) | pin | never "leg" or "lead" for a part's terminal |
| 端子 | terminal | |
| 回路図 | schematic | |
| 実体配線図 | wiring diagram | |
| 寸法図 | dimension drawing | copper-clad board drawings |
| 信号発生器 (AD3 の Wavegen、NanoVNA の出力) | signal generator | an instrument. Keep "Wavegen" for the WaveForms tool |
| 発振回路 | oscillator circuit | a circuit that oscillates |
| 発振器 (部品) | oscillator | a component, e.g. a crystal oscillator |
| 計器 | instrument | |
| ひずみ / 歪み率 | distortion / distortion factor | |
| センサー | sensor | |
| 時定数 | time constant | |
| 実効値 | RMS value | `V<sub>rms</sub>` |
| 波高値 / ピーク値 / 振幅 (peak) | peak value / amplitude | `V<sub>p</sub>`. Peak-to-peak is `Vpp` |
| 計算値 | calculated value | |
| 見積り | estimate | a value that was not verified |
| 目安 | rough guide | a typical value, not a guarantee |
| 仮定 | assumption | |
| 実測 | measured | |
| 理想 | ideal | |
| 未確認 | not verified | |
| 出典 | source | |
| 借りた回路 | borrowed circuit | |
| 負荷 | load | |
| 入力 / 出力 | input / output | |
| 帯域 | bandwidth | |
| 周波数 | frequency | |
| 直流 / 交流 | DC / AC | |
| 電源 | power supply | "+5 V rail" for a rail |
| 接地 / GND | ground / GND | draw it as GND in figures |
| 部品表 | parts list | |
| 手持ちの部品 | parts you have | |
| 順方向 / 逆方向 | forward / reverse direction | |
| 順方向電圧 | forward voltage (V<sub>F</sub>) | |
| 逆耐圧 | reverse breakdown voltage | |
| アノード / カソード | anode / cathode | |
| 発光ダイオード | light-emitting diode (LED) | |
| テスター | multimeter | |
| 直流電圧レンジ / 電流レンジ | DC voltage range / current range | |
| 合成抵抗 | combined resistance | |
| 直列 / 並列 | series / parallel | |
| 分圧 | voltage divider | |
| 直列抵抗 | series resistor | |
| ジャンパ線 | jumper wire | |
| 単 3 電池 | AA battery | |
| 電源レール (ブレッドボード) | power rail | "top + rail", "GND rail" |
| 電源の箱 (図の機器) | power supply box | the label in the figure is "Analog Discovery 3 (Supplies)" |
| 整流 / 保護の回路 | rectifier / protection circuits | |
| 発振器 (0-6 の計器) | signal generator | as in the instrument list |
| ロール表示 | roll mode | |
| 共通 (端子) | common | |
| 1 回路 2 接点 | 1 pole, 2 throw (SPDT) | |
| 帯のある側 (ダイオード) | striped side | the cathode end |
| 電源装置 | bench power supply | 01-circuits chapter 13 |
| ブレッドボード中央の溝 | center gap ("the gap", "across the gap") | not "trench" |
| 電源 1 系統 (AD3 の Supplies の 1 つ) | supply channel | not "rail". "rail" is only a power rail of the breadboard |
| テスターの棒 / リード線 | lead (meter lead, clip lead) | a part's terminal is a pin, never a lead |
| IC のピン番号 (10・12 章、ブレッドボード図) | PIN N | uppercase, as in the Japanese. Pico 2 pins are `pin N` |
| 触れる板 (金属板、2-4) | touch plate | |
| 弛張発振 | relaxation oscillation | |
| 突入電流 | inrush current | |
| 帰還 / 負帰還 / 正帰還 | feedback / negative feedback / positive feedback | |
| 開ループ利得 | open-loop gain | |
| 入力バイアス電流 | input bias current | |
| 仮想接地 | virtual ground | |
| 比較器 / ヒステリシス | comparator / hysteresis | |
| ツェナー電圧 / シリーズレギュレータ | zener voltage / series regulator | |
| リップル / ドロップアウト | ripple / dropout | |
| 逆起電力 / フライバック電圧 | back EMF / flyback voltage | |
| 1 次 / 2 次 / 巻数比 | primary / secondary / turns ratio | |
| 差動対 / テール抵抗 | differential pair / tail resistor | |
| 動作点 / バイアス | operating point / bias | |
| ダーリントン接続 | Darlington connection | |
| 搬送波 / 側波 / 変調指数 | carrier / sidebands / modulation index | |
| 禁止入力 / 負論理 | forbidden input / active low | |
| 方形波 / ボード線図 | square wave / Bode plot | |
| 遮断周波数 / 利得 | cutoff frequency / gain | |
| 電験三種 (冊の名) | Denken Level 3 | |

Instruments and tools keep their names: Analog Discovery 3 (AD3), WaveForms (menu names Scope, Wavegen, Supplies,
Logic, Spectrum, Network, Patterns, Protocol), LiteVNA64, NanoVNA, tinySA Ultra, LTspice, Pico 2, Pico SDK,
MicroPython, Verilator, Yosys, nextpnr.

## Decisions made while translating

- Cross references to other exercises keep their number: "(0-4)" stays "(0-4)"; add "see" only when the sentence needs it
  ("see 0-4"). A chapter reference "(第 N 章)" is "(Chapter N)".
- The front matter `source` value is copied as it is (`自作`). The Sources section says "Original work."
- Table column headings for parts lists: Symbol / Part / Value.
- Figure `title:` length: a `circuit` title is at most 60 characters (the fence refuses more). A `scope` title is cut
  off with "…" past about 45 characters and a `breadboard` title past about 65. Do not put a `:` in a `title:` (YAML).
  Use a comma or a dash instead. `npm run en:check` runs each fence's own `check`, which finds these.

- Table headings for check tables: Measure / What it shows / Result / Match. Cells start with a lowercase letter; the
  result word at the start of a cell (`Agrees`) is capitalized. `50 %` has a space.
- Section and table headings use sentence case ("Parts list", not "Parts List").
- Do not write `1s` / `2s` / `0s` for digits (en-check reads them as seconds): use "ones place", "twos place", "zeros and ones".
- Title limits are by width, not only by count: a `scope`, `spectrum`, `vna`, `graph` or `copper` title is cut with "…" past
  about 55 characters, a `breadboard` title or `notes:` past about 55–60. Shorten the title and render the figure to check.
- Inside a figure `title:` and `- text:` annotation do not use a colon followed by a space, `=` or `;` — YAML breaks (the annotation
  disappears from the figure) or the fence's own check refuses it. Use a comma or a dash.
- Cross-book references: write the book name ("10-3 of the Analog Discovery book").

## Style

- American spelling (analyzer, color, meter).
- Short declarative sentences in the present tense. Procedures are numbered imperative steps ("Connect CH1 to ...").
- Say who measures what: "CH1 reads ..." rather than "it is seen that ...".
- A Greek letter used as a **symbol** gets its name once, at its first appearance in a document:
  "reflection coefficient Γ (gamma)". Units (Ω, µ) do not.
- Do not translate part numbers, pin names, net names, file names, command lines or code. Translate comments.
- Japanese punctuation becomes ASCII. A range written with 〜 becomes an en dash (`0–3 MHz`) or "to".
- Figure titles start with `Fig. N` (the Japanese `図N`). The prose says "Fig. 3". Keep each title short enough for
  the figure (a `circuit` title is at most 60 characters).
- Do not add facts. If the English reads better with one more sentence, the Japanese file gets the sentence first.

## Units (same rules as the Japanese text)

One space between the number and the unit (`10 kΩ`, `100 kHz`, `5 V`, `25 °C`, `−30 dBm`). Micro is `µ` (U+00B5):
`µs`, `µF`. Peak-to-peak is `Vpp`, peak is `V<sub>p</sub>`, RMS is `V<sub>rms</sub>`. The minus sign is `−` (U+2212).
A `spectrum` figure uses dBm (`unit: dBm`). Values inside a fence follow the fence's own spelling (`10kHz`).
`npm run en:check` checks these.

## Figures

The fence itself does not change: parts, values, addresses, wires, `board:`, `device:` stay as in the Japanese file.
Translate `title:`, annotation text and other human-readable strings. The figure rules of the drawing skills
(`readable-schematic`, `breadboard-wiring`, `perfboard-wiring`, `copper-board`, `instrument-screen`,
`readable-graph`) still apply: after translating, render the figure to an image and look at it. English strings
are often longer than Japanese ones, so check that labels do not overlap or run off the figure.
The first line of a fence (`# Schematic (tommie-fence circuit fence)`) and the image line under it are written
by `npm run figures`, not by hand.

| Fence | Label | Image alt |
| --- | --- | --- |
| `circuit` | Schematic | Schematic |
| `breadboard` | Breadboard wiring diagram | Breadboard wiring diagram |
| `perfboard` | Perfboard wiring diagram | Perfboard wiring diagram |
| `copper` | Copper-clad board dimension drawing | Copper-clad board dimension drawing |
| `vna` | NanoVNA screen | NanoVNA screen |
| `scope` | Oscilloscope screen | Oscilloscope screen |
| `spectrum` | Spectrum analyzer screen | Spectrum analyzer screen |
| `graph` | Graph | Graph |
| `logic` | Logic analyzer screen | Logic analyzer screen |
| `plantuml` | (no label line) | Block diagram |

## Staleness

`ja: <hash>` in the front matter is the git blob hash of the Japanese file the translation was made from
(`git hash-object <file>`). `npm run en:check` warns when the Japanese file has changed since. A warning does not
fail the check. `npm run i18n:stale` lists the stale and the missing translations.
