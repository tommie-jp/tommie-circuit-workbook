import subprocess, numpy as np, os, re, textwrap
VTO=0.4; K1=33.7e-3; K2=60e-3
def netlist(ana, vg1_div=(1e6,242e3), g2=(33e3,100e3), frf=1.0e6, flo=1.455e6, prf_dbm=-30, plo_dbm=7, tstop=1.4e-3, extra="", vdd=5, rt=51):
    rtop,rbot=vg1_div
    vrf=np.sqrt(8*50*10**(prf_dbm/10)/1e3)   # open-circuit peak for available power
    vlo=np.sqrt(8*50*10**(plo_dbm/10)/1e3)
    rtop2,rbot2=g2
    src_rf = f"Vrf rfs 0 SIN(0 {vrf} {frf}) AC 1" if ana!='ac_if' else "Vrf rfs 0 0"
    return f"""* 3SK291 dual-gate mixer (stand-in model)
.options reltol=1e-4 abstol=1e-10 vntol=1e-7 gmin=1e-12
VDD vdd 0 {vdd}
C6 vdd 0 100n
C7 vdd 0 10u
L1 vdd d1 220u
RL1 d1 d 5
C3 vdd d 560p
R4 vdd g2 {rtop2}
R5 g2 0 {rbot2}
R2 vdd g1 {rtop}
R6 g1 0 {rbot}
R3 lo 0 {rt}
C2 lo g2 10n
R1 rf 0 {rt}
C1 rf g1 10n
.model NE NMOS (LEVEL=1 VTO={VTO} KP={K1} LAMBDA=0.03 CGSO=1.9p CGDO=0.016p)
.model NE2 NMOS (LEVEL=1 VTO={VTO} KP={K2} LAMBDA=0.03 CGSO=1.5p CGDO=0.3p)
M1 mid g1 0 0 NE
M2 d g2 mid 0 NE2
C4 d fin 10n
Rleak fin 0 1G
R7 fin 0 2k
* 455k ceramic filter equivalent (3rd-order BPF, 1.5k, BW~12k, finite Q)
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
{ 'Rload out 0 50' if ana!='ac_out' else '' }
{extra}
"""
def run(net, cmds, name):
    open(name+'.cir','w').write(net+"\n.control\n"+cmds+"\n.endc\n.end\n")
    r=subprocess.run(['ngspice','-b',name+'.cir'],capture_output=True,text=True,timeout=900)
    return r.stdout+r.stderr

def tran(frf, flo, prf=-30, plo=7, g2=(33e3,100e3), g1=(1e6,242e3), tstop=1.4e-3, step=25e-9, tag='t', node='out', ret_t=False):
    extra="Vlo los 0 SIN(0 %g %g)\nRlo los lo 50\nVrf rfs 0 SIN(0 %g %g)\nRrf rfs rf 50\n" % (np.sqrt(8*50*10**(plo/10)/1e3),flo,np.sqrt(8*50*10**(prf/10)/1e3),frf)
    net=netlist('tran', vg1_div=g1, g2=g2, extra=extra)
    cmd=f".tran {step} {tstop} 0 {step}\n" if False else f"tran {step} {tstop} 0 {step}\nwrdata {tag}.dat v({node})\n"
    out=run(net,cmd,tag)
    d=np.loadtxt(tag+'.dat')
    t,v=d[:,0],d[:,1]
    return t,v
def spec(t,v,t0=0.4e-3,T=1.0e-3,step=25e-9):
    tt=np.arange(t0,t0+T,step)
    vv=np.interp(tt,t,v)
    w=np.hanning(len(vv))
    X=np.fft.rfft(vv*w)*2/np.sum(w)
    f=np.fft.rfftfreq(len(vv),step)
    return f,np.abs(X)
def dbm(vpk): # across 50 ohm
    return 10*np.log10((vpk**2/2/50)/1e-3+1e-30)
