"""3-2 の残りの 2 点を調べる。ngspice は Docker (ngspice-py) で回す。結果は r7_g2_probe.json。
1. R7 (2 kΩ) の有無で IF OUT の通過帯域 (中心・−3 dB 幅・リップル) がどう変わるか (RF をずらす過渡解析)
2. LO 0 dBm で G2 の最適が 1.6 V 付近にずれる原因 (M1 の gm の LO による振れ・M1 が飽和にいる時間の割合・平均電流)"""
import os, sys, json, subprocess, hashlib, numpy as np
from concurrent.futures import ThreadPoolExecutor
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "04-mixer-2sc1815", "sim"))
import compare_gain as cg   # 3SK291 の回路 (3-2 と同じ値) と FFT を共用する
WORK = os.path.join(HERE, "_work"); os.makedirs(WORK, exist_ok=True)
VTO = 0.4

def passband(x, r7):
    """RF = 1.000 MHz − x、LO 1.455 MHz (+7 dBm) で IF = 455 kHz + x の利得"""
    return float(cg.gains("fet", plo=7, src="0", frf=1.0e6 - x, flo=1.455e6, r7=r7)["gp"])

def probe(vg2, plo):
    """M1 の gm・gds、中点 (M1 のドレイン) の電圧、ドレイン電流の波形を取り、IF の短絡電流も測る"""
    o = {**cg.DEF, "plo": plo, "src": "0", "load": "sc", "g2b": 33e3 * vg2 / (5 - vg2)}
    net, _ = cg.netlist("fet", o)
    tag = "probe_" + hashlib.md5(json.dumps(o, sort_keys=True).encode()).hexdigest()[:10]
    ctl = (".control\nsave all @m1[gm] @m1[gds] @m1[id]\ntran 25n 1.4m 0 25n\n"
           f"wrdata {tag}.dat i(Vm) v(mid) v(g1) v(g2) @m1[gm] @m1[gds] @m1[id]\nop\nprint v(mid) v(g1) v(g2) @m1[gm] @m1[gds] @m1[id]\n.endc\n.end\n")
    open(f"{WORK}/{tag}.cir", "w").write(net + "\n" + ctl)
    r = subprocess.run(["docker", "run", "--rm", "-v", f"{WORK}:/w", "-w", "/w", "ngspice-py", "ngspice", "-b", f"{tag}.cir"],
                       capture_output=True, text=True, timeout=1800)
    import re
    opv = {k: float(v) for k, v in re.findall(r"^(\S+)\s*=\s*([-+0-9.e]+)\s*$", r.stdout, re.M)}
    d = np.loadtxt(f"{WORK}/{tag}.dat")
    t = d[:, 0]; iif = d[:, 1]; vmid = d[:, 3]; vg1 = d[:, 5]; gm = d[:, 9]; idm = d[:, 13]
    w = t > 0.4e-3
    vport = cg.vs_open(-30) / 2
    sat = vmid[w] >= (vg1[w] - VTO)            # M1 が飽和にいる (V_DS ≥ V_GS − V_T)
    return dict(vg2=vg2, plo=plo,
                gc_mS=cg.amp(t, iif, 455e3) / vport * 1e3,
                gm1_lo_mS=cg.amp(t, gm, 1.455e6) * 1e3,          # gm1 の LO の周波数の成分 (波高値)
                gm1_mean_mS=float(np.mean(gm[w])) * 1e3,
                gm1_min_max_mS=[float(gm[w].min()) * 1e3, float(gm[w].max()) * 1e3],
                vmid_dc=opv.get("v(mid)"), vmid_min_max=[float(vmid[w].min()), float(vmid[w].max())],
                vsat_edge=float(np.mean(vg1[w]) - VTO),
                sat_frac=float(np.mean(sat)), id_mean_mA=float(np.mean(idm[w])) * 1e3,
                id_dc_mA=opv.get("@m1[id]", float("nan")) * 1e3, gm1_dc_mS=opv.get("@m1[gm]", float("nan")) * 1e3)

if __name__ == "__main__":
    R = {"passband": {}, "probe": []}
    xs = list(range(-20000, 20001, 1000))
    with ThreadPoolExecutor(14) as ex:
        for r7 in (2e3, None):
            R["passband"][str(r7)] = list(ex.map(lambda x: passband(x, r7), xs))
        R["passband"]["x"] = xs
        jobs = [(v, p) for p in (0, 7) for v in (1.0, 1.2, 1.3, 1.41, 1.5, 1.6, 1.7, 1.8, 2.0, 2.2)]
        R["probe"] = list(ex.map(lambda j: probe(*j), jobs))
    for r in R["probe"]:
        print({k: (round(v, 3) if isinstance(v, float) else v) for k, v in r.items()})
    json.dump(R, open(os.path.join(HERE, "r7_g2_probe.json"), "w"), indent=1)
