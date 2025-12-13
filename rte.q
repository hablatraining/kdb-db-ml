/ q tick/rte.q  -p 5013
\l funq.q
\l tick/u.q

minD: 1.1649949550628662;                 / Min data
maxD: 1.1756490468978882;                 / Max data
W:10;                                     / Window size
T:10 6 1;                                 / Topology [Lags; Hidden; Output]

norm:{%[x-minD;maxD-minD]};
denorm:{minD+x*maxD-minD};

.u.init[];
theta_final:@[;`theta](enlist"F";enlist",")0:`:weights.csv;  / load trained weights
hgolf:`h`g`o`l!`.ml.lrelu`.ml.dlrelu`.ml.linear`.ml.mseloss / (h=hidden, g=gradient hidden, o=output, l=loss)

h_tp:hopen 5010;

show"Init OK";
upd:{[t;d]
  insert[t;d];
  if[W<count get t;
    input_seq:(W,1)#norm neg[W]#get[t]`price;
    t0:.z.n;
    out:.ml.pnn[hgolf;input_seq] .ml.nncut[T] theta_final;
    .rte.latency:.z.n-t0;
    insert[`pred_trade;([]time:1#last d`time;sym:1#`USDEUR;price:"f"$out . 0 0)]];
  };

h_tp"(.u.sub[`;`])";

.u.end:{};

.u.snap:{0#pred_trade};