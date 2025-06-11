# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────
cmake_minimum_required(VERSION 3.16)
project(SAGE_OS VERSION 0.1.0 LANGUAGES C CXX ASM)

# Set C standard
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Set C++ standard (for TensorFlow Lite)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Options
option(ENABLE_AI "Enable AI capabilities" OFF)
option(ENABLE_CRYPTO "Enable cryptography" ON)
option(TARGET_PLATFORM "Target platform" "rpi4")
option(ENABLE_AI_HAT_PLUS "Enable AI HAT+ support" OFF)
option(MEMORY_SIZE "Memory size in MB" 1024)

# Include directories
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/kernel/core
    ${CMAKE_CURRENT_SOURCE_DIR}/kernel/hal
    ${CMAKE_CURRENT_SOURCE_DIR}/kernel/drivers
    ${CMAKE_CURRENT_SOURCE_DIR}/security
)

# Platform-specific settings
if(TARGET_PLATFORM STREQUAL "rpi4")
    add_definitions(-DPLATFORM_RPI4)
    set(PLATFORM_SOURCES
        kernel/drivers/rpi4/uart.c
        kernel/drivers/rpi4/gpio.c
        kernel/drivers/rpi4/timer.c
    )
elseif(TARGET_PLATFORM STREQUAL "rpi5")
    add_definitions(-DPLATFORM_RPI5)
    set(PLATFORM_SOURCES
        kernel/drivers/rpi5/uart.c
        kernel/drivers/rpi5/gpio.c
        kernel/drivers/rpi5/timer.c
        boot/boot.S
    )
elseif(TARGET_PLATFORM STREQUAL "riscv")
    add_definitions(-DPLATFORM_RISCV)
    set(PLATFORM_SOURCES
        kernel/drivers/riscv/uart.c
        kernel/drivers/riscv/gpio.c
        kernel/drivers/riscv/timer.c
    )
elseif(TARGET_PLATFORM STREQUAL "x86_64")
    add_definitions(-DPLATFORM_X86_64)
    set(PLATFORM_SOURCES
        kernel/drivers/x86_64/uart.c
        kernel/drivers/x86_64/gpio.c
        kernel/drivers/x86_64/timer.c
    )
endif()

# Core C sources
set(CORE_SOURCES
    kernel/core/boot.c
    kernel/core/init.c
    kernel/hal/hal.c
)

# Cryptography sources
if(ENABLE_CRYPTO)
    add_definitions(-DENABLE_CRYPTO)
    set(CRYPTO_SOURCES
        security/crypto.c
        security/secure_boot.c
    )
endif()

# AI sources
if(ENABLE_AI)
    add_definitions(-DENABLE_AI)
    
    # Common AI sources
    set(AI_SOURCES
        ai/inference/tflite_wrapper.cc
        kernel/drivers/ai_hat.c
    )
    
    # Platform-specific AI sources
    if(TARGET_PLATFORM STREQUAL "rpi5")
        list(APPEND AI_SOURCES
            kernel/drivers/rpi5/i2c.c
            kernel/drivers/rpi5/spi.c
        )
        add_definitions(-DENABLE_AI_HAT_PLUS)
        message(STATUS "Enabling AI HAT+ support for Raspberry Pi 5")
    endif()
    
    # TensorFlow Lite Micro
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/external/tensorflow-lite-micro/CMakeLists.txt")
        add_subdirectory(external/tensorflow-lite-micro)
        include_directories(${TFLM_INCLUDE_DIRS})
    else()
        message(WARNING "TensorFlow Lite Micro not found, AI capabilities will be limited")
    endif()
endif()

# Combine all sources
set(ALL_SOURCES
    ${CORE_SOURCES}
    ${PLATFORM_SOURCES}
    ${CRYPTO_SOURCES}
    ${AI_SOURCES}
)

# Rust library integration
add_custom_target(rust_lib
    COMMAND cargo build --release
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Building Rust library"
)

# Create the kernel executable
add_executable(kernel.elf ${ALL_SOURCES})
add_dependencies(kernel.elf rust_lib)

# Link with the Rust static library
target_link_libraries(kernel.elf
    ${CMAKE_CURRENT_SOURCE_DIR}/target/release/libsage_os.a
)

if(ENABLE_AI)
    target_link_libraries(kernel.elf tensorflow-lite-micro)
endif()

# Create the binary image
add_custom_command(TARGET kernel.elf POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O binary kernel.elf kernel8.img
    COMMENT "Creating binary image"
)

# Install
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/kernel8.img
    DESTINATION ${CMAKE_INSTALL_PREFIX}
)

# Documentation
add_custom_target(docs
    COMMAND cargo doc --no-deps
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Generating Rust documentation"
)

# Testing
enable_testing()
add_subdirectory(tests)