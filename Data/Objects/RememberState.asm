; ---------------------------------------------------------------------------
; Subroutine to remember whether an object is destroyed/collected
; ---------------------------------------------------------------------------

MarkObjGone:
RememberState:
Sprite_OnScreen_Test:
		moveq	#-$80,d0										; round down to nearest $80
		and.w	x_pos(a0),d0										; get object position

Sprite_OnScreen_Test2:
		out_of_xrange2.s	Sprite_OnScreen_Test_Collision.offscreen
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

MarkObjGone_Collision:
RememberState_Collision:
Sprite_CheckDeleteTouch3:
Sprite_OnScreen_Test_Collision:
		moveq	#-$80,d0										; round down to nearest $80
		and.w	x_pos(a0),d0										; get object position

.skipxpos
		out_of_xrange2.s	.offscreen
		jmp	(Draw_And_Touch_Sprite).w
; ---------------------------------------------------------------------------

.offscreen
		move.w	respawn_addr(a0),d0								; get address in respawn table
		beq.s	.delete											; if it's zero, it isn't remembered
		movea.w	d0,a2											; load address into a2
		bclr	#7,(a2)

.delete
		jmp	(Delete_Current_Sprite).w

; =============== S U B R O U T I N E =======================================

Delete_Sprite_If_Not_In_Range:
		moveq	#-$80,d0										; round down to nearest $80
		and.w	x_pos(a0),d0										; get object position

Delete_Sprite_If_Not_In_Range2:
		out_of_xrange2.s	Sprite_OnScreen_Test_Collision.offscreen
		rts

; =============== S U B R O U T I N E =======================================

Delete_Sprite_If_Not_In_RangeCheck:
		moveq	#-$80,d0										; round down to nearest $80
		and.w	x_pos(a0),d0										; get object position

Delete_Sprite_If_Not_In_RangeCheck2:
		out_of_xrange2.s	Sprite_CheckDelete.offscreen
		rts

; =============== S U B R O U T I N E =======================================

Sprite_CheckDelete:
		moveq	#-$80,d0										; round down to nearest $80
		and.w	x_pos(a0),d0										; get object position

.skipxpos
		out_of_xrange2.s	.offscreen
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.offscreen
		move.w	respawn_addr(a0),d0								; get address in respawn table
		beq.s	.delete											; if it's zero, it isn't remembered
		movea.w	d0,a2											; load address into a2
		bclr	#7,(a2)

.delete
		bset	#7,status(a0)
		move.l	#Delete_Current_Sprite,address(a0)
		rts

; =============== S U B R O U T I N E =======================================

Sprite_CheckDeleteTouch:
		moveq	#-$80,d0										; round down to nearest $80
		and.w	x_pos(a0),d0										; get object position

.skipxpos
		out_of_xrange2.s	Sprite_CheckDelete.offscreen
		jmp	(Draw_And_Touch_Sprite).w

; =============== S U B R O U T I N E =======================================

Sprite_CheckDelete2:
		moveq	#-$80,d0										; round down to nearest $80
		and.w	x_pos(a0),d0										; get object position

.skipxpos
		out_of_xrange2.s	.offscreen
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.offscreen
		move.w	respawn_addr(a0),d0								; get address in respawn table
		beq.s	.delete											; if it's zero, it isn't remembered
		movea.w	d0,a2											; load address into a2
		bclr	#7,(a2)

.delete
		bset	#4,objoff_38(a0)
		move.l	#Delete_Current_Sprite,address(a0)

.return
		rts

; =============== S U B R O U T I N E =======================================

Sprite_CheckDeleteTouch2:
		moveq	#-$80,d0										; round down to nearest $80
		and.w	x_pos(a0),d0										; get object position

.skipxpos
		out_of_xrange2.s	Sprite_CheckDelete2.offscreen
		jmp	(Draw_And_Touch_Sprite).w

; =============== S U B R O U T I N E =======================================

Sprite_CheckDelete3:
		moveq	#-$80,d0										; round down to nearest $80
		and.w	x_pos(a0),d0										; get object position

.skipxpos
		out_of_xrange2.s	.offscreen
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.offscreen
		move.w	respawn_addr(a0),d0								; get address in respawn table
		beq.s	.delete											; if it's zero, it isn't remembered
		movea.w	d0,a2											; load address into a2
		bclr	#7,(a2)

.delete
		move.l	#Delete_Current_Sprite,address(a0)
		rts

; =============== S U B R O U T I N E =======================================

Sprite_CheckDeleteXY:
		out_of_xrange.w	Go_Delete_Sprite

Sprite_CheckDeleteY:
		out_of_yrange.w	Go_Delete_Sprite
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

Sprite_CheckDeleteXY_NoDraw:
		out_of_xrange.w	Go_Delete_Sprite

Sprite_CheckDeleteY_NoDraw:
		out_of_yrange.w	Go_Delete_Sprite
		rts

; =============== S U B R O U T I N E =======================================

Sprite_ChildCheckDeleteXY:
		out_of_xrange.w	Go_Delete_Sprite

Sprite_ChildCheckDeleteY:
		out_of_yrange.w	Go_Delete_Sprite
		movea.w	parent3(a0),a1
		btst	#7,status(a1)
		bne.w	Go_Delete_Sprite
		bra.w	Draw_Sprite

; =============== S U B R O U T I N E =======================================

Sprite_ChildCheckDeleteXY_NoDraw:
		out_of_xrange.w	Go_Delete_Sprite

Sprite_ChildCheckDeleteY_NoDraw:
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
		move.b	(V_int_run_count+3).w,d0
		add.b	d7,d0
		andi.b	#1,d0
		bne.s	Sprite_ChildCheckDeleteY_NoDraw.return
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

Sprite_CheckDeleteTouchXY:
		out_of_xrange.w	Go_Delete_Sprite

Sprite_CheckDeleteTouchY:
		out_of_yrange.w	Go_Delete_Sprite
		jmp	(Draw_And_Touch_Sprite).w

; =============== S U B R O U T I N E =======================================

Sprite_ChildCheckDeleteTouchXY:
		out_of_xrange.w	Go_Delete_Sprite

Sprite_ChildCheckDeleteTouchY:
		out_of_yrange.w	Go_Delete_Sprite
		movea.w	parent3(a0),a1
		btst	#7,status(a1)
		bne.w	Go_Delete_Sprite
		jmp	(Draw_And_Touch_Sprite).w

; =============== S U B R O U T I N E =======================================

Sprite_CheckDeleteSlotted:
		out_of_xrange.s	Go_Delete_SpriteSlotted
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

Go_Delete_SpriteSlotted:
		move.w	respawn_addr(a0),d0								; get address in respawn table
		beq.s	Go_Delete_SpriteSlotted2							; if it's zero, it isn't remembered
		movea.w	d0,a2											; load address into a2
		bclr	#7,(a2)

Go_Delete_SpriteSlotted2:
		bset	#7,status(a0)

Go_Delete_SpriteSlotted3:
		move.l	#Delete_Current_Sprite,address(a0)

Remove_From_TrackingSlot:
		move.b	ros_bit(a0),d0									; slot bit
		movea.w	ros_addr(a0),a1									; slot address
		bclr	d0,(a1)												; turn off this slot
		rts

; =============== S U B R O U T I N E =======================================

Sprite_CheckDeleteTouchSlotted:
		tst.b	status(a0)
		bmi.s	Go_Delete_SpriteSlotted3
		out_of_xrange.s	Go_Delete_SpriteSlotted
		pea	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

Add_SpriteToCollisionResponseList:
		lea	(Collision_response_list).w,a1
		move.w	(a1),d0											; get list to d0
		addq.b	#2,d0											; is list full? ($80)
		bmi.s	.return											; if so, return
		move.w	d0,(a1)											; save list  ($7E)
		move.w	a0,(a1,d0.w)										; store RAM address in list

.return
		rts

; =============== S U B R O U T I N E =======================================

Obj_WaitOffscreen:
		move.l	#Map_Offscreen,mappings(a0)
		bset	#2,render_flags(a0)									; use screen coordinates
		move.w	#bytes_to_word(64/2,64/2),height_pixels(a0)			; set height and width
		move.l	(sp)+,objoff_34(a0)								; save address after bsr/jsr
		move.l	#.main,address(a0)

.main
		tst.b	render_flags(a0)										; object visible on the screen?
		bmi.s	.restore											; if yes, branch
		bra.w	Sprite_OnScreen_Test
; ---------------------------------------------------------------------------

.restore
		move.l	objoff_34(a0),address(a0)							; restore normal object operation when onscreen
		rts
; ---------------------------------------------------------------------------

Map_Offscreen:	dc.w Map_Offscreen-Map_Offscreen
