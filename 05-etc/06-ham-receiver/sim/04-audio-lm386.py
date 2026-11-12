"""6-4 音声段の算術での突き合わせ (LTspice の 04-audio-lm386.cir と同じ模型を節点方程式で解く)。
LM386 は振る舞いの模型 (入力 50 kΩ × 2、差動利得 200、30 kHz の 1 極、出力抵抗 0.2 Ω)。実測ではない。"""
import numpy as np

def gain(f, cc=10e-9, rl=33.0, c1=47e-9):
    s = 2j * np.pi * f
    r3, r1, r2, rin = 150e3, 1.5e3, 1.5e3, 50e3
    yc1, ycc = s * c1, s * cc
    # 未知数: a, b, p, m (W1 = 1 V)
    A = np.array([
        [1/r3 + 1/r1 + yc1 + ycc, -yc1, -ycc, 0],
        [-yc1, 1/r2 + yc1 + ycc, 0, -ycc],
        [-ycc, 0, ycc + 1/rin, 0],
        [0, -ycc, 0, ycc + 1/rin],
    ], dtype=complex)
    a, b, p, m = np.linalg.solve(A, np.array([1/r3, 0, 0, 0], dtype=complex))
    e = 200 * (p - m) / (1 + s / (2 * np.pi * 30e3))
    zl = 1 / (s * 220e-6) + rl            # 出力のコンデンサと負荷
    zz = 10 + 1 / (s * 47e-9)             # Zobel
    zp = zl * zz / (zl + zz)
    out = e * zp / (0.2 + zp)
    return out * rl / zl, a - b, p - m

def band(**kw):
    f = np.logspace(1, 5, 40001)
    g = np.abs(np.array([gain(x, **kw)[0] for x in f]))
    k = g.argmax()
    lo = f[:k][g[:k] < g[k] / np.sqrt(2)][-1]
    hi = f[k:][g[k:] < g[k] / np.sqrt(2)][0]
    return f[k], g[k], lo, hi

for cc in (10e-9, 100e-9):
    for rl in (33.0, 8.2):
        fp, gp, lo, hi = band(cc=cc, rl=rl)
        o, ab, pm = gain(700, cc=cc, rl=rl)
        row = [abs(gain(x, cc=cc, rl=rl)[0]) for x in (50, 100, 300, 3000)]
        print(f"Cc={cc*1e9:.0f}n RL={rl}: peak {gp:.4f} ({20*np.log10(gp*101):.2f} dB at pins) @ {fp:.0f} Hz, "
              f"-3dB {lo:.0f}..{hi:.0f} Hz, 700Hz {abs(o):.4f} ({20*np.log10(abs(o)*101):.2f} dB) "
              f"phase {np.degrees(np.angle(o)):.1f} deg, 50/100/300/3k = "
              + "/".join(f"{20*np.log10(x/gp):.1f}" for x in row) + " dB re peak")
o, ab, pm = gain(700)
print("700 Hz: |A-B| per 1 V =", abs(ab), " |p-m| =", abs(pm), " thevenin =", 1.5/151.5)
print("f_lp = 1/(2pi (R1//R3 + R2) C1) =", 1/(2*np.pi*(1.5e3*150e3/151.5e3+1.5e3)*47e-9))
print("f_hp = 1/(2pi 50k 10n) =", 1/(2*np.pi*50e3*10e-9), " 100n:", 1/(2*np.pi*50e3*100e-9))
print("f_out 220u: 33 ohm", 1/(2*np.pi*33.2*220e-6), " 8.2 ohm", 1/(2*np.pi*8.4*220e-6))
