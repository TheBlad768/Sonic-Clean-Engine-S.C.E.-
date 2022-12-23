; ---------------------------------------------------------------------------
; Wait and jump to subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_Wait:
		tst.w	objoff_2E(a0)
		beq.s	Obj_Jump
		subq.w	#1,objoff_2E(a0)
		rts
; ---------------------------------------------------------------------------

Obj_Jump:
		movea.l	objoff_34(a0),a1
		jmp	(a1)

; =============== S U B R O U T I N E =======================================

ObjHitFloor_DoRoutine:
		tst.w	y_vel(a0)
		bmi.s	ObjHitFloor_DoRoutine_Return
		bsr.w	ObjCheckFloorDist
		tst.w	d1
		bmi.s	+
		beq.s	+

ObjHitFloor_DoRoutine_Return:
		rts
; ---------------------------------------------------------------------------
+		add.w	d1,y_pos(a0)
		movea.l	objoff_34(a0),a1
		jmp	(a1)

; =============== S U B R O U T I N E =======================================

ObjHitCeiling_DoRoutine:
		tst.w	y_vel(a0)
		bmi.s	ObjHitCeiling_DoRoutine_Return
		bsr.w	ObjCheckCeilingDist
		tst.w	d1
		bmi.s	+
		beq.s	+

ObjHitCeiling_DoRoutine_Return:
		rts
; ---------------------------------------------------------------------------
+		sub.w	d1,y_pos(a0)
		movea.l	objoff_34(a0),a1
		jmp	(a1)

; =============== S U B R O U T I N E =======================================

ObjHitFloor2_DoRoutine:
		move.w	x_vel(a0),d3
		ext.l	d3
		asl.l	#8,d3
		add.l	x_pos(a0),d3
		swap	d3
		bsr.w	ObjCheckFloorDist2
		cmpi.w	#-1,d1
		blt.s		+
		cmpi.w	#12,d1
		bge.s	+
		add.w	d1,y_pos(a0)
		moveq	#0,d0
		rts
; ---------------------------------------------------------------------------
+		movea.l	objoff_34(a0),a1
		jsr	(a1)
		moveq	#1,d0
		rts

; =============== S U B R O U T I N E =======================================

ObjHitWall_DoRoutine:
		bsr.w	ObjCheckRightWallDist
		tst.w	d1
		bpl.s	ObjHitFloor_DoRoutine_Return
		add.w	d1,x_pos(a0)
		movea.l	objoff_34(a0),a1
		jmp	(a1)

; =============== S U B R O U T I N E =======================================

ObjHitWall2_DoRoutine:
		bsr.w	ObjCheckLeftWallDist
		tst.w	d1
		bpl.s	ObjHitFloor_DoRoutine_Return
		add.w	d1,x_pos(a0)
		movea.l	objoff_34(a0),a1
		jmp	(a1)
