/* Debug kernel to test SAGE OS functionality without serial */

// Dummy serial functions that don't actually output
void serial_init(void) {
    // Do nothing
}

void serial_putc(char c) {
    // Do nothing
}

void serial_puts(const char* str) {
    // Do nothing
}

// Simple memory operations to verify kernel is working
static volatile int test_counter = 0;
static volatile char test_buffer[1024];

void kernel_main() {
    // Test basic functionality without serial output
    
    // Test 1: Basic arithmetic
    test_counter = 42;
    test_counter += 58;  // Should be 100
    
    // Test 2: Memory operations
    for (int i = 0; i < 1024; i++) {
        test_buffer[i] = (char)(i % 256);
    }
    
    // Test 3: Verify memory writes
    int checksum = 0;
    for (int i = 0; i < 1024; i++) {
        checksum += test_buffer[i];
    }
    
    // Test 4: Simple loop with delay
    for (int loop = 0; loop < 10; loop++) {
        test_counter++;
        
        // Add delay
        for (volatile int delay = 0; delay < 1000000; delay++);
        
        // ARM64 wait for interrupt
        __asm__ volatile("wfi");
    }
    
    // If we reach here, basic kernel functionality works
    // Final infinite loop
    while (1) {
        test_counter++;
        
        // Longer delay
        for (volatile int delay = 0; delay < 10000000; delay++);
        
        __asm__ volatile("wfi");
    }
}