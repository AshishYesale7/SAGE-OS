/* ─────────────────────────────────────────────────────────────────────────────
 * SAGE OS Shell - Core Version (No AI Integration)
 * Enhanced command-line interface with file management
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

#define MAX_COMMAND_LENGTH 256
#define MAX_ARGS 16

// Command structure
typedef struct {
    const char* name;
    const char* description;
    void (*handler)(int argc, char* argv[]);
} command_t;

// Forward declarations
static void cmd_help(int argc, char* argv[]);
static void cmd_echo(int argc, char* argv[]);
static void cmd_clear(int argc, char* argv[]);
static void cmd_meminfo(int argc, char* argv[]);
static void cmd_reboot(int argc, char* argv[]);
static void cmd_version(int argc, char* argv[]);
static void cmd_exit(int argc, char* argv[]);
static void cmd_shutdown(int argc, char* argv[]);
static void cmd_ls(int argc, char* argv[]);
static void cmd_pwd(int argc, char* argv[]);
static void cmd_cat(int argc, char* argv[]);
static void cmd_save(int argc, char* argv[]);
static void cmd_append(int argc, char* argv[]);
static void cmd_delete(int argc, char* argv[]);
static void cmd_fileinfo(int argc, char* argv[]);
static void cmd_uptime(int argc, char* argv[]);
static void cmd_whoami(int argc, char* argv[]);

// Command table
static command_t commands[] = {
    {"help",     "Display available commands",           cmd_help},
    {"echo",     "Echo text to output",                  cmd_echo},
    {"clear",    "Clear the screen",                     cmd_clear},
    {"meminfo",  "Display memory information",         cmd_meminfo},
    {"reboot",   "Reboot the system",                  cmd_reboot},
    {"version",  "Display OS version information",     cmd_version},
    {"exit",     "Exit SAGE OS and shutdown QEMU",     cmd_exit},
    {"shutdown", "Shutdown the system",                cmd_shutdown},
    {"ls",       "List directory contents",            cmd_ls},
    {"pwd",      "Print working directory",            cmd_pwd},
    {"cat",      "Display file contents",              cmd_cat},
    {"save",     "Save text to file",                  cmd_save},
    {"append",   "Append text to file",                cmd_append},
    {"delete",   "Delete a file",                      cmd_delete},
    {"fileinfo", "Display file information",           cmd_fileinfo},
    {"uptime",   "Display system uptime",              cmd_uptime},
    {"whoami",   "Display current user",               cmd_whoami},
    {NULL, NULL, NULL}  // Sentinel
};

// Initialize shell
void shell_init(void) {
    // Initialize file system
    fs_init();
    
    serial_puts("SAGE OS Shell initialized\n");
}

// Split a command into arguments
static int split_args(char* command, char* argv[], int max_args) {
    int argc = 0;
    char* token = command;
    
    while (*token && argc < max_args - 1) {
        // Skip leading whitespace
        while (*token == ' ' || *token == '\t') {
            token++;
        }
        
        if (*token == '\0') break;
        
        argv[argc++] = token;
        
        // Find end of current argument
        while (*token && *token != ' ' && *token != '\t') {
            token++;
        }
        
        if (*token) {
            *token = '\0';
            token++;
        }
    }
    
    argv[argc] = NULL;
    return argc;
}

// Execute a command
static void execute_command(char* command) {
    char* argv[MAX_ARGS];
    int argc = split_args(command, argv, MAX_ARGS);
    
    if (argc == 0) return;
    
    // Find and execute command
    for (int i = 0; commands[i].name != NULL; i++) {
        if (strcmp(argv[0], commands[i].name) == 0) {
            commands[i].handler(argc, argv);
            return;
        }
    }
    
    // Command not found
    serial_puts("Command not found: ");
    serial_puts(argv[0]);
    serial_puts("\nType 'help' for available commands.\n");
}

// Read a line from input
static int read_line(char* buffer, int max_length) {
    int pos = 0;
    char c;
    
    while (pos < max_length - 1) {
        c = uart_getc();
        
        if (c == '\r' || c == '\n') {
            uart_putc('\n');
            buffer[pos] = '\0';
            return pos;
        } else if (c == '\b' || c == 127) { // Backspace
            if (pos > 0) {
                pos--;
                uart_puts("\b \b");
            }
        } else if (c >= 32 && c <= 126) { // Printable characters
            buffer[pos++] = c;
            uart_putc(c);
        }
    }
    
    buffer[pos] = '\0';
    return pos;
}

// Main shell loop
void shell_run(void) {
    char command[MAX_COMMAND_LENGTH];
    
    serial_puts("\n");
    serial_puts("╔══════════════════════════════════════════════════════════════════════════════╗\n");
    serial_puts("║                            SAGE OS Shell v1.0.1                             ║\n");
    serial_puts("║                    Self-Aware General Environment OS                        ║\n");
    serial_puts("║                        Enhanced File Management                             ║\n");
    serial_puts("╚══════════════════════════════════════════════════════════════════════════════╝\n");
    serial_puts("\nWelcome to SAGE OS! Type 'help' for available commands.\n\n");
    
    while (1) {
        serial_puts("SAGE:/ $ ");
        
        if (read_line(command, MAX_COMMAND_LENGTH) > 0) {
            execute_command(command);
        }
    }
}

// Command implementations
static void cmd_help(int argc, char* argv[]) {
    (void)argc; (void)argv;  // Suppress unused parameter warnings
    
    serial_puts("\n╔══════════════════════════════════════════════════════════════════════════════╗\n");
    serial_puts("║                            SAGE OS Commands                                 ║\n");
    serial_puts("╠══════════════════════════════════════════════════════════════════════════════╣\n");
    serial_puts("║ File Management:                                                             ║\n");
    serial_puts("║   save <file> <content>  - Save text to file                                ║\n");
    serial_puts("║   cat <file>             - Display file contents                            ║\n");
    serial_puts("║   append <file> <text>   - Append text to file                              ║\n");
    serial_puts("║   delete <file>          - Delete a file                                    ║\n");
    serial_puts("║   ls                     - List files                                       ║\n");
    serial_puts("║   fileinfo <file>        - Show file information                            ║\n");
    serial_puts("║                                                                              ║\n");
    serial_puts("║ System Commands:                                                             ║\n");
    serial_puts("║   pwd                    - Show current directory                           ║\n");
    serial_puts("║   clear                  - Clear screen                                     ║\n");
    serial_puts("║   echo <text>            - Echo text                                        ║\n");
    serial_puts("║   meminfo                - Memory information                               ║\n");
    serial_puts("║   version                - OS version                                       ║\n");
    serial_puts("║   uptime                 - System uptime                                    ║\n");
    serial_puts("║   whoami                 - Current user                                     ║\n");
    serial_puts("║   reboot                 - Reboot system                                    ║\n");
    serial_puts("║   exit                   - Exit SAGE OS                                     ║\n");
    serial_puts("╚══════════════════════════════════════════════════════════════════════════════╝\n\n");
    
    serial_puts("Examples:\n");
    serial_puts("  save hello.txt \"Hello, SAGE OS!\"\n");
    serial_puts("  cat hello.txt\n");
    serial_puts("  append hello.txt \" Welcome to the future!\"\n");
    serial_puts("  ls\n");
    serial_puts("  fileinfo hello.txt\n\n");
}

static void cmd_echo(int argc, char* argv[]) {
    for (int i = 1; i < argc; i++) {
        serial_puts(argv[i]);
        if (i < argc - 1) serial_puts(" ");
    }
    serial_puts("\n");
}

static void cmd_clear(int argc, char* argv[]) {
    (void)argc; (void)argv;  // Suppress unused parameter warnings
    
    // ANSI escape sequence to clear screen and move cursor to top
    serial_puts("\033[2J\033[H");
}

static void cmd_meminfo(int argc, char* argv[]) {
    (void)argc; (void)argv;  // Suppress unused parameter warnings
    
    uint32_t total_files, memory_used, memory_available;
    fs_get_memory_info(&total_files, &memory_used, &memory_available);
    
    serial_puts("Memory Information:\n");
    serial_puts("  Total Memory: 4096 KB\n");
    serial_puts("  Used Memory:  ");
    char buffer[32];
    my_itoa(memory_used / 1024, buffer, 10);
    serial_puts(buffer);
    serial_puts(" KB\n");
    serial_puts("  Free Memory:  ");
    my_itoa(memory_available / 1024, buffer, 10);
    serial_puts(buffer);
    serial_puts(" KB\n");
    serial_puts("  Total Files:  ");
    my_itoa(total_files, buffer, 10);
    serial_puts(buffer);
    serial_puts("\n");
}

static void cmd_reboot(int argc, char* argv[]) {
    (void)argc; (void)argv;  // Suppress unused parameter warnings
    
    serial_puts("Rebooting SAGE OS...\n");
    serial_puts("System will restart now.\n");
    
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
    (void)argc; (void)argv;  // Suppress unused parameter warnings
    
    serial_puts("SAGE OS v1.0.1 ARM64 Core Edition\n");
    serial_puts("Self-Aware General Environment Operating System\n");
    serial_puts("Copyright (c) 2025 Ashish Vasant Yesale\n");
    serial_puts("Designed by Ashish Yesale (ashishyesale007@gmail.com)\n");
    serial_puts("\nCore Features:\n");
    serial_puts("- ARM64 Cortex-A76 optimized\n");
    serial_puts("- In-memory file system\n");
    serial_puts("- Advanced shell commands\n");
    serial_puts("- Persistent memory storage\n");
    serial_puts("- Enhanced I/O handling\n");
}

// Exit command - shuts down QEMU
static void cmd_exit(int argc, char* argv[]) {
    (void)argc; (void)argv;  // Suppress unused parameter warnings
    
    serial_puts("Shutting down SAGE OS...\n");
    serial_puts("Thank you for using SAGE OS!\n");
    serial_puts("Designed by Ashish Yesale\n\n");
    
    // Send QEMU monitor command to quit
    serial_puts("Sending QEMU quit command...\n");
    
    // For QEMU, we can use the special debug exit
    #if defined(__aarch64__)
        // ARM64 QEMU exit
        volatile uint32_t* qemu_exit = (uint32_t*)0x09000000;
        *qemu_exit = 0x20026;  // QEMU virt machine exit code
    #else
        // x86 QEMU exit
        __asm__ volatile("outw %0, %1" : : "a"(0x2000), "Nd"(0x604));
    #endif
    
    // If QEMU exit doesn't work, just halt
    while (1) {
        #if defined(__aarch64__)
            __asm__ volatile("wfi");
        #else
            __asm__ volatile("hlt");
        #endif
    }
}

// Shutdown command
static void cmd_shutdown(int argc, char* argv[]) {
    cmd_exit(argc, argv);  // Same as exit for now
}

// List files command
static void cmd_ls(int argc, char* argv[]) {
    (void)argc; (void)argv;  // Suppress unused parameter warnings
    
    char buffer[2048];
    if (fs_list_files(buffer, sizeof(buffer)) == 0) {
        serial_puts(buffer);
    } else {
        serial_puts("Error listing files\n");
    }
}

// Print working directory
static void cmd_pwd(int argc, char* argv[]) {
    (void)argc; (void)argv;  // Suppress unused parameter warnings
    
    char cwd[256];
    fs_get_current_directory(cwd, sizeof(cwd));
    serial_puts(cwd);
    serial_puts("\n");
}

// Cat command - display file contents
static void cmd_cat(int argc, char* argv[]) {
    if (argc < 2) {
        serial_puts("Usage: cat <filename>\n");
        return;
    }
    
    char content[4096];
    
    if (fs_read_file(argv[1], content, sizeof(content)) == 0) {
        serial_puts(content);
        serial_puts("\n");
    } else {
        serial_puts("Error: File '");
        serial_puts(argv[1]);
        serial_puts("' not found or cannot be read\n");
    }
}

static void cmd_uptime(int argc, char* argv[]) {
    (void)argc; (void)argv;  // Suppress unused parameter warnings
    serial_puts("System uptime: Running since boot\n");
}

static void cmd_whoami(int argc, char* argv[]) {
    (void)argc; (void)argv;  // Suppress unused parameter warnings
    serial_puts("root\n");
}

// Save command - save text to file
static void cmd_save(int argc, char* argv[]) {
    if (argc < 3) {
        serial_puts("Usage: save <filename> <content>\n");
        serial_puts("Example: save hello.txt \"Hello, World!\"\n");
        return;
    }
    
    // Combine all arguments after filename into content
    char content[4096] = {0};
    for (int i = 2; i < argc; i++) {
        my_strcat(content, argv[i]);
        if (i < argc - 1) {
            my_strcat(content, " ");
        }
    }
    
    if (fs_write_file(argv[1], content, my_strlen(content)) == 0) {
        serial_puts("File '");
        serial_puts(argv[1]);
        serial_puts("' saved successfully\n");
    } else {
        serial_puts("Error: Could not save file '");
        serial_puts(argv[1]);
        serial_puts("'\n");
    }
}

// Append command - append text to file
static void cmd_append(int argc, char* argv[]) {
    if (argc < 3) {
        serial_puts("Usage: append <filename> <content>\n");
        serial_puts("Example: append hello.txt \" More text\"\n");
        return;
    }
    
    // Read existing content
    char existing_content[4096] = {0};
    fs_read_file(argv[1], existing_content, sizeof(existing_content));
    
    // Combine all arguments after filename into new content
    char new_content[4096] = {0};
    for (int i = 2; i < argc; i++) {
        my_strcat(new_content, argv[i]);
        if (i < argc - 1) {
            my_strcat(new_content, " ");
        }
    }
    
    // Append new content to existing
    my_strcat(existing_content, new_content);
    
    if (fs_write_file(argv[1], existing_content, my_strlen(existing_content)) == 0) {
        serial_puts("Content appended to '");
        serial_puts(argv[1]);
        serial_puts("' successfully\n");
    } else {
        serial_puts("Error: Could not append to file '");
        serial_puts(argv[1]);
        serial_puts("'\n");
    }
}

// Delete command - delete a file
static void cmd_delete(int argc, char* argv[]) {
    if (argc < 2) {
        serial_puts("Usage: delete <filename>\n");
        return;
    }
    
    if (fs_delete_file(argv[1]) == 0) {
        serial_puts("File '");
        serial_puts(argv[1]);
        serial_puts("' deleted successfully\n");
    } else {
        serial_puts("Error: Could not delete file '");
        serial_puts(argv[1]);
        serial_puts("' (file not found)\n");
    }
}

// File info command - display file information
static void cmd_fileinfo(int argc, char* argv[]) {
    if (argc < 2) {
        serial_puts("Usage: fileinfo <filename>\n");
        return;
    }
    
    if (fs_file_exists(argv[1])) {
        size_t size = fs_get_file_size(argv[1]);
        char buffer[32];
        
        serial_puts("File Information for '");
        serial_puts(argv[1]);
        serial_puts("':\n");
        serial_puts("  Size: ");
        my_itoa(size, buffer, 10);
        serial_puts(buffer);
        serial_puts(" bytes\n");
        serial_puts("  Status: Exists\n");
    } else {
        serial_puts("Error: File '");
        serial_puts(argv[1]);
        serial_puts("' not found\n");
    }
}