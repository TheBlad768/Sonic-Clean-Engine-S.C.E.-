
; =============== S U B R O U T I N E =======================================

LevelSetup:
		move.w	#$FFF,(Screen_Y_wrap_value).w
		move.w	#$FF0,(Camera_Y_pos_mask).w
		move.w	#$7C,(Layout_row_index_mask).w
		move.w	(Camera_X_pos).w,(Camera_X_pos_copy).w
		move.w	(Camera_Y_pos).w,(Camera_Y_pos_copy).w
		lea	(Plane_buffer).w,a0
		movea.l	(Block_table_addr_ROM).w,a2
		movea.l	(Level_layout2_addr_ROM).w,a3
		move.w	#vram_fg,d7
		movea.l	(Level_data_addr_RAM.ScreenInit).w,a1
		jsr	(a1)
		addq.w	#2,a3
		move.w	#vram_bg,d7
		movea.l	(Level_data_addr_RAM.BackgroundInit).w,a1
		jsr	(a1)
		move.w	(Camera_Y_pos_copy).w,(V_scroll_value).w
		move.w	(Camera_Y_pos_BG_copy).w,(V_scroll_value_BG).w
		rts
; ---------------------------------------------------------------------------

ScreenEvents:
		move.w	(Camera_X_pos).w,(Camera_X_pos_copy).w
		move.w	(Camera_Y_pos).w,(Camera_Y_pos_copy).w
		lea	(Plane_buffer).w,a0
		movea.l	(Block_table_addr_ROM).w,a2
		movea.l	(Level_layout2_addr_ROM).w,a3
		move.w	#vram_fg,d7
		movea.l	(Level_data_addr_RAM.ScreenEvent).w,a1
		jsr	(a1)
		addq.w	#2,a3
		move.w	#vram_bg,d7
		movea.l	(Level_data_addr_RAM.BackgroundEvent).w,a1
		jsr	(a1)
		move.w	(Camera_Y_pos_copy).w,(V_scroll_value).w
		move.w	(Camera_Y_pos_BG_copy).w,(V_scroll_value_BG).w
		rts

; =============== S U B R O U T I N E =======================================

DEZ1_ScreenInit:
		bsr.w	Reset_TileOffsetPositionActual
		bra.w	Refresh_PlaneFull

; =============== S U B R O U T I N E =======================================

DEZ1_ScreenEvent:
		tst.b (Screen_event_flag).w
		bne.s	DEZ1_ScreenEvent_RefreshPlane
		move.w	(Screen_shaking_flag+2).w,d0
		add.w	d0,(Camera_Y_pos_copy).w
		bra.w	DrawTilesAsYouMove
; ---------------------------------------------------------------------------

DEZ1_ScreenEvent_RefreshPlane:
		clr.b	(Screen_event_flag).w
		bra.w	Refresh_PlaneScreenDirect

; =============== S U B R O U T I N E =======================================

DEZ1_BackgroundInit:
		bsr.s	DEZ1_Deform
		bsr.w	Reset_TileOffsetPositionEff
		moveq	#0,d1	; Set XCam BG pos
		bsr.w	Refresh_PlaneFull
		bra.s	DEZ1_BackgroundEvent.deform

; =============== S U B R O U T I N E =======================================

DEZ1_BackgroundEvent:
		tst.b (Background_event_flag).w
		bne.s	DEZ1_Transition
		bsr.s	DEZ1_Deform

.deform:
		lea	DEZ1_BGDrawArray(pc),a4
		lea	(H_scroll_table).w,a5
		bsr.w	ApplyDeformation
		bra.w	ShakeScreen_Setup
; ---------------------------------------------------------------------------

DEZ1_BGDrawArray:	dc.w $7FFF
; ---------------------------------------------------------------------------

DEZ1_Deform:
		lea	DEZ1_ParallaxScript(pc),a1
		bra.w	ExecuteParallaxScript
; ---------------------------------------------------------------------------

DEZ1_ParallaxScript:
			; Mode	Speed coef.	Number of lines(Linear only)
		dc.w	_normal,	 $0050		; BG
		dc.w	-1
; ---------------------------------------------------------------------------

DEZ1_Transition:
		clr.b	(Background_event_flag).w
		rts

