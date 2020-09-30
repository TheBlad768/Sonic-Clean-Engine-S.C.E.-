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
		moveq	#((Dynamic_object_RAM_End-Dynamic_object_RAM)/object_size)-1,d0
		bra.s	NFree_Loop
; ---------------------------------------------------------------------------

SingleObjLoad2:
FindNextFreeObj:
Create_New_Sprite3:
		movea.l	a0,a1
		move.w	#Dynamic_object_RAM_End,d0
		sub.w	a0,d0
		lsr.w	#6,d0								; Divide by $40... even though SSTs are $4A bytes long in this game
		move.b	Find_First_Sprite_Table(pc,d0.w),d0	; Use a look-up table to get the right loop counter
		bmi.s	NFree_Found

NFree_Loop:
		lea	next_object(a1),a1		; goto next object RAM slot
		tst.l	(a1)					; is object RAM slot empty?
		dbeq	d0,NFree_Loop

NFree_Found:
		rts
; End of function Create_New_Sprite
; ---------------------------------------------------------------------------

Find_First_Sprite_Table:
.a	set	Dynamic_Object_RAM
.b	set	Dynamic_Object_RAM_End
.c	set	.b							; begin from bottom of array and decrease backwards
		rept	(.b-.a)/$40				; repeat for all slots, minus exception
.c	set		.c-$40					; address for previous $40 (also skip last part)
		dc.b	(.b-.c-1)/object_size-1		; write possible slots according to object_size division + hack + dbf hack
		endm
	even