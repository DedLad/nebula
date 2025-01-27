ENTRY(_start)
OUTPUT_FORMAT(elf64-x86-64)
OUTPUT_ARCH(i386:x86-64)

SECTIONS
{
    . = 0x1000;    /* Match KERNEL_OFFSET from mbr.asm */
    
    .text ALIGN(4K) : {
        *(.text*)
    }
    
    .rodata ALIGN(4K) : {
        *(.rodata*)
    }
    
    .data ALIGN(4K) : {
        *(.data*)
    }
    
    .bss ALIGN(4K) : {
        *(COMMON)
        *(.bss*)
    }
}