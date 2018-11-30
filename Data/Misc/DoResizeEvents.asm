; ---------------------------------------------------------------------------
; Dynamic level events
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Do_ResizeEvents:
		moveq	#0,d0
		move.w	(Current_zone_and_act).w,d0
		lsl.b	#6,d0
		lsr.w	#5,d0
		move.w	LevelResizeArray(pc,d0.w),d0
		jsr	LevelResizeArray(pc,d0.w)
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
		btst	#1,(v_player+obStatus).w
		beq.s	+
		add.w	d1,d1
		add.w	d1,d1
+		add.w	d1,(Camera_max_Y_pos).w
		move.b	#1,(Camera_max_Y_pos_changing).w

No_Resize:
		rts
; End of function Do_ResizeEvents
; ---------------------------------------------------------------------------

LevelResizeArray: offsetTable
		offsetTableEntry.w No_Resize	; DEZ 1
		offsetTableEntry.w No_Resize	; DEZ 2
		offsetTableEntry.w No_Resize	; DEZ 3
		offsetTableEntry.w No_Resize	; DEZ 4

		zonewarning LevelResizeArray,(2*4)

; =============== S U B R O U T I N E =======================================
