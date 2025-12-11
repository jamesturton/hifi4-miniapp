ENTRY(_ResetVector)

MEMORY
{
    iram0 (rx)  : ORIGIN = 0x00400000, LENGTH = 0x00010000
    ddr1  (rwx) : ORIGIN = 0x42000000, LENGTH = 0x00100000
}

PHDRS
{
    iram0_phdr PT_LOAD;
    ddr1_phdr  PT_LOAD;
}

PROVIDE(__stack = 0x37d00000);
_heap_sentry = 0x37d00000;

SECTIONS
{
    .oemhead.text : ALIGN(4)
    {
        _oemhead_text_start = ABSOLUTE(.);
        KEEP (*(.oemhead.text))
        . = ALIGN (4);
        _oemhead_text_end = ABSOLUTE(.);
    } >iram0 :iram0_phdr

    .oemhead.literal : ALIGN(4)
    {
        _oemhead_literal_start = ABSOLUTE(.);
        *(.oemhead.literal)
        . = ALIGN (4);
        _oemhead_literal_end = ABSOLUTE(.);
        _memmap_seg_iram0_0_end = ALIGN(0x8);
    } >iram0 :iram0_phdr

    .ResetVector.literal : ALIGN(4) {
        *(.ResetVector.literal)
    } > iram0 :iram0_phdr
    
    .ResetVector.text : ALIGN(4) {
        *(.ResetVector.text)
    } > iram0 :iram0_phdr
    
    .WindowVectors.text : ALIGN(4) {
        . = 0x0;
        KEEP(*(.WindowVectors.text))
    } > iram0 :iram0_phdr
    
    .text : ALIGN(4) {
        *(.literal .literal.* .text .text.*)
        *(.stub)
        *(.gnu.linkonce.literal.* .gnu.linkonce.t.*)
        *(.fini.literal)
        *(.fini)
        *(.gnu.version)
    } > ddr1 :ddr1_phdr
    
    .rodata : ALIGN(4) {
        *(.rodata .rodata.*)
        *(.gnu.linkonce.r.*)
        *(.rodata1)
    } > ddr1 :ddr1_phdr
    
    .data : ALIGN(4) {
        *(.data .data.*)
        *(.gnu.linkonce.d.*)
        *(.data1)
        *(.sdata .sdata.* .sdata2.*)
        *(.gnu.linkonce.s.*)
    } > ddr1 :ddr1_phdr
    
    .bss (NOLOAD) : ALIGN(4) {
        _bss_start = ABSOLUTE(.);
        *(.dynsbss)
        *(.sbss .sbss.* .scommon)
        *(.dynbss)
        *(.bss .bss.*)
        *(.gnu.linkonce.b.*)
        *(COMMON)
        . = ALIGN(4);
        _bss_end = ABSOLUTE(.);
    } > ddr1 :ddr1_phdr
    
    _end = .;
}
