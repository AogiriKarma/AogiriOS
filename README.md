# AogiriOS

Un projet d'apprentissage OS development from scratch, documenté étape par étape.

## C'est quoi ?

AogiriOS est un projet personnel de création d'OS. Le but n'est pas de faire un OS utilisable, mais de comprendre comment ça marche sous le capot : le BIOS, le hardware, le boot process, l'assembleur x86, etc.

Tout le parcours est documenté dans [docs/](docs/) avec un journal détaillé des recherches et découvertes.

## Prérequis

- [NASM](https://nasm.us/) — assembleur x86
- [QEMU](https://www.qemu.org/) — émulateur pour tester les boot sectors

### Installation (Arch Linux)

```bash
sudo pacman -S nasm qemu-full
```

## Build & Run

Assembler un fichier :

```bash
nasm -f bin file.asm -o file.bin
```

Lancer dans QEMU :

```bash
qemu-system-x86_64 file.bin
```

## Documentation

La doc complète est dans [docs/index.md](docs/index.md), et le journal de bord dans [docs/journal.md](docs/journal.md).