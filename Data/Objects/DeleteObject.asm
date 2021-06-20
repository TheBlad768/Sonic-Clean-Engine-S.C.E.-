; ---------------------------------------------------------------------------
; Subroutine to delete an object
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

DeleteObject:
Delete_Current_Sprite:
		movea.l	a0,a1

DeleteChild:
DeleteObject2:
Delete_Referenced_Sprite:
		moveq	#0,d0
	rept	bytesTo2Lcnt(object_size)
		move.l	d0,(a1)+
	endm
	if object_size&2
		move.w	d0,(a1)+
	endif
		rts
; End of function Delete_Current_Sprite

; =============== S U B R O U T I N E =======================================

Go_Delete_Sprite:
		move.l	#Delete_Current_Sprite,address(a0)
		bset	#7,status(a0)
		rts
; End of function Go_Delete_Sprite

; =============== S U B R O U T I N E =======================================

Go_Delete_Sprite_2:
		move.l	#Delete_Current_Sprite,address(a0)
		bset	#4,$38(a0)
		rts
; End of function Go_Delete_Sprite_2

; =============== S U B R O U T I N E =======================================

Go_Delete_Sprite_3:
		move.l	#Delete_Current_Sprite,address(a0)
		bset	#7,status(a0)
		bset	#4,$38(a0)
		rts
; End of function Go_Delete_Sprite_3
