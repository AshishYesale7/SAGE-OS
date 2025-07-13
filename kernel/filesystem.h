/* ─────────────────────────────────────────────────────────────────────────────
 * SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
 * SPDX-License-Identifier: BSD-3-Clause OR Proprietary
 * SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
 * 
 * This file is part of the SAGE OS Project.
 * ───────────────────────────────────────────────────────────────────────────── */

#ifndef FILESYSTEM_H
#define FILESYSTEM_H

#include "types.h"

#define MAX_FILES 64
#define MAX_FILENAME 32
#define MAX_FILESIZE 4096
#define MAX_PATH 128

typedef struct {
    char name[MAX_FILENAME];
    char content[MAX_FILESIZE];
    size_t size;
    uint32_t created_time;
    uint32_t modified_time;
    uint8_t is_used;
} file_t;

typedef struct {
    file_t files[MAX_FILES];
    char current_directory[MAX_PATH];
    uint32_t file_count;
    uint32_t total_memory_used;
} filesystem_t;

// File system functions
void fs_init(void);
int fs_create_file(const char* filename);
int fs_write_file(const char* filename, const char* content, size_t size);
int fs_read_file(const char* filename, char* buffer, size_t buffer_size);
int fs_delete_file(const char* filename);
int fs_list_files(char* buffer, size_t buffer_size);
int fs_file_exists(const char* filename);
size_t fs_get_file_size(const char* filename);
void fs_get_current_directory(char* buffer, size_t buffer_size);
int fs_change_directory(const char* path);
void fs_get_memory_info(uint32_t* total_files, uint32_t* memory_used, uint32_t* memory_available);

// File operations
int fs_cat(const char* filename, char* output, size_t output_size);
int fs_save(const char* filename, const char* content);
int fs_append(const char* filename, const char* content);

#endif // FILESYSTEM_H