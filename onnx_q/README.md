## Prerequisites

- KDB+ and q installed on your system.

- ONNX Runtime libraries installed (if you use dynamically linked extension):

  Fedora:
  ```bash
  sudo dnf install onnxruntime onnxruntime-devel
  ```
  (devel is required for compilation)
  
  Ubuntu:
  ```bash
  sudo apt-get install onnxruntime libonnxruntime-dev
  ```

- A g++/gcc compiler

## Installation

### Use the ONNX q extension dynamically linked

You can try to use `onnx_q.so` that is stored in the `compiled` folder. However, this file may not be compatible with your system due to differences in ONNX Runtime library versions.


If you want to check the dependencies of the `onnx_q.so` file, you can use the `ldd` command:
```bash
ldd compiled/onnx_q.so
```
If the dependencies are not met, you can compile the extension yourself by following the steps below.

You can use `onnx_q.so` copying it to your desired location. Then, execute `example.q` to verify the installation. You should see output similar to:

```bash
KDB-X 5.0 2025.11.17 Copyright (C) 1993-2025 Kx Systems

...

-0.3022825 -0.1541319 0.6898746 -0.5554121 0.4120433 0.2180877 0.09677694 0.1155136 0.2425012 0.279036 -0.247232 -0.08938641 0.7667145 -0.4712944 0.5968385 0.3473793 0.1525749 ..
```


### Compile the ONNX q extension (dinamically linked)

To compile the ONNX , run:

```bash
g++ -shared -fPIC \
    onnx_q.cpp \
    -lonnxruntime \
    -o onnx_q.so
```

Move the file `onnx_q.so` to your desired location. Execute `example.q` to verify the installation. You should see output similar to:

```bash
KDB-X 5.0 2025.11.17 Copyright (C) 1993-2025 Kx Systems

...

-0.3022825 -0.1541319 0.6898746 -0.5554121 0.4120433 0.2180877 0.09677694 0.1155136 0.2425012 0.279036 -0.247232 -0.08938641 0.7667145 -0.4712944 0.5968385 0.3473793 0.1525749 ..
```

### Use the ONNX q extension statically linked

You have a file named `onnx_q_static.so` in the folder `compiled`. This file contains the ONNX q extension statically linked with the ONNX Runtime library. You can use this file directly without the need to compile it yourself and without the need to install the ONNX Runtime library on your system.

To use the statically linked extension, simply load it in your q script:

```q
init_fn: `onnx_q_static 2: (`init_model; 1);
run_fn: `onnx_q_static 2: (`run_model; 3);
free_fn: `onnx_q_static 2: (`free_model; 1);

model: init_fn[`example.onnx];

flat_data: 300?1.0e;

result: run_fn[model; flat_data; 10 30];

show result;

free_fn[model];
```
