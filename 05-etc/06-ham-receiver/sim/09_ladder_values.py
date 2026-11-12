"""6-9 本文の表の数。python3 -I 09_ladder_values.py"""
import numpy as np
from importlib import util
import os,sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import importlib; d=importlib.import_module('09_ladder_design')
FS=d.FS; C=220e-12; RT=200.0
print('Lm mH',d.LM*1e3,'Q',2*np.pi*FS*d.LM/d.RS, 'fp-fs',FS*d.CM/(2*d.C0))
r,f,g=d.analyse(C,RT,endC=True)
print({k:round(float(v),2) for k,v in r.items()})
fc=r['fc']
def at(x,**k): return 20*np.log10(abs(d.s21(x,C,RT,endC=True,**k)))
for off in (-2000,-1400,-1000,-700,-500,0,500,700,1000,1400,2000,3000):
    print(f"fc{off:+5d} Hz ({(fc+off)/1e6:.6f} MHz): {at(fc+off):7.2f} dB  (山から {at(fc+off)-r['pk']:7.2f})")
print('peak f',f[g.argmax()])
# C を替えたとき (Rt 200)
for c in (150e-12,180e-12,220e-12,270e-12,330e-12):
    q,_,_=d.analyse(c,RT,endC=True); print(f"C {c*1e12:.0f}p bw3 {q['bw3']:.0f} bw6 {q['bw6']:.0f} bw60 {q['bw60']:.0f} loss {-q['pk']:.2f} fc {q['fc']-FS:+.0f} rip {q['rip']:.2f} 形状比 {q['bw60']/q['bw6']:.1f}")
# 端の直列 C の有無
q,_,_=d.analyse(C,RT,endC=False); print('endC なし',{k:round(float(v),2) for k,v in q.items()})
# Rs を替えたとき
for rs in (10,20,30,50,80):
    f2=np.arange(FS-1000,FS+3000,1.0); g2=[20*np.log10(abs(d.s21(x,C,RT,endC=True,rs=rs))) for x in f2]
    print('Rs',rs,'loss',round(-max(g2),2))
# 水晶の fs のばらつき
for name,dfs in (('そろえた ±10',[10,-10,5,-5]),('±50',[50,-40,30,-50]),('±150',[150,-120,90,-150]),('±300',[300,-250,200,-300])):
    f2=np.arange(FS-1000,FS+3000,1.0); g2=np.array([20*np.log10(abs(d.s21(x,C,RT,endC=True,dfs=dfs))) for x in f2])
    pk=g2.max(); i3=np.where(g2>=pk-3)[0]; pb=g2[i3[0]:i3[-1]+1]
    mins=[pb[j] for j in range(1,len(pb)-1) if pb[j]<pb[j-1] and pb[j]<=pb[j+1]]
    print(name,'loss',round(-pk,2),'bw3',f2[i3[-1]]-f2[i3[0]],'rip',round(pk-min(mins),2) if mins else 0)
# 治具 (直列 150 Ω を両端、50 Ω 系) の S21
def jig(x):
    w=2*np.pi*x; m=d.ser(150)
    for i in range(4):
        z=d.xtal(w)
        if i in (0,3): z=z+1/(1j*w*C)
        m=m@d.ser(z)
        if i<3: m=m@d.sh(1j*w*C)
    m=m@d.ser(150); A,B,Cc,D=m.ravel(); return 20*np.log10(abs(2/(A+B/50+Cc*50+D)))
for x in (4.9140e6, fc-1400, r['f_lo'], f[g.argmax()], fc, r['f_hi'], fc+1400, 4.9190e6, 4.9165e6,4.9145e6):
    print(f"jig {x/1e6:.6f} MHz {jig(x):7.2f} dB")
print('治具の足し算 dB', 20*np.log10(200/50)/1, 10*np.log10(200/50)*2)
# 水晶 1 個を 50 Ω 系に直列: fs と -3dB 幅 → Rs, Q
ff=np.arange(FS-500,FS+500,0.5); s=np.array([abs(2*50/(2*50+d.xtal(2*np.pi*x))) for x in ff]); 
pk=s.max(); i3=np.where(s>=pk/np.sqrt(2))[0]
print('単体: 山',20*np.log10(pk),'dB  f',ff[s.argmax()],' 幅',ff[i3[-1]]-ff[i3[0]],' Rs=100(1/|S21|-1)=',100*(1/pk-1), 'Lm=(100+Rs)/(2π幅)',(100+d.RS)/(2*np.pi*(ff[i3[-1]]-ff[i3[0]])))
# 直列に Cs=33p を入れたときのずれ → Cm
Cs=33e-12; s2=np.array([abs(2*50/(2*50+d.xtal(2*np.pi*x)+1/(1j*2*np.pi*x*Cs))) for x in np.arange(FS,FS+3000,0.5)])
f2=np.arange(FS,FS+3000,0.5)[s2.argmax()]; df=f2-ff[s.argmax()]
print('Cs 33p ずれ',df,' Cm=2Δf(Cs+C0)/fs',2*df*(Cs+d.C0)/FS)
