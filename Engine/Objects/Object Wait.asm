; ---------------------------------------------------------------------------
; Wait and jump to subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_Wait:
		subq.w	#1,wait_timer(a0)						; subtract 1
		bpl.s	Obj_WaitRun.return						; if timer has not ended, branch

Obj_Jump:
		movea.l	objoff_34(a0),a1
		jmp	(a1)

; =============== S U B R O U T I N E =======================================

Obj_WaitRun:
		tst.w wait_timer(a0)							; is timer over?
		bmi.s	.return								; if yes, branch
		subq.w	#1,wait_timer(a0)						; subtract 1
		addq.w	#4,sp								; don't run the code after the call to this routine

.return
		rts

; =============== S U B R O U T I N E =======================================

ObjCheckFloorDist_DoRoutine:
		tst.w	y_vel(a0)							; is object falling down?
		bmi.s	.return								; if not, branch
		bsr.w	ObjCheckFloorDist
		tst.w	d1
		bmi.s	.jump
		beq.s	.jump

.return
		rts
; ---------------------------------------------------------------------------

.jump
		add.w	d1,y_pos(a0)
		movea.l	objoff_34(a0),a1
		jmp	(a1)

; =============== S U B R O U T I N E =======================================

ObjCheckCeilingDist_DoRoutine:
		tst.w	y_vel(a0)							; is object falling upwards?
		bmi.s	.return								; if not, branch
		bsr.w	ObjCheckCeilingDist
		tst.w	d1
		bmi.s	.jump
		beq.s	.jump

.return
		rts
; ---------------------------------------------------------------------------

.jump
		sub.w	d1,y_pos(a0)
		movea.l	objoff_34(a0),a1
		jmp	(a1)

; =============== S U B R O U T I N E =======================================

ObjCheckFloorDist2_DoRoutine:
		move.w	x_vel(a0),d3
		ext.l	d3
		asl.l	#8,d3
		add.l	x_pos(a0),d3
		swap	d3
		bsr.w	ObjCheckFloorDist2
		cmpi.w	#-1,d1
		blt.s	.jump
		cmpi.w	#12,d1
		bge.s	.jump
		add.w	d1,y_pos(a0)
		moveq	#0,d0
		rts
; ---------------------------------------------------------------------------

.jump
		movea.l	objoff_34(a0),a1
		jsr	(a1)
		moveq	#1,d0
		rts

; =============== S U B R O U T I N E =======================================

ObjCheckRightWallDist_DoRoutine:
		bsr.w	ObjCheckRightWallDist
		tst.w	d1
		bpl.s	ObjCheckCeilingDist_DoRoutine.return

		; jump
		add.w	d1,x_pos(a0)
		movea.l	objoff_34(a0),a1
		jmp	(a1)

; =============== S U B R O U T I N E =======================================

ObjCheckLeftWallDist_DoRoutine:
		bsr.w	ObjCheckLeftWallDist
		tst.w	d1
		bpl.s	ObjCheckCeilingDist_DoRoutine.return

		; jump
		add.w	d1,x_pos(a0)
		movea.l	objoff_34(a0),a1
		jmp	(a1)
