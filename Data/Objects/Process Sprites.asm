; ---------------------------------------------------------------------------
; Object code execution subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Process_Sprites:
		lea	(Object_RAM).w,a0
		cmpi.b	#id_SonicDeath,routine(a0)	; has Sonic just died?
		bhs.s	Process_Sprites_FreezeObject	; if yes, branch

Process_Sprites_Skip:
		moveq	#((Object_RAM_end-Object_RAM)/object_size)-1,d7

Process_Sprites_Loop:
		move.l	address(a0),d0
		beq.s	.nextslot
		movea.l	d0,a1
		jsr	(a1)

.nextslot
		lea	next_object(a0),a0
		dbf	d7,Process_Sprites_Loop
		rts

; =============== S U B R O U T I N E =======================================

Process_Sprites_FreezeObject:
		cmpi.b	#id_SonicDrown,(Player_1+routine).w
		beq.s	Process_Sprites_Skip
		moveq	#(((Dynamic_object_RAM+object_size)-Object_RAM)/object_size)-1,d7
		bsr.s	Process_Sprites_Loop
		moveq	#(((Dynamic_object_RAM_end+object_size)-(Dynamic_object_RAM+object_size))/object_size)-1,d7
		bsr.s	Process_Sprites_FreezeObject_Loop
		moveq	#((Object_RAM_end-(Dynamic_object_RAM_end+object_size))/object_size)-1,d7
		bra.s	Process_Sprites_Loop
; ---------------------------------------------------------------------------

Process_Sprites_FreezeObject_Loop:
		tst.l	address(a0)
		beq.s	.nextslot
		tst.b	render_flags(a0)
		bpl.s	.nextslot
		bsr.w	Draw_Sprite

.nextslot
		lea	next_object(a0),a0
		dbf	d7,Process_Sprites_FreezeObject_Loop
		rts
