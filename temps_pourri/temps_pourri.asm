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
    sty player_missile_pos
    sty ENEMY_POS
    ldy #0

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
    bra DRAW_MISSILES
RESET_ENEMY
    ldy #0
    sty ENEMY_POS

DRAW_MISSILES
****************** DRAW MISSILES
    LDB #10
    LDX #0
draw_missile_loop
    LDA missiles_life,X
    CMPA #0
    BEQ next_missile        * If the pointer is null, then next
    LDY missiles_pos,X      * Y = missiles_pos[X]
    JSR DRAW_MISSILE_LINE   * Draw missile first line
    LEAY 1,Y                * Y++
    JSR DRAW_MISSILE_LINE   * Draw missile second line
next_missile
    LEAX 2,X                * X += 2
    DECB
    BNE draw_missile_loop
end_missiles

****************************
* DISPLAY SCORE
****************************
    LDA #$F0
    STA $F00B
    LDX #SCORE
    JSR DISPLAY_TEXT

****************************
* MOVE MISSILES
****************************
    LDB #10
    LDX #0
move_missile_loop
    LDA missiles_life,X
    CMPA #0
    BEQ next_missile_to_move        ; missiles_life[X] == 0, next
    DECA
    STA missiles_life,X             ; missiles_life[X]--
    LDY missiles_pos,X
    LEAY 1,Y
    STY missiles_pos,X              ; missiles_pos[X]++
next_missile_to_move
    LEAX 2,X                        ; X += 2
    DECB
    BNE move_missile_loop


****************************

CHECK_KEYBOARD
    lda $F046
    cmpa #$FF
    bne check_keyboard_keys
    LDA #0
    STA space_key_down          ; space_key_down = 0
    JMP MAIN_LOOP
check_keyboard_keys
    ldy PLAYER_POS              ; Y = player_pos

    CMPA #$EF
    BEQ keyboard_space
    LDA #0
    STA space_key_down          ; space_key_down = 0
next_key
    lda $F046
    cmpa #$DF
    lbeq KEYBOARD_LEFT
    cmpa #$BF
    lbeq KEYBOARD_RIGHT
    jmp MAIN_LOOP

****************************
* END OF MAIN LOOP
****************************

*********** FIRE
keyboard_space
    LDA space_key_down
    CMPA #0
    BNE keyboard_space_end          ; is space_key_down != 0, skip
    LDA #1
    STA space_key_down              ; space_key_down = 1
    LDB #10
    LDX #0
look_for_available_missile_loop
    LDA missiles_life,X
    CMPA #0
    BNE look_for_next_available_missile     ; if missiles_life[X] != 0, next
    LDY player_missile_pos        ; Y = player_missile_pos
    STY missiles_pos,X               ; missiles_pos[X] = PLAYER_MISSILE_POS
    LDA #99
    STA missiles_life,X             ; missiles_life[X] = 100
    BRA keyboard_space_end
look_for_next_available_missile
    LEAX 2,X
    DECB
    BNE look_for_available_missile_loop
keyboard_space_end
    BRA next_key

*********** MOVE RIGHT
KEYBOARD_RIGHT                      * Y = player position
    cmpy #45                        * If Y == 45 and going right
    beq RIGHT_RESET                 * Then reset the player_position
    lda #6                          * Otherwise paint lines Y, Y+1, Y+2 blue
    sta LINE_COLOR,Y
    sta LINE_COLOR+1,Y
    sta LINE_COLOR+2,Y
    lda #1                          * And paint lines Y+4, Y+5 yellow (Y+3 stays yellow)
    sta LINE_COLOR+4,Y
    sta LINE_COLOR+5,Y
    cmpy #42                        * If player_position == 42
    beq KEYBOARD_RIGHT_DRAW_FIRST_VECTOR
    sta LINE_COLOR+6,Y              * Paint line Y+6 yellow
    bra MOVE_PLAYER_RIGHT
KEYBOARD_RIGHT_DRAW_FIRST_VECTOR
    sta LINE_COLOR-42,Y             * Paint line 0 yellow
MOVE_PLAYER_RIGHT
    leay 3,Y
    sty PLAYER_POS
    ldy player_missile_pos
    leay 100,Y
    sty player_missile_pos
    jmp MAIN_LOOP
RIGHT_RESET
    lda #6
    sta LINE_COLOR,Y
    sta LINE_COLOR+1,Y
    sta LINE_COLOR+2,Y
    ldy #0
    sty PLAYER_POS
    sty player_missile_pos
    lda #1
    sta LINE_COLOR+1,Y
    sta LINE_COLOR+2,Y
    sta LINE_COLOR+3,Y
    jmp MAIN_LOOP

*********** MOVE LEFT
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
    ldy player_missile_pos
    leay -100,Y
    sty player_missile_pos
    jmp MAIN_LOOP
LEFT_RESET
    lda #6
    sta LINE_COLOR+1,Y
    sta LINE_COLOR+2,Y
    sta LINE_COLOR+3,Y
    ldy #1500
    sty player_missile_pos
    ldy #45
    sty PLAYER_POS
    lda #1
    sta LINE_COLOR,Y
    sta LINE_COLOR+1,Y
    sta LINE_COLOR+2,Y
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

DISPLAY_TEXT
    LDA #$0
    STA $F010       ; Color (white)

    CLR $F008
    LDA #$60        ; X position
    STA $F009
    CLR $F00A

    LDA #$11        ; Text size
    STA $F003

TEXT_LOOP
    LDA ,X+
    BEQ TEXT_END
    STA $F000
    BRA TEXT_LOOP
TEXT_END
    RTS

********************************************************************************

SCORE
    FCC /Score: 0010/

PLAYER_POS      FDB $0000
ENEMY_POS       FDB $0000
missiles_pos
    FDB $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
missiles_life
    FDB $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
player_missile_pos
    FDB $0000
space_key_down  fcb $00
next_missile_idx    fcb $00


    INCLUD "temps_pourri/temps_pourri_vectors.asm"
