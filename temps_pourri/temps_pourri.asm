GPU_CMD     EQU $F000
GPU_DX      EQU $F005
GPU_DY      EQU $F007
GPU_X_MSB   EQU $F008
GPU_X_LSB   EQU $F009
GPU_Y_MSB   EQU $F00A
GPU_Y_LSB   EQU $F00B
GPU_COLOR   EQU $F010

MAZE_NB_LINES   EQU 48

    org $0000
    setdp $F0

    lda #$F0
    exg A,DP

WAIT_VIDEO_CHIP
    lda GPU_CMD
    anda #4
    beq WAIT_VIDEO_CHIP

    clr GPU_COLOR

WAIT_VIDEO_CHIP2
    lda GPU_CMD
    anda #4
    beq WAIT_VIDEO_CHIP2

****************************
* INIT
****************************
    ldy #0
    sty PLAYER_POS
*    ldy #MAZE_NB_LINES
    sty ENEMY_POS
    ldy #50
    sty MISSILE_POS1
    ldy #160
    sty MISSILE_POS2
    ldy #300
    sty MISSILE_POS3
    ldy #490
    sty MISSILE_POS4
    ldy #710
    sty MISSILE_POS5

****************************
* MAIN LOOP
****************************
MAIN_LOOP
    jsr VBLANK
    jsr CLEAR_SCREEN

    LDX #MAZE_NB_LINES
LINE_LOOP
    leax -1,X
    jsr DRAW_LINE
    cmpx #0
    bne LINE_LOOP
****************** DRAW ENEMY
    ldy ENEMY_POS           * Draw enemy
    jsr DRAW_ENEMY_LINE
    leay 1,Y
    jsr DRAW_ENEMY_LINE
    cmpy #1599                * If enemy ptr is 73
    beq RESET_ENEMY
    leay 1,Y
    sty ENEMY_POS
    bra DRAW_MISSILE
RESET_ENEMY
    ldy #0
    sty ENEMY_POS

DRAW_MISSILE
****************** DRAW MISSILE
    ldy MISSILE_POS1           * Draw enemy
    jsr DRAW_MISSILE_LINE
    leay 1,Y
    jsr DRAW_MISSILE_LINE
    cmpy #1599                * If enemy ptr is 73
    beq RESET_MISSILE1
    leay 1,Y
    sty MISSILE_POS1
    bra DRAW_MISSILE2
RESET_MISSILE1
    ldy #0
    sty MISSILE_POS1

DRAW_MISSILE2
    ldy MISSILE_POS2           * Draw enemy
    jsr DRAW_MISSILE_LINE
    leay 1,Y
    jsr DRAW_MISSILE_LINE
    cmpy #1599                * If enemy ptr is 73
    beq RESET_MISSILE2
    leay 1,Y
    sty MISSILE_POS2
    bra DRAW_MISSILE3
RESET_MISSILE2
    ldy #0
    sty MISSILE_POS2

DRAW_MISSILE3
    ldy MISSILE_POS3           * Draw enemy
    jsr DRAW_MISSILE_LINE
    leay 1,Y
    jsr DRAW_MISSILE_LINE
    cmpy #1599                * If enemy ptr is 73
    beq RESET_MISSILE3
    leay 1,Y
    sty MISSILE_POS3
    bra DRAW_MISSILE4
RESET_MISSILE3
    ldy #0
    sty MISSILE_POS3

DRAW_MISSILE4
    ldy MISSILE_POS4           * Draw enemy
    jsr DRAW_MISSILE_LINE
    leay 1,Y
    jsr DRAW_MISSILE_LINE
    cmpy #1599                * If enemy ptr is 73
    beq RESET_MISSILE4
    leay 1,Y
    sty MISSILE_POS4
    bra DRAW_MISSILE5
RESET_MISSILE4
    ldy #0
    sty MISSILE_POS4

DRAW_MISSILE5
    ldy MISSILE_POS5           * Draw enemy
    jsr DRAW_MISSILE_LINE
    leay 1,Y
    jsr DRAW_MISSILE_LINE
    cmpy #1599                * If enemy ptr is 73
    beq RESET_MISSILE5
    leay 1,Y
    sty MISSILE_POS5
    bra CHECK_KEYBOARD
RESET_MISSILE5
    ldy #0
    sty MISSILE_POS5

****************************

CHECK_KEYBOARD
    lda $F046
    cmpa #$FF
    lbeq MAIN_LOOP
    ldy PLAYER_POS

    cmpa #$FE
    lbeq KEYBOARD_UP
    cmpa #$7F
    lbeq KEYBOARD_DOWN
    cmpa #$DF
    lbeq KEYBOARD_LEFT
    cmpa #$BF
    lbeq KEYBOARD_RIGHT
    jmp MAIN_LOOP

****************************
* END OF MAIN LOOP
****************************

KEYBOARD_RIGHT
    cmpy #45
    beq RIGHT_RESET
    lda #6
    sta LINE_COLOR,Y
    sta LINE_COLOR+1,Y
    sta LINE_COLOR+2,Y
    lda #1
    sta LINE_COLOR+4,Y
    sta LINE_COLOR+5,Y
    cmpy #42
    beq KEYBOARD_RIGHT_DRAW_FIRST_VECTOR
    sta LINE_COLOR+6,Y
    bra MOVE_PLAYER_RIGHT
KEYBOARD_RIGHT_DRAW_FIRST_VECTOR
    sta LINE_COLOR-42,Y
MOVE_PLAYER_RIGHT
    leay 3,Y
    sty PLAYER_POS
    jmp MAIN_LOOP
RIGHT_RESET
    lda #6
    sta LINE_COLOR,Y
    sta LINE_COLOR+1,Y
    sta LINE_COLOR+2,Y
    ldy #0
    sty PLAYER_POS
    lda #1
    sta LINE_COLOR+1,Y
    sta LINE_COLOR+2,Y
    sta LINE_COLOR+3,Y
    jmp MAIN_LOOP

KEYBOARD_LEFT
    cmpy #0
    beq LEFT_RESET
    lda #6
    sta LINE_COLOR+1,Y
    sta LINE_COLOR+2,Y
    cmpy #45
    beq KEYBOARD_LEFT_ERASE_FIRST_VECTOR
    sta LINE_COLOR+3,Y
    bra MOVE_PLAYER_LEFT
KEYBOARD_LEFT_ERASE_FIRST_VECTOR
    sta LINE_COLOR
MOVE_PLAYER_LEFT
    lda #1
    sta LINE_COLOR-1,Y
    sta LINE_COLOR-2,Y
    sta LINE_COLOR-3,Y
    leay -3,Y
    sty PLAYER_POS
    jmp MAIN_LOOP
LEFT_RESET
    lda #6
    sta LINE_COLOR+1,Y
    sta LINE_COLOR+2,Y
    sta LINE_COLOR+3,Y
    ldy #45
    sty PLAYER_POS
    lda #1
    sta LINE_COLOR,Y
    sta LINE_COLOR+1,Y
    sta LINE_COLOR+2,Y
    jmp MAIN_LOOP

KEYBOARD_UP
    jmp MAIN_LOOP
KEYBOARD_DOWN
    jmp MAIN_LOOP

END_PRG
    bra END_PRG

********************************************************************************

CLEAR_SCREEN
WAIT_VIDEO_CHIP_CS                  * WAIT_EF9365_READY();
    lda GPU_CMD
    anda #4
    beq WAIT_VIDEO_CHIP_CS

    ldb #$4
    ldx #GPU_CMD
	stb ,X
    rts

********************************************************************************

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

********************************************************************************

DRAW_LINE
WAIT_VIDEO_CHIP_DL                  * WAIT_EF9365_READY();
*    lda GPU_CMD
*    anda #4
*    beq WAIT_VIDEO_CHIP_DL

    lda LINE_X1,X
    sta GPU_X_LSB   * X = X_staRT
    clr GPU_X_MSB   * ? = 0
    clr GPU_Y_MSB   * ? = 0
    lda LINE_Y1,X
    sta GPU_Y_LSB   * Y = B
    lda LINE_DX,X
    sta GPU_DX   * dX
    lda LINE_COLOR,X
    sta GPU_COLOR   * color
    lda LINE_DY,X
    sta GPU_DY   * dY
    lda LINE_CMD,X
    sta GPU_CMD   * CMD = draw_line
    rts

********************************************************************************

DRAW_ENEMY_LINE
*WAIT_VIDEO_CHIP_DEL                  * WAIT_EF9365_READY();
*    lda GPU_CMD
*    anda #4
*    beq WAIT_VIDEO_CHIP_DEL

    lda LINE_ENEMY_X1,Y
    sta GPU_X_LSB   * X = X_staRT
    clr GPU_X_MSB   * ? = 0
    clr GPU_Y_MSB   * ? = 0
    lda LINE_ENEMY_Y1,Y
    sta GPU_Y_LSB   * Y = B
    lda LINE_ENEMY_DX,Y
    sta GPU_DX   * dX
    lda #3
    sta GPU_COLOR   * color
    lda LINE_ENEMY_DY,Y
    sta GPU_DY   * dY
    lda LINE_ENEMY_CMD,Y
    sta GPU_CMD   * CMD = draw_line
    rts

********************************************************************************

DRAW_MISSILE_LINE
*WAIT_VIDEO_CHIP_DEL                  * WAIT_EF9365_READY();
*    lda GPU_CMD
*    anda #4
*    beq WAIT_VIDEO_CHIP_DEL

    lda LINE_MISSILE_X1,Y
    sta GPU_X_LSB   * X = X_staRT
    clr GPU_X_MSB   * ? = 0
    clr GPU_Y_MSB   * ? = 0
    lda LINE_MISSILE_Y1,Y
    sta GPU_Y_LSB   * Y = B
    lda LINE_MISSILE_DX,Y
    sta GPU_DX   * dX
    lda #5
    sta GPU_COLOR   * color
    lda LINE_MISSILE_DY,Y
    sta GPU_DY   * dY
    lda LINE_MISSILE_CMD,Y
    sta GPU_CMD   * CMD = draw_line
    rts

********************************************************************************

PLAYER_POS      FDB $0000
ENEMY_POS       FDB $0000
MISSILE_POS1    FDB $5804
MISSILE_POS2    FDB $5806
MISSILE_POS3    FDB $5808
MISSILE_POS4    FDB $580A
MISSILE_POS5    FDB $580C


    INCLUD "temps_pourri/temps_pourri_vectors.asm"
