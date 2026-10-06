"""4-3 の表とグラフに使う数を出す。結果は results.json に残す。"""
from lib import *
import json
R = {}
RF = [0.53,0.6,0.8,1.0,1.2,1.4,1.6]
def one(kind, **kw):
    nodes = ('out','d','e') if kind=='single' else ('c1','c2','t')
    t, vs = tran(kind, nodes=nodes, **kw)
    prf = kw.get('prf', -30)
    if kind=='single':
        f,A = spec(t, vs[0]); fd,Ad = spec(t, vs[1])
        return dict(g=gain(amp(f,A,455e3),prf), lo=db(amp(fd,Ad,kw.get('flo',1.455e6))),
                    rf=db(amp(fd,Ad,kw.get('frf',1e6))), if_=db(amp(fd,Ad,455e3)),
                    ic=(5-np.mean(vs[1][-20000:]))*0)  # 電流は DC 解析で別に出す
    d = vs[0]-vs[1]; f,A = spec(t, d); f1,A1 = spec(t, vs[0])
    return dict(g=gain(amp(f,A,455e3),prf), lo=db(amp(f,A,kw.get('flo',1.455e6))), rf=db(amp(f,A,kw.get('frf',1e6))),
                if_=db(amp(f,A,455e3)), lo1=db(amp(f1,A1,kw.get('flo',1.455e6))), rf1=db(amp(f1,A1,kw.get('frf',1e6))))
for kind in ('single','diff'):
    R[kind] = {}
    R[kind]['plo'] = {p: one(kind, plo=p) for p in (-20,-15,-10,-5,0,4,7)}
    R[kind]['trk'] = {x: one(kind, plo=0, frf=x*1e6, flo=x*1e6+455e3)['g'] for x in RF}
    R[kind]['p1'] = {p: one(kind, plo=0, prf=p)['g'] for p in (-40,-30,-20,-15,-10,-7,-5,0,5)}
    print(kind, json.dumps({k:(v if not isinstance(v,dict) else {a:(round(b,1) if not isinstance(b,dict) else {c:round(e,1) for c,e in b.items()}) for a,b in v.items()}) for k,v in R[kind].items()}), flush=True)
json.dump(R, open('results.json','w'), indent=1, default=float)
