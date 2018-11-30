; ---------------------------------------------------------------------------
; Called at the end of each frame to perform vertical synchronization
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Wait_VSync:
DelayProgram:
		enableInts

-		tst.b	(V_int_routine).w
		bne.s	-	; wait until V-int's run
		rts
; End of function Wait_VSync