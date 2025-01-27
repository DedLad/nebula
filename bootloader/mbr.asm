[bits 16]
[org 0x7c00]

; Constants
KERNEL_OFFSET    equ 0x1000      ; Load kernel at 0x1000 instead of 0x100000
STACK_ADDR       equ 0x9000      ; Stack at 0x9000 instead of 0x90000

start:
    ; Save boot drive number
    mov [BOOT_DRIVE], dl

    ; Set up stack
    mov bp, STACK_ADDR
    mov sp, bp

    ; Load kernel
    call load_kernel
    
    ; Switch to protected mode
    call switch_to_32bit
    
    jmp $

%include "bootloader/print.asm"
%include "bootloader/disk.asm"
%include "bootloader/gdt.asm"
%include "bootloader/elf.asm"
%include "bootloader/switch-to-32bit.asm"

[bits 16]
load_kernel:
    pusha
    ; Print loading message
    mov bx, MSG_LOAD_KERNEL
    call print_string

    mov bx, KERNEL_OFFSET    ; bx -> destination
    mov dh, 32              ; dh -> num sectors
    mov dl, [BOOT_DRIVE]    ; dl -> disk
    call disk_load
    
    popa
    ret

[bits 32]
BEGIN_32BIT:
    ; Set up segment registers for protected mode
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; Set up stack for protected mode
    mov ebp, 0x90000
    mov esp, ebp

    ; Load kernel
    push KERNEL_OFFSET
    call load_elf
    add esp, 4

    ; Jump to kernel entry point
    call [kernel_entry]
    
    jmp $

; Data
BOOT_DRIVE:     db 0
MSG_LOAD_KERNEL: db "Loading kernel...", 0

; Boot sector padding
times 510 - ($ - $$) db 0
dw 0xaa55