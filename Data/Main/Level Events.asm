; ---------------------------------------------------------------------------
; Dynamic level events
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Do_ResizeEvents:

		; check
		move.l	(Level_data_addr_RAM.Resize).w,d0
		beq.s	.rskip
		movea.l	d0,a0
		jsr	(a0)

.rskip
		moveq	#2,d1
		move.w	(Camera_target_max_Y_pos).w,d0
		sub.w	(Camera_max_Y_pos).w,d0
		beq.s	++
		bhs.s	+++
		neg.w	d1
		move.w	(Camera_Y_pos).w,d0
		cmp.w	(Camera_target_max_Y_pos).w,d0
		bls.s		+
		move.w	d0,(Camera_max_Y_pos).w
		andi.w	#$FFFE,(Camera_max_Y_pos).w
+		add.w	d1,(Camera_max_Y_pos).w
		st	(Camera_max_Y_pos_changing).w
+		rts
; ---------------------------------------------------------------------------
+		move.w	(Camera_Y_pos).w,d0
		addq.w	#8,d0
		cmp.w	(Camera_max_Y_pos).w,d0
		blo.s		+
		btst	#Status_InAir,(Player_1+status).w						; is the player in the air?
		beq.s	+												; if not, branch
		add.w	d1,d1
		add.w	d1,d1
+		add.w	d1,(Camera_max_Y_pos).w
		st	(Camera_max_Y_pos_changing).w
		rts
