/* ─────────────────────────────────────────────────────────────────────────────
 * SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
 * SPDX-License-Identifier: BSD-3-Clause OR Proprietary
 * SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
 * 
 * This file is part of the SAGE OS Project.
 *
 * ───────────────────────────────────────────────────────────────────────────── */
#include "ai_hat.h"
#include "../uart.h"
#include "../i2c.h"
#include "../spi.h"
#include "../../kernel/stdio.h"
#include <stdbool.h>

// AI HAT+ I2C address
#define AI_HAT_I2C_ADDR     0x42

// AI HAT+ command registers
#define AI_HAT_REG_VERSION  0x00
#define AI_HAT_REG_CONTROL  0x01
#define AI_HAT_REG_STATUS   0x02
#define AI_HAT_REG_TEMP     0x03
#define AI_HAT_REG_POWER    0x04
#define AI_HAT_REG_MODEL    0x10
#define AI_HAT_REG_INFERENCE 0x20

// AI HAT+ control commands
#define AI_HAT_CMD_INIT     0x01
#define AI_HAT_CMD_SHUTDOWN 0x02
#define AI_HAT_CMD_SET_POWER 0x03
#define AI_HAT_CMD_LOAD_MODEL 0x10
#define AI_HAT_CMD_UNLOAD_MODEL 0x11
#define AI_HAT_CMD_RUN_INFERENCE 0x20

// Static variables
static bool ai_hat_initialized = false;
static ai_hat_info_t ai_hat_info;
static ai_hat_model_t loaded_models[8]; // Support up to 8 models
static uint32_t num_loaded_models = 0;

// Delay function - simple busy wait
static void __attribute__((unused)) delay(int32_t count) {
    while (count--) {
        asm volatile("nop");
    }
}

// Initialize I2C for communication with AI HAT+
static ai_hat_status_t init_i2c() {
    i2c_status_t status;
    
    // Initialize I2C at 400 kHz (Fast mode)
    status = i2c_init(I2C_SPEED_FAST);
    if (status != I2C_SUCCESS) {
        uart_puts("Failed to initialize I2C for AI HAT+\n");
        return AI_HAT_ERROR_INIT;
    }
    
    // Check if AI HAT+ is present
    uint8_t dummy = 0;
    status = i2c_write(AI_HAT_I2C_ADDR, &dummy, 0);
    if (status != I2C_SUCCESS) {
        uart_puts("AI HAT+ not detected on I2C bus\n");
        return AI_HAT_ERROR_COMM;
    }
    
    uart_puts("AI HAT+ detected on I2C bus\n");
    return AI_HAT_SUCCESS;
}

// Initialize SPI for high-speed data transfer with AI HAT+
static ai_hat_status_t init_spi() {
    spi_status_t status;
    
    // Configure SPI for AI HAT+
    spi_config_t config;
    config.clock_speed = 20000000;  // 20 MHz
    config.cpol = SPI_CPOL_0;       // Clock idle low
    config.cpha = SPI_CPHA_0;       // Sample on first edge
    config.cs_pol = SPI_CS_POL_LOW; // CS active low
    config.cs_pin = 0;              // Use CS0
    config.bits_per_word = 8;       // 8 bits per word
    
    // Initialize SPI
    status = spi_init(&config);
    if (status != SPI_SUCCESS) {
        uart_puts("Failed to initialize SPI for AI HAT+\n");
        return AI_HAT_ERROR_INIT;
    }
    
    uart_puts("SPI initialized for AI HAT+\n");
    return AI_HAT_SUCCESS;
}

// Send command to AI HAT+ via I2C
static ai_hat_status_t send_command(uint8_t reg, uint8_t cmd, uint8_t* data, uint32_t len) {
    i2c_status_t status;
    
    // Prepare command buffer
    uint8_t cmd_buffer[len + 2];
    cmd_buffer[0] = reg;
    cmd_buffer[1] = cmd;
    
    // Copy data if provided
    if (data != NULL && len > 0) {
        memcpy(&cmd_buffer[2], data, len);
    }
    
    // Send command via I2C
    status = i2c_write(AI_HAT_I2C_ADDR, cmd_buffer, len + 2);
    if (status != I2C_SUCCESS) {
        uart_puts("Failed to send command to AI HAT+\n");
        return AI_HAT_ERROR_COMM;
    }
    
    return AI_HAT_SUCCESS;
}

// Read data from AI HAT+ via I2C
static ai_hat_status_t read_data(uint8_t reg, uint8_t* data, uint32_t len) {
    i2c_status_t status;
    
    // Send register address
    status = i2c_write(AI_HAT_I2C_ADDR, &reg, 1);
    if (status != I2C_SUCCESS) {
        uart_puts("Failed to send register address to AI HAT+\n");
        return AI_HAT_ERROR_COMM;
    }
    
    // Read data
    status = i2c_read(AI_HAT_I2C_ADDR, data, len);
    if (status != I2C_SUCCESS) {
        uart_puts("Failed to read data from AI HAT+\n");
        return AI_HAT_ERROR_COMM;
    }
    
    // For simulation purposes, override with simulated data
    // In a real implementation, this would be removed
    if (reg == AI_HAT_REG_VERSION) {
        // Simulate version information
        data[0] = 1; // Version 1.0
        data[1] = 0;
    } else if (reg == AI_HAT_REG_TEMP) {
        // Simulate temperature reading (45°C)
        data[0] = 45;
    } else if (reg == AI_HAT_REG_POWER) {
        // Simulate power consumption (1200mW)
        data[0] = 1200 & 0xFF;
        data[1] = (1200 >> 8) & 0xFF;
    }
    
    return AI_HAT_SUCCESS;
}

// Transfer data to/from AI HAT+ via SPI
static ai_hat_status_t __attribute__((unused)) transfer_data(uint8_t* tx_data, uint8_t* rx_data, uint32_t len) {
    spi_status_t status;
    
    // Transfer data via SPI
    status = spi_transfer(tx_data, rx_data, len);
    if (status != SPI_SUCCESS) {
        uart_puts("Failed to transfer data to/from AI HAT+\n");
        return AI_HAT_ERROR_COMM;
    }
    
    return AI_HAT_SUCCESS;
}

// Initialize the AI HAT+
ai_hat_status_t ai_hat_init(void) {
    ai_hat_status_t status;
    
    // Check if already initialized
    if (ai_hat_initialized) {
        return AI_HAT_SUCCESS;
    }
    
    uart_puts("Initializing AI HAT+...\n");
    
    // Initialize I2C
    status = init_i2c();
    if (status != AI_HAT_SUCCESS) {
        uart_puts("Failed to initialize I2C\n");
        return status;
    }
    
    // Initialize SPI
    status = init_spi();
    if (status != AI_HAT_SUCCESS) {
        uart_puts("Failed to initialize SPI\n");
        return status;
    }
    
    // Send initialization command to AI HAT+
    status = send_command(AI_HAT_REG_CONTROL, AI_HAT_CMD_INIT, NULL, 0);
    if (status != AI_HAT_SUCCESS) {
        uart_puts("Failed to initialize AI HAT+\n");
        return status;
    }
    
    // Read version information
    uint8_t version[2];
    status = read_data(AI_HAT_REG_VERSION, version, 2);
    if (status != AI_HAT_SUCCESS) {
        uart_puts("Failed to read AI HAT+ version\n");
        return status;
    }
    
    // Initialize AI HAT+ information
    ai_hat_info.version = (version[0] << 8) | version[1];
    ai_hat_info.max_tops = 26; // 26 TOPS for AI HAT+
    ai_hat_info.memory_size = 4 * 1024 * 1024; // 4GB in MB to avoid overflow
    ai_hat_info.power_mode = AI_HAT_POWER_MEDIUM;
    
    // Read initial temperature and power consumption
    uint8_t temp;
    status = read_data(AI_HAT_REG_TEMP, &temp, 1);
    if (status == AI_HAT_SUCCESS) {
        ai_hat_info.temperature = temp;
    }
    
    uint8_t power[2];
    status = read_data(AI_HAT_REG_POWER, power, 2);
    if (status == AI_HAT_SUCCESS) {
        ai_hat_info.power_consumption = (power[1] << 8) | power[0];
    }
    
    // Initialize model list
    num_loaded_models = 0;
    
    ai_hat_initialized = true;
    uart_puts("AI HAT+ initialized successfully\n");
    
    return AI_HAT_SUCCESS;
}

// Get AI HAT+ information
ai_hat_status_t ai_hat_get_info(ai_hat_info_t* info) {
    if (!ai_hat_initialized) {
        return AI_HAT_ERROR_INIT;
    }
    
    if (info == NULL) {
        return AI_HAT_ERROR_PARAM;
    }
    
    // Update temperature and power consumption
    uint8_t temp;
    ai_hat_status_t status = read_data(AI_HAT_REG_TEMP, &temp, 1);
    if (status == AI_HAT_SUCCESS) {
        ai_hat_info.temperature = temp;
    }
    
    uint8_t power[2];
    status = read_data(AI_HAT_REG_POWER, power, 2);
    if (status == AI_HAT_SUCCESS) {
        ai_hat_info.power_consumption = (power[1] << 8) | power[0];
    }
    
    // Copy information to output
    memcpy(info, &ai_hat_info, sizeof(ai_hat_info_t));
    
    return AI_HAT_SUCCESS;
}

// Set AI HAT+ power mode
ai_hat_status_t ai_hat_set_power_mode(ai_hat_power_mode_t mode) {
    if (!ai_hat_initialized) {
        return AI_HAT_ERROR_INIT;
    }
    
    if (mode < AI_HAT_POWER_OFF || mode > AI_HAT_POWER_MAX) {
        return AI_HAT_ERROR_PARAM;
    }
    
    // Send power mode command
    uint8_t data = mode;
    ai_hat_status_t status = send_command(AI_HAT_REG_CONTROL, AI_HAT_CMD_SET_POWER, &data, 1);
    if (status != AI_HAT_SUCCESS) {
        return status;
    }
    
    // Update local information
    ai_hat_info.power_mode = mode;
    
    return AI_HAT_SUCCESS;
}

// Get AI HAT+ temperature (in Celsius)
ai_hat_status_t ai_hat_get_temperature(uint32_t* temperature) {
    if (!ai_hat_initialized) {
        return AI_HAT_ERROR_INIT;
    }
    
    if (temperature == NULL) {
        return AI_HAT_ERROR_PARAM;
    }
    
    // Read temperature
    uint8_t temp;
    ai_hat_status_t status = read_data(AI_HAT_REG_TEMP, &temp, 1);
    if (status != AI_HAT_SUCCESS) {
        return status;
    }
    
    // Update local information and output
    ai_hat_info.temperature = temp;
    *temperature = temp;
    
    return AI_HAT_SUCCESS;
}

// Get AI HAT+ power consumption (in mW)
ai_hat_status_t ai_hat_get_power_consumption(uint32_t* power) {
    if (!ai_hat_initialized) {
        return AI_HAT_ERROR_INIT;
    }
    
    if (power == NULL) {
        return AI_HAT_ERROR_PARAM;
    }
    
    // Read power consumption
    uint8_t power_data[2];
    ai_hat_status_t status = read_data(AI_HAT_REG_POWER, power_data, 2);
    if (status != AI_HAT_SUCCESS) {
        return status;
    }
    
    // Update local information and output
    ai_hat_info.power_consumption = (power_data[1] << 8) | power_data[0];
    *power = ai_hat_info.power_consumption;
    
    return AI_HAT_SUCCESS;
}

// Load a model to the AI HAT+
ai_hat_status_t ai_hat_load_model(const void* model_data, uint32_t model_size, uint32_t* model_id) {
    if (!ai_hat_initialized) {
        return AI_HAT_ERROR_INIT;
    }
    
    if (model_data == NULL || model_id == NULL || model_size == 0) {
        return AI_HAT_ERROR_PARAM;
    }
    
    if (num_loaded_models >= 8) {
        return AI_HAT_ERROR_MEMORY;
    }
    
    // TODO: Implement actual model loading via SPI
    // This is a placeholder for actual model loading code
    
    // For now, we'll simulate successful model loading
    *model_id = num_loaded_models + 1;
    
    // Add model to list
    ai_hat_model_t* model = &loaded_models[num_loaded_models];
    model->id = *model_id;
    model->size = model_size;
    model->precision = AI_HAT_PRECISION_FP16; // Default precision
    model->input_size = 1024; // Example input size
    model->output_size = 1000; // Example output size
    
    // Use a safer method than sprintf to create model name
    char name_prefix[] = "Model_";
    memcpy(model->name, name_prefix, sizeof(name_prefix) - 1);
    
    // Convert model ID to string
    char id_str[8];
    int i = 0;
    uint32_t id_copy = *model_id;
    do {
        id_str[i++] = '0' + (id_copy % 10);
        id_copy /= 10;
    } while (id_copy > 0 && i < 7);
    id_str[i] = '\0';
    
    // Reverse the digits
    for (int j = 0; j < i/2; j++) {
        char temp = id_str[j];
        id_str[j] = id_str[i-j-1];
        id_str[i-j-1] = temp;
    }
    
    // Append to name (ensuring we don't overflow)
    size_t prefix_len = sizeof(name_prefix) - 1;
    size_t id_len = i;
    if (prefix_len + id_len < sizeof(model->name)) {
        memcpy(model->name + prefix_len, id_str, id_len + 1);
    }
    
    num_loaded_models++;
    
    return AI_HAT_SUCCESS;
}

// Unload a model from the AI HAT+
ai_hat_status_t ai_hat_unload_model(uint32_t model_id) {
    if (!ai_hat_initialized) {
        return AI_HAT_ERROR_INIT;
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
        return AI_HAT_ERROR_PARAM;
    }
    
    // TODO: Implement actual model unloading
    // This is a placeholder for actual model unloading code
    
    // Remove model from list by shifting remaining models
    for (uint32_t i = model_index; i < num_loaded_models - 1; i++) {
        loaded_models[i] = loaded_models[i + 1];
    }
    
    num_loaded_models--;
    
    return AI_HAT_SUCCESS;
}

// Run inference on a loaded model
ai_hat_status_t ai_hat_run_inference(uint32_t model_id, const void* input, uint32_t input_size, void* output, uint32_t output_size) {
    if (!ai_hat_initialized) {
        return AI_HAT_ERROR_INIT;
    }
    
    if (input == NULL || output == NULL) {
        return AI_HAT_ERROR_PARAM;
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
        return AI_HAT_ERROR_PARAM;
    }
    
    // Check input and output sizes
    if (input_size != loaded_models[model_index].input_size ||
        output_size != loaded_models[model_index].output_size) {
        return AI_HAT_ERROR_PARAM;
    }
    
    // TODO: Implement actual inference via SPI
    // This is a placeholder for actual inference code
    
    // For now, we'll simulate successful inference with dummy output
    memset(output, 0, output_size);
    
    return AI_HAT_SUCCESS;
}

// Get list of loaded models
ai_hat_status_t ai_hat_get_models(ai_hat_model_t* models, uint32_t max_models, uint32_t* num_models) {
    if (!ai_hat_initialized) {
        return AI_HAT_ERROR_INIT;
    }
    
    if (models == NULL || num_models == NULL || max_models == 0) {
        return AI_HAT_ERROR_PARAM;
    }
    
    // Copy models to output
    uint32_t count = (num_loaded_models < max_models) ? num_loaded_models : max_models;
    for (uint32_t i = 0; i < count; i++) {
        models[i] = loaded_models[i];
    }
    
    *num_models = count;
    
    return AI_HAT_SUCCESS;
}

// Shutdown the AI HAT+
void ai_hat_shutdown(void) {
    if (!ai_hat_initialized) {
        return;
    }
    
    // Send shutdown command
    send_command(AI_HAT_REG_CONTROL, AI_HAT_CMD_SHUTDOWN, NULL, 0);
    
    ai_hat_initialized = false;
}