"""6-9 水晶ラダーフィルタの算術 (ABCD 行列)。python3 -I 09_ladder_design.py
水晶の定数は見積り: Cm 15 fF, Lm 69.9 mH (fs 4.9152 MHz から), Rs 30 Ω, C0 4 pF。"""
import numpy as np, sys
FS=4.9152e6; CM=15e-15; LM=1/((2*np.pi*FS)**2*CM); RS=30.0; C0=4e-12
def xtal(w, dfs=0.0, rs=RS):
    lm=LM; cm=1/((2*np.pi*(FS+dfs))**2*lm)
    zs=rs+1j*w*lm+1/(1j*w*cm); return zs/(1+1j*w*C0*zs)
def ser(z): return np.array([[1,z],[0,1]],complex)
def sh(y): return np.array([[1,0],[y,1]],complex)
def s21(f, C, Rt, n=4, endC=False, dfs=None, rs=RS):
    w=2*np.pi*f; m=np.eye(2,dtype=complex)
    for i in range(n):
        z=xtal(w, 0 if dfs is None else dfs[i], rs)
        if endC and i in (0,n-1): z=z+1/(1j*w*C)
        m=m@ser(z)
        if i<n-1: m=m@sh(1j*w*C)
    A,B,Cc,D=m.ravel(); return 2/(A+B/Rt+Cc*Rt+D)
def analyse(C,Rt,**k):
    f=np.arange(FS-2000,FS+6000,1.0); g=np.array([20*np.log10(abs(s21(x,C,Rt,**k))) for x in f])
    pk=g.max(); i3=np.where(g>=pk-3)[0]; i6=np.where(g>=pk-6)[0]; i60=np.where(g>=pk-60)[0]; i20=np.where(g>=pk-20)[0]
    pb=g[i3[0]:i3[-1]+1]
    # リップル: 通過帯域の中の極小の深さ
    inner=pb; mins=[inner[j] for j in range(1,len(inner)-1) if inner[j]<inner[j-1] and inner[j]<=inner[j+1]]
    rip=pk-min(mins) if mins else 0.0
    return dict(pk=pk,f_lo=f[i3[0]],f_hi=f[i3[-1]],bw3=f[i3[-1]]-f[i3[0]],bw6=f[i6[-1]]-f[i6[0]],bw20=f[i20[-1]]-f[i20[0]],bw60=f[i60[-1]]-f[i60[0]],rip=rip,fc=(f[i3[0]]+f[i3[-1]])/2), f, g
if __name__=='__main__':
    for endC in (False,True):
        print('endC',endC)
        for C in (150e-12,180e-12,220e-12,270e-12,330e-12):
            for Rt in (150,200,270,330,390,470,560,680):
                r,_,_=analyse(C,Rt,endC=endC)
                print(f" C={C*1e12:.0f}p Rt={Rt:4d} loss={-r['pk']:5.2f} bw3={r['bw3']:5.0f} bw6={r['bw6']:5.0f} bw20={r['bw20']:5.0f} bw60={r['bw60']:5.0f} rip={r['rip']:4.2f} fc={r['fc']-FS:+6.0f}")
