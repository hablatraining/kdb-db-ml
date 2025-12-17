/ q tick/rte_pykx.q  -p 5013
\l pykx.q
\l tick/u.q
system"l tick/sym.q"

// zb:.pykx.import`zerobus_cli;
// zir:zb`:ingest_records;

minD: 1.1649949550628662;                        / Min data
maxD: 1.1756490468978882;                        / Max data
lats:([]time:`timespan$();lat:`timespan$());

topD:`baseline`wide`deep`input!(10 6 1;200 1024 512 1;
                                10 16 16 16 16 16 16 16 16 1;
                                2000 16 8 1);
T:topD `$label:first .Q.opt[.z.x]`label;  / Topology [Lags; Hidden; Output] read by argument line
W:first T;                                / Window size

norm:{%[x-minD;maxD-minD]};
denorm:{minD+x*maxD-minD};

.u.init[];
ort:.pykx.import[`onnxruntime];
mP:.pykx.eval"\"../models/dummy-",label,".onnx\""    / (m)odel (P)ath
session:ort[`:InferenceSession] mP;               / create inference session
                                              
h_tp:hopen 5010;

// latestSymPrice: 0!`sym xkey 0#trade;
show"Init OK";
upd:{[t;d]
  insert[t;d];
  if[W<count get t;
    input_seq:(1,W)#norm neg[W]#get[t]`price;
    t0:.z.n;out:session[`:run][::;enlist[`input]!enlist input_seq]`;.rte.latency:.z.n-t0;
    insert[`lats;([]time:1#last d`time;lat:1#.rte.latency)];
    insert[`pred_trade;([]time:1#last d`time;sym:1#`USDEUR;price:"f"$denorm out . 0 0)]
   ];
  };

h_tp"(.u.sub[`;`])";

.u.end:{};

.u.snap:{0#pred_trade};
// .u.snap:{[x;y]select from latestSymPrice where sym=x, side=y};

// .z.ts:{.u.pub[`trade;select from latestSymPrice]};
// \t 16