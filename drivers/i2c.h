/* ─────────────────────────────────────────────────────────────────────────────
 * SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
 * SPDX-License-Identifier: BSD-3-Clause OR Proprietary
 * SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
 * 
 * This file is part of the SAGE OS Project.
 *
 * ───────────────────────────────────────────────────────────────────────────── */
#ifndef I2C_H
#define I2C_H

#include "../kernel/types.h"

// I2C status codes
typedef enum {
    I2C_SUCCESS = 0,
    I2C_ERROR_INIT = -1,
    I2C_ERROR_BUSY = -2,
    I2C_ERROR_NACK = -3,
    I2C_ERROR_TIMEOUT = -4,
    I2C_ERROR_PARAM = -5
} i2c_status_t;

// I2C bus speed
typedef enum {
    I2C_SPEED_STANDARD = 100000,  // 100 kHz
    I2C_SPEED_FAST = 400000,      // 400 kHz
    I2C_SPEED_FAST_PLUS = 1000000 // 1 MHz
} i2c_speed_t;

// Initialize I2C controller
i2c_status_t i2c_init(i2c_speed_t speed);

// Write data to I2C device
i2c_status_t i2c_write(uint8_t device_addr, const uint8_t* data, uint32_t len);

// Read data from I2C device
i2c_status_t i2c_read(uint8_t device_addr, uint8_t* data, uint32_t len);

// Write register and then read data from I2C device
i2c_status_t i2c_write_read(uint8_t device_addr, const uint8_t* write_data, uint32_t write_len, uint8_t* read_data, uint32_t read_len);

// Write register to I2C device
i2c_status_t i2c_write_reg(uint8_t device_addr, uint8_t reg, uint8_t value);

// Read register from I2C device
i2c_status_t i2c_read_reg(uint8_t device_addr, uint8_t reg, uint8_t* value);

// Scan I2C bus for devices
i2c_status_t i2c_scan(uint8_t* devices, uint32_t max_devices, uint32_t* num_devices);

#endif // I2C_H