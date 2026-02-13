[org 0x7c00]

jmp main

%include "lib/boot_print.asm"
%include "lib/boot_disk.asm"

main:
    call clear_screen
    
    mov bx, msg
    call print_string
    
    mov bx, 0x9000
    mov dh, 1
    call disk_load
    
    jmp 0x9000

msg: db "Loading kernel...", 0

times 510 - ($-$$) db 0
dw 0xaa55
