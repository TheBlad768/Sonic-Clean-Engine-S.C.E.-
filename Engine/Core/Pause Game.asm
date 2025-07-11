; ---------------------------------------------------------------------------
; Subroutine to pause the game
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Pause_Game:
		tst.b	(Time_over_flag).w						; is time over?
		bne.w	.unpause							; if yes, branch
		tst.b	(Game_paused).w							; is game already paused?
		bne.s	.paused								; if yes, branch
		tst.b	(Ctrl_1_pressed).w						; is Start button pressed?
		bpl.s	.nopause							; if not, branch

.paused
		st	(Game_paused).w							; pause the game
		SMPS_PauseMusic								; pause the music

.loop
		move.b	#VintID_Level,(V_int_routine).w
		bsr.s	Wait_VSync

	if GameDebug
		btst	#button_A,(Ctrl_1_pressed).w					; is button A pressed?
		beq.s	.chkframeadvance						; if not, branch
		move.b	#GameModeID_LevelSelectScreen,(Game_mode).w			; set screen mode to Level Select (SCE)
		addq.w	#4,sp								; exit from current screen
		bra.s	.resumemusic
; ---------------------------------------------------------------------------

.chkframeadvance
		btst	#button_B,(Ctrl_1_held).w					; is button B held?
		bne.s	.frameadvance							; if yes, branch
		btst	#button_C,(Ctrl_1_pressed).w					; is button C pressed?
		bne.s	.frameadvance							; if yes, branch

.chkstart
	endif

		tst.b	(Ctrl_1_pressed).w						; is Start pressed?
		bpl.s	.loop								; if not, branch

.resumemusic
		SMPS_UnpauseMusic							; unpause the music

.unpause
		clr.b	(Game_paused).w							; unpause the game

.nopause
		rts
; ---------------------------------------------------------------------------

	if GameDebug
.frameadvance
		st	(Game_paused).w
		SMPS_UnpauseMusic							; unpause the music
		rts											; advance by a single frame
	endif
