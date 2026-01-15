## Installation

First, configure environment variables if needed:
```bash
export QHOME=~/q
```

Then, run the installation command:
```bash
make install
```

This commands compiles necessary components and moves libraries and scripts to their respective directories in the `$QHOME` path.

## Usage

To run an ONNX model using the provided `onnx_q` library, use the following Q script:
```q
\l onnx_q.q

// Load the model
model: .onnx_q.init_fn["example.onnx"]

// run model
dims: (1 30);
total_shape: prd dims;
flat_data: total_shape ? 1e;

result: .onnx_q.run_fn[model; flat_data; dims]

// free model
.onnx_q.free_fn[model]
```
