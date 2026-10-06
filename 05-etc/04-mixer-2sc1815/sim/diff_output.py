"""4-2 の差動対の出力を、トランスを使わずに 1 本 (単端) にする方法を比べる。
どの方法も同じ出力回路 (セラミックフィルタ相当・L 型整合・50 Ω の負荷) につなぎ、
変換利得 (50 Ω の負荷の電力 ÷ RF の有能電力)・RF の打ち消し・電源の電流を出す。
信号源は 0 Ω (Wavegen と同じ)。使い方: python3 diff_output.py (結果は diff_output.json)。"""
import subprocess, os, re, json, hashlib, numpy as np
from concurrent.futures import ThreadPoolExecutor
import sys; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from compare_gain import Q, FILTER, vs_open, amp, WORK

HERE = os.path.dirname(os.path.abspath(__file__))
# 2SA1015 の代用モデル (hFE≈200・fT≈80 MHz・Cob≈4 pF の目安から作った仮定。実測の値ではない)
QP = ".model Q1015 PNP (IS=2e-14 BF=200 NF=1 VAF=50 IKF=0.15 RB=30 RE=1 RC=5 CJE=8p CJC=4p TF=2n TR=50n)"
TANK_GND = "Ct d t1 100n\nLt t1 0 220u\nRLt t1 0 1G\nCtk t1 0 560p\n"   # 455 kHz の並列同調を C で DC を切って GND へ

def core(o):
    """差動対の下半分 (Q3 の電流源・Q1/Q2・バイアス) は元の 4-2 と同じ。re_split: RE をバイパスしない側の抵抗 (None なら 470 Ω 1 本)、re_b: バイパスする側"""
    re3 = "RE3 e3 0 470" if not o.get("re_split") else f"RE3a e3 e3b {o['re_split']}\nRE3b e3b 0 {o.get('re_b', 470 - o['re_split'])}\nCE e3b 0 1u"
    return f"""{Q}
{QP}
VDD vdd 0 5
C6 vdd 0 100n
C7 vdd 0 10u
RB1 vdd b3 82k
RB2 b3 0 22k
{re3}
C1 rf b3 10n
R1 rf 0 51
Q3 t b3 e3 Q1815
RL1 vdd b1 10k
RL2 b1 0 10k
RR1 vdd b2 10k
RR2 b2 0 10k
C9 b2 0 100n
C2 lo b1 10n
R3 lo 0 51
"""

def output(m, o):
    """m: 出力の取り出し方。どれも fin から先 (R7・フィルタ・50 Ω) は同じ。出力の前のノードは d"""
    chain = ("R7 fin 0 2k\n" if o.get("r7", True) else "") + FILTER + "Rload out 0 50\nRleak fin 0 1G\n"
    if m == "open":       # 元の 4-2: 3.3 kΩ ずつ、差を見る (フィルタ無し)
        return "Q1 c1 b1 t Q1815\nQ2 c2 b2 t Q1815\nRC1 vdd c1 3.3k\nRC2 vdd c2 3.3k\n", False
    if m == "se_tank":    # 片側のコレクタに 1 石と同じ同調回路 (もう片側は 3.3 kΩ)
        return ("Q1 c1 b1 t Q1815\nQ2 d b2 t Q1815\nRC1 vdd c1 3.3k\n"
                "L1 vdd d1 220u\nRLt d1 d 5\nC3 vdd d 560p\nC4 d fin 10n\n" + chain), True
    if m == "rc15":       # 片側のコレクタを 1.5 kΩ にし、フィルタ (1.5 kΩ) へ直に (R7 無し)
        return ("Q1 c1 b1 t Q1815\nQ2 d b2 t Q1815\nRC1 vdd c1 1.5k\nRC2 vdd d 1.5k\nC4 d fin 10n\n"
                + FILTER + "Rload out 0 50\nRleak fin 0 1G\n"), True
    if m == "sc":         # 変換コンダクタンス用: カレントミラーの出力を 3.2 V の電圧源 (0 V の電流計を通す) で短絡
        return ("Q1 c1 b1 t Q1815\nQ2 d b2 t Q1815\n"
                "RM1 vdd m1 220\nRM2 vdd m2 220\nQ4 c1 c1 m1 Q1015\nQ5 d c1 m2 Q1015\n"
                "Vm d db 0\nVb db 0 3.2\n"), "sc"
    if m in ("mirror", "mirror_tank"):   # PNP のカレントミラー (2SA1015 × 2、エミッタに 220 Ω) を能動負荷に
        s = ("Q1 c1 b1 t Q1815\nQ2 d b2 t Q1815\n"
             "RM1 vdd m1 220\nRM2 vdd m2 220\nQ4 c1 c1 m1 Q1015\nQ5 d c1 m2 Q1015\n"
             f"RBT vdd d {o.get('rbt', '15k')}\nRBB d 0 {o.get('rbb', '27k')}\nC4 d fin 10n\n")
        if m == "mirror_tank": s += TANK_GND
        return s + chain, True
    if m == "da":         # 両コレクタ (3.3 kΩ) をもう 1 段の差動対 (Q4・Q5、尾 2.2 kΩ) で受け、Q5 のコレクタ 1.5 kΩ からフィルタへ
        return ("Q1 c1 b1 t Q1815\nQ2 c2 b2 t Q1815\nRC1 vdd c1 3.3k\nRC2 vdd c2 3.3k\n"
                "Q4 vdd c1 t2 Q1815\nQ5 d c2 t2 Q1815\nRT2 t2 0 2.2k\nRC5 vdd d 1.5k\nC4 d fin 10n\n"
                + FILTER + "Rload out 0 50\nRleak fin 0 1G\n"), True
    raise ValueError(m)

DEF = dict(plo=0, prf=-30, frf=1.0e6, flo=1.455e6)
def run(m, **kw):
    o = {**DEF, **kw}
    tag = "do_" + hashlib.md5(json.dumps([m, o], sort_keys=True).encode()).hexdigest()[:10]
    out, has_out = output(m, o)
    k = 0 if o.get("nosig") else 1
    lo50 = o.get("src_lo") == "50"
    src = (f"Vlo los 0 SIN(0 {k * vs_open(o['plo']) / (1 if lo50 else 2)} {o['flo']})\nRlo los lo {50 if lo50 else '1m'}\n"
           f"Vrf rfs 0 SIN(0 {k * vs_open(o['prf'])/2} {o['frf']})\nRrf rfs rf 1m\n")
    nodes = {True: "v(out) v(d)", False: "v(c1) v(c2)", "sc": "i(Vm) v(c1)"}[has_out]
    net = (f"* diff output {m}\n.options reltol=1e-4 abstol=1e-10 vntol=1e-7 gmin=1e-12\n" + core(o) + out + src +
           f".control\ntran 25n 1.4m 0 25n\nwrdata {tag}.dat {nodes}\nmeas tran idd avg i(VDD) from=0.4m to=1.4m\n"
           "op\nprint v(d) v(c1) v(c2) v(t) v(b1) v(b2) v(b3) v(e3) v(m1) i(VDD)\n.endc\n.end\n")
    os.makedirs(WORK, exist_ok=True)
    open(f"{WORK}/{tag}.cir", "w").write(net)
    r = subprocess.run(["docker", "run", "--rm", "-v", f"{WORK}:/w", "-w", "/w", "ngspice-py", "ngspice", "-b", f"{tag}.cir"],
                       capture_output=True, text=True, timeout=1800)
    d = np.loadtxt(f"{WORK}/{tag}.dat")
    t = d[:, 0]
    fif, frf, flo = o["flo"] - o["frf"], o["frf"], o["flo"]
    vport = vs_open(o["prf"]) / 2; pav = vport ** 2 / 100
    res = dict(idd_mA=-float(re.search(r"idd\s*=\s*([-+0-9.e]+)", r.stdout).group(1)) * 1e3)
    dc = dict(re.findall(r"^([vi]\(\w+\))\s*=\s*([-+0-9.e]+)", r.stdout, re.M))
    res["dc"] = {k: float(v) for k, v in dc.items()}
    if has_out == "sc":
        res["gc_mS"] = amp(t, d[:, 1], fif) / vport * 1e3
        return res
    if has_out:
        vo, vd = d[:, 1], d[:, 3]
        a = amp(t, vo, fif)
        res["g"] = 10 * np.log10((a ** 2 / 100) / pav)
        res["node_if_mV"] = amp(t, vd, fif) * 1e3
        res["node_rf_mV"] = amp(t, vd, frf) * 1e3
        res["node_lo_mV"] = amp(t, vd, flo) * 1e3
        res["node_rf_vs_if_dB"] = 20 * np.log10(amp(t, vd, frf) / amp(t, vd, fif))
        res["node_lo_vs_if_dB"] = 20 * np.log10(amp(t, vd, flo) / amp(t, vd, fif))
        freqs = dict(if_=fif, rf=frf, lo=flo, sum=flo + frf, lo2=2 * flo)
        res["out_mV"] = {k: amp(t, vo, f) * 1e3 for k, f in freqs.items()}
        res["node_mV"] = {k: amp(t, vd, f) * 1e3 for k, f in freqs.items()}
        res["node_min_max"] = [float(vd[t > 0.4e-3].min()), float(vd[t > 0.4e-3].max())]
    else:
        v = d[:, 1] - d[:, 3]
        res["gv_diff"] = 20 * np.log10(amp(t, v, fif) / vport)
        res["node_rf_vs_if_dB"] = 20 * np.log10(amp(t, v, frf) / amp(t, v, fif))
        res["node_lo_vs_if_dB"] = 20 * np.log10(amp(t, v, flo) / amp(t, v, fif))
    return res

NEW = dict(re_split=47, re_b=430)   # 選んだ方法: カレントミラー + 同調回路 + RE を 47 Ω と 430 Ω (1 µF でバイパス) に分ける

if __name__ == "__main__":
    jobs = {}
    def add(n, m, **kw): jobs[n] = (m, kw)
    # 1 取り出し方の比べ (RE は元の 470 Ω のまま)
    for m in ("open", "se_tank", "rc15", "mirror", "mirror_tank", "da"):
        for plo in (-10, 0, 7):
            add(f"{m}_lo{plo}", m, plo=plo)
        for prf in (-40, -20, -15, -10, -5, 0):
            add(f"{m}_prf{prf}", m, prf=prf)
    # 2 RE の一部をバイパスしたとき (出力はカレントミラー + 同調回路、と片側 + 同調回路)
    for rs in (100, 47, 22):
        for m in ("mirror_tank", "se_tank"):
            for prf in (-40, -30, -20, -15, -10, -5, 0, 5):
                add(f"{m}_re{rs}_prf{prf}", m, re_split=rs, prf=prf)
    # 3 選んだ回路 (NEW) の特性: LO・RF 周波数・RF 電力・R7・LO の源 50 Ω・Gc・動作点
    for plo in (-20, -15, -10, -5, 0, 4, 7, 10, 13, 16):
        add(f"new_lo{plo}", "mirror_tank", plo=plo, **NEW)
        add(f"new_lo50_lo{plo}", "mirror_tank", plo=plo, src_lo="50", **NEW)
        add(f"new_sc_lo{plo}", "sc", plo=plo, **NEW)
    for x in (0.53, 0.6, 0.8, 1.0, 1.2, 1.4, 1.6):
        add(f"new_f{x}", "mirror_tank", frf=x * 1e6, flo=x * 1e6 + 455e3, **NEW)
    for prf in (-40, -30, -20, -15, -10, -7, -5, 0, 5):
        add(f"new_prf{prf}", "mirror_tank", prf=prf, **NEW)
    for plo in (0, 7, 13):
        add(f"new_r7none_lo{plo}", "mirror_tank", plo=plo, r7=False, **NEW)
    add("new_nosig", "mirror_tank", nosig=True, **NEW)
    add("new_prf-20", "mirror_tank", prf=-20, **NEW)
    def go(item):
        n, (m, kw) = item
        r = run(m, **kw)
        print(n, {k: (round(v, 2) if isinstance(v, float) else v) for k, v in r.items() if k not in ("dc", "out_mV", "node_mV")}, flush=True)
        return n, r
    R = {}
    with ThreadPoolExecutor(14) as ex:
        for n, r in ex.map(go, jobs.items()): R[n] = r
    json.dump(R, open(f"{HERE}/diff_output.json", "w"), indent=1, default=float)
