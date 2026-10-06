# LTspice での照合

ngspice の結果を LTspice (Windows 版を WSL から) で照合した。ネットリストは `compare_gain.py` と `diff_output.py` が書く物と同じで、
末尾に `.tran 0 1.4m 0 25n` と `.options plotwinsize=0` を足した (波形を間引かせない)。
455 kHz の大きさは、どちらも最後の 1 ms をハニング窓で FFT して読んだ (`compare_gain.py` の `amp`)。

| ネットリスト | 条件 | ngspice | LTspice |
| --- | --- | --- | --- |
| `fet_r7.cir` | 3SK291、LO +7 dBm、R7 2 kΩ | +1.24 dB | +1.20 dB |
| `fet_nor7.cir` | 3SK291、LO +7 dBm、R7 なし | +6.27 dB | +6.20 dB |
| `single_r7.cir` | 1 石、LO +7 dBm、R7 2 kΩ | +10.58 dB | +10.56 dB |
| `single_nor7.cir` | 1 石、LO +7 dBm、R7 なし | +15.80 dB | +15.76 dB |
| `diffnew_r7.cir` | 差動対 (4-2)、LO 0 dBm、R7 2 kΩ | +0.34 dB (ミラーの出力で RF は IF の −35.9 dB) | +0.33 dB (−36.1 dB) |
| `diffnew_nor7.cir` | 差動対 (4-2)、LO 0 dBm、R7 なし | +5.05 dB (−40.6 dB) | +5.03 dB (−40.6 dB) |

RF −30 dBm、信号源 0 Ω。利得は IF OUT (50 Ω) の電力 ÷ RF の有能電力。差は 0.1 dB 以内。
