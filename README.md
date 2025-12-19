# Deep Learning Tick Architecture + Databricks ingestion

## Overview

This project implements a real-time **Tick Architecture** designed to integrate Deep Learning models within a high-frequency data environment. The primary objective is to study and benchmark inference latencies across different implementation strategies.

We specifically compare two approaches for model inference:
1.  **Native Q:** Running logic directly within the kdb+ environment.
2.  **PyKX & ONNX:** Leveraging Python integration via PyKX to run models exported to the ONNX format.
3. **C API Binding (ONNX)**: A high-performance implementation using the kdb+ C API to create a direct binding with the ONNX Runtime, minimizing overhead by bypassing the Python interpreter entirely.

## Prerequisites

Before running the architecture, please ensure your environment meets the following requirements:

* **KDB-X**: The KDB environment must be installed and correctly configured.
* **PyKX**: Must be installed as a part of the kdbx installation.
* **ONNX Runtime C**: Required for compiling and linking the direct C API binding.
* **Python Dependencies**: You must have `onnxruntime` installed in your Python environment.
    ```bash
    pip install onnxruntime
    ```

## How to Run

To launch the full tick architecture, execute the provided shell script from your terminal:

```bash
bash tick.sh
```

## Methodologies

The benchmark measures the round-trip time and processing overhead for various model architectures (Baseline, Wide, Deep, Input). 

* **Environment `Q`**: Represents the native kdb+ approach.
* **Environment `PY`**: Represents the Python approach using PyKX with ONNX Runtime.
* **Environment `C API`**: Direct integration using the kdb+ C API for maximum performance and minimum latency.
* **Metric**: Latency is measured in microseconds (or the specific unit relevant to your timer), averaged over 100,000 calls.

## Performance Results

The following table summarizes the benchmark results. It compares the mean latency and standard deviation for each model across both environments.

| Model | Env | Num Calls | Mean | Std |
| :--- | :--- | :--- | :--- | :--- |
| **baseline** | C API | 100,000 | 1.5435 | 0.1884 |
| **baseline** | Q | 100,000 | 8.744082 | 6.066646 |
| **baseline** | PY | 100,000 | 293.0992 | 7118.33 |
| **wide** | C API | 100,000 | 44.4280 | 2.5842 |
| **wide** | Q | 100,000 | 2933.54 | 21764.99 |
| **wide** | PY | 100,000 | 317.9046 | 7962.475 |
| **deep** | C API | 100,000 | 3.0413 | 0.1685 |
| **deep** | Q | 100,000 | 39.36039 | 17.85333 |
| **deep** | PY | 100,000 | 132.8266 | 100.6198 |
| **input** | C API | 100,000 | 3.3457 | 0.2369 |
| **input** | Q | 100,000 | 88.59854 | 18.5757 |
| **input** | PY | 100,000 | 171.4899 | 112.7705 |

You can reproduce this results by executing:
```bash
q q/benchmark.q -n_run 100000
```

### Observations

* **C API Performance**: The direct C API binding is the clear winner, offering the lowest latency and highest stability (lowest standard deviation) across every tested architecture.
* **Overhead Elimination**: By using the C API, we eliminate the IPC/bridge overhead inherent in PyKX and the performance limitations of native Q for complex neural network operations.
* **Scalability**: The C API shows remarkable efficiency in the Wide model, being nearly 66x faster than native Q, which struggles with the matrix complexity of that specific architecture.
* **Real-Time Readiness**: The sub-5 microsecond performance for Baseline, Deep, and Input models using the C API makes it the only viable candidate for ultra-low latency production environments.