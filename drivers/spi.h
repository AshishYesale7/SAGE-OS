/* ─────────────────────────────────────────────────────────────────────────────
 * SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
 * SPDX-License-Identifier: BSD-3-Clause OR Proprietary
 * SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
 * 
 * This file is part of the SAGE OS Project.
 *
 * ───────────────────────────────────────────────────────────────────────────── */
#ifndef SPI_H
#define SPI_H

#include "../kernel/types.h"

// SPI status codes
typedef enum {
    SPI_SUCCESS = 0,
    SPI_ERROR_INIT = -1,
    SPI_ERROR_BUSY = -2,
    SPI_ERROR_TIMEOUT = -3,
    SPI_ERROR_PARAM = -4
} spi_status_t;

// SPI clock polarity
typedef enum {
    SPI_CPOL_0 = 0,  // Clock idle low
    SPI_CPOL_1 = 1   // Clock idle high
} spi_cpol_t;

// SPI clock phase
typedef enum {
    SPI_CPHA_0 = 0,  // Sample on first edge
    SPI_CPHA_1 = 1   // Sample on second edge
} spi_cpha_t;

// SPI chip select polarity
typedef enum {
    SPI_CS_POL_LOW = 0,   // CS active low
    SPI_CS_POL_HIGH = 1   // CS active high
} spi_cs_pol_t;

// SPI configuration
typedef struct {
    uint32_t clock_speed;  // Clock speed in Hz
    spi_cpol_t cpol;       // Clock polarity
    spi_cpha_t cpha;       // Clock phase
    spi_cs_pol_t cs_pol;   // Chip select polarity
    uint8_t cs_pin;        // Chip select pin (0-2)
    uint8_t bits_per_word; // Bits per word (8-16)
} spi_config_t;

// Initialize SPI controller
spi_status_t spi_init(const spi_config_t* config);

// Transfer data over SPI (simultaneous read/write)
spi_status_t spi_transfer(const uint8_t* tx_data, uint8_t* rx_data, uint32_t len);

// Write data over SPI (ignore received data)
spi_status_t spi_write(const uint8_t* tx_data, uint32_t len);

// Read data over SPI (send zeros)
spi_status_t spi_read(uint8_t* rx_data, uint32_t len);

// Write command and then read data over SPI
spi_status_t spi_write_read(const uint8_t* tx_data, uint32_t tx_len, uint8_t* rx_data, uint32_t rx_len);

// Set SPI clock speed
spi_status_t spi_set_clock_speed(uint32_t clock_speed);

// Set SPI mode (CPOL and CPHA)
spi_status_t spi_set_mode(spi_cpol_t cpol, spi_cpha_t cpha);

#endif // SPI_H