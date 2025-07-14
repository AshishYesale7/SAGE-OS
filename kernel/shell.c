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
    char msg[256];
    sprintf(msg, "Unknown command: %s\n", argv[0]);
    serial_puts(msg);
    serial_puts("Type 'help' for a list of commands\n");
}

// Run the shell (main loop)
void shell_run() {
    char command[MAX_COMMAND_LENGTH];
    int pos = 0;
    
    while (1) {
        // Display prompt
        serial_puts(PROMPT);
        
        // Reset command buffer
        memset(command, 0, MAX_COMMAND_LENGTH);
        pos = 0;
        
        // Read command
        while (1) {
            char c = uart_getc();
            
            if (c == '\r' || c == '\n') {
                // End of command
                serial_puts("\n");
                break;
            } else if (c == 8 || c == 127) {
                // Backspace
                if (pos > 0) {
                    pos--;
                    serial_puts("\b \b");  // Erase character
                }
            } else if (c >= ' ' && c <= '~' && pos < MAX_COMMAND_LENGTH - 1) {
                // Printable character
                command[pos++] = c;
                serial_putc(c);  // Echo
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
    // Display basic memory statistics
    serial_puts("Memory Statistics:\n");
    serial_puts("  Total RAM: 1024 MB\n");
    serial_puts("  Available: 1000 MB\n");
    serial_puts("  Used: 24 MB\n");
    serial_puts("  Kernel: 16 MB\n");
    serial_puts("  User: 8 MB\n");
    
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
    serial_puts("Rebooting...\n");
    
    // For i386, we can use the keyboard controller to reboot
    // This is a common method for x86 systems
    serial_puts("Sending reboot command to keyboard controller...\n");
    
    // Wait for keyboard controller to be ready
    uint8_t temp;
    do {
        temp = *((volatile uint8_t*)0x64);
    } while (temp & 0x02);
    
    // Send reboot command
    *((volatile uint8_t*)0x64) = 0xFE;
    
    // If we get here, the reboot failed
    serial_puts("Reboot failed. System halted.\n");
    while (1) {
        // Halt
    }
}

static void cmd_version(int argc, char* argv[]) {
    serial_puts("SAGE OS v1.0.1 i386 Edition\n");
    serial_puts("Self-Aware General Environment Operating System\n");
    serial_puts("Copyright (c) 2025 Ashish Vasant Yesale\n");
    serial_puts("Designed by Ashish Yesale (ashishyesale007@gmail.com)\n");
    serial_puts("\nFeatures:\n");
    serial_puts("- i386 optimized\n");
    serial_puts("- In-memory file system\n");
    serial_puts("- Advanced shell commands\n");
    serial_puts("- Persistent memory storage\n");
}

// Exit command - shuts down QEMU
static void cmd_exit(int argc, char* argv[]) {
    serial_puts("Shutting down SAGE OS...\n");
    serial_puts("Thank you for using SAGE OS!\n");
    serial_puts("Designed by Ashish Yesale\n\n");

    // Send QEMU monitor command to quit
    serial_puts("Sending QEMU quit command...\n");

    // For QEMU, we can trigger a shutdown by writing to specific ports
    // or by causing a triple fault. Let's use a clean shutdown approach.

    // Method 1: ACPI shutdown (works on x86)
    // Using inline assembly instead of outw function
    __asm__ __volatile__ ("outw %0, %1" : : "a"((uint16_t)0x2000), "Nd"((uint16_t)0xB004));

    // Method 2: QEMU debug exit (if enabled)
    __asm__ __volatile__ ("outw %0, %1" : : "a"((uint16_t)0x31), "Nd"((uint16_t)0x501));

    // Method 3: Bochs/QEMU shutdown port
    __asm__ __volatile__ ("outw %0, %1" : : "a"((uint16_t)0x00), "Nd"((uint16_t)0x8900));

    // If we get here, none of the methods worked
    serial_puts("Shutdown failed. System halted.\n");
    while (1) {
        // Halt
    }
}

// Shutdown command (alias for exit)
static void cmd_shutdown(int argc, char* argv[]) {
    cmd_exit(argc, argv);
}

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
        serial_puts("Usage: mkdir <directory_name>\n");
        return;
    }
    // For now, just simulate directory creation since we have a simple file system
    char msg[256];
    sprintf(msg, "Directory '%s' created (simulated)\n", argv[1]);
    serial_puts(msg);
}

// Remove directory (simulated)
static void cmd_rmdir(int argc, char* argv[]) {
    if (argc < 2) {
        serial_puts("Usage: rmdir <directory_name>\n");
        return;
    }
    char msg[256];
    sprintf(msg, "Directory '%s' removed (simulated)\n", argv[1]);
    serial_puts(msg);
}

// Create empty file
static void cmd_touch(int argc, char* argv[]) {
    if (argc < 2) {
        serial_puts("Usage: touch <filename>\n");
        return;
    }
    
    // Create empty file using filesystem
    int result = fs_save(argv[1], "");
    if (result == 0) {
        char msg[256];
        sprintf(msg, "File '%s' created\n", argv[1]);
        serial_puts(msg);
    } else {
        char msg[256];
        sprintf(msg, "Error creating file '%s' (code: %d)\n", argv[1], result);
        serial_puts(msg);
    }
}

// Remove file
static void cmd_rm(int argc, char* argv[]) {
    if (argc < 2) {
        serial_puts("Usage: rm <filename>\n");
        return;
    }
    
    // Delete file using filesystem
    int result = fs_delete_file(argv[1]);
    if (result == 0) {
        char msg[256];
        sprintf(msg, "File '%s' deleted\n", argv[1]);
        serial_puts(msg);
    } else {
        char msg[256];
        sprintf(msg, "Error deleting file '%s' (code: %d)\n", argv[1], result);
        serial_puts(msg);
    }
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
        serial_puts("\n");
    } else {
        char error_msg[256];
        sprintf(error_msg, "File not found: %s\n", argv[1]);
        serial_puts(error_msg);
    }
}

// Simple text editor (simulated)
static void cmd_nano(int argc, char* argv[]) {
    if (argc < 2) {
        serial_puts("Usage: nano <filename>\n");
        return;
    }
    
    char buffer[4096] = "";
    int result = fs_cat(argv[1], buffer, sizeof(buffer));
    
    if (result < 0) {
        char msg[256];
        sprintf(msg, "Creating new file: %s\n", argv[1]);
        serial_puts(msg);
    } else {
        char msg[256];
        sprintf(msg, "Editing file: %s\n", argv[1]);
        serial_puts(msg);
        serial_puts("Current content:\n");
        serial_puts(buffer);
        serial_puts("\n");
    }
    
    serial_puts("Enter new content (end with a line containing only '.')\n");
    
    char content[4096] = "";
    char line[256];
    int pos = 0;
    
    while (1) {
        serial_puts("> ");
        
        // Read a line
        int line_pos = 0;
        while (1) {
            char c = uart_getc();
            
            if (c == '\r' || c == '\n') {
                serial_puts("\n");
                line[line_pos] = '\0';
                break;
            } else if (c == 8 || c == 127) {
                // Backspace
                if (line_pos > 0) {
                    line_pos--;
                    serial_puts("\b \b");
                }
            } else if (c >= ' ' && c <= '~' && line_pos < sizeof(line) - 1) {
                line[line_pos++] = c;
                serial_putc(c);
            }
        }
        
        // Check for end marker
        if (strcmp(line, ".") == 0) {
            break;
        }
        
        // Add line to content
        int line_len = strlen(line);
        if (pos + line_len + 2 < sizeof(content)) {
            strcpy(content + pos, line);
            pos += line_len;
            content[pos++] = '\n';
            content[pos] = '\0';
        } else {
            serial_puts("Buffer full, saving current content\n");
            break;
        }
    }
    
    // Save the file
    result = fs_save(argv[1], content);
    if (result == 0) {
        char msg[256];
        sprintf(msg, "File '%s' saved successfully\n", argv[1]);
        serial_puts(msg);
    } else {
        char msg[256];
        sprintf(msg, "Error saving file '%s'\n", argv[1]);
        serial_puts(msg);
    }
}

// Show system uptime (simulated)
static void cmd_uptime(int argc, char* argv[]) {
    serial_puts("System uptime: 0 days, 0 hours, 5 minutes\n");
}

// Show current user (simulated)
static void cmd_whoami(int argc, char* argv[]) {
    serial_puts("sage\n");
}

// Show system information (simulated)
static void cmd_uname(int argc, char* argv[]) {
    serial_puts("SAGE-OS 1.0.1 i386 #1 SMP PREEMPT\n");
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
        sprintf(msg, "File not found: %s\n", argv[1]);
        serial_puts(msg);
        return;
    }
    
    size_t size = fs_get_file_size(argv[1]);
    
    char buffer[256];
    sprintf(buffer, "File: %s\n", argv[1]);
    serial_puts(buffer);
    sprintf(buffer, "Size: %u bytes\n", (unsigned int)size);
    serial_puts(buffer);
    
    // Read file content for preview
    char content[4096];
    fs_cat(argv[1], content, sizeof(content));
    
    // Calculate lines and words
    int lines = 0;
    int words = 0;
    int in_word = 0;
    
    for (size_t i = 0; i < strlen(content); i++) {
        if (content[i] == '\n') {
            lines++;
            in_word = 0;
        } else if (content[i] == ' ' || content[i] == '\t') {
            in_word = 0;
        } else if (!in_word) {
            words++;
            in_word = 1;
        }
    }
    
    sprintf(buffer, "Lines: %d\n", lines + 1);
    serial_puts(buffer);
    sprintf(buffer, "Words: %d\n", words);
    serial_puts(buffer);
    
    // Show preview
    serial_puts("Preview:\n");
    if (size > 100) {
        char preview[101];
        strncpy(preview, content, 100);
        preview[100] = '\0';
        serial_puts(preview);
        serial_puts("...\n");
    } else {
        serial_puts(content);
        serial_puts("\n");
    }
}