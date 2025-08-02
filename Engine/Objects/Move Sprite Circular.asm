; ---------------------------------------------------------------------------
; Move sprite circular subroutine
; ---------------------------------------------------------------------------

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
		movea.w	parent3(a0),a1							; a1=parent object
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
		movea.w	parent3(a0),a1							; a1=parent object
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
		movea.w	parent3(a0),a1							; a1=parent object
		move.l	x_pos(a1),d2
		move.l	y_pos(a1),d3
		btst	#render_flags.x_flip,render_flags(a1)				; check flipx
		beq.s	.notflipx
		neg.l	d0

.notflipx
		add.l	d0,d2
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
		movea.w	parent3(a0),a1							; a1=parent object
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
		movea.w	parent3(a0),a1							; a1=parent object
		lea	$40(a2),a3
		move.w	x_pos(a1),d2
		move.w	y_pos(a1),d3
		move.b	child_dx(a0),d4
		ext.w	d4
		btst	#render_flags.x_flip,render_flags(a0)				; check flipx
		beq.s	.notflipx
		neg.w	d4

.notflipx
		add.w	d4,d2
		move.b	child_dy(a0),d4
		ext.w	d4
		add.w	d4,d3
		move.w	d0,d4
		not.w	d4
		jsr	MoveSprite_AtAngleLookup.index(pc,d1.w)
		btst	#render_flags.x_flip,render_flags(a0)				; check flipx
		beq.s	.notflipx2
		neg.w	d5

.notflipx2
		add.w	d5,d2
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
		movea.w	parent3(a0),a1							; a1=parent object
		lea	$40(a2),a3
		move.w	x_pos(a1),d2
		move.w	y_pos(a1),d3
		move.w	d0,d4
		not.w	d4
		jsr	.index(pc,d1.w)
		add.w	d5,d2
		add.w	d6,d3
		move.w	d2,x_pos(a0)
		move.w	d3,y_pos(a0)
		rts
; ---------------------------------------------------------------------------

.index
		bra.s	AtAngle_00_3F							; 0
		bra.s	AtAngle_40_7F							; 2
		bra.s	AtAngle_80_BF							; 4
; ---------------------------------------------------------------------------

		; AtAngle_C0_FF:							; 6
		moveq	#0,d5
		move.b	(a3,d4.w),d5
		neg.w	d5
		moveq	#0,d6
		move.b	(a2,d0.w),d6
		rts
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

; =============== S U B R O U T I N E =======================================

MoveSprite_AngleYLookup:
		moveq	#0,d0
		move.b	objoff_3C(a0),d0
		move.w	d0,d1
		andi.w	#$3F,d0
		lsr.w	#5,d1
		andi.w	#6,d1
		movea.w	parent3(a0),a1							; a1=parent object
		lea	$40(a2),a3
		move.w	y_pos(a1),d3
		move.w	d0,d4
		not.w	d4
		jsr	.index(pc,d1.w)
		add.w	d1,d3
		move.w	d3,y_pos(a0)
		rts
; ---------------------------------------------------------------------------

.index
		bra.s	loc_84E16							; 0
		bra.s	loc_84E1E							; 2
		bra.s	loc_84E28							; 4
; ---------------------------------------------------------------------------

											; 6
		moveq	#0,d1
		move.b	(a2,d0.w),d1
		rts
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
; Calculate the angle of the object subroutine
; ---------------------------------------------------------------------------
; a1 - object
; a2 - player
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Calc_ObjAngle:

	irp	reg, d0,d1,d2,d3,d4
		moveq	#0,reg
	endr

		move.w	x_pos(a2),d0
		move.w	y_pos(a2),d1
		sub.w	x_pos(a1),d0
		bpl.s	.skipx
		neg.w	d0
		moveq	#8,d2

.skipx
		sub.w	y_pos(a1),d1
		bpl.s	.skipy
		neg.w	d1
		moveq	#4,d3

.skipy
		cmp.w	d0,d1
		bhs.s	.check
		exg	d0,d1
		moveq	#2,d4

.check
		tst.w	d1
		beq.s	.return
		lsl.w	#5,d0
		divu.w	d1,d0
		add.w	d2,d3
		add.w	d3,d4
		beq.s	.return
		jmp	.index-2(pc,d4.w)
; ---------------------------------------------------------------------------

.index
		bra.s	loc_86280							; 2
		bra.s	loc_86288							; 4
		bra.s	loc_86290							; 6
		bra.s	loc_86296							; 8
		bra.s	loc_8629A							; A
		bra.s	loc_862A0							; C
; ---------------------------------------------------------------------------

											; E
		subi.w	#$C0,d0
		neg.w	d0

.return
		rts
; ---------------------------------------------------------------------------

loc_86280:
		subi.w	#$40,d0
		neg.w	d0
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

; =============== S U B R O U T I N E =======================================

MoveSprite_AngleXLookupOffset:
		moveq	#0,d0
		move.b	objoff_3C(a0),d0
		move.b	d0,d1
		rol.b	#3,d1
		andi.w	#6,d1
		jmp	.index(pc,d1.w)
; ---------------------------------------------------------------------------

.index
		bra.s	loc_84E58							; 0
		bra.s	loc_84E60							; 2
		bra.s	loc_84E6C							; 4
; ---------------------------------------------------------------------------

											; 6
		move.w	#$FF,d1
		sub.w	d0,d1
		move.b	(a1,d1.w),d1
		neg.w	d1

loc_84E8C:
		movea.w	parent3(a0),a1							; a1=parent object
		move.w	x_pos(a1),d2
		move.b	child_dx(a0),d3
		ext.w	d3
		add.w	d3,d2
		btst	#render_flags.x_flip,render_flags(a1)				; check flipx
		beq.s	.notflipx
		neg.w	d1

.notflipx
		add.w	d1,d2
		move.w	d2,x_pos(a0)
		move.w	y_pos(a1),d2
		move.b	child_dy(a0),d3
		ext.w	d3
		add.w	d3,d2
		move.w	d2,y_pos(a0)
		rts
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

; =============== S U B R O U T I N E =======================================

MoveSprite_AngleXLookupOffset2:
		moveq	#0,d0
		move.b	objoff_3C(a0),d0
		move.b	d0,d1
		rol.b	#3,d1
		andi.w	#6,d1
		jmp	.index(pc,d1.w)
; ---------------------------------------------------------------------------

.index
		bra.s	loc_84EDC							; 0
		bra.s	loc_84EE4							; 2
		bra.s	loc_84EF0							; 4
; ---------------------------------------------------------------------------

											; 6
		move.w	#$FF,d1
		sub.w	d0,d1
		move.w	(a1,d1.w),d1
		neg.w	d1

loc_84F10:
		movea.w	parent3(a0),a1							; a1=parent object
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
