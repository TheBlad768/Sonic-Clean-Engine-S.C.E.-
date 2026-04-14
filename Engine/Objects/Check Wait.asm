; ---------------------------------------------------------------------------
; Wait and jump to subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_Wait:
		tst.w wait_timer(a0)							; is timer over?
		bmi.s	.jump								; if yes, branch
		subq.w	#1,wait_timer(a0)						; decrement timer
		bmi.s	.jump								; if timer has run out, branch
		rts
; ---------------------------------------------------------------------------

.jump

		; jump to custom code
		movea.l	wait_addr(a0),a1
		jmp	(a1)

; ---------------------------------------------------------------------------
; Wait to subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_WaitRun:
		tst.w wait_timer(a0)							; is timer over?
		bmi.s	.return								; if yes, branch
		subq.w	#1,wait_timer(a0)						; decrement timer
		addq.w	#4,sp								; don't run the code after the call to this routine

.return
		rts

; ---------------------------------------------------------------------------
; Check floor dist and jump to subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

ObjCheckFloorDist_DoRoutine:
		tst.w	y_vel(a0)							; is object falling down?
		bmi.s	.return								; if not, branch
		bsr.w	ObjCheckFloorDist						; "
		tst.w	d1								; is object in the ground?
		bmi.s	.jump								; if so, branch
		beq.s	.jump								; "

.return
		rts
; ---------------------------------------------------------------------------

.jump
		add.w	d1,y_pos(a0)							; move object out of the ground

		; jump to custom code
		movea.l	wait_addr(a0),a1
		jmp	(a1)

; ---------------------------------------------------------------------------
; Check ceiling dist and jump to subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

ObjCheckCeilingDist_DoRoutine:
		tst.w	y_vel(a0)							; is object falling upwards?
		bmi.s	.return								; if not, branch
		bsr.w	ObjCheckCeilingDist						; "
		tst.w	d1								; is object in the ground (ceiling)?
		bmi.s	.jump								; if so, branch
		beq.s	.jump								; "

.return
		rts
; ---------------------------------------------------------------------------

.jump
		sub.w	d1,y_pos(a0)							; move object out of the ground

		; jump to custom code
		movea.l	wait_addr(a0),a1
		jmp	(a1)

; ---------------------------------------------------------------------------
; Check floor dist 2 and jump to subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

ObjCheckFloorDist2_DoRoutine:

		; move object
		move.w	x_vel(a0),d3							; load x speed
		ext.l	d3								; sign extension
		asl.l	#8,d3								; shift velocity to line up with the middle 16 bits of the 32-bit position
		add.l	x_pos(a0),d3							; add to x-axis position ; note this affects the subpixel position x_sub(a0) = 2+x_pos(a0)

		; check floor
		swap	d3								; long to word
		bsr.w	ObjCheckFloorDist2						; "
		cmpi.w	#-1,d1
		blt.s	.jump
		cmpi.w	#12,d1
		bge.s	.jump
		add.w	d1,y_pos(a0)
		moveq	#0,d0								; set flag to 0
		rts
; ---------------------------------------------------------------------------

.jump

		; jump to custom code
		movea.l	wait_addr(a0),a1
		jsr	(a1)
		moveq	#1,d0								; set flag to 1

.return
		rts

; ---------------------------------------------------------------------------
; Check right wall dist and jump to subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

ObjCheckRightWallDist_DoRoutine:
		bsr.w	ObjCheckRightWallDist						; "
		tst.w	d1								; has the object hit a wall?
		bpl.s	ObjCheckFloorDist2_DoRoutine.return				; if not, branch
		add.w	d1,x_pos(a0)							; move object out of the wall

		; jump to custom code
		movea.l	wait_addr(a0),a1
		jmp	(a1)

; ---------------------------------------------------------------------------
; Check left wall dist and jump to subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

ObjCheckLeftWallDist_DoRoutine:
		bsr.w	ObjCheckLeftWallDist						; "
		tst.w	d1								; has the object hit a wall?
		bpl.s	ObjCheckFloorDist2_DoRoutine.return				; if not, branch
		add.w	d1,x_pos(a0)							; move object out of the wall

		; jump to custom code
		movea.l	wait_addr(a0),a1
		jmp	(a1)

; ---------------------------------------------------------------------------
; Wait delay and jump to subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_WaitNewDelay:
		subq.w	#1,wait_timer(a0)						; decrement timer
		bmi.s	.jump								; if timer has run out, branch
		bra.w	Draw_Sprite
; ---------------------------------------------------------------------------

.jump
		bclr	#render_flags.on_screen,render_flags(a0)
		move.w	#(2*60)-1,wait_timer(a0)					; set timer

		; jump to custom code
		movea.l	wait_addr(a0),a1
		jmp	(a1)

; ---------------------------------------------------------------------------
; Wait fade and jump to subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_WaitFadeToLevelMusic:
		subq.w	#1,wait_timer(a0)						; decrement timer
		bmi.s	.jump								; if timer has run out, branch
		bra.w	Draw_Sprite
; ---------------------------------------------------------------------------

.jump
		bclr	#render_flags.on_screen,render_flags(a0)
		move.w	#(2*60)-1,wait_timer(a0)					; set timer

		; create
		bsr.w	Create_New_Object
		bne.s	.notfree
		move.l	#Obj_Song_Fade_ToLevelMusic,code_addr(a1)

.notfree

		; jump to custom code
		movea.l	wait_addr(a0),a1
		jmp	(a1)
