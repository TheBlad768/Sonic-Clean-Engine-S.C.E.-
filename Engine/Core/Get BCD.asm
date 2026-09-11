; ---------------------------------------------------------------------------
; Get BCD
;
; Inputs:
; d1 = long value
;
; Outputs:
; d1 = long value
; Optimized by MarkeyJester
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Get_BCD:
		movem.l	d0/d3/a1,-(sp)							; save the registers to the stack

		; init
		lea	.table(pc),a1
		move.l	(a1)+,d0							; from 1000000 to 10
		moveq	#0,d3

.loop
		cmp.l	d0,d1
		blo.s	.next

.finddigit
		addq.b	#1,d3
		sub.l	d0,d1
		bhs.s	.finddigit
		add.l	d0,d1
		subq.b	#1,d3

.next
		rol.l	#4,d3
		move.l	(a1)+,d0
		bne.s	.loop
		or.l	d3,d1

		; exit
		movem.l	(sp)+,d0/d3/a1							; return saved registers from the stack
		rts
; ---------------------------------------------------------------------------

.table	dc.l 1000000, 100000, 10000, 1000, 100, 10, 0
