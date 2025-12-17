# Deep Learning Tick Architecture + Databricks ingestion

## Overview

This project implements a real-time **Tick Architecture** designed to integrate Deep Learning models within a high-frequency data environment. The primary objective is to study and benchmark inference latencies across different implementation strategies.

We specifically compare two approaches for model inference:
1.  **Native Q:** Running logic directly within the kdb+ environment.
2.  **PyKX & ONNX:** Leveraging Python integration via PyKX to run models exported to the ONNX format.

## Prerequisites

Before running the architecture, please ensure your environment meets the following requirements:

* **KDB-X**: The KDB environment must be installed and correctly configured.
* **PyKX**: Must be installed as a part of the kdbx installation.
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
* **Metric**: Latency is measured in microseconds (or the specific unit relevant to your timer), averaged over 100,000 calls.

## Performance Results

The following table summarizes the benchmark results. It compares the mean latency and standard deviation for each model across both environments.

| Model | Env | Num Calls | Mean | Std |
| :--- | :--- | :--- | :--- | :--- |
| **baseline** | Q | 100,000 | 8.744082 | 6.066646 |
| **baseline** | PY | 100,000 | 293.0992 | 7118.33 |
| **wide** | Q | 100,000 | 2933.54 | 21764.99 |
| **wide** | PY | 100,000 | 317.9046 | 7962.475 |
| **deep** | Q | 100,000 | 39.36039 | 17.85333 |
| **deep** | PY | 100,000 | 132.8266 | 100.6198 |
| **input** | Q | 100,000 | 88.59854 | 18.5757 |
| **input** | PY | 100,000 | 171.4899 | 112.7705 |

You can reproduce this results by executing:
```bash
q q/benchmark.q -n_run 100000
```

### Observations

* **Baseline Performance:** The native `Q` environment demonstrates significantly lower latency and variance for the baseline model compared to the `PY` environment, likely due to the overhead of the Python interface call (IPC/PyKX bridge).
* **Complex Models (Wide):** Interestingly, for the "Wide" model, the `PY` environment offers better stability and mean performance than the native `Q` implementation, suggesting that optimized Python libraries (via ONNX) may handle larger matrix operations more efficiently than the native Q implementation used in this specific test.
* **Stability:** In general, the native Q environment (`env: Q`) shows lower standard deviation for most models, indicating more deterministic performance suitable for strict real-time requirements.