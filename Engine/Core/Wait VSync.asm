; ---------------------------------------------------------------------------
; Called at the end of each frame to perform vertical synchronization
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Wait_VSync:

	ifdef __DEBUG__	; lagometer is only available in DEBUG builds
		move.w	#$9100,(VDP_control_port).l				; window H position at default
	endif

		enableInts

.wait
		tst.b	(V_int_routine).w
		bne.s	.wait							; wait until V-int's run

	ifdef __DEBUG__	; lagometer is only available in DEBUG builds
		move.w	#$9193,(VDP_control_port).l				; window H right side, base point $80
	endif

		rts