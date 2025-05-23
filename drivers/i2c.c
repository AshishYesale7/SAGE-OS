// ─────────────────────────────────────────────────────────────────────────────
// SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
// SPDX-License-Identifier: BSD-3-Clause OR Proprietary
// SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
// 
// This file is part of the SAGE OS Project.
//
// ─────────────────────────────────────────────────────────────────────────────
#include "i2c.h"
#include "uart.h"

// Raspberry Pi 5 I2C registers
#define RPI5_PERIPHERAL_BASE 0xFE000000

// I2C registers
#define I2C_BASE            (RPI5_PERIPHERAL_BASE + 0x804000)
#define I2C_C               ((volatile uint32_t*)(I2C_BASE + 0x00))
#define I2C_S               ((volatile uint32_t*)(I2C_BASE + 0x04))
#define I2C_DLEN            ((volatile uint32_t*)(I2C_BASE + 0x08))
#define I2C_A               ((volatile uint32_t*)(I2C_BASE + 0x0C))
#define I2C_FIFO            ((volatile uint32_t*)(I2C_BASE + 0x10))
#define I2C_DIV             ((volatile uint32_t*)(I2C_BASE + 0x14))
#define I2C_DEL             ((volatile uint32_t*)(I2C_BASE + 0x18))
#define I2C_CLKT            ((volatile uint32_t*)(I2C_BASE + 0x1C))

// I2C control register bits
#define I2C_C_I2CEN         (1 << 15)
#define I2C_C_INTR          (1 << 10)
#define I2C_C_INTT          (1 << 9)
#define I2C_C_INTD          (1 << 8)
#define I2C_C_ST            (1 << 7)
#define I2C_C_CLEAR         (1 << 4)
#define I2C_C_READ          (1 << 0)

// I2C status register bits
#define I2C_S_CLKT          (1 << 9)
#define I2C_S_ERR           (1 << 8)
#define I2C_S_RXF           (1 << 7)
#define I2C_S_TXE           (1 << 6)
#define I2C_S_RXD           (1 << 5)
#define I2C_S_TXD           (1 << 4)
#define I2C_S_RXR           (1 << 3)
#define I2C_S_TXW           (1 << 2)
#define I2C_S_DONE          (1 << 1)
#define I2C_S_TA            (1 << 0)

// I2C clock divider
#define I2C_CLOCK_FREQ      150000000  // 150 MHz

// Static variables
static bool i2c_initialized = false;

// Delay function - simple busy wait
static void delay(int32_t count) {
    while (count--) {
        asm volatile("nop");
    }
}

// Wait for I2C transfer to complete
static i2c_status_t i2c_wait_done() {
    int timeout = 1000000;  // Timeout in microseconds
    
    while (!(*I2C_S & I2C_S_DONE)) {
        if (--timeout <= 0) {
            return I2C_ERROR_TIMEOUT;
        }
        
        if (*I2C_S & I2C_S_ERR) {
            return I2C_ERROR_NACK;
        }
        
        if (*I2C_S & I2C_S_CLKT) {
            return I2C_ERROR_TIMEOUT;
        }
        
        delay(10);
    }
    
    return I2C_SUCCESS;
}

// Initialize I2C controller
i2c_status_t i2c_init(i2c_speed_t speed) {
    // Check if already initialized
    if (i2c_initialized) {
        return I2C_SUCCESS;
    }
    
    uart_puts("Initializing I2C...\n");
    
    // Calculate clock divider
    uint32_t divider = I2C_CLOCK_FREQ / speed;
    
    // Reset I2C controller
    *I2C_C = 0;
    delay(100);
    
    // Clear status
    *I2C_S = I2C_S_CLKT | I2C_S_ERR | I2C_S_DONE;
    
    // Set clock divider
    *I2C_DIV = divider;
    
    // Enable I2C controller
    *I2C_C = I2C_C_I2CEN;
    
    i2c_initialized = true;
    uart_printf("I2C initialized at %d Hz\n", speed);
    
    return I2C_SUCCESS;
}

// Write data to I2C device
i2c_status_t i2c_write(uint8_t device_addr, const uint8_t* data, uint32_t len) {
    if (!i2c_initialized) {
        return I2C_ERROR_INIT;
    }
    
    if (data == NULL || len == 0) {
        return I2C_ERROR_PARAM;
    }
    
    // Wait if I2C is busy
    if (*I2C_S & I2C_S_TA) {
        return I2C_ERROR_BUSY;
    }
    
    // Clear FIFO
    *I2C_C = I2C_C_I2CEN | I2C_C_CLEAR;
    
    // Clear status
    *I2C_S = I2C_S_CLKT | I2C_S_ERR | I2C_S_DONE;
    
    // Set slave address
    *I2C_A = device_addr;
    
    // Set data length
    *I2C_DLEN = len;
    
    // Fill FIFO with data (up to 16 bytes)
    uint32_t fifo_count = (len > 16) ? 16 : len;
    for (uint32_t i = 0; i < fifo_count; i++) {
        *I2C_FIFO = data[i];
    }
    
    // Start transfer (write)
    *I2C_C = I2C_C_I2CEN | I2C_C_ST;
    
    // Send remaining data
    uint32_t sent = fifo_count;
    while (sent < len) {
        // Wait for space in FIFO
        while (!(*I2C_S & I2C_S_TXW)) {
            if (*I2C_S & I2C_S_ERR) {
                return I2C_ERROR_NACK;
            }
            
            if (*I2C_S & I2C_S_CLKT) {
                return I2C_ERROR_TIMEOUT;
            }
            
            if (*I2C_S & I2C_S_DONE) {
                break;
            }
        }
        
        // Send data
        *I2C_FIFO = data[sent++];
    }
    
    // Wait for transfer to complete
    return i2c_wait_done();
}

// Read data from I2C device
i2c_status_t i2c_read(uint8_t device_addr, uint8_t* data, uint32_t len) {
    if (!i2c_initialized) {
        return I2C_ERROR_INIT;
    }
    
    if (data == NULL || len == 0) {
        return I2C_ERROR_PARAM;
    }
    
    // Wait if I2C is busy
    if (*I2C_S & I2C_S_TA) {
        return I2C_ERROR_BUSY;
    }
    
    // Clear FIFO
    *I2C_C = I2C_C_I2CEN | I2C_C_CLEAR;
    
    // Clear status
    *I2C_S = I2C_S_CLKT | I2C_S_ERR | I2C_S_DONE;
    
    // Set slave address
    *I2C_A = device_addr;
    
    // Set data length
    *I2C_DLEN = len;
    
    // Start transfer (read)
    *I2C_C = I2C_C_I2CEN | I2C_C_ST | I2C_C_READ;
    
    // Read data
    uint32_t received = 0;
    while (received < len) {
        // Wait for data in FIFO
        while (!(*I2C_S & I2C_S_RXD)) {
            if (*I2C_S & I2C_S_ERR) {
                return I2C_ERROR_NACK;
            }
            
            if (*I2C_S & I2C_S_CLKT) {
                return I2C_ERROR_TIMEOUT;
            }
            
            if (*I2C_S & I2C_S_DONE) {
                break;
            }
        }
        
        // Read data
        data[received++] = *I2C_FIFO;
    }
    
    // Wait for transfer to complete
    return i2c_wait_done();
}

// Write register and then read data from I2C device
i2c_status_t i2c_write_read(uint8_t device_addr, const uint8_t* write_data, uint32_t write_len, uint8_t* read_data, uint32_t read_len) {
    i2c_status_t status;
    
    // Write data
    status = i2c_write(device_addr, write_data, write_len);
    if (status != I2C_SUCCESS) {
        return status;
    }
    
    // Read data
    status = i2c_read(device_addr, read_data, read_len);
    
    return status;
}

// Write register to I2C device
i2c_status_t i2c_write_reg(uint8_t device_addr, uint8_t reg, uint8_t value) {
    uint8_t data[2] = {reg, value};
    return i2c_write(device_addr, data, 2);
}

// Read register from I2C device
i2c_status_t i2c_read_reg(uint8_t device_addr, uint8_t reg, uint8_t* value) {
    i2c_status_t status;
    
    // Write register address
    status = i2c_write(device_addr, &reg, 1);
    if (status != I2C_SUCCESS) {
        return status;
    }
    
    // Read register value
    status = i2c_read(device_addr, value, 1);
    
    return status;
}

// Scan I2C bus for devices
i2c_status_t i2c_scan(uint8_t* devices, uint32_t max_devices, uint32_t* num_devices) {
    if (!i2c_initialized) {
        return I2C_ERROR_INIT;
    }
    
    if (devices == NULL || num_devices == NULL || max_devices == 0) {
        return I2C_ERROR_PARAM;
    }
    
    *num_devices = 0;
    
    // Scan all possible addresses (0x08 to 0x77)
    for (uint8_t addr = 0x08; addr <= 0x77; addr++) {
        // Skip reserved addresses
        // Note: We're already starting at 0x08, so this check is redundant
        // if (addr >= 0x00 && addr <= 0x07) continue;
        if (addr >= 0x78 && addr <= 0x7F) continue;
        
        // Try to write to device
        uint8_t dummy = 0;
        i2c_status_t status = i2c_write(addr, &dummy, 0);
        
        if (status == I2C_SUCCESS) {
            // Device found
            if (*num_devices < max_devices) {
                devices[*num_devices] = addr;
                (*num_devices)++;
            }
        }
    }
    
    return I2C_SUCCESS;
}