; ---------------------------------------------------------------------------
; Get level size
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Get_LevelSizeStart:

		; get level size
		lea	(Level_data_addr_RAM.xstart).w,a1
		move.l	(a1)+,d0
		move.l	d0,(Camera_min_X_pos).w
		move.l	d0,(Camera_target_min_X_pos).w
		move.l	(a1)+,d0
		move.l	d0,(Camera_min_Y_pos).w
		move.l	d0,(Camera_target_min_Y_pos).w

		; set
		move.w	#(224/2)-16,(Distance_from_top).w

	if ExtendedCamera
		move.w	#320/2,(Camera_X_center).w
	endif

		moveq	#-1,d0
		move.w	d0,(Screen_X_wrap_value).w
		move.w	d0,(Screen_Y_wrap_value).w

		; check
		tst.b	(Last_star_post_hit).w						; have any starpost been hit?
		beq.s	.startloc							; if not, branch
		jsr	(Load_StarPost_Settings).l
		move.w	(Player_1+x_pos).w,d1
		move.w	(Player_1+y_pos).w,d0
		bra.s	.skipstartpos
; ---------------------------------------------------------------------------

.startloc
		lea	(Level_data_addr_RAM.Location).w,a1				; load Sonic's start location
		move.w	(a1)+,d1
		move.w	d1,(Player_1+x_pos).w						; set Sonic's position on x-axis
		move.w	(a1),d0
		move.w	d0,(Player_1+y_pos).w						; set Sonic's position on y-axis

.skipstartpos
		subi.w	#320/2,d1							; is Sonic more than 160px from left edge?
		bhs.s	.withinleft							; if yes, branch
		moveq	#0,d1

.withinleft
		move.w	(Camera_max_X_pos).w,d2
		cmp.w	d2,d1								; is Sonic inside the right edge?
		blo.s	.withinright							; if yes, branch
		move.w	d2,d1

.withinright
		move.w	d1,(Camera_X_pos).w						; set horizontal screen position
		subi.w	#(224/2)-16,d0							; is Sonic within 96px of upper edge?
		bhs.s	.withintop							; if yes, branch
		moveq	#0,d0

.withintop
		cmp.w	(Camera_max_Y_pos).w,d0						; is Sonic above the bottom edge?
		blt.s	.withinbottom							; if yes, branch
		move.w	(Camera_max_Y_pos).w,d0

.withinbottom
		move.w	d0,(Camera_Y_pos).w						; set vertical screen position
		rts
