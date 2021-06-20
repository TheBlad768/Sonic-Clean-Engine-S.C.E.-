; ---------------------------------------------------------------------------
; Subroutine calculate an angle
; input:
; d1 = x-axis distance
; d2 = y-axis distance
; output:
; d0 = angle
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

CalcAngle:
GetArcTan:
		movem.l	d3-d4,-(sp)
		moveq	#0,d3
		moveq	#0,d4
		move.w	d1,d3
		move.w	d2,d4
		or.w	d3,d4
		beq.s	GetArcTan_Zero	; special case when both x and y are zero
		move.w	d2,d4
		tst.w	d3
		bpl.s	+
		neg.w	d3
+		tst.w	d4
		bpl.s	+
		neg.w	d4
+		cmp.w	d3,d4
		bhs.s	+	; if |y| >= |x|
		lsl.l	#8,d4
		divu.w	d3,d4
		moveq	#0,d0
		move.b	ArcTanTable(pc,d4.w),d0
		bra.s	++
+		lsl.l	#8,d3
		divu.w	d4,d3
		moveq	#$40,d0
		sub.b	ArcTanTable(pc,d3.w),d0	; arctan(y/x) = 90 - arctan(x/y)
+		tst.w	d1
		bpl.s	+
		neg.w	d0
		addi.w	#$80,d0		; place angle in appropriate quadrant
+		tst.w	d2
		bpl.s	+
		neg.w	d0
		addi.w	#$100,d0	; place angle in appropriate quadrant
+		movem.l	(sp)+,d3-d4
		rts
; ---------------------------------------------------------------------------

GetArcTan_Zero:
		moveq	#$40,d0		; angle = 90 degrees
		movem.l	(sp)+,d3-d4
		rts
; End of function GetArcTan
; ---------------------------------------------------------------------------

ArcTanTable:		binclude	"Misc Data/Arctan.bin"
	even