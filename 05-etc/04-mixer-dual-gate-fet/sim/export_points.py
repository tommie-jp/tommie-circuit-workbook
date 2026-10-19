"""main2.py (R2.pkl) と ac.py (Z.pkl) の結果を、graph フェンスの点列にして標準出力へ書く。"""
import pickle
import numpy as np

R = pickle.load(open('R2.pkl', 'rb'))
Z = pickle.load(open('Z.pkl', 'rb'))


def pts(xs, ys, fx, fy=lambda v: f"{v:.2f}"):
    return "\n".join(f"    - {fx(x)} {fy(y)}" for x, y in zip(xs, ys))


def k(v):
    return f"{v / 1e3:g}k"


def mhz(v):
    return f"{v / 1e6:g}M"


print("# 図1 変換利得 (LO 追従)")
for p in (0, 4, 7, 10):
    print(f"  LO {p:+d} dBm dB:")
    print(pts(R['rf'], R[f'trk{p}'], mhz))
print("# 図2 IF の通過特性")
print(pts(455e3 + R['d'], R['main'], k, lambda v: f"{v:.1f}"))
print("# 図3 LO 電力")
print(pts(R['plo'], R['cg_plo'], lambda v: f"{v:g}"))
print("# 図4 G2 の電圧")
print(pts(sorted(set(R['vg2'])), [R['cg_vg2'][list(R['vg2']).index(v)] for v in sorted(set(R['vg2']))], lambda v: f"{v:g}"))
f, z = Z['out']
m = [i for i in range(len(f)) if 440e3 <= f[i] <= 470e3 and abs((f[i] / 1e3) % 1) < 1e-6]
G = (z - 50) / (z + 50)
print("# 図5 IF OUT のインピーダンス (R, X, リターンロス)")
print(pts(f[m], z[m].real, k, lambda v: f"{v:.1f}"))
print(pts(f[m], z[m].imag, k, lambda v: f"{v:.1f}"))
print(pts(f[m], -20 * np.log10(abs(G[m])), k, lambda v: f"{v:.1f}"))
print("# 図6 入出力特性")
print(pts(R['prf'], R['pout'], lambda v: f"{v:g}", lambda v: f"{v:.1f}"))
