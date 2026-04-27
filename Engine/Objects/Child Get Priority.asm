; ---------------------------------------------------------------------------
; Get priority subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Child_GetPriority:
		movea.w	parent3(a0),a1							; a1=parent object

.skipp
		bclr	#high_priority_bit,art_tile(a0)					; low priority
		btst	#high_priority_bit,art_tile(a1)					; is parent object has high priority?
		beq.s	.nothighpriority						; if not, branch
		bset	#high_priority_bit,art_tile(a0)					; high priority

.nothighpriority
		move.w	priority(a1),priority(a0)					; copy parent object priority
		rts

; ---------------------------------------------------------------------------
; Get priority once subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Child_GetPriorityOnce:
		movea.w	parent3(a0),a1							; a1=parent object

.skipp
		btst	#high_priority_bit,art_tile(a1)					; is parent object has high priority?
		beq.s	.nothighpriority						; if not, branch
		bset	#high_priority_bit,art_tile(a0)					; high priority
		move.l	(sp),code_addr(a0)						; set address after bsr/jsr

.nothighpriority
		rts

; ---------------------------------------------------------------------------
; Get priority 2 subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Child_GetPriority2:
		movea.w	parent3(a0),a1							; a1=parent object

.skipp
		btst	#high_priority_bit,art_tile(a1)					; is parent object has high priority?
		beq.s	.nothighpriority						; if not, branch
		bset	#high_priority_bit,art_tile(a0)					; high priority

.nothighpriority
		rts

; ---------------------------------------------------------------------------
; Get VRAM and priority once subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Child_GetVRAMPriorityOnce:
		movea.w	parent3(a0),a1							; a1=parent object

.skipp
		move.w	art_tile(a1),d0							; is parent object has high priority?
		bpl.s	.nothighpriority						; if not, branch
		move.w	d0,art_tile(a0)							; copy parent VRAM
		move.w	priority(a1),priority(a0)					; copy parent object priority
		move.l	(sp),code_addr(a0)						; set address after bsr/jsr

.nothighpriority
		rts

; ---------------------------------------------------------------------------
; Sync draw
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Child_SyncDraw:
		movea.w	parent3(a0),a1							; a1=parent object

.skipp
		btst	#6,state_flags(a1)
		bne.s	.setflag
		bclr	#6,state_flags(a0)
		bset	#high_priority_bit,art_tile(a0)					; high priority
		btst	#high_priority_bit,art_tile(a1)					; is parent object has high priority?
		bne.s	.highpriority							; if yes, branch
		bclr	#high_priority_bit,art_tile(a0)					; low priority

.highpriority
		rts
; ---------------------------------------------------------------------------

.setflag
		bset	#6,state_flags(a0)
		rts

; ---------------------------------------------------------------------------
; Get collision and priority once subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Child_GetCollisionPriorityOnce:
		movea.w	parent3(a0),a1							; a1=parent object

.skipp
		btst	#high_priority_bit,art_tile(a1)					; is parent object has high priority?
		beq.s	.nothighpriority						; if not, branch
		bset	#high_priority_bit,art_tile(a0)					; high priority
		move.l	(sp),code_addr(a0)						; set address after bsr/jsr
		move.b	d0,collision_type(a0)						; set collision type
		swap	d0
		move.w	d0,collision_height(a0)						; set collision height and width

.nothighpriority
		rts
