; ---------------------------------------------------------------------------
; Vertical interrupt handler
; ---------------------------------------------------------------------------

VInt:
		nop
		movem.l	d0-a6,-(sp)							; save all the registers to the stack
		tst.b	(V_int_routine).w
		beq.w	VInt_Lag_Main

-		move.w	(VDP_control_port).l,d0
		andi.w	#8,d0
		beq.s	-	; wait until vertical blanking is taking place

		move.l	#vdpComm($0000,VSRAM,WRITE),(VDP_control_port).l
		move.l	(V_scroll_value).w,(VDP_data_port).l
		btst	#6,(Graphics_flags).w
		beq.s	+									; branch if it's not a PAL system
		move.w	#$700,d0
		dbf	d0,*										; otherwise, waste a bit of time here
+		move.b	(V_int_routine).w,d0
		clr.b	(V_int_routine).w
		st	(H_int_flag).w							; Allow H Interrupt code to run
		andi.w	#$3E,d0
		move.w	VInt_Table(pc,d0.w),d0
		jsr	VInt_Table(pc,d0.w)

VInt_Music:
		SMPS_UpdateSoundDriver						; Update SMPS

VInt_Done:
		jsr	(Random_Number).w
		addq.l	#1,(V_int_run_count).w
		movem.l	(sp)+,d0-a6							; return saved registers from the stack
		rte
; ---------------------------------------------------------------------------

VInt_Table: offsetTable
ptr_VInt_Lag:		offsetTableEntry.w VInt_Lag		; 0
ptr_VInt_Main:		offsetTableEntry.w VInt_Main		; 2
ptr_VInt_Sega:		offsetTableEntry.w VInt_Sega		; 4
ptr_VInt_Title:		offsetTableEntry.w VInt_Title		; 6
ptr_VInt_Menu:		offsetTableEntry.w VInt_Menu		; 8
ptr_VInt_Level:		offsetTableEntry.w VInt_Level		; A
ptr_VInt_TitleCard:	offsetTableEntry.w VInt_TitleCard	; C
ptr_VInt_Fade:		offsetTableEntry.w VInt_Fade		; E
; ---------------------------------------------------------------------------

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
		move.w	(VDP_control_port).l,d0
		btst	#6,(Graphics_flags).w
		beq.s	+									; branch if it isn't a PAL system
		move.w	#$700,d0
		dbf	d0,*										; otherwise waste a bit of time here
+		st	(H_int_flag).w							; set HInt flag
		stopZ80
		tst.b	(Water_full_screen_flag).w					; is water above top of screen?
		bne.s	VInt_Lag_FullyUnderwater 			; if yes, branch
		dma68kToVDP Normal_palette,$0000,$80,CRAM
		bra.s	VInt_Lag_Water_Cont
; ---------------------------------------------------------------------------

VInt_Lag_FullyUnderwater:
		dma68kToVDP Water_palette,$0000,$80,CRAM

VInt_Lag_Water_Cont:
		move.w	(H_int_counter_command).w,(a5)
		startZ80
		bra.w	VInt_Music
; ---------------------------------------------------------------------------

VInt_Lag_NoWater:
		move.w	(VDP_control_port).l,d0
		btst	#6,(Graphics_flags).w
		beq.s	+	; branch if it isn't a PAL system
		move.w	#$700,d0
		dbf	d0,*		; otherwise, waste a bit of time here
+		st	(H_int_flag).w
		move.w	(H_int_counter_command).w,(VDP_control_port).l

VInt_Lag_Done:
		bra.w	VInt_Music
; ---------------------------------------------------------------------------

VInt_Main:
		bsr.s	Do_ControllerPal
		tst.w	(Demo_timer).w
		beq.s	+
		subq.w	#1,(Demo_timer).w
+		rts
; ---------------------------------------------------------------------------

VInt_Title:
		bsr.s	Do_ControllerPal
		tst.w	(Demo_timer).w
		beq.s	+
		subq.w	#1,(Demo_timer).w
+		rts
; ---------------------------------------------------------------------------

VInt_Fade:
		bsr.s	Do_ControllerPal
		move.w	(H_int_counter_command).w,(a5)
		rts

; =============== S U B R O U T I N E =======================================

Do_ControllerPal:
		stopZ80
		stopZ802
		jsr	(Poll_Controllers).w
		startZ802
		tst.b	(Water_full_screen_flag).w
		bne.s	+
		dma68kToVDP Normal_palette,$0000,$80,CRAM
		bra.s	++
+		dma68kToVDP Water_palette,$0000,$80,CRAM
+		dma68kToVDP Sprite_table_buffer,vram_sprites,$280,VRAM
		dma68kToVDP H_scroll_buffer,vram_hscroll,$380,VRAM
		jsr	(Process_DMA_Queue).w
		startZ80
		rts
; End of function Do_ControllerPal

; =============== S U B R O U T I N E =======================================

VInt_Sega:
		move.b	(V_int_run_count+3).w,d0
		andi.w	#$F,d0
		bne.s	+	; run the following code once every 16 frames
		stopZ80
		stopZ802
		jsr	(Poll_Controllers).w
		startZ802
		startZ80
+		tst.w	(Demo_timer).w
		beq.s	+
		subq.w	#1,(Demo_timer).w
+		jmp	(Set_Kos_Bookmark).w
; ---------------------------------------------------------------------------

VInt_Menu:
		bsr.w	Do_ControllerPal
		tst.w	(Demo_timer).w
		beq.s	+
		subq.w	#1,(Demo_timer).w
+		jmp	(Set_Kos_Bookmark).w
; ---------------------------------------------------------------------------

VInt_TitleCard:
		bsr.w	Do_ControllerPal
		move.w	(H_int_counter_command).w,(a5)
		jmp	(Set_Kos_Bookmark).w
; ---------------------------------------------------------------------------

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
		lea	(VDP_data_port).l,a6
		move.l	#vdpComm($0000,CRAM,WRITE),VDP_control_port-VDP_data_port(a6)
		move.w	#cWhite,d0
		moveq	#64-1,d1

-		move.w	d0,VDP_data_port-VDP_data_port(a6)
		dbf	d1,-	; fill entire palette with white
		bra.w	VInt_Level_Cont
; ---------------------------------------------------------------------------

VInt_Level_NoFlash:
		tst.b	(Negative_flash_timer).w
		beq.s	VInt_Level_NoNegativeFlash
		subq.b	#1,(Negative_flash_timer).w
		btst	#2,(Negative_flash_timer).w
		beq.s	VInt_Level_NoNegativeFlash
		lea	(VDP_data_port).l,a6
		move.l	#vdpComm($0000,CRAM,WRITE),VDP_control_port-VDP_data_port(a6)
		moveq	#(64/2)-1,d1
		move.l	#$0EEE0EEE,d2
		lea	(Normal_palette).w,a1

-		move.l	(a1)+,d0
		not.l	d0
		and.l	d2,d0
		move.l	d0,VDP_data_port-VDP_data_port(a6)
		dbf	d1,-
		bra.s	VInt_Level_Cont
; ---------------------------------------------------------------------------

VInt_Level_NoNegativeFlash:
		tst.b	(Water_full_screen_flag).w
		bne.s	+
		dma68kToVDP Normal_palette,$0000,$80,CRAM
		bra.s	++
+		dma68kToVDP Water_palette,$0000,$80,CRAM
+		move.w	(H_int_counter_command).w,(a5)

VInt_Level_Cont:
		dma68kToVDP H_scroll_buffer,vram_hscroll,$380,VRAM
		dma68kToVDP Sprite_table_buffer,vram_sprites,$280,VRAM
		jsr	(Process_DMA_Queue).w
		jsr	(VInt_DrawLevel).w
		startZ80
		enableInts
		tst.b	(Water_flag).w
		beq.s	+
		cmpi.b	#92,(H_int_counter).w	; is H-int occuring on or below line 92?
		bhs.s	+
		st	(Do_Updates_in_H_int).w
		jsr	(Set_Kos_Bookmark).w
		addq.l	#4,sp
		bra.w	VInt_Done
+		bsr.s	Do_Updates
		jmp	(Set_Kos_Bookmark).w

; =============== S U B R O U T I N E =======================================

Do_Updates:
		jsr	(UpdateHUD).w
		clr.w	(Lag_frame_count).w
		tst.w	(Demo_timer).w ; is there time left on the demo?
		beq.s	+
		subq.w	#1,(Demo_timer).w ; subtract 1 from time left
+		rts
; End of function Do_Updates
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
	rept 32
		move.l	(a0)+,VDP_data_port-VDP_data_port(a1)
	endm
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