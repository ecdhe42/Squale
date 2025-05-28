GPU_CMD     EQU $F000
GPU_DX      EQU $F005
GPU_DY      EQU $F007
GPU_X_MSB   EQU $F008
GPU_X_LSB   EQU $F009
GPU_Y_MSB   EQU $F00A
GPU_Y_LSB   EQU $F00B
GPU_COLOR   EQU $F010
IRQ_REG     EQU $EFFA
AY_REG      EQU $F060
COLOR_BG    EQU $6
NB_FRAMES   EQU 18
NB_NOTES    EQU 64
NOTE_DURATION EQU 3

    ORG $0000
    SETDP $F0

    LDA #$F0
    EXG A,DP
    LDA #NB_FRAMES
    STA BITMAP_NB
    
WAIT_VIDEO_CHIP
    LDA $F000
    ANDA #4
    BEQ WAIT_VIDEO_CHIP

    CLR $F010

WAIT_VIDEO_CHIP2
    LDA $F000
    ANDA #4
    BEQ WAIT_VIDEO_CHIP2

    JSR CLEAR_SCREEN
    bra background_end
    LDA #COLOR_BG
    STA $F010   * color
    LDB #$20
    JSR DRAW_BACKGROUND_LINE
    LDB #$50
    JSR DRAW_BACKGROUND_LINE
    LDB #$70
    JSR DRAW_BACKGROUND_LINE
    LDB #$80
    JSR DRAW_BACKGROUND_LINE

    LDB #20

    LDA #89
    STA X_START
    LDA #$17
    STA CMD
    JSR DRAW_BACKGROUND_LINE2

    LDA #171
    STA X_START
    LDA #$15
    STA CMD
    JSR DRAW_BACKGROUND_LINE2
background_end

    LDA #$FF
    STA TOP_LINE
    LDA #$90
    STA LINE_COUNTER

    LDB #NB_NOTES
    STB SOUND_COUNTER           ; sound_counter = NB_NOTES
    LDB #NOTE_DURATION
    STB SOUND_DURATION          ; sound_duration = note_duration
    LDY #SOUND_OLIPIX_DATA
    STY SOUND_PTR               ; sound_ptr = &sound_olipix_data

    LDX #BITMAP_OLIPIX1
fall_loop
    JSR VBLANK
    JSR DRAW_BITMAP
    DEC BITMAP_NB
    BNE fall_draw
    LDA #NB_FRAMES
    STA BITMAP_NB
    LDX #BITMAP_OLIPIX1
fall_draw
    JSR SOUND_PLAYLIST

    DEC TOP_LINE
    DEC LINE_COUNTER
    DEC TOP_LINE
    DEC LINE_COUNTER
*    LDA SOUND_COUNTER
*    CMPA #0
    LDA LINE_COUNTER
    CMPA #40
    BNE fall_loop

background_rising
    JSR VBLANK
    JSR move_background
    JSR DRAW_BITMAP
    DEC BITMAP_NB
    BNE background_draw
    LDA #NB_FRAMES
    STA BITMAP_NB
    LDX #BITMAP_OLIPIX1
background_draw
    JSR SOUND_PLAYLIST

*    DEC TOP_LINE
*    DEC LINE_COUNTER
*    DEC TOP_LINE
*    DEC LINE_COUNTER
    LDA SOUND_COUNTER
    CMPA #0
    BNE background_rising

    LDB #NB_NOTES
    STB SOUND_COUNTER
continue_music
    JSR SOUND_PLAYLIST
    LDB SOUND_COUNTER
    CMPB 0
    BNE continue_music

    JSR SOUND_OFF
END_PRG
    BRA END_PRG

********************************************************************
* MOVE BACKGROUND
********************************************************************

move_background
    LDA #15
    STA $F010   * color

    LDB BACKGROUND_LINE0_Y
    JSR DRAW_BACKGROUND_LINE

    LDB BACKGROUND_LINE1_Y
    BEQ erase_horizontal_lines_end
    JSR DRAW_BACKGROUND_LINE

    LDB BACKGROUND_LINE2_Y
    BEQ erase_horizontal_lines_end
    JSR DRAW_BACKGROUND_LINE

    LDB BACKGROUND_LINE3_Y
    BEQ erase_horizontal_lines_end
    JSR DRAW_BACKGROUND_LINE
erase_horizontal_lines_end

    LDB BACKGROUND_LINE0_Y

    LDA #89
    STA X_START
    LDA #$17
    STA CMD
    JSR DRAW_BACKGROUND_LINE2

    LDA #171
    STA X_START
    LDA #$15
    STA CMD
    JSR DRAW_BACKGROUND_LINE2

redraw_background
    LDA #COLOR_BG
    STA $F010   * color

    LDB BACKGROUND_LINE0_Y
    INCB
    JSR DRAW_BACKGROUND_LINE
    STB BACKGROUND_LINE0_Y
    CMPB #$10
    BNE move_line1
    INC BACKGROUND_LINE1_Y
move_line1
    LDB BACKGROUND_LINE1_Y
    CMPB #0
    BEQ move_line2
    INCB
    JSR DRAW_BACKGROUND_LINE
    STB BACKGROUND_LINE1_Y
    CMPB #$20
    BNE move_line2
    INC BACKGROUND_LINE2_Y
move_line2
    LDB BACKGROUND_LINE2_Y
    CMPB #0
    BEQ move_line3
    INCB
    JSR DRAW_BACKGROUND_LINE
    STB BACKGROUND_LINE2_Y
    CMPB #$30
    BNE move_line3
    INC BACKGROUND_LINE3_Y
move_line3
    LDB BACKGROUND_LINE3_Y
    CMPB #0
    BEQ draw_horizontal_lines_end
    INCB
    JSR DRAW_BACKGROUND_LINE
    STB BACKGROUND_LINE3_Y
draw_horizontal_lines_end

    LDB BACKGROUND_LINE0_Y

    LDA #89
    STA X_START
    LDA #$17
    STA CMD
    JSR DRAW_BACKGROUND_LINE2

    LDA #171
    STA X_START
    LDA #$15
    STA CMD
    JSR DRAW_BACKGROUND_LINE2

    RTS

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
    LDA #89
    STA $F005   * dX = 255
    CLR $F007   * dY = 0
    LDA #$11
    STA $F000   * CMD = draw_line

    CLR $F008   * ? = 0
    LDA #168
    STA $F009   * X = 0
    CLR $F00A   * ? = 0
*    STB $F00B   * Y = B
    LDA #88
    STA $F005   * dX = 255
    CLR $F007   * dY = 0
    LDA #$11
    STA $F000   * CMD = draw_line

*    RTS
*    PSHS B
    TFR B,A
    SBCA #75
    BGE draw_background_line_end

WAIT_VIDEO_CHIP_BG3                  * WAIT_EF9365_READY();
    LDA $F000
    ANDA #4
    BEQ WAIT_VIDEO_CHIP_BG3

    CLR $F008   * ? = 0
    LDA #89
    STA $F009   * X = 0
    CLR $F00A   * ? = 0
*    STB $F00B   * Y = B
    LDA #80
    STA $F005   * dX = 255
    CLR $F007   * dY = 0
    LDA #$11
    STA $F000   * CMD = draw_line

draw_background_line_end
*    PULS B
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
    LDA #$80
    STA $F007   * dY
    LDA CMD
    STA $F000   * CMD = draw_line
    RTS

********************************************************************************

DRAW_BITMAP
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
    CMPA BACKGROUND_LINE0_Y
    BEQ BACKGROUND_COLOR
    CMPA BACKGROUND_LINE1_Y
    BEQ BACKGROUND_COLOR
    CMPA BACKGROUND_LINE2_Y
    BEQ BACKGROUND_COLOR
    CMPA BACKGROUND_LINE3_Y
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

VBLANK
WAIT_FOR_VSYNC
    lda GPU_CMD
    anda #$02
    beq WAIT_FOR_VSYNC
WAIT_FOR_VBLANK
    lda GPU_CMD
    anda #$02
    bne WAIT_FOR_VBLANK
    rts

SOUND_PLAYLIST
    LDY SOUND_PTR
    JSR SOUND
    DEC SOUND_DURATION
    BEQ next_note
    RTS
next_note
    STY SOUND_PTR
    LDA #NOTE_DURATION
    STA SOUND_DURATION
    DEC SOUND_COUNTER
*    BEQ reset_sound
    RTS
reset_sound
    LDA #NB_NOTES
    STA SOUND_COUNTER
    LDY #SOUND_OLIPIX_DATA
    STY SOUND_PTR
    RTS

SOUND_OFF
    LDY #SOUND_OFF_DATA
    LDB #0
    STB SOUND_VAL
    JSR SOUND
    RTS

SOUND_FALL
    LDY #SOUND_DATA
    JSR SOUND
    INC SOUND_VAL
    INC SOUND_VAL
    RTS

SOUND
    PSHS X
    LDA GPU_CMD
    LDX #AY_REG

    LDA #00
    LDB ,Y+
*    LDB SOUND_VAL
    STD ,X

    LDA #01
    LDB ,Y+
    STD ,X

    LDA #02
    LDB ,Y+
    STD ,X

    LDA #03
    LDB ,Y+
    STD ,X

    LDA #04
    LDB ,Y+
    STD ,X

    LDA #05
    LDB ,Y+
    STD ,X

    LDA #06
    LDB ,Y+
    STD ,X

    LDA #07
    LDB ,Y+
    STD ,X

    LDA #08
    LDB ,Y+
    STD ,X

    LDA #09
    LDB ,Y+
    STD ,X

    LDA #10
    LDB ,Y+
    STD ,X

    LDA #11
    LDB ,Y+
    STD ,X

    LDA #12
    LDB ,Y+
    STD ,X
    LDA #13
    LDB ,Y+
    STD ,X

    PULS X
    RTS

********************************************************************************

NB_LINES    FCB $00
NB_VECTORS  FCB $01
SCAN_LINE   FCB $02
COLOR       FCB $03
CNT         FCB $04
REG0        FCB $05
REG1        FCB $06
TOP_LINE    FCB $07
LINE_COUNTER FCB $08
DX          FCB $09
X_START     FCB $0A
CMD         FCB $0B
BITMAP_NB   FCB $0C
SOUND_PTR   FCB $00,$00
SOUND_COUNTER   FCB $10
SOUND_VAL   FCB $01
SOUND_DURATION FCB $00
BACKGROUND_LINE0_Y FCB $00
BACKGROUND_LINE1_Y FCB $00
BACKGROUND_LINE2_Y FCB $00
BACKGROUND_LINE3_Y FCB $00

SOUND_DATA
    FCB $F8,$04,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF
    FCB $E8,$04,$D0,$08,$77,$07,$07,$F8,$09,$09,$00,$00,$00,$FF
    FCB $48,$04,$90,$08,$FF,$07,$07,$F8,$0B,$0B,$00,$00,$00,$FF
    FCB $68,$04,$D0,$08,$77,$07,$07,$F8,$09,$09,$00,$00,$00,$FF
SOUND_OLIPIX_DATA
    FCB $F3,$05,$F9,$02,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $01,$05,$80,$02,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $F3,$05,$F9,$02,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $01,$05,$80,$02,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $F9,$03,$FC,$01,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $01,$05,$80,$02,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $F3,$05,$F9,$02,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $01,$05,$80,$02,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $F3,$05,$F9,$02,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $01,$05,$80,$02,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $F3,$05,$F9,$02,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $01,$05,$80,$02,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $F9,$03,$FC,$01,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $01,$05,$80,$02,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $F3,$05,$F9,$02,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $01,$05,$80,$02,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $F2,$07,$F9,$03,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $AE,$06,$57,$03,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $F2,$07,$F9,$03,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $AE,$06,$57,$03,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $4D,$05,$A6,$02,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $AE,$06,$57,$03,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $F2,$07,$F9,$03,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $AE,$06,$57,$03,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $F2,$07,$F9,$03,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $AE,$06,$57,$03,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $F2,$07,$F9,$03,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $AE,$06,$57,$03,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $4D,$05,$A6,$02,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $AE,$06,$57,$03,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $F2,$07,$F9,$03,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $AE,$06,$57,$03,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $AE,$06,$57,$03,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $4D,$05,$A6,$02,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $AE,$06,$57,$03,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $4D,$05,$A6,$02,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $75,$04,$3A,$02,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $4D,$05,$A6,$02,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $AE,$06,$57,$03,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $4D,$05,$A6,$02,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $AE,$06,$57,$03,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $4D,$05,$A6,$02,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $AE,$06,$57,$03,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $4D,$05,$A6,$02,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $75,$04,$3A,$02,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $4D,$05,$A6,$02,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $AE,$06,$57,$03,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $4D,$05,$A6,$02,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $E7,$0B,$F3,$05,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $02,$0A,$01,$05,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $E7,$0B,$F3,$05,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $02,$0A,$01,$05,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $F2,$07,$F9,$03,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $02,$0A,$01,$05,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $E7,$0B,$F3,$05,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $02,$0A,$01,$05,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $E7,$0B,$F3,$05,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $02,$0A,$01,$05,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $E7,$0B,$F3,$05,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $02,$0A,$01,$05,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $F2,$07,$F9,$03,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $02,$0A,$01,$05,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $E7,$0B,$F3,$05,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13
    FCB $02,$0A,$01,$05,$00,$00,$00,$F8,$0A,$0A,$00,$00,$A7,$13

    FCB $F3,$05,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; D3
    FCB $01,$05,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; F3
    FCB $F3,$05,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; D3
    FCB $01,$05,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; F3
    FCB $F9,$03,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; A3
    FCB $01,$05,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; F3
    FCB $F3,$05,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; D3
    FCB $01,$05,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; F3

    FCB $F3,$05,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; D3
    FCB $01,$05,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; F3
    FCB $F3,$05,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; D3
    FCB $01,$05,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; F3
    FCB $F9,$03,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; A3
    FCB $01,$05,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; F3
    FCB $F3,$05,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; D3
    FCB $01,$05,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; F3

    FCB $F2,$07,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; A2
    FCB $AE,$06,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; C3
    FCB $F2,$07,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; A2
    FCB $AE,$06,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; C3
    FCB $4D,$05,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; E3
    FCB $AE,$06,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; C3
    FCB $F2,$07,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; A2
    FCB $AE,$06,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; C3

    FCB $F2,$07,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; A2
    FCB $AE,$06,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; C3
    FCB $F2,$07,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; A2
    FCB $AE,$06,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; C3
    FCB $4D,$05,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; E3
    FCB $AE,$06,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; C3
    FCB $F2,$07,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; A2
    FCB $AE,$06,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; C3

    FCB $AE,$06,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; C3
    FCB $4D,$05,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; E3
    FCB $AE,$06,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; C3
    FCB $4D,$05,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; E3
    FCB $75,$04,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; G3
    FCB $4D,$05,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; E3
    FCB $AE,$06,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; C3
    FCB $4D,$05,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; E3

    FCB $AE,$06,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; C3
    FCB $4D,$05,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; E3
    FCB $AE,$06,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; C3
    FCB $4D,$05,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; E3
    FCB $75,$04,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; G3
    FCB $4D,$05,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; E3
    FCB $AE,$06,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; C3
    FCB $4D,$05,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; E3

    FCB $E7,$0B,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; D2
    FCB $02,$0A,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; F2
    FCB $E7,$0B,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; D2
    FCB $02,$0A,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; F2
    FCB $F2,$07,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; A2
    FCB $02,$0A,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; F2
    FCB $E7,$0B,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; D2
    FCB $02,$0A,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; F2

    FCB $E7,$0B,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; D2
    FCB $02,$0A,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; F2
    FCB $E7,$0B,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; D2
    FCB $02,$0A,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; F2
    FCB $F2,$07,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; A2
    FCB $02,$0A,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; F2
    FCB $E7,$0B,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; D2
    FCB $02,$0A,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; F2


SOUND_OLIPIX_DATA2
    FCB $E7,$0B,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF
    FCB $E7,$0B,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF
    FCB $E7,$0B,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF
    FCB $E7,$0B,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF
    FCB $02,$0A,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF
    FCB $02,$0A,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF
    FCB $02,$0A,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF
    FCB $02,$0A,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF
    FCB $F2,$07,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF
    FCB $F2,$07,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF
    FCB $F2,$07,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF
    FCB $F2,$07,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF
    FCB $AE,$06,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF
    FCB $AE,$06,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF
    FCB $AE,$06,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF
    FCB $AE,$06,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF
    FCB $F3,$05,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF
    FCB $F3,$05,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF
    FCB $F3,$05,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF
    FCB $F3,$05,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF
    FCB $01,$05,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF
    FCB $01,$05,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF
    FCB $01,$05,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF
    FCB $01,$05,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF

    FCB $E7,$0B,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; D2
    FCB $02,$0A,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; F2
    FCB $F2,$07,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; A2
    FCB $AE,$06,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; C3
    FCB $F3,$05,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; D3
    FCB $01,$05,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF ; F3


SOUND_OFF_DATA
    FCB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF

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

    INCLUD "olipix/olipix_bitmaps.asm"
