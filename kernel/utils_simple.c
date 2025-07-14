/* SAGE OS Utils - Simple Version */

#include "types.h"

// Memory operations
void* memset(void* dest, int val, size_t len) {
    unsigned char* ptr = (unsigned char*)dest;
    while (len-- > 0) {
        *ptr++ = val;
    }
    return dest;
}

void* memcpy(void* dest, const void* src, size_t len) {
    unsigned char* d = (unsigned char*)dest;
    const unsigned char* s = (const unsigned char*)src;
    while (len--) {
        *d++ = *s++;
    }
    return dest;
}

// These string functions are already defined in stdio.c, so we'll omit them here
// to avoid multiple definition errors