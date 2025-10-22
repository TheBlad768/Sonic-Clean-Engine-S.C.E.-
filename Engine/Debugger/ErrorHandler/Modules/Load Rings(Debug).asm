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
		Console.WriteLine "%<pal1>Ring table current: %<pal2>%<.l a2>"
		Console.WriteLine "%<pal1>Ring table start:   %<pal2>%<.l #Ring_status_table>"
		Console.WriteLine "%<pal1>Ring table end:     %<pal2>%<.l #Ring_status_table_end>"

.return
		rts

; =============== S U B R O U T I N E =======================================

Test_Ring_Collisions_RaiseError:

		; check
		move.w	(a1),d0
		cmp.w	(Screen_X_wrap_value).w,d0					; check ring's x_pos
		bhs.s	.x
		move.w	2(a1),d0
		cmp.w	(Screen_Y_wrap_value).w,d0					; check ring's y_pos
		blo.w	.return

		; debug

.y
		RaiseError "Ring y position is corrupted", .console

.x
		RaiseError "Ring x position is corrupted", .console

.console
		Console.WriteLine "It seems you have a corrupted ring!%<endl>"
		Console.WriteLine "%<pal1>Ring ROM current:    %<pal2>%<.l a1>"
		Console.WriteLine "%<pal1>Ring x position:     %<pal2>%<.w (a1)>"
		Console.WriteLine "%<pal1>Ring y position:     %<pal2>%<.w 2(a1)>%<endl>"
		Console.WriteLine "%<pal1>Screen x wrap value: %<pal2>%<.w Screen_X_wrap_value>"
		Console.WriteLine "%<pal1>Screen y wrap value: %<pal2>%<.w Screen_Y_wrap_value>"

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
		Console.WriteLine "%<pal1>Ring list current: %<pal2>%<.l a3>"
		Console.WriteLine "%<pal1>Ring list start:   %<pal2>%<.l #Ring_consumption_list>"
		Console.WriteLine "%<pal1>Ring list end:     %<pal2>%<.l #Ring_consumption_list_end>"

.return
		rts
