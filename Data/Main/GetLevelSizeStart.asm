; ---------------------------------------------------------------------------
; Get level size
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Get_LevelSizeStart:
		lea	(Level_data_addr_RAM.xstart).w,a1
		move.l	(a1)+,d0
		move.l	d0,(Camera_min_X_pos).w
		move.l	d0,(Camera_target_min_X_pos).w
		move.l	(a1)+,d0
		move.l	d0,(Camera_min_Y_pos).w
		move.l	d0,(Camera_target_min_Y_pos).w

		; set
		move.w	#$60,(Distance_from_top).w
	if ExtendedCamera
		move.w	#320/2,(Camera_X_center).w
	endif
		move.w	#-1,d0
		move.w	d0,(Screen_X_wrap_value).w
		move.w	d0,(Screen_Y_wrap_value).w
		tst.b	(Last_star_post_hit).w							; have any lampposts been hit?
		beq.s	LevSz_StartLoc							; if not, branch
		bsr.w	Load_StarPost_Settings
		move.w	(Player_1+x_pos).w,d1
		move.w	(Player_1+y_pos).w,d0
		bra.s	LevSz_SkipStartPos
; ---------------------------------------------------------------------------

LevSz_StartLoc:
		lea	(Level_data_addr_RAM.Location).w,a1			; load Sonic's start location
		move.w	(a1)+,d1
		move.w	d1,(Player_1+x_pos).w						; set Sonic's position on x-axis
		moveq	#0,d0
		move.w	(a1),d0
		move.w	d0,(Player_1+y_pos).w						; set Sonic's position on y-axis

LevSz_SkipStartPos:
		subi.w	#160,d1									; is Sonic more than 160px from left edge?
		bhs.s	SetScr_WithinLeft						; if yes, branch
		moveq	#0,d1

SetScr_WithinLeft:
		move.w	(Camera_max_X_pos).w,d2
		cmp.w	d2,d1									; is Sonic inside the right edge?
		blo.s		SetScr_WithinRight						; if yes, branch
		move.w	d2,d1

SetScr_WithinRight:
		move.w	d1,(Camera_X_pos).w						; set horizontal screen position
		subi.w	#96,d0									; is Sonic within 96px of upper edge?
		bhs.s	SetScr_WithinTop						; if yes, branch
		moveq	#0,d0

SetScr_WithinTop:
		cmp.w	(Camera_max_Y_pos).w,d0				; is Sonic above the bottom edge?
		blt.s		SetScr_WithinBottom						; if yes, branch
		move.w	(Camera_max_Y_pos).w,d0

SetScr_WithinBottom:
		move.w	d0,(Camera_Y_pos).w						; set vertical screen position
		rts
