"""6-2 最初のアンテナ: 5 m のワイヤの等価回路と tinySA の読みの見積り (算術)。

python3 -I 05-etc/06-ham-receiver/sim/02-wire-antenna.py
"""
import math

C0 = 299_792_458.0
F = 7.1e6            # Hz
H = 5.0              # m。ワイヤの長さ
A = 0.25e-3          # m。線の半径 (直径 0.5 mm)
RL = 50.0            # Ω。tinySA の入力
C_RET = 20e-12       # F。カウンターポイズ無しのときの帰り道 (計器の筐体と周りの容量、仮定)
RBW = 3e3            # Hz

lam = C0 / F
beta_h = 2 * math.pi * H / lam
z0 = 60 * (math.log(2 * H / A) - 1)                 # 単線モノポールの平均特性インピーダンス
x_ant = -z0 / math.tan(beta_h)                      # 入力リアクタンス
c_eq = -1 / (2 * math.pi * F * x_ant)
r_rad = 40 * math.pi ** 2 * (H / lam) ** 2          # 短いモノポールの放射抵抗
h_eff = H / 2                                       # 短いモノポールの実効高

def dbm(p_w):
    return 10 * math.log10(p_w / 1e-3)

def divider(x_total):
    """起電力 → 50 Ω の両端の比 (電圧)。"""
    return RL / math.hypot(RL + r_rad, x_total)

k_cp = divider(x_ant)
x_ret = -1 / (2 * math.pi * F * C_RET)
k_nocp = divider(x_ant + x_ret)

print(f"波長 {lam:.2f} m、λ/4 {lam / 4:.2f} m、βh {math.degrees(beta_h):.1f}°")
print(f"Z0 {z0:.0f} Ω、X {x_ant:.0f} Ω、等価 C {c_eq * 1e12:.1f} pF、放射抵抗 {r_rad:.2f} Ω、実効高 {h_eff:.1f} m")
print(f"分圧 (カウンターポイズ有り) {k_cp:.4f} = {20 * math.log10(k_cp):.1f} dB")
print(f"帰り道 20 pF の X {x_ret:.0f} Ω、分圧 (無し) {k_nocp:.4f} = {20 * math.log10(k_nocp):.1f} dB、差 {20 * math.log10(k_nocp / k_cp):.1f} dB")

p_avail_ratio = (k_cp ** 2 / RL) / (1 / (4 * r_rad))
print(f"整合したときに比べた損 {10 * math.log10(p_avail_ratio):.1f} dB")

for e_dbuv in (60, 50, 40):
    e = 10 ** (e_dbuv / 20) * 1e-6                  # V/m
    emf = e * h_eff
    v = emf * k_cp
    print(f"電界 {e_dbuv} dBµV/m: 起電力 {emf * 1e6:.0f} µV、50 Ω の両端 {v * 1e6:.1f} µV、{dbm(v * v / RL):.1f} dBm")

# 外来雑音 (ITU-R P.372 の人工雑音の中央値 Fa = c - d log10 f[MHz])
for name, c, d in (("city", 76.8, 27.7), ("residential", 72.5, 27.7), ("rural", 67.2, 27.7)):
    fa = c - d * math.log10(F / 1e6)
    n_avail = -174 + fa + 10 * math.log10(RBW)
    n_in = n_avail + 10 * math.log10(p_avail_ratio)
    print(f"{name}: Fa {fa:.1f} dB、RBW 3 kHz の有能雑音 {n_avail:.1f} dBm、tinySA の入力で {n_in:.1f} dBm")

floor = -102 + 10 * math.log10(RBW / 30e3)
print(f"tinySA Ultra の床 (RBW 3 kHz) LNA 切 {floor:.1f} dBm、LNA 入 16 dB で {floor - 16:.1f} dBm、20 dB で {floor - 20:.1f} dBm")
