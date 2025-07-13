/* Minimal ARM64 kernel test */

void kernel_main() {
    // Try multiple UART addresses
    volatile unsigned int* uart_bases[] = {
        (volatile unsigned int*)0x09000000,  // QEMU virt
        (volatile unsigned int*)0x10000000,  // Alternative
        (volatile unsigned int*)0x3F201000,  // RPi
        0
    };
    
    int i = 0;
    while (uart_bases[i]) {
        // Try to write 'H' to each UART
        *(uart_bases[i]) = 'H';
        *(uart_bases[i]) = 'e';
        *(uart_bases[i]) = 'l';
        *(uart_bases[i]) = 'l';
        *(uart_bases[i]) = 'o';
        *(uart_bases[i]) = '\n';
        i++;
    }
    
    // Infinite loop
    while (1) {
        __asm__ volatile("wfi");
    }
}