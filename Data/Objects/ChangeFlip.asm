
; =============== S U B R O U T I N E =======================================

Change_FlipX:
		bclr	#0,render_flags(a0)
		tst.w	d0
		beq.s	+
		bset	#0,render_flags(a0)
+		rts
; End of function Change_FlipX

; =============== S U B R O U T I N E =======================================

Change_FlipX2:
		bclr	#0,render_flags(a0)
		tst.w	d0
		bne.s	+
		bset	#0,render_flags(a0)
+		rts
; End of function Change_FlipX2

; =============== S U B R O U T I N E =======================================

Change_FlipXWithVelocity:
		bclr	#0,render_flags(a0)
		tst.w	x_vel(a0)
		bmi.s	+
		bset	#0,render_flags(a0)
+		rts
; End of function Change_FlipXWithVelocity

; =============== S U B R O U T I N E =======================================

Change_FlipXWithVelocity2:
		bclr	#0,render_flags(a0)
		tst.w	x_vel(a0)
		bpl.s	+
		bset	#0,render_flags(a0)
+		rts
; End of function Change_FlipXWithVelocity2

; =============== S U B R O U T I N E =======================================

Change_FlipXUseParent:
		movea.w	parent3(a0),a1
		bclr	#0,render_flags(a0)
		btst	#0,render_flags(a1)
		beq.s	+
		bset	#0,render_flags(a0)
+		rts
; End of function Change_FlipXUseParent

; =============== S U B R O U T I N E =======================================

Change_FlipYUseParent:
		movea.w	parent3(a0),a1
		bclr	#1,render_flags(a0)
		btst	#1,render_flags(a1)
		beq.s	+
		bset	#1,render_flags(a0)
+		rts
; End of function Change_FlipXUseParent

; =============== S U B R O U T I N E =======================================

Change_VelocityWithFlipX:
		btst	#0,render_flags(a0)
		beq.s	+
		neg.w	d0
+		move.w	d0,x_vel(a0)
		rts
; End of function Change_VelocityWithFlipX

; =============== S U B R O U T I N E =======================================

Change_VelocityWithFlipXUseParent:
		movea.w	parent3(a0),a1
		btst	#0,render_flags(a1)
		beq.s	+
		neg.w	d0
+		move.w	d0,x_vel(a0)
		rts
; End of function Change_VelocityWithFlipXUseParent
