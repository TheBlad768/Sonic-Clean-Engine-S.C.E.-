; ---------------------------------------------------------------------------
; Subroutine to pause the game
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Pause_Game:
		nop
		tst.b	(Game_paused).w
		bne.s	+
		move.b	(Ctrl_1_pressed).w,d0
		andi.b	#button_start_mask,d0			; is Start pressed?
		beq.s	Pause_NoPause					; if not, branch
+		st	(Game_paused).w
		SMPS_PauseMusic

Pause_Loop:
		move.b	#VintID_Level,(V_int_routine).w
		bsr.w	Wait_VSync
	if GameDebug=1
		btst	#bitA,(Ctrl_1_pressed).w				; is button A pressed?
		beq.s	Pause_ChkFrameAdvance			; if not, branch
		move.b	#id_LevelSelect,(Game_mode).w	; set game mode
		bra.s	Pause_ResumeMusic
; ---------------------------------------------------------------------------

Pause_ChkFrameAdvance:
		btst	#bitB,(Ctrl_1).w						; is button B pressed?
		bne.s	Pause_FrameAdvance				; if yes, branch
		btst	#bitC,(Ctrl_1_pressed).w				; is button C pressed?
		bne.s	Pause_FrameAdvance				; if yes, branch
Pause_ChkStart:
	endif
		move.b	(Ctrl_1_pressed).w,d0
		andi.b	#button_start_mask,d0
		beq.s	Pause_Loop

Pause_ResumeMusic:
		SMPS_UnpauseMusic

Pause_Unpause:
		sf	(Game_paused).w

Pause_NoPause:
		rts
; ---------------------------------------------------------------------------
	if GameDebug=1
Pause_FrameAdvance:
		st	(Game_paused).w
		SMPS_UnpauseMusic
		rts
; End of function Pause_Game
	endif
