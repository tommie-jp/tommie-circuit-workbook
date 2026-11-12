"""6-3 入力の同調回路: 算術での確かめ (python3 -I 03-input-tuning.py)。

T1 = T37-2 (A_L 4.0 nH/回²)、2 次 32 回・リンク 4 回、C1 100 pF + トリマ、負荷は R1 1.5 kΩ + VNA の 50 Ω。
結合係数は 1、コイルの無負荷 Q は 150 (見積り) と置く。
"""
import cmath
import math

AL = 4.0e-9
N2, N1 = 32, 4
L2 = AL * N2**2
QU = 150.0
F0 = 7.1e6
Z0 = 50.0


def par(*zs):
    return 1 / sum(1 / z for z in zs)


def tank(f, c, rload, n1=N1, rs=Z0):
    """2 次側に換算した並列共振。返すのは (V_hot / Vs, 1 次から見た Z)。"""
    n = N2 / n1
    w = 2 * math.pi * f
    rp = QU * 2 * math.pi * F0 * L2
    z = par(1j * w * L2, 1 / (1j * w * c), rp, rload)
    rs2 = rs * n * n
    vhot = n * z / (z + rs2)
    return vhot, z / (n * n)


def s21_fixture(f, c, r1=1500.0):
    vhot, zin = tank(f, c, r1 + Z0)
    s21 = 2 * vhot * Z0 / (r1 + Z0)
    s11 = (zin - Z0) / (zin + Z0)
    return s21, s11


def db(x):
    return 20 * math.log10(abs(x))


w0 = 2 * math.pi * F0
ctot = 1 / (w0 * w0 * L2)
xl = w0 * L2
print(f"L2 = {L2*1e6:.3f} uH, XL = {xl:.1f} ohm, C(7.1 MHz) = {ctot*1e12:.2f} pF, Rp(Qu) = {QU*xl/1e3:.1f} kohm")

print("\n# リンクの巻数と Q (負荷 1.5 kΩ = SA612)")
for n1 in (3, 4, 6):
    n = N2 / n1
    r = par(Z0 * n * n, 1500.0, QU * xl)
    q = r / xl
    vhot, zin = tank(F0, ctot, 1500.0, n1)
    gain = 4 * Z0 * abs(vhot) ** 2 / 1500.0
    print(f"link {n1}: n={n:.2f} Rs'={Z0*n*n:.0f} R={r:.0f} Q={q:.2f} BW={F0/q/1e6:.2f} MHz "
          f"Zin={abs(zin):.1f} ohm loss={10*math.log10(gain):.2f} dB Vhot/Vs={abs(vhot):.2f} ({db(vhot):.1f} dB)")

print("\n# 治具 (R1 1.5 kΩ + 50 Ω)")
r = par(Z0 * 64, 1550.0, QU * xl)
print(f"R={r:.1f} Q={r/xl:.2f} BW={F0/(r/xl)/1e6:.3f} MHz")
print(f"1 次に換算: L={L2/64*1e9:.1f} nH C={ctot*64*1e9:.4f} nF rp={QU*xl/64:.1f} load={1550/64:.3f}")
b = Z0 / (8 * Z0 / 1550.0) - Z0
a = 1 / (64 / 1550.0 - 1 / (b + Z0))
print(f"dut: shunt R {a:.2f}, series R {b:.2f}; R1 の見かけの損失 = {10*math.log10(1550/50):.2f} dB")
peak = db(s21_fixture(F0, ctot)[0])
for f in (1e6, 3.5e6, 6.0e6, 6.48e6, 7.0e6, 7.1e6, 7.2e6, 7.45e6, 7.78e6, 14.2e6, 21.3e6, 30e6):
    s21, s11 = s21_fixture(f, ctot)
    swr = (1 + abs(s11)) / (1 - abs(s11))
    print(f"{f/1e6:6.2f} MHz S21 {db(s21):7.2f} dB (山から {db(s21)-peak:6.2f}) S11 {db(s11):6.2f} dB SWR {swr:5.2f}")
# -3 dB の幅
lo = hi = None
f = 5e6
while f < 9.5e6:
    d = db(s21_fixture(f, ctot)[0]) - peak
    if lo is None and d >= -3.0103:
        lo = f
    if lo is not None and hi is None and f > F0 and d < -3.0103:
        hi = f
    f += 500
print(f"-3 dB: {lo/1e6:.3f} .. {hi/1e6:.3f} MHz (幅 {(hi-lo)/1e6:.3f} MHz)")

print("\n# トリマの範囲 (C1 100 pF + TC1 + 浮遊)")
for ct, stray in ((6, 3), (20, 3), (50, 3), (6, 8), (50, 8)):
    c = (100 + ct + stray) * 1e-12
    print(f"TC1 {ct} pF 浮遊 {stray} pF: f0 = {1/(2*math.pi*math.sqrt(L2*c))/1e6:.3f} MHz")
print(f"合わせる TC1 (浮遊 3 pF) = {ctot*1e12-103:.1f} pF")

print("\n# AD3 の Scope (24 pF) を熱い側に直に挟むと")
print(f"f0 = {1/(2*math.pi*math.sqrt(L2*(ctot+24e-12)))/1e6:.3f} MHz")

print("\n# 巻線")
turn = 2 * (3.25 + (9.53 - 5.21) / 2) + 1.3
print(f"1 回 約 {turn:.1f} mm, 32 回 {32*turn/10:.0f} cm, 4 回 {4*turn/10:.1f} cm, 内周 {math.pi*5.21:.1f} mm に 36 回 x 0.33 = {36*0.33:.1f} mm")
