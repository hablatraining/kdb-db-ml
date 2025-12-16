all: onnx_q.so

onnx_q.so:
	g++ -shared -fPIC onnx_q.cpp -lonnxruntime -o onnx_q.so
