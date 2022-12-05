
; =============== S U B R O U T I N E =======================================

Swing_Setup1:
		move.w	#$C0,d0
		move.w	d0,$3E(a0)
		move.w	d0,y_vel(a0)
		move.w	#$10,$40(a0)
		bclr	#0,$38(a0)
		rts

; =============== S U B R O U T I N E =======================================

Swing_Setup2:
		move.w	#$200,d0
		move.w	d0,$3A(a0)
		move.w	d0,x_vel(a0)
		move.w	#$20,$3C(a0)
		bclr	#3,$38(a0)
		rts

; =============== S U B R O U T I N E =======================================

Swing_UpAndDown_Count:
		bsr.s	Swing_UpAndDown
		tst.w	d3
		beq.s	+
		move.b	$39(a0),d2
		subq.b	#1,d2
		move.b	d2,$39(a0)
		bmi.s	++
		moveq	#0,d0
+		rts
; ---------------------------------------------------------------------------
+		moveq	#1,d0
		rts

; =============== S U B R O U T I N E =======================================

Swing_UpAndDown:
		move.w	$40(a0),d0	; Acceleration
		move.w	y_vel(a0),d1	; Velocity
		move.w	$3E(a0),d2	; Maximum acceleration before "swinging"
		moveq	#0,d3
		btst	#0,$38(a0)
		bne.s	+
		neg.w	d0			; Apply upward acceleration
		add.w	d0,d1
		neg.w	d2
		cmp.w	d2,d1
		bgt.s	++
		bset	#0,$38(a0)
		neg.w	d0
		neg.w	d2
		moveq	#1,d3
+		add.w	d0,d1		; Apply downward acceleration
		cmp.w	d2,d1
		blt.s		+
		bclr	#0,$38(a0)
		neg.w	d0
		add.w	d0,d1
		moveq	#1,d3
+		move.w	d1,y_vel(a0)
		rts

; =============== S U B R O U T I N E =======================================

Swing_LeftAndRight:
		move.w	$3C(a0),d0
		move.w	x_vel(a0),d1
		move.w	$3A(a0),d2
		moveq	#0,d3
		btst	#3,$38(a0)
		bne.s	+
		neg.w	d0
		add.w	d0,d1
		neg.w	d2
		cmp.w	d2,d1
		bgt.s	++
		bset	#3,$38(a0)
		neg.w	d0
		neg.w	d2
		moveq	#1,d3
+		add.w	d0,d1
		cmp.w	d2,d1
		blt.s		+
		bclr	#3,$38(a0)
		neg.w	d0
		add.w	d0,d1
		moveq	#1,d3
+		move.w	d1,x_vel(a0)
		rts

; =============== S U B R O U T I N E =======================================

Swing_UpAndDown_Slow:
		move.b	angle(a0),d0
		addq.b	#2,angle(a0)
		bsr.w	GetSineCosine
		asr.w	#2,d0
		move.w	d0,y_vel(a0)
		rts

; =============== S U B R O U T I N E =======================================

Refresh_ChildPosition:
		movea.w	parent3(a0),a1

Refresh_ChildPosition2:
		move.w	x_pos(a1),d0
		move.b	child_dx(a0),d1
		ext.w	d1
		add.w	d1,d0
		move.w	d0,x_pos(a0)
		move.w	y_pos(a1),d0
		move.b	child_dy(a0),d1
		ext.w	d1
		add.w	d1,d0
		move.w	d0,y_pos(a0)
		rts

; =============== S U B R O U T I N E =======================================

Refresh_Child_X_Position:
		movea.w	parent3(a0),a1

Refresh_Child_X_Position2:
		move.w	x_pos(a1),d0
		move.b	child_dx(a0),d1
		ext.w	d1
		add.w	d1,d0
		move.w	d0,x_pos(a0)
		rts

; =============== S U B R O U T I N E =======================================

Refresh_Child_Y_Position:
		movea.w	parent3(a0),a1

Refresh_Child_Y_Position2:
		move.w	y_pos(a1),d0
		move.b	child_dy(a0),d1
		ext.w	d1
		add.w	d1,d0
		move.w	d0,y_pos(a0)
		rts

; =============== S U B R O U T I N E =======================================

Refresh_ChildPositionAdjusted:
		movea.w	parent3(a0),a1

Refresh_ChildPositionAdjusted2:
		move.w	x_pos(a1),d0
		move.b	child_dx(a0),d1
		ext.w	d1
		bclr	#0,render_flags(a0)
		btst	#0,render_flags(a1)
		beq.s	+
		neg.w	d1
		bset	#0,render_flags(a0)
+		add.w	d1,d0
		move.w	d0,x_pos(a0)
		move.w	y_pos(a1),d0
		move.b	child_dy(a0),d1
		ext.w	d1
		bclr	#1,render_flags(a0)
		btst	#1,render_flags(a1)
		beq.s	+
		neg.w	d1
		bset	#1,render_flags(a0)
+		add.w	d1,d0
		move.w	d0,y_pos(a0)
		rts

; =============== S U B R O U T I N E =======================================

Refresh_Child_X_PositionAdjusted:
		movea.w	parent3(a0),a1

Refresh_Child_X_PositionAdjusted2:
		move.w	x_pos(a1),d0
		move.b	child_dx(a0),d1
		ext.w	d1
		bclr	#0,render_flags(a0)
		btst	#0,render_flags(a1)
		beq.s	+
		neg.w	d1
		bset	#0,render_flags(a0)
+		add.w	d1,d0
		move.w	d0,x_pos(a0)
		rts

; =============== S U B R O U T I N E =======================================

Refresh_Child_Y_PositionAdjusted:
		movea.w	parent3(a0),a1

Refresh_Child_Y_PositionAdjusted2:
		move.w	y_pos(a1),d0
		move.b	child_dy(a0),d1
		ext.w	d1
		bclr	#1,render_flags(a0)
		btst	#1,render_flags(a1)
		beq.s	+
		neg.w	d1
		bset	#1,render_flags(a0)
+		add.w	d1,d0
		move.w	d0,y_pos(a0)
		rts

; =============== S U B R O U T I N E =======================================

Refresh_ChildPositionAdjusted_Animate:
		movea.w	parent3(a0),a1

Refresh_ChildPositionAdjusted_Animate2:
		move.w	x_pos(a1),d0
		move.b	child_dx(a0),d1
		ext.w	d1
		bclr	#0,status(a0)
		btst	#0,status(a1)
		beq.s	+
		neg.w	d1
		bset	#0,status(a0)
+		add.w	d1,d0
		move.w	d0,x_pos(a0)
		move.w	y_pos(a1),d0
		move.b	child_dy(a0),d1
		ext.w	d1
		bclr	#1,status(a0)
		btst	#1,status(a1)
		beq.s	+
		neg.w	d1
		bset	#1,status(a0)
+		add.w	d1,d0
		move.w	d0,y_pos(a0)
		rts

; =============== S U B R O U T I N E =======================================

Refresh_Child_X_PositionAdjusted_Animate:
		movea.w	parent3(a0),a1

Refresh_Child_X_PositionAdjusted_Animate2:
		move.w	x_pos(a1),d0
		move.b	child_dx(a0),d1
		ext.w	d1
		bclr	#0,status(a0)
		btst	#0,status(a1)
		beq.s	+
		neg.w	d1
		bset	#0,status(a0)
+		add.w	d1,d0
		move.w	d0,x_pos(a0)
		rts

; =============== S U B R O U T I N E =======================================

Refresh_Child_Y_PositionAdjusted_Animate:
		movea.w	parent3(a0),a1

Refresh_Child_Y_PositionAdjusted_Animate2:
		move.w	y_pos(a1),d0
		move.b	child_dy(a0),d1
		ext.w	d1
		bclr	#1,status(a0)
		btst	#1,status(a1)
		beq.s	+
		neg.w	d1
		bset	#1,status(a0)
+		add.w	d1,d0
		move.w	d0,y_pos(a0)
		rts

; ---------------------------------------------------------------------------
; Set velx track Sonic subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Set_VelocityXTrackSonic:
		bsr.w	Find_SonicObject
		bclr	#0,render_flags(a0)
		tst.w	d0
		beq.s	+
		neg.w	d4
		bset	#0,render_flags(a0)
+		move.w	d4,x_vel(a0)
		rts

; ---------------------------------------------------------------------------
; Chase object subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Chase_Object:
		move.w	d0,d2
		neg.w	d2
		move.w	d1,d3
		move.w	x_pos(a0),d4
		cmp.w	x_pos(a1),d4
		seq	d5
		beq.s	++
		bcs.s	+
		neg.w	d1
+		move.w	x_vel(a0),d4
		add.w	d1,d4
		cmp.w	d2,d4
		blt.s		+
		cmp.w	d0,d4
		bgt.s	+
		move.w	d4,x_vel(a0)
+		move.w	y_pos(a0),d4
		cmp.w	y_pos(a1),d4
		beq.s	+++
		bcs.s	+
		neg.w	d3
+		move.w	y_vel(a0),d4
		add.w	d3,d4
		cmp.w	d2,d4
		blt.s		+
		cmp.w	d0,d4
		bgt.s	+
		move.w	d4,y_vel(a0)
+		rts
; ---------------------------------------------------------------------------
+		tst.b	d5
		beq.s	+
		clr.l	x_vel(a0)
+		rts

; ---------------------------------------------------------------------------
; Chase xpos object subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Chase_ObjectXOnly:
		move.w	d0,d2
		neg.w	d2
		move.w	x_pos(a1),d3
		move.b	child_dx(a0),d4
		ext.w	d4
		add.w	d4,d3
		cmp.w	x_pos(a0),d3
		bhs.s	+
		neg.w	d1
+		move.w	x_vel(a0),d3
		add.w	d1,d3
		cmp.w	d2,d3
		blt.s		+
		cmp.w	d0,d3
		bgt.s	+
		move.w	d3,x_vel(a0)
+		rts

; ---------------------------------------------------------------------------
; Chase ypos object subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Chase_ObjectYOnly:
		move.w	d0,d2
		neg.w	d2
		move.w	y_pos(a1),d3
		move.b	child_dy(a0),d4
		ext.w	d4
		add.w	d4,d3
		cmp.w	y_pos(a0),d3
		bhs.s	+
		neg.w	d1
+		move.w	y_vel(a0),d3
		add.w	d1,d3
		cmp.w	d2,d3
		blt.s		+
		cmp.w	d0,d3
		bgt.s	+
		move.w	d3,y_vel(a0)
+		rts

; ---------------------------------------------------------------------------
; Chase object 2 subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Chase_Object2:
		move.w	d0,d2
		neg.w	d2
		move.w	d1,d3
		move.w	x_pos(a1),d6
		move.b	child_dx(a0),d4
		ext.w	d4
		add.w	d4,d6
		cmp.w	x_pos(a0),d6
		seq	d5
		beq.s	++
		bcc.s	+
		neg.w	d1
+		move.w	x_vel(a0),d4
		add.w	d1,d4
		cmp.w	d2,d4
		blt.s		+
		cmp.w	d0,d4
		bgt.s	+
		move.w	d4,x_vel(a0)
+		move.w	y_pos(a1),d6
		move.b	child_dy(a0),d4
		ext.w	d4
		add.w	d4,d6
		cmp.w	y_pos(a0),d6
		beq.s	+++
		bcc.s	+
		neg.w	d3
+		move.w	y_vel(a0),d4
		add.w	d3,d4
		cmp.w	d2,d4
		blt.s		+
		cmp.w	d0,d4
		bgt.s	+
		move.w	d4,y_vel(a0)
+		rts
; ---------------------------------------------------------------------------
+		tst.b	d5
		beq.s	+
		clr.l	x_vel(a0)
+		rts

; ---------------------------------------------------------------------------
; Shot object subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Shot_Object:
Shot_ObjectInSonic:
		lea	(Player_1).w,a1

Shot_Object_2:
		moveq	#0,d0
		move.w	x_pos(a1),d0
		moveq	#0,d1
		move.w	y_pos(a1),d1

Shot_Object_3:
		sub.w	x_pos(a0),d0
		smi	d2
		bpl.s	+
		neg.w	d0
+		sub.w	y_pos(a0),d1
		smi	d3
		bpl.s	+
		neg.w	d1
+		cmp.w	d1,d0
		scs	d4
		beq.s	loc_8621A
		bcc.s	+
		exg	d0,d1
+		swap	d1
		divu.w	d0,d1
-		move.w	#256,d0
		lsl.w	d5,d0
		moveq	#8,d6
		sub.w	d5,d6
		lsr.w	d6,d1
-		tst.b	d4
		beq.s	+
		exg	d0,d1
+		tst.b	d2
		beq.s	+
		neg.w	d0
+		tst.b	d3
		beq.s	+
		neg.w	d1
+		move.w	d0,x_vel(a0)
		move.w	d1,y_vel(a0)
		rts
; ---------------------------------------------------------------------------

loc_8621A:
		tst.w	d0
		beq.s	--
		move.w	#256,d0
		lsl.w	d5,d0
		move.w	#256,d1
		lsl.w	d5,d1
		bra.s	-

; =============== S U B R O U T I N E =======================================

sub_8619A:
		move.w	objoff_30(a0),d2
		move.w	objoff_34(a0),d3
		moveq	#0,d0
		move.b	objoff_40(a0),d0
		addq.w	#4,d0
		move.l	#$100,d4
		divu.w	d0,d4
		sub.w	d4,d2
		sub.w	d4,d3
		move.w	d2,x_pos(a0)
		move.w	d3,y_pos(a0)
		rts
