// Neural Network Training Script in q
// q train_nn.q -s 4 
\l funq.q

minD: 1.1649949550628662;                 / Min data
maxD: 1.1756490468978882;                 / Max data
W:10;                                     / Window size
T:10 6 1;                                 / Topology [Lags; Hidden; Output]

data:("STF";enlist",")0:`$":data/FX_data.csv";  / load FX training data
usdeur:select from data where id=`USDEUR; / filter for USDEUR
data:exec price from usdeur;               / extract price column

X:flip W#'(til neg[W]+count data)_\:data   / Input matrix
Y:enlist W _ data;                         / Output vector

norm:{%[x-minD;maxD-minD]};                / Normalization function
denorm:{minD+x*maxD-minD};                 / Denormalization function
rf:.ml.l2[1f];                             / L2 regularization factor

X_norm:norm X;
theta:2 raze/ .ml.heu'[1+-1_T;1_T];        / Heuristic initialization of weights
hgolf:`h`g`o`l!`.ml.lrelu`.ml.dlrelu`.ml.linear`.ml.mseloss / (h=hidden, g=gradient hidden, o=output, l=loss)

// TRAINING
iter:200;                                  / Number of iterations
res:.fmincg.fmincg[iter;.ml.nncostgrad[rf;T;hgolf;Y;X_norm];theta];
weights:first res;
save `:weights.csv;