; ---------------------------------------------------------------------------
; Dynamic level events
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Do_ResizeEvents:
		movea.l	(Level_data_addr_RAM.Resize).w,a0
		jsr	(a0)
		moveq	#2,d1
		move.w	(Camera_target_max_Y_pos).w,d0
		sub.w	(Camera_max_Y_pos).w,d0
		beq.s	++
		bcc.s	+++
		neg.w	d1
		move.w	(Camera_Y_pos).w,d0
		cmp.w	(Camera_target_max_Y_pos).w,d0
		bls.s		+
		move.w	d0,(Camera_max_Y_pos).w
		andi.w	#-2,(Camera_max_Y_pos).w
+		add.w	d1,(Camera_max_Y_pos).w
		move.b	#1,(Camera_max_Y_pos_changing).w
+		rts
; ---------------------------------------------------------------------------
+		move.w	(Camera_Y_pos).w,d0
		addq.w	#8,d0
		cmp.w	(Camera_max_Y_pos).w,d0
		blo.s		+
		btst	#1,(Player_1+status).w
		beq.s	+
		add.w	d1,d1
		add.w	d1,d1
+		add.w	d1,(Camera_max_Y_pos).w
		move.b	#1,(Camera_max_Y_pos_changing).w

No_Resize:
		rts
; End of function Do_ResizeEvents

; =============== S U B R O U T I N E =======================================
