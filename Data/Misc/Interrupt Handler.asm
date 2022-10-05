; ---------------------------------------------------------------------------
; Vertical interrupt handler
; ---------------------------------------------------------------------------

VInt:
		movem.l	d0-a6,-(sp)							; save all the registers to the stack
		lea	(VDP_data_port).l,a6
		lea	VDP_control_port-VDP_data_port(a6),a5

		tst.b	(V_int_routine).w
		beq.s	VInt_Lag_Main

.wait
		move.w	VDP_control_port-VDP_control_port(a5),d0
		andi.w	#8,d0
		beq.s	.wait	; wait until vertical blanking is taking place

		move.l	#vdpComm($0000,VSRAM,WRITE),VDP_control_port-VDP_control_port(a5)
		move.l	(V_scroll_value).w,VDP_data_port-VDP_data_port(a6) ; send screen ypos to VSRAM
		btst	#6,(Graphics_flags).w
		beq.s	.notpal								; branch if it's not a PAL system
		move.w	#$700,d0
		dbf	d0,*										; otherwise, waste a bit of time here

.notpal
		move.b	(V_int_routine).w,d0
		clr.b	(V_int_routine).w
		st	(H_int_flag).w							; allow H Interrupt code to run
		andi.w	#$3E,d0
		move.w	VInt_Table(pc,d0.w),d0
		jsr	VInt_Table(pc,d0.w)

VInt_Music:
		SMPS_UpdateSoundDriver						; update SMPS	; warning: a5-a6 will be overwritten

VInt_Done:
		jsr	(Random_Number).w
		addq.l	#1,(V_int_run_count).w
	if Lagometer
		move.w	#$9193,(VDP_control_port).l			; window H right side, base point $80
	endif
		movem.l	(sp)+,d0-a6							; return saved registers from the stack
		rte
; ---------------------------------------------------------------------------

VInt_Table: offsetTable
ptr_VInt_Lag:		offsetTableEntry.w VInt_Lag		; 0
ptr_VInt_Main:		offsetTableEntry.w VInt_Main		; 2
ptr_VInt_Sega:		offsetTableEntry.w VInt_Sega		; 4
ptr_VInt_Menu:		offsetTableEntry.w VInt_Menu		; 6
ptr_VInt_Level:		offsetTableEntry.w VInt_Level		; 8
ptr_VInt_Fade:		offsetTableEntry.w VInt_Fade		; A

; ---------------------------------------------------------------------------
; Lag
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

VInt_Lag:
		addq.w	#4,sp

VInt_Lag_Main:
		addq.b	#1,(Lag_frame_count).w

		; branch if a level is running
		cmpi.b	#GameModeID_TitleCard|id_LevelScreen,(Game_mode).w
		beq.s	VInt_Lag_Level
		cmpi.b	#id_LevelScreen,(Game_mode).w		; is game on a level?
		beq.s	VInt_Lag_Level
		bra.s	VInt_Music							; otherwise, return from V-int
; ---------------------------------------------------------------------------

VInt_Lag_Level:
		tst.b	(Water_flag).w
		beq.w	VInt_Lag_NoWater
		move.w	VDP_control_port-VDP_control_port(a5),d0
		btst	#6,(Graphics_flags).w
		beq.s	.notpal								; branch if it isn't a PAL system
		move.w	#$700,d0
		dbf	d0,*										; otherwise waste a bit of time here

.notpal
		st	(H_int_flag).w							; set HInt flag
		stopZ80
		tst.b	(Water_full_screen_flag).w					; is water above top of screen?
		bne.s	VInt_Lag_FullyUnderwater 			; if yes, branch
		dma68kToVDP Normal_palette,$0000,$80,CRAM
		bra.s	VInt_Lag_Water_Cont
; ---------------------------------------------------------------------------

VInt_Lag_FullyUnderwater:
		dma68kToVDP Water_palette,$0000,$80,CRAM

VInt_Lag_Water_Cont:
		move.w	(H_int_counter_command).w,VDP_control_port-VDP_control_port(a5)
		startZ80
		bra.w	VInt_Music
; ---------------------------------------------------------------------------

VInt_Lag_NoWater:
		move.w	VDP_control_port-VDP_control_port(a5),d0
		btst	#6,(Graphics_flags).w
		beq.s	.notpal	; branch if it isn't a PAL system
		move.w	#$700,d0
		dbf	d0,*		; otherwise, waste a bit of time here

.notpal
		st	(H_int_flag).w
		move.w	(H_int_counter_command).w,VDP_control_port-VDP_control_port(a5)

VInt_Lag_Done:
		bra.w	VInt_Music

; ---------------------------------------------------------------------------
; Main
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

VInt_Main:
		bsr.s	Do_ControllerPal
		tst.w	(Demo_timer).w
		beq.s	.return
		subq.w	#1,(Demo_timer).w

.return
		rts

; ---------------------------------------------------------------------------
; Menu
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

VInt_Menu:
		bsr.s	Do_ControllerPal
		tst.w	(Demo_timer).w
		beq.s	.kosm
		subq.w	#1,(Demo_timer).w

.kosm
		jmp	(Set_Kos_Bookmark).w

; ---------------------------------------------------------------------------
; Fade
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

VInt_Fade:
		bsr.s	Do_ControllerPal
		move.w	(H_int_counter_command).w,VDP_control_port-VDP_control_port(a5)
		jmp	(Set_Kos_Bookmark).w

; ---------------------------------------------------------------------------
; Main updates
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Do_ControllerPal:
		stopZ80
		stopZ802
		jsr	(Poll_Controllers).w
		startZ802
		tst.b	(Water_full_screen_flag).w
		bne.s	.water
		dma68kToVDP Normal_palette,$0000,$80,CRAM
		bra.s	.skipwater

.water
		dma68kToVDP Water_palette,$0000,$80,CRAM

.skipwater
		dma68kToVDP Sprite_table_buffer,vram_sprites,$280,VRAM
		dma68kToVDP H_scroll_buffer,vram_hscroll,(224<<2),VRAM
		jsr	(Process_DMA_Queue).w
		startZ80
		rts

; ---------------------------------------------------------------------------
; Sega
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

VInt_Sega:
		move.b	(V_int_run_count+3).w,d0
		andi.w	#$F,d0
		bne.s	.skip	; run the following code once every 16 frames
		stopZ80
		stopZ802
		jsr	(Poll_Controllers).w
		startZ802
		startZ80

.skip
		tst.w	(Demo_timer).w
		beq.s	.kosm
		subq.w	#1,(Demo_timer).w

.kosm
		jmp	(Set_Kos_Bookmark).w

; ---------------------------------------------------------------------------
; Level
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

VInt_Level:
		stopZ80
		stopZ802
		jsr	(Poll_Controllers).w
		startZ802
		tst.b	(Game_paused).w
		bne.s	VInt_Level_NoNegativeFlash
		tst.b	(Hyper_Sonic_flash_timer).w
		beq.s	VInt_Level_NoFlash

		; flash screen white
		subq.b	#1,(Hyper_Sonic_flash_timer).w
		move.l	#vdpComm($0000,CRAM,WRITE),VDP_control_port-VDP_control_port(a5)
		moveq	#64/2-1,d1
		move.l	#cWhite<<16|cWhite,d0

.copy
		move.l	d0,VDP_data_port-VDP_data_port(a6)
		dbf	d1,.copy	; fill entire palette with white
		bra.w	VInt_Level_Cont
; ---------------------------------------------------------------------------

VInt_Level_NoFlash:
		tst.b	(Negative_flash_timer).w
		beq.s	VInt_Level_NoNegativeFlash

		; flash screen negative
		subq.b	#1,(Negative_flash_timer).w
		btst	#2,(Negative_flash_timer).w
		beq.s	VInt_Level_NoNegativeFlash
		move.l	#vdpComm($0000,CRAM,WRITE),VDP_control_port-VDP_control_port(a5)
		moveq	#64/2-1,d1
		move.l	#$0EEE0EEE,d2
		lea	(Normal_palette).w,a1

.copy
		move.l	(a1)+,d0
		not.l	d0
		and.l	d2,d0
		move.l	d0,VDP_data_port-VDP_data_port(a6)
		dbf	d1,.copy
		bra.s	VInt_Level_Cont
; ---------------------------------------------------------------------------

VInt_Level_NoNegativeFlash:
		tst.b	(Water_full_screen_flag).w
		bne.s	.water
		dma68kToVDP Normal_palette,$0000,$80,CRAM
		bra.s	.skipwater

.water
		dma68kToVDP Water_palette,$0000,$80,CRAM

.skipwater
		move.w	(H_int_counter_command).w,VDP_control_port-VDP_control_port(a5)

VInt_Level_Cont:
		dma68kToVDP H_scroll_buffer,vram_hscroll,(224<<2),VRAM
		dma68kToVDP Sprite_table_buffer,vram_sprites,$280,VRAM
		jsr	(Process_DMA_Queue).w
		jsr	(VInt_DrawLevel).w
		startZ80
		enableInts
		tst.b	(Water_flag).w
		beq.s	.notwater
		cmpi.b	#92,(H_int_counter).w	; is H-int occuring on or below line 92?
		bhs.s	.notwater				; if it is, branch
		st	(Do_Updates_in_H_int).w
		jsr	(Set_Kos_Bookmark).w
		addq.l	#4,sp
		bra.w	VInt_Done
; ---------------------------------------------------------------------------

.notwater
		bsr.s	Do_Updates
		jmp	(Set_Kos_Bookmark).w

; ---------------------------------------------------------------------------
; Other updates
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Do_Updates:
		jsr	(UpdateHUD).w
		clr.w	(Lag_frame_count).w
		tst.w	(Demo_timer).w ; is there time left on the demo?
		beq.s	.return
		subq.w	#1,(Demo_timer).w ; subtract 1 from time left

.return
		rts

; ---------------------------------------------------------------------------
; Horizontal interrupt
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

HInt:
		disableInts
		tst.b	(H_int_flag).w
		beq.w	HInt_Done
		clr.b	(H_int_flag).w
		movem.l	a0-a1,-(sp)
		lea	(VDP_data_port).l,a1
		move.w	#$8A00+223,VDP_control_port-VDP_data_port(a1)
		lea	(Water_palette).w,a0
		move.l	#vdpComm($0000,CRAM,WRITE),VDP_control_port-VDP_data_port(a1)
	rept 64/2
		move.l	(a0)+,VDP_data_port-VDP_data_port(a1)
	endr
		movem.l	(sp)+,a0-a1
		tst.b	(Do_Updates_in_H_int).w
		beq.s	HInt_Done
		clr.b	(Do_Updates_in_H_int).w
		movem.l	d0-a6,-(sp)			; move all the registers to the stack
		bsr.w	Do_Updates
		SMPS_UpdateSoundDriver		; Update SMPS
		movem.l	(sp)+,d0-a6			; load saved registers from the stack

HInt_Done:
		rte
