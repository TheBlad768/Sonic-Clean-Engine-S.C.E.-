; ---------------------------------------------------------------
; Debug
; ---------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Create_New_Object_RaiseError:

		; check
		beq.s	.return

		; debug
		RaiseError "Object buffer overflow", .return

.return
		rts
