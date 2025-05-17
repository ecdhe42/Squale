LINE_COUNTER2 EQU $0319
COLOR_BG    EQU $E
MAZE_NB_LINES   EQU 48

NB_LINES    EQU $800
NB_VECTORS  EQU $801
SCAN_LINE   EQU $802
COLOR       EQU $803
CNT         EQU $804
SIZE        EQU $805
REG1        EQU $806
TOP_LINE    EQU $807
LINE_COUNTER EQU $808
PLAYER_POS  EQU $809

    ORG $0000

WAIT_VIDEO_CHIP
    LDA $F000
    ANDA #4
    BEQ WAIT_VIDEO_CHIP

    CLR $F010

WAIT_VIDEO_CHIP2
    LDA $F000
    ANDA #4
    BEQ WAIT_VIDEO_CHIP2

    LDY #0

MAIN_LOOP
    JSR VBLANK
    JSR CLEAR_SCREEN

    LDX #MAZE_NB_LINES
LINE_LOOP
    LEAX -1,X
    JSR DRAW_LINE
    CMPX #0
    BNE LINE_LOOP

CHECK_KEYBOARD
    LDA $F046
    CMPA #$FF
    BEQ MAIN_LOOP

    CMPA #$FE
    LBEQ KEYBOARD_UP
    CMPA #$7F
    LBEQ KEYBOARD_DOWN
    CMPA #$DF
    LBEQ KEYBOARD_LEFT
    CMPA #$BF
    LBEQ KEYBOARD_RIGHT
    BRA MAIN_LOOP

KEYBOARD_RIGHT
    CMPY #45
    BEQ RIGHT_RESET
    LDA #6
    STA LINE_COLOR,Y
    STA LINE_COLOR+1,Y
    STA LINE_COLOR+2,Y
    LDA #1
    STA LINE_COLOR+4,Y
    STA LINE_COLOR+5,Y
    CMPY #42
    BEQ KEYBOARD_RIGHT_DRAW_FIRST_VECTOR
    STA LINE_COLOR+6,Y
    BRA MOVE_PLAYER_RIGHT
KEYBOARD_RIGHT_DRAW_FIRST_VECTOR
    STA LINE_COLOR-42,Y
MOVE_PLAYER_RIGHT
    LEAY 3,Y
    BRA MAIN_LOOP
RIGHT_RESET
    LDA #6
    STA LINE_COLOR,Y
    STA LINE_COLOR+1,Y
    STA LINE_COLOR+2,Y
    LDY #0
    LDA #1
    STA LINE_COLOR+1,Y
    STA LINE_COLOR+2,Y
    STA LINE_COLOR+3,Y
    JMP MAIN_LOOP

KEYBOARD_LEFT
    CMPY #0
    BEQ LEFT_RESET
    LDA #6
    STA LINE_COLOR+1,Y
    STA LINE_COLOR+2,Y
    CMPY #45
    BEQ KEYBOARD_LEFT_ERASE_FIRST_VECTOR
    STA LINE_COLOR+3,Y
    BRA MOVE_PLAYER_LEFT
KEYBOARD_LEFT_ERASE_FIRST_VECTOR
    STA LINE_COLOR
MOVE_PLAYER_LEFT
    LDA #1
    STA LINE_COLOR-1,Y
    STA LINE_COLOR-2,Y
    STA LINE_COLOR-3,Y
    LEAY -3,Y
    JMP MAIN_LOOP
LEFT_RESET
    LDA #6
    STA LINE_COLOR+1,Y
    STA LINE_COLOR+2,Y
    STA LINE_COLOR+3,Y
    LDY #45
    LDA #1
    STA LINE_COLOR,Y
    STA LINE_COLOR+1,Y
    STA LINE_COLOR+2,Y
    JMP MAIN_LOOP

KEYBOARD_UP
    LDA SIZE
    ANDA #$0F
    CMPA #$0F
    LBEQ MAIN_LOOP
    INC SIZE
    JMP MAIN_LOOP
KEYBOARD_DOWN
    LDA SIZE
    ANDA #$0F
    CMPA #$01
    LBEQ MAIN_LOOP
    DEC SIZE
    JMP MAIN_LOOP

END_PRG
    BRA END_PRG

********************************************************************************

CLEAR_SCREEN
WAIT_VIDEO_CHIP_CS                  * WAIT_EF9365_READY();
    LDA $F000
    ANDA #4
    BEQ WAIT_VIDEO_CHIP_CS

    LDB #$4
    LDX #$F000
	STB ,X
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

DRAW_LINE
WAIT_VIDEO_CHIP_DL                  * WAIT_EF9365_READY();
*    LDA $F000
*    ANDA #4
*    BEQ WAIT_VIDEO_CHIP_DL

    LDA LINE_X1,X
    STA $F009   * X = X_START
    CLR $F008   * ? = 0
    CLR $F00A   * ? = 0
    LDA LINE_Y1,X
    STA $F00B   * Y = B
    LDA LINE_DX,X
    STA $F005   * dX
    LDA LINE_COLOR,X
    STA $F010   * color
    LDA LINE_DY,X
    STA $F007   * dY
    LDA LINE_CMD,X
    STA $F000   * CMD = draw_line
    RTS

LINE_X1
    FCB $28,$28,$71,$7d,$5a,$7d,$7d,$5a,$7d,$89,$85,$88,$95,$ad,$95,$96,$ae,$94,$a1,$dc,$a1,$a2,$dd,$a1,$a1,$dc,$a1,$ac,$ad,$95,$ad,$ad,$94,$85,$85,$88,$59,$59,$7c,$59,$7c,$58,$70,$70,$28,$71,$28,$70,0,0,0
LINE_X2
    FCB $72,$59,$7d,$5a,$5a,$7d,$5a,$86,$89,$85,$ae,$94,$ad,$ad,$95,$ae,$dd,$a1,$dc,$dc,$a1,$dd,$dc,$a1,$dd,$ac,$95,$95,$ad,$95,$95,$86,$88,$88,$59,$7c,$7c,$59,$7c,$7b,$71,$29,$28,$70,$28,$28,$28,$71,0,0,0
LINE_Y1
    FCB $4a,$4a,$80,$80,$49,$81,$74,$25,$75,$74,$25,$75,$74,$24,$75,$82,$4c,$82,$82,$4c,$81,$8e,$79,$8e,$97,$a7,$97,$a7,$a8,$98,$d1,$d1,$a6,$d0,$d0,$a6,$d0,$d0,$a6,$a7,$96,$a7,$96,$95,$a7,$8d,$82,$8c,0,0,0
LINE_Y2
    FCB $80,$4a,$80,$4a,$25,$74,$24,$25,$75,$24,$25,$75,$24,$4d,$83,$4c,$4c,$82,$4c,$7a,$8f,$79,$a8,$99,$a7,$a7,$97,$98,$d2,$a7,$a6,$d1,$a6,$a6,$d0,$a6,$a6,$a7,$96,$96,$96,$a7,$a7,$8d,$82,$82,$4b,$80,0,0,0
LINE_DX
    FCB $4a,$31,$c,$23,$0,$0,$23,$2c,$c,$4,$29,$c,$18,$0,$0,$18,$2f,$d,$3b,$0,$0,$3b,$1,$0,$3c,$30,$c,$17,$0,$0,$18,$27,$c,$3,$2c,$c,$23,$0,$0,$22,$b,$2f,$48,$0,$0,$49,$0,$1,0,0,0
LINE_DY
    FCB $36,$0,$0,$36,$24,$d,$50,$0,$0,$50,$0,$0,$50,$29,$e,$36,$0,$0,$36,$2e,$e,$15,$2f,$b,$10,$0,$0,$f,$2a,$f,$2b,$0,$0,$2a,$0,$0,$2a,$29,$10,$11,$0,$0,$11,$8,$25,$b,$37,$c,0,0,0
LINE_CMD
    FCB $11,$11,$11,$17,$15,$15,$17,$11,$11,$17,$11,$11,$15,$11,$11,$15,$11,$11,$15,$11,$11,$15,$13,$11,$11,$13,$13,$17,$11,$11,$17,$13,$13,$15,$13,$13,$15,$15,$15,$15,$13,$13,$13,$15,$15,$17,$15,$15,0,0,0
LINE_COLOR
    FCB $1,$1,$1,$1,$6,$6,$6,$6,$6,$6,$6,$6,$6,$6,$6,$6,$6,$6,$6,$6,$6,$6,$6,$6,$6,$6,$6,$6,$6,$6,$6,$6,$6,$6,$6,$6,$6,$6,$6,$6,$6,$6,$6,$6,$6,$6,$6,$6,0,0,0

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
