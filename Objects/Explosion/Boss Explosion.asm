; ----------------------------------------------------------------------------
; Boss explosions
; ----------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_CreateBossExplosion:
		moveq	#0,d0
		move.b	subtype(a0),d0
		lea	CreateBossExpParameterIndex(pc),a1
		adda.w	(a1,d0.w),a1
		move.b	(a1)+,$39(a0)
		move.b	(a1)+,$3A(a0)
		move.b	(a1)+,$3B(a0)
		move.b	(a1)+,d0
		lea	CreateBossExpRoutineSet(pc,d0.w),a1
		movea.l	(a1)+,a2
		move.l	a2,address(a0)
		move.l	(a1)+,$34(a0)
		jmp	(a2)
; ---------------------------------------------------------------------------

CreateBossExpRoutineSet:
		dc.l Obj_Wait
		dc.l Obj_BossExpControl1
		dc.l Obj_WaitForParent
		dc.l Obj_BossExpControl1
		dc.l Obj_Wait
		dc.l Obj_NormalExpControl
		dc.l Obj_Wait
		dc.l Obj_BossExpControl2
		dc.l Obj_WaitForParent
		dc.l Obj_BossExpControl2
		dc.l Obj_WaitForParent
		dc.l Obj_NormalExpControl
		dc.l Obj_WaitForParent
		dc.l Obj_BossExpControlOff
CreateBossExpParameterIndex: offsetTable
		offsetTableEntry.w CreateBossExp_00
		offsetTableEntry.w CreateBossExp_02
		offsetTableEntry.w CreateBossExp_04
		offsetTableEntry.w CreateBossExp_06
		offsetTableEntry.w CreateBossExp_08
		offsetTableEntry.w CreateBossExp_0A
		offsetTableEntry.w CreateBossExp_0C
		offsetTableEntry.w CreateBossExp_0E
		offsetTableEntry.w CreateBossExp_10
		offsetTableEntry.w CreateBossExp_12
		offsetTableEntry.w CreateBossExp_14
		offsetTableEntry.w CreateBossExp_16
		offsetTableEntry.w CreateBossExp_18
		offsetTableEntry.w CreateBossExp_1A
		offsetTableEntry.w CreateBossExp_1C
		offsetTableEntry.w CreateBossExp_1E
		offsetTableEntry.w CreateBossExp_20
CreateBossExp_00:	dc.b $20, $20, $20, 0		; Explosion timer, X offset range, Y offset range, routine set
CreateBossExp_02:	dc.b $28, $80, $80, $18
CreateBossExp_04:	dc.b $80, $20, $20, 8
CreateBossExp_06:	dc.b	4, $10, $10, 0
CreateBossExp_08:	dc.b	8, $20, $20, $10
CreateBossExp_0A:	dc.b $20, $20, $20, 0
CreateBossExp_0C:	dc.b $40, $80, $20, 0
CreateBossExp_0E:	dc.b $80, $40, $40, 8
CreateBossExp_10:	dc.b $20, $20, $20, $18
CreateBossExp_12:	dc.b $80, $20, $20, $20
CreateBossExp_14:	dc.b	8, $80, $20, $10
CreateBossExp_16:	dc.b $80, $80, $80, 8
CreateBossExp_18:	dc.b $80, $80, $80, $28
CreateBossExp_1A:	dc.b $80, $40, $40, $28
CreateBossExp_1C:	dc.b $80, $80, $40, 8
CreateBossExp_1E:	dc.b $80, $10, $10, 8
CreateBossExp_20:	dc.b $80, $20, $20, $30

; =============== S U B R O U T I N E =======================================

Obj_WaitForParent:
		movea.w	parent3(a0),a1
		btst	#5,$38(a1)
		bne.s	loc_83EC2
		tst.l	address(a1)
		beq.s	loc_83EC2
		move.w	x_pos(a1),x_pos(a0)
		move.w	y_pos(a1),y_pos(a0)
		jmp	(Obj_Wait).w
; ---------------------------------------------------------------------------

Obj_BossExpControl1:
		move.b	$39(a0),d0
		bmi.s	loc_83E7E			; If negative, explosions are constantly created every three frames
		subq.b	#1,d0
		move.b	d0,$39(a0)			; Otherwise, continue making explosions until timer runs out
		beq.s	loc_83EC2

loc_83E7E:
		move.w	#2,$2E(a0)

sub_83E84:
		lea	Child6_MakeBossExplosion1(pc),a2
		jsr	(CreateChild6_Simple).w
		bne.s	locret_83EC0

loc_83E90:
		jsr	(Random_Number).w		; Offset the explosion by a random amount capped by an effective range
		moveq	#0,d1
		move.b	$3A(a0),d1
		move.w	d1,d2
		add.w	d2,d2
		subq.w	#1,d2
		and.w	d2,d0
		sub.w	d1,d0
		add.w	d0,x_pos(a1)
		swap	d0
		moveq	#0,d1
		move.b	$3B(a0),d1
		move.w	d1,d2
		add.w	d2,d2
		subq.w	#1,d2
		and.w	d2,d0
		sub.w	d1,d0
		add.w	d0,y_pos(a1)

locret_83EC0:
		rts
; ---------------------------------------------------------------------------

loc_83EC2:
		jmp	(Go_Delete_Sprite).w

; =============== S U B R O U T I N E =======================================

Obj_NormalExpControl:
		subq.b	#1,$39(a0)				; Same as above, but uses regular explosions (no animals of course)
		beq.s	loc_83EC2
		move.w	#2,$2E(a0)
		lea	Child6_MakeNormalExplosion(pc),a2
		jsr	(CreateChild6_Simple).w
		bne.s	locret_83EC0
		move.b	#2,routine(a1)
		bset	#7,art_tile(a1)
		bra.s	loc_83E90

; =============== S U B R O U T I N E =======================================

Obj_BossExpControl2:
		subq.b	#1,$39(a0)
		beq.s	loc_83EC2
		move.w	#2,$2E(a0)
		lea	Child6_MakeBossExplosion2(pc),a2
		jsr	(CreateChild6_Simple).w
		bne.s	locret_83EC0
		bra.s	loc_83E90

; =============== S U B R O U T I N E =======================================

Obj_BossExpControlOff:
		subq.b	#1,$39(a0)
		beq.s	loc_83EC2
		move.w	#2,$2E(a0)
		lea	Child6_MakeBossExplosionOff(pc),a2
		jsr	(CreateChild6_Simple).w
		bne.s	locret_83EC0
		bra.w	loc_83E90

; =============== S U B R O U T I N E =======================================

Obj_BossExplosionSpecial:
		move.w	#2,$2E(a0)
		move.w	(Camera_X_pos).w,d0
		addi.w	#$A0,d0
		move.w	d0,x_pos(a0)
		move.w	(Camera_Y_pos).w,d0
		addi.w	#$70,d0
		move.w	d0,y_pos(a0)
		move.b	#2,$2C(a0)
		bra.w	Obj_CreateBossExplosion

; =============== S U B R O U T I N E =======================================

Obj_BossExplosion1:
		lea	ObjDat_BossExplosion1(pc),a1
		jsr	(SetUp_ObjAttributes).w

loc_83F52:
		move.l	#Obj_BossExplosionAnim,address(a0)
		move.l	#Go_Delete_Sprite,$34(a0)
		sfx	sfx_Explode

Obj_BossExplosionAnim:
		lea	AniRaw_BossExplosion(pc),a1
		jsr	(Animate_RawNoSSTMultiDelay).w
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

Obj_BossExplosion2:
		lea	ObjDat_BossExplosion2(pc),a1
		jsr	(SetUp_ObjAttributes).w
		bra.s	loc_83F52

; =============== S U B R O U T I N E =======================================

Obj_BossExplosionOffset:
		lea	ObjDat_BossExplosion1(pc),a1
		jsr	(SetUp_ObjAttributes).w
		move.l	#Obj_BossExplosionOffsetAnim,address(a0)
		move.l	#Go_Delete_Sprite,$34(a0)
		sfx	sfx_Explode

Obj_BossExplosionOffsetAnim:
		lea	AniRaw_BossExplosion(pc),a1
		jsr	(Animate_RawNoSSTMultiDelay).w
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

ObjDat_BossExplosion1:
		dc.l Map_BossExplosion
		dc.w $8500
		dc.w 0
		dc.b 24/2
		dc.b 24/2
		dc.b 0
		dc.b 0
ObjDat_BossExplosion2:
		dc.l Map_BossExplosion
		dc.w $84D2
		dc.w 0
		dc.b 24/2
		dc.b 24/2
		dc.b 0
		dc.b 0
Child6_MakeBossExplosion1:
		dc.w 1-1
		dc.l Obj_BossExplosion1
Child6_MakeBossExplosion2:
		dc.w 1-1
		dc.l Obj_BossExplosion2
Child6_MakeBossExplosionOff:
		dc.w 1-1
		dc.l Obj_BossExplosionOffset
Child6_CreateBossExplosion:
		dc.w 1-1
		dc.l Obj_CreateBossExplosion
Child6_MakeNormalExplosion:
		dc.w 1-1
		dc.l Obj_Explosion
ChildObjDat_ExplosionSpecial:
		dc.w 1-1
		dc.l Obj_BossExplosionSpecial
AniRaw_BossExplosion:
		dc.b	0, 0
		dc.b	0, 1
		dc.b	1, 1
		dc.b	2, 2
		dc.b	3, 3
		dc.b	4, 4
		dc.b	5, 4
		dc.b arfJump
	even
; ---------------------------------------------------------------------------

		include "Objects/Explosion/Object Data/Map - Boss Explosion.asm"
