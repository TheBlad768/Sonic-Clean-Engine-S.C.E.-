; ---------------------------------------------------------------
; Debug
; ---------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Queue_KosPlus_RaiseError:

		; check
		cmpa.w	#KosPlus_decomp_queue_end,a3
		blo.s	.return

		; debug
		RaiseError "Kosinki Plus buffer overflow", .return

.return
		rts

; =============== S U B R O U T I N E =======================================

Queue_KosPlus_Module_RaiseError:

		; check
		cmpa.w	#KosPlus_module_queue_end,a2
		blo.s	.return

		; debug
		RaiseError "Kosinki Plus Module buffer overflow", .return

.return
		rts