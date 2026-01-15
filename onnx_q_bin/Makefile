INCLUDES = -I./include
LIBS = -L./bin -lonnxruntime

CPPFLAGS = -shared -fPIC -Wl,-rpath,'$$ORIGIN' -std=c++17 -O3

all: bin/onnx_q.so

bin/onnx_q.so: onnx_q.cpp
	g++ $(CPPFLAGS) $(INCLUDES) onnx_q.cpp $(LIBS) -o bin/onnx_q.so

install: bin/onnx_q.so bindings.q
	@if [ -z "${QHOME}" ]; then \
        echo "Error: QHOME is not set, please set QHOME to your Q installation directory."; \
        exit 1; \
    fi
	@mkdir -p ${QHOME}/l64
	@cp bin/* ${QHOME}/l64
	@cp bindings.q ${QHOME}/onnx_q.q

clean:
	@rm -f bin/onnx_q.so

uninstall:
	@if [ -z "${QHOME}" ]; then \
        echo "Error: QHOME is not set, please set QHOME to your Q installation directory."; \
        exit 1; \
    fi
	@rm -f ${QHOME}/l64/onnx_q.so
	@rm -f ${QHOME}/l64/libonnxruntime*.so*
