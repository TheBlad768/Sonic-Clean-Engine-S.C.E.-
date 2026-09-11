; ---------------------------------------------------------------------------
; Add points subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

HUD_AddToScore:
		move.b	#1,(Update_HUD_score).w						; set score counter to update

.main
		move.l	(Score).w,d1							; get current score
		add.l	d0,d1								; add d0*10 to the score
		move.l	#999999,d0							; 9999990 maximum points
		cmp.l	d1,d0								; is score below 999999?
		bhi.s	.set								; if yes, branch
		move.l	d0,d1								; reset score to 999999

.set
		move.l	d1,(Score).w							; save score

.return
		rts
