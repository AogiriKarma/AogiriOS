; ===========================================
; boot_disk.asm - Lecture disque 16 bits
; ===========================================

; ------------------------------------------
; disk_load - Charge des secteurs du disque en RAM
; Input: 
;   dh = nombre de secteurs à lire
;   dl = numéro du disque (le BIOS le met déjà pour toi)
;   bx = adresse RAM où charger les données
; Output: rien (données chargées à l'adresse bx)
; ------------------------------------------
disk_load:
    pusha
    push dx             ; sauvegarde dh (nombre de secteurs demandés)

    mov ah, 0x02        ; fonction BIOS "lire secteurs"
    mov al, dh          ; nombre de secteurs à lire
    mov cl, 0x02        ; secteur de départ (0x02 = juste après le boot sector)
    mov ch, 0x00        ; cylindre 0
    mov dh, 0x00        ; tête 0
    ; dl = numéro du disque, déjà set par le BIOS

    int 0x13            ; appel BIOS
    jc .disk_error      ; si erreur (carry flag), on saute

    pop dx              ; récupère le nombre de secteurs demandés
    cmp al, dh          ; compare avec le nombre lu (retourné dans al)
    jne .sectors_error  ; si différent, erreur

    popa
    ret

.disk_error:
    mov bx, DISK_ERROR_MSG
    call print_string
    jmp $

.sectors_error:
    mov bx, SECTORS_ERROR_MSG
    call print_string
    jmp $

DISK_ERROR_MSG: db "Disk read error!", 0
SECTORS_ERROR_MSG: db "Wrong sector count!", 0
