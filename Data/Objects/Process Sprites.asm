; ---------------------------------------------------------------------------
; Object code execution subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Process_Sprites:
		lea	(Object_RAM).w,a0
		cmpi.b	#id_SonicDeath,(Player_1+routine).w
		bhs.s	Process_Sprites_FreezeObject
		moveq	#((Object_RAM_End-Object_RAM)/object_size)-1,d7

Process_Sprites_Loop:
		move.l	(a0),d0
		beq.s	+
		movea.l	d0,a1
		jsr	(a1)
+		lea	next_object(a0),a0
		dbf	d7,Process_Sprites_Loop
		rts
; End of function Process_Sprites

; =============== S U B R O U T I N E =======================================

Process_Sprites_FreezeObject:
		moveq	#3,d7
		bsr.s	Process_Sprites_Loop
		moveq	#((Dynamic_object_RAM_End-Dynamic_object_RAM)/object_size)-1,d7
		bsr.s	Process_Sprites_FreezeObject_Loop
		moveq	#$F,d7
		bra.s	Process_Sprites_Loop
; ---------------------------------------------------------------------------

Process_Sprites_FreezeObject_Loop:
		move.l	(a0),d0
		beq.s	+
		tst.b	render_flags(a0)
		bpl.s	+
		jsr	Draw_Sprite(pc)
+		lea	next_object(a0),a0
		dbf	d7,Process_Sprites_FreezeObject_Loop
		rts
; End of function Process_Sprites_FreezeObject
