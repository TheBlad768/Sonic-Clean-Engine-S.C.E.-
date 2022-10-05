
; =============== S U B R O U T I N E =======================================

Child_GetPriority:
		movea.w	parent3(a0),a1
		bclr	#7,art_tile(a0)
		btst	#7,art_tile(a1)
		beq.s	.nothighpriority
		bset	#7,art_tile(a0)

.nothighpriority
		move.w	priority(a1),priority(a0)
		rts

; =============== S U B R O U T I N E =======================================

Child_GetPriorityOnce:
		movea.w	parent3(a0),a1
		btst	#7,art_tile(a1)
		beq.s	.nothighpriority
		bset	#7,art_tile(a0)
		move.l	(sp),address(a0)

.nothighpriority
		rts

; =============== S U B R O U T I N E =======================================

Child_GetVRAMPriorityOnce:
		movea.w	parent3(a0),a1
		move.w	art_tile(a1),d0
		bpl.s	.nothighpriority
		move.w	d0,art_tile(a0)
		move.w	priority(a1),priority(a0)
		move.l	(sp),address(a0)

.nothighpriority
		rts

; =============== S U B R O U T I N E =======================================

Child_SyncDraw:
		movea.w	parent3(a0),a1
		btst	#6,$38(a1)
		bne.s	.setflag
		bclr	#6,$38(a0)
		bset	#7,art_tile(a0)
		btst	#7,art_tile(a1)
		bne.s	.highpriority
		bclr	#7,art_tile(a0)

.highpriority
		rts
; ---------------------------------------------------------------------------

.setflag
		bset	#6,$38(a0)
		rts
