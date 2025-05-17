all: olipix.rom texte.rom temps_pourri.rom

olipix.rom: bootloader.BIN olipix.BIN
	python buildrom.py olipix.BIN
	cp olipix.rom ../

texte.rom: bootloader.BIN texte.BIN
	python buildrom.py texte.BIN
	cp texte.rom ../

temps_pourri.rom: bootloader.BIN temps_pourri.BIN
	python buildrom.py temps_pourri.BIN
	cp temps_pourri.rom ../

bootloader.BIN: bootloader.asm
	c6809 bootloader.asm

olipix.BIN: olipix.asm
	c6809 olipix.asm

texte.BIN: texte.asm
	c6809 texte.asm

temps_pourri.BIN: temps_pourri.asm
	c6809 temps_pourri.asm

clean:
	rm *.BIN
	rm *.html
	rm *.rom
	rm *.lst
