; ---------------------------------------------------------------------------
; Subroutine to find a free object space
; output:
; a1 = free position in object RAM
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Create_New_Sprite:
		lea	(Dynamic_object_RAM-next_object).w,a1			; start address for object RAM
		moveq	#bytesToXcnt(Dynamic_object_RAM_end-Dynamic_object_RAM,object_size),d0

.loop
		lea	next_object(a1),a1					; goto next object RAM slot
		tst.l	address(a1)						; is object RAM slot empty?
		dbeq	d0,.loop						; if not, branch
		rts

; =============== S U B R O U T I N E =======================================

Create_New_Sprite3:
		move.w	#Dynamic_object_RAM_end,d0
		sub.w	a0,d0
		lsr.w	#object_size_bits,d0					; divide by $40... even though SSTs are $4A bytes long in this game
		move.b	.table(pc,d0.w),d0					; use a look-up table to get the right loop counter
		bmi.s	.done

		; find slot
		lea	-next_object(a0),a1					; load current object to a1

.loop
		lea	next_object(a1),a1					; goto next object RAM slot
		tst.l	address(a1)						; is object RAM slot empty?
		dbeq	d0,.loop						; if not, branch

.done
		rts
; ---------------------------------------------------------------------------

.table

		set	.a,Dynamic_object_RAM
		set	.b,Dynamic_object_RAM_end
		set	.c,.b							; begin from bottom of array and decrease backwards

		rept (.b-.a)/setBit(object_size_bits)						; repeat for all slots, minus exception
			set	.c,.c-setBit(object_size_bits)					; address for previous $40 (also skip last part)
			dc.b (.b-.c-1)/object_size-1				; write possible slots according to object_size division + hack + dbf hack
		endr
	even
