; elf.asm
[bits 32]

; ELF Header constants
ELFCLASS64    equ 2
ELFDATA2LSB   equ 1
EV_CURRENT    equ 1
ET_EXEC       equ 2
EM_X86_64     equ 62

; ELF Header offsets
ELF_ENTRY     equ 24
ELF_PHOFF     equ 32
ELF_PHNUM     equ 56

; Program Header offsets 
PH_TYPE       equ 0
PH_FLAGS      equ 4
PH_OFFSET     equ 8
PH_VADDR      equ 16
PH_PADDR      equ 24
PH_FILESZ     equ 32
PH_MEMSZ      equ 40
PH_ALIGN      equ 48

load_elf:
    push ebp
    mov ebp, esp
    
    ; ebp+8 contains ELF file address
    mov esi, [ebp+8]   
    
    ; Verify ELF magic number
    cmp dword [esi], 0x464C457F  ; "\x7FELF"
    jne .error
    
    ; Check for 64-bit
    cmp byte [esi+4], ELFCLASS64
    jne .error
    
    ; Get entry point
    mov eax, [esi+ELF_ENTRY]
    mov [kernel_entry], eax
    
    ; Get program header information
    mov edx, [esi+ELF_PHOFF]     ; Program header offset
    movzx ecx, word [esi+ELF_PHNUM] ; Number of program headers
    
.load_segments:
    push ecx
    
    ; Check if loadable segment
    mov eax, [esi+edx+PH_TYPE]
    cmp eax, 1  ; PT_LOAD
    jne .next_segment
    
    ; Get segment info
    mov eax, [esi+edx+PH_OFFSET]  ; File offset
    mov ebx, [esi+edx+PH_VADDR]   ; Virtual address
    mov ecx, [esi+edx+PH_FILESZ]  ; Size in file
    
    ; Copy segment
    push esi
    add esi, eax        ; Source = file + offset
    mov edi, ebx        ; Destination = virtual address
    rep movsb           ; Copy ecx bytes
    pop esi
    
.next_segment:
    add edx, 56         ; Size of program header
    pop ecx
    loop .load_segments
    
    mov esp, ebp
    pop ebp
    ret

.error:
    mov eax, 1          ; Return error
    mov esp, ebp
    pop ebp
    ret

kernel_entry: dd 0      ; Storage for entry point