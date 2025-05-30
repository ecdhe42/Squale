# API Graphique Squale

Contrairement à beaucoup de micro-ordinateurs, le Squale ne permet pas de modifier directement la mémoire de l'écran. Il faut passer par le processeur graphique Thomson EF 9365 en modifiant ses registres aux adresses $F000-$F00B.

L'adresse $F000 est l'adresse de commande (c-a-d quelle opération effectuer). La modifier lance l'exécution.

A noter que l'adresse XY des pixels suit la notation mathématique, avec le point (0,0) en bas à gauche et non en haut à gauche comme la plupart des ordinateurs.

Ceci ne couvre pas toutes les fonctionnalités graphiques du Squale. Pour plus d'infos sur les API, voir le [code MAME](https://github.com/mamedev/mame/blob/master/src/devices/video/ef9365.cpp#L929)

## Effacer l'écran

- $F010: couleur
- $F000: $4

## Afficher du texte

- $F010: couleur
- $F003: taille du texte (de $11 à $FF, $N? pour la taille horizontale, $?N pour la taille verticale)
- $F009: position X
- $F00B: position Y
- Pour chaque caractère de la chaîne, stocker la valeur dans $F000

## Dessiner une ligne

- $F009: position X du point de départ
- $F008: position X haute du point de départ (en mode 256x256, toujours à zéro)
- $F00A: position Y du point de départ
- $F00B: position Y haute du point de départ (en mode 256x256, toujours à zéro)
- $F005: delta X (toujours positif)
- $F007: delta Y (toujours positif)
- $F010: couleur
- $F000: $11 + 2 (si la ligne va de droite à gauche) + 4 (si la ligne va de haut en bas)

## Attendre que le processeur graphique ait terminé

- Lire le registre $F000
- S'assurer que le bit 2 ($F000 & 4) est désactivé

```
WAIT_VIDEO_CHIP
    LDA $F000
    ANDA #4
    BEQ WAIT_VIDEO_CHIP
```

## Attendre la Vertical Blank

- Lire le registre $F000 en boucle jusqu'à ce que le bit 1 ($F000 & 2) soit à 1. Une fois qu'il est à 1 le faisceau est en haut de l'écran visible
- Lire le registre $F000 en boucle jusqu'à ce que le bit 1 ($F000 & 2) soit à 0. Une fois qu'il est à 0 le faisceau est en bas de l'écran visible (Vertical Blank)

```
VBLANK
WAIT_FOR_VSYNC
    LDA $F000
    ANDA #$02
    BEQ WAIT_FOR_VSYNC
WAIT_FOR_VBLANK
    LDA $F000
    ANDA #$02
    BNE WAIT_FOR_VBLANK
    RTS
```

## Couleurs

- 0: blanc
- 1: jaune
- 2: fuchsia
- 3: rouge
- 4: turquoise
- 5: vert
- 6: bleu
- 7: noir
- 8: gris
- 9: jaune foncé
- 10: fuchsia fondé
- 11: rouge foncé
- 12: turquoise foncé
- 13: vert foncé
- 14: bleu foncé
- 15: noir

## Sons

Le Squale utilise un General Instrument AY-3-8910A comme processeur sonore - un processeur très courant à l'époque dont diverses variantes ont été utilisées par des machines telles que l'Oric-1, l'Amstrad CPC ou l'Atari ST.

Le Squale n'utilise que deux registres pour programmer le son: $F060 et $F061. La première adresse indique le registre sonore à modifier, la second la valeur à mettre dans ledit registre sonore.

Le détail des registres de l'AY-3-8910 sont [disponible en ligne](https://map.grauw.nl/resources/sound/generalinstrument_ay-3-8910.pdf). Et un bon logiciel pour tester les possibilités du processeur et récuppérer les valeurs des registres associées est le programme [Sound FX Generator](https://forum.defence-force.org/viewtopic.php?t=2280) pour Oric-1.
