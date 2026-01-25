; ---------------------------------------------------------------------------
; Subroutine to delete an object
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Delete_Current_Object:
		movea.w	a0,a1								; load current object to a1

Delete_Referenced_Object:
		moveq	#0,d0

	rept bytesTo2Lcnt(object_size)
		move.l	d0,(a1)+
	endr

	if object_size&2
		move.w	d0,(a1)+
	endif

		rts

; =============== S U B R O U T I N E =======================================

Go_Delete_Object_3:
		bset	#4,state_flags(a0)						; set "delete child object" flag

Go_Delete_Object:
		move.l	#Delete_Current_Object,address(a0)
		bset	#status.npc.defeated,status(a0)					; set "boss defeated" flag
		rts

; =============== S U B R O U T I N E =======================================

Go_Delete_Object_2:
		move.l	#Delete_Current_Object,address(a0)
		bset	#4,state_flags(a0)						; set "delete child object" flag
		rts
