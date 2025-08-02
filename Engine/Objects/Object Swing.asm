; ---------------------------------------------------------------------------
; Object swing subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Swing_Setup1:
		move.w	#$C0,d0
		move.w	d0,objoff_3E(a0)
		move.w	d0,y_vel(a0)
		move.w	#$10,objoff_40(a0)
		bclr	#0,objoff_38(a0)
		rts

; =============== S U B R O U T I N E =======================================

Swing_Setup2:
		move.w	#$200,d0
		move.w	d0,objoff_3A(a0)
		move.w	d0,x_vel(a0)
		move.w	#$20,objoff_3C(a0)
		bclr	#3,objoff_38(a0)
		rts

; =============== S U B R O U T I N E =======================================

Swing_UpAndDown_Count:
		bsr.s	Swing_UpAndDown
		tst.w	d3
		beq.s	.return
		move.b	objoff_39(a0),d2
		subq.b	#1,d2
		move.b	d2,objoff_39(a0)
		bmi.s	.end
		moveq	#0,d0

.return
		rts
; ---------------------------------------------------------------------------

.end
		moveq	#1,d0
		rts

; =============== S U B R O U T I N E =======================================

Swing_UpAndDown:
		move.w	objoff_40(a0),d0						; acceleration
		move.w	y_vel(a0),d1							; velocity
		move.w	objoff_3E(a0),d2						; maximum acceleration before "swinging"
		moveq	#0,d3
		btst	#0,objoff_38(a0)
		bne.s	.check
		neg.w	d0								; apply upward acceleration
		add.w	d0,d1
		neg.w	d2
		cmp.w	d2,d1
		bgt.s	.set
		bset	#0,objoff_38(a0)
		neg.w	d0
		neg.w	d2
		moveq	#1,d3

.check
		add.w	d0,d1								; apply downward acceleration
		cmp.w	d2,d1
		blt.s	.set
		bclr	#0,objoff_38(a0)
		neg.w	d0
		add.w	d0,d1
		moveq	#1,d3

.set
		move.w	d1,y_vel(a0)
		rts

; =============== S U B R O U T I N E =======================================

Swing_LeftAndRight:
		move.w	objoff_3C(a0),d0
		move.w	x_vel(a0),d1
		move.w	objoff_3A(a0),d2
		moveq	#0,d3
		btst	#3,objoff_38(a0)
		bne.s	.check
		neg.w	d0
		add.w	d0,d1
		neg.w	d2
		cmp.w	d2,d1
		bgt.s	.set
		bset	#3,objoff_38(a0)
		neg.w	d0
		neg.w	d2
		moveq	#1,d3

.check
		add.w	d0,d1
		cmp.w	d2,d1
		blt.s	.set
		bclr	#3,objoff_38(a0)
		neg.w	d0
		add.w	d0,d1
		moveq	#1,d3

.set
		move.w	d1,x_vel(a0)
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
		movea.w	parent3(a0),a1							; a1=parent object

.skipp
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
		movea.w	parent3(a0),a1							; a1=parent object

.skipp
		move.w	x_pos(a1),d0
		move.b	child_dx(a0),d1
		ext.w	d1
		add.w	d1,d0
		move.w	d0,x_pos(a0)
		rts

; =============== S U B R O U T I N E =======================================

Refresh_Child_Y_Position:
		movea.w	parent3(a0),a1							; a1=parent object

.skipp
		move.w	y_pos(a1),d0
		move.b	child_dy(a0),d1
		ext.w	d1
		add.w	d1,d0
		move.w	d0,y_pos(a0)
		rts

; =============== S U B R O U T I N E =======================================

Refresh_ChildPositionAdjusted:
		movea.w	parent3(a0),a1							; a1=parent object

.skipp
		move.w	x_pos(a1),d0
		move.b	child_dx(a0),d1
		ext.w	d1
		bclr	#render_flags.x_flip,render_flags(a0)
		btst	#render_flags.x_flip,render_flags(a1)
		beq.s	.notflipx
		neg.w	d1
		bset	#render_flags.x_flip,render_flags(a0)

.notflipx
		add.w	d1,d0
		move.w	d0,x_pos(a0)
		move.w	y_pos(a1),d0
		move.b	child_dy(a0),d1
		ext.w	d1
		bclr	#render_flags.y_flip,render_flags(a0)
		btst	#render_flags.y_flip,render_flags(a1)
		beq.s	.notflipy
		neg.w	d1
		bset	#render_flags.y_flip,render_flags(a0)

.notflipy
		add.w	d1,d0
		move.w	d0,y_pos(a0)
		rts

; =============== S U B R O U T I N E =======================================

Refresh_Child_X_PositionAdjusted:
		movea.w	parent3(a0),a1							; a1=parent object

.skipp
		move.w	x_pos(a1),d0
		move.b	child_dx(a0),d1
		ext.w	d1
		bclr	#render_flags.x_flip,render_flags(a0)
		btst	#render_flags.x_flip,render_flags(a1)
		beq.s	.notflipx
		neg.w	d1
		bset	#render_flags.x_flip,render_flags(a0)

.notflipx
		add.w	d1,d0
		move.w	d0,x_pos(a0)
		rts

; =============== S U B R O U T I N E =======================================

Refresh_Child_Y_PositionAdjusted:
		movea.w	parent3(a0),a1							; a1=parent object

.skipp
		move.w	y_pos(a1),d0
		move.b	child_dy(a0),d1
		ext.w	d1
		bclr	#render_flags.y_flip,render_flags(a0)
		btst	#render_flags.y_flip,render_flags(a1)
		beq.s	.notflipy
		neg.w	d1
		bset	#render_flags.y_flip,render_flags(a0)

.notflipy
		add.w	d1,d0
		move.w	d0,y_pos(a0)
		rts

; =============== S U B R O U T I N E =======================================

Refresh_ChildPositionAdjusted_Animate:
		movea.w	parent3(a0),a1							; a1=parent object

.skipp
		move.w	x_pos(a1),d0
		move.b	child_dx(a0),d1
		ext.w	d1
		bclr	#render_flags.x_flip,status(a0)
		bclr	#render_flags.x_flip,render_flags(a0)
		btst	#render_flags.x_flip,status(a1)
		beq.s	.notflipx
		neg.w	d1
		bset	#render_flags.x_flip,status(a0)
		bset	#render_flags.x_flip,render_flags(a0)

.notflipx
		add.w	d1,d0
		move.w	d0,x_pos(a0)
		move.w	y_pos(a1),d0
		move.b	child_dy(a0),d1
		ext.w	d1
		bclr	#render_flags.y_flip,status(a0)
		bclr	#render_flags.y_flip,render_flags(a0)
		btst	#render_flags.y_flip,status(a1)
		beq.s	.notflipy
		neg.w	d1
		bset	#render_flags.y_flip,status(a0)
		bset	#render_flags.y_flip,render_flags(a0)

.notflipy
		add.w	d1,d0
		move.w	d0,y_pos(a0)
		rts

; =============== S U B R O U T I N E =======================================

Refresh_Child_X_PositionAdjusted_Animate:
		movea.w	parent3(a0),a1							; a1=parent object

.skipp
		move.w	x_pos(a1),d0
		move.b	child_dx(a0),d1
		ext.w	d1
		bclr	#render_flags.x_flip,status(a0)
		bclr	#render_flags.x_flip,render_flags(a0)
		btst	#render_flags.x_flip,status(a1)
		beq.s	.notflipx
		neg.w	d1
		bset	#render_flags.x_flip,status(a0)
		bset	#render_flags.x_flip,render_flags(a0)

.notflipx
		add.w	d1,d0
		move.w	d0,x_pos(a0)
		rts

; =============== S U B R O U T I N E =======================================

Refresh_Child_Y_PositionAdjusted_Animate:
		movea.w	parent3(a0),a1							; a1=parent object

.skipp
		move.w	y_pos(a1),d0
		move.b	child_dy(a0),d1
		ext.w	d1
		bclr	#render_flags.y_flip,status(a0)
		bclr	#render_flags.y_flip,render_flags(a0)
		btst	#render_flags.y_flip,status(a1)
		beq.s	.notflipy
		neg.w	d1
		bset	#render_flags.y_flip,status(a0)
		bset	#render_flags.y_flip,render_flags(a0)

.notflipy
		add.w	d1,d0
		move.w	d0,y_pos(a0)
		rts

; =============== S U B R O U T I N E =======================================

Refresh_ChildPositionAdjusted_Animate2:
		movea.w	parent3(a0),a1							; a1=parent object

.skipp
		move.w	x_pos(a1),d0
		move.b	child_dx(a0),d1
		ext.w	d1
		bclr	#render_flags.x_flip,status(a0)
		bclr	#render_flags.x_flip,render_flags(a0)
		btst	#render_flags.x_flip,render_flags(a1)
		beq.s	.notflipx
		neg.w	d1
		bset	#render_flags.x_flip,status(a0)
		bset	#render_flags.x_flip,render_flags(a0)

.notflipx
		add.w	d1,d0
		move.w	d0,x_pos(a0)
		move.w	y_pos(a1),d0
		move.b	child_dy(a0),d1
		ext.w	d1
		bclr	#render_flags.y_flip,status(a0)
		bclr	#render_flags.y_flip,render_flags(a0)
		btst	#render_flags.y_flip,render_flags(a1)
		beq.s	.notflipy
		neg.w	d1
		bset	#render_flags.y_flip,status(a0)
		bset	#render_flags.y_flip,render_flags(a0)

.notflipy
		add.w	d1,d0
		move.w	d0,y_pos(a0)
		rts

; =============== S U B R O U T I N E =======================================

sub_7675C:
		movea.w	parent3(a0),a1							; a1=parent object
		move.w	x_pos(a1),x_pos(a0)
		move.w	y_pos(a1),y_pos(a0)
		bclr	#render_flags.x_flip,render_flags(a0)
		btst	#render_flags.x_flip,render_flags(a1)
		beq.s	.return
		bset	#render_flags.x_flip,render_flags(a0)

.return
		rts

; ---------------------------------------------------------------------------
; Chase object subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Chase_Object:
		move.w	d0,d2								; d0 = maximum speed
		neg.w	d2
		move.w	d1,d3								; d1 = acceleration

		; check xpos
		move.w	x_pos(a0),d4
		cmp.w	x_pos(a1),d4
		seq	d5
		beq.s	.checky
		blo.s	.setx
		neg.w	d1

.setx
		move.w	x_vel(a0),d4
		add.w	d1,d4
		cmp.w	d2,d4
		blt.s	.checky
		cmp.w	d0,d4
		bgt.s	.checky
		move.w	d4,x_vel(a0)

.checky
		move.w	y_pos(a0),d4
		cmp.w	y_pos(a1),d4
		beq.s	.exit
		blo.s	.sety
		neg.w	d3

.sety
		move.w	y_vel(a0),d4
		add.w	d3,d4
		cmp.w	d2,d4
		blt.s	.return
		cmp.w	d0,d4
		bgt.s	.return
		move.w	d4,y_vel(a0)

.return
		rts
; ---------------------------------------------------------------------------

.exit
		tst.b	d5
		beq.s	.return2
		clr.l	x_vel(a0)

.return2
		rts

; ---------------------------------------------------------------------------
; Chase xpos object subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Chase_ObjectXOnly:
		move.w	d0,d2								; d0 = maximum speed
		neg.w	d2

		; check xpos
		move.w	x_pos(a1),d3
		move.b	child_dx(a0),d4
		ext.w	d4
		add.w	d4,d3
		cmp.w	x_pos(a0),d3
		bhs.s	.setx
		neg.w	d1

.setx
		move.w	x_vel(a0),d3
		add.w	d1,d3
		cmp.w	d2,d3
		blt.s	.return
		cmp.w	d0,d3
		bgt.s	.return
		move.w	d3,x_vel(a0)

.return
		rts

; ---------------------------------------------------------------------------
; Chase ypos object subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Chase_ObjectYOnly:
		move.w	d0,d2								; d0 = maximum speed
		neg.w	d2

		; check ypos
		move.w	y_pos(a1),d3
		move.b	child_dy(a0),d4
		ext.w	d4
		add.w	d4,d3
		cmp.w	y_pos(a0),d3
		bhs.s	.sety
		neg.w	d1

.sety
		move.w	y_vel(a0),d3
		add.w	d1,d3
		cmp.w	d2,d3
		blt.s	.return
		cmp.w	d0,d3
		bgt.s	.return
		move.w	d3,y_vel(a0)

.return
		rts

; ---------------------------------------------------------------------------
; Chase object offset subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Chase_ObjectOffset:
		move.w	d0,d2								; d0 = maximum speed
		neg.w	d2
		move.w	d1,d3								; d1 = acceleration

		; check xpos
		move.w	x_pos(a1),d6
		move.b	child_dx(a0),d4
		ext.w	d4
		add.w	d4,d6
		cmp.w	x_pos(a0),d6
		seq	d5
		beq.s	.checky
		bhs.s	.setx
		neg.w	d1

.setx
		move.w	x_vel(a0),d4
		add.w	d1,d4
		cmp.w	d2,d4
		blt.s	.checky
		cmp.w	d0,d4
		bgt.s	.checky
		move.w	d4,x_vel(a0)

.checky
		move.w	y_pos(a1),d6
		move.b	child_dy(a0),d4
		ext.w	d4
		add.w	d4,d6
		cmp.w	y_pos(a0),d6
		beq.s	.exit
		bhs.s	.sety
		neg.w	d3

.sety
		move.w	y_vel(a0),d4
		add.w	d3,d4
		cmp.w	d2,d4
		blt.s	.return
		cmp.w	d0,d4
		bgt.s	.return
		move.w	d4,y_vel(a0)

.return
		rts
; ---------------------------------------------------------------------------

.exit
		tst.b	d5
		beq.s	.return2
		clr.l	x_vel(a0)

.return2
		rts

; ---------------------------------------------------------------------------
; Shot object subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Shot_Object:
		lea	(Player_1).w,a1							; a1=character

Shot_Object_2:
		moveq	#0,d0
		move.w	x_pos(a1),d0
		moveq	#0,d1
		move.w	y_pos(a1),d1

Shot_Object_3:
		sub.w	x_pos(a0),d0
		smi	d2
		bpl.s	.skipx
		neg.w	d0

.skipx
		sub.w	y_pos(a0),d1
		smi	d3
		bpl.s	.skipy
		neg.w	d1

.skipy
		cmp.w	d1,d0
		scs	d4
		beq.s	.exit
		bhs.s	.skip1
		exg	d0,d1

.skip1
		swap	d1
		divu.w	d0,d1

.calc
		move.w	#256,d0
		lsl.w	d5,d0
		moveq	#8,d6
		sub.w	d5,d6
		lsr.w	d6,d1

.check
		tst.b	d4
		beq.s	.skip2
		exg	d0,d1

.skip2
		tst.b	d2
		beq.s	.skip3
		neg.w	d0

.skip3
		tst.b	d3
		beq.s	.setxy
		neg.w	d1

.setxy
		movem.w	d0-d1,x_vel(a0)
		rts
; ---------------------------------------------------------------------------

.exit
		tst.w	d0
		beq.s	.calc
		move.w	#256,d0
		lsl.w	d5,d0
		move.w	#256,d1
		lsl.w	d5,d1
		bra.s	.check

; =============== S U B R O U T I N E =======================================

sub_8619A:
		move.w	objoff_30(a0),d2
		move.w	objoff_34(a0),d3
		moveq	#4,d0
		add.b	objoff_40(a0),d0
		move.l	#$100,d4
		divu.w	d0,d4
		sub.w	d4,d2
		sub.w	d4,d3
		move.w	d2,x_pos(a0)
		move.w	d3,y_pos(a0)
		rts

; =============== S U B R O U T I N E =======================================

Gradual_SwingOffset:
		move.l	objoff_2E(a0),d2
		tst.b	objoff_36(a0)
		beq.s	loc_465F6
		neg.l	d1
		add.l	d2,objoff_32(a0)						; moving up and then down. Reset speed/direction when center point is reached going down
		bmi.s	loc_4660E
		move.l	d0,objoff_2E(a0)						; reset initial speed (positive) to move downwards
		clr.l	objoff_32(a0)
		clr.b	objoff_36(a0)
		move.w	objoff_32(a0),d0						; get final offset for us by calling object
		rts
; ---------------------------------------------------------------------------

loc_465F6:
		add.l	d2,objoff_32(a0)						; moving down and then up. Reset speed/direction when center point is reached going up
		bmi.s	loc_465FE
		bne.s	loc_4660E

loc_465FE:
		neg.l	d0								; reverse direction to move upwards when speed has reached
		move.l	d0,objoff_2E(a0)						; reset initial speed (negative)
		clr.l	objoff_32(a0)
		st	objoff_36(a0)
		move.w	objoff_32(a0),d0						; get final offset for us by calling object
		rts
; ---------------------------------------------------------------------------

loc_4660E:
		sub.l	d1,objoff_2E(a0)						; apply speed
		move.w	objoff_32(a0),d0						; get final offset for us by calling object
		rts

; =============== S U B R O U T I N E =======================================

sub_86458:
		lea	sub2_x_pos(a0),a2
		move.w	mainspr_childsprites(a0),d0
		subq.w	#1,d0
		move.w	x_pos(a0),d2
		move.w	y_pos(a0),d3

.next
		move.b	(a1)+,d1
		ext.w	d1
		btst	#render_flags.x_flip,render_flags(a0)
		beq.s	.notflipx
		neg.w	d1

.notflipx
		add.w	d2,d1
		move.w	d1,(a2)+							; sub2_x_pos
		move.b	(a1)+,d1
		ext.w	d1
		add.w	d3,d1
		move.w	d1,(a2)+							; sub2_y_pos
		addq.w	#next_subspr-4,a2						; skip sub2_mapframe
		dbf	d0,.next
		rts
