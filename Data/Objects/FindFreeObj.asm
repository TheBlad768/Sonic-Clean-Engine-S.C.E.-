; ---------------------------------------------------------------------------
; Subroutine to find a free object space
; output:
; a1 = free position in object RAM
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

FindFreeObj:
SingleObjLoad:
Create_New_Sprite:
		lea	(Dynamic_object_RAM).w,a1	; start address for object RAM
		moveq	#((Dynamic_object_RAM_end-Dynamic_object_RAM)/object_size)-1,d0
		bra.s	Create_New_Sprite3.loop
; ---------------------------------------------------------------------------

SingleObjLoad2:
FindNextFreeObj:
Create_New_Sprite3:
		movea.w	a0,a1
		move.w	#Dynamic_object_RAM_end,d0
		sub.w	a0,d0
		lsr.w	#6,d0								; divide by $40... even though SSTs are $4A bytes long in this game
		move.b	.find_first_sprite_table(pc,d0.w),d0		; use a look-up table to get the right loop counter
		bmi.s	.found

.loop
		lea	next_object(a1),a1		; goto next object RAM slot
		tst.l	address(a1)			; is object RAM slot empty?
		dbeq	d0,.loop

.found
		rts
; ---------------------------------------------------------------------------

.find_first_sprite_table
.a	set	Dynamic_object_RAM
.b	set	Dynamic_object_RAM_end
.c	set	.b							; begin from bottom of array and decrease backwards
		rept	(.b-.a)/$40				; repeat for all slots, minus exception
.c	set		.c-$40					; address for previous $40 (also skip last part)
		dc.b	(.b-.c-1)/object_size-1		; write possible slots according to object_size division + hack + dbf hack
		endr
	even
