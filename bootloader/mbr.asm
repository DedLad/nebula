[bits 16]
[org 0x7c00]
;TODO : FFS WRITE COMMENTS LATER
    mov ah, 0x0E        
    mov al, 'H'         
    int 0x10  
    mov al, '~'         
    int 0x10  
KERNEL_OFFSET equ 0x1000

mov [BOOT_DRIVE], dl

mov bp, 0x9000
mov sp, bp 

call load_kernel

mov ah, 0x0e    
mov al, 'B'     
int 0x10        

mov al, 0x0d    
int 0x10
mov al, 0x0a    
int 0x10

call switch_to_32bit

jmp $

%include "bootloader/disk.asm"
%include "bootloader/gdt.asm"
%include "bootloader/switch-to-32bit.asm"

[bits 16]
load_kernel:
    mov bx, KERNEL_OFFSET 
    mov dh, 2             
    mov dl, [BOOT_DRIVE]  
    call disk_load
    ret

[bits 32]
BEGIN_32BIT:

mov ebx, 0xb8000     
mov al, 'F'          
mov ah, 0x0f         
mov [ebx], ax        
mov al, 'W'          
mov [ebx + 2], ax    
    
    call KERNEL_OFFSET ;el
    jmp $ 
    ; hlt
BOOT_DRIVE db 0

; 
times 510 - ($-$$) db 0

dw 0xaa55