; ---------------------------------------------------------------------------
; Get priority subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Child_GetPriority:
		movea.w	parent3(a0),a1

.skipp
		bclr	#high_priority_bit,art_tile(a0)
		btst	#high_priority_bit,art_tile(a1)
		beq.s	.nothighpriority
		bset	#high_priority_bit,art_tile(a0)

.nothighpriority
		move.w	priority(a1),priority(a0)
		rts

; =============== S U B R O U T I N E =======================================

Child_GetPriorityOnce:
		movea.w	parent3(a0),a1

.skipp
		btst	#high_priority_bit,art_tile(a1)
		beq.s	.nothighpriority
		bset	#high_priority_bit,art_tile(a0)
		move.l	(sp),address(a0)

.nothighpriority
		rts

; =============== S U B R O U T I N E =======================================

Child_GetPriority2:
		movea.w	parent3(a0),a1

.skipp
		btst	#high_priority_bit,art_tile(a1)
		beq.s	.nothighpriority
		bset	#high_priority_bit,art_tile(a0)

.nothighpriority
		rts

; =============== S U B R O U T I N E =======================================

Child_GetVRAMPriorityOnce:
		movea.w	parent3(a0),a1

.skipp
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

.skipp
		btst	#6,objoff_38(a1)
		bne.s	.setflag
		bclr	#6,objoff_38(a0)
		bset	#high_priority_bit,art_tile(a0)
		btst	#high_priority_bit,art_tile(a1)
		bne.s	.highpriority
		bclr	#high_priority_bit,art_tile(a0)

.highpriority
		rts
; ---------------------------------------------------------------------------

.setflag
		bset	#6,objoff_38(a0)
		rts

; =============== S U B R O U T I N E =======================================

Child_GetCollisionPriorityOnce:
		movea.w	parent3(a0),a1

.skipp
		btst	#high_priority_bit,art_tile(a1)
		beq.s	.nothighpriority
		bset	#high_priority_bit,art_tile(a0)
		move.l	(sp),address(a0)
		move.b	d0,collision_flags(a0)

.nothighpriority
		rts
