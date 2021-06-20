
; =============== S U B R O U T I N E =======================================

Child_GetPriority:
		movea.w	parent3(a0),a1
		bclr	#7,art_tile(a0)
		btst	#7,art_tile(a1)
		beq.s	+
		bset	#7,art_tile(a0)
+		move.w	priority(a1),priority(a0)
		rts
; End of function Child_GetPriority

; =============== S U B R O U T I N E =======================================

Child_GetPriorityOnce:
		movea.w	parent3(a0),a1
		btst	#7,art_tile(a1)
		beq.s	+
		bset	#7,art_tile(a0)
		move.l	(sp),address(a0)
+		rts
; End of function Child_GetPriorityOnce

; =============== S U B R O U T I N E =======================================

Child_GetVRAMPriorityOnce:
		movea.w	parent3(a0),a1
		move.w	art_tile(a1),d0
		bpl.s	+
		move.w	d0,art_tile(a0)
		move.w	priority(a1),priority(a0)
		move.l	(sp),address(a0)
+		rts
; End of function Child_GetVRAMPriorityOnce

; =============== S U B R O U T I N E =======================================

Child_SyncDraw:
		movea.w	parent3(a0),a1
		btst	#6,$38(a1)
		bne.s	++
		bclr	#6,$38(a0)
		bset	#7,art_tile(a0)
		btst	#7,art_tile(a1)
		bne.s	+
		bclr	#7,art_tile(a0)
+		rts
; ---------------------------------------------------------------------------
+		bset	#6,$38(a0)
		rts
; End of function Child_SyncDraw
