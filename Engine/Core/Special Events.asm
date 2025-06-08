; ---------------------------------------------------------------------------
; Special events
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Special_Events:
		move.l	(Special_events_addr).w,d0
		beq.s	.return						; if zero, branch
		cmpi.b	#PlayerID_Death,(Player_1+routine).w		; is player dead?
		bhs.s	.return						; if yes, branch
		movea.l	d0,a0
		jmp	(a0)
; ---------------------------------------------------------------------------

.return
		rts