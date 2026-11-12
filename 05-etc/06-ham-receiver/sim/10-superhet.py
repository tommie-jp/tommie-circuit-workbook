"""6-10 CW 用スーパーヘテロダインの算術。python3 -I 10-superhet.py

(1) ラダーフィルタ (6-9 の定数と L 型の整合) の裾 = 逆サイドの抑圧
(2) 周波数の計画 (局発・イメージ・方形波の高調波による応答)
(3) 入力の同調回路 (6-3 の式。結合係数 1、無負荷 Q 150、負荷 1.5 kΩ) がイメージをどれだけ落とすか
(4) 利得の配分

水晶の定数は 6-9 と同じ見積り (Cm 15 fF、Lm は fs 4.9152 MHz から、Rs 30 Ω、C0 4 pF)。実物の水晶では測り直す。
"""
import importlib
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
d = importlib.import_module('09_ladder_design')   # 6-9 の水晶の模型 (xtal・ser・sh)
FS = d.FS
CK = 220e-12          # 並列 3 個・両端の直列 2 個
LM, CP, RSA = 18e-6, 47e-12, 1500.0   # L 型の整合と SA612 の 1.5 kΩ
CIN = 3e-12           # SA612 の入力の容量


def chain(f, rl=0.0):
    """SA612 (1.5 kΩ) - 47 pF - 18 µH - フィルタ - 18 µH - 47 pF (+3 pF) - SA612 の S21。"""
    w = 2 * np.pi * f
    m = d.sh(1j * w * CP) @ d.ser(1j * w * LM + rl)
    for i in range(4):
        z = d.xtal(w)
        if i in (0, 3):
            z = z + 1 / (1j * w * CK)
        m = m @ d.ser(z)
        if i < 3:
            m = m @ d.sh(1j * w * CK)
    m = m @ d.ser(1j * w * LM + rl) @ d.sh(1j * w * (CP + CIN))
    a, b, c, dd = m.ravel()
    return 2 / (a + b / RSA + c * RSA + dd)


def db(x):
    return 20 * np.log10(abs(x))


f = np.arange(FS - 3000, FS + 5000, 1.0)
g = np.array([db(chain(x)) for x in f])
pk = g.max()
i3 = np.where(g >= pk - 3)[0]
f_lo, f_hi = f[i3[0]], f[i3[-1]]
f0 = (f_lo + f_hi) / 2
print("== (1) ラダーフィルタ + L 型の整合 ==")
print(f"損失 {-pk:.2f} dB  -3 dB {f_lo-FS:+.0f}..{f_hi-FS:+.0f} Hz (幅 {f_hi-f_lo:.0f} Hz)  中心 f0 = fs {f0-FS:+.0f} Hz = {f0/1e6:.6f} MHz")
ref = db(chain(f0))
for dx in (-2100, -1400, -700, -350, 0, 350, 700, 1400, 2100):
    print(f"  f0{dx:+5d} Hz: {db(chain(f0+dx))-ref:7.1f} dB (f0 を 0 dB)")
sup_hi = db(chain(f0 + 1400)) - ref
sup_lo = db(chain(f0 - 1400)) - ref
print(f"BFO = f0+700 Hz ({(f0+700)/1e6:.6f} MHz): 逆サイドは IF で f0+1400 Hz、{sup_hi:.1f} dB")
print(f"BFO = f0-700 Hz ({(f0-700)/1e6:.6f} MHz): 逆サイドは IF で f0-1400 Hz、{sup_lo:.1f} dB")

print("\n== (2) 周波数の計画 (IF = f0) ==")
for rx in (7.000e6, 7.010e6, 7.030e6, 7.200e6):
    lo_l, lo_h = rx - f0, rx + f0
    print(f"受信 {rx/1e6:.3f} MHz: 下側の局発 {lo_l/1e6:.6f} MHz (イメージ {(f0-lo_l)/1e6:.4f} MHz) / 上側の局発 {lo_h/1e6:.6f} MHz (イメージ {(lo_h+f0)/1e6:.4f} MHz)")
rx = 7.030e6
print("方形波の局発の n 倍による応答 (受信 7.030 MHz、n×LO±IF、混合の強さは 1/n):")
for name, lo in (("下側", rx - f0), ("上側", rx + f0)):
    for n in (3, 5, 7):
        print(f"  {name} n={n}: {abs(n*lo-f0)/1e6:8.3f} MHz と {(n*lo+f0)/1e6:8.3f} MHz ({20*np.log10(1/n):.1f} dB)")

print("\n== (3) 入力の同調回路 (6-3 の式) ==")
AL, N2, N1, QU, F0, Z0 = 4.0e-9, 32, 4, 150.0, 7.1e6, 50.0
L2 = AL * N2**2
CT = 1 / ((2 * np.pi * F0) ** 2 * L2)


def vhot(fx, rload=1500.0):
    n = N2 / N1
    w = 2 * np.pi * fx
    rp = QU * 2 * np.pi * F0 * L2
    y = 1 / (1j * w * L2) + 1j * w * CT + 1 / rp + 1 / rload
    z = 1 / y
    return n * z / (z + Z0 * n * n)


fs_ = np.arange(5e6, 9.5e6, 500.0)
gg = np.array([abs(vhot(x)) for x in fs_])
i3 = np.where(gg >= gg.max() / np.sqrt(2))[0]
bw = fs_[i3[-1]] - fs_[i3[0]]
print(f"L2 {L2*1e6:.3f} uH、C {CT*1e12:.1f} pF、山 {fs_[np.argmax(gg)]/1e6:.2f} MHz、-3 dB 幅 {bw/1e6:.2f} MHz (Q {F0/bw:.1f})、電圧の利得 {db(vhot(F0)):.1f} dB (アンテナの開放電圧比)")
gref = abs(vhot(rx))
rows = (("下側の局発のイメージ", f0 - (rx - f0)), ("上側の局発のイメージ", (rx + f0) + f0), ("IF そのもの", f0),
        ("下側 3 倍 (中波)", abs(3 * (rx - f0) - f0)), ("下側 5 倍", abs(5 * (rx - f0) - f0)), ("下側 3 倍 (和)", 3 * (rx - f0) + f0),
        ("下側 7 倍", abs(7 * (rx - f0) - f0)), ("上側 3 倍", 3 * (rx + f0) - f0))
for name, fx in rows:
    print(f"  {name:14s} {fx/1e6:7.3f} MHz: {db(vhot(fx))-20*np.log10(gref):6.1f} dB (7.03 MHz を 0 dB)")

print("\n== (4) 利得の配分 (見積り) ==")
g_mix, g_af = 17.0, 43.55
for name, loss in (("コイルの損失なし", 0.0), ("コイルの Q 80", 2 * np.pi * f0 * LM / 80)):
    gq = np.array([db(chain(x, rl=loss)) for x in f]).max()
    print(f"{name}: フィルタの損失 {-gq:.2f} dB → SA612 {g_mix:.0f} + フィルタ {gq:.1f} + SA612 {g_mix:.0f} + 音声段 {g_af:.2f} = {2*g_mix+gq+g_af:.1f} dB")
print(f"6-5 のダイレクトコンバージョン: SA612 {g_mix:.0f} + 音声段 {g_af:.2f} = {g_mix+g_af:.1f} dB")
# AD3 での試験: W1 20 mVp を 5.1 kΩ + 51 Ω (-40 dB) に通す
vin = 0.020 * 51 / (5100 + 51)
print(f"試験の入力: W1 20 mVp → 減衰器の出口 {vin*1e6:.0f} uVp (51 Ω の両端。源は約 50 Ω)")

print("\n== (5) Si5351 の設定 (水晶 25 MHz、分数の分母 1048575、出力の分周は偶数の整数) ==")
XTAL, CDEN = 25e6, 1048575
for name, fout, div in (("CLK0 (PLL A) 7.000 MHz 用", 7.000e6 - f0, 300), ("CLK0 (PLL A) 7.030 MHz 用", 7.030e6 - f0, 300),
                        ("CLK0 (PLL A) 7.200 MHz 用", 7.200e6 - f0, 300), ("CLK1 (PLL B) BFO", f0 + 700, 150)):
    vco = fout * div
    a = int(vco // XTAL)
    b = round((vco / XTAL - a) * CDEN)
    act = XTAL * (a + b / CDEN) / div
    print(f"{name}: {fout:.1f} Hz = VCO {vco/1e6:.4f} MHz ÷ {div}、a = {a}、b = {b}、実際 {act:.2f} Hz (刻み {XTAL/CDEN/div:.3f} Hz)")

print("\n== 図5 の点列 (IF の中心からのずれ Hz、dB) ==")
for dx in list(range(-2500, -800, 100)) + list(range(-800, 801, 50)) + list(range(900, 2501, 100)):
    print(f"    - {dx} {db(chain(f0+dx))-ref:.1f}")
