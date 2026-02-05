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

