; ---------------------------------------------------------------------------
; Subroutine to delete an object
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

DeleteObject:
Delete_Current_Sprite:
		movea.w	a0,a1

DeleteChild:
DeleteObject2:
Delete_Referenced_Sprite:
		moveq	#0,d0
	rept	bytesTo2Lcnt(object_size)
		move.l	d0,(a1)+
	endr
	if object_size&2
		move.w	d0,(a1)+
	endif
		rts

; =============== S U B R O U T I N E =======================================

Go_Delete_Sprite_3:
		bset	#4,objoff_38(a0)

Go_Delete_Sprite:
		move.l	#Delete_Current_Sprite,address(a0)
		bset	#7,status(a0)
		rts

; =============== S U B R O U T I N E =======================================

Go_Delete_Sprite_2:
		move.l	#Delete_Current_Sprite,address(a0)
		bset	#4,objoff_38(a0)
		rts