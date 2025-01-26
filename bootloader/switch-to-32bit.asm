[bits 16]

MSG_PROT_MODE db "Successfully landed in 32-bit Protected Mode", 0

switch_to_32bit:
    cli                    
    lgdt [gdt_descriptor]  
    mov eax, cr0
    or eax, 0x1            
    mov cr0, eax


    jmp CODE_SEG:init_32bit

[bits 32]
init_32bit:
    mov ax, DATA_SEG       
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000       
    mov esp, ebp

    mov ebx, MSG_PROT_MODE
    mov ah, 0x0f           
    mov edx, 0xb8000       
    
msg_loop:
    mov al, [ebx]          
    cmp al, 0              
    je done
    mov [edx], ax          
    add ebx, 1             
    add edx, 2             
    jmp msg_loop
done:

    call BEGIN_32BIT       