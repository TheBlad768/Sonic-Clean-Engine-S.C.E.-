; ---------------------------------------------------------------------------
; Dynamic level events
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

DEZ1_Resize:

		; check end level
		move.w	(Camera_max_X_pos).w,d0
		subi.w	#256,d0
		cmp.w	(Camera_X_pos).w,d0
		bhi.s	.return
		move.w	d0,(Camera_min_X_pos).w
		move.w	#$380,(Camera_target_max_Y_pos).w
		move.l	#.checkxpos,(Level_data_addr_RAM.Resize).w

.checkxpos

		; check xpos
		move.w	(Camera_max_X_pos).w,d0
		cmp.w	(Camera_X_pos).w,d0
		bhi.s	.return
		move.w	d0,(Camera_min_X_pos).w
		move.l	#.checksign,(Level_data_addr_RAM.Resize).w

		; set flags
		st	(Last_act_end_flag).w						; disable background event and Title Card

		; clear flags
		moveq	#0,d0
		move.b	d0,(Update_HUD_timer).w						; stop timer
		move.b	d0,(End_of_level_flag).w
		move.b	d0,(Boss_flag).w

		; create signpost
		jsr	(Create_New_Sprite).w
		bne.s	.return
		move.l	#Obj_EndSignControl,address(a1)
		move.w	(Camera_X_pos).w,d2
		addi.w	#320/2,d2
		move.w	d2,x_pos(a1)

.return
		rts
; ---------------------------------------------------------------------------

.checksign
		tst.b	(End_of_level_flag).w
		beq.s	.return

		; next act
		move.b	#1,(Current_act).w						; set act 2
		move.w	(Current_zone_and_act).w,(Apparent_zone_and_act).w
		st	(Restart_level_flag).w
		clr.b	(Last_star_post_hit).w
		rts
