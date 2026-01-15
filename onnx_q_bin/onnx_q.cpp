#include <iostream>
#include <vector>
#include "onnxruntime/onnxruntime_cxx_api.h"
#define KXVER 3
#include "k.h"

Ort::Env* global_env = nullptr;

struct OnnxModel {
    Ort::Session* session;
    OnnxModel() : session(nullptr) {}
    ~OnnxModel() { if(session) delete session; }
};

extern "C" {

    K init_model(K path_k) {
        if (path_k->t != -KS && path_k->t != KC) return krr((S)"type_error_path");

        try {
            if (!global_env) global_env = new Ort::Env(ORT_LOGGING_LEVEL_WARNING, "Q_ONNX_MULTI");

            std::string model_path;
            if (path_k->t == -KS) model_path = path_k->s;
            else model_path = std::string((char*)kG(path_k), path_k->n);

            Ort::SessionOptions session_options;
            session_options.SetIntraOpNumThreads(1);

            OnnxModel* model_ctx = new OnnxModel();

            model_ctx->session = new Ort::Session(*global_env, model_path.c_str(), session_options);
            return kj((J)model_ctx);

        } catch (const std::exception& e) {
            return krr((S)e.what());
        }
    }

    K run_model(K model_ptr_k, K input_k, K shape_k) {
        if (model_ptr_k->t != -KJ) return krr((S)"Error: Model handle must be a long (-7h)");

            OnnxModel* model_ctx = (OnnxModel*)model_ptr_k->j;

            if (!model_ctx || !model_ctx->session) return krr((S)"Error: Invalid model handle");
        if (input_k->t != 9 && input_k->t != 19 && input_k->t != 8) return krr((S)"Error: Data must be float/real list");
        if (shape_k->t != 7) return krr((S)"Error: Shape must be a long list (type 7h)");

        try {
            Ort::Session* session = model_ctx->session;
            Ort::AllocatorWithDefaultOptions allocator;

            auto input_name_ptr = session->GetInputNameAllocated(0, allocator);
            auto output_name_ptr = session->GetOutputNameAllocated(0, allocator);

            const char* input_names[] = { input_name_ptr.get() };
            const char* output_names[] = { output_name_ptr.get() };

            std::vector<int64_t> input_dims;
            int64_t shape_product = 1;
            J* shape_ptr = kJ(shape_k);

            for (long i = 0; i < shape_k->n; ++i) {
                input_dims.push_back((int64_t)shape_ptr[i]);
                shape_product *= shape_ptr[i];
            }

            if (shape_product != input_k->n) {
                std::cerr << "[C++ Error] Shape mismatch: " << shape_product
                            << " != " << input_k->n << std::endl;
                return krr((S)"shape_mismatch_check_log");
            }

            size_t input_len = input_k->n;
            std::vector<float> input_data_float(input_len);
            float* input_data_ptr = nullptr;

            if (input_k->t == 8 || input_k->t == 19) {
                input_data_ptr = kE(input_k);
            } else if (input_k->t == 9) {
                double* src = kF(input_k);
                input_data_ptr = (float*) malloc(sizeof(float) * input_len);
                for(size_t i=0; i<input_len; ++i) input_data_ptr[i] = (float)src[i];
            } else {
                return krr((S)"type_error_need_float_or_double");
            }

            auto memory_info = Ort::MemoryInfo::CreateCpu(OrtArenaAllocator, OrtMemTypeDefault);
            Ort::Value input_tensor = Ort::Value::CreateTensor<float>(
                memory_info,
                input_data_ptr,
                input_len,
                input_dims.data(),
                input_dims.size()
            );

            auto output_tensors = session->Run(
                Ort::RunOptions{nullptr},
                input_names, &input_tensor, 1,
                output_names, 1
            );

            float* floatarr = output_tensors[0].GetTensorMutableData<float>();
            size_t output_len = output_tensors[0].GetTensorTypeAndShapeInfo().GetElementCount();

            K result_k = ktn(9, output_len);
            for(size_t i=0; i<output_len; ++i) kF(result_k)[i] = (double)floatarr[i];

            return result_k;

        } catch (const Ort::Exception& e) {
            std::cerr << "[C++ ONNX Exception] " << e.what() << std::endl;
            return krr((S)"onnx_runtime_error_check_log");
        } catch (const std::exception& e) {
            std::cerr << "[C++ STD Exception] " << e.what() << std::endl;
            return krr((S)"std_exception_check_log");
        }
    }

    K free_model(K model_ptr_k) {
        if (model_ptr_k->t != -KJ) return krr((S)"type_error_handle");

        OnnxModel* model_ctx = (OnnxModel*)model_ptr_k->j;

        if (model_ctx) {
            delete model_ctx;
        }

        return (K)0;
    }
}
