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

Instruments and tools keep their names: Analog Discovery 3 (AD3), WaveForms (menu names Scope, Wavegen, Supplies,
Logic, Spectrum, Network, Patterns, Protocol), LiteVNA64, NanoVNA, tinySA Ultra, LTspice, Pico 2, Pico SDK,
MicroPython, Verilator, Yosys, nextpnr.

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
