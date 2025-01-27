gdt_start:

gdt_null:       ; Null descriptor
    dd 0x0      ; 4 bytes
    dd 0x0      ; 4 bytes

gdt_code:       ; Code segment descriptor
    dw 0xffff   ; Limit (bits 0-15)
    dw 0x0      ; Base (bits 0-15)
    db 0x0      ; Base (bits 16-23)
    db 10011010b; Access byte
    db 11001111b; Flags + Limit (bits 16-19)
    db 0x0      ; Base (bits 24-31)

gdt_data:       ; Data segment descriptor
    dw 0xffff   ; Limit (bits 0-15)
    dw 0x0      ; Base (bits 0-15)
    db 0x0      ; Base (bits 16-23)
    db 10010010b; Access byte
    db 11001111b; Flags + Limit (bits 16-19)
    db 0x0      ; Base (bits 24-31)

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1  ; Size of GDT
    dd gdt_start                ; Start address of GDT

; Define constants for segment selectors
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start