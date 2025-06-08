; ---------------------------------------------------------------------------
; Calculates the sine and cosine of the angle in d0 (360 degrees = 256)
; Returns the sine in d0 and the cosine in d1 (both multiplied by $100)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

GetSineCosine:
		andi.w	#$FF,d0
		add.w	d0,d0
		addi.w	#$40*2,d0			; $40 = 90 degrees, sin(x+90) = cos(x)
		move.w	SineTable(pc,d0.w),d1		; cos
		subi.w	#$40*2,d0
		move.w	SineTable(pc,d0.w),d0		; sin
		rts
; ---------------------------------------------------------------------------

SineTable:	binclude "Data/Misc/Sine.bin"
	even