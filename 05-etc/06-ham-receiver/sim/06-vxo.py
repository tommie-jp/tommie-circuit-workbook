"""6-6 VXO: 水晶 + 直列の L1 + VC1 + コルピッツの C で、発振周波数 (リアクタンスの和が 0 になる周波数) を算術で求める。

水晶の等価回路は 7 MHz の HC-49/U の典型の見積り (実物の測定値ではない)。
  python3 06-vxo.py          表を出す
"""
import math

CM, C0, RS = 20e-15, 5e-12, 20.0          # モーショナル容量・電極の容量・直列抵抗 (見積り)
F_NOM, CL_NOM = 7.030e6, 20e-12           # 刻印の周波数と、その負荷容量 (見積り)
FS = F_NOM / (1 + CM / (2 * (C0 + CL_NOM)))          # 直列共振
LM = 1 / ((2 * math.pi * FS) ** 2 * CM)
CA = CB = 100e-12                          # コルピッツの 2 本
CSTRAY = 10e-12                            # VC1 と並列の浮遊容量 (見積り)


def series(*cs):
    return 1 / sum(1 / c for c in cs)


def x_xtal(f):
    """水晶の端子間のリアクタンス (Rs は無視)。"""
    w = 2 * math.pi * f
    xm = w * LM - 1 / (w * CM)
    xc0 = -1 / (w * C0)
    return xm * xc0 / (xm + xc0)


def x_load(f, l1, vc):
    w = 2 * math.pi * f
    return w * l1 - 1 / (w * series(vc + CSTRAY, CA, CB))


def f_osc(l1, vc):
    """fs の近くで x_xtal + x_load = 0 になる周波数 (2 分法)。反共振 fp より下の枝だけを見る。"""
    fp = FS * math.sqrt(1 + CM / C0)
    lo, hi = FS - 60e3, fp - 1.0
    g = lambda f: x_xtal(f) + x_load(f, l1, vc)
    if g(lo) * g(hi) > 0:
        return float('nan')
    for _ in range(200):
        mid = (lo + hi) / 2
        if g(lo) * g(mid) <= 0:
            hi = mid
        else:
            lo = mid
    return (lo + hi) / 2


def f_approx(l1, vc):
    """本文の式: Δf = fs·Cm / (2·(C0 + CLeff))、CLeff = 1 / (ω·(1/(ωCL) − ωL))。"""
    w = 2 * math.pi * FS
    cl = series(vc + CSTRAY, CA, CB)
    x = 1 / (w * cl) - w * l1
    cleff = 1 / (w * x)
    return FS * (1 + CM / (2 * (C0 + cleff)))


if __name__ == '__main__':
    print(f'fs = {FS:.1f} Hz, Lm = {LM*1e3:.3f} mH, fp = {FS*math.sqrt(1+CM/C0):.1f} Hz, Q = {2*math.pi*FS*LM/RS:.0f}')
    for l1 in (0, 10e-6, 22e-6, 33e-6, 39e-6, 47e-6, 56e-6):
        row = []
        for vc in (10e-12, 20e-12, 50e-12, 100e-12, 150e-12, 200e-12, 260e-12):
            row.append(f'{f_osc(l1, vc)/1e6:.5f}')
        fa, fb = f_osc(l1, 10e-12), f_osc(l1, 260e-12)
        print(f'L1 = {l1*1e6:4.0f} uH: ' + ' '.join(row) + f'  幅 {abs(fa-fb):.0f} Hz')
    print('近似式との差 (L1 = 33 uH):')
    for vc in (10e-12, 50e-12, 100e-12, 260e-12):
        print(f'  VC {vc*1e12:.0f} pF: 厳密 {f_osc(33e-6, vc):.0f}  近似 {f_approx(33e-6, vc):.0f}')


def sensitivity():
    """L1 が 1 % 増えたとき・VC1 と並列の浮遊が 1 pF 増えたときに動く Hz (VC1 = 260 pF と 10 pF)。"""
    global CSTRAY
    for l1 in (22e-6, 47e-6, 56e-6, 68e-6):
        out = []
        for vc in (10e-12, 260e-12):
            f0 = f_osc(l1, vc)
            dl = f_osc(l1 * 1.01, vc) - f0
            keep = CSTRAY
            CSTRAY = keep + 1e-12
            dc = f_osc(l1, vc) - f0
            CSTRAY = keep
            out.append(f'VC {vc*1e12:3.0f} pF: f {f0:.0f}  L+1% {dl:+.0f} Hz  C+1pF {dc:+.0f} Hz')
        print(f'L1 = {l1*1e6:.0f} uH | ' + ' | '.join(out))


def cm_spread():
    """水晶の Cm が違うとき (低背の HC-49/S は小さい) の可変幅。fs は刻印 7.030 MHz・負荷 20 pF から決め直す。"""
    global CM, FS, LM
    keep = (CM, FS, LM)
    for cm in (10e-15, 15e-15, 20e-15, 25e-15):
        CM = cm
        FS = F_NOM / (1 + CM / (2 * (C0 + CL_NOM)))
        LM = 1 / ((2 * math.pi * FS) ** 2 * CM)
        a, b = f_osc(47e-6, 10e-12), f_osc(47e-6, 260e-12)
        print(f'Cm = {cm*1e15:.0f} fF: {b:.0f} .. {a:.0f} Hz  幅 {a-b:.0f} Hz')
    CM, FS, LM = keep


if __name__ == '__main__':
    print('感度:')
    sensitivity()
    print('Cm の違い (L1 = 47 uH):')
    cm_spread()
    w = 2 * math.pi * 7.022e6
    for ie in (0.12e-3, 0.25e-3):
        gm = ie / 0.02585
        print(f'Ie = {ie*1e3:.2f} mA: gm = {gm*1e3:.1f} mS, 負性抵抗 = {gm/(w*w*CA*CB):.0f} ohm')
    print(f'L1 47 uH の X = {w*47e-6:.0f} ohm, Q 80 なら直列抵抗 {w*47e-6/80:.0f} ohm')
