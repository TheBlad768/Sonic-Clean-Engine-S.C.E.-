; ---------------------------------------------------------------------------
; Vertical interrupt handler
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

VInt:
		movem.l	d0-a6,-(sp)										; save all the registers to the stack
		lea	(VDP_data_port).l,a6									; load VDP data address to a6
		lea	VDP_control_port-VDP_data_port(a6),a5							; load VDP control address to a5

		; check
		tst.b	(V_int_routine).w
		beq.s	VInt_Lag_Main

.wait
		moveq	#8,d0
		and.w	VDP_control_port-VDP_control_port(a5),d0
		beq.s	.wait											; wait until vertical blanking is taking place

		move.l	#vdpComm(0,VSRAM,WRITE),VDP_control_port-VDP_control_port(a5)
		move.l	(V_scroll_value).w,VDP_data_port-VDP_data_port(a6)					; send screen ypos to VSRAM

		; detect PAL region consoles
		btst	#0,(VDP_control_port-VDP_control_port)+1(a5)
		beq.s	.notpal											; branch if it's not a PAL system
		move.w	#$700,d0
		dbf	d0,*											; otherwise, waste a bit of time here

.notpal
		moveq	#$7E,d0											; limit VInt routine value to $7E max
		and.b	(V_int_routine).w,d0									; get VInt routine to d0
		clr.b	(V_int_routine).w									; clear VInt routine
		st	(H_int_flag).w										; allow H Interrupt code to run
		move.w	VInt_Table(pc,d0.w),d0
		jsr	VInt_Table(pc,d0.w)

VInt_Done:
		jsr	(Random_Number).w
		addq.l	#1,(V_int_run_count).w
		movem.l	(sp)+,d0-a6										; return saved registers from the stack
		rte
; ---------------------------------------------------------------------------

VInt_Table: offsetTable
		ptrTableEntry.w VInt_Lag		; 0
		ptrTableEntry.w VInt_Main		; 2
		ptrTableEntry.w VInt_Sega		; 4
		ptrTableEntry.w VInt_Menu		; 6
		ptrTableEntry.w VInt_Level		; 8
		ptrTableEntry.w VInt_Fade		; A
		ptrTableEntry.w VInt_LevelSelect	; C

; ---------------------------------------------------------------------------
; Lag
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

VInt_Lag:
		addq.w	#4,sp

VInt_Lag_Main:
		addq.w	#1,(Lag_frame_count).w

		; branch if a level is running
		moveq	#$7C,d0											; limit Game Mode value to $7C max
		and.b	(Game_mode).w,d0									; get Game Mode to d0
		cmpi.b	#GameModeID_LevelScreen,d0								; is game on a level?
		bne.s	VInt_Done										; if not, return from V-int

VInt_Lag_Level:
		tst.b	(Water_flag).w
		beq.s	VInt_Lag_NoWater
		move.w	VDP_control_port-VDP_control_port(a5),d0

		; detect PAL region consoles
		btst	#0,(VDP_control_port-VDP_control_port)+1(a5)
		beq.s	.notpal											; branch if it isn't a PAL system
		move.w	#$700,d0
		dbf	d0,*											; otherwise waste a bit of time here

.notpal
		st	(H_int_flag).w										; set HInt flag
		stopZ80
		tst.b	(Water_full_screen_flag).w								; is water above top of screen?
		bne.s	VInt_Lag_FullyUnderwater								; if yes, branch
		dma68kToVDP Normal_palette,0,$80,CRAM
		bra.s	VInt_Lag_Water_Cont
; ---------------------------------------------------------------------------

VInt_Lag_FullyUnderwater:
		dma68kToVDP Water_palette,0,$80,CRAM

VInt_Lag_Water_Cont:
		move.w	(H_int_counter_command).w,VDP_control_port-VDP_control_port(a5)
		startZ80
		bra.w	VInt_Done
; ---------------------------------------------------------------------------

VInt_Lag_NoWater:
		move.w	VDP_control_port-VDP_control_port(a5),d0

		; detect PAL region consoles
		btst	#0,(VDP_control_port-VDP_control_port)+1(a5)
		beq.s	.notpal											; branch if it isn't a PAL system
		move.w	#$700,d0
		dbf	d0,*											; otherwise, waste a bit of time here

.notpal
		st	(H_int_flag).w
		move.w	(H_int_counter_command).w,VDP_control_port-VDP_control_port(a5)
		bra.w	VInt_Done

; ---------------------------------------------------------------------------
; Main
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

VInt_Main:
		bsr.s	Do_ControllerPal

		; demo
		tst.w	(Demo_timer).w										; is there time left on the demo?
		beq.s	.return											; if not, branch
		subq.w	#1,(Demo_timer).w									; subtract 1 from time left

.return
		rts

; ---------------------------------------------------------------------------
; Menu
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

VInt_Menu:
		bsr.s	Do_ControllerPal

		; demo
		tst.w	(Demo_timer).w										; is there time left on the demo?
		beq.s	.kospm											; if not, branch
		subq.w	#1,(Demo_timer).w									; subtract 1 from time left

.kospm
		jmp	(Set_KosPlus_Bookmark).w

; ---------------------------------------------------------------------------
; Fade
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

VInt_Fade:
		bsr.s	Do_ControllerPal
		move.w	(H_int_counter_command).w,VDP_control_port-VDP_control_port(a5)
		jmp	(Set_KosPlus_Bookmark).w

; ---------------------------------------------------------------------------
; Main updates
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Do_ControllerPal:
		stopZ80
		stopZ802
		bsr.w	Poll_Controllers
		startZ802
		tst.b	(Water_full_screen_flag).w
		bne.s	.water
		dma68kToVDP Normal_palette,0,$80,CRAM
		bra.s	.skipwater

.water
		dma68kToVDP Water_palette,0,$80,CRAM

.skipwater
		dma68kToVDP Sprite_table_buffer,VRAM_Sprite_Attribute_Table,VRAM_Sprite_Attribute_Table_Size,VRAM
		dma68kToVDP H_scroll_buffer,VRAM_Horiz_Scroll_Table,(224<<2),VRAM
		jsr	(Process_DMA_Queue).w
		startZ80
		rts

; ---------------------------------------------------------------------------
; Level Select
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

VInt_LevelSelect:
		stopZ80
		stopZ802
		bsr.w	Poll_Controllers
		startZ802
		dma68kToVDP Normal_palette,0,$80,CRAM
		dma68kToVDP Sprite_table_buffer,VRAM_Sprite_Attribute_Table,VRAM_Sprite_Attribute_Table_Size,VRAM
		dma68kToVDP H_scroll_buffer,VRAM_Horiz_Scroll_Table,(224<<2),VRAM
		dma68kToVDP (LevelSelect_buffer2),VRAM_Plane_A_Name_Table,VRAM_Plane_Table_Size,VRAM		; foreground buffer to VRAM
		jsr	(Process_DMA_Queue).w
		startZ80

		; demo
		tst.w	(Demo_timer).w										; is there time left on the demo?
		beq.s	.return											; if not, branch
		subq.w	#1,(Demo_timer).w									; subtract 1 from time left

.return
		rts

; ---------------------------------------------------------------------------
; Sega
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

VInt_Sega:
		moveq	#$F,d0
		and.b	(V_int_run_count+3).w,d0
		bne.s	.skip											; run the following code once every 16 frames
		stopZ80
		stopZ802
		bsr.w	Poll_Controllers
		startZ802
		startZ80

.skip

		; demo
		tst.w	(Demo_timer).w										; is there time left on the demo?
		beq.s	.return											; if not, branch
		subq.w	#1,(Demo_timer).w									; subtract 1 from time left

.return
		rts

; ---------------------------------------------------------------------------
; Level
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

VInt_Level:
		stopZ80
		stopZ802
		bsr.w	Poll_Controllers
		startZ802
		tst.b	(Game_paused).w										; is the game paused?
		bne.s	VInt_Level_NoNegativeFlash								; if yes, branch
		tst.b	(Hyper_Sonic_flash_timer).w
		beq.s	VInt_Level_NoFlash

		; flash screen white
		subq.b	#1,(Hyper_Sonic_flash_timer).w
		move.l	#vdpComm(0,CRAM,WRITE),VDP_control_port-VDP_control_port(a5)
		moveq	#bytesToXcnt(64,2),d1
		move.l	#words_to_long(cWhite,cWhite),d0

.copy
		move.l	d0,VDP_data_port-VDP_data_port(a6)
		dbf	d1,.copy										; fill entire palette with white
		bra.s	VInt_Level_Cont
; ---------------------------------------------------------------------------

VInt_Level_NoFlash:
		tst.b	(Negative_flash_timer).w
		beq.s	VInt_Level_NoNegativeFlash

		; flash screen negative
		subq.b	#1,(Negative_flash_timer).w
		btst	#2,(Negative_flash_timer).w
		beq.s	VInt_Level_NoNegativeFlash
		move.l	#vdpComm(0,CRAM,WRITE),VDP_control_port-VDP_control_port(a5)
		moveq	#bytesToXcnt(64,2),d1
		move.l	#words_to_long($EEE,$EEE),d2
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
		dma68kToVDP Normal_palette,0,$80,CRAM
		bra.s	.skipwater

.water
		dma68kToVDP Water_palette,0,$80,CRAM

.skipwater
		move.w	(H_int_counter_command).w,VDP_control_port-VDP_control_port(a5)

VInt_Level_Cont:
		dma68kToVDP H_scroll_buffer,VRAM_Horiz_Scroll_Table,(224<<2),VRAM
		dma68kToVDP Sprite_table_buffer,VRAM_Sprite_Attribute_Table,VRAM_Sprite_Attribute_Table_Size,VRAM
		jsr	(Process_DMA_Queue).w
		bsr.s	VInt_SpecialFunction
		jsr	(VInt_DrawLevel.main).w
		startZ80
		enableInts
		tst.b	(Water_flag).w
		beq.s	.notwater
		cmpi.b	#92,(H_int_counter).w									; is H-int occuring on or below line 92?
		bhs.s	.notwater										; if it is, branch
		st	(Do_Updates_in_H_int).w
		jmp	(Set_KosPlus_Bookmark).w
; ---------------------------------------------------------------------------

.notwater
		pea	(Set_KosPlus_Bookmark).w

; ---------------------------------------------------------------------------
; Other updates
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Do_Updates:
		jsr	(UpdateHUD).w
		clr.w	(Lag_frame_count).w

		; demo
		tst.w	(Demo_timer).w										; is there time left on the demo?
		beq.s	.return											; if not, branch
		subq.w	#1,(Demo_timer).w									; subtract 1 from time left

.return
		rts

; ---------------------------------------------------------------------------
; Special function
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

VInt_SpecialFunction:
		moveq	#0,d0
		move.b	(Special_V_int_routine).w,d0
		beq.s	.return											; if zero, branch
		jmp	.index-2(pc,d0.w)
; ---------------------------------------------------------------------------

.index
		bra.s	.vscrollon										; 2 (vertical scrolling on)
		bra.s	.vscrollcopy										; 4 (vertical scrolling copy)
; ---------------------------------------------------------------------------

.vscrolloff													; 6 (vertical scrolling off)
		move.w	#$8B03,VDP_control_port-VDP_control_port(a5)						; command $8B03 - VScroll full, HScroll line-based
		clr.b	(Special_V_int_routine).w

.return
		rts
; ---------------------------------------------------------------------------

.vscrollon
		move.w	#$8B07,VDP_control_port-VDP_control_port(a5)						; command $8B07 - VScroll cell-based, HScroll line-based
		addq.b	#2,(Special_V_int_routine).w

.vscrollcopy
		stopZ80
		dma68kToVDP V_scroll_buffer,0,(320/4),VSRAM
		startZ80
		rts

; ---------------------------------------------------------------------------
; Horizontal interrupt (Water)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

HInt:
		disableInts
		tst.b	(H_int_flag).w
		beq.s	HInt_Done
		clr.b	(H_int_flag).w
		movem.l	a0-a1,-(sp)
		lea	(VDP_data_port).l,a1									; load VDP data address to a1
		move.w	#$8A00+223,VDP_control_port-VDP_data_port(a1)
		lea	(Water_palette).w,a0
		move.l	#vdpComm(0,CRAM,WRITE),VDP_control_port-VDP_data_port(a1)

	rept 64/2
		move.l	(a0)+,VDP_data_port-VDP_data_port(a1)
	endr

		movem.l	(sp)+,a0-a1

		; check
		tst.b	(Do_Updates_in_H_int).w
		beq.s	HInt_Done
		clr.b	(Do_Updates_in_H_int).w
		movem.l	d0-a6,-(sp)										; move all the registers to the stack
		bsr.w	Do_Updates
		movem.l	(sp)+,d0-a6										; load saved registers from the stack

HInt_Done:
		rte
