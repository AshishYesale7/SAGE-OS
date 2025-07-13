/* ─────────────────────────────────────────────────────────────────────────────
 * SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
 * SPDX-License-Identifier: BSD-3-Clause OR Proprietary
 * SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
 * 
 * This file is part of the SAGE OS Project.
 *
 * ───────────────────────────────────────────────────────────────────────────── */
#ifndef AI_SUBSYSTEM_H
#define AI_SUBSYSTEM_H

#include "../types.h"
#include "../../drivers/ai_hat/ai_hat.h"

// AI subsystem status codes
typedef enum {
    AI_SUBSYSTEM_SUCCESS = 0,
    AI_SUBSYSTEM_ERROR_INIT = -1,
    AI_SUBSYSTEM_ERROR_MEMORY = -2,
    AI_SUBSYSTEM_ERROR_MODEL = -3,
    AI_SUBSYSTEM_ERROR_INFERENCE = -4,
    AI_SUBSYSTEM_ERROR_PARAM = -5
} ai_subsystem_status_t;

// AI model type
typedef enum {
    AI_MODEL_TYPE_CLASSIFICATION = 0,
    AI_MODEL_TYPE_DETECTION = 1,
    AI_MODEL_TYPE_SEGMENTATION = 2,
    AI_MODEL_TYPE_GENERATION = 3,
    AI_MODEL_TYPE_CUSTOM = 4
} ai_model_type_t;

// AI model descriptor
typedef struct {
    char name[32];
    uint32_t id;
    ai_model_type_t type;
    uint32_t input_dims[4];  // [batch, height, width, channels]
    uint32_t output_dims[4]; // [batch, height, width, channels]
    ai_hat_precision_t precision;
} ai_model_descriptor_t;

// Initialize the AI subsystem
ai_subsystem_status_t ai_subsystem_init(void);

// Get AI subsystem information
ai_subsystem_status_t ai_subsystem_get_info(ai_hat_info_t* info);

// Load a model from memory
ai_subsystem_status_t ai_subsystem_load_model(const void* model_data, uint32_t model_size, 
                                             ai_model_type_t type, ai_model_descriptor_t* descriptor);

// Unload a model
ai_subsystem_status_t ai_subsystem_unload_model(uint32_t model_id);

// Run inference on a loaded model
ai_subsystem_status_t ai_subsystem_run_inference(uint32_t model_id, const void* input, void* output);

// Get list of loaded models
ai_subsystem_status_t ai_subsystem_get_models(ai_model_descriptor_t* models, uint32_t max_models, uint32_t* num_models);

// Get AI subsystem temperature
ai_subsystem_status_t ai_subsystem_get_temperature(uint32_t* temperature);

// Get AI subsystem power consumption
ai_subsystem_status_t ai_subsystem_get_power_consumption(uint32_t* power);

// Set AI subsystem power mode
ai_subsystem_status_t ai_subsystem_set_power_mode(ai_hat_power_mode_t mode);

// Shutdown the AI subsystem
void ai_subsystem_shutdown(void);

#endif // AI_SUBSYSTEM_H