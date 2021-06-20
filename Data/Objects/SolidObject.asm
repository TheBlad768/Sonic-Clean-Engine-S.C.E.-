
; =============== S U B R O U T I N E =======================================

SolidObject:
SolidObjectFull:
		lea	(Player_1).w,a1
		moveq	#p1_standing_bit,d6
		btst	d6,status(a0)
		beq.w	loc_1DF88
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
; End of function SolidObjectFull

; =============== S U B R O U T I N E =======================================

SolidObjectFull2:
		lea	(Player_1).w,a1
		moveq	#p1_standing_bit,d6
		movem.l	d1-d4,-(sp)
		bsr.s	SolidObjectFull2_1P
		movem.l	(sp)+,d1-d4
		rts
; ---------------------------------------------------------------------------

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
; End of function SolidObjectFull2

; =============== S U B R O U T I N E =======================================

sub_1DD0E:
		lea	(Player_1).w,a1
		moveq	#p1_standing_bit,d6
		movem.l	d1-d4,-(sp)
		bsr.s	sub_1DD24
		movem.l	(sp)+,d1-d4
		rts
; ---------------------------------------------------------------------------

sub_1DD24:
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
; End of function sub_1DD24

; =============== S U B R O U T I N E =======================================

SolidObjectFull_Offset:
		lea	(Player_1).w,a1
		moveq	#p1_standing_bit,d6
		movem.l	d1-d4,-(sp)
		bsr.s	sub_1DE36
		movem.l	(sp)+,d1-d4
		rts
; ---------------------------------------------------------------------------

sub_1DE36:
		btst	d6,status(a0)
		beq.w	loc_1DE8C
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
		bmi.w	loc_1E0A2
		move.w	d1,d4
		add.w	d4,d4
		cmp.w	d4,d0
		bhi.w	loc_1E0A2
		move.w	y_pos(a0),d5
		add.w	d3,d5
		move.b	y_radius(a1),d3
		ext.w	d3
		add.w	d3,d2
		move.w	y_pos(a1),d3
		sub.w	d5,d3
		addq.w	#4,d3
		add.w	d2,d3
		bmi.w	loc_1E0A2
		move.w	d2,d4
		add.w	d4,d4
		cmp.w	d4,d3
		bhs.w	loc_1E0A2
		bra.w	loc_1DFFE
; ---------------------------------------------------------------------------

loc_1DECE:
		move.w	x_pos(a1),d0
		sub.w	x_pos(a0),d0
		add.w	d1,d0
		bmi.w	loc_1E0A2
		move.w	d1,d3
		add.w	d3,d3
		cmp.w	d3,d0
		bhi.w	loc_1E0A2
		move.w	d0,d5
		btst	#0,render_flags(a0)
		beq.s	loc_1DEF4
		not.w	d5
		add.w	d3,d5

loc_1DEF4:
		lsr.w	#1,d5
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
		bmi.w	loc_1E0A2
		move.w	d2,d4
		add.w	d4,d4
		cmp.w	d4,d3
		bhs.w	loc_1E0A2
		bra.w	loc_1DFFE
; ---------------------------------------------------------------------------

loc_1DF88:
		tst.b	4(a0)
		bpl.w	loc_1E0A2

SolidObject_cont:
		move.w	x_pos(a1),d0
		sub.w	x_pos(a0),d0
		add.w	d1,d0
		move.w	d1,d3
		add.w	d3,d3
		cmp.w	d3,d0
		bhi.w	loc_1E0A2
		tst.b	(Reverse_gravity_flag).w
		beq.s	loc_1DFD6
		move.b	$44(a1),d4
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
		bhs.w	loc_1E0A2
		bra.s	loc_1DFFE
; ---------------------------------------------------------------------------

loc_1DFD6:
		move.b	$44(a1),d4
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
		bhs.w	loc_1E0A2

loc_1DFFE:
		tst.b	$2E(a1)
		bmi.w	loc_1E0A2
		cmpi.b	#id_SonicDeath,routine(a1)
		bhs.w	loc_1E0D0
		tst.w	(Debug_placement_mode).w
		bne.w	loc_1E0D0
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
		bhi.w	loc_1E0D4
		cmpi.w	#4,d1
		bls.w	loc_1E0D4

loc_1E042:
		tst.w	d0
		beq.s	loc_1E06E
		bmi.s	loc_1E050
		tst.w	x_vel(a1)
		bmi.s	loc_1E06E
		bra.s	loc_1E056
; ---------------------------------------------------------------------------

loc_1E050:
		tst.w	x_vel(a1)
		bpl.s	loc_1E06E

loc_1E056:
		clr.w	ground_vel(a1)
		clr.w	x_vel(a1)
		tst.b	$37(a1)
		bpl.s	loc_1E06E
		bset	#6,$37(a1)

loc_1E06E:
		sub.w	d0,x_pos(a1)
		btst	#Status_InAir,status(a1)
		bne.s	loc_1E094
		move.l	d6,d4
		addq.b	#2,d4
		bset	d4,status(a0)
		bset	#Status_Push,status(a1)
		move.w	d6,d4
		addi.b	#$D,d4
		bset	d4,d6
		moveq	#1,d4
		rts
; ---------------------------------------------------------------------------

loc_1E094:
		bsr.s	sub_1E0C2
		move.w	d6,d4
		addi.b	#$D,d4
		bset	d4,d6
		moveq	#1,d4
		rts
; ---------------------------------------------------------------------------

loc_1E0A2:
		move.l	d6,d4
		addq.b	#2,d4
		btst	d4,status(a0)
		beq.s	loc_1E0D0
		cmpi.b	#id_Roll,anim(a1)
		beq.s	sub_1E0C2
		cmpi.b	#id_SpinDash,anim(a1)
		beq.s	sub_1E0C2
		move.w	#id_Run,anim(a1)

sub_1E0C2:
		move.l	d6,d4
		addq.b	#2,d4
		bclr	d4,status(a0)
		bclr	#Status_Push,status(a1)

loc_1E0D0:
		moveq	#0,d4
		rts
; End of function sub_1E0C2
; ---------------------------------------------------------------------------

loc_1E0D4:
		tst.w	d3
		bmi.s	loc_1E0E0
		cmpi.w	#$10,d3
		blo.s		loc_1E154
		bra.s	loc_1E0A2
; ---------------------------------------------------------------------------

loc_1E0E0:
		btst	#Status_InAir,status(a1)
		bne.s	loc_1E0F6
		tst.w	y_vel(a1)
		beq.s	loc_1E126
		bpl.s	loc_1E10E
		tst.w	d3
		bpl.s	loc_1E10E
		bra.s	loc_1E0FC
; ---------------------------------------------------------------------------

loc_1E0F6:
		clr.w	ground_vel(a1)

loc_1E0FC:
		tst.b	(Reverse_gravity_flag).w
		beq.s	+
		neg.w	d3
+		sub.w	d3,y_pos(a1)
		clr.w	y_vel(a1)

loc_1E10E:
		tst.b	$37(a1)
		bpl.s	loc_1E11A
		bset	#5,$37(a1)

loc_1E11A:
		move.w	d6,d4
		addi.b	#$F,d4
		bset	d4,d6
		moveq	#-2,d4
		rts
; ---------------------------------------------------------------------------

loc_1E126:
		btst	#Status_InAir,status(a1)
		bne.s	loc_1E10E
		move.w	d0,d4
		bpl.s	loc_1E134
		neg.w	d4

loc_1E134:
		cmpi.w	#$10,d4
		blo.w	loc_1E042
		move.l	a0,-(sp)
		movea.l	a1,a0
		bsr.w	Kill_Character
		movea.l	(sp)+,a0
		move.w	d6,d4
		addi.b	#$F,d4
		bset	d4,d6
		moveq	#-2,d4
		rts
; ---------------------------------------------------------------------------

loc_1E154:
		subq.w	#4,d3
		moveq	#0,d1
		move.b	7(a0),d1
		move.w	d1,d2
		add.w	d2,d2
		add.w	x_pos(a1),d1
		sub.w	x_pos(a0),d1
		bmi.s	loc_1E198
		cmp.w	d2,d1
		bhs.s	loc_1E198
		subq.w	#1,y_pos(a1)
		tst.b	(Reverse_gravity_flag).w
		beq.s	loc_1E17E
		neg.w	d3
		addq.w	#2,y_pos(a1)

loc_1E17E:
		sub.w	d3,y_pos(a1)
		tst.w	y_vel(a1)
		bmi.s	loc_1E198
		bsr.w	RideObject_SetRide
		move.w	d6,d4
		addi.b	#$11,d4
		bset	d4,d6
		moveq	#-1,d4
		rts
; ---------------------------------------------------------------------------

loc_1E198:
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
		tst.b	$2E(a1)
		bmi.s	locret_1E1F2
		cmpi.b	#id_SonicDeath,routine(a1)
		bhs.s	locret_1E1F2
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
		tst.b	$2E(a1)
		bmi.s	locret_1E21C
		cmpi.b	#id_SonicDeath,routine(a1)
		bhs.s	locret_1E21C
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
; End of function MvSonicOnPtfm

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
; End of function SolidObjSloped

; =============== S U B R O U T I N E =======================================

SolidObjSloped2:
		btst	#Status_OnObj,status(a1)
		beq.s	locret_1E280
		move.w	x_pos(a1),d0
		sub.w	x_pos(a0),d0
		add.w	d1,d0
		lsr.w	#1,d0
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
; End of function SolidObjSloped2

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
		andi.w	#-2,d0
		bra.s	loc_1E260
; End of function SolidObjSloped4

; =============== S U B R O U T I N E =======================================

SolidObjectTop:
		lea	(Player_1).w,a1
		moveq	#p1_standing_bit,d6
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
; End of function sub_1E2BC

; =============== S U B R O U T I N E =======================================

SolidObjectTopSloped2:
		lea	(Player_1).w,a1
		moveq	#p1_standing_bit,d6
		movem.l	d1-d4,-(sp)
		bsr.s	sub_1E314
		movem.l	(sp)+,d1-d4
		rts
; ---------------------------------------------------------------------------

sub_1E314:
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
; End of function sub_1E314

; =============== S U B R O U T I N E =======================================

SolidObjectTopSloped:
		lea	(Player_1).w,a1
		moveq	#p1_standing_bit,d6
		movem.l	d1-d4,-(sp)
		bsr.s	sub_1E36C
		movem.l	(sp)+,d1-d4
		rts
; ---------------------------------------------------------------------------

sub_1E36C:
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
; End of function sub_1E36C

; =============== S U B R O U T I N E =======================================

sub_1E410:
		tst.w	y_vel(a1)
		bmi.w	locret_1E4D4
		move.w	x_pos(a1),d0
		sub.w	x_pos(a0),d0
		add.w	d1,d0
		bmi.w	locret_1E4D4
		cmp.w	d2,d0
		bhs.w	locret_1E4D4
		bra.s	loc_1E44C
; ---------------------------------------------------------------------------

loc_1E42E:
		tst.w	y_vel(a1)
		bmi.w	locret_1E4D4
		move.w	x_pos(a1),d0
		sub.w	x_pos(a0),d0
		add.w	d1,d0
		bmi.w	locret_1E4D4
		add.w	d1,d1
		cmp.w	d1,d0
		bhs.w	locret_1E4D4

loc_1E44C:
		tst.b	(Reverse_gravity_flag).w
		bne.w	loc_1E4D6
		move.w	y_pos(a0),d0
		sub.w	d3,d0

loc_1E45A:
		move.w	y_pos(a1),d2
		move.b	y_radius(a1),d1
		ext.w	d1
		add.w	d2,d1
		addq.w	#4,d1
		sub.w	d1,d0
		bhi.w	locret_1E4D4
		cmpi.w	#-$10,d0
		blo.w	locret_1E4D4
		tst.b	$2E(a1)
		bmi.w	locret_1E4D4
		cmpi.b	#id_SonicDeath,routine(a1)
		bhs.w	locret_1E4D4
		add.w	d0,d2
		addq.w	#3,d2
		move.w	d2,y_pos(a1)

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
		move.l	a0,-(sp)
		movea.l	a1,a0
		bsr.w	Sonic_ResetOnFloor
		movea.l	(sp)+,a0

locret_1E4D4:
		rts
; End of function RideObject_SetRide
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
		cmpi.w	#-$10,d1
		blo.s		locret_1E4D4
		tst.b	$2E(a1)
		bmi.s	locret_1E4D4
		cmpi.b	#id_SonicDeath,routine(a1)
		bhs.s	locret_1E4D4
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
		lsr.w	#1,d0
		move.b	(a2,d0.w),d3
		ext.w	d3
		move.w	y_pos(a0),d0
		sub.w	d3,d0
		bra.w	loc_1E45A
; ---------------------------------------------------------------------------

SolidObjCheckSloped:
		tst.w	y_vel(a1)
		bmi.s	locret_1E5DE
		move.w	x_pos(a1),d0
		sub.w	x_pos(a0),d0
		add.w	d1,d0
		bmi.s	locret_1E5DE
		add.w	d1,d1
		cmp.w	d1,d0
		bhs.s	locret_1E5DE
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
		lea	(Player_1).w,a1
		btst	#Status_OnObj,status(a0)
		beq.s	++
		bsr.w	SonicOnObjHitFloor
		tst.w	d1
		beq.s	+
		bpl.s	++
+		lea	(Player_1).w,a1
		bclr	#Status_OnObj,status(a1)
		bset	#Status_InAir,status(a1)
		bclr	#Status_OnObj,status(a0)
+		moveq	#0,d4

locret_1E5DE:
		rts
; End of function CheckPlayerReleaseFromObj
