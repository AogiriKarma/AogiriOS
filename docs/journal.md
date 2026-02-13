# Journal

## Explications

Ce journal servira à tracer dans le plus grand détail toutes mes recherches et emmerdes.

---

## Jour 1

Je commence assez simplement par chercher sur internet : "how to create an os".

Résultats qui me sautent aux yeux directement :

- <https://github.com/cfenollosa/os-tutorial> — mais c'est outdated...
- <https://www.reddit.com/r/C_Programming/comments/r9eyok/i_want_to_build_an_os/> — et dans les réponses je trouve assez souvent le même lien
- <https://wiki.osdev.org/Expanded_Main_Page> — ça a l'air d'être pas mal

Résultat j'ouvre le site. Second résultat : je comprends rien.

On est assez loin d'un tuto, même très loin.

Je lis l'introduction, puis vais voir les *beginner mistakes* où je suis très gentiment renvoyé vers cette page Wikipédia : <https://en.wikipedia.org/wiki/Dunning%E2%80%93Kruger_effect>. Bon bah on va faire avec hein...

Bon on retourne sur le GitHub. Ça a beau être outdated, c'est un OS, ça peut pas être si outdated que ça, voyons voir ce qu'il nous propose.

Il commence par nous demander d'installer NASM et QEMU.

I use Arch btw donc pour moi c'est `sudo pacman -S nasm qemu`

OKOKOKOOKKOKOK, bon je suis allé jusqu'au 01 bootsecteur barebones... et c'est trop bien !!! Bon déjà de l'assembleur :

```asm
; Infinite loop (e9 fd ff)
loop:
    jmp loop

; Fill with 510 zeros minus the size of the previous code
times 510-($-$$) db 0
; Magic number
dw 0xaa55
```

Bon au début ça avait l'air de chinois mais attends une seconde...

Pour résumer le code qui sort après ça c'est : un retour constant en arrière, je m'explique :

`loop:` définit un point d'ancrage.

`jmp loop` retourne à ce point-là en boucle, peu importe ce qui se passe.

Au départ j'étais un peu perdu quant au premier lancement de `loop` mais en fait en assembleur `loop` n'est pas comme une méthode mais juste un point qui est posé, ce qui fait que la prochaine instruction est `jmp loop` (oé je sais je pars de loin hehe).

Ensuite le fameux `times 510-($-$$) db 0`, lui c'est assez simple à comprendre. `0xAA55` c'est 2 octets donc on veut remplir le reste du programme de 0 pour pouvoir le spécifier à la fin. Puisque `0xAA55` c'est ce qui dit au bootloader qu'on est un OS (et quel OS si je puis me permettre), mais pour qu'il le voie il se met au départ du disque et il regarde 512 octets (la taille d'un boot sector du coup) et si ça finit par notre magic number c'est un OS. Donc le `times`, ça sert à remplir le fichier : on prend 510 (512 - magic number), on regarde où on est dans le fichier (le `$` seul), où est le début (les deux `$$`) et ça ça nous donne le calcul `510 - ($-$$)` qui nous donne le nombre de 0 à mettre dans le padding du fichier pour que le magic number soit au bon endroit.

ET TADAAAAAM l'OS boooooooooooooot agaga j'ai jamais été aussi content de voir l'écran *"booting from Hard Disk..."* le gars du tuto avait raison quand il disait *"When was the last time you were so excited to see an infinite loop? ;-)"* je suis comme un enfant la veille de Noël.


### Prochaine étape : PRINT DANS LE TERMINAL

Bon dans un langage normal... on `print("j'ai fini mon os")` et c'est win... mais là... bah nan.

#### Les interruptions

Premièrement, pour faire faire quelque chose au CPU on utilise une **interruption**. Sur <https://www.developpez.net/forums/d1593920/autres-langages/assembleur/x86-16-bits/liste-complete-interruptions-bios/> je trouve toutes les interruptions dispo. La `10h` m'intéresse puisque c'est la gestion vidéo.

Ensuite je regarde comment on la fait marcher cette interruption, et là on me parle de **registres CPU**... pourquoi pas.

#### Les registres

Donc je cherche ça et je tombe sur ce lien : <https://www.eecg.utoronto.ca/~amza/www.mindsec.com/files/x86regs.html>. Bon je vais pas vous mentir j'ai pas compris grand-chose au premier regard, donc je me suis posé et j'ai lu, puis j'ai relu. Bon heu globalement c'est des petits endroits où on stocke des data. L'avantage c'est que c'est dans le CPU, donc fuck la gestion de la RAM, j'ai pas le temps puis de toute façon c'est plus rapide que la RAM donc c'est bénef.

#### L'interruption 10h

Mais la vraie utilité c'est ensuite quand on va voir la documentation de notre interruption `10h` : <https://www.gladir.com/LEXIQUE/INTR/INT10F00.HTM> (oui moi aussi je perds de l'espérance de vie à chaque fois que je vais sur des sites pour mes recherches). On peut y lire *"Cette fonction de l'interruption 10h, est sans doute la plus importante, car celle-ci permet de changer de mode vidéo d'affichage en fonction d'un standard préétablie à l'origine par le fabricant IBM pour sa gamme de PC."* Ce qui grosso modo veut dire "si tu veux afficher un truc, te faut cette merde". Bon bah je ferai avec.

On retrouve notre registre `AH` et `AL` donc 8 bits splité (on retient un peu hehe). On spécifie ce qu'on veut :

- Dans `AH` je lui donne une première fois `0x00` (`00h`) qui me sert à clean le screen, avec la valeur `AL` = `0x03` (`03h`) → taille de screen 80x25.
- Ensuite pour écrire on met dans `AH` `0x0E`. Pourquoi ? Bonne question, je répondrais que dans le tuto c'est ce qu'on m'a donné comme info et que quand je le regarde dans la doc (<https://www.gladir.com/LEXIQUE/INTR/int10f0e.htm>) ça me dit que ça écrit (mode TTY). Donc je mets mon caractère dans `AL` et j'interromps.

Ah d'ailleurs pour interrompre j'utilise `int 0x10` (le `10h` d'avant du coup) qui me sert à la gestion vidéo donc au print.

#### Le code

Ça donne ce code-là :

```asm
; clear screen

mov ah, 0x00
mov al, 0x03
int 0x10

; write

mov ah, 0x0e
mov al, 'A'
int 0x10
mov al, 'o'
int 0x10
mov al, 'g'
int 0x10
mov al, 'i'
int 0x10
mov al, 'r'
int 0x10
mov al, 'i'
int 0x10
mov al, 'O'
int 0x10
mov al, 'S'
int 0x10

mov al, '.'
int 0x10
int 0x10
int 0x10

jmp $ ; jump to current address = infinite loop

; padding and magic number
times 510 - ($-$$) db 0
dw 0xaa55
```

On remarque une update depuis la dernière fois, les boucles sont plus un jump avec une ancre mais un `jmp $` qui fait la même chose au final.


### La mémoire

OK prochaine update, la mémoire. Oui plus haut j'avais dit fuck la RAM mais là c'est cool, et pas si dur à utiliser. Premièrement dans cet article Wikipédia <https://fr.wikipedia.org/wiki/Master_boot_record> à la section de la structure du MBR on retrouve trois choses : nos 512 octets, notre `0xAA55` qui était notre magic number pour définir un bootloader, et enfin `0x7C00` qui est l'emplacement en RAM où notre boot sector va être load (les 512 octets). Donc dans ce code :

```asm
[org 0x7c00] ; place où sera load le boot sector ALWAYS THE SAME (offset toutes les adresses par celle-ci ensuite)

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
```

On lui dit où il est : `[org 0x7c00]`.

Puis ensuite comme je l'avais pas encore fait mais que j'avais trouvé cette page en cherchant pour écrire : <https://www.gladir.com/LEXIQUE/INTR/int10f13.htm>, on remplit les différentes valeurs :

- `mov ah, 0x13` → c'est le mode pour écrire une ligne entière
- `mov al, 0x01` → cette valeur dit qu'il faut actualiser la position du curseur
- `mov bl, 0x02` → table de couleur, `0` pour noir (fond) et `2` pour vert (texte)

| Valeur | Couleur |
|--------|---------|
| `0` | Noir |
| `1` | Bleu |
| `2` | Vert |
| `3` | Cyan |
| `4` | Rouge |
| `5` | Magenta |
| `6` | Marron |
| `7` | Gris clair |
| `8` | Gris foncé |
| `9` | Bleu clair |
| `A` | Vert clair |
| `B` | Cyan clair |
| `C` | Rouge clair |
| `D` | Magenta clair |
| `E` | Jaune |
| `F` | Blanc |

- `mov cx, msg_len` → entre la longueur du texte qu'on veut écrire
- `mov dh, 0x00` → ligne 0 (haut de l'écran)
- `mov dl, 0x00` → colonne 0 (gauche)
- `mov bp, text` → `BP` attend un pointeur donc pas de `[]`

#### Les données

Ensuite notre interruption pour exec puis on voit :

```asm
text:
    db "AogiriOS"
    msg_len equ $ - text
```

Ici le code est assez simple, `text` est défini à `"AogiriOS"` et `msg_len` devient la longueur. Ce n'est pas une variable ou une assignation, `equ` est la méthode pour remplacer : donc quand on compile, tous les `msg_len` vont devenir `8` automatiquement.



## Jour 2

J'appréhende beaucoup ce jour parce que c'est là que je vais probablement commencer à voir les problèmes de start un projet big avec aucune compétence pour me back up.

Malgré tout je continue de regarder le GitHub <https://github.com/cfenollosa/os-tutorial/tree/master/04-bootsector-stack> c'est là que je suis et le concept ne me paraît pas étranger, je connaissais déjà l'existence de la stack je ne savais par contre pas comment elle était stockée, le fait que ce soit un emplacement du registre qui contienne l'adresse m'a pas mal étonné (`bp`) en parallèle un autre registre tient le haut de la pile (`sp`) ce qui veut dire que quand on initialise `bp` à une adresse mémoire, qui doit d'ailleurs être plus grande que `0x07E00` (`0x07C00` + 512 octets du boot sector), on doit aussi set `sp` à `bp` ensuite quand on push on ajoute à la stack ce qui fait bouger le `sp` mais pas le `bp`.

En sachant ça on peut donc créer une nouvelle méthode pour écrire notre texte (oui encore une)


```asm
[org 0x7c00] ; place où sera load le boot sector ALWAYS THE SAME (offset toutes les adresses par celle-ci ensuite)

xor ax,ax      ; We want a segment of 0 for DS for this question
mov ds,ax      ;     Set AX to appropriate segment value for your situation
mov es,ax      ; In this case we'll default to ES=DS
mov bx,0x8000  ; Stack segment can be any usable memory

cli            ; Disable interrupts to circumvent bug on early 8088 CPUs
mov ss,bx      ; This places it with the top of the stack @ 0x80000.
mov sp,ax      ; Set SP=0 so the bottom of stack will be @ 0x8FFFF
mov bp, sp     ; bp = sp = start of the stack
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
    push 'S'
    push 'O'
    push 'i'
    push 'r'
    push 'i'
    push 'g'
    push 'o'
    push 'A'
    ; push AogiriOS

    call clear_screen
    jmp write_stack

loop:
    jmp $ ; fallback just in case



; padding and magic number
times 510 - ($-$$) db 0
dw 0xaa55
```

Pour cette version j'ai décidé de changer la manière de faire. Je crée des pseudo-méthodes pour nos bouts de code et au début du fichier j'ai ajouté du code servant à trust les registres que j'utilise. Ça vient de ces deux posts StackOverflow où j'ai lu à propos de bonnes pratiques :

- <https://stackoverflow.com/questions/43359327/default-registers-and-segments-value-on-booting-x86-machine>
- <https://stackoverflow.com/questions/32701854/boot-loader-doesnt-jump-to-kernel-code/32705076#32705076>

Ensuite j'ai `write_stack` :

Pour cette méthode j'en ai chié, je veux pouvoir écrire sur l'écran un caractère, ça facile je le fais depuis le début quasiment, MAIS LÀ... le caractère vient du stack dans le code vous pouvez voir `pop ax` ce qui veut dire, met le top du registre dans `ax`, et là normalement vous faites un infarctus parce que je vous disais que la lettre était à mettre dans `al` et pas `ax`, bon pour être honnête, mettre dans `ax` met dans `al` aussi MAIS `ax` = 16 bits `ah` = 8 premiers bits et `al` = les 8 derniers, mais comme quand on met un caractère dans le stack c'est forcément 16 bits on peut pas pop dans `al`, par contre quand on pop dans `ax` il met les 8 derniers dans `al` et comme nos 8 derniers c'est le caractère... bah ça marche, faut set le `ah` à chaque fois par contre mais à part ça ça marche hehehe

Le `clear_screen` on connaît déjà.

Maintenant le `main` :

Le `main` c'est le programme principal, quand je le lance je vais ajouter au stack, mais là vous regardez les push et vous m'insultez normalement. CALMEZ-VOUS, le stack fonctionne à l'envers ce qui veut dire que last in first out, ou en français "le dernier que c'est que t'as push qu'il est le premier a pop"

Le dernier truc restant à expliquer ce sont les `call` et les `ret`. Jusqu'à maintenant on utilisait `jmp`, mais le problème de `jmp` c'est qu'il reprend de là où on l'a lancé mais revient pas là où il était à la fin de l'ancre, nan il continue ce qui crée une boucle infinie pour ça, j'ai trouvé ce cours d'assembleur et ces deux mots-clés :

`call` et `ret`

<https://e-ressources.univ-avignon.fr/assembleur/co/8_1.html>

Pour faire simple c'est dans les 3/4 des langages courants l'équivalent d'un appel de fonction puis d'un return. Sauf qu'en assembleur faut le spécifier son truc de con... bref comme ça notre code marche. Et il est 00:13 donc la suite au jour 3 je crois.

## Jour 3

Bon.. il est toujours 00:13 mais je suis accro donc on va continuer.

Prochaine étape c'est... aucune idée alons voir ce que nous propose le tuto github

Ok, le 5 est pas fou, il nous montre les fonctions.. oupss.. bon bah au moins y nous dit aussi comment include des fichier 

%include "file.asm"

pourquoi pas.. on verra si je trouve une utilité plus tard.

on regarde le 6 bon c'est cryptic mais ca parle de segmentation et d'emplacement mémoire.. pourquoi pas aussi mais pour l'instant je m'en sors pas mal voyons voir la suite, j'ai vraiment envie de passer mon bootloader au niveau supérieur, voir attaquer le kernel etc.


## Jour 4

Je retrouve enfin du temps pour travailler dessus, je reprend la ou j'en etait.

Je commence par crée une lib pour mon bootloader, le but est d'avoir des methodes propres et simple a utiliser plus tard, celle que je crée en premier est `boot_print.asm` elle sert a gérer le texte, clear et write un char ou un string, on utilise bx pour passer les strings puisque c'est un registre qui sert a contenir des addresse mémoire on utilise le 0x00 comme délimiteur de fin de string puisque il n'a pas d'equivalent ascii (fin si c'est nul mais ducoup il en a pas vraiment quoi..).

Maintenant, je veux executer du code depuis le disque, pour ensuite pouvoir y placer mon Kernel puis mon OS.

Pour ce faire j'ai crée bood_disk.asm 

```
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

```

dans ce script le depart c'est pusha et ca se termine quand ca reussis par popa c'est les deux commandes pour stash les registres dans le stack et les remettre en place ensuite il me permet de remettre les registres dans l etat ou ils etaient avant que je fasse quoi que ce soit. 

push dx — sauvegarde le nombre de secteurs demandés (dans dh) parce qu'on va écraser dx après
Les mov configurent INT 13h fonction 02h (lire secteurs) :
ah = 0x02 — fonction "lire"
al = dh — nombre de secteurs
cl = 0x02 — secteur de départ (2 = juste après le boot sector)
ch = 0x00 — cylindre 0
dh = 0x00 — tête 0
dl — numéro du disque (déjà mis par le BIOS)
int 0x13 — appelle le BIOS
jc .disk_error — si le carry flag est set, y'a eu une erreur
pop dx puis cmp al, dh — vérifie qu'on a lu le bon nombre de secteurs

Code adapté du tuto os-tutorial et de la doc INT 13h
http://stanislavs.org/helppc/int_13-1.html


