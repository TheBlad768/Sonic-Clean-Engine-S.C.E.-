; -------------------------------------------------------------------------
; 2-argument arctangent (angle between (0,0) and (x,y))
; Based on http://codebase64.org/doku.php?id=base:8bit_atan2_8-bit_angle
; New version by Ralakimus
; -------------------------------------------------------------------------
; PARAMETERS:
; d1.w - X value
; d2.w - Y value
; RETURNS:
; d0.b - 2-argument arctangent value (angle between (0,0) and (x,y))
; -------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

CalcAngle:
GetArcTan:
		moveq	#0,d0					; Default to bottom right quadrant
		tst.w	d1						; Is the X value negative?
		beq.s	CalcAngle_XZero			; If the X value is zero, branch
		bpl.s	CalcAngle_CheckY			; If not, branch
		not.w	d1						; If so, get the absolute value
		moveq	#4,d0					; Shift to left quadrant

CalcAngle_CheckY:
		tst.w	d2						; Is the Y value negative?
		beq.s	CalcAngle_YZero			; If the Y value is zero, branch
		bpl.s	CalcAngle_CheckOctet		; If not, branch
		not.w	d2						; If so, get the absolute value
		addq.b	#2,d0					; Shift to top quadrant

CalcAngle_CheckOctet:
		cmp.w	d2,d1					; Are we horizontally closer to the center?
		bcc.s	CalcAngle_Divide			; If not, branch
		exg.l	d1,d2						; If so, divide Y from X instead
		addq.b	#1,d0					; Use octant that's horizontally closer to the center

CalcAngle_Divide:
		move.w	d1,-(sp)					; Shrink X and Y down into bytes
		moveq	#0,d3
		move.b	(sp)+,d3
		move.b	WordShiftTable(pc,d3.w),d3
		lsr.w	d3,d1
		lsr.w	d3,d2

		lea	LogarithmTable(pc),a2				; Perform logarithmic division
		move.b	(a2,d2.w),d2
		sub.b	(a2,d1.w),d2
		bne.s	CalcAngle_GetAtan2Val
		move.w	#$FF,d2					; Edge case where X and Y values are too close for the division to handle

CalcAngle_GetAtan2Val:
		lea	ArcTanTable(pc),a2				; Get atan2 value
		move.b	(a2,d2.w),d2
		move.b	OctantAdjust(pc,d0.w),d0
		eor.b	d2,d0
		rts
; -------------------------------------------------------------------------

CalcAngle_YZero:
		tst.b	d0							; Was the X value negated?
		beq.s	CalcAngle_End			; If not, branch (d0 is already 0, so no need to set it again on branch)
		moveq	#-$80,d0				; 180 degrees

CalcAngle_End:
		rts
; -------------------------------------------------------------------------

CalcAngle_XZero:
		tst.w	d2						; Is the Y value negative?
		bmi.s	CalcAngle_XZeroYNeg		; If so, branch
		moveq	#$40,d0					; 90 degrees
		rts
; -------------------------------------------------------------------------

CalcAngle_XZeroYNeg:
		moveq	#-$40,d0				; 270 degrees
		rts
; -------------------------------------------------------------------------

OctantAdjust:
		dc.b %00000000					; +X, +Y, |X|>|Y|
		dc.b %00111111					; +X, +Y, |X|<|Y|
		dc.b %11111111					; +X, -Y, |X|>|Y|
		dc.b %11000000					; +X, -Y, |X|<|Y|
		dc.b %01111111					; -X, +Y, |X|>|Y|
		dc.b %01000000					; -X, +Y, |X|<|Y|
		dc.b %10000000					; -X, -Y, |X|>|Y|
		dc.b %10111111					; -X, -Y, |X|<|Y|
; -------------------------------------------------------------------------

WordShiftTable:	binclude "Misc Data/Angle/WordShift.bin"
	even
LogarithmTable:	binclude "Misc Data/Angle/Logarithmic.bin"	; log base 2
	even
ArcTanTable:		binclude "Misc Data/Angle/Arctan.bin"	; 2-argument
	even
