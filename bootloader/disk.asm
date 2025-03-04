; disk_load.asm
disk_load:
    pusha
    push dx

    mov ah, 0x02    ; BIOS read sector function
    mov al, dh      ; Read DH sectors
    mov ch, 0x00    ; Select cylinder 0
    mov dh, 0x00    ; Select head 0
    mov cl, 0x02    ; Start reading from second sector (after boot sector)
    
    int 0x13        ; BIOS interrupt
    jc disk_error   ; Jump if error (carry flag set)

    pop dx          ; Get back original number of sectors to read
    cmp dh, al      ; Compare sectors read to sectors expected
    jne disk_error  ; Display error if mismatch
    
    popa
    ret

disk_error:
    mov bx, DISK_ERROR_MSG
    call print_string
    jmp $

DISK_ERROR_MSG: db "Disk read error!", 0