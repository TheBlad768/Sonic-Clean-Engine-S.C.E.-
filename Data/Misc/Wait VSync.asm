; ---------------------------------------------------------------------------
; Called at the end of each frame to perform vertical synchronization
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Wait_VSync:
DelayProgram:
	if Lagometer
		move.w	#$9100,(VDP_control_port).l	; window H position at default
	endif
		enableInts

.wait
		tst.b	(V_int_routine).w
		bne.s	.wait	; wait until V-int's run
		rts