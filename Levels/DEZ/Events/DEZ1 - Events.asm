; ---------------------------------------------------------------------------
; DEZ events
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

DEZ1_ScreenInit:

		; update FG
		jsr	(Reset_TileOffsetPositionActual).w
		jmp	(Refresh_PlaneFull).w

; =============== S U B R O U T I N E =======================================

DEZ1_ScreenEvent:
		move.w	(Screen_shaking_offset).w,d0					; shake foreground
		add.w	d0,(Camera_Y_pos_copy).w
		jmp	(DrawTilesAsYouMove).w

; =============== S U B R O U T I N E =======================================

DEZ1_BackgroundInit:
		bsr.s	DEZ1_Deform

		; update BG
		jsr	(Reset_TileOffsetPositionEff).w
		jsr	(Refresh_PlaneFull).w

		; deform
		lea	DEZ1_BGDeformArray(pc),a4
		lea	(H_scroll_table).w,a5
		jmp	(ApplyDeformation).w

; =============== S U B R O U T I N E =======================================

DEZ1_BackgroundEvent:
		tst.b	(Background_event_flag).w
		bne.s	DEZ1_Transition
		bsr.s	DEZ1_Deform

.deform
		lea	DEZ1_BGDeformArray(pc),a4
		lea	(H_scroll_table).w,a5
		jsr	(ApplyDeformation).w
		jmp	(ShakeScreen_Setup).w
; ---------------------------------------------------------------------------

DEZ1_Transition:
		clr.b	(Background_event_flag).w
		rts

; =============== S U B R O U T I N E =======================================

DEZ1_Deform:

		; yscroll
;		move.w	(Camera_Y_pos_copy).w,d0					; 100% to d0 ($1000)
;		asr.w	#6,d0								; get 1.5625% ($40)
;		move.w	d0,(Camera_Y_pos_BG_copy).w					; save 1.5625%

		; xscroll
		lea	(H_scroll_table).w,a1
		move.w	(Level_frame_counter).w,d0					; 100% to d0 ($1000)
		asr.w	d0								; get 50% ($800)
		move.w	d0,d1								; save 50% speed star 1
		asr.w	d0								; get 25% ($400)

	rept 16/2
		move.w	d1,(a1)+							; set 50% speed star 1
		move.w	d0,(a1)+							; set 25% speed star 2
	endr

		rts
; ---------------------------------------------------------------------------

DEZ1_BGDeformArray:
		dcb.w 15, 16	; stars
		dc.w $7FFF	; last stars
