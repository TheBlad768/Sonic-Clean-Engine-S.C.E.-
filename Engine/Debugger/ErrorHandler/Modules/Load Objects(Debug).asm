; ---------------------------------------------------------------
; Debug
; ---------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Load_Objects_RaiseError:

		; check
		cmpa.w	#Object_respawn_table_end,a3
		blo.w	.return

		; debug
		RaiseError "Object respawn table overflow", .console

.console
		Console.WriteLine "It looks like you added too many%<endl>objects!%<endl>"
		Console.WriteLine "%<pal1>Object table current: %<.l a2>"
		Console.WriteLine "%<pal1>Object table start:   %<pal2>%<.l #Object_respawn_table>"
		Console.WriteLine "%<pal1>Object table end:     %<pal2>%<.l #Object_respawn_table_end>"

.return
		rts