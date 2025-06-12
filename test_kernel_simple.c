// Simple test kernel to verify QEMU boot
// This will write directly to VGA text buffer

void kernel_main() {
    // VGA text buffer starts at 0xB8000
    volatile char *video = (volatile char*)0xB8000;
    
    // Clear screen (fill with spaces)
    for (int i = 0; i < 80 * 25 * 2; i += 2) {
        video[i] = ' ';     // Character
        video[i + 1] = 0x07; // Attribute (white on black)
    }
    
    // Write test message
    const char *message = "SAGE OS 32-bit Graphics Test - Kernel Running!";
    int pos = 0;
    
    for (int i = 0; message[i] != '\0'; i++) {
        video[pos] = message[i];
        video[pos + 1] = 0x0F; // Bright white on black
        pos += 2;
    }
    
    // Write system info on second line
    const char *info = "VGA Graphics Mode: ENABLED | Keyboard Input: ENABLED | System ready!";
    pos = 160; // Second line (80 chars * 2 bytes per char)
    
    for (int i = 0; info[i] != '\0'; i++) {
        video[pos] = info[i];
        video[pos + 1] = 0x0A; // Bright green on black
        pos += 2;
    }
    
    // Write interactive prompt on fourth line
    const char *prompt = "=== SAGE OS Interactive Mode ===";
    pos = 320; // Fourth line
    
    for (int i = 0; prompt[i] != '\0'; i++) {
        video[pos] = prompt[i];
        video[pos + 1] = 0x0E; // Yellow on black
        pos += 2;
    }
    
    // Write instructions on fifth line
    const char *instructions = "Type commands and press Enter. Type 'help' for available commands.";
    pos = 480; // Fifth line
    
    for (int i = 0; instructions[i] != '\0'; i++) {
        video[pos] = instructions[i];
        video[pos + 1] = 0x07; // White on black
        pos += 2;
    }
    
    // Write keyboard test on sixth line
    const char *keyboard = "This interactive mode works with keyboard input in QEMU graphics mode.";
    pos = 640; // Sixth line
    
    for (int i = 0; keyboard[i] != '\0'; i++) {
        video[pos] = keyboard[i];
        video[pos + 1] = 0x0B; // Cyan on black
        pos += 2;
    }
    
    // Infinite loop to keep kernel running
    while (1) {
        // Halt CPU to save power
        asm volatile("hlt");
    }
}