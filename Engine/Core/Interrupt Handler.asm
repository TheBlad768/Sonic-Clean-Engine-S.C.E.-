; ---------------------------------------------------------------------------
; Vertical interrupt handler
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

VInt:
		movem.l	d0-a6,-(sp)							; save all the registers to the stack
		lea	(VDP_data_port).l,a6						; load VDP data address to a6
		lea	VDP_control_port-VDP_data_port(a6),a5				; load VDP control address to a5

		; check lag
		tst.b	(V_int_flag).w
		beq.s	VInt_Lag_Main

.wait
		moveq	#8,d0
		and.w	VDP_control_port-VDP_control_port(a5),d0
		beq.s	.wait								; wait until vertical blanking is taking place

		move.l	#vdpComm(0,VSRAM,WRITE),VDP_control_port-VDP_control_port(a5)
		move.l	(V_scroll_value).w,VDP_data_port-VDP_data_port(a6)		; send screen ypos to VSRAM

		; detect PAL region consoles
		btst	#0,(VDP_control_port-VDP_control_port)+1(a5)
		beq.s	.not_pal							; branch if it's not a PAL system

		; wait to hide CRAM dots
		move.w	#$700,d0
		dbf	d0,*								; otherwise, waste a bit of time here

.not_pal

		; VInt flag shared VInt pointer RAM
		; VInt flag must be cleared before checking the pointer

		sf	(V_int_flag).w							; clear VInt flag
		st	(H_int_flag).w							; allow H Interrupt code to run

		; check
		move.l	(V_int_ptr).w,d0						; get VInt pointer to d0
		beq.s	VInt_Music							; if zero, branch
		movea.l	d0,a0								; load VInt pointer to a0
		jsr	(a0)								; jump to current VInt pointer

VInt_Music:
		SMPS_UpdateSoundDriver							; update SMPS ; warning: a5-a6 will be overwritten

VInt_Done:
		addq.l	#1,(V_int_run_count).w
		movem.l	(sp)+,d0-a6							; return saved registers from the stack
		rte

; ---------------------------------------------------------------------------
; Lag
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

VInt_Lag:
		addq.w	#4,sp								; do not execute "VInt_Music" and "VInt_Done" twice

VInt_Lag_Main:
		addq.w	#1,(Lag_frame_count).w

		; branch if a level is running
		moveq	#$7C,d0								; limit Game Mode value to $7C max
		and.b	(Game_mode).w,d0						; get Game Mode to d0
		cmpi.b	#GameModeID_LevelScreen,d0					; is game on a level?
		bne.s	VInt_Music							; if not, return from V-int

		; level only

.main_level

		; check water
		tst.b	(Water_flag).w
		beq.s	.skip_water

		; detect PAL region consoles
		btst	#0,(VDP_control_port-VDP_control_port)+1(a5)
		beq.s	.not_pal							; branch if it isn't a PAL system

		; wait to hide CRAM dots
		move.w	#$700,d0
		dbf	d0,*								; otherwise waste a bit of time here

.not_pal
		st	(H_int_flag).w							; set HInt flag
		stopZ80
		tst.b	(Water_full_screen_flag).w					; is water above top of screen?
		bne.s	.water_above							; if yes, branch
		dma68kToVDP Normal_palette,0,$80,CRAM
		bra.s	.water_below
; ---------------------------------------------------------------------------

.water_above
		dma68kToVDP Water_palette,0,$80,CRAM

.water_below
		move.w	(H_int_counter_command).w,VDP_control_port-VDP_control_port(a5)
		startZ80
		bra.w	VInt_Music
; ---------------------------------------------------------------------------

.skip_water

		; detect PAL region consoles
		btst	#0,(VDP_control_port-VDP_control_port)+1(a5)
		beq.s	.not_pal2							; branch if it isn't a PAL system

		; wait to hide CRAM dots
		move.w	#$700,d0
		dbf	d0,*								; otherwise, waste a bit of time here

.not_pal2
		st	(H_int_flag).w
		move.w	(H_int_counter_command).w,VDP_control_port-VDP_control_port(a5)
		bra.w	VInt_Music

; ---------------------------------------------------------------------------
; Main
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

VInt_Main:
		bsr.s	Do_ControllerPal

		; check demo
		tst.w	(Demo_timer).w							; is there time left on the demo?
		beq.s	.return								; if not, branch
		subq.w	#1,(Demo_timer).w						; subtract 1 from time left

.return
		rts

; ---------------------------------------------------------------------------
; Menu
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

VInt_Menu:
		bsr.s	Do_ControllerPal

		; check demo
		tst.w	(Demo_timer).w							; is there time left on the demo?
		beq.s	.kospm								; if not, branch
		subq.w	#1,(Demo_timer).w						; subtract 1 from time left

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
		tst.b	(Water_full_screen_flag).w					; is water above top of screen?
		bne.s	.water_above							; if yes, branch
		dma68kToVDP Normal_palette,0,$80,CRAM
		bra.s	.water_below
; ---------------------------------------------------------------------------

.water_above
		dma68kToVDP Water_palette,0,$80,CRAM

.water_below
		dma68kToVDP Sprite_table_buffer,VRAM_Sprite_Attribute_Table,VRAM_Sprite_Attribute_Table_Size,VRAM
		dma68kToVDP H_scroll_buffer,VRAM_Horiz_Scroll_Table,VRAM_Horiz_Scroll_Table_Size,VRAM
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
		dma68kToVDP H_scroll_buffer,VRAM_Horiz_Scroll_Table,VRAM_Horiz_Scroll_Table_Size,VRAM
		dma68kToVDP (LevelSelect.buffer2),VRAM_Plane_A_Name_Table,VRAM_Plane_Table_Size,VRAM	; foreground buffer to VRAM
		jsr	(Process_DMA_Queue).w
		startZ80

		; check demo
		tst.w	(Demo_timer).w							; is there time left on the demo?
		beq.s	.return								; if not, branch
		subq.w	#1,(Demo_timer).w						; subtract 1 from time left

.return
		rts

; ---------------------------------------------------------------------------
; Sega
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

VInt_Sega:
		moveq	#$F,d0
		and.b	(V_int_run_count.byte).w,d0
		bne.s	.check_demo							; run the following code once every 16 frames
		stopZ80
		stopZ802
		bsr.w	Poll_Controllers
		startZ802
		startZ80

.check_demo

		; check demo
		tst.w	(Demo_timer).w							; is there time left on the demo?
		beq.s	.return								; if not, branch
		subq.w	#1,(Demo_timer).w						; subtract 1 from time left

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

		; check flash screen white
		tst.b	(Hyper_Sonic_flash_timer).w					; is white flash timer over?
		beq.s	.no_white_flash							; if yes, branch
		tst.b	(Game_paused).w							; is the game paused?
		bne.s	.draw_white_flash						; if yes, branch

		; flash screen white
		subq.b	#1,(Hyper_Sonic_flash_timer).w

.draw_white_flash
		move.l	#vdpComm(0,CRAM,WRITE),VDP_control_port-VDP_control_port(a5)
		move.l	#words_to_long(cWhite,cWhite),d0

	rept (palette_line_size*4)/4
		move.l	d0,VDP_data_port-VDP_data_port(a6)
	endr

		bra.w	.main_level
; ---------------------------------------------------------------------------

.no_white_flash

		; check flash screen negative
		tst.b	(Negative_flash_timer).w					; is negative flash timer over?
		beq.w	.no_negative_flash						; if yes, branch
		tst.b	(Game_paused).w							; is the game paused?
		bne.s	.check_negative_flash						; if yes, branch

		; flash screen negative
		subq.b	#1,(Negative_flash_timer).w

.check_negative_flash
		btst	#2,(Negative_flash_timer).w					; 0 or 4
		beq.w	.no_negative_flash

		; draw negative flash
		move.l	#vdpComm(0,CRAM,WRITE),VDP_control_port-VDP_control_port(a5)
		move.l	#words_to_long($EEE,$EEE),d2
		lea	(Normal_palette).w,a1

	rept (palette_line_size*4)/4
		move.l	(a1)+,d0
		eor.l	d2,d0
		move.l	d0,VDP_data_port-VDP_data_port(a6)
	endr

		bra.s	.main_level
; ---------------------------------------------------------------------------

.no_negative_flash
		tst.b	(Water_full_screen_flag).w					; is water above top of screen?
		bne.s	.water_above							; if yes, branch
		dma68kToVDP Normal_palette,0,$80,CRAM
		bra.s	.water_below
; ---------------------------------------------------------------------------

.water_above
		dma68kToVDP Water_palette,0,$80,CRAM

.water_below
		move.w	(H_int_counter_command).w,VDP_control_port-VDP_control_port(a5)

.main_level
		dma68kToVDP H_scroll_buffer,VRAM_Horiz_Scroll_Table,VRAM_Horiz_Scroll_Table_Size,VRAM
		dma68kToVDP Sprite_table_buffer,VRAM_Sprite_Attribute_Table,VRAM_Sprite_Attribute_Table_Size,VRAM
		jsr	(Process_DMA_Queue).w
		bsr.s	VInt_SpecialFunction
		bsr.w	VInt_DrawLevel.main
		startZ80
		enableInts

		; check water flag
		tst.b	(Water_flag).w
		beq.s	.not_water
		cmpi.b	#92,(H_int_counter).w						; is H-int occuring on or below line 92?
		bhs.s	.not_water							; if it is, branch
		st	(Do_Updates_in_H_int).w
		move.l	#VInt_Done,(sp)							; skip update SMPS
		jmp	(Set_KosPlus_Bookmark).w
; ---------------------------------------------------------------------------

.not_water
		pea	(Set_KosPlus_Bookmark).w

; ---------------------------------------------------------------------------
; Other updates
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Do_Updates:
		bsr.w	HUD_Update
		clr.w	(Lag_frame_count).w

		; check demo
		tst.w	(Demo_timer).w							; is there time left on the demo?
		beq.s	.return								; if not, branch
		subq.w	#1,(Demo_timer).w						; subtract 1 from time left

.return
		rts

; ---------------------------------------------------------------------------
; Special function
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

VInt_SpecialFunction:
		moveq	#0,d0
		move.b	(Special_V_int_routine).w,d0
		beq.s	.return								; if zero, return
		jmp	.index-2(pc,d0.w)
; ---------------------------------------------------------------------------

.index
		bra.s	.vscroll_on							; 2 (vertical scrolling on)
		bra.s	.vscroll_copy							; 4 (vertical scrolling copy)
; ---------------------------------------------------------------------------

		; vscrolloff								; 6 (vertical scrolling off)
		move.w	#$8B03,VDP_control_port-VDP_control_port(a5)			; command $8B03 - VScroll full, HScroll line-based
		clr.b	(Special_V_int_routine).w

.return
		rts
; ---------------------------------------------------------------------------

.vscroll_on
		move.w	#$8B07,VDP_control_port-VDP_control_port(a5)			; command $8B07 - VScroll cell-based, HScroll line-based
		addq.b	#2,(Special_V_int_routine).w

.vscroll_copy
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

		; check
		tst.b	(H_int_flag).w							; is the HInt flag set?
		beq.w	HInt_Done							; if not, branch
		sf	(H_int_flag).w							; clear HInt flag

		; set
		movem.l	a0-a1,-(sp)
		lea	(VDP_data_port).l,a1						; load VDP data address to a1
		move.w	#$8A00+(screen_height-1),VDP_control_port-VDP_data_port(a1)
		lea	(Water_palette).w,a0
		move.l	#vdpComm(0,CRAM,WRITE),VDP_control_port-VDP_data_port(a1)

	rept 64/2
		move.l	(a0)+,VDP_data_port-VDP_data_port(a1)
	endr

		movem.l	(sp)+,a0-a1

		; check
		tst.b	(Do_Updates_in_H_int).w						; is the HInt do updates flag set?
		beq.s	HInt_Done							; if not, branch
		sf	(Do_Updates_in_H_int).w						; clear HInt do updates flag

		; update
		movem.l	d0-a6,-(sp)							; move all the registers to the stack
		bsr.w	Do_Updates
		SMPS_UpdateSoundDriver							; Update SMPS
		movem.l	(sp)+,d0-a6							; load saved registers from the stack

HInt_Done:
		rte
