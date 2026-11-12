"""6-8 再生式受信機の確かめ。LTspice MCP の run_code から exec して使う (api・measurements が名前空間にある)。

    exec(open('05-etc/06-ham-receiver/sim/08-regen-lib.py').read()); ac([0.3, 0.9, 1.0])
"""
import os, re
HERE = "/home/tommie/52-tommie-fence/tommie-circuit-workbook/05-etc/06-ham-receiver/sim"
Q = ".model Q1815 NPN (IS=2e-14 BF=250 NF=1 VAF=100 IKF=0.15 RB=30 RE=1 RC=5 CJE=8p CJC=2p TF=2n TR=50n)"

def core(p):
    """検波段。部品の番号は本文の図1 と同じ。VW は再生の可変抵抗 VR1 の摺動子の電圧。
    CVC は C3 (22 pF) と VC1 の直列に配線の浮遊容量 (5 pF と置いた) を足した値。18 pF で約 7.15 MHz。"""
    return f"""{Q}
VCC vcc 0 5
L1 tank 0 4.096u Rser=1.22
C2 tank 0 {p.get('c2','62p')}
CVC tank 0 {p.get('cv','18p')}
C4 tank b {p.get('c4','47p')}
C5 b e {p.get('c5','220p')}
C6 e 0 {p.get('c6','470p')}
R2 e 0 {p.get('r2','4.7k')}
R1 w b 100k
R3 vcc c 22k
C7 c 0 2.2n
Q1 c b e Q1815
RANT a a1 50
C1 a1 tank {p.get('c1','4.7p')}
"""

def _run(name, text, wait=60):
    path = os.path.join(HERE, name)
    open(path, "w").write(text)
    r = api.run_experiments(circuits=[{"path": path}], execution={"wait_s": wait})
    return r["job_id"]

def ac(vws, lo="6.9Meg", hi="7.6Meg", n=70001, **p):
    text = "* 6-8 regenerative detector: small-signal Q vs regeneration (VW)\n" + core(p) + f"""VW w 0 {{VW}}
VANT a 0 AC 1
.ac lin {n} {lo} {hi}
.step param VW list {' '.join(str(v) for v in vws)}
.meas ac pk max mag(v(tank))
.meas ac fpk when mag(v(tank))=pk
.meas ac bw trig mag(v(tank))=pk/sqrt(2) rise=1 targ mag(v(tank))=pk/sqrt(2) fall=last
.end
"""
    m = measurements(job_id=_run("08-regen-ac.cir", text))["measurements"]
    out = []
    for i, v in enumerate(vws):
        g = lambda k: m[k]["values"][i]
        bw, f = g("bw"), g("fpk")
        out.append((v, g("pk"), f, bw))
        print(v, "pk=%.2f" % g("pk"), "f=%.4f MHz" % (f / 1e6), "bw=%s" % (None if bw is None else round(bw)), "Q=%s" % (None if not bw else round(f / bw)))
    return out

def op(vws, **p):
    meas = "".join(f".meas dc ve{i} find v(e) at {v}\n.meas dc vc{i} find v(c) at {v}\n" for i, v in enumerate(vws))
    text = "* 6-8 regenerative detector: operating point vs VW\n" + core(p) + f"""VW w 0 1
VANT a 0 0
.dc VW 0.2 2.0 0.005
{meas}.end
"""
    m = measurements(job_id=_run("08-regen-op.cir", text))["measurements"]
    out = []
    for i, v in enumerate(vws):
        ve, vc = m[f"ve{i}"]["values"][0], m[f"vc{i}"]["values"][0]
        out.append((v, ve / 4700, vc))
        print(v, "Ie=%.1f uA" % (ve / 4700 * 1e6), "Vc=%.3f V" % vc)
    return out

def tran(name, vw, src, tstop="6m", win="1m", dt="5n", extra="", vc0=3.0, **p):
    """過渡解析。src は VANT の波 (B 源の式か SIN)。最後の win の間で振幅を読む。"""
    text = f"* 6-8 regenerative detector: transient ({name})\n" + core(p) + f"""VW w 0 {vw}
{src}
* audio path to LM386 +INPUT (50k)
C10 c au 10n ic={vc0}
.ic v(c)={vc0}
RIN au 0 50k
.options reltol=1e-4
.tran 0 {tstop} 0 {dt} uic
.meas tran tkpp0 pp v(tank) from {{{tstop}-3*{win}}} to {{{tstop}-2*{win}}}
.meas tran tkpp pp v(tank) from {{{tstop}-{win}}} to {tstop}
.meas tran aupp pp v(au) from {{{tstop}-{win}}} to {tstop}
.meas tran vcavg avg v(c) from {{{tstop}-{win}}} to {tstop}
.meas tran t1 find time when v(tank)=0 rise=1 td={{{tstop}-{win}}}
.meas tran t2 find time when v(tank)=0 rise=1001 td={{{tstop}-{win}}}
.meas tran aurms rms v(au) from {{{tstop}-{win}}} to {tstop}
{extra}.end
"""
    path = os.path.join(HERE, f"08-regen-{name}.cir"); open(path, "w").write(text); return path

def read(name, jid):
    m = measurements(job_id=jid)["measurements"]
    g = lambda k: (m.get(k) or {}).get("values", [None])[0]
    f = None
    if g("t1") is not None and g("t2") is not None: f = 1000 / (g("t2") - g("t1"))
    print(name, "tank(before)=%.4g" % g("tkpp0"), "tank=%.4g Vpp" % g("tkpp"), "audio=%.4g Vpp" % g("aupp"), "Vc=%.4f" % g("vcavg"), "f=%s" % (None if f is None else "%.5f MHz" % (f / 1e6)))
    return m
