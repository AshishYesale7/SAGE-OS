/* ─────────────────────────────────────────────────────────────────────────────
 * SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
 * SPDX-License-Identifier: BSD-3-Clause OR Proprietary
 * SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
 * 
 * This file is part of the SAGE OS Project.
 * ───────────────────────────────────────────────────────────────────────────── */
#include "shell.h"
#include "../drivers/uart.h"
#include "../drivers/serial.h"
#include "memory.h"
#include "types.h"
#include "stdio.h"
#include "utils.h"
#include "filesystem.h"
// #include "ai/ai_subsystem.h"  // Temporarily disabled

#define MAX_COMMAND_LENGTH 256
#define MAX_ARGS 16

// Shell prompt
static const char* PROMPT = "sage> ";

// Command history
#define HISTORY_SIZE 10
static char history[HISTORY_SIZE][MAX_COMMAND_LENGTH];
static int history_count = 0;
static int history_index = 0;

// Built-in commands
typedef void (*command_func_t)(int argc, char* argv[]);

typedef struct {
    const char* name;
    const char* description;
    command_func_t func;
} command_t;

// Forward declarations of command functions
static void cmd_help(int argc, char* argv[]);
static void cmd_echo(int argc, char* argv[]);
static void cmd_clear(int argc, char* argv[]);
static void cmd_meminfo(int argc, char* argv[]);
static void cmd_reboot(int argc, char* argv[]);
static void cmd_version(int argc, char* argv[]);
// static void cmd_ai(int argc, char* argv[]);  // Temporarily disabled
static void cmd_exit(int argc, char* argv[]);
static void cmd_shutdown(int argc, char* argv[]);
static void cmd_ls(int argc, char* argv[]);
static void cmd_pwd(int argc, char* argv[]);
static void cmd_mkdir(int argc, char* argv[]);
static void cmd_rmdir(int argc, char* argv[]);
static void cmd_touch(int argc, char* argv[]);
static void cmd_rm(int argc, char* argv[]);
static void cmd_cat(int argc, char* argv[]);
static void cmd_nano(int argc, char* argv[]);
static void cmd_uptime(int argc, char* argv[]);
static void cmd_whoami(int argc, char* argv[]);
static void cmd_uname(int argc, char* argv[]);
static void cmd_save(int argc, char* argv[]);
static void cmd_append(int argc, char* argv[]);
static void cmd_delete(int argc, char* argv[]);
static void cmd_fileinfo(int argc, char* argv[]);

// Command table
static const command_t commands[] = {
    {"help",     "Display help information",           cmd_help},
    {"echo",     "Echo arguments to the console",      cmd_echo},
    {"clear",    "Clear the screen",                   cmd_clear},
    {"meminfo",  "Display memory information",         cmd_meminfo},
    {"reboot",   "Reboot the system",                  cmd_reboot},
    {"version",  "Display OS version information",     cmd_version},
    // {"ai",       "AI subsystem commands",              cmd_ai},  // Temporarily disabled
    {"exit",     "Exit SAGE OS and shutdown QEMU",     cmd_exit},
    {"shutdown", "Shutdown the system",                cmd_shutdown},
    {"ls",       "List directory contents",            cmd_ls},
    {"pwd",      "Print working directory",            cmd_pwd},
    {"mkdir",    "Create directory",                   cmd_mkdir},
    {"rmdir",    "Remove directory",                   cmd_rmdir},
    {"touch",    "Create empty file",                  cmd_touch},
    {"rm",       "Remove file",                        cmd_rm},
    {"cat",      "Display file contents",              cmd_cat},
    {"nano",     "Simple text editor",                 cmd_nano},
    {"uptime",   "Show system uptime",                 cmd_uptime},
    {"whoami",   "Display current user",               cmd_whoami},
    {"uname",    "Display system information",         cmd_uname},
    {"save",     "Save text to file (save filename content)", cmd_save},
    {"append",   "Append text to file",                cmd_append},
    {"delete",   "Delete file",                        cmd_delete},
    {"fileinfo", "Display file information",           cmd_fileinfo},
    {NULL, NULL, NULL}  // Terminator
};

// Initialize the shell
void shell_init() {
    // Initialize file system first
    fs_init();
    serial_puts("SAGE OS File System initialized\n");
    
    serial_puts("SAGE OS Shell initialized\n");
    
    // Initialize AI subsystem (temporarily disabled)
    // ai_subsystem_status_t status = ai_subsystem_init();
    // if (status == AI_SUBSYSTEM_SUCCESS) {
    //     serial_puts("AI subsystem initialized\n");
    // } else {
    //     serial_puts("AI subsystem initialization failed\n");
    // }
}

// Split a command into arguments
static int split_args(char* command, char* argv[], int max_args) {
    int argc = 0;
    char* token = command;
    char* end = command + strlen(command);
    
    // Skip leading whitespace
    while (*token && (*token == ' ' || *token == '\t')) {
        token++;
    }
    
    while (token < end && argc < max_args) {
        // Mark the start of the argument
        argv[argc++] = token;
        
        // Find the end of the argument
        while (*token && *token != ' ' && *token != '\t') {
            token++;
        }
        
        // Null-terminate the argument
        if (*token) {
            *token++ = '\0';
        }
        
        // Skip whitespace to the next argument
        while (*token && (*token == ' ' || *token == '\t')) {
            token++;
        }
    }
    
    return argc;
}

// Add a command to history
static void add_to_history(const char* command) {
    if (strlen(command) == 0) {
        return;  // Don't add empty commands to history
    }
    
    // Check if this command is the same as the last one
    if (history_count > 0 && strcmp(command, history[(history_index - 1) % HISTORY_SIZE]) == 0) {
        return;  // Don't add duplicate commands consecutively
    }
    
    // Use safe string copy with bounds checking
    strncpy(history[history_index], command, MAX_COMMAND_LENGTH - 1);
    history[history_index][MAX_COMMAND_LENGTH - 1] = '\0';  // Ensure null termination
    history_index = (history_index + 1) % HISTORY_SIZE;
    if (history_count < HISTORY_SIZE) {
        history_count++;
    }
}

// Process a command
void shell_process_command(const char* command) {
    char cmd_copy[MAX_COMMAND_LENGTH];
    strncpy(cmd_copy, command, MAX_COMMAND_LENGTH - 1);
    cmd_copy[MAX_COMMAND_LENGTH - 1] = '\0';
    
    // Add to history
    add_to_history(cmd_copy);
    
    // Split into arguments
    char* argv[MAX_ARGS];
    int argc = split_args(cmd_copy, argv, MAX_ARGS);
    
    if (argc == 0) {
        return;  // Empty command
    }
    
    // Find and execute the command
    for (int i = 0; commands[i].name != NULL; i++) {
        if (strcmp(argv[0], commands[i].name) == 0) {
            commands[i].func(argc, argv);
            return;
        }
    }
    
    // Command not found
    uart_printf("Unknown command: %s\n", argv[0]);
    uart_puts("Type 'help' for a list of commands\n");
}

// Run the shell (main loop)
void shell_run() {
    char command[MAX_COMMAND_LENGTH];
    int pos = 0;
    
    while (1) {
        // Display prompt
        uart_puts(PROMPT);
        
        // Reset command buffer
        memset(command, 0, MAX_COMMAND_LENGTH);
        pos = 0;
        
        // Read command
        while (1) {
            char c = uart_getc();
            
            if (c == '\r' || c == '\n') {
                // End of command
                uart_puts("\n");
                break;
            } else if (c == 8 || c == 127) {
                // Backspace
                if (pos > 0) {
                    pos--;
                    uart_puts("\b \b");  // Erase character
                }
            } else if (c >= ' ' && c <= '~' && pos < MAX_COMMAND_LENGTH - 1) {
                // Printable character
                command[pos++] = c;
                uart_putc(c);  // Echo
            }
        }
        
        command[pos] = '\0';  // Null-terminate
        
        // Process the command
        shell_process_command(command);
    }
}

// Command implementations

static void cmd_help(int argc, char* argv[]) {
    serial_puts("SAGE OS Shell - Available Commands:\n");
    serial_puts("==================================\n\n");
    
    for (int i = 0; commands[i].name != NULL; i++) {
        char help_line[256];
        sprintf(help_line, "  %-12s - %s\n", commands[i].name, commands[i].description);
        serial_puts(help_line);
    }
    
    serial_puts("\nFile Management Examples:\n");
    serial_puts("  save test.txt Hello World    - Save text to file\n");
    serial_puts("  cat test.txt                 - Display file contents\n");
    serial_puts("  append test.txt More text    - Append to file\n");
    serial_puts("  delete test.txt              - Delete file\n");
    serial_puts("  ls                           - List all files\n");
    
    // If ai command help is requested, show subcommands
    if (argc > 1 && strcmp(argv[1], "ai") == 0) {
        uart_puts("\nAI subsystem commands:\n");
        uart_puts("  ai info     - Display AI subsystem information\n");
        uart_puts("  ai temp     - Show AI HAT+ temperature\n");
        uart_puts("  ai power    - Show AI HAT+ power consumption\n");
        uart_puts("  ai models   - List loaded AI models\n");
    }
}

static void cmd_echo(int argc, char* argv[]) {
    for (int i = 1; i < argc; i++) {
        serial_puts(argv[i]);
        if (i < argc - 1) {
            serial_putc(' ');
        }
    }
    serial_putc('\n');
}

static void cmd_clear(int argc, char* argv[]) {
    // Clear screen (ANSI escape sequence)
    serial_puts("\033[2J\033[H");
    serial_puts("SAGE OS Shell - Screen Cleared\n");
    serial_puts("Type 'help' for available commands.\n");
}

static void cmd_meminfo(int argc, char* argv[]) {
    memory_stats();
    
    // Add file system memory information
    uint32_t total_files, memory_used, memory_available;
    fs_get_memory_info(&total_files, &memory_used, &memory_available);
    
    serial_puts("\nFile System Memory:\n");
    char buffer[256];
    sprintf(buffer, "  Total Files: %u\n", total_files);
    serial_puts(buffer);
    sprintf(buffer, "  Memory Used: %u bytes\n", memory_used);
    serial_puts(buffer);
    sprintf(buffer, "  Memory Available: %u bytes\n", memory_available);
    serial_puts(buffer);
}

static void cmd_reboot(int argc, char* argv[]) {
    uart_puts("Rebooting...\n");
    
    // Reset the system using the PM (Power Management) registers
    // This is specific to Raspberry Pi
    volatile uint32_t* PM_RSTC = (uint32_t*)0x3F10001C;
    volatile uint32_t* PM_WDOG = (uint32_t*)0x3F100024;
    
    // PM password
    const uint32_t PM_PASSWORD = 0x5A000000;
    const uint32_t PM_RSTC_WRCFG_FULL_RESET = 0x00000020;
    
    // Set watchdog timer
    *PM_WDOG = PM_PASSWORD | 1;
    *PM_RSTC = PM_PASSWORD | PM_RSTC_WRCFG_FULL_RESET;
    
    while (1) {
        // Wait for reset
    }
}

static void cmd_version(int argc, char* argv[]) {
    serial_puts("SAGE OS v1.0.1 ARM64 Edition\n");
    serial_puts("Self-Aware General Environment Operating System\n");
    serial_puts("Copyright (c) 2025 Ashish Vasant Yesale\n");
    serial_puts("Designed by Ashish Yesale (ashishyesale007@gmail.com)\n");
    serial_puts("\nFeatures:\n");
    serial_puts("- ARM64 Cortex-A76 optimized\n");
    serial_puts("- In-memory file system\n");
    serial_puts("- Advanced shell commands\n");
    serial_puts("- AI subsystem integration\n");
    serial_puts("- Persistent memory storage\n");
}

// AI command handler
static void cmd_ai(int argc, char* argv[]) {
    if (argc < 2) {
        uart_puts("AI subsystem commands:\n");
        uart_puts("  info     - Display AI subsystem information\n");
        uart_puts("  temp     - Show AI HAT+ temperature\n");
        uart_puts("  power    - Show AI HAT+ power consumption\n");
        uart_puts("  models   - List loaded AI models\n");
        return;
    }
    
    if (strcmp(argv[1], "info") == 0) {
        ai_hat_info_t info;
        ai_subsystem_status_t status = ai_subsystem_get_info(&info);
        
        if (status == AI_SUBSYSTEM_SUCCESS) {
            uart_puts("AI Subsystem Information:\n");
            uart_printf("  Version: %d.%d\n", (info.version >> 8) & 0xFF, info.version & 0xFF);
            uart_printf("  Max TOPS: %d\n", info.max_tops);
            uart_printf("  Memory: %d MB\n", info.memory_size / (1024 * 1024));
            uart_printf("  Temperature: %d°C\n", info.temperature);
            uart_printf("  Power consumption: %d mW\n", info.power_consumption);
            
            const char* power_mode;
            switch (info.power_mode) {
                case AI_HAT_POWER_OFF:
                    power_mode = "Off";
                    break;
                case AI_HAT_POWER_LOW:
                    power_mode = "Low";
                    break;
                case AI_HAT_POWER_MEDIUM:
                    power_mode = "Medium";
                    break;
                case AI_HAT_POWER_HIGH:
                    power_mode = "High";
                    break;
                case AI_HAT_POWER_MAX:
                    power_mode = "Maximum";
                    break;
                default:
                    power_mode = "Unknown";
                    break;
            }
            uart_printf("  Power mode: %s\n", power_mode);
        } else {
            uart_puts("Failed to get AI subsystem information\n");
        }
    } else if (strcmp(argv[1], "temp") == 0) {
        uint32_t temperature;
        ai_subsystem_status_t status = ai_subsystem_get_temperature(&temperature);
        
        if (status == AI_SUBSYSTEM_SUCCESS) {
            uart_printf("AI HAT+ temperature: %d°C\n", temperature);
        } else {
            uart_puts("Failed to get AI HAT+ temperature\n");
        }
    } else if (strcmp(argv[1], "power") == 0) {
        uint32_t power;
        ai_subsystem_status_t status = ai_subsystem_get_power_consumption(&power);
        
        if (status == AI_SUBSYSTEM_SUCCESS) {
            uart_printf("AI HAT+ power consumption: %d mW\n", power);
        } else {
            uart_puts("Failed to get AI HAT+ power consumption\n");
        }
    } else if (strcmp(argv[1], "models") == 0) {
        ai_model_descriptor_t models[8];
        uint32_t num_models;
        ai_subsystem_status_t status = ai_subsystem_get_models(models, 8, &num_models);
        
        if (status == AI_SUBSYSTEM_SUCCESS) {
            if (num_models == 0) {
                uart_puts("No AI models loaded\n");
            } else {
                uart_printf("Loaded AI models (%d):\n", num_models);
                for (uint32_t i = 0; i < num_models; i++) {
                    uart_printf("  %d: %s (ID: %d)\n", i + 1, models[i].name, models[i].id);
                    
                    const char* type;
                    switch (models[i].type) {
                        case AI_MODEL_TYPE_CLASSIFICATION:
                            type = "Classification";
                            break;
                        case AI_MODEL_TYPE_DETECTION:
                            type = "Detection";
                            break;
                        case AI_MODEL_TYPE_SEGMENTATION:
                            type = "Segmentation";
                            break;
                        case AI_MODEL_TYPE_GENERATION:
                            type = "Generation";
                            break;
                        case AI_MODEL_TYPE_CUSTOM:
                            type = "Custom";
                            break;
                        default:
                            type = "Unknown";
                            break;
                    }
                    uart_printf("     Type: %s\n", type);
                    
                    const char* precision;
                    switch (models[i].precision) {
                        case AI_HAT_PRECISION_FP32:
                            precision = "FP32";
                            break;
                        case AI_HAT_PRECISION_FP16:
                            precision = "FP16";
                            break;
                        case AI_HAT_PRECISION_INT8:
                            precision = "INT8";
                            break;
                        case AI_HAT_PRECISION_INT4:
                            precision = "INT4";
                            break;
                        default:
                            precision = "Unknown";
                            break;
                    }
                    uart_printf("     Precision: %s\n", precision);
                    
                    uart_printf("     Input: [%d, %d, %d, %d]\n",
                               models[i].input_dims[0], models[i].input_dims[1],
                               models[i].input_dims[2], models[i].input_dims[3]);
                    uart_printf("     Output: [%d, %d, %d, %d]\n",
                               models[i].output_dims[0], models[i].output_dims[1],
                               models[i].output_dims[2], models[i].output_dims[3]);
                }
            }
        } else {
            uart_puts("Failed to get AI models\n");
        }
    } else {
        uart_printf("Unknown AI command: %s\n", argv[1]);
        uart_puts("Type 'ai' for a list of AI commands\n");
    }
}

// Exit command - shuts down QEMU
static void cmd_exit(int argc, char* argv[]) {
    uart_puts("Shutting down SAGE OS...\n");
    uart_puts("Thank you for using SAGE OS!\n");
    uart_puts("Designed by Ashish Yesale\n\n");
    
    // Send QEMU monitor command to quit
    uart_puts("Sending QEMU quit command...\n");
    
    // For QEMU, we can trigger a shutdown by writing to specific ports
    // or by causing a triple fault. Let's use a clean shutdown approach.
    
    // Method 1: ACPI shutdown (works on x86)
    #if defined(__x86_64__) || defined(__i386__)
        // ACPI shutdown - write 0x2000 to port 0x604 (QEMU specific)
        asm volatile("outw %%ax, %%dx" : : "a"(0x2000), "d"(0x604));
    #endif
    
    // Method 2: ARM/AArch64 - use PSCI (Power State Coordination Interface)
    #if defined(__aarch64__)
        // PSCI system_off call - use register variables for better control
        register uint64_t x0 asm("x0") = 0x84000008ULL;
        asm volatile("hvc #0" : : "r"(x0) : "memory");
    #elif defined(__arm__)
        // ARM32 PSCI system_off call
        register uint32_t r0 asm("r0") = 0x84000008U;
        asm volatile("smc #0" : : "r"(r0) : "memory");
    #endif
    
    // Method 3: RISC-V - use SBI (Supervisor Binary Interface)
    #if defined(__riscv)
        // SBI system shutdown
        register long a7 asm("a7") = 8;
        register long a0 asm("a0") = 0;
        asm volatile("ecall" : : "r"(a7), "r"(a0) : "memory");
    #endif
    
    // If none of the above work, halt the CPU
    uart_puts("System halted. You can close QEMU now.\n");
    while (1) {
        #if defined(__aarch64__) || defined(__arm__)
            asm volatile("wfe");
        #elif defined(__x86_64__) || defined(__i386__)
            asm volatile("hlt");
        #elif defined(__riscv)
            asm volatile("wfi");
        #else
            for (volatile int i = 0; i < 1000000; i++);
        #endif
    }
}

// Shutdown command - alias for exit
static void cmd_shutdown(int argc, char* argv[]) {
    cmd_exit(argc, argv);
}

// List directory contents using file system
static void cmd_ls(int argc, char* argv[]) {
    char buffer[2048];
    int result = fs_list_files(buffer, sizeof(buffer));
    
    if (result >= 0) {
        serial_puts(buffer);
    } else {
        serial_puts("Error listing files\n");
    }
}

// Print working directory
static void cmd_pwd(int argc, char* argv[]) {
    char current_dir[128];
    fs_get_current_directory(current_dir, sizeof(current_dir));
    serial_puts(current_dir);
    serial_puts("\n");
}

// Create directory (simulated)
static void cmd_mkdir(int argc, char* argv[]) {
    if (argc < 2) {
        uart_puts("Usage: mkdir <directory_name>\n");
        return;
    }
    uart_printf("Created directory: %s\n", argv[1]);
}

// Remove directory (simulated)
static void cmd_rmdir(int argc, char* argv[]) {
    if (argc < 2) {
        uart_puts("Usage: rmdir <directory_name>\n");
        return;
    }
    uart_printf("Removed directory: %s\n", argv[1]);
}

// Create empty file (simulated)
static void cmd_touch(int argc, char* argv[]) {
    if (argc < 2) {
        uart_puts("Usage: touch <filename>\n");
        return;
    }
    uart_printf("Created file: %s\n", argv[1]);
}

// Remove file (simulated)
static void cmd_rm(int argc, char* argv[]) {
    if (argc < 2) {
        uart_puts("Usage: rm <filename>\n");
        return;
    }
    uart_printf("Removed file: %s\n", argv[1]);
}

// Display file contents (simulated)
static void cmd_cat(int argc, char* argv[]) {
    if (argc < 2) {
        serial_puts("Usage: cat <filename>\n");
        return;
    }
    
    char buffer[4096];
    int result = fs_cat(argv[1], buffer, sizeof(buffer));
    
    if (result >= 0) {
        serial_puts(buffer);
    } else {
        char error_msg[256];
        sprintf(error_msg, "File not found: %s\n", argv[1]);
        serial_puts(error_msg);
    }
}

// Simple text editor (simulated)
static void cmd_nano(int argc, char* argv[]) {
    if (argc < 2) {
        uart_puts("Usage: nano <filename>\n");
        return;
    }
    
    uart_printf("Opening %s in nano editor (simulated)...\n", argv[1]);
    uart_puts("This is a simulated text editor.\n");
    uart_puts("In a full implementation, this would provide text editing capabilities.\n");
    uart_puts("Press Ctrl+X to exit (simulated).\n");
}

// Show system uptime
static void cmd_uptime(int argc, char* argv[]) {
    uart_puts("System uptime: 00:00:42 up 1 min, 1 user, load average: 0.00, 0.00, 0.00\n");
}

// Display current user
static void cmd_whoami(int argc, char* argv[]) {
    uart_puts("root\n");
}

// Display system information
static void cmd_uname(int argc, char* argv[]) {
    if (argc > 1 && strcmp(argv[1], "-a") == 0) {
        uart_puts("SAGE-OS sage-os 0.1.0 #1 ");
        #if defined(__aarch64__)
            uart_puts("aarch64");
        #elif defined(__x86_64__)
            uart_puts("x86_64");
        #elif defined(__arm__)
            uart_puts("arm");
        #elif defined(__riscv)
            uart_puts("riscv64");
        #elif defined(__i386__)
            uart_puts("i386");
        #else
            uart_puts("unknown");
        #endif
        uart_puts(" GNU/Linux\n");
    } else {
        uart_puts("SAGE-OS\n");
    }
}

// Save text to file
static void cmd_save(int argc, char* argv[]) {
    if (argc < 3) {
        serial_puts("Usage: save <filename> <content>\n");
        serial_puts("Example: save test.txt \"Hello World\"\n");
        return;
    }
    
    // Combine all arguments after filename into content
    char content[4096] = "";
    for (int i = 2; i < argc; i++) {
        strcat(content, argv[i]);
        if (i < argc - 1) {
            strcat(content, " ");
        }
    }
    
    int result = fs_save(argv[1], content);
    if (result == 0) {
        char msg[256];
        sprintf(msg, "File '%s' saved successfully\n", argv[1]);
        serial_puts(msg);
    } else {
        char msg[256];
        sprintf(msg, "Error saving file '%s' (code: %d)\n", argv[1], result);
        serial_puts(msg);
    }
}

// Append text to file
static void cmd_append(int argc, char* argv[]) {
    if (argc < 3) {
        serial_puts("Usage: append <filename> <content>\n");
        return;
    }
    
    // Combine all arguments after filename into content
    char content[4096] = "";
    for (int i = 2; i < argc; i++) {
        strcat(content, argv[i]);
        if (i < argc - 1) {
            strcat(content, " ");
        }
    }
    
    int result = fs_append(argv[1], content);
    if (result == 0) {
        char msg[256];
        sprintf(msg, "Content appended to '%s' successfully\n", argv[1]);
        serial_puts(msg);
    } else {
        char msg[256];
        sprintf(msg, "Error appending to file '%s' (code: %d)\n", argv[1], result);
        serial_puts(msg);
    }
}

// Delete file
static void cmd_delete(int argc, char* argv[]) {
    if (argc < 2) {
        serial_puts("Usage: delete <filename>\n");
        return;
    }
    
    int result = fs_delete_file(argv[1]);
    if (result == 0) {
        char msg[256];
        sprintf(msg, "File '%s' deleted successfully\n", argv[1]);
        serial_puts(msg);
    } else {
        char msg[256];
        sprintf(msg, "Error deleting file '%s' (code: %d)\n", argv[1], result);
        serial_puts(msg);
    }
}

// Display file information
static void cmd_fileinfo(int argc, char* argv[]) {
    if (argc < 2) {
        serial_puts("Usage: fileinfo <filename>\n");
        return;
    }
    
    if (!fs_file_exists(argv[1])) {
        char msg[256];
        sprintf(msg, "File '%s' does not exist\n", argv[1]);
        serial_puts(msg);
        return;
    }
    
    size_t file_size = fs_get_file_size(argv[1]);
    char msg[256];
    sprintf(msg, "File: %s\n", argv[1]);
    serial_puts(msg);
    sprintf(msg, "Size: %zu bytes\n", file_size);
    serial_puts(msg);
    serial_puts("Type: text file\n");
}