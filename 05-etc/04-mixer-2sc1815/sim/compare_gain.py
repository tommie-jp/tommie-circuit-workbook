"""4-3 の「条件をそろえた変換利得」を出す。3 つのミキサー (1 石・差動対・3SK291) を同じ関数で組み、
信号源・出力の負荷・利得の定義を揃えて過渡解析する。ngspice は Docker (ngspice-py) で回す。
使い方: python3 compare_gain.py (結果は compare_gain.json)。"""
import subprocess, os, json, hashlib, numpy as np
from concurrent.futures import ThreadPoolExecutor
HERE = os.path.dirname(os.path.abspath(__file__))
WORK = os.path.join(HERE, "_work")
os.makedirs(WORK, exist_ok=True)

Q = ".model Q1815 NPN (IS=2e-14 BF=250 NF=1 VAF=100 IKF=0.15 RB=30 RE=1 RC=5 CJE=8p CJC=2p TF=2n TR=50n)"
FET = (".model NE NMOS (LEVEL=1 VTO=0.4 KP=0.0337 LAMBDA=0.03 CGSO=1.9p CGDO=0.016p)\n"
       ".model NE2 NMOS (LEVEL=1 VTO=0.4 KP=0.06 LAMBDA=0.03 CGSO=1.5p CGDO=0.3p)")
FILTER = """Ls1 fin a 19.9m
Cs1 a fb1 6.15p
Rs1 fb1 n1 38
Cp1 n1 0 17.7n
Lp1 n1 0 6.9u
Ls2 n1 c 19.9m
Cs2 c e1 6.15p
Rs2 e1 fout 38
C5 fout 0 1.2n
L2 fout o2 100u
RLf2 o2 out 2
"""
TANK = "L1 vdd d1 220u\nRLt d1 d 5\nC3 vdd d 560p\nC4 d fin 10n\nRleak fin 0 1G\n"
G1 = (1e6, 330e3)   # G1 の分圧 (1.24 V)

def vs_open(dbm):  # 有能電力 dBm の 50 Ω 源の開放電圧 (波高値)
    return float(np.sqrt(8 * 50 * 10 ** (dbm / 10) / 1e3))

def tank(o):
    # load == "sc": IF を 0 V の電流計 (Vm) に流し、IF の短絡電流を測る (負荷に依らない変換コンダクタンス)
    return "Vm vdd d 0\n" if o["load"] == "sc" else TANK

def core(kind, o):
    TANK = tank(o)
    if kind == "single":
        return f"""{Q}
RB1 vdd b 82k
RB2 b 0 22k
RE e 0 470
C1 rf b 10n
C2 lo e 10n
Q1 d b e Q1815
{TANK}"""
    if kind == "fet":
        g2t = o.get("g2t", 33e3); g2b = o.get("g2b", 13e3)
        return f"""{FET}
R4 vdd g2 {g2t}
R5 g2 0 {g2b}
R2 vdd g1 {G1[0]}
R6 g1 0 {o.get("g1b", G1[1])}
C2 lo g2 10n
C1 rf g1 10n
M1 mid g1 0 0 NE
M2 d g2 mid 0 NE2
{TANK}"""
    se = kind == "diffse"   # 差動対の c1 だけを取り出し、1 石と同じ同調回路・R7・フィルタ・50 Ω につなぐ
    return f"""{Q}
RB1 vdd b3 82k
RB2 b3 0 22k
RE3 e3 0 470
C1 rf b3 10n
Q3 t b3 e3 Q1815
RL1 vdd b1 10k
RL2 b1 0 10k
RR1 vdd b2 10k
RR2 b2 0 10k
C9 b2 0 100n
C2 lo b1 10n
Q1 {"d" if se else "c1"} b1 t Q1815
Q2 c2 b2 t Q1815
{TANK if se else ("Vm1 vdd c1 0" if o["load"] == "sc" else "RC1 vdd c1 3300")}
{"Vm2 vdd c2 0" if o["load"] == "sc" and not se else "RC2 vdd c2 3300"}
"""

def netlist(kind, o):
    """o: plo prf frf flo src('50'|'0') load('pub'|'open'|抵抗値 Ω) r7(pub のとき。None で無し) g2t g2b"""
    s = [f"* mixer {kind}", ".options reltol=1e-4 abstol=1e-10 vntol=1e-7 gmin=1e-12",
         "VDD vdd 0 5", "C6 vdd 0 100n", "C7 vdd 0 10u", "R1 rf 0 51", "R3 lo 0 51", core(kind, o)]
    load, out = o["load"], None
    if kind == "diff":
        if load == "sc":
            out = ("Vm1#branch", "Vm2#branch")
        elif load in ("pub", "open"):
            out = ("c1", "c2")
        else:
            s.append(f"Cx1 c1 x 10n\nCx2 c2 y 10n\nRlx x y {load}\nRlk1 x 0 1G\nRlk2 y 0 1G"); out = ("x", "y")
    else:
        if load == "sc":
            out = ("Vm#branch", None)
        elif load == "pub":
            if o.get("r7", 2e3): s.append(f"R7 fin 0 {o.get('r7', 2e3)}")
            s.append(FILTER + "Rload out 0 50"); out = ("out", None)
        else:
            s.append(f"Rlx fin 0 {load}"); out = ("fin", None)
    def port(name, node, dbm, f, src):
        rs, k = (50, 1) if src == "50" else (1e-3, 0.5)
        return f"V{name} {name}s 0 SIN(0 {vs_open(dbm)*k} {f})\nR{name} {name}s {node} {rs}"
    s.append(port("lo", "lo", o["plo"], o["flo"], o.get("src_lo", o["src"])))
    s.append(port("rf", "rf", o["prf"], o["frf"], o.get("src_rf", o["src"])))
    return "\n".join(s), out

def sim(tag, kind, o, step=25e-9, tstop=1.4e-3):
    net, out = netlist(kind, o)
    nodes = [n for n in out if n]
    wr = " ".join((f"i({n[:-7]})" if n.endswith("#branch") else f"v({n})") for n in nodes)
    ctl = f"tran {step} {tstop} 0 {step}\nwrdata {tag}.dat {wr}\nmeas tran idd avg i(VDD) from=0.4m to=1.4m"
    open(f"{WORK}/{tag}.cir", "w").write(net + "\n.control\n" + ctl + "\n.endc\n.end\n")
    r = subprocess.run(["docker", "run", "--rm", "-v", f"{WORK}:/w", "-w", "/w", "ngspice-py", "ngspice", "-b", f"{tag}.cir"],
                       capture_output=True, text=True, timeout=1800)
    import re
    m = re.search(r"idd\s*=\s*([-+0-9.e]+)", r.stdout)
    d = np.loadtxt(f"{WORK}/{tag}.dat")
    t = d[:, 0]
    v = d[:, 1] - d[:, 3] if kind == "diff" else d[:, 1]
    if kind == "diff" and o["load"] == "sc": v = v / 2   # 浮かせた負荷に流れる電流は i1 (= −i2)
    return t, v, (-float(m.group(1)) if m else float("nan"))

def amp(t, v, fx, t0=0.4e-3, T=1.0e-3, step=25e-9):
    tt = np.arange(t0, t0 + T, step); vv = np.interp(tt, t, v); w = np.hanning(len(vv))
    X = np.fft.rfft(vv * w) * 2 / np.sum(w); f = np.fft.rfftfreq(len(vv), step)
    return abs(X[np.argmin(abs(f - fx))])

DEF = dict(plo=0, prf=-30, frf=1.0e6, flo=1.455e6, src="50", load="pub")
def gains(kind, **kw):
    """返す値: v_if (IF の振幅、負荷の両端)、gp = 負荷に出る IF 電力 ÷ RF の有能電力 (dB)、gv = IF の電圧 ÷ RF のポート電圧 (dB)"""
    o = {**DEF, **kw}
    tag = f"{kind}_{hashlib.md5(json.dumps(o, sort_keys=True, default=str).encode()).hexdigest()[:10]}"
    t, v, idd = sim(tag, kind, o)
    a = amp(t, v, o["flo"] - o["frf"])
    vport = vs_open(o["prf"]) / 2                      # 整合した 50 Ω 源が作るポートの電圧 (波高値)
    pav = vport ** 2 / (2 * 50)                          # RF の有能電力
    r = 50 if (o["load"] == "pub" and kind != "diff") else (None if o["load"] in ("open",) or (o["load"] == "pub") else o["load"])
    out = dict(vif=a, gv=20 * np.log10(a / vport), idd_mA=idd * 1e3)
    if o["load"] == "sc":
        out["gc_mS"] = a / vport * 1e3
        out.pop("gv"); return out
    if r: out["gp"] = 10 * np.log10((a ** 2 / (2 * r)) / pav)
    return out

if __name__ == "__main__":
    jobs = {}
    def add(name, kind, **kw): jobs[name] = (kind, kw)
    KINDS = ("single", "diff", "fet", "diffse")
    LOS = (-10, -5, 0, 4, 7, 10, 13, 16)
    # E1 公表値の再現と、信号源の違い (src: 0 = 0 Ω の源 = Wavegen、50 = 50 Ω の源 = 3-2 の条件)。RF と LO を別々にも変える
    for kind, plo in (("single", 0), ("diff", 0), ("fet", 7), ("fet", 0)):
        for src in ("0", "50"):
            add(f"pub_{kind}_lo{plo}_src{src}", kind, plo=plo, src=src)
        add(f"pub_{kind}_lo{plo}_rf0_lo50", kind, plo=plo, src_rf="0", src_lo="50")
        add(f"pub_{kind}_lo{plo}_rf50_lo0", kind, plo=plo, src_rf="50", src_lo="0")
    # E2 変換コンダクタンス (IF の短絡電流 ÷ RF のポート電圧)。負荷に依らない。信号源は 0 Ω と 50 Ω
    for kind in KINDS:
        for plo in LOS:
            for src in ("0", "50"):
                add(f"gc_{kind}_lo{plo}_src{src}", kind, plo=plo, src=src, load="sc")
    for kind in ("single", "fet", "diffse"):
        for plo in (0, 7, 13):
            add(f"pub50_{kind}_lo{plo}", kind, plo=plo, src_rf="0", src_lo="50")
            add(f"pub0_{kind}_lo{plo}", kind, plo=plo, src="0")
            add(f"pub0none_{kind}_lo{plo}", kind, plo=plo, src="0", r7=None)
    # E7 LO の電力の掃引 (同じ出力回路。図 4 用)
    for plo in LOS:
        add(f"sweep_single_lo{plo}", "single", plo=plo, src="0")
        add(f"sweep_single50_lo{plo}", "single", plo=plo, src_rf="0", src_lo="50")
        add(f"sweep_fet_lo{plo}", "fet", plo=plo, src="0")
        add(f"sweep_diffse_lo{plo}", "diffse", plo=plo, src="0")
        add(f"sweep_diff_lo{plo}", "diff", plo=plo, src="0")
    # E3 同じ負荷 (抵抗) に出る利得。差動対は 2 つのコレクタの間に浮かせる。信号源 0 Ω
    for kind in KINDS:
        for plo in (0, 7):
            for rl in (500, 2e3, 6.6e3, 20e3, 100e3):
                add(f"load_{kind}_lo{plo}_{int(rl)}", kind, plo=plo, src="0", load=rl)
    # E4 R7 の有無 (フィルタの後、50 Ω)。1 石にも掛ける
    for kind in ("single", "fet"):
        for plo in (0, 7, 10, 13):
            add(f"r7none_{kind}_lo{plo}", kind, plo=plo, src="0", r7=None)
            add(f"r72k_{kind}_lo{plo}", kind, plo=plo, src="0", r7=2e3)
    for r7 in (500, 1e3, 1.5e3, 3e3, 5e3):
        add(f"r7_{r7:g}_fet_lo7", "fet", plo=7, src="0", r7=r7)
    # E5 G2 の電圧の掃引 (R7 あり・なし、LO 0 / +7 / +13 dBm、Gc も)
    for v in (0.9, 1.0, 1.1, 1.2, 1.3, 1.41, 1.5, 1.6, 1.8, 2.0, 2.5):
        g2b = 33e3 * v / (5 - v)
        for plo in (0, 7, 13):
            add(f"g2_{v}_lo{plo}_pub", "fet", plo=plo, g2b=g2b, src="0")
            add(f"g2_{v}_lo{plo}_none", "fet", plo=plo, g2b=g2b, src="0", r7=None)
            add(f"g2_{v}_lo{plo}_gc", "fet", plo=plo, g2b=g2b, src="0", load="sc")
    # E6 G1 の電圧 (ドレイン電流) の掃引 (LO +7、G2 1.41 V)
    for v in (0.9, 1.0, 1.1, 1.24, 1.4, 1.6, 1.8):
        g1b = 1e6 * v / (5 - v)
        add(f"g1_{v}_pub", "fet", plo=7, g1b=g1b, src="0")
        add(f"g1_{v}_none", "fet", plo=7, g1b=g1b, src="0", r7=None)
        add(f"g1_{v}_gc", "fet", plo=7, g1b=g1b, src="0", load="sc")
    def run(item):
        n, (kind, kw) = item
        r = gains(kind, **kw)
        print(n, {k: round(float(x), 2) for k, x in r.items()}, flush=True)
        return n, {k: float(x) for k, x in r.items()}
    R = {}
    with ThreadPoolExecutor(14) as ex:
        for n, r in ex.map(run, jobs.items()): R[n] = r
    json.dump(R, open(f"{HERE}/compare_gain.json", "w"), indent=1)
