
	 ####################
	######################
	##     			 	##
	##	  TRON v2.0	 	##
	##			 		##
	##	  Created by 	##
	##	  Graham Sider	##
	##	& Junhyeok Hong	##
	##  			 	##
	##	  ECE 243		##
	##	  2018		 	##
	##			 		##
	######################
	 ####################
	
	
	
	
	########
	# DATA #
	########
	
	.section .data
	.align 2
	
	# VGA ADAPTER
	.equ VGA_PBASE, 0x08000000			# STORED IN: r8
	.equ VGA_CBASE, 0x09000000
	
	# VIDEO CONTROL BUFFER
	.equ VCB_BASE, 0xFF203020			# STORED IN: r9
	.equ VCB_FRONT_BUFFER, 0x00			# BASE
	.equ VCB_BACK_BUFFER, 0x04			# BASE + 4
	.equ VCB_PIXEL_COORDS, 0x08			# BASE + 8
	.equ VCB_CONFIG, 0x0C				# BASE + 12
	
	#PS/2 Controller
	.equ PS2_BASE, 0xFF200100			# STORED IN: r10
	.equ PS2_CONTROL, 0x04				# BASE + 4
	
	# (TEMP) LEDS
	.equ LED_BASE, 0xFF200000			# STORED IN: r11
	
    # Data for Player One
    PlayerOneData:  .byte ' '           # STORE IN: r12
    .equ KEY_A, 0x1C                    # All these keys stored in r7
    .equ KEY_W, 0x1D
    .equ KEY_S, 0x1B
    .equ KEY_D, 0x23

    # Data for Player Two
    PlayerTwoData:  .byte ' '

    # Colour Values For the Pixel buffer

    .equ red, 0xF100
    .equ blue, 0x001F
	
	
	##############
	# EXCEPTIONS #
	##############
	
	.section .exceptions, "ax"
	.align 2
	
_isr:
	
	ldwio r4, 0(r10)					# r4 = PS2 BASE INFO
	andi r5, r4, 0x00008000				# r5 = TEMP
	srli r5, 0x0E						
	bne r5, r0, _ps2_valid				# DATA VALID CHECK
	br _inf_loop						# PS2 DATA INVALID
	
_ps2_valid:								# PS2 DATA VALID
	
	andi r5, r4, 0xFFFF0000				# r5 = NUM CHARS LEFT TO READ
	andi r6, r4, 0x000000FF				# r6 = DATA

    movi r7, KEY_A                      # r7 = A
    beq r6, r7, _key_a_pressed

    movi r7, KEY_W                      # r7 = W
    beq r6, r7, _key_w_pressed

    movi r7, KEY_S                      # r7 = S
    beq r6, r7, _key_s_pressed

    movi r7, KEY_D                      # r7 = D
    beq r6, r7, _key_d_pressed

    br _done_player_move                # branch to end exception handler

_key_a_pressed:
    movia r12, PlayerOneData            # Write the Key into memory
    stbio r6, 0(r12)

    br _done_player_move                # branch to end exception handler

_key_w_pressed:

    br _done_player_move                # branch to end exception handler

_key_s_pressed:

    br _done_player_move                # branch to end exception handler

_key_d_pressed:

    br _done_player_move                # branch to end exception handler

_done_player_move:                      #END EXCEPTION HANDLER
    stwio r6, 0(r11)                    # DISPLAY DATA VIA LEDS
    bne r5, r0, _ps2_valid              # IF MORE CHARS TO READ, RE-LOOP
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
	br _infloop							# INFINITE LOOP (TEMP)
	
#	call _startscreen
	
	

_setup:
	
	movia r8, VGA_PBASE					# r8 = VGA PIXEL BASE
	movia r9, VCB_BASE					# r9 = VCB BASE
	movia r10, PS2_BASE					# r10 = PS2 BASE
	movia r11, LED_BASE					# r11 = LED BASE (TEMP)

    # ENABLE DOUBLE BUFFER
    movui  r4, 0x1                      # r4 = TEMP
    stwio r4, VCB_FRONT_BUFFER(r9)      # Enable double buffer (swap pixel data from back buffer to front buffer)

	# INTERRUPT SETUP
	wrctl ctl0, r4						# CPU	(status)
	stwio r4, PS2_CONTROL(r10)			# PS2	(IRQ 7)
	movui r4, 0x7
	wrctl ctl3, r4						# CPU	(ienable)
	
	stwio r0, 0(r11)					# RESETTING LEDS (TEMP)
	
	ret
	
#_startscreen:


	
_infloop:
	br _inf_loop
