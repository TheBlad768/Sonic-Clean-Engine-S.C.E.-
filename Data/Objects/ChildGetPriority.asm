
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