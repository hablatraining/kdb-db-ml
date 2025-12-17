/ q tick/rte_pykx.q  -p 5013
\l pykx.q
\l tick/u.q
system"l tick/sym.q"

// zb:.pykx.import`zerobus_cli;
// zir:zb`:ingest_records;

W:15;                                            / Window Parameter
minD: 1.1649949550628662;                        / Min data
maxD: 1.1756490468978882;                        / Max data

norm:{%[x-minD;maxD-minD]};
denorm:{minD+x*maxD-minD};

.u.init[];
ort:.pykx.import[`onnxruntime];
mP:.pykx.eval"\"../models/usdeur_model_no_hidden.onnx\""    / (m)odel (P)ath
session:ort[`:InferenceSession] mP;               / create inference session
                                              
h_tp:hopen 5010;

// latestSymPrice: 0!`sym xkey 0#trade;
show"Init OK";
upd:{[t;d]
  insert[t;d];
  input_seq:(1,W,1)#norm neg[count[get t]&W]#get[t]`price;
  t0:.z.t;out:session[`:run][::;enlist[`input_sequence]!enlist input_seq]`;.rte.latency:.z.t-t0;
  insert[`pred_trade;([]time:1#last d`time;sym:1#`USDEUR;price:"f"$denorm out . 0 0)];
  };

h_tp"(.u.sub[`;`])";

.u.end:{};

.u.snap:{0#pred_trade};
// .u.snap:{[x;y]select from latestSymPrice where sym=x, side=y};

// .z.ts:{.u.pub[`trade;select from latestSymPrice]};
// \t 16