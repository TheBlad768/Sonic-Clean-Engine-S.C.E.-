; ---------------------------------------------------------------------------
; Subroutine to find a free object space
;
; Output:
; a1 = free position in object RAM
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Create_New_Object:
		lea	(Dynamic_object_RAM-next_object).w,a1				; start address for object RAM
		moveq	#bytesToXcnt(Dynamic_object_RAM_end-Dynamic_object_RAM,object_size),d0

.find
		lea	next_object(a1),a1						; goto next object RAM slot
		tst.l	address(a1)							; is object RAM slot empty?
		dbeq	d0,.find							; if not, branch
		rts

; ---------------------------------------------------------------------------
; Subroutine to find a free object space using pre-calculated parameters
;
; Input:
; d0 = maximum object slots to check
; a1 = object address to start checking from
;
; Output:
; a1 = free position in object RAM
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Create_New_Object_4:
		subq.w	#1,d0
		bmi.s	.done								; branch, if there are no free object slots here

.find
		lea	next_object(a1),a1						; goto next object RAM slot
		tst.l	address(a1)							; is object RAM slot empty?
		dbeq	d0,.find							; if not, branch

.done
		rts

; ---------------------------------------------------------------------------
; Subroutine to find the current object space
;
; Output:
; a1 = free position in object RAM
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Find_Object_Slot:
		move.w	#Dynamic_object_RAM_end,d0
		sub.w	a0,d0
		lsr.w	#object_size_bits,d0						; divide by $40... even though SSTs are $50 bytes long in this game
		move.b	Create_New_Object_3.table(pc,d0.w),d0				; use a look-up table to get the right loop counter
		rts

; ---------------------------------------------------------------------------
; Subroutine to find a free object space starting from a specific object
;
; Input:
; a0 = current object address
;
; Output:
; a1 = free position in object RAM
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Create_New_Object_3:
		move.w	#Dynamic_object_RAM_end,d0
		sub.w	a0,d0
		lsr.w	#object_size_bits,d0						; divide by $40... even though SSTs are $50 bytes long in this game
		move.b	.table(pc,d0.w),d0						; use a look-up table to get the right loop counter
		bmi.s	.done								; branch, if there are no free object slots here

		; find slot
		lea	-next_object(a0),a1						; load current object to a1

.find
		lea	next_object(a1),a1						; goto next object RAM slot
		tst.l	address(a1)							; is object RAM slot empty?
		dbeq	d0,.find							; if not, branch

.done
		rts
; ---------------------------------------------------------------------------

.table

		set	.a,Dynamic_object_RAM
		set	.b,Dynamic_object_RAM_end
		set	.c,.b-.a							; begin from bottom of array and decrease backwards
		set	.d,.c/setBit(object_size_bits)

		if (.c#setBit(object_size_bits))<>0					; modulo division
			set	.d,.d+1
		endif

		set	.c,.b

		rept .d									; repeat for all slots, minus exception
			set	.c,.c-setBit(object_size_bits)				; address for previous $40 (also skip last part)
			dc.b (.b-.c-1)/object_size-1					; write possible slots according to object_size division + hack + dbf hack
		endr
	even
