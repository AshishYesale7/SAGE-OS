# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# Multi-architecture Dockerfile for SAGE OS
ARG TARGETARCH
ARG TARGETPLATFORM

# Base image selection based on architecture
FROM --platform=$TARGETPLATFORM ubuntu:22.04 as base

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV SAGE_OS_VERSION=0.1.0
ENV SAGE_OS_ARCH=${TARGETARCH}

# Install base dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    g++ \
    make \
    nasm \
    qemu-system \
    genisoimage \
    xorriso \
    mtools \
    dosfstools \
    grub-pc-bin \
    grub-efi-amd64-bin \
    curl \
    wget \
    git \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Architecture-specific toolchain installation
RUN case "${TARGETARCH}" in \
    "amd64") \
        echo "Installing x86_64 toolchain" && \
        apt-get update && apt-get install -y gcc-multilib g++-multilib \
        ;; \
    "arm64") \
        echo "Installing ARM64 toolchain" && \
        apt-get update && apt-get install -y gcc-aarch64-linux-gnu g++-aarch64-linux-gnu \
        ;; \
    "arm") \
        echo "Installing ARM toolchain" && \
        apt-get update && apt-get install -y gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf \
        ;; \
    "riscv64") \
        echo "Installing RISC-V toolchain" && \
        apt-get update && apt-get install -y gcc-riscv64-linux-gnu g++-riscv64-linux-gnu \
        ;; \
    *) \
        echo "Unknown architecture: ${TARGETARCH}" \
        ;; \
    esac && \
    rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /sage-os

# Copy source code
COPY . .

# Create build directory structure
RUN mkdir -p build/${TARGETARCH} dist/${TARGETARCH}

# Build stage
FROM base as builder

# Set architecture-specific build variables
ENV ARCH=${TARGETARCH}
ENV CROSS_COMPILE=""

# Set cross-compilation variables based on architecture
RUN case "${TARGETARCH}" in \
    "amd64") \
        echo "export ARCH=x86_64" >> /etc/environment && \
        echo "export CROSS_COMPILE=" >> /etc/environment \
        ;; \
    "arm64") \
        echo "export ARCH=aarch64" >> /etc/environment && \
        echo "export CROSS_COMPILE=aarch64-linux-gnu-" >> /etc/environment \
        ;; \
    "arm") \
        echo "export ARCH=arm" >> /etc/environment && \
        echo "export CROSS_COMPILE=arm-linux-gnueabihf-" >> /etc/environment \
        ;; \
    "riscv64") \
        echo "export ARCH=riscv64" >> /etc/environment && \
        echo "export CROSS_COMPILE=riscv64-linux-gnu-" >> /etc/environment \
        ;; \
    esac

# Build SAGE OS (mock build for now)
RUN echo "Building SAGE OS for ${TARGETARCH}" && \
    mkdir -p build/${TARGETARCH} && \
    echo "SAGE OS Kernel ${SAGE_OS_VERSION} for ${TARGETARCH}" > build/${TARGETARCH}/kernel.img && \
    echo "SAGE OS ELF ${SAGE_OS_VERSION} for ${TARGETARCH}" > build/${TARGETARCH}/kernel.elf && \
    echo "SAGE OS Map ${SAGE_OS_VERSION} for ${TARGETARCH}" > build/${TARGETARCH}/kernel.map && \
    ls -la build/${TARGETARCH}/

# Runtime stage
FROM ubuntu:22.04 as runtime

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    qemu-system \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Create sage user
RUN useradd -m -s /bin/bash sage && \
    mkdir -p /home/sage/sage-os

# Copy built artifacts
COPY --from=builder /sage-os/build /home/sage/sage-os/build
COPY --from=builder /sage-os/config* /home/sage/sage-os/ 2>/dev/null || true
COPY --from=builder /sage-os/scripts /home/sage/sage-os/scripts 2>/dev/null || true

# Set ownership
RUN chown -R sage:sage /home/sage/sage-os

# Switch to sage user
USER sage
WORKDIR /home/sage/sage-os

# Set environment variables
ENV SAGE_OS_VERSION=0.1.0
ENV SAGE_OS_HOME=/home/sage/sage-os

# Expose any necessary ports (if SAGE OS has network services)
EXPOSE 8080 8443

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD ls build/ || exit 1

# Default command
CMD ["bash", "-c", "echo 'SAGE OS Container Ready' && echo 'Available builds:' && ls -la build/ && bash"]

# Labels for metadata
LABEL org.opencontainers.image.title="SAGE OS"
LABEL org.opencontainers.image.description="SAGE OS - Advanced Operating System with AI Integration"
LABEL org.opencontainers.image.version="${SAGE_OS_VERSION}"
LABEL org.opencontainers.image.authors="Ashish Vasant Yesale <ashishyesale007@gmail.com>"
LABEL org.opencontainers.image.url="https://github.com/AshishYesale7/SAGE-OS"
LABEL org.opencontainers.image.source="https://github.com/AshishYesale7/SAGE-OS"
LABEL org.opencontainers.image.licenses="BSD-3-Clause OR Proprietary"
LABEL org.opencontainers.image.vendor="SAGE OS Project"