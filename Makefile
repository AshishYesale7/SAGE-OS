# Default architecture is aarch64
ARCH ?= aarch64

# Set up cross-compilation toolchain based on architecture
ifeq ($(ARCH),x86_64)
    CROSS_COMPILE=x86_64-linux-gnu-
else ifeq ($(ARCH),arm64)
    CROSS_COMPILE=aarch64-linux-gnu-
else ifeq ($(ARCH),aarch64)
    CROSS_COMPILE=aarch64-linux-gnu-
else ifeq ($(ARCH),riscv64)
    CROSS_COMPILE=riscv64-linux-gnu-
else
    $(error Unsupported architecture: $(ARCH))
endif

CC=$(CROSS_COMPILE)gcc
LD=$(CROSS_COMPILE)ld
OBJCOPY=$(CROSS_COMPILE)objcopy

# Include paths
INCLUDES=-I. -Ikernel -Idrivers

# Architecture-specific flags
ifeq ($(ARCH),x86_64)
    ARCH_FLAGS=-m64
else ifeq ($(ARCH),arm64)
    ARCH_FLAGS=
else ifeq ($(ARCH),aarch64)
    ARCH_FLAGS=
else ifeq ($(ARCH),riscv64)
    ARCH_FLAGS=
endif

CFLAGS=-nostdlib -nostartfiles -ffreestanding -O2 -Wall -Wextra $(ARCH_FLAGS) $(INCLUDES)
LDFLAGS=-T linker.ld

# Create build directory for architecture
BUILD_DIR=build/$(ARCH)

# Source files
BOOT_SOURCES = $(wildcard boot/*.S)
KERNEL_SOURCES = $(wildcard kernel/*.c) $(wildcard kernel/*/*.c)
DRIVER_SOURCES = $(wildcard drivers/*.c) $(wildcard drivers/*/*.c)

SOURCES = $(BOOT_SOURCES) $(KERNEL_SOURCES) $(DRIVER_SOURCES)
OBJECTS = $(patsubst %.c,$(BUILD_DIR)/%.o,$(filter %.c,$(SOURCES)))
OBJECTS += $(patsubst %.S,$(BUILD_DIR)/%.o,$(filter %.S,$(SOURCES)))

all: $(BUILD_DIR)/kernel.img

# Create build directories
$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: %.S
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/kernel.elf: $(OBJECTS)
	@mkdir -p $(dir $@)
	$(LD) $(LDFLAGS) -o $@ $(OBJECTS)

$(BUILD_DIR)/kernel.img: $(BUILD_DIR)/kernel.elf
	$(OBJCOPY) -O binary $< $@
	@echo "Build completed for $(ARCH) architecture"
	@echo "Output: $@"

clean:
	rm -rf build/
	@echo "Cleaned build directories"

# Create all architecture builds
all-arch:
	$(MAKE) ARCH=x86_64
	$(MAKE) ARCH=aarch64
	$(MAKE) ARCH=riscv64

# Show build information
info:
	@echo "SAGE OS Build Information"
	@echo "------------------------"
	@echo "Compiler: $(CC)"
	@echo "Linker: $(LD)"
	@echo "Object Copy: $(OBJCOPY)"
	@echo "CFLAGS: $(CFLAGS)"
	@echo "LDFLAGS: $(LDFLAGS)"
	@echo "Source files: $(words $(SOURCES))"
	@echo "Object files: $(words $(OBJECTS))"
