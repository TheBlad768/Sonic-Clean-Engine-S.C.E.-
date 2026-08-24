; ---------------------------------------------------------------------------
; Song fade (Object)
; ---------------------------------------------------------------------------

; dynamic object variables

; =============== S U B R O U T I N E =======================================

Obj_Song_Fade_Transition:
		music	cmd_FadeOut							; fade out music
		move.w	#(2*60)-30,wait_timer(a0)					; fade time
		move.l	#.wait,code_addr(a0)

.return
		rts
; ---------------------------------------------------------------------------

.wait
		subq.w	#1,wait_timer(a0)						; subtract 1 from fade delay
		bpl.s	.return								; if fade still remains, branch
		move.b	subtype.byte(a0),d0
		move.b	d0,(Current_music+1).w
		jsr	(Play_Music).w							; play music

		; delete
		jmp	(Delete_Current_Object).w

; ---------------------------------------------------------------------------
; Song fade to level music (Object)
; ---------------------------------------------------------------------------

; dynamic object variables

; =============== S U B R O U T I N E =======================================

Obj_Song_Fade_ToLevelMusic:
		music	cmd_FadeOut							; fade out music
		move.w	#2*60,wait_timer(a0)						; fade time
		move.l	#.wait,code_addr(a0)

.return
		rts
; ---------------------------------------------------------------------------

.wait
		subq.w	#1,wait_timer(a0)						; subtract 1 from fade delay
		bpl.s	.return								; if fade still remains, branch
		jsr	(Restore_LevelMusic).w						; play music

		; delete
		jmp	(Delete_Current_Object).w
