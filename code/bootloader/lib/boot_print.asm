; ===========================================
; boot_print.asm - Fonctions d'affichage 16 bits
; ===========================================

; ------------------------------------------
; clear_screen - Efface l'écran
; Input: rien
; Output: rien
; ------------------------------------------
clear_screen:
    pusha
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    popa
    ret

; ------------------------------------------
; print_char - Affiche un caractère
; Input: al = caractère à afficher
; Output: rien
; ------------------------------------------
print_char:
    pusha
    mov ah, 0x0e
    int 0x10
    popa
    ret

; ------------------------------------------
; print_string - Affiche une string terminée par 0
; Input: bx = adresse de la string
; Output: rien
; ------------------------------------------
print_string:
    pusha
.loop:
    mov al, [bx]        ; charge le caractère à l'adresse bx
    cmp al, 0           ; fin de string ?
    je .done
    mov ah, 0x0e
    int 0x10
    inc bx              ; caractère suivant
    jmp .loop
.done:
    popa
    ret

; ------------------------------------------
; print_newline - Retour à la ligne
; Input: rien
; Output: rien
; ------------------------------------------
print_newline:
    pusha
    mov ah, 0x0e
    mov al, 0x0D        ; carriage return
    int 0x10
    mov al, 0x0A        ; line feed
    int 0x10
    popa
    ret
