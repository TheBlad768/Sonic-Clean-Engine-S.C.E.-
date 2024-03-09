; ---------------------------------------------------------------------------
; DEZ events
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

DEZ1_ScreenInit:
		jsr	(Reset_TileOffsetPositionActual).w
		jmp	(Refresh_PlaneFull).w

; =============== S U B R O U T I N E =======================================

DEZ1_ScreenEvent:
		tst.b	(Screen_event_flag).w
		bne.s	DEZ1_ScreenEvent_RefreshPlane
		move.w	(Screen_shaking_offset).w,d0
		add.w	d0,(Camera_Y_pos_copy).w
		jmp	(DrawTilesAsYouMove).w
; ---------------------------------------------------------------------------

DEZ1_ScreenEvent_RefreshPlane:
		clr.b	(Screen_event_flag).w
		jmp	(Refresh_PlaneScreenDirect).w

; =============== S U B R O U T I N E =======================================

DEZ1_BackgroundInit:
		bsr.s	DEZ1_Deform
		jsr	(Reset_TileOffsetPositionEff).w
		jsr	(Refresh_PlaneFull).w
		bra.s	DEZ1_BackgroundEvent.deform

; =============== S U B R O U T I N E =======================================

DEZ1_BackgroundEvent:
		tst.b	(Background_event_flag).w
		bne.s	DEZ1_Transition
		bsr.s	DEZ1_Deform

.deform:
		lea	DEZ1_BGDeformArray(pc),a4
		lea	(H_scroll_table).w,a5
		jsr	(ApplyDeformation).w
		jmp	(ShakeScreen_Setup).w
; ---------------------------------------------------------------------------

DEZ1_Transition:
		clr.b	(Background_event_flag).w
		rts
; ---------------------------------------------------------------------------

DEZ1_BGDeformArray:
		dcb.w 15, 16		; stars
		dc.w $7FFF		; last stars
; ---------------------------------------------------------------------------

DEZ1_Deform:

		; yscroll
;		move.w	(Camera_Y_pos_copy).w,d0
;		asr.w	#6,d0
;		move.w	d0,(Camera_Y_pos_BG_copy).w

		; xscroll
		lea	(H_scroll_table).w,a1
		move.w	(Level_frame_counter).w,d0
		asr.w	d0								; $800
		move.w	d0,d1							; save speed star 1
		asr.w	d0								; $400
		move.w	d0,d2							; save speed star 2

	rept 16/2
		move.w	d1,(a1)+							; set speed star 1
		move.w	d2,(a1)+							; set speed star 2
	endr

		rts
