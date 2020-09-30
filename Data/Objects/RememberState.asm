; ---------------------------------------------------------------------------
; Subroutine to remember whether an object is destroyed/collected
; ---------------------------------------------------------------------------

MarkObjGone:
RememberState:
Sprite_OnScreen_Test:
		move.w	x_pos(a0),d0

Sprite_OnScreen_Test2:
		andi.w	#-128,d0
		sub.w	(Camera_X_pos_coarse_back).w,d0
		cmpi.w	#128+320+192,d0
		bhi.s	.offscreen
		bra.w	Draw_Sprite
; ---------------------------------------------------------------------------

.offscreen:
		move.w	respawn_addr(a0),d0
		beq.s	.delete
		movea.w	d0,a2
		bclr	#7,(a2)

.delete:
		bra.w	Delete_Current_Sprite

; =============== S U B R O U T I N E =======================================

MarkObjGone_Collision:
RememberState_Collision:
Sprite_OnScreen_Test_Collision:
		move.w	x_pos(a0),d0
		andi.w	#-128,d0
		sub.w	(Camera_X_pos_coarse_back).w,d0
		cmpi.w	#128+320+192,d0
		bhi.s	.offscreen
		bsr.w	Add_SpriteToCollisionResponseList
		bra.w	Draw_Sprite
; ---------------------------------------------------------------------------

.offscreen:
		move.w	respawn_addr(a0),d0
		beq.s	.delete
		movea.w	d0,a2
		bclr	#7,(a2)

.delete:
		bra.w	Delete_Current_Sprite

; =============== S U B R O U T I N E =======================================

Delete_Sprite_If_Not_In_Range:
		move.w	x_pos(a0),d0
		andi.w	#-128,d0
		sub.w	(Camera_X_pos_coarse_back).w,d0
		cmpi.w	#128+320+192,d0
		bhi.s	.offscreen
		rts
; ---------------------------------------------------------------------------

.offscreen:
		move.w	respawn_addr(a0),d0
		beq.s	.delete
		movea.w	d0,a2
		bclr	#7,(a2)

.delete:
		bra.w	Delete_Current_Sprite
; End of function Delete_Sprite_If_Not_In_Range

; =============== S U B R O U T I N E =======================================

Sprite_CheckDelete:
		move.w	x_pos(a0),d0
		andi.w	#-128,d0
		sub.w	(Camera_X_pos_coarse_back).w,d0
		cmpi.w	#128+320+192,d0
		bhi.s	.offscreen
		bra.w	Draw_Sprite
; ---------------------------------------------------------------------------

.offscreen:
		move.w	respawn_addr(a0),d0
		beq.s	.delete
		movea.w	d0,a2
		bclr	#7,(a2)

.delete:
		bset	#7,status(a0)
		move.l	#Delete_Current_Sprite,address(a0)
		rts

; =============== S U B R O U T I N E =======================================

Sprite_CheckDelete2:
		move.w	x_pos(a0),d0
		andi.w	#-128,d0
		sub.w	(Camera_X_pos_coarse_back).w,d0
		cmpi.w	#128+320+192,d0
		bhi.s	.offscreen
		bra.w	Draw_Sprite
; ---------------------------------------------------------------------------

.offscreen:
		move.w	respawn_addr(a0),d0
		beq.s	.delete
		movea.w	d0,a2
		bclr	#7,(a2)

.delete:
		bset	#4,$38(a0)
		move.l	#Delete_Current_Sprite,address(a0)

.return:
		rts

; =============== S U B R O U T I N E =======================================

Sprite_CheckDeleteXY:
		move.w	x_pos(a0),d0
		andi.w	#-128,d0
		sub.w	(Camera_X_pos_coarse_back).w,d0
		cmpi.w	#128+320+192,d0
		bhi.w	Go_Delete_Sprite
		move.w	y_pos(a0),d0
		sub.w	(Camera_Y_pos).w,d0
		addi.w	#$80,d0
		cmpi.w	#320+192,d0
		bhi.w	Go_Delete_Sprite
		bra.w	Draw_Sprite

; =============== S U B R O U T I N E =======================================

Obj_FlickerMove:
		bsr.w	MoveSprite
		move.w	x_pos(a0),d0
		andi.w	#-128,d0
		sub.w	(Camera_X_pos_coarse_back).w,d0
		cmpi.w	#128+320+192,d0
		bhi.w	Go_Delete_Sprite_3
		move.w	y_pos(a0),d0
		sub.w	(Camera_Y_pos).w,d0
		addi.w	#$80,d0
		cmpi.w	#320+192,d0
		bhi.w	Go_Delete_Sprite_3
		bchg	#6,$38(a0)
		beq.s	Sprite_CheckDelete2.return
		bra.w	Draw_Sprite

; =============== S U B R O U T I N E =======================================

Sprite_CheckDeleteTouch:
		move.w	x_pos(a0),d0
		andi.w	#-128,d0
		sub.w	(Camera_X_pos_coarse_back).w,d0
		cmpi.w	#128+320+192,d0
		bhi.w	Sprite_CheckDelete.offscreen
		bsr.w	Add_SpriteToCollisionResponseList
		bra.w	Draw_Sprite

; =============== S U B R O U T I N E =======================================

Sprite_CheckDeleteTouch2:
		move.w	x_pos(a0),d0
		andi.w	#-128,d0
		sub.w	(Camera_X_pos_coarse_back).w,d0
		cmpi.w	#128+320+192,d0
		bhi.w	Sprite_CheckDelete2.offscreen
		bsr.w	Add_SpriteToCollisionResponseList
		bra.w	Draw_Sprite

; =============== S U B R O U T I N E =======================================

Sprite_CheckDeleteTouchXY:
		move.w	x_pos(a0),d0
		andi.w	#-128,d0
		sub.w	(Camera_X_pos_coarse_back).w,d0
		cmpi.w	#128+320+192,d0
		bhi.w	Go_Delete_Sprite
		move.w	y_pos(a0),d0
		sub.w	(Camera_Y_pos).w,d0
		addi.w	#$80,d0
		cmpi.w	#320+192,d0
		bhi.w	Go_Delete_Sprite
		bsr.w	Add_SpriteToCollisionResponseList
		bra.w	Draw_Sprite

; =============== S U B R O U T I N E =======================================

Sprite_CheckDeleteSlotted:
		move.w	x_pos(a0),d0
		andi.w	#-128,d0
		sub.w	(Camera_X_pos_coarse_back).w,d0
		cmpi.w	#128+320+192,d0
		bhi.s	Go_Delete_SpriteSlotted
		bra.w	Draw_Sprite

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
		move.b	$3B(a0),d0
		movea.w	$3C(a0),a1
		bclr	d0,(a1)
		rts
; End of function Remove_From_TrackingSlot

; =============== S U B R O U T I N E =======================================

Sprite_CheckDeleteTouchSlotted:
		tst.b	status(a0)
		bmi.s	Go_Delete_SpriteSlotted3
		move.w	x_pos(a0),d0
		andi.w	#-128,d0
		sub.w	(Camera_X_pos_coarse_back).w,d0
		cmpi.w	#128+320+192,d0
		bhi.s	Go_Delete_SpriteSlotted
		bsr.w	Add_SpriteToCollisionResponseList
		bra.w	Draw_Sprite
; ---------------------------------------------------------------------------

Go_Delete_SpriteSlotted3:
		move.l	#Delete_Current_Sprite,address(a0)
		bra.s	Remove_From_TrackingSlot

; =============== S U B R O U T I N E =======================================

Obj_WaitOffscreen:
		move.l	#Map_Offscreen,mappings(a0)
		bset	#2,render_flags(a0)
		move.b	#64/2,width_pixels(a0)
		move.b	#64/2,height_pixels(a0)
		move.l	(sp)+,$34(a0)
		move.l	#+,address(a0)
+		tst.b	render_flags(a0)
		bmi.s	+
		bra.w	Sprite_OnScreen_Test
; ---------------------------------------------------------------------------
+		move.l	$34(a0),address(a0)			; Restore normal object operation when onscreen
		rts
; End of function Obj_WaitOffscreen
; ---------------------------------------------------------------------------
Map_Offscreen:	dc.w 0
