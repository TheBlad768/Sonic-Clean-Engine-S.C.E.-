; ---------------------------------------------------------------------------
; Find floor subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Player_AnglePos:
		move.l	(Primary_collision_addr).w,(Collision_addr).w
		cmpi.b	#$C,top_solid_bit(a0)
		beq.s	.check
		move.l	(Secondary_collision_addr).w,(Collision_addr).w

.check
		move.b	top_solid_bit(a0),d5
		btst	#status.player.on_object,status(a0)				; is player standing on an object?
		beq.s	loc_EC5A							; if not, branch

		; clear
		moveq	#0,d0
		move.b	d0,(Primary_Angle).w
		move.b	d0,(Secondary_Angle).w
		rts
; ---------------------------------------------------------------------------

loc_EC5A:
		moveq	#3,d0
		move.b	d0,(Primary_Angle).w
		move.b	d0,(Secondary_Angle).w
		moveq	#$20,d0
		add.b	angle(a0),d0
		bpl.s	loc_EC7C
		move.b	angle(a0),d0
		bpl.s	loc_EC76
		subq.b	#1,d0

loc_EC76:
		addi.b	#$20,d0
		bra.s	loc_EC88
; ---------------------------------------------------------------------------

loc_EC7C:
		move.b	angle(a0),d0
		bpl.s	loc_EC84
		addq.b	#1,d0

loc_EC84:
		addi.b	#$1F,d0

loc_EC88:
		andi.b	#$C0,d0
		cmpi.b	#$40,d0
		beq.w	Player_WalkVertL
		cmpi.b	#$80,d0
		beq.w	Player_WalkCeiling
		cmpi.b	#$C0,d0
		beq.w	Player_WalkVertR
		move.w	y_pos(a0),d2
		move.w	x_pos(a0),d3
		moveq	#0,d0
		move.b	y_radius(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	x_radius(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(Primary_Angle).w,a4
		lea	($10).w,a3
		moveq	#0,d6
		bsr.w	FindFloor
		move.w	d1,-(sp)
		move.w	y_pos(a0),d2
		move.w	x_pos(a0),d3
		moveq	#0,d0
		move.b	y_radius(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	x_radius(a0),d0
		ext.w	d0
		neg.w	d0
		add.w	d0,d3
		lea	(Secondary_Angle).w,a4
		lea	($10).w,a3
		moveq	#0,d6
		bsr.w	FindFloor
		move.w	(sp)+,d0
		bsr.s	Player_Angle
		tst.w	d1
		beq.s	locret_ED12
		bpl.s	loc_ED14
		cmpi.w	#-$E,d1
		blt.s	locret_ED12
		add.w	d1,y_pos(a0)

locret_ED12:
		rts
; ---------------------------------------------------------------------------

loc_ED14:
		tst.b	stick_to_convex(a0)
		bne.s	loc_ED32
		move.b	x_vel(a0),d0
		bpl.s	loc_ED22
		neg.b	d0

loc_ED22:
		addq.b	#4,d0
		cmpi.b	#$E,d0
		blo.s	loc_ED2E
		move.b	#$E,d0

loc_ED2E:
		cmp.b	d0,d1
		bgt.s	loc_ED38

loc_ED32:
		add.w	d1,y_pos(a0)
		rts
; ---------------------------------------------------------------------------

loc_ED38:
		bset	#status.player.in_air,status(a0)
		bclr	#status.player.pushing,status(a0)
		move.b	#AniIDSonAni_Run,prev_anim(a0)
		rts

; =============== S U B R O U T I N E =======================================

Player_Angle:
		move.w	d0,d3
		move.b	(Secondary_Angle).w,d2
		cmp.w	d0,d1
		ble.s	loc_ED5E
		move.b	(Primary_Angle).w,d2
		move.w	d1,d3
		move.w	d0,d1

loc_ED5E:
		btst	#0,d2
		bne.s	loc_ED7A
		tst.b	stick_to_convex(a0)
		bne.s	loc_ED74
		move.b	d2,d0
		sub.b	angle(a0),d0
		bpl.s	loc_ED6E
		neg.b	d0

loc_ED6E:
		cmpi.b	#$20,d0
		bhs.s	loc_ED7A

loc_ED74:
		move.b	d2,angle(a0)
		rts
; ---------------------------------------------------------------------------

loc_ED7A:
		moveq	#$20,d2
		add.b	angle(a0),d2
		andi.b	#$C0,d2
		move.b	d2,angle(a0)
		rts

; =============== S U B R O U T I N E =======================================

Player_WalkVertR:
		move.w	y_pos(a0),d2
		move.w	x_pos(a0),d3
		moveq	#0,d0
		move.b	x_radius(a0),d0
		ext.w	d0
		neg.w	d0
		add.w	d0,d2
		move.b	y_radius(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(Primary_Angle).w,a4
		lea	($10).w,a3
		moveq	#0,d6
		bsr.w	FindWall
		move.w	d1,-(sp)
		move.w	y_pos(a0),d2
		move.w	x_pos(a0),d3
		moveq	#0,d0
		move.b	x_radius(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	y_radius(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(Secondary_Angle).w,a4
		lea	($10).w,a3
		moveq	#0,d6
		bsr.w	FindWall
		move.w	(sp)+,d0
		bsr.w	Player_Angle
		tst.w	d1
		beq.s	locret_EE00
		bpl.s	loc_EE22
		cmpi.w	#-$E,d1
		blt.s	locret_EE00
		add.w	d1,x_pos(a0)

locret_EE00:
		rts
; ---------------------------------------------------------------------------

loc_EE22:
		tst.b	stick_to_convex(a0)
		bne.s	loc_EE40
		move.b	y_vel(a0),d0
		bpl.s	loc_EE30
		neg.b	d0

loc_EE30:
		addq.b	#4,d0
		cmpi.b	#$E,d0
		blo.s	loc_EE3C
		move.b	#$E,d0

loc_EE3C:
		cmp.b	d0,d1
		bgt.s	loc_EE46

loc_EE40:
		add.w	d1,x_pos(a0)
		rts
; ---------------------------------------------------------------------------

loc_EE46:
		bset	#status.player.in_air,status(a0)
		bclr	#status.player.pushing,status(a0)
		move.b	#AniIDSonAni_Run,prev_anim(a0)
		rts

; =============== S U B R O U T I N E =======================================

Player_WalkCeiling:
		move.w	y_pos(a0),d2
		move.w	x_pos(a0),d3
		moveq	#0,d0
		move.b	y_radius(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		move.b	x_radius(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(Primary_Angle).w,a4
		lea	(-$10).w,a3
		move.w	#$800,d6
		bsr.w	FindFloor
		move.w	d1,-(sp)
		move.w	y_pos(a0),d2
		move.w	x_pos(a0),d3
		moveq	#0,d0
		move.b	y_radius(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		move.b	x_radius(a0),d0
		ext.w	d0
		sub.w	d0,d3
		lea	(Secondary_Angle).w,a4
		lea	(-$10).w,a3
		move.w	#$800,d6
		bsr.w	FindFloor
		move.w	(sp)+,d0
		bsr.w	Player_Angle
		tst.w	d1
		beq.s	locret_EECE
		bpl.s	loc_EED0
		cmpi.w	#-$E,d1
		blt.s	locret_EECE
		sub.w	d1,y_pos(a0)

locret_EECE:
		rts
; ---------------------------------------------------------------------------

loc_EED0:
		tst.b	stick_to_convex(a0)
		bne.s	loc_EEEE
		move.b	x_vel(a0),d0
		bpl.s	loc_EEDE
		neg.b	d0

loc_EEDE:
		addq.b	#4,d0
		cmpi.b	#$E,d0
		blo.s	loc_EEEA
		move.b	#$E,d0

loc_EEEA:
		cmp.b	d0,d1
		bgt.s	loc_EEF4

loc_EEEE:
		sub.w	d1,y_pos(a0)
		rts
; ---------------------------------------------------------------------------

loc_EEF4:
		bset	#status.player.in_air,status(a0)
		bclr	#status.player.pushing,status(a0)
		move.b	#AniIDSonAni_Run,prev_anim(a0)
		rts

; =============== S U B R O U T I N E =======================================

Player_WalkVertL:
		move.w	y_pos(a0),d2
		move.w	x_pos(a0),d3
		moveq	#0,d0
		move.b	x_radius(a0),d0
		ext.w	d0
		sub.w	d0,d2
		move.b	y_radius(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eori.w	#$F,d3
		lea	(Primary_Angle).w,a4
		lea	(-$10).w,a3
		move.w	#$400,d6
		bsr.w	FindWall
		move.w	d1,-(sp)
		move.w	y_pos(a0),d2
		move.w	x_pos(a0),d3
		moveq	#0,d0
		move.b	x_radius(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	y_radius(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eori.w	#$F,d3
		lea	(Secondary_Angle).w,a4
		lea	(-$10).w,a3
		move.w	#$400,d6
		bsr.w	FindWall
		move.w	(sp)+,d0
		bsr.w	Player_Angle
		tst.w	d1
		beq.s	locret_EF7C
		bpl.s	loc_EF7E
		cmpi.w	#-$E,d1
		blt.s	locret_EF7C
		sub.w	d1,x_pos(a0)

locret_EF7C:
		rts
; ---------------------------------------------------------------------------

loc_EF7E:
		tst.b	stick_to_convex(a0)
		bne.s	loc_EF9C
		move.b	y_vel(a0),d0
		bpl.s	loc_EF8C
		neg.b	d0

loc_EF8C:
		addq.b	#4,d0
		cmpi.b	#$E,d0
		blo.s	loc_EF98
		move.b	#$E,d0

loc_EF98:
		cmp.b	d0,d1
		bgt.s	loc_EFA2

loc_EF9C:
		sub.w	d1,x_pos(a0)
		rts
; ---------------------------------------------------------------------------

loc_EFA2:
		bset	#status.player.in_air,status(a0)
		bclr	#status.player.pushing,status(a0)
		move.b	#AniIDSonAni_Run,prev_anim(a0)
		rts

; =============== S U B R O U T I N E =======================================

GetFloorPosition_BG:
		movea.l	(Level_layout_addr_ROM).w,a1
		move.w	d2,d0
		lsr.w	#5,d0
		and.w	(Layout_row_index_mask).w,d0
		move.w	d3,d1
		lsr.w	#3,d1
		move.w	d1,d4
		lsr.w	#4,d1
		add.w	d1,d1								; chunk ID to word
		add.w	$A(a1,d0.w),d1
		adda.w	d1,a1
		moveq	#0,d1
		move.w	(a1),d1								; move 128*128 chunk ID to d1
		lsl.w	#7,d1								; multiply by $80
		move.w	d2,d0
		andi.w	#$70,d0
		add.w	d0,d1
		andi.w	#$E,d4
		add.w	d4,d1
		movea.l	(Level_data_addr_RAM.128x128RAM).w,a1
		adda.l	d1,a1
		rts

; =============== S U B R O U T I N E =======================================

GetFloorPosition_FG:
		movea.l	(Level_layout_addr_ROM).w,a1
		move.w	d2,d0
		lsr.w	#5,d0
		and.w	(Layout_row_index_mask).w,d0
		move.w	d3,d1
		lsr.w	#3,d1
		move.w	d1,d4
		lsr.w	#4,d1
		add.w	d1,d1								; chunk ID to word
		add.w	8(a1,d0.w),d1
		adda.w	d1,a1
		moveq	#0,d1
		move.w	(a1),d1								; move 128*128 chunk ID to d1
		lsl.w	#7,d1								; multiply by $80
		move.w	d2,d0
		andi.w	#$70,d0
		add.w	d0,d1
		andi.w	#$E,d4
		add.w	d4,d1
		movea.l	(Level_data_addr_RAM.128x128RAM).w,a1
		adda.l	d1,a1
		rts

; =============== S U B R O U T I N E =======================================

FindFloor:
		lea	GetFloorPosition_FG(pc),a5
		tst.b	(Background_collision_flag).w
		beq.s	sub_F264
		bsr.s	sub_F264
		move.b	(a4),Primary_Angle_save-Primary_Angle(a4)
		move.w	d1,-(sp)
		sub.w	(Camera_X_diff).w,d3
		sub.w	(Camera_Y_diff).w,d2
		lea	GetFloorPosition_BG(pc),a5
		bsr.s	sub_F264
		add.w	(Camera_X_diff).w,d3
		add.w	(Camera_Y_diff).w,d2
		move.w	(sp)+,d0
		cmp.w	d0,d1
		ble.s	.return
		move.b	Primary_Angle_save-Primary_Angle(a4),(a4)
		move.w	d0,d1

.return
		rts

; =============== S U B R O U T I N E =======================================

sub_F264:
		jsr	(a5)
		move.w	(a1),d0
		move.w	d0,d4
		andi.w	#$3FF,d0
		beq.s	loc_F274
		btst	d5,d4
		bne.s	loc_F282

loc_F274:
		add.w	a3,d2
		bsr.w	FindFloor2
		sub.w	a3,d2
		addi.w	#$10,d1
		rts
; ---------------------------------------------------------------------------

loc_F282:
		movea.l	(Collision_addr).w,a2
		add.w	d0,d0
		move.b	(a2,d0.w),d0
		andi.w	#$FF,d0
		beq.s	loc_F274
		lea	(AngleArray).l,a2
		move.b	(a2,d0.w),(a4)
		lsl.w	#4,d0
		move.w	d3,d1
		btst	#$A,d4
		beq.s	loc_F2AA
		not.w	d1
		neg.b	(a4)

loc_F2AA:
		btst	#$B,d4
		beq.s	loc_F2BA
		addi.b	#$40,(a4)
		neg.b	(a4)
		subi.b	#$40,(a4)

loc_F2BA:
		andi.w	#$F,d1
		add.w	d0,d1
		lea	(HeightMaps).l,a2
		move.b	(a2,d1.w),d0
		ext.w	d0
		eor.w	d6,d4
		btst	#$B,d4
		beq.s	loc_F2D6
		neg.w	d0

loc_F2D6:
		tst.w	d0
		beq.s	loc_F274
		bmi.s	loc_F2F2
		cmpi.b	#$10,d0
		beq.s	loc_F2FE
		move.w	d2,d1
		andi.w	#$F,d1
		add.w	d1,d0
		move.w	#$F,d1
		sub.w	d0,d1
		rts
; ---------------------------------------------------------------------------

loc_F2F2:
		move.w	d2,d1
		andi.w	#$F,d1
		add.w	d1,d0
		bpl.w	loc_F274

loc_F2FE:
		sub.w	a3,d2
		bsr.s	FindFloor2
		add.w	a3,d2
		subi.w	#$10,d1
		rts

; =============== S U B R O U T I N E =======================================

FindFloor2:
		jsr	(a5)
		move.w	(a1),d0
		move.w	d0,d4
		andi.w	#$3FF,d0
		beq.s	loc_F31C
		btst	d5,d4
		bne.s	loc_F32A

loc_F31C:
		move.w	#$F,d1
		move.w	d2,d0
		andi.w	#$F,d0
		sub.w	d0,d1
		rts
; ---------------------------------------------------------------------------

loc_F32A:
		movea.l	(Collision_addr).w,a2
		add.w	d0,d0
		move.b	(a2,d0.w),d0
		andi.w	#$FF,d0
		beq.s	loc_F31C
		lea	(AngleArray).l,a2
		move.b	(a2,d0.w),(a4)
		lsl.w	#4,d0
		move.w	d3,d1
		btst	#$A,d4
		beq.s	loc_F352
		not.w	d1
		neg.b	(a4)

loc_F352:
		btst	#$B,d4
		beq.s	loc_F362
		addi.b	#$40,(a4)
		neg.b	(a4)
		subi.b	#$40,(a4)

loc_F362:
		andi.w	#$F,d1
		add.w	d0,d1
		lea	(HeightMaps).l,a2
		move.b	(a2,d1.w),d0
		ext.w	d0
		eor.w	d6,d4
		btst	#$B,d4
		beq.s	loc_F37E
		neg.w	d0

loc_F37E:
		tst.w	d0
		beq.s	loc_F31C
		bmi.s	loc_F394
		move.w	d2,d1
		andi.w	#$F,d1
		add.w	d1,d0
		move.w	#$F,d1
		sub.w	d0,d1
		rts
; ---------------------------------------------------------------------------

loc_F394:
		move.w	d2,d1
		andi.w	#$F,d1
		add.w	d1,d0
		bpl.w	loc_F31C
		not.w	d1
		rts

; =============== S U B R O U T I N E =======================================

Ring_FindFloor:
		lea	GetFloorPosition_FG(pc),a5
		tst.b	(Background_collision_flag).w
		beq.s	sub_F3DE
		bsr.s	sub_F3DE
		move.b	(a4),Primary_Angle_save-Primary_Angle(a4)
		move.w	d1,-(sp)
		sub.w	(Camera_X_diff).w,d3
		sub.w	(Camera_Y_diff).w,d2
		lea	GetFloorPosition_BG(pc),a5
		bsr.s	sub_F3DE
		add.w	(Camera_X_diff).w,d3
		add.w	(Camera_Y_diff).w,d2
		move.w	(sp)+,d0
		cmp.w	d0,d1
		ble.s	.return
		move.b	Primary_Angle_save-Primary_Angle(a4),(a4)
		move.w	d0,d1

.return
		rts

; =============== S U B R O U T I N E =======================================

sub_F3DE:
		jsr	(a5)
		move.w	(a1),d0
		move.w	d0,d4
		andi.w	#$3FF,d0
		beq.s	loc_F3EE
		btst	d5,d4
		bne.s	loc_F3F4

loc_F3EE:
		move.w	#$10,d1
		rts
; ---------------------------------------------------------------------------

loc_F3F4:
		movea.l	(Collision_addr).w,a2
		add.w	d0,d0
		move.b	(a2,d0.w),d0
		andi.w	#$FF,d0
		beq.s	loc_F3EE
		lea	(AngleArray).l,a2
		move.b	(a2,d0.w),(a4)
		lsl.w	#4,d0
		move.w	d3,d1
		btst	#$A,d4
		beq.s	loc_F41C
		not.w	d1
		neg.b	(a4)

loc_F41C:
		btst	#$B,d4
		beq.s	loc_F42C
		addi.b	#$40,(a4)
		neg.b	(a4)
		subi.b	#$40,(a4)

loc_F42C:
		andi.w	#$F,d1
		add.w	d0,d1
		lea	(HeightMaps).l,a2
		move.b	(a2,d1.w),d0
		ext.w	d0
		eor.w	d6,d4
		btst	#$B,d4
		beq.s	loc_F448
		neg.w	d0

loc_F448:
		tst.w	d0
		beq.s	loc_F3EE
		bmi.s	loc_F464
		cmpi.b	#$10,d0
		beq.s	loc_F470
		move.w	d2,d1
		andi.w	#$F,d1
		add.w	d1,d0
		move.w	#$F,d1
		sub.w	d0,d1
		rts
; ---------------------------------------------------------------------------

loc_F464:
		move.w	d2,d1
		andi.w	#$F,d1
		add.w	d1,d0
		bpl.s	loc_F3EE

loc_F470:
		sub.w	a3,d2
		bsr.w	FindFloor2
		add.w	a3,d2
		subi.w	#$10,d1
		rts

; =============== S U B R O U T I N E =======================================

FindWall:
		lea	GetFloorPosition_FG(pc),a5
		tst.b	(Background_collision_flag).w
		beq.s	sub_F4DC
		bsr.s	sub_F4DC
		move.b	(a4),Primary_Angle_save-Primary_Angle(a4)
		move.w	d1,-(sp)
		move.w	a3,d0
		bpl.s	loc_F4A4
		eori.w	#$F,d3
		sub.w	(Camera_X_diff).w,d3
		eori.w	#$F,d3
		bra.s	loc_F4A8
; ---------------------------------------------------------------------------

loc_F4A4:
		sub.w	(Camera_X_diff).w,d3

loc_F4A8:
		sub.w	(Camera_Y_diff).w,d2
		lea	GetFloorPosition_BG(pc),a5
		bsr.s	sub_F4DC
		move.w	a3,d0
		bpl.s	loc_F4C6
		eori.w	#$F,d3
		add.w	(Camera_X_diff).w,d3
		eori.w	#$F,d3
		bra.s	loc_F4CA
; ---------------------------------------------------------------------------

loc_F4C6:
		add.w	(Camera_X_diff).w,d3

loc_F4CA:
		add.w	(Camera_Y_diff).w,d2
		move.w	(sp)+,d0
		cmp.w	d0,d1
		ble.s	.return
		move.b	Primary_Angle_save-Primary_Angle(a4),(a4)
		move.w	d0,d1

.return
		rts

; =============== S U B R O U T I N E =======================================

sub_F4DC:
		jsr	(a5)
		move.w	(a1),d0
		move.w	d0,d4
		andi.w	#$3FF,d0
		beq.s	loc_F4EC
		btst	d5,d4
		bne.s	loc_F4FA

loc_F4EC:
		add.w	a3,d3
		bsr.w	FindWall2
		sub.w	a3,d3
		addi.w	#$10,d1
		rts
; ---------------------------------------------------------------------------

loc_F4FA:
		movea.l	(Collision_addr).w,a2
		add.w	d0,d0
		move.b	(a2,d0.w),d0
		andi.w	#$FF,d0
		beq.s	loc_F4EC
		lea	(AngleArray).l,a2
		move.b	(a2,d0.w),(a4)
		lsl.w	#4,d0
		move.w	d2,d1
		btst	#$B,d4
		beq.s	loc_F52A
		not.w	d1
		addi.b	#$40,(a4)
		neg.b	(a4)
		subi.b	#$40,(a4)

loc_F52A:
		btst	#$A,d4
		beq.s	loc_F532
		neg.b	(a4)

loc_F532:
		andi.w	#$F,d1
		add.w	d0,d1
		lea	(HeightMapsRot).l,a2
		move.b	(a2,d1.w),d0
		ext.w	d0
		eor.w	d6,d4
		btst	#$A,d4
		beq.s	loc_F54E
		neg.w	d0

loc_F54E:
		tst.w	d0
		beq.s	loc_F4EC
		bmi.s	loc_F56A
		cmpi.b	#$10,d0
		beq.s	loc_F576
		move.w	d3,d1
		andi.w	#$F,d1
		add.w	d1,d0
		move.w	#$F,d1
		sub.w	d0,d1
		rts
; ---------------------------------------------------------------------------

loc_F56A:
		move.w	d3,d1
		andi.w	#$F,d1
		add.w	d1,d0
		bpl.w	loc_F4EC

loc_F576:
		sub.w	a3,d3
		bsr.s	FindWall2
		add.w	a3,d3
		subi.w	#$10,d1
		rts

; =============== S U B R O U T I N E =======================================

FindWall2:
		jsr	(a5)
		move.w	(a1),d0
		move.w	d0,d4
		andi.w	#$3FF,d0
		beq.s	loc_F594
		btst	d5,d4
		bne.s	loc_F5A2

loc_F594:
		move.w	#$F,d1
		move.w	d3,d0
		andi.w	#$F,d0
		sub.w	d0,d1
		rts
; ---------------------------------------------------------------------------

loc_F5A2:
		movea.l	(Collision_addr).w,a2
		add.w	d0,d0
		move.b	(a2,d0.w),d0
		andi.w	#$FF,d0
		beq.s	loc_F594
		lea	(AngleArray).l,a2
		move.b	(a2,d0.w),(a4)
		lsl.w	#4,d0
		move.w	d2,d1
		btst	#$B,d4
		beq.s	loc_F5D2
		not.w	d1
		addi.b	#$40,(a4)
		neg.b	(a4)
		subi.b	#$40,(a4)

loc_F5D2:
		btst	#$A,d4
		beq.s	loc_F5DA
		neg.b	(a4)

loc_F5DA:
		andi.w	#$F,d1
		add.w	d0,d1
		lea	(HeightMapsRot).l,a2
		move.b	(a2,d1.w),d0
		ext.w	d0
		eor.w	d6,d4
		btst	#$A,d4
		beq.s	loc_F5F6
		neg.w	d0

loc_F5F6:
		tst.w	d0
		beq.s	loc_F594
		bmi.s	loc_F60C
		move.w	d3,d1
		andi.w	#$F,d1
		add.w	d1,d0
		move.w	#$F,d1
		sub.w	d0,d1
		rts
; ---------------------------------------------------------------------------

loc_F60C:
		move.w	d3,d1
		andi.w	#$F,d1
		add.w	d1,d0
		bpl.w	loc_F594
		not.w	d1
		rts

; =============== S U B R O U T I N E =======================================

sub_F6B4:
		move.l	(Primary_collision_addr).w,(Collision_addr).w
		cmpi.b	#$C,top_solid_bit(a0)
		beq.s	.check
		move.l	(Secondary_collision_addr).w,(Collision_addr).w

.check
		move.b	lrb_solid_bit(a0),d5
		move.l	x_pos(a0),d3
		move.l	y_pos(a0),d2
		move.w	x_vel(a0),d1
		ext.l	d1
		asl.l	#8,d1
		add.l	d1,d3
		move.w	y_vel(a0),d1
		ext.l	d1
		asl.l	#8,d1
		add.l	d1,d2
		swap	d2
		swap	d3
		move.b	d0,(Primary_Angle).w
		move.b	d0,(Secondary_Angle).w
		move.b	d0,d1
		addi.b	#$20,d0
		bpl.s	loc_F708
		move.b	d1,d0
		bpl.s	loc_F702
		subq.b	#1,d0

loc_F702:
		addi.b	#$20,d0
		bra.s	loc_F712
; ---------------------------------------------------------------------------

loc_F708:
		move.b	d1,d0
		bpl.s	loc_F70E
		addq.b	#1,d0

loc_F70E:
		addi.b	#$1F,d0

loc_F712:
		andi.b	#$C0,d0
		beq.w	sub_F828
		cmpi.b	#$80,d0
		beq.w	CheckCeilingDist_WithRadius
		cmpi.b	#$40,d0
		beq.w	sub_FDC8
		bra.w	sub_FAA4

; =============== S U B R O U T I N E =======================================

CalcRoomInFront:
		move.l	(Primary_collision_addr).w,(Collision_addr).w
		cmpi.b	#$C,top_solid_bit(a0)
		beq.s	.check
		move.l	(Secondary_collision_addr).w,(Collision_addr).w

.check
		move.b	lrb_solid_bit(a0),d5
		move.l	x_pos(a0),d3
		move.l	y_pos(a0),d2
		move.w	x_vel(a0),d1
		ext.l	d1
		asl.l	#8,d1
		add.l	d1,d3
		move.w	y_vel(a0),d1

		; check gravity
		tst.b	(Reverse_gravity_flag).w
		beq.s	.notgrav
		neg.w	d1								; reverse it

.notgrav
		ext.l	d1
		asl.l	#8,d1
		add.l	d1,d2
		swap	d2
		swap	d3
		move.b	d0,(Primary_Angle).w
		move.b	d0,(Secondary_Angle).w
		move.b	d0,d1
		addi.b	#$20,d0
		bpl.s	loc_F680
		move.b	d1,d0
		bpl.s	loc_F67A
		subq.b	#1,d0

loc_F67A:
		addi.b	#$20,d0
		bra.s	loc_F68A
; ---------------------------------------------------------------------------

loc_F680:
		move.b	d1,d0
		bpl.s	loc_F686
		addq.b	#1,d0

loc_F686:
		addi.b	#$1F,d0

loc_F68A:
		andi.b	#$C0,d0
		beq.w	CheckFloorDist_Part2
		cmpi.b	#$80,d0
		beq.w	CheckCeilingDist_Part2
		andi.b	#$38,d1
		bne.s	.skip
		addq.w	#8,d2

		; fix by devon
		btst	#status.player.rolling,status(a0)				; is Sonic rolling?
		beq.s	.skip								; if not, branch
		subq.w	#5,d2								; if so, move push sensor up a bit

		; check gravity
		tst.b	(Reverse_gravity_flag).w
		beq.s	.skip
		subi.w	#-(5+5),d2

.skip
		cmpi.b	#$40,d0
		beq.w	CheckLeftWallDist_Part2
		bra.w	CheckRightWallDist_Part2

; ---------------------------------------------------------------------------
; Subroutine to calculate how much space is empty above Sonic's/Tails' head
; d0 = input angle perpendicular to the spine
; d1 = output about how many pixels are overhead (up to some high enough amount)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

CalcRoomOverHead:
		move.l	(Primary_collision_addr).w,(Collision_addr).w
		cmpi.b	#$C,top_solid_bit(a0)
		beq.s	.check
		move.l	(Secondary_collision_addr).w,(Collision_addr).w

.check
		move.b	lrb_solid_bit(a0),d5
		move.b	d0,(Primary_Angle).w
		move.b	d0,(Secondary_Angle).w
		addi.b	#$20,d0
		andi.b	#$C0,d0
		cmpi.b	#$40,d0
		beq.w	CheckLeftCeilingDist
		cmpi.b	#$80,d0
		beq.w	Sonic_CheckCeiling2
		cmpi.b	#$C0,d0
		beq.w	CheckRightCeilingDist
		bra.s	Sonic_CheckFloor2

; ---------------------------------------------------------------------------
; Subroutine to check if Sonic/Tails is near the floor
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Sonic_CheckFloor:
		move.l	(Primary_collision_addr).w,(Collision_addr).w
		cmpi.b	#$C,top_solid_bit(a0)
		beq.s	.check
		move.l	(Secondary_collision_addr).w,(Collision_addr).w

.check
		move.b	top_solid_bit(a0),d5

Sonic_CheckFloor2:
		move.w	y_pos(a0),d2
		move.w	x_pos(a0),d3
		moveq	#0,d0
		move.b	y_radius(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	x_radius(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(Primary_Angle).w,a4
		lea	($10).w,a3
		moveq	#0,d6
		bsr.w	FindFloor
		move.w	d1,-(sp)
		move.w	y_pos(a0),d2
		move.w	x_pos(a0),d3
		moveq	#0,d0
		move.b	y_radius(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	x_radius(a0),d0
		ext.w	d0
		sub.w	d0,d3
		lea	(Secondary_Angle).w,a4
		lea	($10).w,a3
		moveq	#0,d6
		bsr.w	FindFloor
		move.w	(sp)+,d0
		move.b	#0,d2

loc_F7E2:
		move.b	(Secondary_Angle).w,d3
		cmp.w	d0,d1
		ble.s	.skip
		move.b	(Primary_Angle).w,d3
		exg	d0,d1

.skip
		btst	#0,d3
		beq.s	.return
		move.b	d2,d3

.return
		rts

; ---------------------------------------------------------------------------
; Checks a 16x16 block to find solid ground. May check an additional
; 16x16 block up for ceilings.
; d2 = y_pos
; d3 = x_pos
; d5 = ($c,$d) or ($e,$f) - solidity type bit (L/R/B or top)
; returns relevant block ID in (a1)
; returns distance in d1
; returns angle in d3, or zero if angle was odd
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

CheckFloorDist:
		move.w	y_pos(a0),d2
		move.w	x_pos(a0),d3

CheckFloorDist_Part2:
		addi.w	#$A,d2
		lea	(Primary_Angle).w,a4
		lea	($10).w,a3
		moveq	#0,d6
		bsr.w	FindFloor
		move.b	#0,d2

; d2 what to use as angle if (Primary_Angle).w is odd
; returns angle in d3, or value in d2 if angle was odd
loc_F81A:
		move.b	(Primary_Angle).w,d3
		btst	#0,d3
		beq.s	.return
		move.b	d2,d3

.return
		rts

; =============== S U B R O U T I N E =======================================

sub_F828:
		move.b	x_radius(a0),d0
		ext.w	d0
		add.w	d0,d2
		lea	(Primary_Angle).w,a4
		lea	($10).w,a3
		moveq	#0,d6
		bsr.w	FindFloor
		move.b	#0,d2
		bra.s	loc_F81A

; =============== S U B R O U T I N E =======================================

sub_F846:
		move.w	x_pos(a0),d3
		move.w	y_pos(a0),d2
		subq.w	#4,d2
		move.l	(Primary_collision_addr).w,(Collision_addr).w
		cmpi.b	#$D,lrb_solid_bit(a0)
		beq.s	.check
		move.l	(Secondary_collision_addr).w,(Collision_addr).w

.check
		lea	(Primary_Angle).w,a4
		clr.b	(a4)
		lea	($10).w,a3
		moveq	#0,d6
		move.b	lrb_solid_bit(a0),d5
		movem.l	a4-a6,-(sp)
		bsr.w	FindFloor
		movem.l	(sp)+,a4-a6
		move.b	(Primary_Angle).w,d3
		btst	#0,d3
		beq.s	.return
		move.b	#0,d3

.return
		rts

; =============== S U B R O U T I N E =======================================

ChkFloorEdge:
		move.w	x_pos(a0),d3

ChkFloorEdge_Part2:
		move.w	y_pos(a0),d2
		moveq	#0,d0
		move.b	y_radius(a0),d0
		ext.w	d0
		add.w	d0,d2

ChkFloorEdge_Part3:
		move.l	(Primary_collision_addr).w,(Collision_addr).w
		cmpi.b	#$C,top_solid_bit(a0)
		beq.s	.check
		move.l	(Secondary_collision_addr).w,(Collision_addr).w

.check
		lea	(Primary_Angle).w,a4
		clr.b	(a4)
		lea	($10).w,a3
		moveq	#0,d6
		move.b	top_solid_bit(a0),d5
		movem.l	a4-a6,-(sp)
		bsr.w	FindFloor
		movem.l	(sp)+,a4-a6
		move.b	(Primary_Angle).w,d3
		btst	#0,d3
		beq.s	.return
		move.b	#0,d3

.return
		rts

; =============== S U B R O U T I N E =======================================

SonicOnObjHitFloor:
		move.w	x_pos(a1),d3

SonicOnObjHitFloor2:
		move.w	y_pos(a1),d2
		moveq	#0,d0
		move.b	y_radius(a1),d0
		ext.w	d0
		add.w	d0,d2
		move.l	(Primary_collision_addr).w,(Collision_addr).w
		cmpi.b	#$C,top_solid_bit(a1)
		beq.s	.check
		move.l	(Secondary_collision_addr).w,(Collision_addr).w

.check
		lea	(Primary_Angle).w,a4
		clr.b	(a4)
		lea	($10).w,a3
		moveq	#0,d6
		move.b	top_solid_bit(a1),d5
		bsr.w	FindFloor
		move.b	(Primary_Angle).w,d3
		btst	#0,d3
		beq.s	.return
		move.b	#0,d3

.return
		rts

; ---------------------------------------------------------------------------
; Subroutine checking if an object should interact with the floor
; (objects such as a monitor Sonic bumps from underneath)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

ObjCheckFloorDist:
		move.w	x_pos(a0),d3

ObjCheckFloorDist2:
		move.w	y_pos(a0),d2							; get object position
		move.b	y_radius(a0),d0							; get object height
		ext.w	d0
		add.w	d0,d2
		lea	(Primary_Angle).w,a4
		clr.b	(a4)
		lea	($10).w,a3
		moveq	#0,d6
		moveq	#$C,d5
		bsr.w	FindFloor
		move.b	(Primary_Angle).w,d3
		btst	#0,d3
		beq.s	.return
		move.b	#0,d3

.return
		rts

; =============== S U B R O U T I N E =======================================

CheckRightCeilingDist:
		move.w	y_pos(a0),d2
		move.w	x_pos(a0),d3
		moveq	#0,d0
		move.b	x_radius(a0),d0
		ext.w	d0
		sub.w	d0,d2
		move.b	y_radius(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(Primary_Angle).w,a4
		lea	($10).w,a3
		moveq	#0,d6
		bsr.w	FindWall
		move.w	d1,-(sp)
		move.w	y_pos(a0),d2
		move.w	x_pos(a0),d3
		moveq	#0,d0
		move.b	x_radius(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	y_radius(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(Secondary_Angle).w,a4
		lea	($10).w,a3
		moveq	#0,d6
		bsr.w	FindWall
		move.w	(sp)+,d0
		move.b	#-$40,d2
		bra.w	loc_F7E2

; =============== S U B R O U T I N E =======================================

sub_FA1A:
		move.w	y_pos(a0),d2
		move.w	x_pos(a0),d3
		moveq	#0,d0
		move.b	y_radius(a0),d0
		ext.w	d0
		sub.w	d0,d2
		move.b	x_radius(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(Primary_Angle).w,a4
		lea	($10).w,a3
		moveq	#0,d6
		bsr.w	FindWall
		move.w	d1,-(sp)
		move.w	y_pos(a0),d2
		move.w	x_pos(a0),d3
		moveq	#0,d0
		move.b	y_radius(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	x_radius(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(Secondary_Angle).w,a4
		lea	($10).w,a3
		moveq	#0,d6
		bsr.w	FindWall
		move.w	(sp)+,d0
		move.b	#-$40,d2
		bra.w	loc_F7E2

; =============== S U B R O U T I N E =======================================

CheckRightWallDist:
		move.w	y_pos(a0),d2
		move.w	x_pos(a0),d3

CheckRightWallDist_Part2:
		addi.w	#$A,d3
		lea	(Primary_Angle).w,a4
		lea	($10).w,a3
		moveq	#0,d6
		bsr.w	FindWall
		move.b	#-$40,d2
		bra.w	loc_F81A

; =============== S U B R O U T I N E =======================================

sub_FAA4:
		move.b	x_radius(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(Primary_Angle).w,a4
		lea	($10).w,a3
		moveq	#0,d6
		bsr.w	FindWall
		move.b	#-$40,d2
		bra.w	loc_F81A

; =============== S U B R O U T I N E =======================================

ObjCheckRightWallDist:
		add.w	x_pos(a0),d3

ObjCheckRightWallDist_Part2:
		move.w	y_pos(a0),d2

ObjCheckRightWallDist_Part3:
		lea	(Primary_Angle).w,a4
		clr.b	(a4)
		lea	($10).w,a3
		moveq	#0,d6
		moveq	#$D,d5
		bsr.w	FindWall
		move.b	(Primary_Angle).w,d3
		btst	#0,d3
		beq.s	.return
		move.b	#-$40,d3

.return
		rts

; =============== S U B R O U T I N E =======================================

Sonic_CheckCeiling:
		move.l	(Primary_collision_addr).w,(Collision_addr).w
		cmpi.b	#$C,top_solid_bit(a0)
		beq.s	.check
		move.l	(Secondary_collision_addr).w,(Collision_addr).w

.check
		move.b	top_solid_bit(a0),d5

Sonic_CheckCeiling2:
		move.w	y_pos(a0),d2
		move.w	x_pos(a0),d3
		moveq	#0,d0
		move.b	y_radius(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		move.b	x_radius(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(Primary_Angle).w,a4
		lea	(-$10).w,a3
		move.w	#$800,d6
		bsr.w	FindFloor
		move.w	d1,-(sp)
		move.w	y_pos(a0),d2
		move.w	x_pos(a0),d3
		moveq	#0,d0
		move.b	y_radius(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		move.b	x_radius(a0),d0
		ext.w	d0
		sub.w	d0,d3
		lea	(Secondary_Angle).w,a4
		lea	(-$10).w,a3
		move.w	#$800,d6
		bsr.w	FindFloor
		move.w	(sp)+,d0
		move.b	#$80,d2
		bra.w	loc_F7E2

; =============== S U B R O U T I N E =======================================

sub_FB5A:
		move.w	y_pos(a0),d2
		move.w	x_pos(a0),d3
		moveq	#0,d0
		move.b	y_radius(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		move.b	x_radius(a0),d0
		ext.w	d0
		subq.w	#2,d0
		add.w	d0,d3
		lea	(Primary_Angle).w,a4
		lea	(-$10).w,a3
		move.w	#$800,d6
		bsr.w	FindFloor
		move.w	d1,-(sp)
		move.w	y_pos(a0),d2
		move.w	x_pos(a0),d3
		moveq	#0,d0
		move.b	y_radius(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		move.b	x_radius(a0),d0
		ext.w	d0
		subq.w	#2,d0
		sub.w	d0,d3
		lea	(Secondary_Angle).w,a4
		lea	(-$10).w,a3
		move.w	#$800,d6
		bsr.w	FindFloor
		move.w	(sp)+,d0
		move.b	#$80,d2
		bra.w	loc_F7E2

; =============== S U B R O U T I N E =======================================

CheckCeilingDist:
		move.w	y_pos(a0),d2
		move.w	x_pos(a0),d3

CheckCeilingDist_Part2:
		subi.w	#$A,d2
		eori.w	#$F,d2
		lea	(Primary_Angle).w,a4
		lea	(-$10).w,a3
		move.w	#$800,d6
		bsr.w	FindFloor
		move.b	#$80,d2
		bra.w	loc_F81A

; =============== S U B R O U T I N E =======================================

CheckCeilingDist_WithRadius:
		move.b	x_radius(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		lea	(Primary_Angle).w,a4
		lea	(-$10).w,a3
		move.w	#$800,d6
		bsr.w	FindFloor
		move.b	#$80,d2
		bra.w	loc_F81A

; =============== S U B R O U T I N E =======================================

ObjCheckCeilingDist:
		moveq	#$D,d5

ObjCheckCeilingDist_Part2:
		move.w	x_pos(a0),d3

ObjCheckCeilingDist_Part3:
		move.w	y_pos(a0),d2

ObjCheckCeilingDist_Part4:
		moveq	#0,d0
		move.b	y_radius(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		lea	(Primary_Angle).w,a4
		lea	(-$10).w,a3
		move.w	#$800,d6
		bsr.w	FindFloor
		move.b	(Primary_Angle).w,d3
		btst	#0,d3
		beq.s	.return
		move.b	#$80,d3

.return
		rts

; =============== S U B R O U T I N E =======================================

ChkFloorEdge_ReverseGravity:
		move.w	y_pos(a0),d2
		moveq	#0,d0
		move.b	y_radius(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2

ChkFloorEdge_ReverseGravity_Part2:
		move.l	(Primary_collision_addr).w,(Collision_addr).w
		cmpi.b	#$C,top_solid_bit(a0)
		beq.s	.check
		move.l	(Secondary_collision_addr).w,(Collision_addr).w

.check
		lea	(Primary_Angle).w,a4
		clr.b	(a4)
		lea	(-$10).w,a3
		move.w	#$800,d6
		move.b	top_solid_bit(a0),d5
		movem.l	a4-a6,-(sp)
		bsr.w	FindFloor
		movem.l	(sp)+,a4-a6
		move.b	(Primary_Angle).w,d3
		btst	#0,d3
		beq.s	.return
		move.b	#0,d3

.return
		rts

; =============== S U B R O U T I N E =======================================

CheckLeftCeilingDist:
		move.w	y_pos(a0),d2
		move.w	x_pos(a0),d3
		moveq	#0,d0
		move.b	x_radius(a0),d0
		ext.w	d0
		sub.w	d0,d2
		move.b	y_radius(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eori.w	#$F,d3
		lea	(Primary_Angle).w,a4
		lea	(-$10).w,a3
		move.w	#$400,d6
		bsr.w	FindWall
		move.w	d1,-(sp)
		move.w	y_pos(a0),d2
		move.w	x_pos(a0),d3
		moveq	#0,d0
		move.b	x_radius(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	y_radius(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eori.w	#$F,d3
		lea	(Secondary_Angle).w,a4
		lea	(-$10).w,a3
		move.w	#$400,d6
		bsr.w	FindWall
		move.w	(sp)+,d0
		move.b	#$40,d2
		bra.w	loc_F7E2

; =============== S U B R O U T I N E =======================================

sub_FD32:
		move.w	y_pos(a0),d2
		move.w	x_pos(a0),d3
		moveq	#0,d0
		move.b	y_radius(a0),d0
		ext.w	d0
		sub.w	d0,d2
		move.b	x_radius(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eori.w	#$F,d3
		lea	(Primary_Angle).w,a4
		lea	(-$10).w,a3
		move.w	#$400,d6
		bsr.w	FindWall
		move.w	d1,-(sp)
		move.w	y_pos(a0),d2
		move.w	x_pos(a0),d3
		moveq	#0,d0
		move.b	y_radius(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	x_radius(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eori.w	#$F,d3
		lea	(Secondary_Angle).w,a4
		lea	(-$10).w,a3
		move.w	#$400,d6
		bsr.w	FindWall
		move.w	(sp)+,d0
		move.b	#$40,d2
		bra.w	loc_F7E2

; =============== S U B R O U T I N E =======================================

CheckLeftWallDist:
		move.w	y_pos(a0),d2
		move.w	x_pos(a0),d3

CheckLeftWallDist_Part2:
		subi.w	#$A,d3
		eori.w	#$F,d3
		lea	(Primary_Angle).w,a4
		lea	(-$10).w,a3
		move.w	#$400,d6
		bsr.w	FindWall
		move.b	#$40,d2
		bra.w	loc_F81A

; =============== S U B R O U T I N E =======================================

sub_FDC8:
		move.b	x_radius(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eori.w	#$F,d3
		lea	(Primary_Angle).w,a4
		lea	(-$10).w,a3
		move.w	#$400,d6
		bsr.w	FindWall
		move.b	#$40,d2
		bra.w	loc_F81A

; =============== S U B R O U T I N E =======================================

sub_FDEC:
		move.l	(Primary_collision_addr).w,(Collision_addr).w
		cmpi.b	#$C,top_solid_bit(a0)
		beq.s	.check
		move.l	(Secondary_collision_addr).w,(Collision_addr).w

.check
		move.w	x_pos(a0),d3
		move.w	y_pos(a0),d2
		move.b	y_radius(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eori.w	#$F,d3
		lea	(Primary_Angle).w,a4
		clr.b	(a4)
		lea	(-$10).w,a3
		move.w	#$400,d6
		move.b	lrb_solid_bit(a0),d5
		bsr.w	FindWall
		move.b	(Primary_Angle).w,d3
		btst	#0,d3
		beq.s	.return
		move.b	#$40,d3

.return
		rts

; =============== S U B R O U T I N E =======================================

ObjCheckLeftWallDist:
		add.w	x_pos(a0),d3
		eori.w	#$F,d3								; this was not here in S1/S2, resulting in a bug

ObjCheckLeftWallDist_Part2:
		move.w	y_pos(a0),d2

ObjCheckLeftWallDist_Part3:
		lea	(Primary_Angle).w,a4
		clr.b	(a4)
		lea	(-$10).w,a3
		move.w	#$400,d6
		moveq	#$D,d5
		bsr.w	FindWall
		move.b	(Primary_Angle).w,d3
		btst	#0,d3
		beq.s	.return
		move.b	#$40,d3

.return
		rts
