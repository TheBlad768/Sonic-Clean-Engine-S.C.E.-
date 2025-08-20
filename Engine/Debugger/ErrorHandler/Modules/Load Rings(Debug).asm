; ---------------------------------------------------------------
; Debug
; ---------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Load_Rings_RaiseError:

		; check
		cmpa.w	#Ring_status_table_end,a2
		blo.w	.return

		; debug
		RaiseError "Ring status table overflow", .console

.console
		Console.WriteLine "It looks like you added too many%<endl>rings!%<endl>"
		Console.WriteLine "%<pal1>Ring table current: %<.l a2>"
		Console.WriteLine "%<pal1>Ring table start:   %<pal2>%<.l #Ring_status_table>"
		Console.WriteLine "%<pal1>Ring table end:     %<pal2>%<.l #Ring_status_table_end>"

.return
		rts