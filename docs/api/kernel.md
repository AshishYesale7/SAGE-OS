# Kernel API Reference

Comprehensive API documentation for SAGE-OS kernel functions and system calls.

*Last updated: 2025-06-14*

## Overview

SAGE-OS provides a comprehensive kernel API for system programming, driver development, and AI integration. This documentation covers all public kernel functions, system calls, and interfaces.

## Core Kernel Functions

### Memory Management

#### `void* kmalloc(size_t size)`

Allocates kernel memory.

**Parameters:**
- `size`: Number of bytes to allocate

**Returns:** Pointer to allocated memory, or NULL on failure

**Example:**
```c
void* buffer = kmalloc(1024);
if (buffer) {
    // Use buffer
    kfree(buffer);
}
```

#### `void kfree(void* ptr)`

Frees kernel memory allocated with kmalloc.

**Parameters:**
- `ptr`: Pointer to memory to free

**Example:**
```c
void* buffer = kmalloc(1024);
// ... use buffer ...
kfree(buffer);
```

#### `void* vmalloc(size_t size)`

Allocates virtual memory.

**Parameters:**
- `size`: Number of bytes to allocate

**Returns:** Pointer to allocated virtual memory

**Example:**
```c
void* vbuffer = vmalloc(4096);
if (vbuffer) {
    // Use virtual buffer
    vfree(vbuffer);
}
```

### Process Management

#### `pid_t create_process(const char* name, void (*entry_point)(void))`

Creates a new process.

**Parameters:**
- `name`: Process name
- `entry_point`: Function to execute

**Returns:** Process ID (PID) or -1 on error

**Example:**
```c
void my_process(void) {
    // Process code here
}

pid_t pid = create_process("my_process", my_process);
```

#### `void schedule(void)`

Triggers the process scheduler.

**Example:**
```c
// Yield CPU to other processes
schedule();
```

#### `void exit_process(int status)`

Terminates the current process.

**Parameters:**
- `status`: Exit status code

**Example:**
```c
// Exit with success
exit_process(0);
```

### Interrupt Handling

#### `void register_interrupt_handler(int irq, void (*handler)(void))`

Registers an interrupt handler.

**Parameters:**
- `irq`: Interrupt request number
- `handler`: Function to handle the interrupt

**Example:**
```c
void timer_handler(void) {
    // Handle timer interrupt
}

register_interrupt_handler(0, timer_handler);
```

#### `void enable_interrupts(void)`

Enables hardware interrupts.

**Example:**
```c
enable_interrupts();
```

#### `void disable_interrupts(void)`

Disables hardware interrupts.

**Example:**
```c
disable_interrupts();
// Critical section
enable_interrupts();
```

## Device Driver API

### VGA Graphics

#### `void vga_init(void)`

Initializes the VGA graphics system.

**Example:**
```c
vga_init();
```

#### `void vga_putchar(char c)`

Displays a character on screen.

**Parameters:**
- `c`: Character to display

**Example:**
```c
vga_putchar('A');
```

#### `void vga_puts(const char* str)`

Displays a string on screen.

**Parameters:**
- `str`: Null-terminated string to display

**Example:**
```c
vga_puts("Hello, SAGE-OS!");
```

#### `void vga_clear_screen(void)`

Clears the screen.

**Example:**
```c
vga_clear_screen();
```

#### `void vga_set_color(uint8_t fg, uint8_t bg)`

Sets text foreground and background colors.

**Parameters:**
- `fg`: Foreground color (0-15)
- `bg`: Background color (0-15)

**Example:**
```c
vga_set_color(VGA_COLOR_WHITE, VGA_COLOR_BLUE);
```

### Serial Communication

#### `void serial_init(void)`

Initializes serial communication.

**Example:**
```c
serial_init();
```

#### `void serial_putchar(char c)`

Sends a character via serial port.

**Parameters:**
- `c`: Character to send

**Example:**
```c
serial_putchar('X');
```

#### `char serial_getchar(void)`

Receives a character from serial port.

**Returns:** Received character

**Example:**
```c
char c = serial_getchar();
```

#### `void serial_puts(const char* str)`

Sends a string via serial port.

**Parameters:**
- `str`: Null-terminated string to send

**Example:**
```c
serial_puts("Debug message\n");
```

### Keyboard Input

#### `void keyboard_init(void)`

Initializes keyboard driver.

**Example:**
```c
keyboard_init();
```

#### `char keyboard_getchar(void)`

Gets a character from keyboard input.

**Returns:** Pressed key character

**Example:**
```c
char key = keyboard_getchar();
```

#### `bool keyboard_key_pressed(uint8_t scancode)`

Checks if a specific key is pressed.

**Parameters:**
- `scancode`: Key scancode to check

**Returns:** True if key is pressed

**Example:**
```c
if (keyboard_key_pressed(SCANCODE_ENTER)) {
    // Handle Enter key
}
```

## AI Subsystem API

### AI Core Functions

#### `int ai_init(void)`

Initializes the AI subsystem.

**Returns:** 0 on success, -1 on error

**Example:**
```c
if (ai_init() == 0) {
    // AI subsystem ready
}
```

#### `int ai_process_command(const char* command, char* response, size_t response_size)`

Processes an AI command.

**Parameters:**
- `command`: Input command string
- `response`: Buffer for AI response
- `response_size`: Size of response buffer

**Returns:** 0 on success, -1 on error

**Example:**
```c
char response[256];
int result = ai_process_command("What is SAGE-OS?", response, sizeof(response));
if (result == 0) {
    printf("AI Response: %s\n", response);
}
```

#### `int ai_load_model(const char* model_name)`

Loads an AI model.

**Parameters:**
- `model_name`: Name of the model to load

**Returns:** Model ID on success, -1 on error

**Example:**
```c
int model_id = ai_load_model("gpt-4o-mini");
```

#### `void ai_unload_model(int model_id)`

Unloads an AI model.

**Parameters:**
- `model_id`: ID of the model to unload

**Example:**
```c
ai_unload_model(model_id);
```

### GitHub Models Integration

#### `int github_models_init(const char* api_key)`

Initializes GitHub Models API integration.

**Parameters:**
- `api_key`: GitHub API key

**Returns:** 0 on success, -1 on error

**Example:**
```c
int result = github_models_init("your_api_key_here");
```

#### `int github_models_query(const char* prompt, char* response, size_t response_size)`

Queries GitHub Models API.

**Parameters:**
- `prompt`: Input prompt
- `response`: Buffer for response
- `response_size`: Size of response buffer

**Returns:** 0 on success, -1 on error

**Example:**
```c
char response[512];
int result = github_models_query("Explain operating systems", response, sizeof(response));
```

## System Calls

### File Operations

#### `int sys_open(const char* path, int flags)`

Opens a file.

**Parameters:**
- `path`: File path
- `flags`: Open flags (O_RDONLY, O_WRONLY, O_RDWR)

**Returns:** File descriptor or -1 on error

**Example:**
```c
int fd = sys_open("/dev/console", O_RDWR);
```

#### `int sys_read(int fd, void* buffer, size_t count)`

Reads from a file descriptor.

**Parameters:**
- `fd`: File descriptor
- `buffer`: Buffer to read into
- `count`: Number of bytes to read

**Returns:** Number of bytes read or -1 on error

**Example:**
```c
char buffer[256];
int bytes_read = sys_read(fd, buffer, sizeof(buffer));
```

#### `int sys_write(int fd, const void* buffer, size_t count)`

Writes to a file descriptor.

**Parameters:**
- `fd`: File descriptor
- `buffer`: Buffer to write from
- `count`: Number of bytes to write

**Returns:** Number of bytes written or -1 on error

**Example:**
```c
const char* message = "Hello, World!";
int bytes_written = sys_write(fd, message, strlen(message));
```

#### `int sys_close(int fd)`

Closes a file descriptor.

**Parameters:**
- `fd`: File descriptor to close

**Returns:** 0 on success, -1 on error

**Example:**
```c
sys_close(fd);
```

### Process Control

#### `pid_t sys_fork(void)`

Creates a child process.

**Returns:** PID of child process in parent, 0 in child, -1 on error

**Example:**
```c
pid_t pid = sys_fork();
if (pid == 0) {
    // Child process
} else if (pid > 0) {
    // Parent process
} else {
    // Error
}
```

#### `int sys_exec(const char* path, char* const argv[])`

Executes a program.

**Parameters:**
- `path`: Program path
- `argv`: Argument array

**Returns:** Does not return on success, -1 on error

**Example:**
```c
char* args[] = {"program", "arg1", "arg2", NULL};
sys_exec("/bin/program", args);
```

#### `void sys_exit(int status)`

Terminates the current process.

**Parameters:**
- `status`: Exit status

**Example:**
```c
sys_exit(0);
```

### Memory Management

#### `void* sys_mmap(void* addr, size_t length, int prot, int flags)`

Maps memory.

**Parameters:**
- `addr`: Preferred address (can be NULL)
- `length`: Length to map
- `prot`: Protection flags
- `flags`: Mapping flags

**Returns:** Mapped address or MAP_FAILED on error

**Example:**
```c
void* mapped = sys_mmap(NULL, 4096, PROT_READ | PROT_WRITE, MAP_PRIVATE);
```

#### `int sys_munmap(void* addr, size_t length)`

Unmaps memory.

**Parameters:**
- `addr`: Address to unmap
- `length`: Length to unmap

**Returns:** 0 on success, -1 on error

**Example:**
```c
sys_munmap(mapped, 4096);
```

## Error Handling

### Error Codes

```c
#define SAGE_OK          0    // Success
#define SAGE_ERROR      -1    // Generic error
#define SAGE_ENOMEM     -2    // Out of memory
#define SAGE_EINVAL     -3    // Invalid argument
#define SAGE_ENOENT     -4    // No such file or directory
#define SAGE_EPERM      -5    // Permission denied
#define SAGE_EIO        -6    // I/O error
#define SAGE_EBUSY      -7    // Device busy
#define SAGE_ENOSYS     -8    // Function not implemented
```

### Error Handling Functions

#### `const char* sage_strerror(int error_code)`

Returns error message for error code.

**Parameters:**
- `error_code`: Error code

**Returns:** Error message string

**Example:**
```c
int result = some_function();
if (result < 0) {
    printf("Error: %s\n", sage_strerror(result));
}
```

## Debugging and Logging

### Debug Functions

#### `void debug_print(const char* format, ...)`

Prints debug message.

**Parameters:**
- `format`: Printf-style format string
- `...`: Variable arguments

**Example:**
```c
debug_print("Debug: value = %d\n", value);
```

#### `void kernel_panic(const char* message)`

Triggers kernel panic with message.

**Parameters:**
- `message`: Panic message

**Example:**
```c
if (critical_error) {
    kernel_panic("Critical system error detected");
}
```

### Logging Functions

#### `void log_info(const char* format, ...)`

Logs informational message.

**Example:**
```c
log_info("System initialized successfully");
```

#### `void log_warning(const char* format, ...)`

Logs warning message.

**Example:**
```c
log_warning("Low memory condition detected");
```

#### `void log_error(const char* format, ...)`

Logs error message.

**Example:**
```c
log_error("Failed to initialize device");
```

## Constants and Macros

### Memory Constants

```c
#define PAGE_SIZE        4096
#define KERNEL_HEAP_SIZE (1024 * 1024)  // 1MB
#define MAX_PROCESSES    256
#define STACK_SIZE       8192
```

### VGA Colors

```c
#define VGA_COLOR_BLACK         0
#define VGA_COLOR_BLUE          1
#define VGA_COLOR_GREEN         2
#define VGA_COLOR_CYAN          3
#define VGA_COLOR_RED           4
#define VGA_COLOR_MAGENTA       5
#define VGA_COLOR_BROWN         6
#define VGA_COLOR_LIGHT_GREY    7
#define VGA_COLOR_DARK_GREY     8
#define VGA_COLOR_LIGHT_BLUE    9
#define VGA_COLOR_LIGHT_GREEN   10
#define VGA_COLOR_LIGHT_CYAN    11
#define VGA_COLOR_LIGHT_RED     12
#define VGA_COLOR_LIGHT_MAGENTA 13
#define VGA_COLOR_LIGHT_BROWN   14
#define VGA_COLOR_WHITE         15
```

### File Flags

```c
#define O_RDONLY    0x0000
#define O_WRONLY    0x0001
#define O_RDWR      0x0002
#define O_CREAT     0x0040
#define O_TRUNC     0x0200
#define O_APPEND    0x0400
```

## Usage Examples

### Complete Driver Example

```c
#include "sage_kernel.h"

// Simple character device driver
struct char_device {
    char buffer[256];
    size_t pos;
};

static struct char_device my_device;

int my_device_open(void) {
    my_device.pos = 0;
    return 0;
}

int my_device_read(char* buffer, size_t count) {
    size_t available = strlen(my_device.buffer) - my_device.pos;
    if (count > available) count = available;
    
    memcpy(buffer, my_device.buffer + my_device.pos, count);
    my_device.pos += count;
    
    return count;
}

int my_device_write(const char* buffer, size_t count) {
    if (my_device.pos + count >= sizeof(my_device.buffer)) {
        return SAGE_ENOMEM;
    }
    
    memcpy(my_device.buffer + my_device.pos, buffer, count);
    my_device.pos += count;
    my_device.buffer[my_device.pos] = '\0';
    
    return count;
}

void my_device_init(void) {
    memset(&my_device, 0, sizeof(my_device));
    log_info("Character device initialized");
}
```

### AI Integration Example

```c
#include "sage_kernel.h"
#include "sage_ai.h"

void ai_demo(void) {
    char response[512];
    int result;
    
    // Initialize AI subsystem
    if (ai_init() != 0) {
        log_error("Failed to initialize AI subsystem");
        return;
    }
    
    // Process AI command
    result = ai_process_command("What is the current system status?", 
                               response, sizeof(response));
    
    if (result == 0) {
        vga_puts("AI Response: ");
        vga_puts(response);
        vga_putchar('\n');
    } else {
        log_error("AI command failed");
    }
}
```

## Best Practices

### Memory Management
- Always check return values from memory allocation functions
- Free allocated memory when no longer needed
- Use appropriate allocation functions (kmalloc for kernel, vmalloc for large allocations)

### Error Handling
- Check return values from all system calls
- Use appropriate error codes
- Log errors for debugging

### Interrupt Handling
- Keep interrupt handlers short and fast
- Disable interrupts only when necessary
- Use proper synchronization mechanisms

### Driver Development
- Initialize hardware properly
- Handle error conditions gracefully
- Provide clean shutdown procedures

---

For more detailed information, see:
- [Architecture Overview](../architecture/overview.md)
- [Development Guide](../development/setup.md)
- [Driver Development](../development/contributing.md)
- [System Calls](syscalls.md)