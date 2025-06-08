; ---------------------------------------------------------------------------
; Object code execution subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Process_Sprites:
		lea	(Object_RAM).w,a0
		cmpi.b	#PlayerID_Death,routine(a0)							; has Sonic just died?
		bhs.s	Process_Sprites_FreezeObject							; if yes, branch

Process_Sprites_Skip:
		moveq	#bytesToXcnt(Object_RAM_end-Object_RAM,object_size),d7				; run objects

Process_Sprites_Loop:
		move.l	address(a0),d0
		beq.s	.nextslot
		movea.l	d0,a1
		jsr	(a1)

.nextslot
		lea	next_object(a0),a0								; next slot
		dbf	d7,Process_Sprites_Loop
		rts

; =============== S U B R O U T I N E =======================================

Process_Sprites_FreezeObject:
		cmpi.b	#PlayerID_Drown,routine(a0)							; has Sonic just drown?
		beq.s	Process_Sprites_Skip								; if yes, branch

		; run the first objects normally
		moveq	#bytesToXcnt(Dynamic_object_RAM-Object_RAM,object_size),d7
		bsr.s	Process_Sprites_Loop

		; all objects in this range are paused
		moveq	#bytesToXcnt(Dynamic_object_RAM_end-Dynamic_object_RAM,object_size),d7
		bsr.s	Process_Sprites_FreezeObject_Loop

		; run the last objects normally
		moveq	#bytesToXcnt(Object_RAM_end-Dynamic_object_RAM_end,object_size),d7
		bra.s	Process_Sprites_Loop
; ---------------------------------------------------------------------------

Process_Sprites_FreezeObject_Loop:
		tst.l	address(a0)									; is this object slot occupied?
		beq.s	.nextslot									; if not, branch
		tst.b	render_flags(a0)								; object visible on the screen?
		bpl.s	.nextslot									; if not, branch
		bsr.w	Draw_Sprite

.nextslot
		lea	next_object(a0),a0								; next slot
		dbf	d7,Process_Sprites_FreezeObject_Loop
		rts
