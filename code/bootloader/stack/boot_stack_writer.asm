[org 0x7c00] ; place ou sera load le boot sector ALWAYS THE SAME (offset toutes les adresses par celles ci ensuite)

xor ax,ax      ; We want a segment of 0 for DS for this question
mov ds,ax      ;     Set AX to appropriate segment value for your situation
mov es,ax      ; In this case we'll default to ES=DS
mov bx,0x8000  ; Stack segment can be any usable memory

cli            ; Disable interrupts to circumvent bug on early 8088 CPUs
mov ss,bx      ; This places it with the top of the stack @ 0x80000.
mov sp,ax      ; Set SP=0 so the bottom of stack will be @ 0x8FFFF
sti            ; Re-enable interrupts

cld            ; Set the direction flag to be positive direction

jmp main

write_stack:
    cmp sp, bp 
    je loop
    pop ax
    ; mov al, 'a'
    mov ah, 0x0e 
    int 0x10
    jmp write_stack

clear_screen:
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    ret

main:
    call clear_screen
    
    push 'S'
    push 'O'
    push 'i'
    push 'r'
    push 'i'
    push 'g'
    push 'o'
    push 'A'
    ; push AogiriOS

    jmp write_stack

loop:
    jmp $ ; fallback just in case



; padding and magic number
times 510 - ($-$$) db 0
dw 0xaa55