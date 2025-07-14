/* ─────────────────────────────────────────────────────────────────────────────
 * SAGE OS — Enhanced File System Implementation
 * Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
 * SPDX-License-Identifier: BSD-3-Clause OR Proprietary
 * ───────────────────────────────────────────────────────────────────────────── */

#include "filesystem.h"
#include "../drivers/serial.h"
#include "memory.h"
#include "stdio.h"
#include "utils.h"

#define MAX_FILES 64
#define MAX_FILENAME 128
#define MAX_FILESIZE 2048
#define MAX_DIRECTORIES 16

typedef struct {
    char name[MAX_FILENAME];
    char content[MAX_FILESIZE];
    size_t size;
    int is_used;
    uint32_t created_time;
    uint32_t modified_time;
    uint32_t permissions;
} enhanced_file_entry_t;

typedef struct {
    char name[MAX_FILENAME];
    int is_used;
    uint32_t created_time;
} directory_entry_t;

static enhanced_file_entry_t enhanced_files[MAX_FILES];
static directory_entry_t directories[MAX_DIRECTORIES];
static int enhanced_fs_initialized = 0;
static char current_directory[256] = "/";
static uint32_t system_time = 0;

// Simple time counter (incremented on each file operation)
static uint32_t get_enhanced_system_time() {
    return ++system_time;
}

void enhanced_fs_init() {
    if (enhanced_fs_initialized) {
        return;
    }
    
    // Initialize all file entries
    for (int i = 0; i < MAX_FILES; i++) {
        enhanced_files[i].is_used = 0;
        enhanced_files[i].name[0] = '\0';
        enhanced_files[i].content[0] = '\0';
        enhanced_files[i].size = 0;
        enhanced_files[i].created_time = 0;
        enhanced_files[i].modified_time = 0;
        enhanced_files[i].permissions = 0644; // Default permissions
    }
    
    // Initialize directories
    for (int i = 0; i < MAX_DIRECTORIES; i++) {
        directories[i].is_used = 0;
        directories[i].name[0] = '\0';
        directories[i].created_time = 0;
    }
    
    // Create root directory
    strcpy(directories[0].name, "/");
    directories[0].is_used = 1;
    directories[0].created_time = get_enhanced_system_time();
    
    enhanced_fs_initialized = 1;
    serial_puts("Enhanced file system initialized with persistent storage\n");
    
    // Create some default files with enhanced features
    enhanced_fs_save("welcome.txt", "Welcome to SAGE OS Enhanced!\n\nThis enhanced file system supports:\n- Persistent storage in memory\n- File timestamps\n- Advanced file operations\n- Command history\n\nType 'help' for available commands.\n");
    enhanced_fs_save("commands.txt", "SAGE OS Enhanced Commands:\n========================\n\nFile Operations:\n- save <file> <content>  - Save text to file\n- cat <file>            - Display file contents\n- append <file> <text>  - Append text to file\n- cp <src> <dest>       - Copy file\n- mv <src> <dest>       - Move/rename file\n- rm <file>             - Delete file\n- ls                    - List files\n- find <pattern>        - Find files by name\n- grep <pattern> <file> - Search text in file\n- wc <file>             - Count lines/words/chars\n\nSystem Commands:\n- help                  - Show all commands\n- clear                 - Clear screen\n- version               - Show OS version\n- meminfo               - Show memory info\n- history               - Show command history\n- pwd                   - Show current directory\n- exit                  - Exit SAGE OS\n");
    enhanced_fs_save("system.log", "SAGE OS Enhanced System Log\n===========================\n\nSystem startup completed successfully.\nEnhanced file system initialized.\nPersistent memory storage enabled.\nAdvanced shell commands loaded.\n\nReady for user interaction.\n");
}

int enhanced_fs_save(const char* filename, const char* content) {
    if (!filename || !content || strlen(filename) >= MAX_FILENAME) {
        return -1;
    }
    
    // Find existing file or empty slot
    int slot = -1;
    for (int i = 0; i < MAX_FILES; i++) {
        if (enhanced_files[i].is_used && strcmp(enhanced_files[i].name, filename) == 0) {
            slot = i;
            break;
        }
        if (!enhanced_files[i].is_used && slot == -1) {
            slot = i;
        }
    }
    
    if (slot == -1) {
        return -2; // No space available
    }
    
    // Save file
    strcpy(enhanced_files[slot].name, filename);
    strncpy(enhanced_files[slot].content, content, MAX_FILESIZE - 1);
    enhanced_files[slot].content[MAX_FILESIZE - 1] = '\0';
    enhanced_files[slot].size = strlen(enhanced_files[slot].content);
    enhanced_files[slot].modified_time = get_enhanced_system_time();
    
    if (!enhanced_files[slot].is_used) {
        enhanced_files[slot].created_time = enhanced_files[slot].modified_time;
        enhanced_files[slot].is_used = 1;
    }
    
    return 0;
}

int enhanced_fs_append(const char* filename, const char* content) {
    if (!filename || !content || strlen(filename) >= MAX_FILENAME) {
        return -1;
    }
    
    // Find existing file
    for (int i = 0; i < MAX_FILES; i++) {
        if (enhanced_files[i].is_used && strcmp(enhanced_files[i].name, filename) == 0) {
            size_t current_len = strlen(enhanced_files[i].content);
            size_t append_len = strlen(content);
            
            if (current_len + append_len < MAX_FILESIZE - 1) {
                strcat(enhanced_files[i].content, content);
                enhanced_files[i].size = strlen(enhanced_files[i].content);
                enhanced_files[i].modified_time = get_enhanced_system_time();
                return 0;
            } else {
                return -3; // File too large
            }
        }
    }
    
    return -2; // File not found
}

int enhanced_fs_cat(const char* filename, char* buffer, size_t buffer_size) {
    if (!filename || !buffer || buffer_size == 0) {
        return -1;
    }
    
    for (int i = 0; i < MAX_FILES; i++) {
        if (enhanced_files[i].is_used && strcmp(enhanced_files[i].name, filename) == 0) {
            strncpy(buffer, enhanced_files[i].content, buffer_size - 1);
            buffer[buffer_size - 1] = '\0';
            return enhanced_files[i].size;
        }
    }
    
    return -2; // File not found
}

int enhanced_fs_delete_file(const char* filename) {
    if (!filename) {
        return -1;
    }
    
    for (int i = 0; i < MAX_FILES; i++) {
        if (enhanced_files[i].is_used && strcmp(enhanced_files[i].name, filename) == 0) {
            enhanced_files[i].is_used = 0;
            enhanced_files[i].name[0] = '\0';
            enhanced_files[i].content[0] = '\0';
            enhanced_files[i].size = 0;
            return 0;
        }
    }
    
    return -2; // File not found
}

int enhanced_fs_list_files(char* buffer, size_t buffer_size) {
    if (!buffer || buffer_size == 0) {
        return -1;
    }
    
    buffer[0] = '\0';
    int file_count = 0;
    
    strcat(buffer, "Files in SAGE OS Enhanced File System:\n");
    strcat(buffer, "=====================================\n\n");
    
    for (int i = 0; i < MAX_FILES; i++) {
        if (enhanced_files[i].is_used) {
            char file_info[256];
            sprintf(file_info, "%-20s %6zu bytes  [Created: %u, Modified: %u]\n", 
                    enhanced_files[i].name, 
                    enhanced_files[i].size,
                    enhanced_files[i].created_time,
                    enhanced_files[i].modified_time);
            
            if (strlen(buffer) + strlen(file_info) < buffer_size - 1) {
                strcat(buffer, file_info);
                file_count++;
            }
        }
    }
    
    if (file_count == 0) {
        strcat(buffer, "No files found.\n");
    } else {
        char summary[128];
        sprintf(summary, "\nTotal: %d files\n", file_count);
        if (strlen(buffer) + strlen(summary) < buffer_size - 1) {
            strcat(buffer, summary);
        }
    }
    
    return file_count;
}

void enhanced_fs_get_current_directory(char* buffer, size_t buffer_size) {
    if (buffer && buffer_size > 0) {
        strncpy(buffer, current_directory, buffer_size - 1);
        buffer[buffer_size - 1] = '\0';
    }
}

void enhanced_fs_get_memory_info(uint32_t* total_files, uint32_t* memory_used, uint32_t* memory_available) {
    uint32_t used_files = 0;
    uint32_t used_memory = 0;
    
    for (int i = 0; i < MAX_FILES; i++) {
        if (enhanced_files[i].is_used) {
            used_files++;
            used_memory += enhanced_files[i].size;
        }
    }
    
    if (total_files) *total_files = used_files;
    if (memory_used) *memory_used = used_memory;
    if (memory_available) *memory_available = (MAX_FILES * MAX_FILESIZE) - used_memory;
}

// Wrapper functions to maintain compatibility with existing filesystem interface
void fs_init(void) {
    enhanced_fs_init();
}

int fs_save(const char* filename, const char* content) {
    return enhanced_fs_save(filename, content);
}

int fs_append(const char* filename, const char* content) {
    return enhanced_fs_append(filename, content);
}

int fs_cat(const char* filename, char* buffer, size_t buffer_size) {
    return enhanced_fs_cat(filename, buffer, buffer_size);
}

int fs_delete_file(const char* filename) {
    return enhanced_fs_delete_file(filename);
}

int fs_list_files(char* buffer, size_t buffer_size) {
    return enhanced_fs_list_files(buffer, buffer_size);
}

void fs_get_current_directory(char* buffer, size_t buffer_size) {
    enhanced_fs_get_current_directory(buffer, buffer_size);
}

void fs_get_memory_info(uint32_t* total_files, uint32_t* memory_used, uint32_t* memory_available) {
    enhanced_fs_get_memory_info(total_files, memory_used, memory_available);
}