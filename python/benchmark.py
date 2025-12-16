import argparse
from timeit import repeat

import numpy as np
import onnx
import onnxruntime as ort


def extract_input_dim(model_path: str) -> int:
    model = onnx.load(model_path)
    input_tensor = model.graph.input[0]
    input_shape = [dim.dim_value for dim in input_tensor.type.tensor_type.shape.dim]
    return input_shape[1]  # Assuming shape is [batch_size, input_dim]


def benchmark_model(model_path: str, batch_size: int = 1, n_runs: int = 100):
    session = ort.InferenceSession(model_path)
    input_dim = extract_input_dim(model_path)

    dummy_input = np.random.randn(batch_size, input_dim).astype(np.float32)

    def infer():
        session.run(None, {"input": dummy_input})

    for _ in range(10):
        infer()

    times = repeat(infer, number=1, repeat=n_runs)
    avg_time = sum(times) / n_runs * 1e6  # Convert to microseconds
    std_time = np.std(times) * 1e6  # Convert to microseconds

    if batch_size > 1:
        print(
            f"Inference time over {n_runs} runs with batch size {batch_size}: "
            f"{avg_time:.2f} ± {std_time:.2f} µs"
        )
        print(
            f"Average time per sample: {avg_time / batch_size:.2f} ± {std_time / batch_size:.2f} µs"
        )
    else:
        print(f"Inference time over {n_runs} runs: {avg_time:.2f} ± {std_time:.2f} µs")


def main():
    parser = argparse.ArgumentParser(description="Benchmark ONNX Model Inference Time")
    parser.add_argument(
        "--model-path", type=str, required=True, help="Path to the ONNX model file"
    )

    parser.add_argument(
        "--batch-size", type=int, default=1, help="Batch size for inference"
    )
    parser.add_argument(
        "--n-runs", type=int, default=1_000_000, help="Number of runs for benchmarking"
    )

    args = parser.parse_args()

    print("Starting benchmark with the following parameters:")
    print(f"Model Path: {args.model_path}")
    print(f"Batch Size: {args.batch_size}")
    print(f"Number of Runs: {args.n_runs}")

    benchmark_model(
        model_path=args.model_path,
        batch_size=args.batch_size,
        n_runs=args.n_runs,
    )


if __name__ == "__main__":
    main()
