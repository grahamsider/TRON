
	 #####################
	#######################
	##					 ##
	##	  TRON v1.0		 ##
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
	stwio r6, 0(r11)					# DISPLAY DATA VIA LEDS
	bne r5, r0, _ps2_valid				# IF MORE CHARS TO READ, RE-LOOP
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
	
	# INTERRUPT SETUP
	movui r4, 0x1						# r4 = TEMP
	wrctl ctl0, r4						# CPU	(status)
	stwio r4, PS2_CONTROL(r10)			# PS2	(IRQ 7)
	movui r4, 0x7
	wrctl ctl3, r4						# CPU	(ienable)
	
	stwio r0, 0(r11)					# RESETTING LEDS (TEMP)
	
	ret
	
#_startscreen:


	
_infloop:
	br _inf_loop