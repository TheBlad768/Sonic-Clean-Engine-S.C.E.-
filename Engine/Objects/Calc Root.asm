; ---------------------------------------------------------------------------
; Function to calculate a root
; (c) 2012, Vladikcomper
; ---------------------------------------------------------------------------
;
; INPUT:
; d0.w	= Number
;
; OUTPUT:
; d0.w	= Root of number
;
; USES:
; d0, d1
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

CalcRoot:
		moveq	#-1,d1		; initialize d1 to -1 (will become 1 on first loop — first odd number)

.find
		addq.w	#2,d1		; increment d1 by 2 (step for odd numbers)
		sub.w	d1,d0		; subtract d1 from d0 (input number)
		bhs.s	.find		; branch if d0 >= 0 (loop continues while result is non-negative)

		subq.w	#1,d1		; decrement d1 by 1 to adjust for overshoot
		lsr.w	d1		; divide d1 by 2 (right shift) to get the root
		exg	d1,d0		; exchange d1 and d0 so result is returned in d0
		rts