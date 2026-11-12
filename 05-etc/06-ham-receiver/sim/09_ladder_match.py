"""6-9 フィルタを SA612 (1.5 kΩ) に L 型でつないだときの数。python3 -I 09_ladder_match.py"""
import numpy as np, importlib, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
d=importlib.import_module('09_ladder_design'); FS=d.FS; C=220e-12
def zseen(L,Cp,R=1500.0,f=4.9155e6):
    w=2*np.pi*f; return 1/(1/R+1j*w*Cp)+1j*w*L
for L,Cp in ((18e-6,47e-12),(18e-6,50e-12),(15e-6,56e-12),(22e-6,39e-12)):
    print(f"L {L*1e6:.0f}u Cp {Cp*1e12:.0f}p -> フィルタから見た Z = {zseen(L,Cp):.1f}")
def chain(f,L=18e-6,Cin=47e-12,Cout=50e-12,rl=0.0,R=1500.0):
    w=2*np.pi*f; m=d.sh(1j*w*Cin)@d.ser(1j*w*L+rl)
    for i in range(4):
        z=d.xtal(w)
        if i in (0,3): z=z+1/(1j*w*C)
        m=m@d.ser(z)
        if i<3: m=m@d.sh(1j*w*C)
    m=m@d.ser(1j*w*L+rl)@d.sh(1j*w*Cout); A,B,Cc,D=m.ravel(); return 2/(A+B/R+Cc*R+D)
for rl,name in ((0.0,'L の損失なし'),(2*np.pi*4.9155e6*18e-6/80,'L の Q 80')):
    f=np.arange(FS-1500,FS+3000,1.0); g=np.array([20*np.log10(abs(chain(x,rl=rl))) for x in f]); pk=g.max(); i3=np.where(g>=pk-3)[0]
    pb=g[i3[0]:i3[-1]+1]; mins=[pb[j] for j in range(1,len(pb)-1) if pb[j]<pb[j-1] and pb[j]<=pb[j+1]]
    print(name,'損失',round(-pk,2),'dB  -3dB',f[i3[0]],f[i3[-1]],'幅',f[i3[-1]]-f[i3[0]],'リップル',round(pk-min(mins),2) if mins else 0,'中心',(f[i3[0]]+f[i3[-1]])/2)
# 抵抗で落とす場合 (並列 220 Ω を両側): 1.5k∥220=192 Ω
Rp=220.0
def chain_r(f,R=1500.0):
    w=2*np.pi*f; m=d.sh(1/Rp)
    for i in range(4):
        z=d.xtal(w)
        if i in (0,3): z=z+1/(1j*w*C)
        m=m@d.ser(z)
        if i<3: m=m@d.sh(1j*w*C)
    m=m@d.sh(1/Rp); A,B,Cc,D=m.ravel(); return 2/(A+B/R+Cc*R+D)
g=[20*np.log10(abs(chain_r(x))) for x in np.arange(FS-500,FS+1500,1.0)]; print('並列 220 Ω で落とす: 損失',round(-max(g),2),'dB')
print('FT37-61 18 回', 55e-9*18**2*1e6,'uH')
