; ---------------------------------------------------------------
; Debug
; ---------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

VInt_DrawLevel_RaiseError:

		; check
		cmpa.w	#Plane_buffer_end,a0
		blo.w	.return

		; debug
		RaiseError "Plane buffer overflow", .console

.console
		Console.WriteLine "It seems like there is too much%<endl>data in the plane buffer!%<endl>"
		Console.WriteLine "%<pal1>Plane buffer current: %<pal2>%<.l a0>"
		Console.WriteLine "%<pal1>Plane buffer start:   %<pal2>%<.l #Plane_buffer>"
		Console.WriteLine "%<pal1>Plane buffer end:     %<pal2>%<.l #Plane_buffer_end>"

.return
		rts
