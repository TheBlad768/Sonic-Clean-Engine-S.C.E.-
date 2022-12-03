; ---------------------------------------------------------------------------
; Subroutine to remember whether an object is destroyed/collected
; ---------------------------------------------------------------------------

MarkObjGone:
RememberState:
Sprite_OnScreen_Test:
		move.w	x_pos(a0),d0

Sprite_OnScreen_Test2:
		out_of_xrange2.s	.offscreen
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.offscreen
		move.w	respawn_addr(a0),d0
		beq.s	.delete
		movea.w	d0,a2
		bclr	#7,(a2)

.delete
		jmp	(Delete_Current_Sprite).w

; =============== S U B R O U T I N E =======================================

MarkObjGone_Collision:
RememberState_Collision:
Sprite_CheckDeleteTouch3:
Sprite_OnScreen_Test_Collision:
		move.w	x_pos(a0),d0

.skipxpos
		out_of_xrange2.s	.offscreen
		jsr	(Add_SpriteToCollisionResponseList).w
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.offscreen
		move.w	respawn_addr(a0),d0
		beq.s	.delete
		movea.w	d0,a2
		bclr	#7,(a2)

.delete
		jmp	(Delete_Current_Sprite).w

; =============== S U B R O U T I N E =======================================

Delete_Sprite_If_Not_In_Range:
		out_of_xrange.s	.offscreen
		rts
; ---------------------------------------------------------------------------

.offscreen
		move.w	respawn_addr(a0),d0
		beq.s	.delete
		movea.w	d0,a2
		bclr	#7,(a2)

.delete
		jmp	(Delete_Current_Sprite).w

; =============== S U B R O U T I N E =======================================

Sprite_CheckDelete:
		out_of_xrange.s	.offscreen
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.offscreen
		move.w	respawn_addr(a0),d0
		beq.s	.delete
		movea.w	d0,a2
		bclr	#7,(a2)

.delete
		bset	#7,status(a0)
		move.l	#Delete_Current_Sprite,address(a0)
		rts

; =============== S U B R O U T I N E =======================================

Sprite_CheckDelete2:
		out_of_xrange.s	.offscreen
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.offscreen
		move.w	respawn_addr(a0),d0
		beq.s	.delete
		movea.w	d0,a2
		bclr	#7,(a2)

.delete
		bset	#4,$38(a0)
		move.l	#Delete_Current_Sprite,address(a0)

.return
		rts

; =============== S U B R O U T I N E =======================================

Sprite_CheckDeleteXY:
		out_of_xrange.w	Go_Delete_Sprite
		out_of_yrange.w	Go_Delete_Sprite
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

Sprite_CheckDeleteXY_NoDraw:
		out_of_xrange.w	Go_Delete_Sprite
		out_of_yrange.w	Go_Delete_Sprite
		rts

; =============== S U B R O U T I N E =======================================

Sprite_ChildCheckDeleteXY:
		out_of_xrange.w	Go_Delete_Sprite
		out_of_yrange.w	Go_Delete_Sprite
		movea.w	parent3(a0),a1
		btst	#7,status(a1)
		bne.w	Go_Delete_Sprite
		bra.w	Draw_Sprite

; =============== S U B R O U T I N E =======================================

Sprite_ChildCheckDeleteXY_NoDraw:
		out_of_xrange.w	Go_Delete_Sprite
		out_of_yrange.w	Go_Delete_Sprite
		movea.w	parent3(a0),a1
		btst	#7,status(a1)
		bne.w	Go_Delete_Sprite

.return
		rts

; =============== S U B R O U T I N E =======================================

Obj_FlickerMove:
		bsr.w	MoveSprite
		out_of_xrange.w	Go_Delete_Sprite_3
		out_of_yrange.w	Go_Delete_Sprite_3
		bchg	#6,$38(a0)
		beq.s	Sprite_ChildCheckDeleteXY_NoDraw.return
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

Sprite_CheckDeleteTouch:
		out_of_xrange.w	Sprite_CheckDelete.offscreen
		jsr	(Add_SpriteToCollisionResponseList).w
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

Sprite_CheckDeleteTouch2:
		out_of_xrange.w	Sprite_CheckDelete2.offscreen
		jsr	(Add_SpriteToCollisionResponseList).w
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

Sprite_CheckDeleteTouchXY:
		out_of_xrange.w	Go_Delete_Sprite
		out_of_yrange.w	Go_Delete_Sprite
		jsr	(Add_SpriteToCollisionResponseList).w
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

Sprite_ChildCheckDeleteTouchXY:
		out_of_xrange.w	Go_Delete_Sprite

Sprite_ChildCheckDeleteTouchY:
		out_of_yrange.w	Go_Delete_Sprite
		movea.w	parent3(a0),a1
		btst	#7,status(a1)
		bne.w	Go_Delete_Sprite
		jsr	(Add_SpriteToCollisionResponseList).w
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

Sprite_CheckDeleteSlotted:
		out_of_xrange.s	Go_Delete_SpriteSlotted
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

Go_Delete_SpriteSlotted:
		move.w	respawn_addr(a0),d0
		beq.s	Go_Delete_SpriteSlotted2
		movea.w	d0,a2
		bclr	#7,(a2)

Go_Delete_SpriteSlotted2:
		move.l	#Delete_Current_Sprite,address(a0)
		bset	#7,status(a0)

Remove_From_TrackingSlot:
		move.b	objoff_3B(a0),d0	; slot bit
		movea.w	objoff_3C(a0),a1	; slot address
		bclr	d0,(a1)				; turn off this slot
		rts

; =============== S U B R O U T I N E =======================================

Sprite_CheckDeleteTouchSlotted:
		tst.b	status(a0)
		bmi.s	Go_Delete_SpriteSlotted3
		out_of_xrange.s	Go_Delete_SpriteSlotted
		jsr	(Add_SpriteToCollisionResponseList).w
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

Go_Delete_SpriteSlotted3:
		move.l	#Delete_Current_Sprite,address(a0)
		bra.s	Remove_From_TrackingSlot

; =============== S U B R O U T I N E =======================================

Obj_WaitOffscreen:
		move.l	#Map_Offscreen,mappings(a0)
		bset	#2,render_flags(a0)
		move.w	#bytes_to_word(64/2,64/2),height_pixels(a0)		; set height and width
		move.l	(sp)+,objoff_34(a0)
		move.l	#.main,address(a0)

.main
		tst.b	render_flags(a0)				; object visible on the screen?
		bmi.s	.restore					; if yes, branch
		jmp	Sprite_OnScreen_Test(pc)
; ---------------------------------------------------------------------------

.restore
		move.l	objoff_34(a0),address(a0)	; restore normal object operation when onscreen
		rts
; ---------------------------------------------------------------------------

Map_Offscreen:	dc.w Map_Offscreen-Map_Offscreen
