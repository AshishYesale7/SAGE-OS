/* ─────────────────────────────────────────────────────────────────────────────
 * SAGE OS — Enhanced VGA Graphics Driver
 * Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
 * SPDX-License-Identifier: BSD-3-Clause OR Proprietary
 * ───────────────────────────────────────────────────────────────────────────── */

#include "vga.h"

#if defined(__i386__) || defined(__x86_64__)

#define VGA_WIDTH 80
#define VGA_HEIGHT 25
#define VGA_MEMORY 0xB8000

// Enhanced color definitions
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

static volatile uint16_t* vga_buffer = (volatile uint16_t*)VGA_MEMORY;
static size_t vga_row = 0;
static size_t vga_column = 0;
static uint8_t vga_color = 0x07; // Light grey on black
static int vga_initialized = 0;

// Enhanced color creation
static inline uint8_t vga_entry_color(vga_color_t fg, vga_color_t bg) {
    return fg | bg << 4;
}

// Enhanced character entry creation
static inline uint16_t vga_entry(unsigned char uc, uint8_t color) {
    return (uint16_t) uc | (uint16_t) color << 8;
}

// Enhanced VGA initialization
void vga_init(void) {
    vga_row = 0;
    vga_column = 0;
    vga_color = vga_entry_color(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
    
    // Clear the screen with enhanced styling
    for (size_t y = 0; y < VGA_HEIGHT; y++) {
        for (size_t x = 0; x < VGA_WIDTH; x++) {
            const size_t index = y * VGA_WIDTH + x;
            vga_buffer[index] = vga_entry(' ', vga_color);
        }
    }
    
    vga_initialized = 1;
}

// Enhanced color setting
void vga_set_color(uint8_t color) {
    vga_color = color;
}

// Set foreground and background colors separately
void vga_set_colors(vga_color_t fg, vga_color_t bg) {
    vga_color = vga_entry_color(fg, bg);
}

// Enhanced scrolling
static void vga_scroll(void) {
    // Move all lines up by one
    for (size_t y = 0; y < VGA_HEIGHT - 1; y++) {
        for (size_t x = 0; x < VGA_WIDTH; x++) {
            vga_buffer[y * VGA_WIDTH + x] = vga_buffer[(y + 1) * VGA_WIDTH + x];
        }
    }
    
    // Clear the last line
    for (size_t x = 0; x < VGA_WIDTH; x++) {
        vga_buffer[(VGA_HEIGHT - 1) * VGA_WIDTH + x] = vga_entry(' ', vga_color);
    }
    
    vga_row = VGA_HEIGHT - 1;
}

// Enhanced character output
void vga_putc(char c) {
    if (!vga_initialized) {
        vga_init();
    }
    
    if (c == '\n') {
        vga_column = 0;
        if (++vga_row == VGA_HEIGHT) {
            vga_scroll();
        }
        return;
    }
    
    if (c == '\r') {
        vga_column = 0;
        return;
    }
    
    if (c == '\b') {
        if (vga_column > 0) {
            vga_column--;
            vga_buffer[vga_row * VGA_WIDTH + vga_column] = vga_entry(' ', vga_color);
        }
        return;
    }
    
    if (c == '\t') {
        // Tab to next 4-character boundary
        size_t next_tab = (vga_column + 4) & ~3;
        while (vga_column < next_tab && vga_column < VGA_WIDTH) {
            vga_buffer[vga_row * VGA_WIDTH + vga_column] = vga_entry(' ', vga_color);
            vga_column++;
        }
        if (vga_column >= VGA_WIDTH) {
            vga_column = 0;
            if (++vga_row == VGA_HEIGHT) {
                vga_scroll();
            }
        }
        return;
    }
    
    // Regular character
    vga_buffer[vga_row * VGA_WIDTH + vga_column] = vga_entry(c, vga_color);
    
    if (++vga_column == VGA_WIDTH) {
        vga_column = 0;
        if (++vga_row == VGA_HEIGHT) {
            vga_scroll();
        }
    }
}

// Enhanced string output
void vga_puts(const char* str) {
    if (!str) return;
    
    while (*str) {
        vga_putc(*str++);
    }
}

// Enhanced formatted output
void vga_printf(const char* format, ...) {
    // Simple printf implementation for VGA
    // This is a basic version - you might want to implement a full printf
    vga_puts(format);
}

// Clear screen with enhanced styling
void vga_clear(void) {
    vga_init();
}

// Set cursor position
void vga_set_cursor(size_t x, size_t y) {
    if (x < VGA_WIDTH && y < VGA_HEIGHT) {
        vga_column = x;
        vga_row = y;
    }
}

// Get cursor position
void vga_get_cursor(size_t* x, size_t* y) {
    if (x) *x = vga_column;
    if (y) *y = vga_row;
}

// Draw a box with enhanced graphics characters
void vga_draw_box(size_t x, size_t y, size_t width, size_t height, uint8_t color) {
    if (!vga_initialized) {
        vga_init();
    }
    
    uint8_t old_color = vga_color;
    vga_color = color;
    
    // Draw box using ASCII characters
    for (size_t row = y; row < y + height && row < VGA_HEIGHT; row++) {
        for (size_t col = x; col < x + width && col < VGA_WIDTH; col++) {
            char ch = ' ';
            
            if (row == y || row == y + height - 1) {
                // Top or bottom border
                if (col == x || col == x + width - 1) {
                    ch = '+'; // Corner
                } else {
                    ch = '-'; // Horizontal line
                }
            } else if (col == x || col == x + width - 1) {
                ch = '|'; // Vertical line
            } else {
                ch = ' '; // Inside the box
            }
            
            vga_buffer[row * VGA_WIDTH + col] = vga_entry(ch, color);
        }
    }
    
    vga_color = old_color;
}

// Enhanced status bar
void vga_draw_status_bar(const char* text) {
    if (!vga_initialized) {
        vga_init();
    }
    
    uint8_t old_color = vga_color;
    vga_color = vga_entry_color(VGA_COLOR_BLACK, VGA_COLOR_LIGHT_GREY);
    
    // Clear the bottom line
    for (size_t x = 0; x < VGA_WIDTH; x++) {
        vga_buffer[(VGA_HEIGHT - 1) * VGA_WIDTH + x] = vga_entry(' ', vga_color);
    }
    
    // Write the status text
    if (text) {
        size_t len = 0;
        while (text[len] && len < VGA_WIDTH) {
            vga_buffer[(VGA_HEIGHT - 1) * VGA_WIDTH + len] = vga_entry(text[len], vga_color);
            len++;
        }
    }
    
    vga_color = old_color;
}

// Enhanced welcome screen
void vga_draw_welcome_screen(void) {
    vga_clear();
    
    // Set title color
    vga_set_colors(VGA_COLOR_LIGHT_CYAN, VGA_COLOR_BLACK);
    
    // Center the title
    size_t title_row = 5;
    const char* title_lines[] = {
        "  ███████╗ █████╗  ██████╗ ███████╗      ██████╗ ███████╗",
        "  ██╔════╝██╔══██╗██╔════╝ ██╔════╝     ██╔═══██╗██╔════╝",
        "  ███████╗███████║██║  ███╗█████╗       ██║   ██║███████╗",
        "  ╚════██║██╔══██║██║   ██║██╔══╝       ██║   ██║╚════██║",
        "  ███████║██║  ██║╚██████╔╝███████╗     ╚██████╔╝███████║",
        "  ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝      ╚═════╝ ╚══════╝"
    };
    
    for (int i = 0; i < 6; i++) {
        vga_set_cursor(10, title_row + i);
        vga_puts(title_lines[i]);
    }
    
    // Set subtitle color
    vga_set_colors(VGA_COLOR_LIGHT_GREEN, VGA_COLOR_BLACK);
    vga_set_cursor(15, title_row + 8);
    vga_puts("Self-Aware General Environment Operating System");
    
    vga_set_colors(VGA_COLOR_WHITE, VGA_COLOR_BLACK);
    vga_set_cursor(25, title_row + 9);
    vga_puts("Enhanced Version 1.0.1");
    
    vga_set_cursor(22, title_row + 10);
    vga_puts("Designed by Ashish Yesale");
    
    // Draw a decorative box
    vga_draw_box(5, title_row + 12, 70, 5, vga_entry_color(VGA_COLOR_YELLOW, VGA_COLOR_BLACK));
    
    vga_set_colors(VGA_COLOR_LIGHT_YELLOW, VGA_COLOR_BLACK);
    vga_set_cursor(10, title_row + 14);
    vga_puts("Enhanced Features: File Management, Graphics, Persistent Storage");
    
    // Status bar
    vga_draw_status_bar("SAGE OS Enhanced - Press any key to continue...");
    
    // Reset to normal colors
    vga_set_colors(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
}

#else

// Stub implementations for non-x86 architectures
void vga_init(void) {}
void vga_set_color(uint8_t color) { (void)color; }
void vga_putc(char c) { (void)c; }
void vga_puts(const char* str) { (void)str; }
void vga_clear(void) {}
void vga_set_cursor(size_t x, size_t y) { (void)x; (void)y; }
void vga_get_cursor(size_t* x, size_t* y) { (void)x; (void)y; }
void vga_draw_box(size_t x, size_t y, size_t width, size_t height, uint8_t color) { 
    (void)x; (void)y; (void)width; (void)height; (void)color; 
}
void vga_draw_status_bar(const char* text) { (void)text; }
void vga_draw_welcome_screen(void) {}
void vga_set_colors(int fg, int bg) { (void)fg; (void)bg; }

#endif