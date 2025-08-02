; ---------------------------------------------------------------------------
; Subroutine to display a sprite/object, when a0 is the object RAM
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Draw_And_Touch_Sprite:
		bsr.w	Add_SpriteToCollisionResponseList				; add to collision response list

; =============== S U B R O U T I N E =======================================

Draw_Sprite:
		lea	(Sprite_table_input).w,a1					; load sprite table input to a1
		adda.w	priority(a0),a1							; add sprite priority offset to a1

.find
		move.w	(a1),d0								; get list to d0
		addq.b	#2,d0								; is list full? ($80)
		bmi.s	.next								; if so, return
		move.w	d0,(a1)								; save list ($7E)
		move.w	a0,(a1,d0.w)							; store RAM address in list

.return
		rts
; ---------------------------------------------------------------------------

.next
		cmpa.w	#(Sprite_table_input_end-$80),a1				; is last sprite table?
		beq.s	.return								; if so, return
		lea	$80(a1),a1							; next sprite table
		bra.s	.find								; back

; =============== S U B R O U T I N E =======================================

Child_Draw_Sprite:
		movea.w	parent3(a0),a1							; a1=parent object
		btst	#status.npc.defeated,status(a1)					; is boss defeated?
		bne.w	Go_Delete_Sprite						; if yes, branch
		bra.s	Draw_Sprite

; =============== S U B R O U T I N E =======================================

Child_DrawTouch_Sprite:
		movea.w	parent3(a0),a1							; a1=parent object
		btst	#status.npc.defeated,status(a1)					; is boss defeated?
		bne.w	Go_Delete_Sprite						; if yes, branch
		bra.s	Draw_And_Touch_Sprite

; =============== S U B R O U T I N E =======================================

Child_CheckParent:
		movea.w	parent3(a0),a1							; a1=parent object
		btst	#status.npc.defeated,status(a1)					; is boss defeated?
		bne.w	Go_Delete_Sprite						; if yes, branch
		rts

; =============== S U B R O U T I N E =======================================

Child_AddToTouchList:
		movea.w	parent3(a0),a1							; a1=parent object
		btst	#status.npc.defeated,status(a1)					; is boss defeated?
		bne.w	Go_Delete_Sprite						; if yes, branch
		bra.w	Add_SpriteToCollisionResponseList

; =============== S U B R O U T I N E =======================================

Child_Remember_Draw_Sprite:
		movea.w	parent3(a0),a1							; a1=parent object
		btst	#status.npc.defeated,status(a1)					; is boss defeated?
		bne.s	.delete								; if yes, branch
		bra.s	Draw_Sprite
; ---------------------------------------------------------------------------

.delete
		bsr.w	Remove_From_TrackingSlot
		bra.w	Go_Delete_Sprite

; =============== S U B R O U T I N E =======================================

Child_Draw_Sprite2:
		movea.w	parent3(a0),a1							; a1=parent object
		btst	#4,objoff_38(a1)						; is delete child object flag set?
		bne.w	Go_Delete_Sprite_2						; if yes, branch
		bra.w	Draw_Sprite

; =============== S U B R O U T I N E =======================================

Child_DrawTouch_Sprite2:
		movea.w	parent3(a0),a1							; a1=parent object
		btst	#4,objoff_38(a1)						; is delete child object flag set?
		bne.w	Go_Delete_Sprite_2						; if yes, branch
		btst	#status.npc.defeated,status(a1)					; is boss defeated?
		bne.s	.draw								; if yes, branch
		bsr.w	Add_SpriteToCollisionResponseList

.draw
		bra.w	Draw_Sprite

; =============== S U B R O U T I N E =======================================

Child_Draw_Sprite_FlickerMove:
		movea.w	parent3(a0),a1							; a1=parent object
		btst	#status.npc.defeated,status(a1)					; is boss defeated?
		bne.s	.flicker							; if yes, branch
		bra.w	Draw_Sprite
; ---------------------------------------------------------------------------

.flicker
		bset	#status.npc.defeated,status(a0)					; set "boss defeated" flag
		move.l	#Obj_FlickerMove,address(a0)
		clr.b	collision_flags(a0)
		bsr.w	Set_IndexedVelocity
		bra.w	Draw_Sprite

; =============== S U B R O U T I N E =======================================

Child_Draw_Sprite2_FlickerMove:
		movea.w	parent3(a0),a1							; a1=parent object
		btst	#4,objoff_38(a1)						; is delete child object flag set?
		bne.s	Child_Draw_Sprite_FlickerMove.flicker				; if yes, branch
		bra.w	Draw_Sprite

; =============== S U B R O U T I N E =======================================

Child_DrawTouch_Sprite_FlickerMove:
		movea.w	parent3(a0),a1							; a1=parent object
		btst	#status.npc.defeated,status(a1)					; is boss defeated?
		bne.s	Child_Draw_Sprite_FlickerMove.flicker				; if yes, branch

.draw
		bra.w	Draw_And_Touch_Sprite

; =============== S U B R O U T I N E =======================================

Child_DrawTouch_Sprite2_FlickerMove:
		movea.w	parent3(a0),a1							; a1=parent object
		btst	#4,objoff_38(a1)						; is delete child object flag set?
		bne.s	Child_Draw_Sprite_FlickerMove.flicker				; if yes, branch
		btst	#status.npc.defeated,status(a1)					; is boss defeated?
		beq.s	Child_DrawTouch_Sprite_FlickerMove.draw				; if not, branch
		bset	#status.npc.defeated,status(a0)					; set "boss defeated" flag
		bra.w	Draw_Sprite

; =============== S U B R O U T I N E =======================================

Child_DrawTouch_Sprite2_FlickerMove2:
		movea.w	parent3(a0),a1							; a1=parent object
		btst	#4,objoff_38(a1)						; is delete child object flag set?
		bne.s	Child_Draw_Sprite_FlickerMove.flicker				; if yes, branch
		bra.s	Child_DrawTouch_Sprite_FlickerMove.draw
