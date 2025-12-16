init_fn: `onnx_q 2: (`init_model; 1);
run_fn: `onnx_q 2: (`run_model; 3);
free_fn: `onnx_q 2: (`free_model; 1);

model: init_fn[`example.onnx];

flat_data: 300?1.0e;

result: run_fn[model; flat_data; 10 30];

show result;

free_fn[model];
