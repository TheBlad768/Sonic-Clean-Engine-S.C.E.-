; ---------------------------------------------------------------------------
; Change flip
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Change_FlipX:
		bclr	#render_flags.x_flip,render_flags(a0)
		tst.w	d0
		beq.s	.left
		bset	#render_flags.x_flip,render_flags(a0)

.left
		rts

; =============== S U B R O U T I N E =======================================

Change_FlipX2:
		bclr	#render_flags.x_flip,render_flags(a0)
		tst.w	d0
		bne.s	.right
		bset	#render_flags.x_flip,render_flags(a0)

.right
		rts

; =============== S U B R O U T I N E =======================================

Change_FlipY:
		bclr	#render_flags.y_flip,render_flags(a0)
		tst.w	d1
		beq.s	.up
		bset	#render_flags.y_flip,render_flags(a0)

.up
		rts

; =============== S U B R O U T I N E =======================================

Change_FlipY2:
		bclr	#render_flags.y_flip,render_flags(a0)
		tst.w	d1
		bne.s	.down
		bset	#render_flags.y_flip,render_flags(a0)

.down
		rts

; =============== S U B R O U T I N E =======================================

Change_FlipXWithVelocity:
		bclr	#render_flags.x_flip,render_flags(a0)
		tst.w	x_vel(a0)
		bmi.s	.left
		bset	#render_flags.x_flip,render_flags(a0)

.left
		rts

; =============== S U B R O U T I N E =======================================

Change_FlipXWithVelocity2:
		bclr	#render_flags.x_flip,render_flags(a0)
		tst.w	x_vel(a0)
		bpl.s	.right
		bset	#render_flags.x_flip,render_flags(a0)

.right
		rts

; =============== S U B R O U T I N E =======================================

Change_FlipXUseParent:
		movea.w	parent3(a0),a1							; a1=parent object
		bclr	#render_flags.x_flip,render_flags(a0)
		btst	#render_flags.x_flip,render_flags(a1)
		beq.s	.notflipx
		bset	#render_flags.x_flip,render_flags(a0)

.notflipx
		rts

; =============== S U B R O U T I N E =======================================

Change_FlipYUseParent:
		movea.w	parent3(a0),a1							; a1=parent object
		bclr	#render_flags.y_flip,render_flags(a0)
		btst	#render_flags.y_flip,render_flags(a1)
		beq.s	.notflipy
		bset	#render_flags.y_flip,render_flags(a0)

.notflipy
		rts

; =============== S U B R O U T I N E =======================================

Change_VelocityWithFlipX:
		btst	#render_flags.x_flip,render_flags(a0)
		beq.s	.notflipx
		neg.w	d0

.notflipx
		move.w	d0,x_vel(a0)
		rts

; =============== S U B R O U T I N E =======================================

Change_VelocityWithFlipXUseParent:
		movea.w	parent3(a0),a1							; a1=parent object
		btst	#render_flags.x_flip,render_flags(a1)
		beq.s	.notflipx
		neg.w	d0

.notflipx
		move.w	d0,x_vel(a0)
		rts

; ---------------------------------------------------------------------------
; Set velx track Sonic subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Set_VelocityXTrackSonic:
		bsr.w	Find_SonicObject
		bclr	#render_flags.x_flip,render_flags(a0)
		tst.w	d0
		beq.s	.setxv
		neg.w	d4
		bset	#render_flags.x_flip,render_flags(a0)

.setxv
		move.w	d4,x_vel(a0)
		rts
