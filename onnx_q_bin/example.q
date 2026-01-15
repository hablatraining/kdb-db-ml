\l onnx_q.q

model: .onnx_q.init_fn["example.onnx"]

dims: (1 30);
total_shape: prd dims;
flat_data: total_shape ? 1e;

// warmup
do[10; .onnx_q.run_fn[model; flat_data; dims]];

lats:(); n:10000;
{t0:.z.n; .onnx_q.run_fn[model; flat_data; dims]; lats,:1e-3*.z.n-t0} each til n;
show select avg_us:avg lat, std_us:sdev lat from ([]lat:lats);


.onnx_q.free_fn[model];

\\
