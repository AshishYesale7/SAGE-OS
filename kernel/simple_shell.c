/* ─────────────────────────────────────────────────────────────────────────────
 * SAGE OS — Simple Shell (No AI Features)
 * Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
 * SPDX-License-Identifier: BSD-3-Clause OR Proprietary
 * ───────────────────────────────────────────────────────────────────────────── */

#include "shell.h"
#include "../drivers/serial.h"
#include "../drivers/uart.h"
#include "filesystem.h"
#include "memory.h"
#include "utils.h"

#define MAX_COMMAND_LENGTH 256
#define MAX_ARGS 16

// Command structure
typedef struct {
    const char* name;
    void (*handler)(int argc, char* argv[]);
    const char* description;
} command_t;

// Forward declarations
static void cmd_help(int argc, char* argv[]);
static void cmd_echo(int argc, char* argv[]);
static void cmd_clear(int argc, char* argv[]);
static void cmd_meminfo(int argc, char* argv[]);
static void cmd_reboot(int argc, char* argv[]);
static void cmd_version(int argc, char* argv[]);
static void cmd_exit(int argc, char* argv[]);
static void cmd_ls(int argc, char* argv[]);
static void cmd_pwd(int argc, char* argv[]);
static void cmd_cat(int argc, char* argv[]);
static void cmd_save(int argc, char* argv[]);
static void cmd_rm(int argc, char* argv[]);
static void cmd_uptime(int argc, char* argv[]);
static void cmd_whoami(int argc, char* argv[]);
static void cmd_cp(int argc, char* argv[]);
static void cmd_mv(int argc, char* argv[]);
static void cmd_mkdir(int argc, char* argv[]);
static void cmd_touch(int argc, char* argv[]);
static void cmd_find(int argc, char* argv[]);
static void cmd_grep(int argc, char* argv[]);
static void cmd_wc(int argc, char* argv[]);
static void cmd_head(int argc, char* argv[]);
static void cmd_tail(int argc, char* argv[]);
static void cmd_stat(int argc, char* argv[]);

// Command table
static const command_t commands[] = {
    {"help", cmd_help, "Show available commands"},
    {"echo", cmd_echo, "Echo text to console"},
    {"clear", cmd_clear, "Clear the screen"},
    {"meminfo", cmd_meminfo, "Show memory information"},
    {"reboot", cmd_reboot, "Reboot the system"},
    {"version", cmd_version, "Show OS version"},
    {"exit", cmd_exit, "Exit SAGE OS"},
    {"ls", cmd_ls, "List files and directories"},
    {"pwd", cmd_pwd, "Show current directory"},
    {"cat", cmd_cat, "Display file contents"},
    {"save", cmd_save, "Save text to file"},
    {"rm", cmd_rm, "Remove file"},
    {"cp", cmd_cp, "Copy file"},
    {"mv", cmd_mv, "Move/rename file"},
    {"mkdir", cmd_mkdir, "Create directory"},
    {"touch", cmd_touch, "Create empty file"},
    {"find", cmd_find, "Find files by name"},
    {"grep", cmd_grep, "Search text in files"},
    {"wc", cmd_wc, "Count lines, words, characters"},
    {"head", cmd_head, "Show first lines of file"},
    {"tail", cmd_tail, "Show last lines of file"},
    {"stat", cmd_stat, "Show file statistics"},
    {"uptime", cmd_uptime, "Show system uptime"},
    {"whoami", cmd_whoami, "Show current user"},
    {NULL, NULL, NULL}
};

// Parse command line into arguments
static int parse_command(char* command, char* argv[]) {
    int argc = 0;
    char* token = command;
    
    // Skip leading whitespace
    while (*token == ' ' || *token == '\t') token++;
    
    while (*token && argc < MAX_ARGS - 1) {
        argv[argc++] = token;
        
        // Find end of current argument
        while (*token && *token != ' ' && *token != '\t') token++;
        
        // Null-terminate current argument
        if (*token) {
            *token++ = '\0';
            // Skip whitespace to next argument
            while (*token == ' ' || *token == '\t') token++;
        }
    }
    
    argv[argc] = NULL;
    return argc;
}

// Process a command
void shell_process_command(const char* input) {
    char command[MAX_COMMAND_LENGTH];
    char* argv[MAX_ARGS];
    int argc;
    
    // Copy input to avoid modifying original
    strncpy(command, input, MAX_COMMAND_LENGTH - 1);
    command[MAX_COMMAND_LENGTH - 1] = '\0';
    
    // Parse command
    argc = parse_command(command, argv);
    
    if (argc == 0) return;
    
    // Find and execute command
    for (int i = 0; commands[i].name; i++) {
        if (strcmp(argv[0], commands[i].name) == 0) {
            commands[i].handler(argc, argv);
            return;
        }
    }
    
    // Command not found
    serial_puts("Unknown command: ");
    serial_puts(argv[0]);
    serial_puts("\nType 'help' for available commands.\n");
}

// Command implementations
static void cmd_help(int argc, char* argv[]) {
    (void)argc; (void)argv;
    
    serial_puts("SAGE OS Enhanced Shell - Available Commands:\n");
    serial_puts("==========================================\n");
    
    for (int i = 0; commands[i].name; i++) {
        serial_puts("  ");
        serial_puts(commands[i].name);
        serial_puts(" - ");
        serial_puts(commands[i].description);
        serial_puts("\n");
    }
    
    serial_puts("\nFile Management Examples:\n");
    serial_puts("  save test.txt Hello World  - Save text to file\n");
    serial_puts("  cat test.txt               - Display file contents\n");
    serial_puts("  rm test.txt                - Delete file\n");
    serial_puts("  ls                         - List all files\n");
}

static void cmd_echo(int argc, char* argv[]) {
    for (int i = 1; i < argc; i++) {
        serial_puts(argv[i]);
        if (i < argc - 1) serial_putc(' ');
    }
    serial_putc('\n');
}

static void cmd_clear(int argc, char* argv[]) {
    (void)argc; (void)argv;
    serial_puts("\033[2J\033[H");
    serial_puts("SAGE OS Enhanced Shell - Screen Cleared\n");
}

static void cmd_meminfo(int argc, char* argv[]) {
    (void)argc; (void)argv;
    memory_stats();
}

static void cmd_reboot(int argc, char* argv[]) {
    (void)argc; (void)argv;
    serial_puts("Rebooting SAGE OS...\n");
    
    #if defined(__i386__) || defined(__x86_64__)
    __asm__ volatile("cli");
    while (1) {
        __asm__ volatile("hlt");
    }
    #endif
}

static void cmd_version(int argc, char* argv[]) {
    (void)argc; (void)argv;
    
    serial_puts("SAGE OS Enhanced Shell v1.0.1\n");
    serial_puts("Self-Aware General Environment Operating System\n");
    serial_puts("Copyright (c) 2025 Ashish Vasant Yesale\n");
    serial_puts("Designed by Ashish Yesale (ashishyesale007@gmail.com)\n");
    serial_puts("\nEnhanced Features:\n");
    serial_puts("- File management with persistent storage\n");
    serial_puts("- Advanced shell commands\n");
    serial_puts("- Improved keyboard input handling\n");
    serial_puts("- VGA graphics support\n");
    serial_puts("- Multi-architecture support\n");
    serial_puts("- Persistent memory storage\n");
}

static void cmd_exit(int argc, char* argv[]) {
    (void)argc; (void)argv;
    
    serial_puts("Shutting down SAGE OS Enhanced...\n");
    serial_puts("Thank you for using SAGE OS!\n");
    
    #if defined(__i386__) || defined(__x86_64__)
    __asm__ volatile("outw %%ax, %%dx" : : "a"(0x2000), "d"(0x604));
    #endif
    
    while (1) {
        __asm__ volatile("hlt");
    }
}

static void cmd_ls(int argc, char* argv[]) {
    (void)argc; (void)argv;
    
    char buffer[2048];
    int result = fs_list_files(buffer, sizeof(buffer));
    
    if (result >= 0) {
        serial_puts(buffer);
    } else {
        serial_puts("Error listing files\n");
    }
}

static void cmd_pwd(int argc, char* argv[]) {
    (void)argc; (void)argv;
    
    char current_dir[256];
    fs_get_current_directory(current_dir, sizeof(current_dir));
    serial_puts("Current directory: ");
    serial_puts(current_dir);
    serial_puts("\n");
}

static void cmd_cat(int argc, char* argv[]) {
    if (argc < 2) {
        serial_puts("Usage: cat <filename>\n");
        return;
    }
    
    char content[4096];
    int result = fs_cat(argv[1], content, sizeof(content));
    
    if (result >= 0) {
        serial_puts(content);
        if (strlen(content) > 0 && content[strlen(content) - 1] != '\n') {
            serial_puts("\n");
        }
    } else {
        serial_puts("File '");
        serial_puts(argv[1]);
        serial_puts("' not found\n");
    }
}

static void cmd_save(int argc, char* argv[]) {
    if (argc < 3) {
        serial_puts("Usage: save <filename> <content>\n");
        return;
    }
    
    // Combine all arguments after filename into content
    char content[4096];
    content[0] = '\0';
    
    for (int i = 2; i < argc; i++) {
        strcat(content, argv[i]);
        if (i < argc - 1) {
            strcat(content, " ");
        }
    }
    
    int result = fs_save(argv[1], content);
    if (result == 0) {
        serial_puts("Content saved to '");
        serial_puts(argv[1]);
        serial_puts("' successfully\n");
    } else {
        serial_puts("Failed to save content to '");
        serial_puts(argv[1]);
        serial_puts("'\n");
    }
}

static void cmd_rm(int argc, char* argv[]) {
    if (argc < 2) {
        serial_puts("Usage: rm <filename>\n");
        return;
    }
    
    int result = fs_delete_file(argv[1]);
    if (result == 0) {
        serial_puts("File '");
        serial_puts(argv[1]);
        serial_puts("' deleted successfully\n");
    } else {
        serial_puts("Failed to delete file '");
        serial_puts(argv[1]);
        serial_puts("' (file not found)\n");
    }
}

static void cmd_uptime(int argc, char* argv[]) {
    (void)argc; (void)argv;
    serial_puts("System uptime: Not implemented in enhanced build\n");
}

static void cmd_whoami(int argc, char* argv[]) {
    (void)argc; (void)argv;
    serial_puts("root\n");
}

// Copy file command
static void cmd_cp(int argc, char* argv[]) {
    if (argc < 3) {
        serial_puts("Usage: cp <source> <destination>\n");
        return;
    }
    
    char content[4096];
    int result = fs_cat(argv[1], content, sizeof(content));
    
    if (result >= 0) {
        int save_result = fs_save(argv[2], content);
        if (save_result == 0) {
            serial_puts("File '");
            serial_puts(argv[1]);
            serial_puts("' copied to '");
            serial_puts(argv[2]);
            serial_puts("' successfully\n");
        } else {
            serial_puts("Failed to copy file\n");
        }
    } else {
        serial_puts("Source file '");
        serial_puts(argv[1]);
        serial_puts("' not found\n");
    }
}

// Move/rename file command
static void cmd_mv(int argc, char* argv[]) {
    if (argc < 3) {
        serial_puts("Usage: mv <source> <destination>\n");
        return;
    }
    
    char content[4096];
    int result = fs_cat(argv[1], content, sizeof(content));
    
    if (result >= 0) {
        int save_result = fs_save(argv[2], content);
        if (save_result == 0) {
            int delete_result = fs_delete_file(argv[1]);
            if (delete_result == 0) {
                serial_puts("File '");
                serial_puts(argv[1]);
                serial_puts("' moved to '");
                serial_puts(argv[2]);
                serial_puts("' successfully\n");
            } else {
                serial_puts("File copied but failed to delete source\n");
            }
        } else {
            serial_puts("Failed to move file\n");
        }
    } else {
        serial_puts("Source file '");
        serial_puts(argv[1]);
        serial_puts("' not found\n");
    }
}

// Create directory command (placeholder - filesystem doesn't support directories yet)
static void cmd_mkdir(int argc, char* argv[]) {
    if (argc < 2) {
        serial_puts("Usage: mkdir <directory>\n");
        return;
    }
    
    serial_puts("Directory creation not yet implemented in filesystem\n");
    serial_puts("Creating placeholder file: ");
    serial_puts(argv[1]);
    serial_puts(".dir\n");
    
    char dir_content[256];
    strcpy(dir_content, "Directory placeholder for: ");
    strcat(dir_content, argv[1]);
    strcat(dir_content, "\nCreated by mkdir command\n");
    
    char dir_filename[256];
    strcpy(dir_filename, argv[1]);
    strcat(dir_filename, ".dir");
    
    fs_save(dir_filename, dir_content);
}

// Create empty file command
static void cmd_touch(int argc, char* argv[]) {
    if (argc < 2) {
        serial_puts("Usage: touch <filename>\n");
        return;
    }
    
    // Check if file exists
    char content[4096];
    int result = fs_cat(argv[1], content, sizeof(content));
    
    if (result < 0) {
        // File doesn't exist, create empty file
        int save_result = fs_save(argv[1], "");
        if (save_result == 0) {
            serial_puts("Empty file '");
            serial_puts(argv[1]);
            serial_puts("' created successfully\n");
        } else {
            serial_puts("Failed to create file '");
            serial_puts(argv[1]);
            serial_puts("'\n");
        }
    } else {
        serial_puts("File '");
        serial_puts(argv[1]);
        serial_puts("' already exists (timestamp updated)\n");
    }
}

// Find files by name command
static void cmd_find(int argc, char* argv[]) {
    if (argc < 2) {
        serial_puts("Usage: find <pattern>\n");
        serial_puts("Example: find test (finds files containing 'test')\n");
        return;
    }
    
    char buffer[2048];
    int result = fs_list_files(buffer, sizeof(buffer));
    
    if (result >= 0) {
        serial_puts("Files matching '");
        serial_puts(argv[1]);
        serial_puts("':\n");
        
        // Simple pattern matching - check if filename contains the pattern
        char* line = buffer;
        int found = 0;
        
        while (*line) {
            char* line_end = line;
            while (*line_end && *line_end != '\n') line_end++;
            
            // Extract filename from line (assuming format: "filename - size bytes")
            char* dash = line;
            while (dash < line_end && *dash != ' ') dash++;
            
            if (dash < line_end) {
                *dash = '\0';  // Temporarily null-terminate filename
                
                // Check if pattern is in filename
                char* found_pos = line;
                char* pattern = argv[1];
                int pattern_len = strlen(pattern);
                
                while (*found_pos) {
                    if (strncmp(found_pos, pattern, pattern_len) == 0) {
                        serial_puts("  ");
                        serial_puts(line);
                        serial_puts("\n");
                        found = 1;
                        break;
                    }
                    found_pos++;
                }
                
                *dash = ' ';  // Restore the space
            }
            
            line = (*line_end == '\n') ? line_end + 1 : line_end;
        }
        
        if (!found) {
            serial_puts("No files found matching '");
            serial_puts(argv[1]);
            serial_puts("'\n");
        }
    } else {
        serial_puts("Error listing files\n");
    }
}

// Search text in files command
static void cmd_grep(int argc, char* argv[]) {
    if (argc < 3) {
        serial_puts("Usage: grep <pattern> <filename>\n");
        serial_puts("Example: grep hello test.txt\n");
        return;
    }
    
    char content[4096];
    int result = fs_cat(argv[2], content, sizeof(content));
    
    if (result >= 0) {
        char* pattern = argv[1];
        char* line = content;
        int line_num = 1;
        int found = 0;
        
        while (*line) {
            char* line_end = line;
            while (*line_end && *line_end != '\n') line_end++;
            
            // Check if pattern is in this line
            char* search_pos = line;
            while (search_pos <= line_end - strlen(pattern)) {
                if (strncmp(search_pos, pattern, strlen(pattern)) == 0) {
                    // Found pattern, print line number and content
                    serial_puts("Line ");
                    char line_str[16];
                    sprintf(line_str, "%d", line_num);
                    serial_puts(line_str);
                    serial_puts(": ");
                    
                    // Print the line
                    char saved_char = *line_end;
                    *line_end = '\0';
                    serial_puts(line);
                    *line_end = saved_char;
                    serial_puts("\n");
                    
                    found = 1;
                    break;
                }
                search_pos++;
            }
            
            line = (*line_end == '\n') ? line_end + 1 : line_end;
            line_num++;
        }
        
        if (!found) {
            serial_puts("Pattern '");
            serial_puts(pattern);
            serial_puts("' not found in '");
            serial_puts(argv[2]);
            serial_puts("'\n");
        }
    } else {
        serial_puts("File '");
        serial_puts(argv[2]);
        serial_puts("' not found\n");
    }
}

// Word count command
static void cmd_wc(int argc, char* argv[]) {
    if (argc < 2) {
        serial_puts("Usage: wc <filename>\n");
        return;
    }
    
    char content[4096];
    int result = fs_cat(argv[1], content, sizeof(content));
    
    if (result >= 0) {
        int lines = 0, words = 0, chars = 0;
        int in_word = 0;
        char* ptr = content;
        
        while (*ptr) {
            chars++;
            
            if (*ptr == '\n') {
                lines++;
            }
            
            if (*ptr == ' ' || *ptr == '\t' || *ptr == '\n') {
                in_word = 0;
            } else if (!in_word) {
                words++;
                in_word = 1;
            }
            
            ptr++;
        }
        
        // If file doesn't end with newline, count the last line
        if (chars > 0 && content[chars-1] != '\n') {
            lines++;
        }
        
        char stats[256];
        sprintf(stats, "  %d lines, %d words, %d characters in '%s'\n", lines, words, chars, argv[1]);
        serial_puts(stats);
    } else {
        serial_puts("File '");
        serial_puts(argv[1]);
        serial_puts("' not found\n");
    }
}

// Show first lines of file
static void cmd_head(int argc, char* argv[]) {
    int num_lines = 10;  // Default
    char* filename;
    
    if (argc < 2) {
        serial_puts("Usage: head [-n lines] <filename>\n");
        return;
    }
    
    if (argc >= 4 && strcmp(argv[1], "-n") == 0) {
        num_lines = 0;
        char* num_str = argv[2];
        while (*num_str >= '0' && *num_str <= '9') {
            num_lines = num_lines * 10 + (*num_str - '0');
            num_str++;
        }
        filename = argv[3];
    } else {
        filename = argv[1];
    }
    
    char content[4096];
    int result = fs_cat(filename, content, sizeof(content));
    
    if (result >= 0) {
        char* line = content;
        int current_line = 0;
        
        while (*line && current_line < num_lines) {
            char* line_end = line;
            while (*line_end && *line_end != '\n') line_end++;
            
            // Print the line
            char saved_char = *line_end;
            *line_end = '\0';
            serial_puts(line);
            serial_puts("\n");
            *line_end = saved_char;
            
            current_line++;
            line = (*line_end == '\n') ? line_end + 1 : line_end;
        }
    } else {
        serial_puts("File '");
        serial_puts(filename);
        serial_puts("' not found\n");
    }
}

// Show last lines of file
static void cmd_tail(int argc, char* argv[]) {
    int num_lines = 10;  // Default
    char* filename;
    
    if (argc < 2) {
        serial_puts("Usage: tail [-n lines] <filename>\n");
        return;
    }
    
    if (argc >= 4 && strcmp(argv[1], "-n") == 0) {
        num_lines = 0;
        char* num_str = argv[2];
        while (*num_str >= '0' && *num_str <= '9') {
            num_lines = num_lines * 10 + (*num_str - '0');
            num_str++;
        }
        filename = argv[3];
    } else {
        filename = argv[1];
    }
    
    char content[4096];
    int result = fs_cat(filename, content, sizeof(content));
    
    if (result >= 0) {
        // Count total lines first
        int total_lines = 0;
        char* ptr = content;
        while (*ptr) {
            if (*ptr == '\n') total_lines++;
            ptr++;
        }
        if (strlen(content) > 0 && content[strlen(content)-1] != '\n') {
            total_lines++;
        }
        
        // Find starting line
        int start_line = (total_lines > num_lines) ? total_lines - num_lines : 0;
        
        char* line = content;
        int current_line = 0;
        
        // Skip to start line
        while (*line && current_line < start_line) {
            if (*line == '\n') current_line++;
            line++;
        }
        
        // Print remaining lines
        while (*line) {
            char* line_end = line;
            while (*line_end && *line_end != '\n') line_end++;
            
            // Print the line
            char saved_char = *line_end;
            *line_end = '\0';
            serial_puts(line);
            serial_puts("\n");
            *line_end = saved_char;
            
            line = (*line_end == '\n') ? line_end + 1 : line_end;
        }
    } else {
        serial_puts("File '");
        serial_puts(filename);
        serial_puts("' not found\n");
    }
}

// Show file statistics
static void cmd_stat(int argc, char* argv[]) {
    if (argc < 2) {
        serial_puts("Usage: stat <filename>\n");
        return;
    }
    
    char content[4096];
    int result = fs_cat(argv[1], content, sizeof(content));
    
    if (result >= 0) {
        int size = strlen(content);
        
        serial_puts("File: ");
        serial_puts(argv[1]);
        serial_puts("\n");
        
        char size_str[32];
        sprintf(size_str, "Size: %d bytes\n", size);
        serial_puts(size_str);
        
        // Count lines
        int lines = 0;
        char* ptr = content;
        while (*ptr) {
            if (*ptr == '\n') lines++;
            ptr++;
        }
        if (size > 0 && content[size-1] != '\n') lines++;
        
        char lines_str[32];
        sprintf(lines_str, "Lines: %d\n", lines);
        serial_puts(lines_str);
        
        serial_puts("Type: Regular file\n");
        serial_puts("Permissions: rw-r--r--\n");
    } else {
        serial_puts("File '");
        serial_puts(argv[1]);
        serial_puts("' not found\n");
    }
}