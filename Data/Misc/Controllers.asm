; ---------------------------------------------------------------------------
; Subroutine to initialise joypads
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Init_Controllers:
		stopZ80
		stopZ802
		moveq	#$40,d0
		lea	(HW_Port_1_Data).l,a0
		move.b	d0,HW_Port_1_Control-HW_Port_1_Data(a0)
		move.b	d0,HW_Port_2_Control-HW_Port_1_Data(a0)
		move.b	d0,HW_Expansion_Control-HW_Port_1_Data(a0)
		startZ802
		startZ80
		rts
; ---------------------------------------------------------------------------
; Subroutine to read joypad input, and send it to the RAM
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Poll_Controllers:
		lea	(Ctrl_1).w,a0
		lea	(HW_Port_1_Data).l,a1
		bsr.s	Poll_Controller	; poll first controller
		addq.w	#2,a1			; poll second controller

Poll_Controller:
		move.b	#0,(a1)			; Poll controller data port
		nop
		nop
		move.b	(a1),d0			; Get controller port data (start/A)
		lsl.b	#2,d0
		andi.b	#$C0,d0
		move.b	#$40,(a1)		; Poll controller data port again
		nop
		nop
		move.b	(a1),d1			; Get controller port data (B/C/Dpad)
		andi.b	#$3F,d1
		or.b	d1,d0				; Fuse together into one controller bit array
		not.b	d0
		move.b	(a0),d1			; Get press button data
		eor.b	d0,d1			; Toggle off buttons that are being held
		move.b	d0,(a0)+			; Put raw controller input (for held buttons) in F604/F606
		and.b	d0,d1
		move.b	d1,(a0)+			; Put pressed controller input in F605/F607
		rts
