/* ─────────────────────────────────────────────────────────────────────────────
 * SAGE OS — Enhanced VGA Graphics Driver Header
 * Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
 * SPDX-License-Identifier: BSD-3-Clause OR Proprietary
 * ───────────────────────────────────────────────────────────────────────────── */

#ifndef ENHANCED_VGA_H
#define ENHANCED_VGA_H

#include "../kernel/types.h"

// Enhanced VGA color definitions
typedef enum {
    VGA_COLOR_BLACK = 0,
    VGA_COLOR_BLUE = 1,
    VGA_COLOR_GREEN = 2,
    VGA_COLOR_CYAN = 3,
    VGA_COLOR_RED = 4,
    VGA_COLOR_MAGENTA = 5,
    VGA_COLOR_BROWN = 6,
    VGA_COLOR_LIGHT_GREY = 7,
    VGA_COLOR_DARK_GREY = 8,
    VGA_COLOR_LIGHT_BLUE = 9,
    VGA_COLOR_LIGHT_GREEN = 10,
    VGA_COLOR_LIGHT_CYAN = 11,
    VGA_COLOR_LIGHT_RED = 12,
    VGA_COLOR_LIGHT_MAGENTA = 13,
    VGA_COLOR_LIGHT_BROWN = 14,
    VGA_COLOR_WHITE = 15,
} vga_color_t;

// Enhanced VGA functions
void vga_init(void);
void vga_set_color(uint8_t color);
void vga_set_colors(vga_color_t fg, vga_color_t bg);
void vga_putc(char c);
void vga_puts(const char* str);
void vga_printf(const char* format, ...);
void vga_clear(void);
void vga_set_cursor(size_t x, size_t y);
void vga_get_cursor(size_t* x, size_t* y);
void vga_draw_box(size_t x, size_t y, size_t width, size_t height, uint8_t color);
void vga_draw_status_bar(const char* text);
void vga_draw_welcome_screen(void);

#endif // ENHANCED_VGA_H