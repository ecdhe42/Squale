LINE_COUNTER2 EQU $0319
COLOR_BG    EQU $6

NB_LINES    EQU $800
NB_VECTORS  EQU $801
SCAN_LINE   EQU $802
COLOR       EQU $803
CNT         EQU $804
REG0        EQU $805
REG1        EQU $806
TOP_LINE    EQU $807
LINE_COUNTER EQU $808
DX          EQU $809
X_START     EQU $80A
CMD         EQU $80B

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

    BSR CLEAR_SCREEN
    LDB #$20
    BSR DRAW_BACKGROUND_LINE
    LDB #$50
    BSR DRAW_BACKGROUND_LINE
    LDB #$70
    BSR DRAW_BACKGROUND_LINE
    LDB #$80
    BSR DRAW_BACKGROUND_LINE

    LDA #89
    STA X_START
    LDA #$17
    STA CMD
    JSR DRAW_BACKGROUND_LINE2

    LDA #171
    STA X_START
    LDA #$15
    STA CMD
    BSR DRAW_BACKGROUND_LINE2

    LDA #$FF
    STA TOP_LINE
    LDA #$90
    STA LINE_COUNTER

DEBUT
    JSR DRAW_BITMAP
    DEC TOP_LINE
    DEC LINE_COUNTER
    DEC TOP_LINE
    DEC LINE_COUNTER
    BNE DEBUT

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

DRAW_BACKGROUND_LINE
WAIT_VIDEO_CHIP_BG1                  * WAIT_EF9365_READY();
    LDA $F000
    ANDA #4
    BEQ WAIT_VIDEO_CHIP_BG1

    CLR $F008   * ? = 0
    CLR $F009   * X = 0
    CLR $F00A   * ? = 0
    STB $F00B   * Y = B
    LDA #$FF
    STA $F005   * dX = 255
    LDA #COLOR_BG
    STA $F010   * color
    CLR $F007   * dY = 0
    LDA #$11
    STA $F000   * CMD = draw_line
    RTS

********************************************************************************

DRAW_BACKGROUND_LINE2
WAIT_VIDEO_CHIP_BG2                  * WAIT_EF9365_READY();
    LDA $F000
    ANDA #4
    BEQ WAIT_VIDEO_CHIP_BG2

    LDA X_START
    STA $F009   * X = X_START
    CLR $F008   * ? = 0
    CLR $F00A   * ? = 0
    STB $F00B   * Y = B
    LDA #30
    STA $F005   * dX
    LDA #COLOR_BG
    STA $F010   * color
    LDA #$80
    STA $F007   * dY
    LDA CMD
    STA $F000   * CMD = draw_line
    RTS

********************************************************************************

DRAW_BITMAP
    LDX #BITMAP

    LDB ,X                      * i = nb_lines
    LDA ,X+                    * nb_lines = *vectorized_sprite++;
    STA NB_LINES

WAIT_VIDEO_CHIP_B1                  * WAIT_EF9365_READY();
    LDA $F000
    ANDA #4
    BEQ WAIT_VIDEO_CHIP_B1

    CLR $F007                       * WR_BYTE(HW_EF9365 + 0x7, 0x00);

    LDA TOP_LINE
    STA SCAN_LINE                   * regsbuf[1] = 100

DRAW_BITMAP_LOOP

WAIT_VIDEO_CHIP_B2                  * WAIT_EF9365_READY();
    LDA $F000
    ANDA #4
    BEQ WAIT_VIDEO_CHIP_B2

    CLR $F008
    CLR $F00A
    LDA #90
    STA $F009
    LDA SCAN_LINE
    STA $F00B

    LDA ,X+                    * nb_vects = *vectorized_sprite++;
    STA NB_VECTORS

DRAW_LINE_LOOP
    LDA ,X+
    STA COLOR
    LSRA
    LSRA
    LSRA
    LSRA
    STA CNT
    CMPA #0
    BNE DRAW_LINE1                  * if (cnt == NULL)
    LDA ,X+                    * regsbuf[0] = *vectorized_sprite++;
    STA REG0
    BRA DRAW_VECTOR
DRAW_LINE1
    STA REG0                        * regsbuf[0] = cnt;
DRAW_VECTOR
    LDA COLOR
    ANDA #$0F
    STA REG1
    CMPA #$07
    BNE WAIT_VIDEO_CHIP_B3
    LDA SCAN_LINE
    CMPA #$50
    BEQ BACKGROUND_COLOR
    CMPA #$70
    BEQ BACKGROUND_COLOR
    CMPA #$80
    BEQ BACKGROUND_COLOR
    BRA WAIT_VIDEO_CHIP_B3
BACKGROUND_COLOR
    LDA #COLOR_BG
    STA REG1

WAIT_VIDEO_CHIP_B3                  * WAIT_EF9365_READY();
    LDA $F000
    ANDA #4
    BEQ WAIT_VIDEO_CHIP_B3

    LDA REG0
    STA $F005
    LDA REG1
    STA $F010
    LDA #$11
    STA $F000

    DEC NB_VECTORS
    BNE DRAW_LINE_LOOP

    DEC SCAN_LINE
    DECB

    LBNE DRAW_BITMAP_LOOP

    RTS

********************************************************************************

DISPLAY_TEXT
WAIT_VIDEO_CHIP_TXT                  * WAIT_EF9365_READY();
    LDA $F000
    ANDA #4
    BEQ WAIT_VIDEO_CHIP_TXT

    LDA #$6
    STA $F010

    CLR $F008
    LDA #$40
    STA $F009
    CLR $F00A
    LDA TOP_LINE
    STA $F00B

    STB $F003

    LDX #LABEL
TEXT_LOOP
    LDA ,X+
    STA $F000
    BNE TEXT_LOOP
    RTS

********************************************************************************
LABEL
    FCN 'HELLO WORLD'
    FCB 0

BITMAP
    FCB $4D,$07,$CA,$C6,$CD,$C1,$C3,$CB,$87,$07,$CA,$C6,$CD,$C1,$C3,$CB
	FCB $87,$07,$CA,$C6,$CD,$C1,$C3,$CB,$87,$07,$CA,$C6,$CD,$C1,$C3,$CB
	FCB $87,$07,$CA,$C6,$CD,$C1,$C3,$CB,$87,$07,$CA,$C6,$CD,$C7,$C3,$CB
	FCB $87,$07,$CA,$C6,$CD,$C7,$C3,$CB,$87,$07,$CA,$C6,$CD,$C7,$C3,$CB
	FCB $87,$07,$CA,$C6,$CD,$C7,$C3,$CB,$87,$05,$CA,$C6,$07,$24,$CB,$87
	FCB $05,$CA,$C6,$07,$24,$CB,$87,$05,$CA,$C6,$07,$24,$CB,$87,$05,$CA
	FCB $C6,$07,$24,$CB,$87,$02,$CA,$07,$44,$02,$CA,$07,$44,$02,$CA,$07
	FCB $44,$02,$CA,$07,$44,$02,$CA,$07,$44,$01,$07,$50,$01,$07,$50,$01
	FCB $07,$50,$01,$07,$50,$01,$07,$50,$01,$07,$50,$01,$07,$50,$01,$07
	FCB $50,$01,$07,$50,$01,$07,$50,$01,$07,$50,$01,$07,$50,$03,$07,$25
	FCB $20,$07,$29,$03,$07,$24,$40,$07,$28,$03,$07,$24,$40,$07,$28,$03
	FCB $07,$24,$40,$07,$28,$03,$07,$25,$30,$07,$28,$05,$07,$24,$40,$07
	FCB $18,$30,$D7,$05,$07,$24,$50,$07,$16,$40,$D7,$05,$07,$23,$60,$07
	FCB $16,$40,$D7,$05,$07,$23,$70,$07,$15,$40,$D7,$05,$07,$23,$70,$07
	FCB $15,$50,$C7,$05,$07,$23,$70,$07,$15,$50,$C7,$05,$07,$23,$60,$07
	FCB $16,$50,$C7,$07,$07,$12,$40,$C7,$70,$07,$15,$60,$C7,$09,$27,$40
	FCB $A7,$70,$A7,$80,$07,$10,$B0,$C7,$09,$17,$60,$87,$A0,$77,$90,$C7
	FCB $00,$10,$B7,$09,$17,$60,$87,$B0,$47,$B0,$A7,$00,$12,$B7,$09,$27
	FCB $50,$87,$C0,$27,$B0,$A7,$00,$13,$B7,$09,$27,$50,$87,$C0,$17,$B0
	FCB $A7,$00,$13,$C7,$07,$17,$60,$87,$00,$18,$97,$00,$10,$07,$10,$07
	FCB $27,$50,$87,$00,$17,$97,$00,$10,$07,$11,$07,$27,$60,$87,$00,$17
	FCB $87,$D0,$07,$14,$07,$47,$50,$87,$00,$16,$77,$D0,$07,$15,$07,$57
	FCB $50,$87,$00,$16,$67,$B0,$07,$17,$07,$67,$50,$87,$00,$15,$57,$B0
	FCB $07,$18,$07,$67,$60,$87,$00,$15,$47,$A0,$07,$19,$07,$67,$70,$67
	FCB $00,$17,$37,$A0,$07,$19,$07,$77,$60,$47,$00,$1A,$27,$90,$07,$1A
	FCB $03,$87,$00,$2D,$07,$1B,$05,$97,$00,$2D,$17,$70,$07,$12,$03,$A7
	FCB $00,$36,$07,$10,$03,$A7,$00,$37,$F7,$03,$A7,$00,$38,$E7,$03,$B7
	FCB $00,$37,$E7,$05,$C7,$90,$57,$00,$29,$D7,$03,$07,$1C,$00,$28,$C7
	FCB $03,$07,$1D,$00,$28,$B7,$05,$07,$1E,$00,$1D,$17,$A0,$A7,$05,$07
	FCB $1F,$00,$1A,$47,$90,$A7,$05,$07,$20,$00,$18,$67,$90,$97,$05,$07
	FCB $21,$00,$15,$97,$90,$87,$07,$07,$22,$00,$13,$B7,$90,$27,$10,$47
	FCB $04,$07,$23,$00,$11,$D7,$F0,$04,$07,$24,$F0,$07,$10,$D0,$04,$07
	FCB $24,$E0,$07,$12,$C0,$07,$07,$26,$10,$27,$80,$07,$14,$A0,$17,$05
	FCB $07,$2B,$40,$07,$17,$60,$47,$03,$07,$46,$40,$67
