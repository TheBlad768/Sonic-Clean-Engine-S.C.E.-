; ---------------------------------------------------------------------------
; Subroutine to check solid object
; These check collision of Sonic with objects on the screen

; input variables:
; d1 = object width / 2
; d2 = object height / 2 (when jumping)
; d3 = object height / 2 (when walking)
; d4 = object x-axis position

; address registers:
; a0 = the object to check collision with
; a1 = Sonic (set inside these subroutines)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

SolidObject:
SolidObjectFull:
		lea	(Player_1).w,a1
		moveq	#p1_standing_bit,d6

SolidObjectFull_1P:
		btst	d6,status(a0)
		beq.w	SolidObject_OnScreenTest
		move.w	d1,d2
		add.w	d2,d2
		btst	#Status_InAir,status(a1)
		bne.s	+
		move.w	x_pos(a1),d0
		sub.w	x_pos(a0),d0
		add.w	d1,d0
		bmi.s	+
		cmp.w	d2,d0
		blo.s		++
+		bclr	#Status_OnObj,status(a1)
		bset	#Status_InAir,status(a1)
		bclr	d6,status(a0)
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------
+		move.w	d4,d2
		bsr.w	MvSonicOnPtfm
		moveq	#0,d4
		rts

; ---------------------------------------------------------------------------
; These check for solidity even if the object is off-screen
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

SolidObjectFull2:
		lea	(Player_1).w,a1
		moveq	#p1_standing_bit,d6

SolidObjectFull2_1P:
		btst	d6,status(a0)
		beq.w	SolidObject_cont
		move.w	d1,d2
		add.w	d2,d2
		btst	#Status_InAir,status(a1)
		bne.s	loc_1DCF0
		move.w	x_pos(a1),d0
		sub.w	x_pos(a0),d0
		add.w	d1,d0
		bmi.s	loc_1DCF0
		cmp.w	d2,d0
		blo.s		loc_1DD04

loc_1DCF0:
		bclr	#Status_OnObj,status(a1)
		bset	#Status_InAir,status(a1)
		bclr	d6,status(a0)
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------

loc_1DD04:
		move.w	d4,d2
		bsr.w	MvSonicOnPtfm
		moveq	#0,d4
		rts

; ---------------------------------------------------------------------------
; Subroutine to collide Sonic with the top of a sloped solid like diagonal springs

; input variables:
; d1 = object width
; d2 = object height / 2 (when jumping)
; d3 = object height / 2 (when walking)
; d4 = object x-axis position

; address registers:
; a0 = the object to check collision with
; a1 = Sonic or Tails (set inside these subroutines)
; a2 = height data for slope
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

sub_1DD0E:
SolidObjectFullSloped_Spring:
		lea	(Player_1).w,a1
		moveq	#p1_standing_bit,d6

sub_1DD24:
SolidObjectFullSloped_Spring_1P:
		btst	d6,status(a0)
		beq.w	loc_1DECE
		move.w	d1,d2
		add.w	d2,d2
		btst	#Status_InAir,status(a1)
		bne.s	loc_1DD48
		move.w	x_pos(a1),d0
		sub.w	x_pos(a0),d0
		add.w	d1,d0
		bmi.s	loc_1DD48
		cmp.w	d2,d0
		blo.s		loc_1DD5C

loc_1DD48:
		bclr	#Status_OnObj,status(a1)
		bset	#Status_InAir,status(a1)
		bclr	d6,status(a0)
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------

loc_1DD5C:
		move.w	d4,d2
		bsr.w	SolidObjSloped2
		move.w	d6,d4
		addi.b	#$11,d4
		bset	d4,d6
		moveq	#0,d4
		rts

; =============== S U B R O U T I N E =======================================

sub_1DD6E:
		lea	(Player_1).w,a1
		moveq	#p1_standing_bit,d6

sub_1DD84:
		btst	d6,status(a0)
		beq.w	loc_1DF28
		move.w	d1,d2
		add.w	d2,d2
		btst	#Status_InAir,status(a1)
		bne.s	loc_1DDA8
		move.w	x_pos(a1),d0
		sub.w	x_pos(a0),d0
		add.w	d1,d0
		bmi.s	loc_1DDA8
		cmp.w	d2,d0
		blo.s		loc_1DDBC

loc_1DDA8:
		bclr	#Status_OnObj,status(a1)
		bset	#Status_InAir,status(a1)
		bclr	d6,status(a0)
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------

loc_1DDBC:
		move.w	d4,d2
		bsr.w	SolidObjSloped4
		moveq	#0,d4
		rts

; =============== S U B R O U T I N E =======================================

sub_1DDC6:
SolidObjectFullSloped:
		lea	(Player_1).w,a1
		moveq	#p1_standing_bit,d6

sub_1DDDC:
SolidObjectFullSloped_1P:
		btst	d6,status(a0)
		beq.w	loc_1DECE
		move.w	d1,d2
		add.w	d2,d2
		btst	#Status_InAir,status(a1)
		bne.s	loc_1DE00
		move.w	x_pos(a1),d0
		sub.w	x_pos(a0),d0
		add.w	d1,d0
		bmi.s	loc_1DE00
		cmp.w	d2,d0
		blo.s		loc_1DE0E

loc_1DE00:
		bclr	#Status_OnObj,status(a1)
		bclr	d6,status(a0)
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------

loc_1DE0E:
		move.w	d4,d2
		bsr.w	SolidObjSloped2
		move.w	d6,d4
		addi.b	#$11,d4
		bset	d4,d6
		moveq	#0,d4
		rts

; =============== S U B R O U T I N E =======================================

SolidObjectFull_Offset:
		lea	(Player_1).w,a1
		moveq	#p1_standing_bit,d6

sub_1DE36:
SolidObjectFull_Offset_1P:
		btst	d6,status(a0)
		beq.s	loc_1DE8C
		btst	#Status_InAir,status(a1)
		bne.s	loc_1DE58
		move.w	x_pos(a1),d0
		sub.w	x_pos(a0),d0
		add.w	d1,d0
		bmi.s	loc_1DE58
		add.w	d1,d1
		cmp.w	d1,d0
		blo.s		loc_1DE6C

loc_1DE58:
		bclr	#Status_OnObj,status(a1)
		bset	#Status_InAir,status(a1)
		bclr	d6,status(a0)
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------

loc_1DE6C:
		move.w	y_pos(a0),d0
		sub.w	d2,d0
		add.w	d3,d0
		moveq	#0,d1
		move.b	y_radius(a1),d1
		sub.w	d1,d0
		move.w	d0,y_pos(a1)
		sub.w	x_pos(a0),d4
		sub.w	d4,x_pos(a1)
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------

loc_1DE8C:
		move.w	x_pos(a1),d0
		sub.w	x_pos(a0),d0
		add.w	d1,d0
		bmi.w	SolidObject_TestClearPush
		move.w	d1,d4
		add.w	d4,d4
		cmp.w	d4,d0
		bhi.w	SolidObject_TestClearPush
		move.w	y_pos(a0),d5
		add.w	d3,d5
		move.b	y_radius(a1),d3
		ext.w	d3
		add.w	d3,d2
		move.w	y_pos(a1),d3
		sub.w	d5,d3
		addq.w	#4,d3
		add.w	d2,d3
		bmi.w	SolidObject_TestClearPush
		move.w	d2,d4
		add.w	d4,d4
		cmp.w	d4,d3
		bhs.w	SolidObject_TestClearPush
		bra.w	SolidObject_ChkBounds
; ---------------------------------------------------------------------------

loc_1DECE:
		move.w	x_pos(a1),d0
		sub.w	x_pos(a0),d0
		add.w	d1,d0
		bmi.w	SolidObject_TestClearPush
		move.w	d1,d3
		add.w	d3,d3
		cmp.w	d3,d0
		bhi.w	SolidObject_TestClearPush
		move.w	d0,d5
		btst	#0,render_flags(a0)
		beq.s	.notflipx
		not.w	d5
		add.w	d3,d5

.notflipx
		lsr.w	d5
		move.b	(a2,d5.w),d3
		sub.b	(a2),d3
		ext.w	d3
		move.w	y_pos(a0),d5
		sub.w	d3,d5
		move.b	y_radius(a1),d3
		ext.w	d3
		add.w	d3,d2
		move.w	y_pos(a1),d3
		sub.w	d5,d3
		addq.w	#4,d3
		add.w	d2,d3
		bmi.w	SolidObject_TestClearPush
		move.w	d2,d4
		add.w	d4,d4
		cmp.w	d4,d3
		bhs.w	SolidObject_TestClearPush
		bra.w	SolidObject_ChkBounds
; ---------------------------------------------------------------------------

loc_1DF28:
		move.w	x_pos(a1),d0
		sub.w	x_pos(a0),d0
		add.w	d1,d0
		bmi.w	SolidObject_TestClearPush
		move.w	d1,d3
		add.w	d3,d3
		cmp.w	d3,d0
		bhi.w	SolidObject_TestClearPush
		move.w	d0,d5
		btst	#0,render_flags(a0)
		beq.s	loc_1DF4E
		not.w	d5
		add.w	d3,d5

loc_1DF4E:
		andi.w	#$FFFE,d5
		move.b	(a2,d5.w),d3
		move.b	1(a2,d5.w),d2
		ext.w	d2
		ext.w	d3
		move.w	y_pos(a0),d5
		sub.w	d3,d5
		move.w	y_pos(a1),d3
		sub.w	d5,d3
		move.b	y_radius(a1),d5
		ext.w	d5
		add.w	d5,d3
		addq.w	#4,d3
		bmi.w	SolidObject_TestClearPush
		add.w	d5,d2
		move.w	d2,d4
		add.w	d5,d4
		cmp.w	d4,d3
		bhs.w	SolidObject_TestClearPush
		bra.s	SolidObject_ChkBounds
; ---------------------------------------------------------------------------

SolidObject_OnScreenTest:
		tst.b	render_flags(a0)
		bpl.w	SolidObject_TestClearPush

SolidObject_cont:
		move.w	x_pos(a1),d0
		sub.w	x_pos(a0),d0
		add.w	d1,d0
		move.w	d1,d3
		add.w	d3,d3
		cmp.w	d3,d0
		bhi.w	SolidObject_TestClearPush
		tst.b	(Reverse_gravity_flag).w
		beq.s	.notgrav
		move.b	default_y_radius(a1),d4
		ext.w	d4
		add.w	d2,d4
		move.b	y_radius(a1),d3
		ext.w	d3
		add.w	d3,d2
		move.w	y_pos(a1),d3
		sub.w	y_pos(a0),d3
		neg.w	d3
		addq.w	#4,d3
		add.w	d2,d3
		andi.w	#$FFF,d3
		add.w	d2,d4
		cmp.w	d4,d3
		bhs.w	SolidObject_TestClearPush
		bra.s	SolidObject_ChkBounds
; ---------------------------------------------------------------------------

.notgrav
		move.b	default_y_radius(a1),d4
		ext.w	d4
		add.w	d2,d4
		move.b	y_radius(a1),d3
		ext.w	d3
		add.w	d3,d2
		move.w	y_pos(a1),d3
		sub.w	y_pos(a0),d3
		addq.w	#4,d3
		add.w	d2,d3
		andi.w	#$FFF,d3
		add.w	d2,d4
		cmp.w	d4,d3
		bhs.w	SolidObject_TestClearPush

SolidObject_ChkBounds:
		tst.b	object_control(a1)
		bmi.w	SolidObject_TestClearPush
		cmpi.b	#id_PlayerDeath,routine(a1)				; has player just died?
		bhs.w	SolidObject_NoCollision					; if yes, branch
		tst.w	(Debug_placement_mode).w
		bne.w	SolidObject_NoCollision
		move.w	d0,d5
		cmp.w	d0,d1
		bhs.s	loc_1E026
		add.w	d1,d1
		sub.w	d1,d0
		move.w	d0,d5
		neg.w	d5

loc_1E026:
		move.w	d3,d1
		cmp.w	d3,d2
		bhs.s	loc_1E034
		subq.w	#4,d3
		sub.w	d4,d3
		move.w	d3,d1
		neg.w	d1

loc_1E034:
		cmp.w	d1,d5
		bhi.w	SolidObject_TopBottom
		cmpi.w	#4,d1
		bls.w	SolidObject_TopBottom

SolidObject_LeftRight:
		tst.w	d0
		beq.s	SolidObject_AtEdge
		bmi.s	SolidObject_InsideRight

; SolidObject_InsideLeft:
		tst.w	x_vel(a1)
		bmi.s	SolidObject_AtEdge
		bra.s	SolidObject_StopCharacter
; ---------------------------------------------------------------------------

SolidObject_InsideRight:
		tst.w	x_vel(a1)
		bpl.s	SolidObject_AtEdge

SolidObject_StopCharacter:
		clr.w	x_vel(a1)
		clr.w	ground_vel(a1)
		tst.b	status_tertiary(a1)
		bpl.s	SolidObject_AtEdge
		bset	#6,status_tertiary(a1)

SolidObject_AtEdge:
		sub.w	d0,x_pos(a1)
		btst	#Status_InAir,status(a1)
		bne.s	SolidObject_SideAir
		move.l	d6,d4
		addq.b	#pushing_bit_delta,d4
		bset	d4,status(a0)
		bset	#Status_Push,status(a1)
		move.w	d6,d4
		addi.b	#$D,d4
		bset	d4,d6
		moveq	#1,d4
		rts
; ---------------------------------------------------------------------------

SolidObject_SideAir:
		bsr.s	Solid_NotPushing
		move.w	d6,d4
		addi.b	#$D,d4
		bset	d4,d6
		moveq	#1,d4
		rts
; ---------------------------------------------------------------------------

SolidObject_TestClearPush:
		move.l	d6,d4
		addq.b	#pushing_bit_delta,d4
		btst	d4,status(a0)
		beq.s	SolidObject_NoCollision

		; check player anim
		cmpi.b	#id_Roll,anim(a1)
		beq.s	Solid_NotPushing
		cmpi.b	#id_SpinDash,anim(a1)
		beq.s	Solid_NotPushing
		cmpi.b	#id_Hurt2,anim(a1)
		beq.s	Solid_NotPushing
		cmpi.b	#id_Death,anim(a1)
		beq.s	Solid_NotPushing
		cmpi.b	#id_Drown,anim(a1)
		beq.s	Solid_NotPushing
		cmpi.b	#id_Landing,anim(a1)
		beq.s	Solid_NotPushing
		move.w	#bytes_to_word(id_Walk,id_Run),anim(a1)

Solid_NotPushing:
		move.l	d6,d4
		addq.b	#pushing_bit_delta,d4
		bclr	d4,status(a0)
		bclr	#Status_Push,status(a1)

SolidObject_NoCollision:
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------

SolidObject_TopBottom:
		tst.w	d3
		bmi.s	SolidObject_InsideBottom

; SolidObject_InsideTop:
		cmpi.w	#16,d3
		blo.s		SolidObject_Landed
		bra.s	SolidObject_TestClearPush
; ---------------------------------------------------------------------------

SolidObject_InsideBottom:
		btst	#Status_InAir,status(a1)
		bne.s	loc_1E0F6
		tst.w	y_vel(a1)
		beq.s	SolidObject_Squash
		bpl.s	loc_1E10E
		tst.w	d3
		bpl.s	loc_1E10E
		bra.s	loc_1E0FC
; ---------------------------------------------------------------------------

loc_1E0F6:
		clr.w	ground_vel(a1)

loc_1E0FC:
		clr.w	y_vel(a1)

loc_1E10E:
		tst.b	status_tertiary(a1)
		bpl.s	loc_1E11A
		bset	#5,status_tertiary(a1)

loc_1E11A:
		tst.b	(Reverse_gravity_flag).w
		beq.s	.notgrav
		neg.w	d3

.notgrav
		sub.w	d3,y_pos(a1)
		move.w	d6,d4
		addi.b	#$F,d4
		bset	d4,d6
		moveq	#-2,d4
		rts
; ---------------------------------------------------------------------------

SolidObject_Squash:
		btst	#Status_InAir,status(a1)
		bne.s	loc_1E10E
		mvabs.w	d0,d4

		cmpi.w	#16,d4
		blo.w	SolidObject_LeftRight
		move.w	a0,-(sp)
		movea.w	a0,a2
		movea.w	a1,a0
		jsr	Kill_Character(pc)
		movea.w	(sp)+,a0
		move.w	d6,d4
		addi.b	#$F,d4
		bset	d4,d6
		moveq	#-2,d4
		rts
; ---------------------------------------------------------------------------

SolidObject_Landed:
		subq.w	#4,d3
		moveq	#0,d1
		move.b	width_pixels(a0),d1
		move.w	d1,d2
		add.w	d2,d2
		add.w	x_pos(a1),d1
		sub.w	x_pos(a0),d1
		bmi.s	SolidObject_Miss
		cmp.w	d2,d1
		bhs.s	SolidObject_Miss
		subq.w	#1,y_pos(a1)
		tst.b	(Reverse_gravity_flag).w
		beq.s	loc_1E17E
		neg.w	d3
		addq.w	#2,y_pos(a1)

loc_1E17E:
		sub.w	d3,y_pos(a1)
		tst.w	y_vel(a1)
		bmi.s	SolidObject_Miss
		bsr.w	RideObject_SetRide
		move.w	d6,d4
		addi.b	#$11,d4
		bset	d4,d6
		moveq	#-1,d4
		rts
; ---------------------------------------------------------------------------

SolidObject_Miss:
		moveq	#0,d4
		rts

; =============== S U B R O U T I N E =======================================

MvSonicOnPtfm:
		tst.b	(Reverse_gravity_flag).w
		bne.s	loc_1E1AA
		move.w	y_pos(a0),d0
		sub.w	d3,d0
		bra.s	loc_1E1CA
; ---------------------------------------------------------------------------

loc_1E1AA:
		move.w	y_pos(a0),d0
		add.w	d3,d0
		bra.s	loc_1E1F4
; ---------------------------------------------------------------------------

loc_1E1CA:
		tst.b	object_control(a1)
		bmi.s	locret_1E1F2
		cmpi.b	#id_PlayerDeath,routine(a1)				; has player just died?
		bhs.s	locret_1E1F2								; if yes, branch
		tst.w	(Debug_placement_mode).w
		bne.s	locret_1E1F2
		moveq	#0,d1
		move.b	y_radius(a1),d1
		sub.w	d1,d0
		move.w	d0,y_pos(a1)
		sub.w	x_pos(a0),d2
		sub.w	d2,x_pos(a1)

locret_1E1F2:
		rts
; ---------------------------------------------------------------------------

loc_1E1F4:
		tst.b	object_control(a1)
		bmi.s	locret_1E21C
		cmpi.b	#id_PlayerDeath,routine(a1)				; has player just died?
		bhs.s	locret_1E21C								; if yes, branch
		tst.w	(Debug_placement_mode).w
		bne.s	locret_1E21C
		moveq	#0,d1
		move.b	y_radius(a1),d1
		add.w	d1,d0
		move.w	d0,y_pos(a1)
		sub.w	x_pos(a0),d2
		sub.w	d2,x_pos(a1)

locret_1E21C:
		rts

; =============== S U B R O U T I N E =======================================

SolidObjSloped:
		btst	#Status_OnObj,status(a1)
		beq.s	locret_1E280
		move.w	x_pos(a1),d0
		sub.w	x_pos(a0),d0
		add.w	d1,d0
		btst	#0,render_flags(a0)
		beq.s	loc_1E23E
		not.w	d0
		add.w	d1,d0
		add.w	d1,d0

loc_1E23E:
		bra.s	loc_1E260

; =============== S U B R O U T I N E =======================================

SolidObjSloped2:
		btst	#Status_OnObj,status(a1)
		beq.s	locret_1E280
		move.w	x_pos(a1),d0
		sub.w	x_pos(a0),d0
		add.w	d1,d0
		lsr.w	d0
		btst	#0,render_flags(a0)
		beq.s	loc_1E260
		not.w	d0
		add.w	d1,d0

loc_1E260:
		move.b	(a2,d0.w),d1
		ext.w	d1
		move.w	y_pos(a0),d0
		sub.w	d1,d0
		moveq	#0,d1
		move.b	y_radius(a1),d1
		sub.w	d1,d0
		move.w	d0,y_pos(a1)
		sub.w	x_pos(a0),d2
		sub.w	d2,x_pos(a1)

locret_1E280:
		rts

; =============== S U B R O U T I N E =======================================

SolidObjSloped4:
		btst	#Status_OnObj,status(a1)
		beq.s	locret_1E280
		move.w	x_pos(a1),d0
		sub.w	x_pos(a0),d0
		add.w	d1,d0
		btst	#0,render_flags(a0)
		beq.s	loc_1E2A0
		not.w	d0
		add.w	d1,d0

loc_1E2A0:
		andi.w	#$FFFE,d0
		bra.s	loc_1E260

; =============== S U B R O U T I N E =======================================

SolidObjectTop:
		lea	(Player_1).w,a1
		moveq	#p1_standing_bit,d6

sub_1E2BC:
SolidObjectTop_1P:
		btst	d6,status(a0)
		beq.w	loc_1E42E
		move.w	d1,d2
		add.w	d2,d2
		btst	#Status_InAir,status(a1)
		bne.s	loc_1E2E0
		move.w	x_pos(a1),d0
		sub.w	x_pos(a0),d0
		add.w	d1,d0
		bmi.s	loc_1E2E0
		cmp.w	d2,d0
		blo.s		loc_1E2F4

loc_1E2E0:
		bclr	#Status_OnObj,status(a1)
		bset	#Status_InAir,status(a1)
		bclr	d6,status(a0)
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------

loc_1E2F4:
		move.w	d4,d2
		bsr.w	MvSonicOnPtfm
		moveq	#0,d4
		rts

; =============== S U B R O U T I N E =======================================

SolidObjectTopSloped2:
		lea	(Player_1).w,a1
		moveq	#p1_standing_bit,d6

sub_1E314:
SolidObjectTopSloped2_1P:
		btst	d6,status(a0)
		beq.w	SolidObjCheckSloped2
		move.w	d1,d2
		add.w	d2,d2
		btst	#Status_InAir,status(a1)
		bne.s	loc_1E338
		move.w	x_pos(a1),d0
		sub.w	x_pos(a0),d0
		add.w	d1,d0
		bmi.s	loc_1E338
		cmp.w	d2,d0
		blo.s		loc_1E34C

loc_1E338:
		bclr	#Status_OnObj,status(a1)
		bset	#Status_InAir,status(a1)
		bclr	d6,status(a0)
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------

loc_1E34C:
		move.w	d4,d2
		bsr.w	SolidObjSloped2
		moveq	#0,d4
		rts

; =============== S U B R O U T I N E =======================================

SolidObjectTopSloped:
		lea	(Player_1).w,a1
		moveq	#p1_standing_bit,d6

sub_1E36C:
SolidObjectTopSloped_1P:
		btst	d6,status(a0)
		beq.w	SolidObjCheckSloped
		move.w	d1,d2
		add.w	d2,d2
		btst	#Status_InAir,status(a1)
		bne.s	loc_1E390
		move.w	x_pos(a1),d0
		sub.w	x_pos(a0),d0
		add.w	d1,d0
		bmi.s	loc_1E390
		cmp.w	d2,d0
		blo.s		loc_1E3A4

loc_1E390:
		bclr	#Status_OnObj,status(a1)
		bset	#Status_InAir,status(a1)
		bclr	d6,status(a0)
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------

loc_1E3A4:
		move.w	d4,d2
		bsr.w	SolidObjSloped
		moveq	#0,d4
		rts

; =============== S U B R O U T I N E =======================================

sub_1E3AE:
		lea	(Player_1).w,a1
		moveq	#p1_standing_bit,d6

sub_1E3C4:
		btst	d6,status(a0)
		bne.s	loc_1E3D6
		btst	#3,status(a1)
		bne.s	loc_1E402
		bra.s	loc_1E42E
; ---------------------------------------------------------------------------

loc_1E3D6:
		move.w	d1,d2
		add.w	d2,d2
		btst	#Status_InAir,status(a1)
		bne.s	loc_1E3F2
		move.w	x_pos(a1),d0
		sub.w	x_pos(a0),d0
		add.w	d1,d0
		bmi.s	loc_1E3F2
		cmp.w	d2,d0
		blo.s		loc_1E406

loc_1E3F2:
		bclr	#3,status(a1)
		bset	#1,status(a1)
		bclr	d6,status(a0)

loc_1E402:
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------

loc_1E406:
		move.w	d4,d2
		bsr.w	MvSonicOnPtfm
		moveq	#0,d4

locret_1E40E:
		rts

; =============== S U B R O U T I N E =======================================

sub_1E410:
		tst.w	y_vel(a1)
		bmi.s	locret_1E40E
		move.w	x_pos(a1),d0
		sub.w	x_pos(a0),d0
		add.w	d1,d0
		bmi.s	locret_1E40E
		cmp.w	d2,d0
		bhs.s	locret_1E40E
		bra.s	loc_1E44C
; ---------------------------------------------------------------------------

loc_1E42E:
		tst.w	y_vel(a1)
		bmi.s	locret_1E40E
		move.w	x_pos(a1),d0
		sub.w	x_pos(a0),d0
		add.w	d1,d0
		bmi.s	locret_1E40E
		add.w	d1,d1
		cmp.w	d1,d0
		bhs.s	locret_1E40E

loc_1E44C:
		tst.b	(Reverse_gravity_flag).w
		bne.s	loc_1E4D6
		move.w	y_pos(a0),d0
		sub.w	d3,d0

loc_1E45A:
		move.w	y_pos(a1),d2
		move.b	y_radius(a1),d1
		ext.w	d1
		add.w	d2,d1
		addq.w	#4,d1
		sub.w	d1,d0
		bhi.s	locret_1E4D4
		cmpi.w	#-16,d0
		blo.s		locret_1E4D4
		tst.b	object_control(a1)
		bmi.s	locret_1E4D4
		cmpi.b	#id_PlayerDeath,routine(a1)				; has player just died?
		bhs.s	locret_1E4D4								; if yes, branch
		tst.w	(Debug_placement_mode).w
		bne.s	locret_1E4D4
		add.w	d0,d2
		addq.w	#3,d2
		move.w	d2,y_pos(a1)

; =============== S U B R O U T I N E =======================================

RideObject_SetRide:
		btst	#Status_OnObj,status(a1)
		beq.s	loc_1E4A0
		movea.w	interact(a1),a3
		bclr	d6,status(a3)

loc_1E4A0:
		move.w	a0,interact(a1)
		clr.b	angle(a1)
		clr.w	y_vel(a1)
		move.w	x_vel(a1),ground_vel(a1)
		bset	#Status_OnObj,status(a1)
		bset	d6,status(a0)
		bclr	#Status_InAir,status(a1)
		beq.s	locret_1E4D4
		move.w	a0,-(sp)
		movea.w	a1,a0
		jsr	Sonic_TouchFloor(pc)
		movea.w	(sp)+,a0

locret_1E4D4:
		rts
; ---------------------------------------------------------------------------

loc_1E4D6:
		move.w	y_pos(a0),d0
		add.w	d3,d0
		move.w	y_pos(a1),d2
		move.b	y_radius(a1),d1
		ext.w	d1
		neg.w	d1
		add.w	d2,d1
		subq.w	#4,d1
		sub.w	d0,d1
		bhi.s	locret_1E4D4
		cmpi.w	#-16,d1
		blo.s		locret_1E4D4
		tst.b	object_control(a1)
		bmi.s	locret_1E4D4
		cmpi.b	#id_PlayerDeath,routine(a1)				; has player just died?
		bhs.s	locret_1E4D4								; if yes, branch
		tst.w	(Debug_placement_mode).w
		bne.s	locret_1E4D4
		sub.w	d1,d2
		subq.w	#4,d2
		move.w	d2,y_pos(a1)
		bra.s	RideObject_SetRide
; ---------------------------------------------------------------------------

SolidObjCheckSloped2:
		tst.w	y_vel(a1)
		bmi.s	locret_1E4D4
		move.w	x_pos(a1),d0
		sub.w	x_pos(a0),d0
		add.w	d1,d0
		bmi.s	locret_1E4D4
		add.w	d1,d1
		cmp.w	d1,d0
		bhs.s	locret_1E4D4
		btst	#0,render_flags(a0)
		beq.s	loc_1E534
		not.w	d0
		add.w	d1,d0

loc_1E534:
		lsr.w	d0
		move.b	(a2,d0.w),d3
		ext.w	d3
		move.w	y_pos(a0),d0
		sub.w	d3,d0
		bra.w	loc_1E45A
; ---------------------------------------------------------------------------

SolidObjCheckSloped:
		tst.w	y_vel(a1)
		bmi.w	CheckPlayerReleaseFromObj.return
		move.w	x_pos(a1),d0
		sub.w	x_pos(a0),d0
		add.w	d1,d0
		bmi.s	CheckPlayerReleaseFromObj.return
		add.w	d1,d1
		cmp.w	d1,d0
		bhs.s	CheckPlayerReleaseFromObj.return
		btst	#0,render_flags(a0)
		beq.s	+
		not.w	d0
		add.w	d1,d0
+		move.b	(a2,d0.w),d3
		ext.w	d3
		move.w	y_pos(a0),d0
		sub.w	d3,d0
		bra.w	loc_1E45A

; =============== S U B R O U T I N E =======================================

CheckPlayerReleaseFromObj:

		; player 1
		lea	(Player_1).w,a1
		btst	#p1_standing_bit,status(a0)
		beq.s	.end
		bsr.w	SonicOnObjHitFloor
		tst.w	d1
		beq.s	.setp1
		bpl.s	.end

.setp1
		lea	(Player_1).w,a1
		bclr	#Status_OnObj,status(a1)
		bset	#Status_InAir,status(a1)
		bclr	#Status_OnObj,status(a0)

.end
		moveq	#0,d4

.return
		rts
