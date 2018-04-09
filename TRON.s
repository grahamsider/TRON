
	 #####################
	#######################
	##					 ##
	##	  TRON v5.0		 ##
	##					 ##
	##	  Created by 	 ##
	##	  Graham Sider	 ##
	##	& Junhyeok Hong	 ##
	##  				 ##
	##	  ECE 243		 ##
	##	  2018			 ##	   			
	##					 ##
	#######################
	 #####################
	
	
	
	
	########
	# DATA #
	########
	
	.section .data
	.align 2
	
	
	### I/O ###
	

	# VIDEO CONTROL BUFFER
	.equ VCB_BASE, 0xFF203020			# STORED IN: r8
	.equ VCB_FRONT_BUFFER, 0x00			# BASE
	.equ VCB_BACK_BUFFER, 0x04			# BASE + 4
	.equ VCB_PIXEL_COORDS, 0x08			# BASE + 8
	.equ VCB_CONFIG, 0x0C				# BASE + 12
	
	#PS/2 CONTROLLER
	.equ PS2_BASE, 0xFF200100			# STORED IN: r9
	.equ PS2_CONTROL, 0x04				# BASE + 4

	# VGA CHARACTER BUFFER
	.equ VGA_CHAR_BUFFER, 0x09000000
	
	# LED BASE
	.equ LED_BASE, 0xFF200000

	
	### STORAGE ###
	
	
	# PLAYER ONE DATA
    P1_KEY:  .byte ' '
    .equ P1_START_COORDS, 0x1DC50
    .equ KEY_A, 0x01C                   
    .equ KEY_W, 0x01D
    .equ KEY_S, 0x01B
    .equ KEY_D, 0x023

    # PLAYER TWO DATA
    P2_KEY:  .byte ' '
    .equ P2_START_COORDS, 0x1DE30
	.equ KEY_ARROW_L, 0x6B
	.equ KEY_ARROW_U, 0x75
	.equ KEY_ARROW_D, 0x72
	.equ KEY_ARROW_R, 0x74

	# OTHER KEYS
	.equ KEY_ENTER, 0x5A

	# MOVEMENT VALS
	.equ MOVE_RIGHT, 2
	.equ MOVE_LEFT, -2
	.equ MOVE_UP, -1024
	.equ MOVE_DOWN, 1024

    # COLOUR VALS
    .equ COLOUR_P1, 0xCB3A						# WAS 0xC87A
    .equ COLOUR_P2, 0x37E4
	.equ COLOUR_BACKGROUND, 0x0845
	.equ COLOUR_BACKGROUND_FLUFF, 0x3576
	.equ COLOUR_BORDER, 0x3577

	# BUFFER SRAM MEMORY LOCATIOINS
	.equ VGA_FRONT_BUFFER, 0x01000000
	.equ VGA_FRONT_BUFFER_END, 0x0103BE7E		# <NOTE> CHANGED FROM 0103FFFF TO 0103BE7E
	.equ VGA_BACK_BUFFER, 0x02000000
	.equ VGA_BACK_BUFFER_END, 0x0203BE7E

	# OTHER SCREEN LOCATIONS
	.equ SCREEN_TOP_LEFT_COORDS, 0x0
	.equ SCREEN_TOP_RIGHT_COORDS, 0x27E
	.equ SCREEN_BOTTOM_LEFT_COORDS, 0x3BC00
	.equ SCREEN_BOTTOM_RIGHT_COORDS, 0x3BE7E

    # HEX DISPLAY (HEX0 = PLAYER 1 & HEX1 = PLAYER 2)
    .equ HEX_ADDRESS, 0xFF200020

    .equ SCORE_ZERO_ZERO, 0x3F3F                # HEX0 = 0 & HEX1 = 0
    .equ SCORE_ONE_ZERO, 0x063F                 # HEX0 = 1 & HEX1 = 0
    .equ SCORE_TWO_ZERO, 0x5B3F                 # HEX0 = 2 & HEX1 = 0
    .equ SCORE_THREE_ZERO, 0x4F3F               # HEX0 = 3 & HEX1 = 0

    .equ SCORE_ZERO_ONE, 0x3F06                 # HEX0 = 0 & HEX1 = 1
    .equ SCORE_ONE_ONE, 0x0606                  # HEX0 = 1 & HEX1 = 1
    .equ SCORE_TWO_ONE, 0x5B06                  # HEX0 = 2 & HEX1 = 1
    .equ SCORE_THREE_ONE, 0x4F06                # HEX0 = 3 & HEX1 = 1

    .equ SCORE_ZERO_TWO, 0x3F5B                 # HEX0 = 0 & HEX1 = 2
    .equ SCORE_ONE_TWO, 0x065B                  # HEX0 = 1 & HEX1 = 2
    .equ SCORE_TWO_TWO, 0x5B5B                  # HEX0 = 2 & HEX1 = 2
    .equ SCORE_THREE_TWO, 0x4F5B                # HEX0 = 3 & HEX1 = 2

    .equ SCORE_ZERO_THREE, 0x3F4F               # HEX0 = 0 & HEX1 = 3
    .equ SCORE_ONE_THREE, 0x064F                # HEX0 = 1 & HEX1 = 3
    .equ SCORE_TWO_THREE, 0x5B4F                # HEX0 = 2 & HEX1 = 3
    .equ SCORE_THREE_THREE, 0x4F4F              # HEX0 = 3 & HEX1 = 3
	

	
	
	##############
	# EXCEPTIONS #
	##############
	
	.section .exceptions, "ax"
	.align 2
	
_isr:									# CONSIDER CHANGING TO USE ET (r24)
	
	ldwio et, 0(r9)						# et = PS2 BASE INFO
	andi et, et, 0x00008000				# et = CHECK VALID READ (TEMP)
	srli et, et, 0x0E						
	bne et, r0, _ps2_valid				# DATA VALID CHECK
	br _in_game							# PS2 DATA INVALID
	
_ps2_valid:								# PS2 DATA VALID
	
	ldwio et, 0(r9)						# et = DATA (TEMP)
	andi et, et, 0x000000FF
	
	movia r23, KEY_ENTER
	beq et, r23, _key_enter

	movia r23, KEY_A					# r23 = TEMP KEYS
	beq et, r23, _p1_key_a
	
	movia r23, KEY_W
	beq et, r23, _p1_key_w
	
	movia r23, KEY_S
	beq et, r23, _p1_key_s
	
	movia r23, KEY_D
	beq et, r23, _p1_key_d
	
	movia r23, KEY_ARROW_L
	beq et, r23, _p2_key_arrow_l
	
	movia r23, KEY_ARROW_U
	beq et, r23, _p2_key_arrow_u
	
	movia r23, KEY_ARROW_D
	beq et, r23, _p2_key_arrow_d
	
	movia r23, KEY_ARROW_R
	beq et, r23, _p2_key_arrow_r

	br _eret	

_key_enter:
	movi r4, 1
	br _eret

_p1_key_a:
	movia r18, MOVE_LEFT
	br _eret
	
_p1_key_w:
	movia r18, MOVE_UP
	br _eret
	
_p1_key_s:
	movia r18, MOVE_DOWN
	br _eret
	
_p1_key_d:
	movia r18, MOVE_RIGHT
	br _eret
	
_p2_key_arrow_l:
	movia r19, MOVE_LEFT
	br _eret
	
_p2_key_arrow_u:
	movia r19, MOVE_UP
	br _eret
	
_p2_key_arrow_d:
	movia r19, MOVE_DOWN
	br _eret
	
_p2_key_arrow_r:
	movia r19, MOVE_RIGHT
	br _eret
	
_eret:
	
	subi ea, ea, 4
	eret								# DONE
	
	
	
	
	################
	# INSTRUCTIONS #
	################
	
	.section .text
	.align 2
	.global _start
	
_start:
	
	call _setup							# SETUP SUBROUTINE

_game:

	br _splashscreen					# CREATE STARTSCREEN

_setup:
	
	movia r8, VCB_BASE					# r8 = VCB BASE
	movia r9, PS2_BASE					# r9 = PS2 BASE
	
	# VIDEO CONTROL BUFFER SETUP
	movui r4, 0x1						# r4 = TEMP
	#stwio r4, VCB_FRONT_BUFFER(r8)		# DOUBLE BUFFER ENABLED
	movia r4, 0x08090020				# DEFAULT VCB CONFIG
	stwio r4, VCB_CONFIG(r8)			# VCB CONFIGURED
	
	# INTERRUPT SETUP
	movui r4, 0x1
	wrctl ctl0, r4						# CPU	(status)
	stwio r4, PS2_CONTROL(r9)			# PS2	(IRQ 7)
	movui r4, 0x80
	wrctl ctl3, r4						# CPU	(ienable)

	movia r4, LED_BASE					# RESETTING LEDs
	stwio r0, 0(r4)
	
	# COLOUR SETUP
	movia r3, COLOUR_BORDER				# r3 = BORDER
	movia r10, COLOUR_BACKGROUND		# r10 = BACKGROUND
	movia r11, COLOUR_BACKGROUND_FLUFF	# r11 = BACKGROUND FLUFF
	movia r12, COLOUR_P1				# r12 = PLAYER 1 COLOUR
	movia r13, COLOUR_P2				# r13 = PLAYER 2 COLOUR

	# SRAM BUFFER MEMORY SETUP
	movia r14, VGA_FRONT_BUFFER 		# r14 = FRONT BUFFER MEMORY LOCATION
	movia r15, VGA_FRONT_BUFFER_END		# r15 = END OF FRONT BUFFER MEMORY LOCATION
	movia r16, VGA_BACK_BUFFER 			# r16 = BACK BUFFER MEMORY LOCATION
	movia r17, VGA_BACK_BUFFER_END		# r17 = END OF BACK BUFFER MEMORY LOCATION

	# PLAYER STARTING POSITIONS
	movia r20, P1_START_COORDS			# r20 = PLAYER 1 STARTING COORDINATES
	movia r21, P2_START_COORDS			# r21 = PLAYER 2 STARTING COORDINATES

    # HEX DISPLAY SETUP
    movia r22, HEX_ADDRESS              # r22 = HEX DISPLAY ADDRESS
	ret
	


_splashscreen:							
	
	movi r2, 1							# r2 = SWAP REGISTER (0x1)
	call _draw_background				# DRAW BACKGROUND
	
	movia r4, VGA_CHAR_BUFFER			# DRAW CHARACTERS
	addi r4, r4, 0x1694
	movi r5, 0x50 						# "P"
	sthio r5, 0(r4)
	movi r5, 0x52						# "R"
	sthio r5, 2(r4)
	movi r5, 0x45						# "E"
	sthio r5, 4(r4)
	movi r5, 0x53						# "S"
	sthio r5, 6(r4)
	movi r5, 0x53						# "S"
	sthio r5, 8(r4)
	movi r5, 0x20						# " "
	sthio r5, 10(r4)
	movi r5, 0x45						# "E"
	sthio r5, 12(r4)
	movi r5, 0x4E						# "N"
	sthio r5, 14(r4)
	movi r5, 0x54						# "T"
	sthio r5, 16(r4)
	movi r5, 0x45						# "E"
	sthio r5, 18(r4)
	movi r5, 0x52						# "R"
	sthio r5, 20(r4)
	movi r5, 0x20						# " "
	sthio r5, 22(r4)
	movi r5, 0x54						# "T"
	sthio r5, 24(r4)
	movi r5, 0x4F						# "O"
	sthio r5, 26(r4)
	movi r5, 0x20						# " "
	sthio r5, 28(r4)
	movi r5, 0x53						# "S"
	sthio r5, 30(r4)
	movi r5, 0x54						# "T"
	sthio r5, 32(r4)
	movi r5, 0x41						# "A"
	sthio r5, 34(r4)
	movi r5, 0x52						# "R"
	sthio r5, 36(r4)
	movi r5, 0x54						# "T"
	sthio r5, 38(r4)

	add r4, r0, r0 						# SET r4 TO 0

_wait_for_enter:
	
	beq r4, r0, _wait_for_enter

_erase_chars:
	
	movia r4, VGA_CHAR_BUFFER			# ERASE CHARACTERS
	addi r4, r4, 0x1694
	movi r5, 0x20						# " "
	sthio r5, 0(r4)
	movi r5, 0x20						# " "
	sthio r5, 2(r4)
	movi r5, 0x20						# " "
	sthio r5, 4(r4)
	movi r5, 0x20						# " "
	sthio r5, 6(r4)
	movi r5, 0x20						# " "
	sthio r5, 8(r4)
	movi r5, 0x20						# " "
	sthio r5, 10(r4)
	movi r5, 0x20						# " "
	sthio r5, 12(r4)
	movi r5, 0x20						# " "
	sthio r5, 14(r4)
	movi r5, 0x20						# " "
	sthio r5, 16(r4)
	movi r5, 0x20						# " "
	sthio r5, 18(r4)
	movi r5, 0x20						# " "
	sthio r5, 20(r4)
	movi r5, 0x20						# " "
	sthio r5, 22(r4)
	movi r5, 0x20						# " "
	sthio r5, 24(r4)
	movi r5, 0x20						# " "
	sthio r5, 26(r4)
	movi r5, 0x20						# " "
	sthio r5, 28(r4)
	movi r5, 0x20						# " "
	sthio r5, 30(r4)
	movi r5, 0x20						# " "
	sthio r5, 32(r4)
	movi r5, 0x20						# " "
	sthio r5, 34(r4)
	movi r5, 0x20						# " "
	sthio r5, 36(r4)
	movi r5, 0x20						# " "
	sthio r5, 38(r4)

	br _game_start

_draw_background:	

	movia r14, VGA_FRONT_BUFFER 		# RE-INSTANTIATE r14 TO FRONT BUFFER
	movia r16, VGA_BACK_BUFFER 			# RE-INSTANTIATE r16 TO BACK BUFFER

	add r4, r0, r0
	addi r5, r0, 16

_fill_background:

	beq r4, r5, _fill_background_line

	sth r10, 0(r14)						# FILL FRONT BUFFER
	addi r14, r14, 2

	sth r10, 0(r16)						# FILL BACK BUFFER
	addi r16, r16, 2

	addi r4, r4, 1

	ble r14, r15, _fill_background		# LOOP UNTIL FILLED
	br _draw_borders

_fill_background_line:
	
	sth r11, 0(r14)						# FILL FRONT BUFFER
	addi r14, r14, 2

	sth r11, 0(r16)						# FILL BACK BUFFER
	addi r16, r16, 2
	
	add r4, r0, r0

	ble r14, r15, _fill_background		# LOOP UNTIL FILLED

_draw_borders:

	movia r4, SCREEN_BOTTOM_LEFT_COORDS	# r4, r5 = TEMP
	movia r5, VGA_FRONT_BUFFER 			# (FOR BORDER DRAWING)
	add r4, r4, r5

_draw_border_bottom:
	
	sth r3, 0(r14)
	subi r14, r14, 2

	sth r3, 0(r16)
	subi r16, r16, 2

	bne r14, r4, _draw_border_bottom

	movia r4, VGA_FRONT_BUFFER

_draw_border_left:
	
	sth r3, 0(r14)
	subi r14, r14, 1024

	sth r3, 0(r16)
	subi r16, r16, 1024

	bne r14, r4, _draw_border_left

	movia r4, SCREEN_TOP_RIGHT_COORDS
	movia r5, VGA_FRONT_BUFFER
	add r4, r4, r5

_draw_border_top:
	
	sth r3, 0(r14)
	addi r14, r14, 2

	sth r3, 0(r16)
	addi r16, r16, 2

	bne r14, r4, _draw_border_top

	movia r4, SCREEN_BOTTOM_RIGHT_COORDS
	movia r5, VGA_FRONT_BUFFER
	add r4, r4, r5

_draw_border_right:
	
	sth r3, 0(r14)
	addi r14, r14, 1024

	sth r3, 0(r16)
	addi r16, r16, 1024

	bne r14, r4, _draw_border_right

	movia r14, VGA_FRONT_BUFFER 		# RE-INSTANTIATE r14 TO FRONT BUFFER
	movia r16, VGA_BACK_BUFFER 			# RE-INSTANTIATE r16 TO BACK BUFFER

	stwio r14, VCB_BACK_BUFFER(r8)		# STORING BACKGROUND TO BACK BUFFER
	stwio r2, VCB_FRONT_BUFFER(r8)		# SWAPPING BUFFERS
	stwio r16, VCB_BACK_BUFFER(r8)		# STORING BACKGROUND TO BACK BUFFER

	ret


	### GAME ###


_game_start:							# GAME START
	
	# SETUP FOR GAME

_set_score_to_zero_on_hex_display:

    movia r4, SCORE_ZERO_ZERO
    stwio r4, 0(r22)                    # INITIAL SCORE IS ZERO, ZERO

_game_continue:

	# PLAYER MOVEMENT STARTING VALUES
	movia r18, MOVE_RIGHT				# r18 = PLAYER 1 MOVEMENT
	movia r19, MOVE_LEFT				# r19 = PLAYER 2 MOVEMENT

	call _draw_background				# DRAWING BACKGROUND

	mov r6, r14							# COPY OF BUFFERS
	mov r7, r16							# FOR PLAYER 2

	add r14, r14, r20 					# MOVING PLAYER 1
	add r16, r16, r20 					# AND 2 INTO
	add r6, r6, r21 					# STARTING
	add r7, r7, r21 					# POSITIONS

_in_game:								# IN GAME
	
_check_collision_p1:					# CHECK FOR PLAYER 1 COLLISION
	
	ldh r4, VCB_FRONT_BUFFER(r14)		# GRAB COLOUR OF NEXT PIXEL FOR PLAYER 1
	andi r4, r4, 0xFFFF					
	beq r4, r10, _check_collision_p2	# IF(BACKGROUND) GOTO _check_collision_p2
	beq r4, r11, _check_collision_p2	# IF(BACKGROUND_FLUFF) GOTO _check_collision_p2

	br _check_same_frame_collision		# ELSE GOTO _check_same_frame_collision

_check_collision_p2:

	ldh r4, VCB_FRONT_BUFFER(r6)		# GRAB COLOUR OF NEXT PIXEL FOR PLAYER 2
	andi r4, r4, 0xFFFF					
	beq r4, r10, _wait	 				# IF(BACKGROUND) GOTO _wait
	beq r4, r11, _wait					# IF(BACKGROUND_FLUFF) GOTO _wait

	br _collision_p2 					# ELSE GOTO _collision_p2

_wait:									# WAIT TO SWAP
	
	ldwio r4, VCB_CONFIG(r8)
	andi r4, r4, 1
	bne r4, r0, _wait

_swap:									# SWAP BUFFERS

	sth r12, VCB_FRONT_BUFFER(r14)		# DRAWING PLAYER 1 FRONT BUFFER
	add r14, r14, r18

	sth r13, VCB_FRONT_BUFFER(r6)		# DRAWING PLAYER 2 FRONT BUFFER
	add r6, r6, r19

	sth r12, VCB_FRONT_BUFFER(r16)		# DRAWING PLAYER 1 BACK BUFFER
	add r16, r16, r18

	sth r13, VCB_FRONT_BUFFER(r7)		# DRAWING PLAYER 2 BACK BUFFER
	add r7, r7, r19

	stwio r2, VCB_FRONT_BUFFER(r8)		# PERFORMING SWAP

	br _in_game

_check_same_frame_collision:
	
	ldh r4, VCB_FRONT_BUFFER(r6)		# GRAB COLOUR OF NEXT PIXEL FOR PLAYER 2
	andi r4, r4, 0xFFFF
	beq r4, r10, _collision_p1 			# IF(BACKGROUND) GOTO _collision_p1
	beq r4, r11, _collision_p1 			# IF(BACKGROUND_FLUFF) GOTO _collision_p1

	br _same_frame_collision 			# COLLISION OCCURED FOR BOTH PLAYERS AT EXACT SAME FRAME
	
	
_collision_p2:							# PLAYER 1 COLLISION OCCURED

    ldhio r4, 0(r22)
    andi r4, r4, 0xFFFF

    # PLAYER2 SCORE IS ZERO
    movia r5, SCORE_ZERO_ZERO
    beq r4, r5, _score_one_zero_p1

    movia r5, SCORE_ONE_ZERO
    beq r4, r5, _score_two_zero_p1

    movia r5, SCORE_TWO_ZERO
    beq r4, r5, _score_three_zero_player1_wins

    # PLAYER2 SCORE IS ONE
    movia r5, SCORE_ZERO_ONE
    beq r4, r5, _score_one_one_p1

    movia r5, SCORE_ONE_ONE
    beq r4, r5, _score_two_one_p1

    movia r5, SCORE_TWO_ONE
    beq r4, r5, _score_three_one_player1_wins

    # PLAYER2 SCORE IS TWO
    movia r5, SCORE_ZERO_TWO
    beq r4, r5, _score_one_two_p1

    movia r5, SCORE_ONE_TWO
    beq r4, r5, _score_two_two_p1

    movia r5, SCORE_TWO_TWO
    beq r4, r5, _score_three_two_player1_wins

# PLAYER2 SCORE IS ZERO
_score_one_zero_p1:
    movia r4, SCORE_ONE_ZERO
    stwio r4, 0(r22)
    br _game_continue

_score_two_zero_p1:
    movia r4, SCORE_TWO_ZERO
    stwio r4, 0(r22)
    br _game_continue

_score_three_zero_player1_wins:
    movia r4, SCORE_THREE_ZERO
    stwio r4, 0(r22)
    br _p1_wins

# PLAYER2 SCORE IS ONE
_score_one_one_p1:
    movia r4, SCORE_ONE_ONE
    stwio r4, 0(r22)
    br _game_continue

_score_two_one_p1:
    movia r4, SCORE_TWO_ONE
    stwio r4, 0(r22)
    br _game_continue

_score_three_one_player1_wins:
    movia r4, SCORE_THREE_ONE
    stwio r4, 0(r22)
    br _p1_wins

# PLAYER2 SCORE IS TWO
_score_one_two_p1:
    movia r4, SCORE_ONE_TWO
    stwio r4, 0(r22)
    br _game_continue

_score_two_two_p1:
    movia r4, SCORE_ONE_TWO
    stwio r4, 0(r22)
    br _game_continue

_score_three_two_player1_wins:
    movia r4, SCORE_THREE_TWO
    stwio r4, 0(r22)
    br _p1_wins

_collision_p1:							# PLAYER 2 COLLISION OCCURED

    ldhio r4, 0(r22)
    andi r4, r4, 0xFFFF

    # PLAYER1 SCORE IS ZERO
    movia r5, SCORE_ZERO_ZERO
    beq r4, r5, _score_zero_one_p2

    movia r5, SCORE_ZERO_ONE
    beq r4, r5, _score_zero_two_p2

    movia r5, SCORE_ZERO_TWO
    beq r4, r5, _score_zero_three_player2_wins

    # PLAYER1 SCORE IS ONE
    movia r5, SCORE_ONE_ZERO
    beq r4, r5, _score_one_one_p2

    movia r5, SCORE_ONE_ONE
    beq r4, r5, _score_one_two_p2

    movia r5, SCORE_ONE_TWO
    beq r4, r5, _score_one_three_player2_wins

    # PLAYER1 SCORE IS TWO
    movia r5, SCORE_TWO_ZERO
    beq r4, r5, _score_two_one_p2

    movia r5, SCORE_TWO_ONE
    beq r4, r5, _score_two_two_p2

    movia r5, SCORE_TWO_TWO
    beq r4, r5, _score_two_three_player2_wins

# PLAYER2 SCORE IS ZERO
_score_zero_one_p2:
    movia r4, SCORE_ZERO_ONE
    stwio r4, 0(r22)
    br _game_continue

_score_zero_two_p2:
    movia r4, SCORE_ZERO_TWO
    stwio r4, 0(r22)
    br _game_continue

_score_zero_three_player2_wins:
    movia r4, SCORE_ZERO_THREE
    stwio r4, 0(r22)
    br _p2_wins

# PLAYER2 SCORE IS ONE
_score_one_one_p2:
    movia r4, SCORE_ONE_ONE
    stwio r4, 0(r22)
    br _game_continue

_score_one_two_p2:
    movia r4, SCORE_ONE_TWO
    stwio r4, 0(r22)
    br _game_continue

_score_one_three_player2_wins:
    movia r4, SCORE_ONE_THREE
    stwio r4, 0(r22)
    br _p2_wins

# PLAYER2 SCORE IS TWO
_score_two_one_p2:
    movia r4, SCORE_TWO_ONE
    stwio r4, 0(r22)
    br _game_continue

_score_two_two_p2:
    movia r4, SCORE_TWO_TWO
    stwio r4, 0(r22)
    br _game_continue

_score_two_three_player2_wins:
    movia r4, SCORE_TWO_THREE
    stwio r4, 0(r22)
    br _p2_wins

_same_frame_collision:
	
	br _game_continue

_p1_wins:
	
	movia r4, VGA_CHAR_BUFFER			# DRAW CHARACTERS
	addi r4, r4, 0x1696
	movi r5, 0x50 						# "P"
	sthio r5, 0(r4)
	movi r5, 0x4C						# "L"
	sthio r5, 2(r4)
	movi r5, 0x41						# "A"
	sthio r5, 4(r4)
	movi r5, 0x59						# "Y"
	sthio r5, 6(r4)
	movi r5, 0x45						# "E"
	sthio r5, 8(r4)
	movi r5, 0x52						# "R"
	sthio r5, 10(r4)
	movi r5, 0x20						# " "
	sthio r5, 12(r4)
	movi r5, 0x4F						# "O"
	sthio r5, 14(r4)
	movi r5, 0x4E						# "N"
	sthio r5, 16(r4)
	movi r5, 0x45						# "E"
	sthio r5, 18(r4)
	movi r5, 0x20						# " "
	sthio r5, 20(r4)
	movi r5, 0x57						# "W"
	sthio r5, 22(r4)
	movi r5, 0x49						# "I"
	sthio r5, 24(r4)
	movi r5, 0x4E						# "N"
	sthio r5, 26(r4)
	movi r5, 0x53						# "S"
	sthio r5, 28(r4)
	movi r5, 0x21						# "!"
	sthio r5, 30(r4)

	add r4, r0, r0 						# SET r4 TO 0
	br _game_end

_p2_wins:
	
	movia r4, VGA_CHAR_BUFFER			# DRAW CHARACTERS
	addi r4, r4, 0x1696
	movi r5, 0x50 						# "P"
	sthio r5, 0(r4)
	movi r5, 0x4C						# "L"
	sthio r5, 2(r4)
	movi r5, 0x41						# "A"
	sthio r5, 4(r4)
	movi r5, 0x59						# "Y"
	sthio r5, 6(r4)
	movi r5, 0x45						# "E"
	sthio r5, 8(r4)
	movi r5, 0x52						# "R"
	sthio r5, 10(r4)
	movi r5, 0x20						# " "
	sthio r5, 12(r4)
	movi r5, 0x54						# "T"
	sthio r5, 14(r4)
	movi r5, 0x57						# "W"
	sthio r5, 16(r4)
	movi r5, 0x4F						# "O"
	sthio r5, 18(r4)
	movi r5, 0x20						# " "
	sthio r5, 20(r4)
	movi r5, 0x57						# "W"
	sthio r5, 22(r4)
	movi r5, 0x49						# "I"
	sthio r5, 24(r4)
	movi r5, 0x4E						# "N"
	sthio r5, 26(r4)
	movi r5, 0x53						# "S"
	sthio r5, 28(r4)
	movi r5, 0x21						# "!"
	sthio r5, 30(r4)

	add r4, r0, r0 						# SET r4 TO 0

_game_end:								# GAME FINISHED
	
	movia r5, LED_BASE
	add r2, r0, r0

_led_flicker:

	ldwio r2, 0(r5)
	nor r2, r2, r0
	stwio r2, 0(r5)
	add r2, r0, r0
	addi r2, r2, 100

_inf_loop:

	subi r2, r2, 1
	beq r2, r0, _led_flicker
	beq r4, r0, _inf_loop

	stwio r0, 0(r5)

	movia r4, VGA_CHAR_BUFFER			# ERASE CHARACTERS
	addi r4, r4, 0x1694
	movi r5, 0x20						# " "
	sthio r5, 0(r4)
	movi r5, 0x20						# " "
	sthio r5, 2(r4)
	movi r5, 0x20						# " "
	sthio r5, 4(r4)
	movi r5, 0x20						# " "
	sthio r5, 6(r4)
	movi r5, 0x20						# " "
	sthio r5, 8(r4)
	movi r5, 0x20						# " "
	sthio r5, 10(r4)
	movi r5, 0x20						# " "
	sthio r5, 12(r4)
	movi r5, 0x20						# " "
	sthio r5, 14(r4)
	movi r5, 0x20						# " "
	sthio r5, 16(r4)
	movi r5, 0x20						# " "
	sthio r5, 18(r4)
	movi r5, 0x20						# " "
	sthio r5, 20(r4)
	movi r5, 0x20						# " "
	sthio r5, 22(r4)
	movi r5, 0x20						# " "
	sthio r5, 24(r4)
	movi r5, 0x20						# " "
	sthio r5, 26(r4)
	movi r5, 0x20						# " "
	sthio r5, 28(r4)
	movi r5, 0x20						# " "
	sthio r5, 30(r4)
	movi r5, 0x20						# " "
	sthio r5, 32(r4)
	movi r5, 0x20

	movi r2, 1
	br _game							# RESTART