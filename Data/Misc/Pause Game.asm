; ---------------------------------------------------------------------------
; Subroutine to pause the game
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Pause_Game:
		tst.b	(Game_paused).w
		bne.s	.paused
		tst.b	(Ctrl_1_pressed).w						; is Start pressed?
		bpl.s	Pause_NoPause						; if not, branch

.paused
		st	(Game_paused).w
		SMPS_PauseMusic

Pause_Loop:
		move.b	#VintID_Level,(V_int_routine).w
		bsr.w	Wait_VSync
	if GameDebug
		btst	#button_A,(Ctrl_1_pressed).w				; is button A pressed?
		beq.s	Pause_ChkFrameAdvance				; if not, branch
		move.b	#id_LevelSelectScreen,(Game_mode).w	; set game mode
		bra.s	Pause_ResumeMusic
; ---------------------------------------------------------------------------

Pause_ChkFrameAdvance:
		btst	#button_B,(Ctrl_1_held).w					; is button B held?
		bne.s	Pause_FrameAdvance					; if yes, branch
		btst	#button_C,(Ctrl_1_pressed).w				; is button C pressed?
		bne.s	Pause_FrameAdvance					; if yes, branch
Pause_ChkStart:
	endif
		tst.b	(Ctrl_1_pressed).w						; is Start pressed?
		bpl.s	Pause_Loop							; if not, branch

Pause_ResumeMusic:
		SMPS_UnpauseMusic

Pause_Unpause:
		clr.b	(Game_paused).w

Pause_NoPause:
		rts
; ---------------------------------------------------------------------------
	if GameDebug
Pause_FrameAdvance:
		st	(Game_paused).w
		SMPS_UnpauseMusic
		rts
	endif
