; ---------------------------------------------------------------------------
; Object code execution subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Process_Objects:
		lea	(Object_RAM).w,a0
		cmpi.b	#PlayerID_Death,routine(a0)					; has Sonic just died?
		bhs.s	.freezeobject							; if yes, branch

.skip
		moveq	#bytesToXcnt(Object_RAM_end-Object_RAM,object_size),d7		; run objects

.loop
		move.l	address(a0),d0							; get object address to d0
		beq.s	.nextslot							; if zero, skip
		movea.l	d0,a1								; load object address to a0
		jsr	(a1)

.nextslot
		lea	next_object(a0),a0						; next object slot
		dbf	d7,.loop
		rts

; ---------------------------------------------------------------------------
; Make enemies and things pause when Sonic dies
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

.freezeobject
		cmpi.b	#PlayerID_Drown,routine(a0)					; has Sonic just drown?
		beq.s	Process_Objects.skip						; if yes, branch

		; run the first objects normally
		moveq	#bytesToXcnt(Dynamic_object_RAM-Object_RAM,object_size),d7
		bsr.s	Process_Objects.loop

		; all objects in this range are paused
		moveq	#bytesToXcnt(Dynamic_object_RAM_end-Dynamic_object_RAM,object_size),d7
		bsr.s	.freezeobject_loop

		; run the last objects normally
		moveq	#bytesToXcnt(Object_RAM_end-Dynamic_object_RAM_end,object_size),d7
		bra.s	Process_Objects.loop
; ---------------------------------------------------------------------------

.freezeobject_loop
		tst.l	address(a0)							; is this object slot occupied?
		beq.s	.freezeobject_nextslot						; if not, branch
		tst.b	render_flags(a0)						; object visible on the screen?
		bpl.s	.freezeobject_nextslot						; if not, branch
		bsr.w	Draw_Sprite

.freezeobject_nextslot
		lea	next_object(a0),a0						; next object slot
		dbf	d7,.freezeobject_loop
		rts
