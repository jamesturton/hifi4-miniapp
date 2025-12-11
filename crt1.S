.section .ResetVector.literal, "a"
    .align 4
.Lstart_addr:
    .word   _start

    .section .ResetVector.text, "ax"
    .global _ResetVector
    .align 4

_ResetVector:
    /* Load address of _start from literal pool and jump */
    l32r    a0, .Lstart_addr
    jx      a0

    .text
    .align  4
    .global _start
    .type   _start, @function

_start:
    /* Initialize PS register - DISABLE windowed calls */
    movi    a2, 0x00000000  /* PS.WOE=0, PS.INTLEVEL=0, PS.EXCM=0 */
    wsr.ps  a2
    rsync
    
    /* Initialize stack pointer */
    movi    a1, __stack
    
    /* Set return address to hang loop in case main returns */
    movi    a0, .Lhang
    
    /* Jump to main (using call0 - non-windowed call) */
    j       main

    /* If main returns, loop forever */
.Lhang:
    j       .Lhang

/* Provide memcpy since we're using -nostdlib */
    .global memcpy
    .type   memcpy, @function
    .align  4
memcpy:
    /* a2 = dest, a3 = src, a4 = n */
    /* For call0 ABI: no entry/retw, just use addi/ret */
    addi    a1, a1, -16     /* Allocate minimal stack frame */
    s32i    a0, a1, 0       /* Save return address */
    
    mov     a5, a2          /* Save dest for return value */
    beqz    a4, .Lmemcpy_done
.Lmemcpy_loop:
    l8ui    a6, a3, 0
    s8i     a6, a2, 0
    addi    a2, a2, 1
    addi    a3, a3, 1
    addi    a4, a4, -1
    bnez    a4, .Lmemcpy_loop
.Lmemcpy_done:
    mov     a2, a5          /* Restore return value */
    l32i    a0, a1, 0       /* Restore return address */
    addi    a1, a1, 16      /* Deallocate stack frame */
    ret                     /* Return using call0 */
