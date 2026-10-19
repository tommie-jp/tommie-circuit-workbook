"""2SC1815 ミキサー (1 石 / 差動対) の過渡解析。ngspice を Docker (ngspice-py) で回す。"""
import subprocess, os, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__))
# 2SC1815 の代用モデル (hFE≈250・fT≈80 MHz・Cob≈2 pF の目安から作った。実測の値ではない)
Q = ".model Q1815 NPN (IS=2e-14 BF=250 NF=1 VAF=100 IKF=0.15 RB=30 RE=1 RC=5 CJE=8p CJC=2p TF=2n TR=50n)"
FILTER = """* 455k セラミックフィルタ相当 (3 次 BPF、1.5k、BW~12k)
Ls1 fin a 19.9m
Cs1 a b1 6.15p
Rs1 b1 n1 38
Cp1 n1 0 17.7n
Lp1 n1 0 6.9u
Ls2 n1 c 19.9m
Cs2 c e1 6.15p
Rs2 e1 fout 38
C5 fout 0 1.2n
L2 fout o2 100u
RL2 o2 out 2
Rload out 0 50
"""
# 信号源は Wavegen と同じく 0 Ω。振幅はポート (51 Ω の終端) の電圧で、50 Ω の整合負荷に出る電力 (dBm) から決める
def vpk(dbm): return float(np.sqrt(8*50*10**(dbm/10)/1e3))   # 50 Ω の開放電圧の波高値
def single(p):
    return f"""* 2SC1815 1-transistor mixer
.options reltol=1e-4 abstol=1e-10 vntol=1e-7 gmin=1e-12
{Q}
VDD vdd 0 5
C6 vdd 0 100n
C7 vdd 0 10u
RB1 vdd b {p['rb1']}
RB2 b 0 {p['rb2']}
RE e 0 {p['re']}
C1 rf b 10n
R1 rf 0 51
R3 lo 0 51
C2 lo e 10n
Q1 d b e Q1815
L1 vdd d1 220u
RL1 d1 d 5
C3 vdd d 560p
C4 d fin 10n
R7 fin 0 2k
Rleak fin 0 1G
{FILTER}
Vlo los 0 SIN(0 {vpk(p['plo'])/2} {p['flo']})
Rlo los lo 1m
Vrf rfs 0 SIN(0 {vpk(p['prf'])/2} {p['frf']})
Rrf rfs rf 1m
"""
def diff(p):
    return f"""* 2SC1815 differential-pair (single balanced) mixer
.options reltol=1e-4 abstol=1e-10 vntol=1e-7 gmin=1e-12
{Q}
VDD vdd 0 5
C6 vdd 0 100n
C7 vdd 0 10u
RB1 vdd b3 {p['rb1']}
RB2 b3 0 {p['rb2']}
RE3 e3 0 {p['re']}
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
Q1 c1 b1 t Q1815
Q2 c2 b2 t Q1815
RC1 vdd c1 {p['rc']}
RC2 vdd c2 {p['rc']}
Vlo los 0 SIN(0 {vpk(p['plo'])/2} {p['flo']})
Rlo los lo 1m
Vrf rfs 0 SIN(0 {vpk(p['prf'])/2} {p['frf']})
Rrf rfs rf 1m
"""
DEF = dict(rb1=82e3, rb2=22e3, re=470, rc=3.3e3, plo=0, prf=-30, flo=1.455e6, frf=1.0e6)
def tran(kind, tag='t', nodes=('out',), tstop=1.4e-3, step=25e-9, **kw):
    p = {**DEF, **kw}
    net = (single if kind == 'single' else diff)(p)
    wr = ' '.join(f'v({n})' for n in nodes)
    ctl = f"tran {step} {tstop} 0 {step}\nwrdata {tag}.dat {wr}\nprint v(vdd)"
    open(f'{HERE}/{tag}.cir', 'w').write(net + "\n.control\n" + ctl + "\n.endc\n.end\n")
    subprocess.run(['docker','run','--rm','-v',f'{HERE}:/w','-w','/w','ngspice-py','ngspice','-b',f'{tag}.cir'],
                   capture_output=True, text=True, timeout=900)
    d = np.loadtxt(f'{HERE}/{tag}.dat')
    return d[:,0], [d[:,1+2*i] for i in range(len(nodes))]
def spec(t, v, t0=0.4e-3, T=1.0e-3, step=25e-9):
    tt = np.arange(t0, t0+T, step); vv = np.interp(tt, t, v); w = np.hanning(len(vv))
    X = np.fft.rfft(vv*w)*2/np.sum(w); return np.fft.rfftfreq(len(vv), step), np.abs(X)
def amp(f, A, fx):
    return A[np.argmin(abs(f-fx))]
def db(x): return 20*np.log10(x+1e-15)
def gain(vif, prf): return db(vif/(vpk(prf)/2))
