/* ─────────────────────────────────────────────────────────────────────────────
 * SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
 * SPDX-License-Identifier: BSD-3-Clause OR Proprietary
 * SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
 * 
 * This file is part of the SAGE OS Project.
 * ───────────────────────────────────────────────────────────────────────────── */

#include "filesystem.h"
#include "utils.h"
#include "stdio.h"
#include "../drivers/serial.h"

static filesystem_t fs;
static uint32_t system_time = 0;

// Simple time counter (incremented by system)
uint32_t get_system_time(void) {
    return ++system_time;
}

void fs_init(void) {
    // Initialize file system
    for (int i = 0; i < MAX_FILES; i++) {
        fs.files[i].is_used = 0;
        fs.files[i].size = 0;
        fs.files[i].name[0] = '\0';
        fs.files[i].content[0] = '\0';
    }
    
    // Set root directory
    strcpy(fs.current_directory, "/");
    fs.file_count = 0;
    fs.total_memory_used = 0;
    
    // Create some default files
    fs_save("welcome.txt", "Welcome to SAGE OS!\nThis is your advanced ARM64 operating system.\n");
    fs_save("readme.txt", "SAGE OS File System\n==================\n\nCommands:\n- save <filename> <content>\n- cat <filename>\n- ls\n- pwd\n- help\n");
}

int fs_create_file(const char* filename) {
    if (!filename || strlen(filename) == 0 || strlen(filename) >= MAX_FILENAME) {
        return -1; // Invalid filename
    }
    
    // Check if file already exists
    if (fs_file_exists(filename)) {
        return -2; // File already exists
    }
    
    // Find empty slot
    for (int i = 0; i < MAX_FILES; i++) {
        if (!fs.files[i].is_used) {
            strcpy(fs.files[i].name, filename);
            fs.files[i].content[0] = '\0';
            fs.files[i].size = 0;
            fs.files[i].created_time = get_system_time();
            fs.files[i].modified_time = fs.files[i].created_time;
            fs.files[i].is_used = 1;
            fs.file_count++;
            return i; // Return file index
        }
    }
    
    return -3; // No space available
}

int fs_write_file(const char* filename, const char* content, size_t size) {
    if (!filename || !content || size >= MAX_FILESIZE) {
        return -1;
    }
    
    // Find file
    for (int i = 0; i < MAX_FILES; i++) {
        if (fs.files[i].is_used && strcmp(fs.files[i].name, filename) == 0) {
            // Update total memory usage
            fs.total_memory_used -= fs.files[i].size;
            
            // Copy content
            strncpy(fs.files[i].content, content, size);
            fs.files[i].content[size] = '\0';
            fs.files[i].size = size;
            fs.files[i].modified_time = get_system_time();
            
            // Update total memory usage
            fs.total_memory_used += size;
            return 0;
        }
    }
    
    return -1; // File not found
}

int fs_read_file(const char* filename, char* buffer, size_t buffer_size) {
    if (!filename || !buffer) {
        return -1;
    }
    
    for (int i = 0; i < MAX_FILES; i++) {
        if (fs.files[i].is_used && strcmp(fs.files[i].name, filename) == 0) {
            size_t copy_size = (fs.files[i].size < buffer_size - 1) ? fs.files[i].size : buffer_size - 1;
            strncpy(buffer, fs.files[i].content, copy_size);
            buffer[copy_size] = '\0';
            return (int)fs.files[i].size;
        }
    }
    
    return -1; // File not found
}

int fs_delete_file(const char* filename) {
    if (!filename) {
        return -1;
    }
    
    for (int i = 0; i < MAX_FILES; i++) {
        if (fs.files[i].is_used && strcmp(fs.files[i].name, filename) == 0) {
            fs.total_memory_used -= fs.files[i].size;
            fs.files[i].is_used = 0;
            fs.files[i].size = 0;
            fs.files[i].name[0] = '\0';
            fs.files[i].content[0] = '\0';
            fs.file_count--;
            return 0;
        }
    }
    
    return -1; // File not found
}

int fs_list_files(char* buffer, size_t buffer_size) {
    if (!buffer) {
        return -1;
    }
    
    buffer[0] = '\0';
    char temp[256];
    
    sprintf(temp, "Files in %s:\n", fs.current_directory);
    strcat(buffer, temp);
    strcat(buffer, "Name                Size    Created   Modified\n");
    strcat(buffer, "--------------------------------------------\n");
    
    int file_count = 0;
    for (int i = 0; i < MAX_FILES; i++) {
        if (fs.files[i].is_used) {
            sprintf(temp, "%s  %zu  %u  %u\n", 
                   fs.files[i].name, 
                   fs.files[i].size,
                   fs.files[i].created_time,
                   fs.files[i].modified_time);
            strcat(buffer, temp);
            file_count++;
        }
    }
    
    if (file_count == 0) {
        strcat(buffer, "(no files)\n");
    }
    
    sprintf(temp, "\nTotal: %d files, %u bytes used\n", file_count, fs.total_memory_used);
    strcat(buffer, temp);
    
    return file_count;
}

int fs_file_exists(const char* filename) {
    if (!filename) {
        return 0;
    }
    
    for (int i = 0; i < MAX_FILES; i++) {
        if (fs.files[i].is_used && strcmp(fs.files[i].name, filename) == 0) {
            return 1;
        }
    }
    
    return 0;
}

size_t fs_get_file_size(const char* filename) {
    if (!filename) {
        return 0;
    }
    
    for (int i = 0; i < MAX_FILES; i++) {
        if (fs.files[i].is_used && strcmp(fs.files[i].name, filename) == 0) {
            return fs.files[i].size;
        }
    }
    
    return 0;
}

void fs_get_current_directory(char* buffer, size_t buffer_size) {
    if (buffer) {
        strncpy(buffer, fs.current_directory, buffer_size - 1);
        buffer[buffer_size - 1] = '\0';
    }
}

int fs_change_directory(const char* path) {
    // Simple implementation - only support root for now
    if (path && strcmp(path, "/") == 0) {
        strcpy(fs.current_directory, "/");
        return 0;
    }
    return -1;
}

void fs_get_memory_info(uint32_t* total_files, uint32_t* memory_used, uint32_t* memory_available) {
    if (total_files) *total_files = fs.file_count;
    if (memory_used) *memory_used = fs.total_memory_used;
    if (memory_available) *memory_available = (MAX_FILES * MAX_FILESIZE) - fs.total_memory_used;
}

// High-level file operations
int fs_cat(const char* filename, char* output, size_t output_size) {
    return fs_read_file(filename, output, output_size);
}

int fs_save(const char* filename, const char* content) {
    if (!filename || !content) {
        return -1;
    }
    
    size_t content_size = strlen(content);
    
    // Create file if it doesn't exist
    if (!fs_file_exists(filename)) {
        int result = fs_create_file(filename);
        if (result < 0) {
            return result;
        }
    }
    
    // Write content to file
    return fs_write_file(filename, content, content_size);
}

int fs_append(const char* filename, const char* content) {
    if (!filename || !content) {
        return -1;
    }
    
    char existing_content[MAX_FILESIZE];
    existing_content[0] = '\0';
    
    // Read existing content if file exists
    if (fs_file_exists(filename)) {
        fs_read_file(filename, existing_content, sizeof(existing_content));
    }
    
    // Append new content
    size_t existing_len = strlen(existing_content);
    size_t new_len = strlen(content);
    
    if (existing_len + new_len >= MAX_FILESIZE) {
        return -1; // Not enough space
    }
    
    strcat(existing_content, content);
    
    return fs_save(filename, existing_content);
}