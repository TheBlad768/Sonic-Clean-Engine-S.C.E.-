; ---------------------------------------------------------------------------
; Subroutine to display a sprite/object, when a0 is the object RAM
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Draw_And_Touch_Sprite:
		bsr.w	Add_SpriteToCollisionResponseList

; =============== S U B R O U T I N E =======================================

Draw_Sprite:
DisplaySprite:
		lea	(Sprite_table_input).w,a1
		adda.w	priority(a0),a1

.find
		move.w	(a1),d0										; get list to d0
		addq.b	#2,d0										; is list full? ($80)
		bmi.s	.full											; if so, return
		move.w	d0,(a1)										; save list  ($7E)
		move.w	a0,(a1,d0.w)									; store RAM address in list

.return
		rts
; ---------------------------------------------------------------------------

.full
		cmpa.w	#(Sprite_table_input_end-$80),a1				; is last sprite table?
		beq.s	.return										; if so, return
		lea	$80(a1),a1										; next sprite table
		bra.s	.find

; =============== S U B R O U T I N E =======================================

Child_Draw_Sprite:
		movea.w	parent3(a0),a1
		btst	#7,status(a1)
		bne.w	Go_Delete_Sprite
		bra.s	Draw_Sprite

; =============== S U B R O U T I N E =======================================

Child_DrawTouch_Sprite:
		movea.w	parent3(a0),a1
		btst	#7,status(a1)
		bne.w	Go_Delete_Sprite
		bra.s	Draw_And_Touch_Sprite

; =============== S U B R O U T I N E =======================================

Child_CheckParent:
		movea.w	parent3(a0),a1
		btst	#7,status(a1)
		bne.w	Go_Delete_Sprite
		rts

; =============== S U B R O U T I N E =======================================

Child_AddToTouchList:
		movea.w	parent3(a0),a1
		btst	#7,status(a1)
		bne.w	Go_Delete_Sprite
		bra.w	Add_SpriteToCollisionResponseList

; =============== S U B R O U T I N E =======================================

Child_Remember_Draw_Sprite:
		movea.w	parent3(a0),a1
		btst	#7,status(a1)
		bne.s	loc_84984
		bra.s	Draw_Sprite
; ---------------------------------------------------------------------------

loc_84984:
		bsr.w	Remove_From_TrackingSlot
		bra.w	Go_Delete_Sprite

; =============== S U B R O U T I N E =======================================

Child_Draw_Sprite2:
		movea.w	parent3(a0),a1
		btst	#4,objoff_38(a1)
		bne.w	Go_Delete_Sprite_2
		bra.w	Draw_Sprite

; =============== S U B R O U T I N E =======================================

Child_DrawTouch_Sprite2:
		movea.w	parent3(a0),a1
		btst	#4,objoff_38(a1)
		bne.w	Go_Delete_Sprite_2
		btst	#7,status(a1)
		bne.s	loc_849BC
		bsr.w	Add_SpriteToCollisionResponseList

loc_849BC:
		bra.w	Draw_Sprite

; =============== S U B R O U T I N E =======================================

Child_Draw_Sprite_FlickerMove:
		movea.w	parent3(a0),a1
		btst	#7,status(a1)
		bne.s	loc_849D8
		bra.w	Draw_Sprite
; ---------------------------------------------------------------------------

loc_849D8:
		bset	#7,status(a0)
		move.l	#Obj_FlickerMove,address(a0)
		clr.b	collision_flags(a0)
		bsr.w	Set_IndexedVelocity
		bra.w	Draw_Sprite

; =============== S U B R O U T I N E =======================================

Child_Draw_Sprite2_FlickerMove:
		movea.w	parent3(a0),a1
		btst	#4,objoff_38(a1)
		bne.s	loc_849D8
		bra.w	Draw_Sprite

; =============== S U B R O U T I N E =======================================

Child_DrawTouch_Sprite_FlickerMove:
		movea.w	parent3(a0),a1
		btst	#7,status(a1)
		bne.s	loc_849D8

loc_84A3C:
		bra.w	Draw_And_Touch_Sprite

; =============== S U B R O U T I N E =======================================

Child_DrawTouch_Sprite2_FlickerMove:
		movea.w	parent3(a0),a1
		btst	#4,objoff_38(a1)
		bne.s	loc_849D8
		btst	#7,status(a1)
		beq.s	loc_84A3C
		bset	#7,status(a0)
		bra.w	Draw_Sprite

; =============== S U B R O U T I N E =======================================

Child_DrawTouch_Sprite2_FlickerMove2:
		movea.w	parent3(a0),a1
		btst	#4,objoff_38(a1)
		bne.s	loc_849D8
		bra.s	loc_84A3C
