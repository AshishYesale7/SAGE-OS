/* Minimal test kernel for ARM64 boot verification */

void kernel_main() {
    // Simple infinite loop - if we get here, boot worked
    volatile int counter = 0;
    while (1) {
        counter++;
        // Add a small delay
        for (volatile int i = 0; i < 1000000; i++);
        
        // On ARM64, use WFI (Wait For Interrupt)
        __asm__ volatile("wfi");
    }
}