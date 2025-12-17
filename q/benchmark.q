/ q q/benchmark.q -n_run 100000
\l funq.q
\l pykx.q

topD:(ms:`baseline`wide`deep`input)!(10 6 1;200 1024 512 1;
                                10 16 16 16 16 16 16 16 16 1;
                                2000 16 8 1); 
ort:.pykx.import[`onnxruntime];

bmk_q:{[m;bs;n]                          / run bechmark model [(m)odel; (b)atch (s)ize; (n)umber of runs]
  .m.lats:();
  path:`$":models/weights_",string[m],".csv";                     / path depending topology
  .m.weights:@[;`weights](enlist"F";enlist",")0:path;             / load trained weights
  .m.hgolf:`h`g`o`l!`.ml.lrelu`.ml.dlrelu`.ml.linear`.ml.mseloss; / (h=hidden, g=gradient hidden, o=output, l=loss)
  inps:(n,.m.W,1)#(n*.m.W:first .m.T:topD m)?1f;                  / generating random inputs
  infer:{[inp]t0:.z.n;.ml.pnn[.m.hgolf;inp] .ml.nncut[.m.T] .m.weights;.m.lats,:1e-3*.z.n-t0};
  infer each inps;                                                / running inference
  @[;`model`env;:;m,`Q]                                           / adding model info
    select num_calls:count i, mean:avg lat, std:sdev lat from ([]lat:.m.lats) / calculating stats
  };

bmk_py:{[m;bs;n]                                                / run bechmark model [(m)odel; (b)atch (s)ize; (n)umber of runs]
  .m.lats:();
  mP:.pykx.eval"\"models/dummy-",string[m],".onnx\"";           / (m)odel (P)ath
  .m.ss:ort[`:InferenceSession] mP;                             / create inference session
  inps:(n,1,.m.W)#(n*.m.W:first .m.T:topD m)?1f;                / generating random inputs
  infer:{[inp]t0:.z.n;.m.ss[`:run][::;enlist[`input]!enlist inp]`;.m.lats,:1e-3*.z.n-t0};
  infer each inps;                                              / running inference
  @[;`model`env;:;m,`PY]                                        / adding model info
    select num_calls:count i, mean:avg lat, std:sdev lat from ([]lat:.m.lats) / calculating stats
  };

show `model`env xcols raze raze (bmk_q;bmk_py).\:/: ms,\:1,first"J"$.Q.opt[.z.x]`n_run