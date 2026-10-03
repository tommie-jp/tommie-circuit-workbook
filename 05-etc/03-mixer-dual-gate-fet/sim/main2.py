from lib import *
import pickle
G2=(33e3,13e3); G1=(1e6,330e3)
R={}
def cg(frf,flo,prf=-30,plo=7,g2=G2,tag='m',fif=None):
    t,v=tran(frf,flo,prf=prf,plo=plo,g2=g2,g1=G1,tag=tag)
    f,A=spec(t,v); fx=abs(flo-frf) if fif is None else fif; i=np.argmin(abs(f-fx)); return dbm(A[i])-prf
rf=np.array([0.53,0.6,0.7,0.8,0.9,1.0,1.1,1.2,1.3,1.4,1.5,1.6])*1e6; R['rf']=rf
for plo in (0,4,7,10):
    R[f'trk{plo}']=np.array([cg(x,x+455e3,plo=plo) for x in rf]); print('track',plo,R[f'trk{plo}'].round(2),flush=True)
d=np.arange(-30e3,30.1e3,2e3); R['d']=d
R['main']=np.array([cg(1.0e6-x,1.455e6) for x in d])   # IF = 455k + x
R['image']=np.array([cg(1.91e6+x,1.455e6) for x in d]) # IF = 455k + x
print('main',R['main'].round(1)); print('image',R['image'].round(1),flush=True)
R['plo']=np.arange(-6,16,2); R['cg_plo']=np.array([cg(1.0e6,1.455e6,plo=p) for p in R['plo']]); print('plo',R['cg_plo'].round(1),flush=True)
vg2=np.array([0.8,1.0,1.2,1.3,1.3,1.41,1.7,1.9,2.2,2.5,3.0,4.5]); R['vg2']=vg2
R['cg_vg2']=np.array([cg(1.0e6,1.455e6,g2=(33e3,33e3*v/(5-v))) for v in vg2]); print('vg2',R['cg_vg2'].round(1),flush=True)
R['prf']=np.arange(-50,1,5)
def pout(prf):
    t,v=tran(1.0e6,1.455e6,prf=prf,g2=G2,g1=G1,tag='m'); f,A=spec(t,v); i=np.argmin(abs(f-455e3)); return dbm(A[i])
R['pout']=np.array([pout(p) for p in R['prf']]); print('pout',R['pout'].round(1),flush=True)
t,v=tran(1.0e6,1.455e6,g2=G2,g1=G1,tag='fft'); f,A=spec(t,v); R['fft']=(f,A)
# unfiltered drain spectrum for reference
t,v=tran(1.0e6,1.455e6,g2=G2,g1=G1,tag='fftd',node='d'); f,A=spec(t,v); R['fftd']=(f,A)
pickle.dump(R,open('R2.pkl','wb'))
