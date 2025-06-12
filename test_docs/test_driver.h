
/*
 * SAGE-OS Test Driver Header
 * Defines interfaces for test drivers
 */

#ifndef TEST_DRIVER_H
#define TEST_DRIVER_H

#include <stdint.h>

// Driver types
typedef enum {
    DRIVER_TYPE_VGA,
    DRIVER_TYPE_SERIAL,
    DRIVER_TYPE_KEYBOARD,
    DRIVER_TYPE_AI_HAT
} driver_type_t;

// Driver structure
typedef struct {
    driver_type_t type;
    uint32_t id;
    char name[32];
    void *private_data;
    
    // Function pointers
    int (*init)(void *data);
    int (*read)(void *buffer, size_t size);
    int (*write)(const void *buffer, size_t size);
    void (*cleanup)(void);
} test_driver_t;

// Function declarations
int register_test_driver(test_driver_t *driver);
int unregister_test_driver(uint32_t driver_id);
test_driver_t *get_test_driver(uint32_t driver_id);
void list_test_drivers(void);

// VGA driver functions
int vga_driver_init(void *data);
int vga_driver_write(const void *buffer, size_t size);
void vga_driver_cleanup(void);

// Serial driver functions
int serial_driver_init(void *data);
int serial_driver_read(void *buffer, size_t size);
int serial_driver_write(const void *buffer, size_t size);
void serial_driver_cleanup(void);

// Keyboard driver functions
int keyboard_driver_init(void *data);
int keyboard_driver_read(void *buffer, size_t size);
void keyboard_driver_cleanup(void);

// AI HAT+ driver functions
int ai_hat_driver_init(void *data);
int ai_hat_driver_process(const void *input, void *output);
void ai_hat_driver_cleanup(void);

#endif // TEST_DRIVER_H
