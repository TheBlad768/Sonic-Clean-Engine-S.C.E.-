; ---------------------------------------------------------------------------
; Change x flip subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Change_FlipX:
		bclr	#render_flags.x_flip,render_flags(a0)				; clear x flip bit
		tst.w	d0								; changed by Find_SonicObject
		beq.s	.left
		bset	#render_flags.x_flip,render_flags(a0)				; set x flip bit

.left
		rts

; ---------------------------------------------------------------------------
; Change x flip 2 subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Change_FlipX2:
		bclr	#render_flags.x_flip,render_flags(a0)				; clear x flip bit
		tst.w	d0								; changed by Find_SonicObject
		bne.s	.right
		bset	#render_flags.x_flip,render_flags(a0)				; set x flip bit

.right
		rts

; ---------------------------------------------------------------------------
; Change y flip subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Change_FlipY:
		bclr	#render_flags.y_flip,render_flags(a0)				; clear y flip bit
		tst.w	d1								; changed by Find_SonicObject
		beq.s	.up
		bset	#render_flags.y_flip,render_flags(a0)				; set y flip bit

.up
		rts

; ---------------------------------------------------------------------------
; Change y flip 2 subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Change_FlipY2:
		bclr	#render_flags.y_flip,render_flags(a0)				; clear y flip bit
		tst.w	d1								; changed by Find_SonicObject
		bne.s	.down
		bset	#render_flags.y_flip,render_flags(a0)				; set y flip bit

.down
		rts

; ---------------------------------------------------------------------------
; Change x flip with velocity subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Change_FlipXWithVelocity:
		bclr	#render_flags.x_flip,render_flags(a0)				; clear x flip bit
		tst.w	x_vel(a0)							; check x velocity
		bmi.s	.left								; left move
		bset	#render_flags.x_flip,render_flags(a0)				; set x flip bit

.left
		rts

; ---------------------------------------------------------------------------
; Change x flip with velocity 2 subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Change_FlipXWithVelocity2:
		bclr	#render_flags.x_flip,render_flags(a0)				; clear x flip bit
		tst.w	x_vel(a0)							; check x velocity
		bpl.s	.right								; right move
		bset	#render_flags.x_flip,render_flags(a0)				; set x flip bit

.right
		rts

; ---------------------------------------------------------------------------
; Change x flip use parent subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Change_FlipXUseParent:
		movea.w	parent3(a0),a1							; a1=parent object
		bclr	#render_flags.x_flip,render_flags(a0)				; clear x flip bit
		btst	#render_flags.x_flip,render_flags(a1)				; check parent's x flip bit
		beq.s	.notflipx							; branch, if parent not x flipped
		bset	#render_flags.x_flip,render_flags(a0)				; set x flip bit

.notflipx
		rts

; ---------------------------------------------------------------------------
; Change y flip use parent subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Change_FlipYUseParent:
		movea.w	parent3(a0),a1							; a1=parent object
		bclr	#render_flags.y_flip,render_flags(a0)				; clear y flip bit
		btst	#render_flags.y_flip,render_flags(a1)				; check parent's y flip bit
		beq.s	.notflipy							; branch, if parent not y flipped
		bset	#render_flags.y_flip,render_flags(a0)				; set y flip bit

.notflipy
		rts

; ---------------------------------------------------------------------------
; Change velocity with x flip subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Change_VelocityWithFlipX:
		btst	#render_flags.x_flip,render_flags(a0)				; check object's x flip bit
		beq.s	.notflipx							; branch, if object not x flipped
		neg.w	d0								; reverse x velocity

.notflipx
		move.w	d0,x_vel(a0)							; set x velocity
		rts

; ---------------------------------------------------------------------------
; Change velocity with x flip use parent subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Change_VelocityWithFlipXUseParent:
		movea.w	parent3(a0),a1							; a1=parent object
		btst	#render_flags.x_flip,render_flags(a1)				; check parent's x flip bit
		beq.s	.notflipx							; branch, if object not x flipped
		neg.w	d0								; reverse x velocity

.notflipx
		move.w	d0,x_vel(a0)							; set x velocity
		rts

; ---------------------------------------------------------------------------
; Set velx track Sonic subroutine subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Set_VelocityXTrackSonic:
		bsr.w	Find_SonicObject
		bclr	#render_flags.x_flip,render_flags(a0)				; clear x flip bit
		tst.w	d0								; changed by Find_SonicObject
		beq.s	.setxv
		neg.w	d4								; reverse x velocity
		bset	#render_flags.x_flip,render_flags(a0)				; set x flip bit

.setxv
		move.w	d4,x_vel(a0)							; set x velocity
		rts
