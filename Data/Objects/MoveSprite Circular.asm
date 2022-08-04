
; =============== S U B R O U T I N E =======================================

MoveSprite_Circular:
		move.b	objoff_3C(a0),d0
		bsr.w	GetSineCosine
		move.w	objoff_3A(a0),d2
		move.w	d2,d3
		muls.w	d0,d2
		swap	d2
		muls.w	d1,d3
		swap	d3
		movea.w	parent3(a0),a1
		move.w	x_pos(a1),d0
		add.w	d2,d0
		move.b	child_dx(a0),d4
		ext.w	d4
		add.w	d4,d0
		move.w	d0,x_pos(a0)
		move.w	y_pos(a1),d1
		add.w	d3,d1
		move.b	child_dy(a0),d4
		ext.w	d4
		add.w	d4,d1
		move.w	d1,y_pos(a0)
		rts

; =============== S U B R O U T I N E =======================================

MoveSprite_CircularSimple:
		move.b	objoff_3C(a0),d0
		bsr.w	GetSineCosine
		swap	d0
		clr.w	d0
		swap	d1
		clr.w	d1
		asr.l	d2,d0
		asr.l	d2,d1
		movea.w	parent3(a0),a1
		move.l	x_pos(a1),d2
		move.l	y_pos(a1),d3
		add.l	d0,d2
		add.l	d1,d3
		move.l	d2,x_pos(a0)
		move.l	d3,y_pos(a0)
		rts

; =============== S U B R O U T I N E =======================================

MoveSprite_CircularSimpleCheckFlip:
		move.b	objoff_3C(a0),d0
		bsr.w	GetSineCosine
		swap	d0
		clr.w	d0
		swap	d1
		clr.w	d1
		asr.l	d2,d0
		asr.l	d2,d1
		movea.w	parent3(a0),a1
		move.l	x_pos(a1),d2
		move.l	y_pos(a1),d3
		btst	#0,render_flags(a1)
		beq.s	+
		neg.l	d0
+		add.l	d0,d2
		add.l	d1,d3
		move.l	d2,x_pos(a0)
		move.l	d3,y_pos(a0)
		rts

; =============== S U B R O U T I N E =======================================

MoveSprite_CircularSimpleOffset:
		move.b	objoff_3C(a0),d0
		bsr.w	GetSineCosine
		swap	d0
		clr.w	d0
		swap	d1
		clr.w	d1
		asr.l	d2,d0
		asr.l	d2,d1
		movea.w	parent3(a0),a1
		move.l	x_pos(a1),d2
		move.l	y_pos(a1),d3
		move.b	child_dx(a0),d4
		ext.w	d4
		swap	d4
		clr.w	d4
		add.l	d4,d2
		move.b	child_dy(a0),d4
		ext.w	d4
		swap	d4
		clr.w	d4
		add.l	d4,d3
		add.l	d0,d2
		add.l	d1,d3
		move.l	d2,x_pos(a0)
		move.l	d3,y_pos(a0)
		rts

; =============== S U B R O U T I N E =======================================

MoveSprite_CircularLookup:
		moveq	#0,d0
		move.b	objoff_3C(a0),d0
		move.w	d0,d1
		andi.w	#$3F,d0
		lsr.w	#5,d1
		andi.w	#6,d1
		movea.w	parent3(a0),a1
		lea	$40(a2),a3
		move.w	x_pos(a1),d2
		move.w	y_pos(a1),d3
		move.b	child_dx(a0),d4
		ext.w	d4
		btst	#0,render_flags(a0)
		beq.s	+
		neg.w	d4
+		add.w	d4,d2
		move.b	child_dy(a0),d4
		ext.w	d4
		add.w	d4,d3
		move.w	d0,d4
		not.w	d4
		move.w	AtAngle_LookupIndex(pc,d1.w),d1
		jsr	AtAngle_LookupIndex(pc,d1.w)
		btst	#0,render_flags(a0)
		beq.s	+
		neg.w	d5
+		add.w	d5,d2
		add.w	d6,d3
		move.w	d2,x_pos(a0)
		move.w	d3,y_pos(a0)
		rts

; =============== S U B R O U T I N E =======================================

MoveSprite_AtAngleLookup:
		moveq	#0,d0
		move.b	objoff_3C(a0),d0
		move.w	d0,d1
		andi.w	#$3F,d0
		lsr.w	#5,d1
		andi.w	#6,d1
		movea.w	parent3(a0),a1
		lea	$40(a2),a3
		move.w	x_pos(a1),d2
		move.w	y_pos(a1),d3
		move.w	d0,d4
		not.w	d4
		move.w	AtAngle_LookupIndex(pc,d1.w),d1
		jsr	AtAngle_LookupIndex(pc,d1.w)
		add.w	d5,d2
		add.w	d6,d3
		move.w	d2,x_pos(a0)
		move.w	d3,y_pos(a0)
		rts
; ---------------------------------------------------------------------------

AtAngle_LookupIndex: offsetTable
		offsetTableEntry.w AtAngle_00_3F
		offsetTableEntry.w AtAngle_40_7F
		offsetTableEntry.w AtAngle_80_BF
		offsetTableEntry.w AtAngle_C0_FF
; ---------------------------------------------------------------------------

AtAngle_00_3F:
		moveq	#0,d5
		move.b	(a2,d0.w),d5
		moveq	#0,d6
		move.b	(a3,d4.w),d6
		rts
; ---------------------------------------------------------------------------

AtAngle_40_7F:
		moveq	#0,d5
		move.b	(a3,d4.w),d5
		moveq	#0,d6
		move.b	(a2,d0.w),d6
		neg.w	d6
		rts
; ---------------------------------------------------------------------------

AtAngle_80_BF:
		moveq	#0,d5
		move.b	(a2,d0.w),d5
		neg.w	d5
		moveq	#0,d6
		move.b	(a3,d4.w),d6
		neg.w	d6
		rts
; ---------------------------------------------------------------------------

AtAngle_C0_FF:
		moveq	#0,d5
		move.b	(a3,d4.w),d5
		neg.w	d5
		moveq	#0,d6
		move.b	(a2,d0.w),d6
		rts

; =============== S U B R O U T I N E =======================================

MoveSprite_AngleYLookup:
		moveq	#0,d0
		move.b	objoff_3C(a0),d0
		move.w	d0,d1
		andi.w	#$3F,d0
		lsr.w	#5,d1
		andi.w	#6,d1
		movea.w	parent3(a0),a1
		lea	$40(a2),a3
		move.w	y_pos(a1),d3
		move.w	d0,d4
		not.w	d4
		move.w	AngleY_LookupIndex(pc,d1.w),d1
		jsr	AngleY_LookupIndex(pc,d1.w)
		add.w	d1,d3
		move.w	d3,y_pos(a0)
		rts
; ---------------------------------------------------------------------------

AngleY_LookupIndex: offsetTable
		offsetTableEntry.w loc_84E16
		offsetTableEntry.w loc_84E1E
		offsetTableEntry.w loc_84E28
		offsetTableEntry.w loc_84E32
; ---------------------------------------------------------------------------

loc_84E16:
		moveq	#0,d1
		move.b	(a3,d4.w),d1
		rts
; ---------------------------------------------------------------------------

loc_84E1E:
		moveq	#0,d1
		move.b	(a2,d0.w),d1
		neg.w	d1
		rts
; ---------------------------------------------------------------------------

loc_84E28:
		moveq	#0,d1
		move.b	(a3,d4.w),d1
		neg.w	d1
		rts
; ---------------------------------------------------------------------------

loc_84E32:
		moveq	#0,d1
		move.b	(a2,d0.w),d1
		rts
; ---------------------------------------------------------------------------
; Calculate the angle of the object subroutine
; ---------------------------------------------------------------------------
; a1 - object
; a2 - player

; =============== S U B R O U T I N E =======================================

CalcObjAngle:
		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		moveq	#0,d3
		moveq	#0,d4
		move.w	x_pos(a2),d0
		move.w	y_pos(a2),d1
		sub.w	x_pos(a1),d0
		bpl.s	+
		neg.w	d0
		moveq	#8,d2
+		sub.w	y_pos(a1),d1
		bpl.s	+
		neg.w	d1
		moveq	#4,d3
+		cmp.w	d0,d1
		bhs.s	+
		exg	d0,d1
		moveq	#2,d4
+		tst.w	d1
		beq.s	locret_8627E
		lsl.w	#5,d0
		divu.w	d1,d0
		add.w	d2,d3
		add.w	d3,d4
		move.w	off_8626E(pc,d4.w),d4
		jmp	off_8626E(pc,d4.w)
; ---------------------------------------------------------------------------

off_8626E: offsetTable
		offsetTableEntry.w locret_8627E
		offsetTableEntry.w loc_86280
		offsetTableEntry.w loc_86288
		offsetTableEntry.w loc_86290
		offsetTableEntry.w loc_86296
		offsetTableEntry.w loc_8629A
		offsetTableEntry.w loc_862A0
		offsetTableEntry.w loc_862A6
; ---------------------------------------------------------------------------

loc_86280:
		subi.w	#$40,d0
		neg.w	d0

locret_8627E:
		rts
; ---------------------------------------------------------------------------

loc_86288:
		subi.w	#$80,d0
		neg.w	d0
		rts
; ---------------------------------------------------------------------------

loc_86290:
		addi.w	#$40,d0
		rts
; ---------------------------------------------------------------------------

loc_86296:
		neg.w	d0
		rts
; ---------------------------------------------------------------------------

loc_8629A:
		addi.w	#$C0,d0
		rts
; ---------------------------------------------------------------------------

loc_862A0:
		addi.w	#$80,d0
		rts
; ---------------------------------------------------------------------------

loc_862A6:
		subi.w	#$C0,d0
		neg.w	d0
		rts

; =============== S U B R O U T I N E =======================================

MoveSprite_AngleXLookupOffset:
		moveq	#0,d0
		move.b	objoff_3C(a0),d0
		move.b	d0,d1
		rol.b	#3,d1
		andi.w	#6,d1
		move.w	AngleX_LookupIndex(pc,d1.w),d2
		jmp	AngleX_LookupIndex(pc,d2.w)
; ---------------------------------------------------------------------------

AngleX_LookupIndex: offsetTable
		offsetTableEntry.w loc_84E58
		offsetTableEntry.w loc_84E60
		offsetTableEntry.w loc_84E6C
		offsetTableEntry.w loc_84E7C
; ---------------------------------------------------------------------------

loc_84E58:
		move.b	(a1,d0.w),d1
		bra.s	loc_84E8C
; ---------------------------------------------------------------------------

loc_84E60:
		moveq	#$7F,d1
		sub.w	d0,d1
		move.b	(a1,d1.w),d1
		bra.s	loc_84E8C
; ---------------------------------------------------------------------------

loc_84E6C:
		move.w	d0,d1
		andi.w	#$3F,d1
		move.b	(a1,d1.w),d1
		neg.w	d1
		bra.s	loc_84E8C
; ---------------------------------------------------------------------------

loc_84E7C:
		move.w	#$FF,d1
		sub.w	d0,d1
		move.b	(a1,d1.w),d1
		neg.w	d1

loc_84E8C:
		movea.w	parent3(a0),a1
		move.w	x_pos(a1),d2
		move.b	child_dx(a0),d3
		ext.w	d3
		add.w	d3,d2
		btst	#0,render_flags(a1)		; check flip
		beq.s	+
		neg.w	d1
+		add.w	d1,d2
		move.w	d2,x_pos(a0)
		move.w	y_pos(a1),d2
		move.b	child_dy(a0),d3
		ext.w	d3
		add.w	d3,d2
		move.w	d2,y_pos(a0)
		rts

; =============== S U B R O U T I N E =======================================

MoveSprite_AngleXLookupOffset2:
		moveq	#0,d0
		move.b	$3C(a0),d0
		move.b	d0,d1
		rol.b	#3,d1
		andi.w	#6,d1
		move.w	AngleX_Lookup2Index(pc,d1.w),d2
		jmp	AngleX_Lookup2Index(pc,d2.w)
; ---------------------------------------------------------------------------

AngleX_Lookup2Index: offsetTable
		offsetTableEntry.w loc_84EDC
		offsetTableEntry.w loc_84EE4
		offsetTableEntry.w loc_84EF0
		offsetTableEntry.w loc_84F00
; ---------------------------------------------------------------------------

loc_84EDC:
		move.b	(a1,d0.w),d1
		bra.s	loc_84F10
; ---------------------------------------------------------------------------

loc_84EE4:
		moveq	#$7F,d1
		sub.w	d0,d1
		move.w	(a1,d1.w),d1
		bra.s	loc_84F10
; ---------------------------------------------------------------------------

loc_84EF0:
		move.w	d0,d1
		andi.w	#$3F,d1
		move.w	(a1,d1.w),d1
		neg.w	d1
		bra.s	loc_84F10
; ---------------------------------------------------------------------------

loc_84F00:
		move.w	#$FF,d1
		sub.w	d0,d1
		move.w	(a1,d1.w),d1
		neg.w	d1

loc_84F10:
		movea.w	parent3(a0),a1
		move.w	x_pos(a1),d2
		move.b	child_dx(a0),d3
		ext.w	d3
		add.w	d3,d2
		move.w	d2,x_pos(a0)
		move.w	y_pos(a1),d2
		move.b	child_dy(a0),d3
		ext.w	d3
		add.w	d3,d2
		add.w	d1,d2
		move.w	d2,y_pos(a0)
		rts
; ---------------------------------------------------------------------------

AngleLookup_1:
		dc.b 0, 0, 1, 1, 1, 1, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 5, 5, 5, 5
		dc.b 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, $A, $A
		dc.b $A, $A, $A, $A, $B, $B, $B, $B, $B, $B, $B, $B, $B, $C, $C, $C, $C, $C, $C, $C
		dc.b $C, $C, $C, $C
AngleLookup_2:
		dc.b 0, 1, 1, 2, 2, 3, 4, 4, 5, 5, 6, 6, 7, 8, 8, 9, 9, $A, $A, $B
		dc.b $B, $C, $C, $D, $D, $E, $E, $F, $F, $10, $10, $11, $11, $11, $12, $12, $13, $13, $13, $14
		dc.b $14, $14, $15, $15, $15, $15, $16, $16, $16, $16, $17, $17, $17, $17, $17, $17, $18, $18, $18, $18
		dc.b $18, $18, $18, $18
AngleLookup_3:
		dc.b 0, 1, 2, 3, 4, 4, 5, 6, 7, 8, 9, $A, $A, $B, $C, $D, $E, $F, $F, $10
		dc.b $11, $12, $13, $13, $14, $15, $15, $16, $17, $18, $18, $19, $19, $1A, $1B, $1B, $1C, $1C, $1D, $1D
		dc.b $1E, $1E, $1F, $1F, $20, $20, $21, $21, $21, $22, $22, $22, $22, $23, $23, $23, $23, $23, $24, $24
		dc.b $24, $24, $24, $24