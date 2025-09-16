all: olipix.rom texte.rom temps_pourri.rom

olipix.rom: bootloader.BIN olipix/olipix.BIN
	python buildrom.py olipix/olipix.BIN
	cp olipix.rom ../

texte.rom: bootloader.BIN texte/texte.BIN
	python buildrom.py texte/texte.BIN
	cp texte.rom ../

temps_pourri.rom: bootloader.BIN temps_pourri/temps_pourri.BIN
	python buildrom.py temps_pourri/temps_pourri.BIN
	cp temps_pourri.rom ../

bootloader.BIN: bootloader.asm
	c6809 bootloader.asm

olipix/olipix.BIN: olipix/olipix.asm
	c6809 olipix/olipix.asm

texte/texte.BIN: texte/texte.asm
	c6809 texte/texte.asm

temps_pourri/temps_pourri_vectors.asm: temps_pourri/parse_svg.py
	python temps_pourri/parse_svg.py > temps_pourri/temps_pourri_vectors.asm

temps_pourri/temps_pourri.BIN: temps_pourri/temps_pourri.asm temps_pourri/temps_pourri_vectors.asm
	c6809 temps_pourri/temps_pourri.asm

temps_pourri_vectors.asm: temps_pourri/temps_pourri.svg temps_pourri/parse_svg.py
	python temps_pourri/parse_svg.py > temps_pourri/temps_pourri_vectors.asm

clean:
	rm *.BIN
	rm *.html
	rm *.rom
	rm *.lst
	rm olipix/*.BIN
	rm olipix/*.html
	rm olipix/*.rom
	rm olipix/*.lst
	rm texte/*.BIN
	rm texte/*.html
	rm texte/*.rom
	rm texte/*.lst
	rm temps_pourri/*.BIN
	rm temps_pourri/*.html
	rm temps_pourri/*.rom
	rm temps_pourri/*.lst
	rm temps_pourri/temps_pourri_vectors
