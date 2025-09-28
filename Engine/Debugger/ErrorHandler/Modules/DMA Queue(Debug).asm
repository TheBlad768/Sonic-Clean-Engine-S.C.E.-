; ---------------------------------------------------------------
; Debug
; ---------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Add_To_DMA_Queue_RaiseError:

		; check
		cmpa.w	#DMA_queue_slot,a1
		bne.s	.return

		; debug
		RaiseError "DMA buffer overflow", .return

.return
		rts