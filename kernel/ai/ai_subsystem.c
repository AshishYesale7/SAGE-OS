// ─────────────────────────────────────────────────────────────────────────────
// SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
// SPDX-License-Identifier: BSD-3-Clause OR Proprietary
// SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
// 
// This file is part of the SAGE OS Project.
//
// ─────────────────────────────────────────────────────────────────────────────
#include "ai/ai_subsystem.h"
#include "ai_hat/ai_hat.h"
#include "memory.h"
#include "uart.h"
#include <string.h>
#include <stdio.h>  // For sprintf

// Maximum number of models that can be loaded
#define MAX_MODELS 8

// Static variables
static bool ai_subsystem_initialized = false;
static ai_model_descriptor_t loaded_models[MAX_MODELS];
static uint32_t num_loaded_models = 0;

// Initialize the AI subsystem
ai_subsystem_status_t ai_subsystem_init(void) {
    // Check if already initialized
    if (ai_subsystem_initialized) {
        return AI_SUBSYSTEM_SUCCESS;
    }
    
    uart_puts("Initializing AI subsystem...\n");
    
    // Initialize AI HAT+
    ai_hat_status_t status = ai_hat_init();
    if (status != AI_HAT_SUCCESS) {
        uart_puts("Failed to initialize AI HAT+\n");
        return AI_SUBSYSTEM_ERROR_INIT;
    }
    
    // Initialize model list
    num_loaded_models = 0;
    
    ai_subsystem_initialized = true;
    uart_puts("AI subsystem initialized successfully\n");
    
    return AI_SUBSYSTEM_SUCCESS;
}

// Get AI subsystem information
ai_subsystem_status_t ai_subsystem_get_info(ai_hat_info_t* info) {
    if (!ai_subsystem_initialized) {
        return AI_SUBSYSTEM_ERROR_INIT;
    }
    
    if (info == NULL) {
        return AI_SUBSYSTEM_ERROR_PARAM;
    }
    
    // Get information from AI HAT+
    ai_hat_status_t status = ai_hat_get_info(info);
    if (status != AI_HAT_SUCCESS) {
        return AI_SUBSYSTEM_ERROR_INIT;
    }
    
    return AI_SUBSYSTEM_SUCCESS;
}

// Load a model from memory
ai_subsystem_status_t ai_subsystem_load_model(const void* model_data, uint32_t model_size, 
                                             ai_model_type_t type, ai_model_descriptor_t* descriptor) {
    if (!ai_subsystem_initialized) {
        return AI_SUBSYSTEM_ERROR_INIT;
    }
    
    if (model_data == NULL || model_size == 0 || descriptor == NULL) {
        return AI_SUBSYSTEM_ERROR_PARAM;
    }
    
    if (num_loaded_models >= MAX_MODELS) {
        return AI_SUBSYSTEM_ERROR_MEMORY;
    }
    
    // Load model to AI HAT+
    uint32_t model_id;
    ai_hat_status_t status = ai_hat_load_model(model_data, model_size, &model_id);
    if (status != AI_HAT_SUCCESS) {
        return AI_SUBSYSTEM_ERROR_MODEL;
    }
    
    // Create model descriptor
    ai_model_descriptor_t model;
    memset(&model, 0, sizeof(ai_model_descriptor_t));
    model.id = model_id;
    model.type = type;
    
    // Set default input/output dimensions based on model type
    switch (type) {
        case AI_MODEL_TYPE_CLASSIFICATION:
            // Default: 224x224 RGB image input, 1000 class output
            model.input_dims[0] = 1;    // batch
            model.input_dims[1] = 224;  // height
            model.input_dims[2] = 224;  // width
            model.input_dims[3] = 3;    // channels
            
            model.output_dims[0] = 1;    // batch
            model.output_dims[1] = 1;    // height
            model.output_dims[2] = 1;    // width
            model.output_dims[3] = 1000; // classes
            break;
            
        case AI_MODEL_TYPE_DETECTION:
            // Default: 416x416 RGB image input, detection output
            model.input_dims[0] = 1;    // batch
            model.input_dims[1] = 416;  // height
            model.input_dims[2] = 416;  // width
            model.input_dims[3] = 3;    // channels
            
            model.output_dims[0] = 1;   // batch
            model.output_dims[1] = 1;   // height
            model.output_dims[2] = 1;   // width
            model.output_dims[3] = 100; // detections
            break;
            
        case AI_MODEL_TYPE_SEGMENTATION:
            // Default: 512x512 RGB image input, segmentation mask output
            model.input_dims[0] = 1;    // batch
            model.input_dims[1] = 512;  // height
            model.input_dims[2] = 512;  // width
            model.input_dims[3] = 3;    // channels
            
            model.output_dims[0] = 1;    // batch
            model.output_dims[1] = 512;  // height
            model.output_dims[2] = 512;  // width
            model.output_dims[3] = 21;   // classes
            break;
            
        case AI_MODEL_TYPE_GENERATION:
            // Default: text generation model
            model.input_dims[0] = 1;    // batch
            model.input_dims[1] = 1;    // height
            model.input_dims[2] = 1;    // width
            model.input_dims[3] = 512;  // sequence length
            
            model.output_dims[0] = 1;    // batch
            model.output_dims[1] = 1;    // height
            model.output_dims[2] = 1;    // width
            model.output_dims[3] = 512;  // sequence length
            break;
            
        case AI_MODEL_TYPE_CUSTOM:
        default:
            // Default: custom model with unknown dimensions
            model.input_dims[0] = 1;  // batch
            model.input_dims[1] = 1;  // height
            model.input_dims[2] = 1;  // width
            model.input_dims[3] = 1;  // channels
            
            model.output_dims[0] = 1; // batch
            model.output_dims[1] = 1; // height
            model.output_dims[2] = 1; // width
            model.output_dims[3] = 1; // channels
            break;
    }
    
    // Set model name
    sprintf(model.name, "Model_%u", model_id);
    
    // Set precision (default to FP16)
    model.precision = AI_HAT_PRECISION_FP16;
    
    // Add model to list
    loaded_models[num_loaded_models] = model;
    num_loaded_models++;
    
    // Copy descriptor to output
    *descriptor = model;
    
    return AI_SUBSYSTEM_SUCCESS;
}

// Unload a model
ai_subsystem_status_t ai_subsystem_unload_model(uint32_t model_id) {
    if (!ai_subsystem_initialized) {
        return AI_SUBSYSTEM_ERROR_INIT;
    }
    
    // Find model in list
    int model_index = -1;
    for (uint32_t i = 0; i < num_loaded_models; i++) {
        if (loaded_models[i].id == model_id) {
            model_index = i;
            break;
        }
    }
    
    if (model_index == -1) {
        return AI_SUBSYSTEM_ERROR_PARAM;
    }
    
    // Unload model from AI HAT+
    ai_hat_status_t status = ai_hat_unload_model(model_id);
    if (status != AI_HAT_SUCCESS) {
        return AI_SUBSYSTEM_ERROR_MODEL;
    }
    
    // Remove model from list by shifting remaining models
    for (uint32_t i = model_index; i < num_loaded_models - 1; i++) {
        loaded_models[i] = loaded_models[i + 1];
    }
    
    num_loaded_models--;
    
    return AI_SUBSYSTEM_SUCCESS;
}

// Run inference on a loaded model
ai_subsystem_status_t ai_subsystem_run_inference(uint32_t model_id, const void* input, void* output) {
    if (!ai_subsystem_initialized) {
        return AI_SUBSYSTEM_ERROR_INIT;
    }
    
    if (input == NULL || output == NULL) {
        return AI_SUBSYSTEM_ERROR_PARAM;
    }
    
    // Find model in list
    int model_index = -1;
    for (uint32_t i = 0; i < num_loaded_models; i++) {
        if (loaded_models[i].id == model_id) {
            model_index = i;
            break;
        }
    }
    
    if (model_index == -1) {
        return AI_SUBSYSTEM_ERROR_PARAM;
    }
    
    // Calculate input and output sizes
    uint32_t input_size = loaded_models[model_index].input_dims[0] *
                         loaded_models[model_index].input_dims[1] *
                         loaded_models[model_index].input_dims[2] *
                         loaded_models[model_index].input_dims[3];
    
    uint32_t output_size = loaded_models[model_index].output_dims[0] *
                          loaded_models[model_index].output_dims[1] *
                          loaded_models[model_index].output_dims[2] *
                          loaded_models[model_index].output_dims[3];
    
    // Run inference on AI HAT+
    ai_hat_status_t status = ai_hat_run_inference(model_id, input, input_size, output, output_size);
    if (status != AI_HAT_SUCCESS) {
        return AI_SUBSYSTEM_ERROR_INFERENCE;
    }
    
    return AI_SUBSYSTEM_SUCCESS;
}

// Get list of loaded models
ai_subsystem_status_t ai_subsystem_get_models(ai_model_descriptor_t* models, uint32_t max_models, uint32_t* num_models) {
    if (!ai_subsystem_initialized) {
        return AI_SUBSYSTEM_ERROR_INIT;
    }
    
    if (models == NULL || num_models == NULL || max_models == 0) {
        return AI_SUBSYSTEM_ERROR_PARAM;
    }
    
    // Copy models to output
    uint32_t count = (num_loaded_models < max_models) ? num_loaded_models : max_models;
    for (uint32_t i = 0; i < count; i++) {
        models[i] = loaded_models[i];
    }
    
    *num_models = count;
    
    return AI_SUBSYSTEM_SUCCESS;
}

// Get AI subsystem temperature
ai_subsystem_status_t ai_subsystem_get_temperature(uint32_t* temperature) {
    if (!ai_subsystem_initialized) {
        return AI_SUBSYSTEM_ERROR_INIT;
    }
    
    if (temperature == NULL) {
        return AI_SUBSYSTEM_ERROR_PARAM;
    }
    
    // Get temperature from AI HAT+
    ai_hat_status_t status = ai_hat_get_temperature(temperature);
    if (status != AI_HAT_SUCCESS) {
        return AI_SUBSYSTEM_ERROR_INIT;
    }
    
    return AI_SUBSYSTEM_SUCCESS;
}

// Get AI subsystem power consumption
ai_subsystem_status_t ai_subsystem_get_power_consumption(uint32_t* power) {
    if (!ai_subsystem_initialized) {
        return AI_SUBSYSTEM_ERROR_INIT;
    }
    
    if (power == NULL) {
        return AI_SUBSYSTEM_ERROR_PARAM;
    }
    
    // Get power consumption from AI HAT+
    ai_hat_status_t status = ai_hat_get_power_consumption(power);
    if (status != AI_HAT_SUCCESS) {
        return AI_SUBSYSTEM_ERROR_INIT;
    }
    
    return AI_SUBSYSTEM_SUCCESS;
}

// Set AI subsystem power mode
ai_subsystem_status_t ai_subsystem_set_power_mode(ai_hat_power_mode_t mode) {
    if (!ai_subsystem_initialized) {
        return AI_SUBSYSTEM_ERROR_INIT;
    }
    
    // Set power mode on AI HAT+
    ai_hat_status_t status = ai_hat_set_power_mode(mode);
    if (status != AI_HAT_SUCCESS) {
        return AI_SUBSYSTEM_ERROR_INIT;
    }
    
    return AI_SUBSYSTEM_SUCCESS;
}

// Shutdown the AI subsystem
void ai_subsystem_shutdown(void) {
    if (!ai_subsystem_initialized) {
        return;
    }
    
    // Unload all models
    while (num_loaded_models > 0) {
        ai_subsystem_unload_model(loaded_models[0].id);
    }
    
    // Shutdown AI HAT+
    ai_hat_shutdown();
    
    ai_subsystem_initialized = false;
}