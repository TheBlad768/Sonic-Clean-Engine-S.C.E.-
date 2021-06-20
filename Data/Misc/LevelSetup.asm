
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
		move.w	(Current_zone_and_act).w,d0
		ror.b	#2,d0
		lsr.w	#2,d0
		movea.l	Offs_ScreenInit(pc,d0.w),a1
		jsr	(a1)
		addq.w	#2,a3
		move.w	#vram_bg,d7
		move.w	(Current_zone_and_act).w,d0
		ror.b	#2,d0
		lsr.w	#2,d0
		movea.l	Offs_BackgroundInit(pc,d0.w),a1
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
		move.w	(Current_zone_and_act).w,d0
		ror.b	#2,d0
		lsr.w	#2,d0
		movea.l	Offs_ScreenEvent(pc,d0.w),a1
		jsr	(a1)
		addq.w	#2,a3
		move.w	#vram_bg,d7
		move.w	(Current_zone_and_act).w,d0
		ror.b	#2,d0
		lsr.w	#2,d0
		movea.l	Offs_BackgroundEvent(pc,d0.w),a1
		jsr	(a1)
		move.w	(Camera_Y_pos_copy).w,(V_scroll_value).w
		move.w	(Camera_Y_pos_BG_copy).w,(V_scroll_value_BG).w
		rts
; ---------------------------------------------------------------------------

Offs_ScreenInit:
		dc.l DEZ1_ScreenInit			; DEZ1
Offs_BackgroundInit:
		dc.l DEZ1_BackgroundInit		; DEZ1
Offs_ScreenEvent:
		dc.l DEZ1_ScreenEvent			; DEZ1
Offs_BackgroundEvent:
		dc.l DEZ1_BackgroundEvent	; DEZ1
		dc.l DEZ1_ScreenInit			; DEZ2
		dc.l DEZ1_BackgroundInit		; DEZ2
		dc.l DEZ1_ScreenEvent			; DEZ2
		dc.l DEZ1_BackgroundEvent	; DEZ2
		dc.l DEZ1_ScreenInit			; DEZ3
		dc.l DEZ1_BackgroundInit		; DEZ3
		dc.l DEZ1_ScreenEvent			; DEZ3
		dc.l DEZ1_BackgroundEvent	; DEZ3
		dc.l DEZ1_ScreenInit			; DEZ4
		dc.l DEZ1_BackgroundInit		; DEZ4
		dc.l DEZ1_ScreenEvent			; DEZ4
		dc.l DEZ1_BackgroundEvent	; DEZ4

		zonewarning Offs_ScreenInit,(16*4)

; =============== S U B R O U T I N E =======================================

DEZ1_ScreenInit:
		jsr	Reset_TileOffsetPositionActual(pc)
		jmp	Refresh_PlaneFull(pc)

; =============== S U B R O U T I N E =======================================

DEZ1_ScreenEvent:
		tst.b (Screen_event_flag).w
		bne.s	DEZ1_ScreenEvent_RefreshPlane
		move.w	(Screen_shaking_flag+2).w,d0
		add.w	d0,(Camera_Y_pos_copy).w
		jmp	DrawTilesAsYouMove(pc)
; ---------------------------------------------------------------------------

DEZ1_ScreenEvent_RefreshPlane:
		clr.b	(Screen_event_flag).w
		jmp	Refresh_PlaneScreenDirect(pc)

; =============== S U B R O U T I N E =======================================

DEZ1_BackgroundInit:
		bsr.s	DEZ1_Deform
		jsr	Reset_TileOffsetPositionEff(pc)
		moveq	#0,d1	; Set XCam BG pos
		jsr	Refresh_PlaneFull(pc)
		bra.s	DEZ1_BackgroundEvent.deform

; =============== S U B R O U T I N E =======================================

DEZ1_BackgroundEvent:
		tst.b (Background_event_flag).w
		bne.s	DEZ1_Transition
		bsr.s	DEZ1_Deform

.deform:
		lea	DEZ1_BGDrawArray(pc),a4
		lea	(H_scroll_table).w,a5
		jsr	ApplyDeformation(pc)
		jmp	ShakeScreen_Setup(pc)
; ---------------------------------------------------------------------------

DEZ1_BGDrawArray:	dc.w $7FFF
; ---------------------------------------------------------------------------

DEZ1_Deform:
		lea	DEZ1_ParallaxScript(pc),a1
		jmp	ExecuteParallaxScript(pc)
; ---------------------------------------------------------------------------

DEZ1_ParallaxScript:
			; Mode	Speed coef.	Number of lines(Linear only)
		dc.w	_normal,	 $0050		; BG
		dc.w	-1
; ---------------------------------------------------------------------------

DEZ1_Transition:
		clr.b	(Background_event_flag).w
		rts

