[org 0x9000]

jmp kernel_start

%include "lib/boot_print.asm"

kernel_start:
    call clear_screen
    
    mov bx, msg
    call print_string
    
    call print_newline
    
    jmp $

msg: db "AogiriOS", 0
