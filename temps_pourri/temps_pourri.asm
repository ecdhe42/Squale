GPU_CMD     EQU $F000
GPU_CSIZE   EQU $F003
GPU_DX      EQU $F005
GPU_DY      EQU $F007
GPU_X_MSB   EQU $F008
GPU_X_LSB   EQU $F009
GPU_Y_MSB   EQU $F00A
GPU_Y_LSB   EQU $F00B
GPU_COLOR   EQU $F010
AY_REG      EQU $F060
KEYB_REG    EQU $F046

MAZE_NB_LINES   EQU 48

    org $0000
    setdp $F0

    LDA #$F0
    EXG A,DP

wait_video_chip
    LDA GPU_CMD
    ANDA #4
    BEQ wait_video_chip

    CLR GPU_COLOR

wait_video_chip2
    LDA GPU_CMD
    ANDA #4
    BEQ wait_video_chip2

****************************
* SPLASH
****************************
splash
    JSR clear_screen

    LDX #txt_splash_temps
    LDA #$6
    STA GPU_COLOR       ; Color (blue)
    LDA #$A0
    STA GPU_Y_LSB       ; Y = $78
    LDA #$45
    STA GPU_X_LSB
    LDA #$44
    STA GPU_CSIZE
    JSR display_custom_text

    LDX #txt_splash_pourri
    LDA #$6
    STA GPU_COLOR       ; Color (blue)
    LDA #$70
    STA GPU_Y_LSB       ; Y = $78
    LDA #$40
    STA GPU_X_LSB
    LDA #$44
    STA GPU_CSIZE
    JSR display_custom_text

    LDX #txt_splash_credit
    LDA #$1
    STA GPU_COLOR       ; Color (blue)
    LDA #$40
    STA GPU_Y_LSB       ; Y = $78
    LDA #$28
    STA GPU_X_LSB
    LDA #$11
    STA GPU_CSIZE
    JSR display_custom_text

splash_loop
    JSR wait_for_space_key

****************************
* GAME INIT
****************************
    LDY #0
    STY player_pos

    JSR rnd
    ANDA #$0F
    LSLA
    TFR A,B
    LDA #0
    TFR D,Y
    LDY enemy_start_pos,Y
    STY enemy_pos               ; Reset enemy position

    LDA #49
    STA enemy_hit
    LDY #98
    STY player_missile_pos
    CLR space_key_down
    CLR gameover
    CLR counter
reset_missiles
    LDB #10
    LDX #0
reset_missiles_loop
    CLR missiles_life,X
    LEAX 2,X                * X += 2
    DECB
    BNE reset_missiles_loop

reset_playfield_color
    LDB #44
    LDX #4
    LDA #6
reset_playfield_color_loop
    STA line_color,X
    LEAX 1,X
    DECB
    BNE reset_playfield_color_loop
    LDA #1
    STA line_color
    STA line_color+1
    STA line_color+2
    STA line_color+3

    LDA #$F0
    STA energy
    LDA #$11
    STA gameover_size
    LDA #$30
    STA score+7
    STA score+8
    STA score+9
    STA score+10
    LDA #$A0
    STA gameover_x
    LDA #2
    STA enemy_pause_move_rate

****************************
* MAIN LOOP
****************************
MAIN_LOOP
    JSR vblank
    JSR clear_screen

    LDX #MAZE_NB_LINES
line_loop
    LEAX -1,X
    JSR draw_line
    CMPX #0
    BNE line_loop

****************************
* DISPLAY SCORE
****************************
    LDA #$F0
    STA GPU_Y_LSB
    LDX #score
    JSR display_text

************************
* GAME OVER?
************************
    LDA energy
    CMPA #0
    BNE game_not_over

    LDA #$80
    STA GPU_Y_LSB
    LDX #txt_game_over

    LDA gameover_size
    LDB counter
    CMPB #24
    BEQ game_over_processing_done
    INCB
    STB counter
    ANDB #$7
    CMPB #0
    BNE game_over_processing_done
    LDA gameover_x
    LSRA
    STA gameover_x
    LDA gameover_size
    ADDA #$11
    STA gameover_size
game_over_processing_done
    STA GPU_CSIZE
    LDA gameover_x        ; X position
    STA GPU_X_LSB
    JSR display_game_over
    CMPB #24
    LBNE MAIN_LOOP
    JSR wait_for_space_key
    JMP splash
game_not_over
    JSR draw_energy_line

****************** DRAW ENEMY
    LDY enemy_pos           * Draw enemy
    JSR draw_enemy_line
    LEAY 1,Y
    JSR draw_enemy_line
    LDA counter
    INCA
    STA counter
    CMPA enemy_pause_move_rate
    BEQ reset_enemy_counter         ; If counter == reset_enemy_counter
    DEC enemy_hit                   ; Otherwise, enemy_hit--
    LEAY 1,Y
    STY enemy_pos                   ; And move the enemy
    BRA draw_enemy_end
reset_enemy_counter
    CLR counter                     ; We just reset the counter but don't move the enemy
draw_enemy_end

draw_missiles
****************** DRAW MISSILES
    LDB #10
    LDX #0
draw_missile_loop
    LDA missiles_life,X
    CMPA #0
    BEQ next_missile        * If the pointer is null, then next
    LDY missiles_pos,X      * Y = missiles_pos[X]
    JSR draw_missile_line   * Draw missile first line
    LEAY 1,Y                * Y++
    JSR draw_missile_line   * Draw missile second line
next_missile
    LEAX 2,X                * X += 2
    DECB
    BNE draw_missile_loop
end_missiles

****************************
* SOUNDS
****************************
    LDA sound_lvl
    CMPA #0
    BEQ shooting_sound
    DECA
    STA sound_lvl
    BRA sound_end
shooting_sound
    LDA sound_sht_dur
    CMPA #0
    BEQ sound_end
    DECA
    STA sound_sht_dur
    CMPA #0
    BNE shooting_sound_down
    LDY #sound_off
    JSR play_sound
    BRA sound_end
shooting_sound_down
    LDD sound_shoot
    ADDD #100
    STD sound_shoot
    LDY #sound_shoot
    JSR play_sound
sound_end

****************************
* MOVE ENEMY
****************************
    LDA enemy_hit
    CMPA #0
    BNE move_enemy_end
hit_by_enemy
    LDA #5
    STA hit
    LDA #20
    STA sound_lvl
    LDY #sound_hit_by_enemy
    JSR play_sound

    LDA energy
    SBCA #$10
    STA energy
    CMPA #0
    BNE reposition_enemy
    CLR counter                 ; If energy == 0, counter = 0
reposition_enemy
    JSR rnd
    ANDA #$0F
    LSLA
    TFR A,B
    LDA #0
    TFR D,Y
    LDY enemy_start_pos,Y
    STY enemy_pos
    LDA #49
    STA enemy_hit
move_enemy_end

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
    CMPY enemy_pos
    LBEQ destroy_enemy               ; if missile_pos[X] == enemy_pos, call destroy_enemy
move_missile
    LEAY -2,Y
    STY missiles_pos,X              ; missiles_pos[X]--
    CMPY enemy_pos
    BEQ destroy_enemy               ; if missile_pos[X] == enemy_pos, call destroy_enemy
next_missile_to_move
    LEAX 2,X                        ; X += 2
    DECB
    BNE move_missile_loop

****************************
*    ; Bit 6 off ($40): right key down
*    ; Bit 5 off ($20): left key down
*    ; Bit 4 off ($10): space key down
check_keyboard
    LDA KEYB_REG
    ANDA #$10
    CMPA #$00
    LBNE keyboard_space
    LDA #0
    STA space_key_down          ; space_key_down = 0
next_key
    LDA counter
    ANDA #$1
    CMPA #0
    LBNE MAIN_LOOP
    LDY player_pos              ; Y = player_pos

check_direction_keyboard
    LDA KEYB_REG
    TFR A,B
    ANDA #$20
    CMPA #$00
    LBNE single_move_left_done
    LDA move_key_down
    CMPA #0
    BEQ set_first_move_left
    CMPA #1
    BEQ set_continuous_move_left
    DECA
    STA move_key_down
    JMP MAIN_LOOP
set_first_move_left
    LDA #3
    STA move_key_down
set_continuous_move_left
    JMP KEYBOARD_LEFT
single_move_left_done
    TFR B,A
    ANDA #$40
    CMPA #$00
    LBNE single_move_right_done
    LDA move_key_down
    CMPA #0
    BEQ set_first_move_right
    CMPA #1
    BEQ set_continuous_move_right
    DECA
    STA move_key_down
    JMP MAIN_LOOP
set_first_move_right
    LDA #3
    STA move_key_down
set_continuous_move_right
    JMP KEYBOARD_RIGHT
single_move_right_done
    LDA #0
    STA move_key_down
    JMP MAIN_LOOP

****************************
* END OF MAIN LOOP
****************************

****************************
* DESTROY ENEMY
****************************
destroy_enemy
    PSHS B
    LDA #0
    STA missiles_life,X
    LDY #0
    JSR rnd
    ANDA #$0F
    LSLA
    TFR A,B
    LDA #0
    TFR D,Y
    LDY enemy_start_pos,Y
    STY enemy_pos
    LDA #49
    STA enemy_hit
    LDA #20
    STA sound_lvl
    LDY #sound_enemy_hit
    JSR play_sound
    PULS B
    LDA (score+10)
    CMPA #$39
    BEQ score_digit_2
    INCA
    STA (score+10)
    JMP next_missile_to_move
score_digit_2
    INC enemy_pause_move_rate           ; Every 10 enemies shot, we increase their speed
    LDA #$30
    STA (score+10)
    LDA (score+9)
    CMPA #$39
    BEQ score_digit_3
    INCA
    STA (score+9)
    JMP next_missile_to_move
score_digit_3
    LDA #$30
    STA (score+9)
    LDA (score+8)
    CMPA #$39
    BEQ score_digit_4
    INCA
    STA (score+8)
    JMP next_missile_to_move
score_digit_4
    LDA #$30
    STA (score+8)
    LDA (score+7)
    INCA
    STA (score+7)
    JMP next_missile_to_move

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
    LDA #49
    STA missiles_life,X             ; missiles_life[X] = 100
    LDA sound_lvl
    CMPA #0
    BNE keyboard_space_end
    LDY #sound_shoot
    JSR play_sound
    LDA #$14
    STA sound_shoot
    LDA #10
    STA sound_sht_dur
    BRA keyboard_space_end
look_for_next_available_missile
    LEAX 2,X
    DECB
    BNE look_for_available_missile_loop
keyboard_space_end
    JMP next_key

*********** MOVE RIGHT
KEYBOARD_RIGHT                      * Y = player position
    CMPY #45                        * If Y == 45 and going right
    BEQ RIGHT_RESET                 * Then reset the player_position
    LDA #6                          * Otherwise paint lines Y, Y+1, Y+2 blue
    STA line_color,Y
    STA line_color+1,Y
    STA line_color+2,Y
    LDA #1                          * And paint lines Y+4, Y+5 yellow (Y+3 stays yellow)
    STA line_color+4,Y
    STA line_color+5,Y
    CMPY #42                        * If player_position == 42
    BEQ KEYBOARD_RIGHT_DRAW_FIRST_VECTOR
    STA line_color+6,Y              * Paint line Y+6 yellow
    BRA MOVE_PLAYER_RIGHT
KEYBOARD_RIGHT_DRAW_FIRST_VECTOR
    STA line_color-42,Y             * Paint line 0 yellow
MOVE_PLAYER_RIGHT
    LEAY 3,Y
    STY player_pos
    LDY player_missile_pos
    LEAY 100,Y
    STY player_missile_pos
    JMP MAIN_LOOP
RIGHT_RESET
    LDA #6
    STA line_color,Y
    STA line_color+1,Y
    STA line_color+2,Y
    LDY #98
    STY player_missile_pos
    LDY #0
    STY player_pos
    LDA #1
    STA line_color+1,Y
    STA line_color+2,Y
    STA line_color+3,Y
    JMP MAIN_LOOP

*********** MOVE LEFT
KEYBOARD_LEFT
    CMPY #0
    BEQ LEFT_RESET
    LDA #6
    STA line_color+1,Y
    STA line_color+2,Y
    CMPY #45
    BEQ KEYBOARD_LEFT_ERASE_FIRST_VECTOR
    STA line_color+3,Y
    BRA MOVE_PLAYER_LEFT
KEYBOARD_LEFT_ERASE_FIRST_VECTOR
    STA line_color
MOVE_PLAYER_LEFT
    LDA #1
    STA line_color-1,Y
    STA line_color-2,Y
    STA line_color-3,Y
    LEAY -3,Y
    STY player_pos
    LDY player_missile_pos
    LEAY -100,Y
    STY player_missile_pos
    JMP MAIN_LOOP
LEFT_RESET
    LDA #6
    STA line_color+1,Y
    STA line_color+2,Y
    STA line_color+3,Y
    LDY #1598
    STY player_missile_pos
    LDY #45
    STY player_pos
    LDA #1
    STA line_color,Y
    STA line_color+1,Y
    STA line_color+2,Y
    JMP MAIN_LOOP

END_PRG
    BRA END_PRG

********************************************************************************

clear_screen
wait_video_chip_CS                  * WAIT_EF9365_READY();
    LDA GPU_CMD
    ANDA #4
    BEQ wait_video_chip_CS

    LDA hit
    CMPA #0
    BEQ clear_screen_black
    DECA
    STA hit
    LDX #$F010
    LDB #3
    STB ,X
    LDB #$C
    BRA clear_screen_cmd
clear_screen_black
    LDB #$4
clear_screen_cmd
    LDX #GPU_CMD
	STB ,X
    RTS

********************************************************************************

vblank
wait_for_vsync
    LDA GPU_CMD
    ANDA #$02
    BEQ wait_for_vsync
wait_for_vblank
    LDA GPU_CMD
    ANDA #$02
    BNE wait_for_vblank
    RTS

********************************************************************************

draw_line
wait_video_chip_DL                  * WAIT_EF9365_READY();
*    LDA GPU_CMD
*    ANDA #4
*    BEQ wait_video_chip_DL

    LDA line_x1,X
    STA GPU_X_LSB   * X = X_staRT
    CLR GPU_X_MSB   * ? = 0
    CLR GPU_Y_MSB   * ? = 0
    LDA line_y1,X
    STA GPU_Y_LSB   * Y = B
    LDA line_dx,X
    STA GPU_DX   * dX
    LDA line_color,X
    STA GPU_COLOR   * color
    LDA line_dy,X
    STA GPU_DY   * dY
    LDA line_cmd,X
    STA GPU_CMD   * CMD = draw_line
    RTS

********************************************************************************

draw_enemy_line
*wait_video_chip_DEL                  * WAIT_EF9365_READY();
*    LDA GPU_CMD
*    ANDA #4
*    BEQ wait_video_chip_DEL

    LDA line_enemy_x1,Y
    STA GPU_X_LSB   * X = X_staRT
    CLR GPU_X_MSB   * ? = 0
    CLR GPU_Y_MSB   * ? = 0
    LDA line_enemy_y1,Y
    STA GPU_Y_LSB   * Y = B
    LDA line_enemy_dx,Y
    STA GPU_DX   * dX
    LDA #3
    STA GPU_COLOR   * color
    LDA line_enemy_dy,Y
    STA GPU_DY   * dY
    LDA line_enemy_cmd,Y
    STA GPU_CMD   * CMD = draw_line
    RTS

********************************************************************************

draw_missile_line
*WAIT_VIDEO_CHIP_DEL                  * WAIT_EF9365_READY();
*    LDA GPU_CMD
*    ANDA #4
*    BEQ WAIT_VIDEO_CHIP_DEL

    LDA line_missile_x1,Y
    STA GPU_X_LSB   * X = X_staRT
    CLR GPU_X_MSB   * ? = 0
    CLR GPU_Y_MSB   * ? = 0
    LDA line_missile_y1,Y
    STA GPU_Y_LSB   * Y = B
    LDA line_missile_dx,Y
    STA GPU_DX   * dX
    LDA #5
    STA GPU_COLOR   * color
    LDA line_missile_dy,Y
    STA GPU_DY   * dY
    LDA line_missile_cmd,Y
    STA GPU_CMD   * CMD = draw_line
    RTS

********************************************************************************

draw_energy_line
    LDA #0
    STA GPU_X_LSB   * X = 0
    CLR GPU_X_MSB   * ? = 0
    CLR GPU_Y_MSB   * ? = 0
    LDA #10
    STA GPU_Y_LSB   * Y = 10
    LDA energy
    STA GPU_DX   * dX = energy
    LDA #2
    STA GPU_COLOR   * color = 2
    CLR GPU_DY   * dY = 0
    LDA #$11
    STA GPU_CMD   * CMD = draw_line
    RTS

********************************************************************************

display_text
    LDA #$0
    STA GPU_COLOR       ; Color (white)

    CLR $F008
    LDA #$60        ; X position
    STA $F009
    CLR $F00A

    LDA #$11        ; Text size
    STA GPU_CSIZE

text_loop
    LDA ,X+
    BEQ text_end
    STA $F000
    BRA text_loop
text_end
    RTS

********************************************************************************

display_game_over
    LDA #$0
    STA GPU_COLOR       ; Color (white)
    LDA #$78
    STA GPU_Y_LSB       ; Y = $78

display_custom_text
    CLR GPU_X_MSB
    CLR GPU_Y_MSB

text_gameover_loop
    LDA ,X+
    BEQ text_gameover_end
    STA $F000
    BRA text_gameover_loop
text_gameover_end
    RTS

********************************************************************************

wait_for_space_key
    LDA KEYB_REG
    ANDA #$10
    CMPA #$00
    BEQ wait_for_space_key      ; Wait for the space key NOT to be pressed
wait_for_space_key_down
    JSR rnd
    LDA KEYB_REG
    ANDA #$10
    CMPA #$00
    BNE wait_for_space_key_down
wait_for_space_key_up
    LDA KEYB_REG
    ANDA #$10
    CMPA #$00
    BEQ wait_for_space_key_up
    RTS

********************************************************************************

rnd
    INC     rndx
    LDA     rnda
    EORA    rndc
    EORA    rndx
    STA     rnda
    ADDA    rndb
    STA     rndb
    LSRA
    ADDA    rndc
    EORA    rnda
    STA     rndc
    RTS

play_sound
    LDX #AY_REG

    LDA #00
    LDB ,Y+
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

    RTS

********************************************************************************

score
    FCC /Score: 0000/
    FCB 0

sound_hit_by_enemy
*    FCB $01,$01,$01,$01,$01,$01,$01,$00,$78,$76,$20,$2C,$04,$00
    FCB $32,$34,$37,$38,$3A,$2D,$00,$00,$78,$76,$20,$2C,$2E,$00
*    FCB $F3,$05,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$FF
*    FCB $00,$00,$00,$00,$00,$00,$1F,$07,$08,$08,$08,$D0,$07,$09

sound_shoot
    FCB $14,$00,$00,$00,$00,$00,$00,$7E,$10,$00,$00,$E8,$E3,$00
    FCB $02,$02,$02,$02,$02,$02,$20,$78,$78,$76,$20,$2C,$05,$00

sound_enemy_hit
    FCB $02,$02,$07,$02,$0A,$02,$00,$00,$78,$76,$20,$2C,$2E,$00
*    FCB $F0,$05,$00,$00,$00,$00,$00,$F8,$09,$09,$00,$00,$00,$00
*    FCB $00,$00,$00,$00,$00,$00,$1F,$47,$08,$08,$08,$D0,$07,$09

sound_off
    FCB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF

player_pos      FDB $0000
enemy_pos       FDB $0000
enemy_hit       FCB $00
enemy_pause_move_rate  FCB $00
hit             FCB $00
counter         FCB $00
rnda            FCB 0
rndb            FCB 0
rndc            FCB 0
rndx            FCB 0
energy          FCB 0
gameover        FCB 0
gameover_size   FCB $11
gameover_x      FCB $A0
sound_lvl       FCB 0
sound_sht_dur   FCB 0

txt_splash_temps
    FCC /Temps/
    FCB 0
txt_splash_pourri
    FCC /Pourri/
    FCB 0
txt_splash_credit
    FCC /Copyleft 2025 Laurent Poulain/
    FCB 0

txt_game_over
    FCC /Game Over/
    FCB 0

enemy_start_pos
    FDB $0000,$0064,$00C8,$012C,$0190,$01F4,$0258,$02BC,$0320,$0384,$03E8,$044C,$04B0,$0514,$0578,$05DC
missiles_pos
    FDB $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
missiles_life
    FDB $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
player_missile_pos
    FDB $0000
space_key_down  fcb $00
move_key_down  fcb $00
next_missile_idx    fcb $00


    INCLUD "temps_pourri/temps_pourri_vectors.asm"
