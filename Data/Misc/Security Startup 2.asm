; ---------------------------------------------------------------------------
; Subroutine to initialise game
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Game_Program:
		move.w	#$4EF9,(V_int_jump).w							; machine code for jmp
		move.l	#VInt,(V_int_addr).w
		move.w	#$4EF9,(H_int_jump).w
		move.l	#HInt,(H_int_addr).w

.wait
		move.w	(VDP_control_port).l,d1
		btst	#1,d1
		bne.s	.wait											; wait till a DMA is completed

		; clear RAM
		clearRAM RAM_start, RAM_end							; clear RAM

		; check
		btst	#6,(HW_Expansion_Control).l
		beq.s	.skip
		cmpi.l	#Ref_Checksum_String,(Checksum_string).w			; has checksum routine already run?
		beq.s	.init												; if yes, branch

.skip

		; get region
		moveq	#signextendB($C0),d0
		and.b	(HW_Version).l,d0
		move.b	d0,(Graphics_flags).w								; save region setting
		move.l	#Ref_Checksum_String,(Checksum_string).w			; set flag so checksum won't run again

.init
		jsr	(Init_MSU_Driver).l
		seq	(SegaCD_Mode).w
		bsr.w	Init_DMA_Queue
		bsr.s	Init_VDP
		bsr.w	SoundDriverLoad
		bsr.w	Init_Controllers
		move.b	#id_LevelSelectScreen,(Game_mode).w				; set Game Mode

.loop
		moveq	#$7C,d0											; limit Game Mode value to $7C max
		and.b	(Game_mode).w,d0								; load Game Mode
		movea.l	Game_Modes(pc,d0.w),a0
		jsr	(a0)
		bra.s	.loop

; ---------------------------------------------------------------------------
; Main game mode array
; ---------------------------------------------------------------------------

Game_Modes:
ptr_LevelSelect:	dc.l LevelSelect_Screen		; Level Select ($00)
ptr_Level:		dc.l Level_Screen			; Level ($04)
