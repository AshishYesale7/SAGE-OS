// ─────────────────────────────────────────────────────────────────────────────
// SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
// SPDX-License-Identifier: BSD-3-Clause OR Proprietary
// SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
// 
// This file is part of the SAGE OS Project.
//
// ─────────────────────────────────────────────────────────────────────────────
// Licensing:
// -----------
//                                 
//                                                                             
//   Licensed under the BSD 3-Clause License or a Commercial License.          
//   You may use this file under the terms of either license as specified in: 
//                                                                             
//      - BSD 3-Clause License (see ./LICENSE)                           
//      - Commercial License (see ./COMMERCIAL_TERMS.md or contact legal@your.org)  
//                                                                             
//   Redistribution and use in source and binary forms, with or without       
//   modification, are permitted under the BSD license provided that the      
//   following conditions are met:                                            
//                                                                             
//     * Redistributions of source code must retain the above copyright       
//       notice, this list of conditions and the following disclaimer.       
//     * Redistributions in binary form must reproduce the above copyright    
//       notice, this list of conditions and the following disclaimer in the  
//       documentation and/or other materials provided with the distribution. 
//     * Neither the name of the project nor the names of its contributors    
//       may be used to endorse or promote products derived from this         
//       software without specific prior written permission.                  
//                                                                             
//   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS  
//   IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED    
//   TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A          
//   PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER 
//   OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
//   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,      
//   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR       
//   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF   
//   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING     
//   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS       
//   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  
//
// By using this software, you agree to be bound by the terms of either license.
//
// Alternatively, commercial use with extended rights is available — contact the author for commercial licensing.
//
// ─────────────────────────────────────────────────────────────────────────────
// Contributor Guidelines:
// ------------------------
// Contributions are welcome under the terms of the Developer Certificate of Origin (DCO).
// All contributors must certify that they have the right to submit the code and agree to
// release it under the above license terms.
//
// Contributions must:
//   - Be original or appropriately attributed
//   - Include clear documentation and test cases where applicable
//   - Respect the coding and security guidelines defined in CONTRIBUTING.md
//
// ─────────────────────────────────────────────────────────────────────────────
// Terms of Use and Disclaimer:
// -----------------------------
// This software is provided "as is", without any express or implied warranty.
// In no event shall the authors, contributors, or copyright holders
// be held liable for any damages arising from the use of this software.
//
// Use of this software in critical systems (e.g., medical, nuclear, safety)
// is entirely at your own risk unless specifically licensed for such purposes.
//
// ─────────────────────────────────────────────────────────────────────────────#include "tflite_wrapper.h"

#ifdef ENABLE_AI

#include <cstdint>
#include <cstring>

#include "tensorflow/lite/micro/all_ops_resolver.h"
#include "tensorflow/lite/micro/micro_error_reporter.h"
#include "tensorflow/lite/micro/micro_interpreter.h"
#include "tensorflow/lite/schema/schema_generated.h"

// TFLite globals
namespace {
    tflite::ErrorReporter* error_reporter = nullptr;
    const tflite::Model* model = nullptr;
    tflite::MicroInterpreter* interpreter = nullptr;
    tflite::AllOpsResolver resolver;
    
    // Arena memory for TFLite
    constexpr int kTensorArenaSize = 128 * 1024;
    static uint8_t tensor_arena[kTensorArenaSize];
}

extern "C" {

int tflite_init(void) {
    // Set up logging
    static tflite::MicroErrorReporter micro_error_reporter;
    error_reporter = &micro_error_reporter;
    
    return 0;
}

void* tflite_load_model(const unsigned char* model_data, unsigned int model_size) {
    // Map the model into a usable data structure
    model = tflite::GetModel(model_data);
    if (model->version() != TFLITE_SCHEMA_VERSION) {
        error_reporter->Report("Model version mismatch!");
        return nullptr;
    }
    
    // Build an interpreter to run the model
    static tflite::MicroInterpreter static_interpreter(
        model, resolver, tensor_arena, kTensorArenaSize, error_reporter);
    interpreter = &static_interpreter;
    
    // Allocate tensors
    if (interpreter->AllocateTensors() != kTfLiteOk) {
        error_reporter->Report("AllocateTensors() failed");
        return nullptr;
    }
    
    return (void*)model;
}

int tflite_run_inference(void* model_handle, 
                         const float* input_data, unsigned int input_size,
                         float* output_data, unsigned int output_size) {
    if (!interpreter) {
        return -1;
    }
    
    // Get input tensor
    TfLiteTensor* input = interpreter->input(0);
    
    // Check input dimensions
    size_t input_bytes = input->bytes;
    if (input_bytes != input_size * sizeof(float)) {
        error_reporter->Report("Input size mismatch!");
        return -2;
    }
    
    // Copy input data
    std::memcpy(input->data.f, input_data, input_bytes);
    
    // Run inference
    if (interpreter->Invoke() != kTfLiteOk) {
        error_reporter->Report("Invoke failed!");
        return -3;
    }
    
    // Get output tensor
    TfLiteTensor* output = interpreter->output(0);
    
    // Check output dimensions
    size_t output_bytes = output->bytes;
    if (output_bytes != output_size * sizeof(float)) {
        error_reporter->Report("Output size mismatch!");
        return -4;
    }
    
    // Copy output data
    std::memcpy(output_data, output->data.f, output_bytes);
    
    return 0;
}

void tflite_unload_model(void* model_handle) {
    // Nothing to do, as we're using static memory
    model = nullptr;
    interpreter = nullptr;
}

} // extern "C"

#else // ENABLE_AI

// Stub implementations when AI is disabled

extern "C" {

int tflite_init(void) {
    return -1;
}

void* tflite_load_model(const unsigned char* model_data, unsigned int model_size) {
    return nullptr;
}

int tflite_run_inference(void* model_handle, 
                         const float* input_data, unsigned int input_size,
                         float* output_data, unsigned int output_size) {
    return -1;
}

void tflite_unload_model(void* model_handle) {
    // Do nothing
}

} // extern "C"

#endif // ENABLE_AI