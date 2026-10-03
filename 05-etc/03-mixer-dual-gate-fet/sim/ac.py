from lib import *
import pickle
G2=(33e3,13e3); G1=(1e6,330e3)
def acz(port, ana='ac', f1=10e3, f2=10e6, sweep='dec 100'):
    extra=f"Vz {port} 0 AC 1\n"
    net=netlist('ac_out' if port=='out' else 'ac', vg1_div=G1,g2=G2,extra=extra)
    o=run(net,f"ac {sweep} {f1} {f2}\nwrdata acz.dat i(Vz)\n","acz")
    d=np.loadtxt('acz.dat'); f=d[:,0]; i=d[:,1]+1j*d[:,2]
    return f, -1/i
R={}
for p in ('rf','lo','out'):
    R[p]=acz(p) if p!='out' else acz(p,f1=400e3,f2=510e3,sweep='lin 221')
    f,z=R[p]
    for fx in (0.53e6,1.0e6,1.6e6,0.455e6,2.0e6):
        k=np.argmin(abs(f-fx)); G=(z[k]-50)/(z[k]+50); print(p,f"{f[k]/1e3:.0f}k",np.round(z[k],1),"RL",round(-20*np.log10(abs(G)),1),"VSWR",round((1+abs(G))/(1-abs(G)),2))
pickle.dump(R,open('Z.pkl','wb'))
# filter chain loss alone: |Vout/Vin| with 1.5k source & 50 load? quick: gain from d via C4 ... skip
