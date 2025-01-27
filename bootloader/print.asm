[bits 16]
print_string:
    pusha
    mov ah, 0x0e        ; BIOS tele-type output
.loop:
    mov al, [bx]        ; Load character
    cmp al, 0           ; Check for string end (null terminator)
    je .done
    int 0x10            ; Print character
    add bx, 1           ; Next character
    jmp .loop
.done:
    popa
    ret