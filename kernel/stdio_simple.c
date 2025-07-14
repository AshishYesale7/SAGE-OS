/* SAGE OS stdio - Simple Version */

#include "types.h"
#include "../drivers/serial.h"

// String functions
size_t strlen(const char* str) {
    size_t len = 0;
    while (str[len]) {
        len++;
    }
    return len;
}

int strcmp(const char* s1, const char* s2) {
    while (*s1 && (*s1 == *s2)) {
        s1++;
        s2++;
    }
    return *(const unsigned char*)s1 - *(const unsigned char*)s2;
}

char* strcpy(char* dest, const char* src) {
    char* d = dest;
    while ((*d++ = *src++));
    return dest;
}

char* strncpy(char* dest, const char* src, size_t n) {
    size_t i;
    for (i = 0; i < n && src[i] != '\0'; i++) {
        dest[i] = src[i];
    }
    for (; i < n; i++) {
        dest[i] = '\0';
    }
    return dest;
}

char* strcat(char* dest, const char* src) {
    char* d = dest;
    // Find the end of the destination string
    while (*d) {
        d++;
    }
    // Copy the source string to the end of the destination string
    while ((*d++ = *src++));
    return dest;
}

// Memory functions
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

// Simplified printf implementation
int sprintf(char* str, const char* format, ...) {
    char* s = str;
    __builtin_va_list args;
    __builtin_va_start(args, format);
    
    while (*format) {
        if (*format == '%') {
            format++;
            switch (*format) {
                case 's': {
                    char* arg = __builtin_va_arg(args, char*);
                    while (*arg) {
                        *s++ = *arg++;
                    }
                    break;
                }
                case 'd': {
                    int arg = __builtin_va_arg(args, int);
                    if (arg < 0) {
                        *s++ = '-';
                        arg = -arg;
                    }
                    
                    // Convert to string (reversed)
                    char temp[12];
                    int i = 0;
                    do {
                        temp[i++] = '0' + (arg % 10);
                        arg /= 10;
                    } while (arg > 0);
                    
                    // Copy in correct order
                    while (i > 0) {
                        *s++ = temp[--i];
                    }
                    break;
                }
                case 'c': {
                    char arg = (char)__builtin_va_arg(args, int);
                    *s++ = arg;
                    break;
                }
                case 'u': {
                    unsigned int arg = __builtin_va_arg(args, unsigned int);
                    
                    // Convert to string (reversed)
                    char temp[12];
                    int i = 0;
                    do {
                        temp[i++] = '0' + (arg % 10);
                        arg /= 10;
                    } while (arg > 0);
                    
                    // Copy in correct order
                    while (i > 0) {
                        *s++ = temp[--i];
                    }
                    break;
                }
                case 'x': {
                    unsigned int arg = __builtin_va_arg(args, unsigned int);
                    
                    // Convert to hex string (reversed)
                    char temp[12];
                    int i = 0;
                    do {
                        unsigned int digit = arg % 16;
                        temp[i++] = digit < 10 ? '0' + digit : 'a' + digit - 10;
                        arg /= 16;
                    } while (arg > 0);
                    
                    // Copy in correct order
                    while (i > 0) {
                        *s++ = temp[--i];
                    }
                    break;
                }
                case '%':
                    *s++ = '%';
                    break;
                default:
                    *s++ = '%';
                    *s++ = *format;
                    break;
            }
        } else {
            *s++ = *format;
        }
        format++;
    }
    
    *s = '\0';
    __builtin_va_end(args);
    return s - str;
}