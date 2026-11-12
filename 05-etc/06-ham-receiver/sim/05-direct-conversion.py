#!/usr/bin/env python3
"""6-5 ダイレクトコンバージョン受信機の数を算術で確かめる (SPICE の模型が無い SA612 の代わり)。

1. Si5351A の分周 (PLL = 25 MHz x (a + b/c)、出力 = VCO / 120) と分解能
2. 局発の減衰器 (1 kΩ + 100 Ω) と方形波の基本波
3. 試験の信号の大きさ (W1 → R4 5.1 kΩ → 50 Ω の終端つきのアンテナ端子 → T1 → IN_A → 音声出力)
4. 理想の乗算器 (方形波の局発 x 正弦の信号) で、局発の上下 700 Hz が同じ 700 Hz になること、
   3 倍の高調波 (21 MHz 台) にも感度があること
使い方: python3 -I 05-direct-conversion.py
"""
import math

import numpy as np

XTAL = 25_000_000
DIV = 120
C = 1_000_000


def si5351(f_hz):
    n = f_hz * DIV
    a = n // XTAL
    b = (n % XTAL) // (XTAL // C)
    fl = 128 * b // C
    p1 = 128 * a + fl - 512
    p2 = 128 * b - C * fl
    actual = XTAL * (a + b / C) / DIV
    return a, b, p1, p2, actual


print('== 1. Si5351A ==')
for f in (7_000_000, 7_010_000, 7_010_100, 7_200_000, 7_450_000):
    a, b, p1, p2, act = si5351(f)
    print(f'{f:>9} Hz: VCO {f * DIV / 1e6:.3f} MHz  a={a} b={b} c={C}  P1={p1} P2={p2}  出力 {act:.3f} Hz')
print(f'分解能 = {XTAL / C / DIV:.4f} Hz、100 Hz の刻みは b を {100 * DIV // (XTAL // C)} 動かす')
print(f'出力の分周 120 の P1 = {128 * DIV - 512} (0x{128 * DIV - 512:04X})')

print('== 2. 局発の減衰器 ==')
vpp = 3.3 * 100 / (1000 + 100)
fund = 4 / math.pi * vpp / 2
print(f'方形波 3.3 Vpp → {vpp:.3f} Vpp、基本波の振幅 {fund * 1e3:.0f} mV (= {2 * fund:.3f} Vpp)')
print(f'OSC_B から見た源の抵抗 = {1000 * 100 / 1100:.1f} Ω')

print('== 3. 試験の信号 ==')
w1 = 10e-3                      # W1 の振幅
r4, r50, vr1 = 5100.0, 50.0, 1000.0
n = 32 / 4
rp = 150 * 2 * math.pi * 7.1e6 * 4.096e-6          # 無負荷 Q 150 の並列抵抗
rin_link = (1500 * rp / (1500 + rp)) / n**2        # リンクから見た共振時の抵抗
zt = 1 / (1 / r50 + 1 / vr1 + 1 / rin_link)
v_ant = w1 * zt / (r4 + zt)
v_ina = v_ant * n
g_mix_db, g_af_db = 17.0, 43.55
v_out = v_ina * 10 ** ((g_mix_db + g_af_db) / 20)
print(f'リンクから見た抵抗 {rin_link:.1f} Ω、端子の合成 {zt:.1f} Ω')
print(f'アンテナ端子 {v_ant * 1e6:.1f} µV、IN_A {v_ina * 1e6:.0f} µV (振幅)')
print(f'音声出力 = {v_out * 1e3:.0f} mV (振幅) = {2 * v_out:.2f} Vpp、33 Ω で {v_out**2 / 2 / 33 * 1e3:.2f} mW')
emf = w1 * (1 / (1 / r50 + 1 / vr1)) / (r4 + 1 / (1 / r50 + 1 / vr1))
print(f'50 Ω の源に直すと起電力 {emf * 1e6:.1f} µV (W1 の {20 * math.log10(emf / w1):.1f} dB)')
g_total = v_out / emf
print(f'起電力から音声出力まで {20 * math.log10(g_total):.1f} dB ({g_total:.0f} 倍)。起電力 1 µV で {g_total * 1e-3:.2f} mV')

print('== 4. 乗算器の模型 ==')
fs = 280e6
t = np.arange(int(fs * 0.01)) / fs                 # 10 ms = 700 Hz の 7 周期
lo = np.sign(np.sin(2 * np.pi * 7.0100e6 * t))


def tone_700(f_rf):
    y = np.sin(2 * np.pi * f_rf * t) * lo
    ref = np.exp(-2j * np.pi * 700 * t)
    return 2 * abs(np.mean(y * ref))


base = tone_700(7.0107e6)
for name, f in (('局発 + 700 Hz (7.0107 MHz)', 7.0107e6), ('局発 − 700 Hz (7.0093 MHz)', 7.0093e6),
                ('3 倍の高調波 + 700 Hz (21.0307 MHz)', 21.0307e6), ('局発 + 5 kHz (7.0150 MHz)', 7.0150e6)):
    v = tone_700(f)
    print(f'{name}: 700 Hz の振幅 {v:.4f} ({20 * math.log10(max(v, 1e-9) / base):+.1f} dB)')
print(f'理想の値 2/π = {2 / math.pi:.4f}')
