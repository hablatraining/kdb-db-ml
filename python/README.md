# Onnx Benchmark

## Create model

```bash
uv run create.py --input-dim 10 --output-dim 1 --hidden-dims 16 8 --output-path ../models/dummy-linear-10-16-8.onnx
```

* --input-dim: input dimension
* --output-dim: output dimension
* --hidden-dims: hidden layer dimensions
* --output-path: output model path

## Run benchmark

```bash
uv run benchmark.py --model-path ../models/dummy-linear-10-16-8.onnx --batch-size 1
```

* --model-path: path to the ONNX model
* --batch-size: batch size for inference
* --n-rums: number of runs for benchmarking


## Some experiments

Baseline: 10; 6; 1 (parameters: 73)
wide: 200; 1024 512; 1 (parameters: 731,137)
deep: 10; 16 16 16 16 16 16 16 16; 1 (parameters: 2,097)
input_heavy: 2000; 16 8; 1 (parameters 32,161)

CPU: Intel(R) Core(TM) Ultra 7 265U

| Model                              | Batch Size | Num runs  | Inference Time per batch (µs) | Inference Time per sample (µs) |
|------------------------------------|------------|-----------|-------------------------------|--------------------------------|
| dummy-baseline.onnx                |          1 | 1,000,000 |                 2.71 ± 0.94   |                  2.71 ± 0.94   |
| dummy-baseline.onnx                |         56 | 1,000,000 |                 3.14 ± 1.45   |                  0.06 ± 0.03   |
| dummy-baseline.onnx                |        126 |   100,000 |                 3.55 ± 1.14   |                  0.03 ± 0.01   |
| dummy-wide.onnx                    |          1 | 1,000,000 |                47.24 ± 55.03  |                 47.24 ± 55.03  |
| dummy-wide.onnx                    |         56 |   100,000 |               662.16 ± 283.43 |                 11.82 ± 5.06   |
| dummy-wide.onnx                    |        126 |    50,000 |              1311.60 ± 616.29 |                 10.41 ± 4.89   |
| dummy-deep.onnx                    |          1 | 1,000,000 |                 7.20 ± 1.16   |                  7.20 ± 1.16   |
| dummy-deep.onnx                    |         56 | 1,000,000 |                12.12 ± 3.25   |                  0.22 ± 0.06   |
| dummy-deep.onnx                    |        126 | 1,000,000 |                17.60 ± 3.42   |                  0.14 ± 0.03   |
| dummy-input_heavy.onnx             |          1 | 1,000,000 |                 7.35 ± 2.45   |                  7.35 ± 2.45   |
| dummy-input_heavy.onnx             |         56 |   500,000 |                54.95 ± 163.80 |                  0.98 ± 2.93   |
| dummy-input_heavy.onnx             |        126 |   500,000 |                76.26 ± 71.77  |                  0.61 ± 0.57   |
