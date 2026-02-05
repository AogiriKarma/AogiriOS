[org 0x7c00] ; place ou sera load le boot sector ALWAYS THE SAME (offset toutes les adresses par celles ci ensuite)

; clear screen

mov ah, 0x00
mov al, 0x03
int 0x10

; write from a var 

mov ah, 0x13 
mov al, 0x01
mov bl, 0x02
mov cx, msg_len
mov dh, 0x00      ; ligne 0 (haut de l'écran)
mov dl, 0x00      ; colonne 0 (gauche)
mov bp, text      ; bp attend un pointeur donc pas de []

int 0x10

jmp $ ;

text:
    db "AogiriOS"
    msg_len equ $ - text

; padding and magic number
times 510 - ($-$$) db 0
dw 0xaa55