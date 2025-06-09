; ---------------------------------------------------------------------------
; 2-argument arctangent (angle between (0,0) and (x,y))
; Based on https://codebase64.org/doku.php?id=base:8bit_atan2_8-bit_angle
; New version by Devon Artmeier
; ---------------------------------------------------------------------------
; PARAMETERS:
; d1.w - X value
; d2.w - Y value
; RETURNS:
; d0.b - 2-argument arctangent value (angle between (0,0) and (x,y))
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

GetArcTan:
		moveq	#0,d0							; default to bottom right quadrant
		tst.w	d1							; is the x value negative?
		beq.s	.xzero							; if the x value is zero, branch
		bpl.s	.checky							; if not, branch
		neg.w	d1							; if so, get the absolute value
		moveq	#4,d0							; shift to left quadrant

.checky
		tst.w	d2							; is the y value negative?
		beq.s	.yzero							; if the y value is zero, branch
		bpl.s	.checkoctet						; if not, branch
		neg.w	d2							; if so, get the absolute value
		addq.b	#2,d0							; shift to top quadrant

.checkoctet
		cmp.w	d2,d1							; are we horizontally closer to the center?
		bhs.s	.divide							; if not, branch
		exg	d1,d2							; if so, divide Y from X instead
		addq.b	#1,d0							; use octant that's horizontally closer to the center

.divide
		move.w	d1,-(sp)						; shrink x and y down into bytes
		moveq	#0,d3
		move.b	(sp)+,d3
		move.b	WordShiftTable(pc,d3.w),d3
		lsr.w	d3,d1
		lsr.w	d3,d2
		lea	LogarithmTable(pc),a3					; perform logarithmic division
		move.b	(a3,d2.w),d2
		sub.b	(a3,d1.w),d2
		bne.s	.getatan2val
		move.w	#$FF,d2							; edge case where x and y values are too close for the division to handle

.getatan2val
		lea	ArcTanTable(pc),a3					; get atan2 value
		move.b	(a3,d2.w),d2
		move.b	.octantadjust(pc,d0.w),d0
		eor.b	d2,d0
		rts
; ---------------------------------------------------------------------------

.yzero
		tst.b	d0							; was the x value negated?
		beq.s	.return							; if not, branch (d0 is already 0, so no need to set it again on branch)
		moveq	#-$80,d0						; 180 degrees

.return
		rts
; ---------------------------------------------------------------------------

.xzero
		tst.w	d2							; is the y value negative?
		bmi.s	.xzeroyneg						; if so, branch
		moveq	#$40,d0							; 90 degrees
		rts
; ---------------------------------------------------------------------------

.xzeroyneg
		moveq	#-$40,d0						; 270 degrees
		rts
; ---------------------------------------------------------------------------

.octantadjust
		dc.b %00000000							; +x, +y, |x|>|y|
		dc.b %00111111							; +x, +y, |x|<|y|
		dc.b %11111111							; +x, -y, |x|>|y|
		dc.b %11000000							; +x, -y, |x|<|y|
		dc.b %01111111							; -x, +y, |x|>|y|
		dc.b %01000000							; -x, +y, |x|<|y|
		dc.b %10000000							; -x, -y, |x|>|y|
		dc.b %10111111							; -x, -y, |x|<|y|
; ---------------------------------------------------------------------------

WordShiftTable:		binclude "Data/Misc/Angle/WordShift.bin"
	even
LogarithmTable:		binclude "Data/Misc/Angle/Logarithmic.bin"		; log base 2
	even
ArcTanTable:		binclude "Data/Misc/Angle/Arctan.bin"			; 2-argument
	even
