INCLUDES = -I/usr/local/include/onnxruntime
LIBS = -L/usr/local/lib -lonnxruntime

CPPFLAGS = -shared -fPIC -std=c++17 -O3

all: onnx_q.so

onnx_q.so: onnx_q.cpp
	g++ $(CPPFLAGS) $(INCLUDES) onnx_q.cpp $(LIBS) -o onnx_q.so
