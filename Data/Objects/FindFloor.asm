
; =============== S U B R O U T I N E =======================================

Player_AnglePos:
		move.l	(Primary_collision_addr).w,(Collision_addr).w
		cmpi.b	#$C,top_solid_bit(a0)
		beq.s	+
		move.l	(Secondary_collision_addr).w,(Collision_addr).w
+		move.b	top_solid_bit(a0),d5
		btst	#3,status(a0)
		beq.s	loc_EC5A
		moveq	#0,d0
		move.b	d0,(Primary_Angle).w
		move.b	d0,(Secondary_Angle).w
		rts
; ---------------------------------------------------------------------------

loc_EC5A:
		moveq	#3,d0
		move.b	d0,(Primary_Angle).w
		move.b	d0,(Secondary_Angle).w
		move.b	$26(a0),d0
		addi.b	#$20,d0
		bpl.s	loc_EC7C
		move.b	$26(a0),d0
		bpl.s	loc_EC76
		subq.b	#1,d0

loc_EC76:
		addi.b	#$20,d0
		bra.s	loc_EC88
; ---------------------------------------------------------------------------

loc_EC7C:
		move.b	$26(a0),d0
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
		movea.w	#$10,a3
		move.w	#0,d6
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
		movea.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindFloor
		move.w	(sp)+,d0
		bsr.w	Player_Angle
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
		tst.b	$3C(a0)
		bne.s	loc_ED32
		move.b	x_vel(a0),d0
		bpl.s	loc_ED22
		neg.b	d0

loc_ED22:
		addq.b	#4,d0
		cmpi.b	#$E,d0
		blo.s		loc_ED2E
		move.b	#$E,d0

loc_ED2E:
		cmp.b	d0,d1
		bgt.s	loc_ED38

loc_ED32:
		add.w	d1,y_pos(a0)
		rts
; ---------------------------------------------------------------------------

loc_ED38:
		bset	#1,status(a0)
		bclr	#5,status(a0)
		move.b	#1,$21(a0)
		rts
; End of function Player_AnglePos

; =============== S U B R O U T I N E =======================================

Player_Angle:
		move.w	d0,d3
		move.b	(Secondary_Angle).w,d2
		cmp.w	d0,d1
		ble.s		loc_ED5E
		move.b	(Primary_Angle).w,d2
		move.w	d1,d3
		move.w	d0,d1

loc_ED5E:
		btst	#0,d2
		bne.s	loc_ED7A
		move.b	d2,d0
		sub.b	$26(a0),d0
		bpl.s	loc_ED6E
		neg.b	d0

loc_ED6E:
		cmpi.b	#$20,d0
		bhs.s	loc_ED7A
		move.b	d2,$26(a0)
		rts
; ---------------------------------------------------------------------------

loc_ED7A:
		move.b	$26(a0),d2
		addi.b	#$20,d2
		andi.b	#$C0,d2
		move.b	d2,$26(a0)
		rts
; End of function Player_Angle
; ---------------------------------------------------------------------------

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
		movea.w	#$10,a3
		move.w	#0,d6
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
		movea.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindWall
		move.w	(sp)+,d0
		bsr.w	Player_Angle
		tst.w	d1
		beq.s	locret_EE00
		bpl.s	loc_EE22
		cmpi.w	#-$E,d1
		blt.s		locret_EE00
		tst.b	$41(a0)
		bne.s	loc_EE02
		add.w	d1,x_pos(a0)

locret_EE00:
		rts
; ---------------------------------------------------------------------------

loc_EE02:
		subq.b	#1,$41(a0)
		move.b	#$C0,$26(a0)
		rts
; ---------------------------------------------------------------------------

loc_EE22:
		tst.b	$3C(a0)
		bne.s	loc_EE40
		move.b	y_vel(a0),d0
		bpl.s	loc_EE30
		neg.b	d0

loc_EE30:
		addq.b	#4,d0
		cmpi.b	#$E,d0
		blo.s		loc_EE3C
		move.b	#$E,d0

loc_EE3C:
		cmp.b	d0,d1
		bgt.s	loc_EE46

loc_EE40:
		add.w	d1,x_pos(a0)
		rts
; ---------------------------------------------------------------------------

loc_EE46:
		bset	#1,status(a0)
		bclr	#5,status(a0)
		move.b	#1,$21(a0)
		rts
; ---------------------------------------------------------------------------

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
		movea.w	#-$10,a3
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
		movea.w	#-$10,a3
		move.w	#$800,d6
		bsr.w	FindFloor
		move.w	(sp)+,d0
		bsr.w	Player_Angle
		tst.w	d1
		beq.s	locret_EECE
		bpl.s	loc_EED0
		cmpi.w	#-$E,d1
		blt.s		locret_EECE
		sub.w	d1,y_pos(a0)

locret_EECE:
		rts
; ---------------------------------------------------------------------------

loc_EED0:
		tst.b	$3C(a0)
		bne.s	loc_EEEE
		move.b	x_vel(a0),d0
		bpl.s	loc_EEDE
		neg.b	d0

loc_EEDE:
		addq.b	#4,d0
		cmpi.b	#$E,d0
		blo.s		loc_EEEA
		move.b	#$E,d0

loc_EEEA:
		cmp.b	d0,d1
		bgt.s	loc_EEF4

loc_EEEE:
		sub.w	d1,y_pos(a0)
		rts
; ---------------------------------------------------------------------------

loc_EEF4:
		bset	#1,status(a0)
		bclr	#5,status(a0)
		move.b	#1,$21(a0)
		rts
; ---------------------------------------------------------------------------

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
		movea.w	#-$10,a3
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
		movea.w	#-$10,a3
		move.w	#$400,d6
		bsr.w	FindWall
		move.w	(sp)+,d0
		bsr.w	Player_Angle
		tst.w	d1
		beq.s	locret_EF7C
		bpl.s	loc_EF7E
		cmpi.w	#-$E,d1
		blt.s		locret_EF7C
		sub.w	d1,x_pos(a0)

locret_EF7C:
		rts
; ---------------------------------------------------------------------------

loc_EF7E:
		tst.b	$3C(a0)
		bne.s	loc_EF9C
		move.b	y_vel(a0),d0
		bpl.s	loc_EF8C
		neg.b	d0

loc_EF8C:
		addq.b	#4,d0
		cmpi.b	#$E,d0
		blo.s		loc_EF98
		move.b	#$E,d0

loc_EF98:
		cmp.b	d0,d1
		bgt.s	loc_EFA2

loc_EF9C:
		sub.w	d1,x_pos(a0)
		rts
; ---------------------------------------------------------------------------

loc_EFA2:
		bset	#1,status(a0)
		bclr	#5,status(a0)
		move.b	#1,$21(a0)
		rts
; ---------------------------------------------------------------------------

GetFloorPosition:
		movea.l	(Level_layout_addr_ROM).w,a1
		move.w	d2,d0
		lsr.w	#5,d0
		and.w	(Layout_row_index_mask).w,d0
		move.w	8(a1,d0.w),d0
		andi.l	#$7FFF,d0
		add.l	a1,d0
		move.w	d3,d1
		lsr.w	#3,d1
		move.w	d1,d4
		lsr.w	#4,d1
		add.w	d1,d0
		moveq	#-1,d1
		clr.w	d1
		movea.l	d0,a1
		move.b	(a1),d1
		add.w	d1,d1
		move.w	ChunkAddrArray(pc,d1.w),d1
		move.w	d2,d0
		andi.w	#$70,d0
		add.w	d0,d1
		andi.w	#$E,d4
		add.w	d4,d1
		movea.l	d1,a1
		rts
; ---------------------------------------------------------------------------

ChunkAddrArray:
		dc.w	 0, $80, $100, $180, $200, $280, $300, $380, $400, $480, $500, $580, $600, $680, $700, $780
		dc.w $800, $880, $900,$980, $A00, $A80, $B00,$B80, $C00, $C80, $D00,$D80,$E00,$E80,$F00,$F80
		dc.w $1000,$1080,$1100,$1180,$1200,$1280,$1300,$1380,$1400,$1480,$1500,$1580,$1600,$1680,$1700,$1780
		dc.w $1800,$1880,$1900,$1980,$1A00,$1A80,$1B00,$1B80,$1C00,$1C80,$1D00,$1D80,$1E00,$1E80,$1F00,$1F80
		dc.w $2000,$2080,$2100,$2180,$2200,$2280,$2300,$2380,$2400,$2480,$2500,$2580,$2600,$2680,$2700,$2780
		dc.w $2800,$2880,$2900,$2980,$2A00,$2A80,$2B00,$2B80,$2C00,$2C80,$2D00,$2D80,$2E00,$2E80,$2F00,$2F80
		dc.w $3000,$3080,$3100,$3180,$3200,$3280,$3300,$3380,$3400,$3480,$3500,$3580,$3600,$3680,$3700,$3780
		dc.w $3800,$3880,$3900,$3980,$3A00,$3A80,$3B00,$3B80,$3C00,$3C80,$3D00,$3D80,$3E00,$3E80,$3F00,$3F80
		dc.w $4000,$4080,$4100,$4180,$4200,$4280,$4300,$4380,$4400,$4480,$4500,$4580,$4600,$4680,$4700,$4780
		dc.w $4800,$4880,$4900,$4980,$4A00,$4A80,$4B00,$4B80,$4C00,$4C80,$4D00,$4D80,$4E00,$4E80,$4F00,$4F80
		dc.w $5000,$5080,$5100,$5180,$5200,$5280,$5300,$5380,$5400,$5480,$5500,$5580,$5600,$5680,$5700,$5780
		dc.w $5800,$5880,$5900,$5980,$5A00,$5A80,$5B00,$5B80,$5C00,$5C80,$5D00,$5D80,$5E00,$5E80,$5F00,$5F80
		dc.w $6000,$6080,$6100,$6180,$6200,$6280,$6300,$6380,$6400,$6480,$6500,$6580,$6600,$6680,$6700,$6780
		dc.w $6800,$6880,$6900,$6980,$6A00,$6A80,$6B00,$6B80,$6C00,$6C80,$6D00,$6D80,$6E00,$6E80,$6F00,$6F80
		dc.w $7000,$7080,$7100,$7180,$7200,$7280,$7300,$7380,$7400,$7480,$7500,$7580,$7600,$7680,$7700,$7780
		dc.w $7800,$7880,$7900,$7980,$7A00,$7A80,$7B00,$7B80,$7C00,$7C80,$7D00,$7D80,$7E00,$7E80,$7F00,$7F80

; =============== S U B R O U T I N E =======================================

FindFloor:
		bsr.w	GetFloorPosition
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
		bsr.w	FindFloor2
		add.w	a3,d2
		subi.w	#$10,d1
		rts
; End of function FindFloor

; =============== S U B R O U T I N E =======================================

FindFloor2:
		bsr.w	GetFloorPosition
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
; End of function FindFloor2
; ---------------------------------------------------------------------------

loc_F3A4:
		bsr.w	GetFloorPosition
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
		bpl.w	loc_F3EE

loc_F470:
		sub.w	a3,d2
		bsr.w	FindFloor2
		add.w	a3,d2
		subi.w	#$10,d1
		rts
; End of function sub_F3DE

; =============== S U B R O U T I N E =======================================

FindWall:
		bsr.w	GetFloorPosition
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
		bsr.w	FindWall2
		add.w	a3,d3
		subi.w	#$10,d1
		rts
; End of function sub_F4DC

; =============== S U B R O U T I N E =======================================

FindWall2:
		bsr.w	GetFloorPosition
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
; End of function FindWall2

; =============== S U B R O U T I N E =======================================

CalcRoomInFront:
		move.l	(Primary_collision_addr).w,(Collision_addr).w
		cmpi.b	#$C,top_solid_bit(a0)
		beq.s	+
		move.l	(Secondary_collision_addr).w,(Collision_addr).w
+		move.b	lrb_solid_bit(a0),d5
		move.l	x_pos(a0),d3
		move.l	y_pos(a0),d2
		move.w	x_vel(a0),d1
		ext.l	d1
		asl.l	#8,d1
		add.l	d1,d3
		move.w	y_vel(a0),d1
		tst.b	(Reverse_gravity_flag).w
		beq.s	+
		neg.w	d1
+		ext.l	d1
		asl.l	#8,d1
		add.l	d1,d2
		swap	d2
		swap	d3
		move.b	d0,(Primary_Angle).w
		move.b	d0,(Secondary_Angle).w
		move.b	d0,d1
		addi.b	#$20,d0
		bpl.s	++
		move.b	d1,d0
		bpl.s	+
		subq.b	#1,d0
+		addi.b	#$20,d0
		bra.s	+++
; ---------------------------------------------------------------------------
+		move.b	d1,d0
		bpl.s	+
		addq.b	#1,d0
+		addi.b	#$1F,d0
+		andi.b	#$C0,d0
		beq.w	CheckFloorDist_Part2
		cmpi.b	#$80,d0
		beq.w	CheckCeilingDist_Part2
		andi.b	#$38,d1
		bne.s	+
		addq.w	#8,d2
+		cmpi.b	#$40,d0
		beq.w	CheckLeftWallDist_Part2
		bra.w	CheckRightWallDist_Part2
; End of function CalcRoomInFront
; ---------------------------------------------------------------------------
; Subroutine to calculate how much space is empty above Sonic's/Tails' head
; d0 = input angle perpendicular to the spine
; d1 = output about how many pixels are overhead (up to some high enough amount)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

CalcRoomOverHead:
		move.l	(Primary_collision_addr).w,(Collision_addr).w
		cmpi.b	#$C,top_solid_bit(a0)
		beq.s	+
		move.l	(Secondary_collision_addr).w,(Collision_addr).w
+		move.b	lrb_solid_bit(a0),d5
		move.b	d0,(Primary_Angle).w
		move.b	d0,(Secondary_Angle).w
		addi.b	#$20,d0
		andi.b	#$C0,d0
		cmpi.b	#$40,d0
		beq.w	CheckLeftCeilingDist
		cmpi.b	#$80,d0
		beq.w	Sonic_CheckCeiling
		cmpi.b	#$C0,d0
		beq.w	CheckRightCeilingDist
; End of function CalcRoomOverHead
; ---------------------------------------------------------------------------
; Subroutine to check if Sonic/Tails is near the floor
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Sonic_CheckFloor:
		move.l	(Primary_collision_addr).w,(Collision_addr).w
		cmpi.b	#$C,top_solid_bit(a0)
		beq.s	+
		move.l	(Secondary_collision_addr).w,(Collision_addr).w
+		move.b	top_solid_bit(a0),d5
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
		movea.w	#$10,a3
		move.w	#0,d6
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
		movea.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindFloor
		move.w	(sp)+,d0
		move.b	#0,d2

loc_F7E2:
		move.b	(Secondary_Angle).w,d3
		cmp.w	d0,d1
		ble.s		+
		move.b	(Primary_Angle).w,d3
		exg	d0,d1
+		btst	#0,d3
		beq.s	+
		move.b	d2,d3
+		rts
; End of function Sonic_CheckFloor
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
		movea.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindFloor
		move.b	#0,d2

; d2 what to use as angle if (Primary_Angle).w is odd
; returns angle in d3, or value in d2 if angle was odd
loc_F81A:
		move.b	(Primary_Angle).w,d3
		btst	#0,d3
		beq.s	+
		move.b	d2,d3
+		rts

; =============== S U B R O U T I N E =======================================

sub_F846:
		move.w	x_pos(a0),d3
		move.w	y_pos(a0),d2
		subq.w	#4,d2
		move.l	(Primary_collision_addr).w,(Collision_addr).w
		cmpi.b	#$D,lrb_solid_bit(a0)
		beq.s	+
		move.l	(Secondary_collision_addr).w,(Collision_addr).w
+		lea	(Primary_Angle).w,a4
		move.b	#0,(a4)
		movea.w	#$10,a3
		move.w	#0,d6
		move.b	lrb_solid_bit(a0),d5
		movem.l	a4-a6,-(sp)
		bsr.w	FindFloor
		movem.l	(sp)+,a4-a6
		move.b	(Primary_Angle).w,d3
		btst	#0,d3
		beq.s	+
		move.b	#0,d3
+		rts
; End of function sub_F846

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
		beq.s	+
		move.l	(Secondary_collision_addr).w,(Collision_addr).w
+		lea	(Primary_Angle).w,a4
		move.b	#0,(a4)
		movea.w	#$10,a3
		move.w	#0,d6
		move.b	top_solid_bit(a0),d5
		movem.l	a4-a6,-(sp)
		bsr.w	FindFloor
		movem.l	(sp)+,a4-a6
		move.b	(Primary_Angle).w,d3
		btst	#0,d3
		beq.s	+
		move.b	#0,d3
+		rts
; End of function ChkFloorEdge_Part3

; =============== S U B R O U T I N E =======================================

SonicOnObjHitFloor:
		move.w	x_pos(a1),d3
		move.w	y_pos(a1),d2
		moveq	#0,d0
		move.b	y_radius(a1),d0
		ext.w	d0
		add.w	d0,d2
		move.l	(Primary_collision_addr).w,(Collision_addr).w
		cmpi.b	#$C,top_solid_bit(a1)
		beq.s	+
		move.l	(Secondary_collision_addr).w,(Collision_addr).w
+		lea	(Primary_Angle).w,a4
		move.b	#0,(a4)
		movea.w	#$10,a3
		move.w	#0,d6
		move.b	top_solid_bit(a1),d5
		bsr.w	FindFloor
		move.b	(Primary_Angle).w,d3
		btst	#0,d3
		beq.s	+
		move.b	#0,d3
+		rts
; End of function SonicOnObjHitFloor
; ---------------------------------------------------------------------------
; Subroutine checking if an object should interact with the floor
; (objects such as a monitor Sonic bumps from underneath)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

ObjHitFloor:
ObjFloorDist:
ObjCheckFloorDist:
		move.w	x_pos(a0),d3

ObjHitFloor2:
ObjFloorDist2:
ObjCheckFloorDist2:
		move.w	y_pos(a0),d2			; Get object position
		move.b	y_radius(a0),d0		; Get object height
		ext.w	d0
		add.w	d0,d2
		lea	(Primary_Angle).w,a4
		move.b	#0,(a4)
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$C,d5
		bsr.w	FindFloor
		move.b	(Primary_Angle).w,d3
		btst	#0,d3
		beq.s	+
		move.b	#0,d3
+		rts
; End of function ObjCheckFloorDist

; =============== S U B R O U T I N E =======================================

RingCheckFloorDist:
		move.w	x_pos(a0),d3
		move.w	y_pos(a0),d2
		move.b	y_radius(a0),d0
		ext.w	d0
		add.w	d0,d2
		lea	(Primary_Angle).w,a4
		move.b	#0,(a4)
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$C,d5
		bra.w	loc_F3A4
; End of function RingCheckFloorDist

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
		movea.w	#$10,a3
		move.w	#0,d6
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
		movea.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindWall
		move.w	(sp)+,d0
		move.b	#-$40,d2
		bra.w	loc_F7E2
; End of function CheckRightCeilingDist

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
		movea.w	#$10,a3
		move.w	#0,d6
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
		movea.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindWall
		move.w	(sp)+,d0
		move.b	#-$40,d2
		bra.w	loc_F7E2
; End of function sub_FA1A

; =============== S U B R O U T I N E =======================================

CheckRightWallDist:
		move.w	y_pos(a0),d2
		move.w	x_pos(a0),d3

CheckRightWallDist_Part2:
		addi.w	#$A,d3
		lea	(Primary_Angle).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindWall
		move.b	#-$40,d2
		bra.w	loc_F81A
; End of function CheckRightWallDist

; =============== S U B R O U T I N E =======================================

; ObjHitWall:
ObjCheckRightWallDist:
		add.w	x_pos(a0),d3
		move.w	y_pos(a0),d2
		lea	(Primary_Angle).w,a4
		move.b	#0,(a4)
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$D,d5
		bsr.w	FindWall
		move.b	(Primary_Angle).w,d3
		btst	#0,d3
		beq.s	+
		move.b	#-$40,d3
+		rts
; End of function ObjCheckRightWallDist

; =============== S U B R O U T I N E =======================================

Sonic_CheckCeiling:
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
		movea.w	#-$10,a3
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
		movea.w	#-$10,a3
		move.w	#$800,d6
		bsr.w	FindFloor
		move.w	(sp)+,d0
		move.b	#-$80,d2
		bra.w	loc_F7E2
; End of function Sonic_CheckCeiling

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
		movea.w	#-$10,a3
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
		movea.w	#-$10,a3
		move.w	#$800,d6
		bsr.w	FindFloor
		move.w	(sp)+,d0
		move.b	#-$80,d2
		bra.w	loc_F7E2
; End of function sub_FB5A

; =============== S U B R O U T I N E =======================================

CheckCeilingDist:
		move.w	y_pos(a0),d2
		move.w	x_pos(a0),d3

CheckCeilingDist_Part2:
		subi.w	#$A,d2
		eori.w	#$F,d2
		lea	(Primary_Angle).w,a4
		movea.w	#-$10,a3
		move.w	#$800,d6
		bsr.w	FindFloor
		move.b	#-$80,d2
		bra.w	loc_F81A

; =============== S U B R O U T I N E =======================================

sub_FBEE:
		move.b	x_radius(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		lea	(Primary_Angle).w,a4
		movea.w	#-$10,a3
		move.w	#$800,d6
		bsr.w	FindFloor
		move.b	#-$80,d2
		bra.w	loc_F81A
; End of function sub_FBEE

; =============== S U B R O U T I N E =======================================

ObjHitCeiling:
ObjCheckCeilingDist:
		move.w	y_pos(a0),d2
		move.w	x_pos(a0),d3
		moveq	#0,d0
		move.b	y_radius(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		lea	(Primary_Angle).w,a4
		movea.w	#-$10,a3
		move.w	#$800,d6
		moveq	#$D,d5
		bsr.w	FindFloor
		move.b	(Primary_Angle).w,d3
		btst	#0,d3
		beq.s	+
		move.b	#-$80,d3
+		rts
; End of function ObjCheckCeilingDist

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
		beq.s	+
		move.l	(Secondary_collision_addr).w,(Collision_addr).w
+		lea	(Primary_Angle).w,a4
		move.b	#0,(a4)
		movea.w	#-$10,a3
		move.w	#$800,d6
		move.b	top_solid_bit(a0),d5
		movem.l	a4-a6,-(sp)
		bsr.w	FindFloor
		movem.l	(sp)+,a4-a6
		move.b	(Primary_Angle).w,d3
		btst	#0,d3
		beq.s	+
		move.b	#0,d3
+		rts
; End of function ChkFloorEdge_ReverseGravity_Part2

; =============== S U B R O U T I N E =======================================

sub_FCA0:
		move.w	x_pos(a0),d3
		move.w	y_pos(a0),d2
		move.b	y_radius(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		lea	(Primary_Angle).w,a4
		move.b	#0,(a4)
		movea.w	#-$10,a3
		move.w	#$800,d6
		moveq	#$C,d5
		bra.w	loc_F3A4
; End of function sub_FCA0

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
		movea.w	#-$10,a3
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
		movea.w	#-$10,a3
		move.w	#$400,d6
		bsr.w	FindWall
		move.w	(sp)+,d0
		move.b	#$40,d2
		bra.w	loc_F7E2
; End of function CheckLeftCeilingDist

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
		movea.w	#-$10,a3
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
		movea.w	#-$10,a3
		move.w	#$400,d6
		bsr.w	FindWall
		move.w	(sp)+,d0
		move.b	#$40,d2
		bra.w	loc_F7E2
; End of function sub_FD32

; =============== S U B R O U T I N E =======================================

CheckLeftWallDist:
		move.w	y_pos(a0),d2
		move.w	x_pos(a0),d3

CheckLeftWallDist_Part2:
		subi.w	#$A,d3
		eori.w	#$F,d3
		lea	(Primary_Angle).w,a4
		movea.w	#-$10,a3
		move.w	#$400,d6
		bsr.w	FindWall
		move.b	#$40,d2
		bra.w	loc_F81A
; End of function CheckLeftWallDist

; =============== S U B R O U T I N E =======================================

sub_FDEC:
		move.l	(Primary_collision_addr).w,(Collision_addr).w
		cmpi.b	#$C,top_solid_bit(a0)
		beq.s	+
		move.l	(Secondary_collision_addr).w,(Collision_addr).w
+		move.w	x_pos(a0),d3
		move.w	y_pos(a0),d2
		move.b	y_radius(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eori.w	#$F,d3
		lea	(Primary_Angle).w,a4
		move.b	#0,(a4)
		movea.w	#-$10,a3
		move.w	#$400,d6
		move.b	lrb_solid_bit(a0),d5
		bsr.w	FindWall
		move.b	(Primary_Angle).w,d3
		btst	#0,d3
		beq.s	+
		move.b	#$40,d3
+		rts
; End of function sub_FDEC

; =============== S U B R O U T I N E =======================================

; ObjHitWall2:
ObjCheckLeftWallDist:
		add.w	x_pos(a0),d3
		eori.w	#$F,d3	; this was not here in S1/S2, resulting in a bug

ObjCheckLeftWallDist_Part2:
		move.w	y_pos(a0),d2
		lea	(Primary_Angle).w,a4
		move.b	#0,(a4)
		movea.w	#-$10,a3
		move.w	#$400,d6
		moveq	#$D,d5
		bsr.w	FindWall
		move.b	(Primary_Angle).w,d3
		btst	#0,d3
		beq.s	+
		move.b	#$40,d3
+		rts
; End of function ObjCheckLeftWallDist_Part2
