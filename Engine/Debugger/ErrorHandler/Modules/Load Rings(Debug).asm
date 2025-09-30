; ---------------------------------------------------------------
; Debug
; ---------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Load_Rings_RaiseError:

		; check
		cmpa.w	#Ring_status_table,a2
		blo.s	.error
		cmpa.w	#Ring_status_table_end,a2
		blo.w	.return

.error

		; debug
		RaiseError "Ring status table overflow", .console

.console
		Console.WriteLine "It looks like you added too many%<endl>rings!%<endl>"
		Console.WriteLine "%<pal1>Ring table current: %<.l a2>"
		Console.WriteLine "%<pal1>Ring table start:   %<pal2>%<.l #Ring_status_table>"
		Console.WriteLine "%<pal1>Ring table end:     %<pal2>%<.l #Ring_status_table_end>"

.return
		rts

; =============== S U B R O U T I N E =======================================

Test_Ring_Collisions_Consume_RaiseError:

		; check
		cmpa.w	#Ring_consumption_list_end,a3
		blo.w	.return

		; debug
		RaiseError "Ring consumption list overflow", .console

.console
		Console.WriteLine "It seems you have collected too many%<endl>rings at once!%<endl>"
		Console.WriteLine "%<pal1>Ring list current: %<.l a3>"
		Console.WriteLine "%<pal1>Ring list start:   %<pal2>%<.l #Ring_consumption_list>"
		Console.WriteLine "%<pal1>Ring list end:     %<pal2>%<.l #Ring_consumption_list_end>"

.return
		rts
