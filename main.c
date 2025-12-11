#include <stdint.h>

/* UART registers - adjust for your platform */
#define UART_BASE 0x02500000
#define UART_THR  (*(volatile uint32_t*)(UART_BASE + 0x00))
#define UART_LSR  (*(volatile uint32_t*)(UART_BASE + 0x14))

void delay(int count) {
    volatile int i;
    for (i = 0; i < count; i++) {
        __asm__ __volatile__ ("nop");
    }
}

void uart_putc(char c) {
    while ((UART_LSR & 0x20) == 0);
    UART_THR = c;
}

void print(const char *s) {
    while (*s) {
        if (*s == '\n') uart_putc('\r');
        uart_putc(*s++);
    }
}

void print_hex(uint32_t val) {
    const char hex[] = "0123456789ABCDEF";
    uart_putc('0');
    uart_putc('x');
    for (int i = 28; i >= 0; i -= 4) {
        uart_putc(hex[(val >> i) & 0xF]);
    }
}

int32_t test_mac(void) {
    int32_t a = 100;
    int32_t b = 200;
    int32_t c = 300;
    return a + (b * c);
}

void test_vector_add(void) {
    volatile int16_t vec_a[8] = {1, 2, 3, 4, 5, 6, 7, 8};
    volatile int16_t vec_b[8] = {10, 20, 30, 40, 50, 60, 70, 80};
    volatile int16_t vec_c[8];
    
    for (int i = 0; i < 8; i++) {
        vec_c[i] = vec_a[i] + vec_b[i];
    }
    
    print("Vector add results: ");
    for (int i = 0; i < 8; i++) {
        print_hex(vec_c[i]);
        uart_putc(' ');
    }
    print("\n");
}

void recursive(int i) {
    delay(100000);
    print("recursive = ");
    print_hex(i);
    print("\n\n");
    recursive(i+1);
}

void main(void) {
    delay(1000000);
    
    print("\n=== HiFi4 DSP Test Application ===\n");
    print("Running on Allwinner R528 HiFi4 DSP\n\n");
    
    print("Test 1: Basic Arithmetic\n");
    int sum = 42 + 58;
    print("  42 + 58 = ");
    print_hex(sum);
    print("\n\n");
    
    print("Test 2: MAC Operation\n");
    int32_t mac_result = test_mac();
    print("  100 + (200 * 300) = ");
    print_hex(mac_result);
    print("\n\n");
    
    print("Test 3: Vector Operations\n");
    test_vector_add();
    print("\n");

    // recursive(0);
    
    // print("Test 4: Memory Test\n");
    // volatile uint32_t *test_mem = (uint32_t*)0x42000100;
    // *test_mem = 0xDEADBEEF;
    // uint32_t readback = *test_mem;
    // print("  Write 0xDEADBEEF, Read back: ");
    // print_hex(readback);
    // print("\n\n");
    
    print("=== All Tests Complete ===\n");
    
    while (1) {
        delay(1000000);
    }
}
