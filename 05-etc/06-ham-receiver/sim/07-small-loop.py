"""6-7 同調式のスモールループ — 算術での確かめ (SPICE は使わない)。

python3 05-etc/06-ham-receiver/sim/07-small-loop.py

主ループ (直径 60 cm・φ2 mm の銅線 1 回) の L・同調容量・損失・Q・帯域と、
結合ループ (直径 16 cm) との相互インダクタンス M (Neumann の式の数値積分)、
結合ループから見たインピーダンスと SWR を出す。
"""
import cmath
import math

MU0 = 4e-7 * math.pi
RHO_CU = 1.68e-8          # 銅の抵抗率 (Ω·m)
C_LIGHT = 299_792_458.0

D_MAIN = 0.60             # 主ループの直径 (m)
D_COUPLE = 0.16           # 結合ループの直径 (m)
WIRE = 0.002              # 線の直径 (m)
GAP = 0.005               # 2 つの輪の線の中心どうしの間隔 (m)
Q_VC = 400.0              # ポリバリコンと固定コンデンサを合わせた Q (見積り)
F0 = 7.1e6


def loop_inductance(diameter, wire):
    radius, a = diameter / 2, wire / 2
    return MU0 * radius * (math.log(8 * radius / a) - 2)


def mutual(r1, r2, offset, n=1500):
    """同じ平面にある 2 つの円 (中心の間隔 offset) の M。Neumann の式。"""
    total = 0.0
    d1 = 2 * math.pi / n
    for i in range(n):
        t1 = (i + 0.5) * d1
        x1, y1 = r1 * math.cos(t1), r1 * math.sin(t1)
        tx1, ty1 = -math.sin(t1), math.cos(t1)
        for j in range(n):
            t2 = (j + 0.5) * d1
            x2, y2 = offset + r2 * math.cos(t2), r2 * math.sin(t2)
            dot = tx1 * -math.sin(t2) + ty1 * math.cos(t2)
            total += dot / math.hypot(x1 - x2, y1 - y2)
    return MU0 / (4 * math.pi) * total * r1 * r2 * d1 * d1


def skin_resistance(length, wire, f):
    delta = math.sqrt(RHO_CU / (math.pi * f * MU0))
    return RHO_CU * length / (math.pi * wire * delta), delta


def main():
    w0 = 2 * math.pi * F0
    l1 = loop_inductance(D_MAIN, WIRE)
    l2 = loop_inductance(D_COUPLE, WIRE)
    print(f"L1 (主ループ) = {l1 * 1e6:.3f} µH, L2 (結合ループ) = {l2 * 1e6:.3f} µH")
    for f in (7.0e6, 7.1e6, 7.2e6, 7.45e6):
        c = 1 / ((2 * math.pi * f) ** 2 * l1)
        print(f"  {f / 1e6:.2f} MHz に合わせる C = {c * 1e12:.1f} pF")

    # 同調のコンデンサ: C1 180 pF ∥ (VC1 20〜260 pF と C2 100 pF の直列) + 浮遊 5 pF
    for vc in (20e-12, 260e-12):
        c = 180e-12 + vc * 100e-12 / (vc + 100e-12) + 5e-12
        print(f"  VC1 = {vc * 1e12:.0f} pF → 合計 {c * 1e12:.1f} pF → {1 / (2 * math.pi * math.sqrt(l1 * c)) / 1e6:.2f} MHz")

    lam = C_LIGHT / F0
    circ = math.pi * D_MAIN
    area = math.pi * (D_MAIN / 2) ** 2
    r_rad = 31171 * (area / lam ** 2) ** 2
    r_wire, delta = skin_resistance(circ, WIRE, F0)
    x_l = w0 * l1
    r_cap = x_l / Q_VC
    r_loss = r_wire + r_cap
    r_total = r_loss + r_rad
    q_u = x_l / r_total
    print(f"波長 {lam:.2f} m, 周の長さ {circ:.3f} m = {circ / lam:.3f} λ, 面積 {area:.4f} m²")
    print(f"表皮の深さ {delta * 1e6:.1f} µm, 線の抵抗 {r_wire:.3f} Ω, コンデンサの損失 {r_cap:.3f} Ω, 放射抵抗 {r_rad * 1e3:.2f} mΩ")
    print(f"X_L = {x_l:.2f} Ω, 合計 R = {r_total:.3f} Ω, 無負荷 Q = {q_u:.0f}, 帯域 {F0 / q_u / 1e3:.1f} kHz")
    print(f"整合したときの負荷 Q = {q_u / 2:.0f}, 帯域 {F0 / (q_u / 2) / 1e3:.1f} kHz")
    eff = r_rad / r_total
    print(f"効率 {eff * 100:.3f} % = {10 * math.log10(eff):.1f} dB")
    fa = 72.5 - 27.7 * math.log10(F0 / 1e6)
    print(f"人工雑音 (住宅地、ITU-R P.372) Fa = {fa:.1f} dB")

    m_need = math.sqrt(50 * r_total) / w0
    offset = D_MAIN / 2 - D_COUPLE / 2 - GAP
    m = mutual(D_MAIN / 2, D_COUPLE / 2, offset)
    m_center = mutual(D_MAIN / 2, D_COUPLE / 2, 0.0)
    k = m / math.sqrt(l1 * l2)
    print(f"50 Ω に要る M = {m_need * 1e9:.1f} nH")
    print(f"M (内側に寄せ、線の間隔 {GAP * 1e3:.0f} mm) = {m * 1e9:.1f} nH (k = {k:.3f}), 中心に置くと {m_center * 1e9:.1f} nH")
    print(f"共振での実部 (ωM)²/R = {(w0 * m) ** 2 / r_total:.1f} Ω")
    print(f"vna の模型: series L {(l2 - m) * 1e9:.0f}n / shunt L {m * 1e9:.0f}n / shunt C esr {r_total:.2f} esl {(l1 - m) * 1e9:.0f}n")

    c_tune = 1 / (w0 ** 2 * l1)

    def swr_at(f, c):
        w = 2 * math.pi * f
        z2 = r_total + 1j * (w * l1 - 1 / (w * c))
        zin = 1j * w * l2 + (w * m) ** 2 / z2
        gamma = (zin - 50) / (zin + 50)
        return zin, (1 + abs(gamma)) / (1 - abs(gamma))

    print(f"C = {c_tune * 1e12:.2f} pF のとき:")
    best = min(((swr_at(F0 + d, c_tune)[1], F0 + d) for d in range(-150_000, 150_001, 500)))
    zin, _ = swr_at(best[1], c_tune)
    print(f"  SWR の底 {best[0]:.2f} @ {best[1] / 1e6:.4f} MHz, Zin = {zin.real:.1f} {zin.imag:+.1f}j Ω")
    lo = hi = None
    for d in range(-150_000, 150_001, 100):
        if swr_at(F0 + d, c_tune)[1] <= 2.0:
            lo = lo if lo is not None else F0 + d
            hi = F0 + d
    if lo:
        print(f"  SWR ≤ 2 の幅 {lo / 1e6:.4f}〜{hi / 1e6:.4f} MHz = {(hi - lo) / 1e3:.1f} kHz")
    lo = hi = None
    for d in range(-150_000, 150_001, 100):
        if swr_at(F0 + d, c_tune)[1] <= 3 + 2 * math.sqrt(2):   # |Γ|² ≤ 0.5 (受ける電力が半分)
            lo = lo if lo is not None else F0 + d
            hi = F0 + d
    print(f"  受ける電力が半分 (−3 dB) になる幅 {lo / 1e6:.4f}〜{hi / 1e6:.4f} MHz = {(hi - lo) / 1e3:.1f} kHz")
    dc = 2 * c_tune * (hi - lo) / F0
    print(f"  その幅を動かす C の変化 {dc * 1e12:.1f} pF")
    for f in (7.0e6, 7.05e6, F0, 7.15e6, 7.2e6):
        zin, s = swr_at(f, c_tune)
        print(f"  {f / 1e6:.3f} MHz: Zin = {zin.real:6.1f} {zin.imag:+7.1f}j Ω, SWR {s:.2f}")

    # 目安の 1/5 (12 cm) だとどうなるか
    m5 = mutual(D_MAIN / 2, 0.06, D_MAIN / 2 - 0.06 - GAP)
    r5 = (w0 * m5) ** 2 / r_total
    z5 = r5 + 1j * w0 * loop_inductance(0.12, WIRE)
    g5 = abs((z5 - 50) / (z5 + 50))
    print(f"直径 12 cm (1/5) の結合ループ: M = {m5 * 1e9:.1f} nH, 共振で {z5.real:.1f} {z5.imag:+.1f}j Ω, SWR {(1 + g5) / (1 - g5):.2f}, 不整合の損失 {10 * math.log10(1 - g5 * g5):.2f} dB")

    # 電界 50 dBµV/m (316 µV/m。6-2 と同じ仮定) の放送を 7.26 MHz で受けたときの電力 (整合・偏波が合ったとして)
    f_bc = 7.26e6
    lam_bc = C_LIGHT / f_bc
    p_iso = (10 ** (50 / 20) * 1e-6) ** 2 / (120 * math.pi) * lam_bc ** 2 / (4 * math.pi)
    p_loop = p_iso * 1.5 * eff
    print(f"50 dBµV/m: 損失の無い等方性アンテナ {10 * math.log10(p_iso * 1e3):.1f} dBm, このループ (指向性 1.5 × 効率) {10 * math.log10(p_loop * 1e3):.1f} dBm")
    print(f"外来雑音が受信機の雑音を上回る条件: 受信機の NF < {fa + 10 * math.log10(eff):.1f} dB")
    # 参考: 送信に使ったとき (5 W) のコンデンサの電圧
    print(f"5 W を入れたときのコンデンサの電圧 {math.sqrt(5 * (q_u / 2) * x_l):.0f} V (実効値)")

    # ヌルの深さ: 軸から θ だけずれたときの感度 sin θ
    for deg in (1, 3, 6, 10, 18, 30, 90):
        print(f"  軸から {deg:2d}° → {20 * math.log10(math.sin(math.radians(deg))):6.1f} dB")


if __name__ == "__main__":
    main()
