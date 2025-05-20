COLOR_BG    EQU $E

SIZE        EQU $800

    ORG $0000

WAIT_VIDEO_CHIP
    LDA $F000
    ANDA #4
    BEQ WAIT_VIDEO_CHIP

    CLR $F010
    LDA #$11
    STA SIZE

WAIT_VIDEO_CHIP2
    LDA $F000
    ANDA #4
    BEQ WAIT_VIDEO_CHIP2

MAIN_LOOP
    JSR VBLANK
    JSR CLEAR_SCREEN
    LDA #$90
    STA $F00B    
    LDX #LABEL1
    JSR DISPLAY_TEXT
    LDA #$10
    STA $F00B    
    LDX #LABEL2
    JSR DISPLAY_TEXT

CHECK_KEYBOARD
    LDA $F046
    CMPA #$FF
    BEQ MAIN_LOOP

    CMPA #$FE
    BEQ KEYBOARD_UP
    CMPA #$7F
    BEQ KEYBOARD_DOWN
    CMPA #$DF
    BEQ KEYBOARD_LEFT
    CMPA #$BF
    BEQ KEYBOARD_RIGHT
    BRA MAIN_LOOP

KEYBOARD_RIGHT
    LDA SIZE
    ANDA #$F0
    CMPA #$F0
    BEQ MAIN_LOOP
    LDA SIZE
    ADDA #$10
    STA SIZE
    BRA MAIN_LOOP
KEYBOARD_LEFT
    LDA SIZE
    ANDA #$F0
    CMPA #$10
    BEQ MAIN_LOOP
    LDA SIZE
    SUBA #$10
    STA SIZE
    BRA MAIN_LOOP
KEYBOARD_UP
    LDA SIZE
    ANDA #$0F
    CMPA #$0F
    BEQ MAIN_LOOP
    INC SIZE
    BRA MAIN_LOOP
KEYBOARD_DOWN
    LDA SIZE
    ANDA #$0F
    CMPA #$01
    BEQ MAIN_LOOP
    DEC SIZE
    BRA MAIN_LOOP

END_PRG
    BRA END_PRG

********************************************************************************

CLEAR_SCREEN
WAIT_VIDEO_CHIP_CS                  * WAIT_EF9365_READY();
    LDA $F000
    ANDA #4
    BEQ WAIT_VIDEO_CHIP_CS

    LDB #$4
    LDY #$F000
	STB ,Y
    RTS

********************************************************************************

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

********************************************************************************

DISPLAY_TEXT
    LDA #$6
    STA $F010

    CLR $F008
    LDA #$10
    STA $F009
    CLR $F00A

    LDA SIZE
    STA $F003

TEXT_LOOP
    LDA ,X+
    BEQ TEXT_END
    STA $F000
    BRA TEXT_LOOP
TEXT_END
    RTS

********************************************************************************
LABEL1
    FCB $48,$65,$6C,$6C,$6F,$00
LABEL2
    FCB $57,$6F,$72,$64,$00

****
* Couleurs:
* - 0: blanc
* - 1: jaune
* - 2: fuchsia
* - 3: rouge
* - 4: turquoise
* - 5: vert
* - 6: bleu
* - 7: noir?
* - 8: gris
* - 9: jaune foncé
* - A: fuchsia fondé
* - B: rouge foncé
* - C: turquoise foncé
* - D: vert foncé
* - E: bleu foncé
* - F: noir
