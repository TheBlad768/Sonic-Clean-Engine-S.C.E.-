; ---------------------------------------------------------------------------
; Generates a pseudo-random number in d0
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Random_Number:
		move.l	(RNG_seed).w,d1
		tst.w	d1
		bne.s	.notreset
		move.l	#$2A6D365B,d1	; reset seed if needed

.notreset

		; set the high word of d0 to be the high word of the RNG
		; and multiply the RNG by 41
		move.l	d1,d0
		asl.l	#2,d1
		add.l	d0,d1
		asl.l	#3,d1
		add.l	d0,d1

		; add the low word of the RNG to the high word of the RNG
		; and set the low word of d0 to be the result
		move.w	d1,d0
		swap	d1
		add.w	d1,d0
		move.w	d0,d1
		swap	d1
		move.l	d1,(RNG_seed).w
		rts