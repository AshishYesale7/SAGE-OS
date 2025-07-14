/* ─────────────────────────────────────────────────────────────────────────────
 * SAGE OS — Enhanced Shell with File Management
 * Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
 * SPDX-License-Identifier: BSD-3-Clause OR Proprietary
 * ───────────────────────────────────────────────────────────────────────────── */

#include "enhanced_shell.h"
#include "../drivers/uart.h"
#include "../drivers/serial.h"
#include "../drivers/vga.h"
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
static void cmd_ls(int argc, char* argv[]);
static void cmd_pwd(int argc, char* argv[]);
static void cmd_mkdir(int argc, char* argv[]);
static void cmd_touch(int argc, char* argv[]);
static void cmd_cat(int argc, char* argv[]);
static void cmd_save(int argc, char* argv[]);
static void cmd_append(int argc, char* argv[]);
static void cmd_rm(int argc, char* argv[]);
static void cmd_cp(int argc, char* argv[]);
static void cmd_mv(int argc, char* argv[]);
static void cmd_find(int argc, char* argv[]);
static void cmd_grep(int argc, char* argv[]);
static void cmd_wc(int argc, char* argv[]);
static void cmd_history(int argc, char* argv[]);

// Command table
static const command_t commands[] = {
    {"help",     "Display available commands",           cmd_help},
    {"echo",     "Echo text to the console",             cmd_echo},
    {"clear",    "Clear the screen",                     cmd_clear},
    {"meminfo",  "Display memory information",           cmd_meminfo},
    {"reboot",   "Reboot the system",                    cmd_reboot},
    {"version",  "Display OS version information",       cmd_version},
    {"exit",     "Exit SAGE OS",                         cmd_exit},
    {"ls",       "List directory contents",              cmd_ls},
    {"pwd",      "Print working directory",              cmd_pwd},
    {"mkdir",    "Create directory",                     cmd_mkdir},
    {"touch",    "Create empty file",                    cmd_touch},
    {"cat",      "Display file contents",                cmd_cat},
    {"save",     "Save text to file (save filename text)", cmd_save},
    {"append",   "Append text to file",                  cmd_append},
    {"rm",       "Remove file",                          cmd_rm},
    {"cp",       "Copy file",                            cmd_cp},
    {"mv",       "Move/rename file",                     cmd_mv},
    {"find",     "Find files by name",                   cmd_find},
    {"grep",     "Search text in files",                 cmd_grep},
    {"wc",       "Count lines, words, characters",       cmd_wc},
    {"history",  "Show command history",                 cmd_history},
    {NULL, NULL, NULL}  // Terminator
};

// Initialize the enhanced shell
void enhanced_shell_init() {
    // Initialize file system
    fs_init();
    serial_puts("SAGE OS Enhanced Shell initialized\n");
    serial_puts("File System initialized with persistent memory storage\n");
    
    // Create some sample files
    fs_save("welcome.txt", "Welcome to SAGE OS Enhanced Shell!\nThis file system supports persistent storage.\n");
    fs_save("readme.txt", "SAGE OS File Commands:\n- save filename content\n- cat filename\n- ls (list files)\n- rm filename\n- cp source dest\n- mv source dest\n");
    fs_save("system.log", "SAGE OS System Log\n================\nSystem started successfully.\nFile system initialized.\n");
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
void enhanced_shell_process_command(const char* command) {
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
    serial_puts("Unknown command: ");
    serial_puts(argv[0]);
    serial_puts("\n");
    serial_puts("Type 'help' for a list of commands\n");
}

// Run the enhanced shell (main loop)
void enhanced_shell_run() {
    char command[MAX_COMMAND_LENGTH];
    int pos = 0;
    
    serial_puts("\n=== SAGE OS Enhanced Shell ===\n");
    serial_puts("Type 'help' for available commands\n\n");
    
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
        enhanced_shell_process_command(command);
    }
}

// Command implementations

static void cmd_help(int argc, char* argv[]) {
    (void)argc; (void)argv; // Suppress unused parameter warnings
    
    serial_puts("SAGE OS Enhanced Shell - Available Commands:\n");
    serial_puts("==========================================\n\n");
    
    for (int i = 0; commands[i].name != NULL; i++) {
        char help_line[256];
        sprintf(help_line, "  %-12s - %s\n", commands[i].name, commands[i].description);
        serial_puts(help_line);
    }
    
    serial_puts("\nFile Management Examples:\n");
    serial_puts("  save test.txt Hello World    - Save text to file\n");
    serial_puts("  cat test.txt                 - Display file contents\n");
    serial_puts("  append test.txt More text    - Append to file\n");
    serial_puts("  rm test.txt                  - Delete file\n");
    serial_puts("  cp test.txt backup.txt       - Copy file\n");
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
    (void)argc; (void)argv; // Suppress unused parameter warnings
    
    // Clear screen (ANSI escape sequence)
    serial_puts("\033[2J\033[H");
    // Also clear VGA if available
    vga_init();
    serial_puts("SAGE OS Enhanced Shell - Screen Cleared\n");
    serial_puts("Type 'help' for available commands.\n");
}

static void cmd_meminfo(int argc, char* argv[]) {
    (void)argc; (void)argv; // Suppress unused parameter warnings
    
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
    (void)argc; (void)argv; // Suppress unused parameter warnings
    
    serial_puts("Rebooting SAGE OS...\n");
    
    // For i386, use keyboard controller reset
    #if defined(__i386__) || defined(__x86_64__)
    __asm__ volatile("cli");
    uint8_t temp = 0x02;
    while (temp & 0x02) {
        temp = *((volatile uint8_t*)0x64);
    }
    *((volatile uint8_t*)0x64) = 0xFE;
    #endif
    
    // Fallback: infinite loop
    while (1) {
        __asm__ volatile("hlt");
    }
}

static void cmd_version(int argc, char* argv[]) {
    (void)argc; (void)argv; // Suppress unused parameter warnings
    
    serial_puts("SAGE OS Enhanced Shell v1.0.1\n");
    serial_puts("Self-Aware General Environment Operating System\n");
    serial_puts("Copyright (c) 2025 Ashish Vasant Yesale\n");
    serial_puts("Designed by Ashish Yesale (ashishyesale007@gmail.com)\n");
    serial_puts("\nFeatures:\n");
    serial_puts("- Enhanced file management with persistent storage\n");
    serial_puts("- Advanced shell commands (cp, mv, find, grep, wc)\n");
    serial_puts("- Command history\n");
    serial_puts("- VGA graphics support\n");
    serial_puts("- Multi-architecture support (i386, x86_64, ARM64)\n");
    
    serial_puts("\nArchitecture: ");
    #if defined(__i386__)
    serial_puts("i386 (32-bit x86)");
    #elif defined(__x86_64__)
    serial_puts("x86_64 (64-bit x86)");
    #elif defined(__aarch64__)
    serial_puts("aarch64 (64-bit ARM)");
    #else
    serial_puts("unknown");
    #endif
    serial_puts("\n");
}

static void cmd_exit(int argc, char* argv[]) {
    (void)argc; (void)argv; // Suppress unused parameter warnings
    
    serial_puts("Shutting down SAGE OS Enhanced Shell...\n");
    serial_puts("Thank you for using SAGE OS!\n");
    
    // Exit QEMU
    #if defined(__i386__) || defined(__x86_64__)
    __asm__ volatile("outw %%ax, %%dx" : : "a"(0x2000), "d"(0x604));
    #endif
    
    // Fallback: halt
    while (1) {
        __asm__ volatile("hlt");
    }
}

static void cmd_ls(int argc, char* argv[]) {
    (void)argc; (void)argv; // Suppress unused parameter warnings
    
    char buffer[2048];
    int file_count = fs_list_files(buffer, sizeof(buffer));
    
    if (file_count >= 0) {
        serial_puts(buffer);
    } else {
        serial_puts("Error listing files\n");
    }
}

static void cmd_pwd(int argc, char* argv[]) {
    (void)argc; (void)argv; // Suppress unused parameter warnings
    
    char current_dir[256];
    fs_get_current_directory(current_dir, sizeof(current_dir));
    serial_printf("Current directory: %s\n", current_dir);
}

static void cmd_mkdir(int argc, char* argv[]) {
    if (argc < 2) {
        serial_puts("Usage: mkdir <directory_name>\n");
        return;
    }
    
    // For now, just create a marker file since we have a simple file system
    char marker_name[128];
    sprintf(marker_name, "%s/.directory", argv[1]);
    
    int result = fs_save(marker_name, "Directory marker file");
    if (result == 0) {
        serial_printf("Directory '%s' created successfully\n", argv[1]);
    } else {
        serial_printf("Failed to create directory '%s'\n", argv[1]);
    }
}

static void cmd_touch(int argc, char* argv[]) {
    if (argc < 2) {
        serial_puts("Usage: touch <filename>\n");
        return;
    }
    
    int result = fs_save(argv[1], "");
    if (result == 0) {
        serial_printf("File '%s' created successfully\n", argv[1]);
    } else {
        serial_printf("Failed to create file '%s'\n", argv[1]);
    }
}

static void cmd_cat(int argc, char* argv[]) {
    if (argc < 2) {
        serial_puts("Usage: cat <filename>\n");
        return;
    }
    
    char content[MAX_FILESIZE];
    int result = fs_cat(argv[1], content, sizeof(content));
    
    if (result >= 0) {
        serial_puts(content);
        if (strlen(content) > 0 && content[strlen(content) - 1] != '\n') {
            serial_puts("\n");
        }
    } else {
        serial_printf("File '%s' not found or error reading file\n", argv[1]);
    }
}

static void cmd_save(int argc, char* argv[]) {
    if (argc < 3) {
        serial_puts("Usage: save <filename> <content>\n");
        return;
    }
    
    // Combine all arguments after filename into content
    char content[MAX_FILESIZE];
    content[0] = '\0';
    
    for (int i = 2; i < argc; i++) {
        strcat(content, argv[i]);
        if (i < argc - 1) {
            strcat(content, " ");
        }
    }
    
    int result = fs_save(argv[1], content);
    if (result == 0) {
        serial_printf("Content saved to '%s' successfully\n", argv[1]);
    } else {
        serial_printf("Failed to save content to '%s'\n", argv[1]);
    }
}

static void cmd_append(int argc, char* argv[]) {
    if (argc < 3) {
        serial_puts("Usage: append <filename> <content>\n");
        return;
    }
    
    // Combine all arguments after filename into content
    char content[MAX_FILESIZE];
    content[0] = '\0';
    
    for (int i = 2; i < argc; i++) {
        strcat(content, argv[i]);
        if (i < argc - 1) {
            strcat(content, " ");
        }
    }
    
    int result = fs_append(argv[1], content);
    if (result == 0) {
        serial_printf("Content appended to '%s' successfully\n", argv[1]);
    } else {
        serial_printf("Failed to append content to '%s'\n", argv[1]);
    }
}

static void cmd_rm(int argc, char* argv[]) {
    if (argc < 2) {
        serial_puts("Usage: rm <filename>\n");
        return;
    }
    
    int result = fs_delete_file(argv[1]);
    if (result == 0) {
        serial_printf("File '%s' deleted successfully\n", argv[1]);
    } else {
        serial_printf("Failed to delete file '%s' (file not found)\n", argv[1]);
    }
}

static void cmd_cp(int argc, char* argv[]) {
    if (argc < 3) {
        serial_puts("Usage: cp <source> <destination>\n");
        return;
    }
    
    char content[MAX_FILESIZE];
    int result = fs_cat(argv[1], content, sizeof(content));
    
    if (result >= 0) {
        result = fs_save(argv[2], content);
        if (result == 0) {
            serial_printf("File copied from '%s' to '%s' successfully\n", argv[1], argv[2]);
        } else {
            serial_printf("Failed to copy file to '%s'\n", argv[2]);
        }
    } else {
        serial_printf("Source file '%s' not found\n", argv[1]);
    }
}

static void cmd_mv(int argc, char* argv[]) {
    if (argc < 3) {
        serial_puts("Usage: mv <source> <destination>\n");
        return;
    }
    
    char content[MAX_FILESIZE];
    int result = fs_cat(argv[1], content, sizeof(content));
    
    if (result >= 0) {
        result = fs_save(argv[2], content);
        if (result == 0) {
            fs_delete_file(argv[1]);
            serial_printf("File moved from '%s' to '%s' successfully\n", argv[1], argv[2]);
        } else {
            serial_printf("Failed to move file to '%s'\n", argv[2]);
        }
    } else {
        serial_printf("Source file '%s' not found\n", argv[1]);
    }
}

static void cmd_find(int argc, char* argv[]) {
    if (argc < 2) {
        serial_puts("Usage: find <pattern>\n");
        return;
    }
    
    // Simple implementation - list files containing the pattern in name
    char buffer[2048];
    fs_list_files(buffer, sizeof(buffer));
    
    serial_printf("Files matching pattern '%s':\n", argv[1]);
    
    // Parse the file list and find matches
    char* line = strtok(buffer, "\n");
    int found = 0;
    
    while (line != NULL) {
        if (strstr(line, argv[1]) != NULL) {
            serial_printf("  %s\n", line);
            found++;
        }
        line = strtok(NULL, "\n");
    }
    
    if (found == 0) {
        serial_puts("No files found matching the pattern\n");
    }
}

static void cmd_grep(int argc, char* argv[]) {
    if (argc < 3) {
        serial_puts("Usage: grep <pattern> <filename>\n");
        return;
    }
    
    char content[MAX_FILESIZE];
    int result = fs_cat(argv[2], content, sizeof(content));
    
    if (result >= 0) {
        serial_printf("Lines in '%s' containing '%s':\n", argv[2], argv[1]);
        
        char* line = strtok(content, "\n");
        int line_num = 1;
        int found = 0;
        
        while (line != NULL) {
            if (strstr(line, argv[1]) != NULL) {
                serial_printf("%d: %s\n", line_num, line);
                found++;
            }
            line = strtok(NULL, "\n");
            line_num++;
        }
        
        if (found == 0) {
            serial_puts("Pattern not found in file\n");
        }
    } else {
        serial_printf("File '%s' not found\n", argv[2]);
    }
}

static void cmd_wc(int argc, char* argv[]) {
    if (argc < 2) {
        serial_puts("Usage: wc <filename>\n");
        return;
    }
    
    char content[MAX_FILESIZE];
    int result = fs_cat(argv[1], content, sizeof(content));
    
    if (result >= 0) {
        int lines = 0, words = 0, chars = strlen(content);
        int in_word = 0;
        
        for (int i = 0; content[i]; i++) {
            if (content[i] == '\n') {
                lines++;
            }
            
            if (content[i] == ' ' || content[i] == '\t' || content[i] == '\n') {
                in_word = 0;
            } else if (!in_word) {
                in_word = 1;
                words++;
            }
        }
        
        serial_printf("  %d  %d  %d %s\n", lines, words, chars, argv[1]);
    } else {
        serial_printf("File '%s' not found\n", argv[1]);
    }
}

static void cmd_history(int argc, char* argv[]) {
    (void)argc; (void)argv; // Suppress unused parameter warnings
    
    serial_puts("Command History:\n");
    
    if (history_count == 0) {
        serial_puts("No commands in history\n");
        return;
    }
    
    int start = (history_count < HISTORY_SIZE) ? 0 : history_index;
    for (int i = 0; i < history_count; i++) {
        int idx = (start + i) % HISTORY_SIZE;
        serial_printf("%3d  %s\n", i + 1, history[idx]);
    }
}