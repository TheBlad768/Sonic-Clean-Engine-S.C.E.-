; ----------------------------------------------------------------------------
; Boss explosions
; ----------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_BossExplosionSpecial:
		move.w	#2,objoff_2E(a0)						; wait
		move.w	(Camera_X_pos).w,d0
		addi.w	#320/2,d0
		move.w	d0,x_pos(a0)
		moveq	#224/2,d0
		add.w	(Camera_Y_pos).w,d0
		move.w	d0,y_pos(a0)
		move.b	#2,subtype(a0)

; ----------------------------------------------------------------------------
; Create boss explosions
; ----------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_CreateBossExplosion:

		; set
		moveq	#0,d0
		move.b	subtype(a0),d0
		add.b	d0,d0								; multiply by 2
		lea	CreateBossExpParameterIndex(pc,d0.w),a1
		move.w	(a1)+,objoff_3A(a0)
		move.b	(a1)+,objoff_39(a0)
		move.b	(a1)+,d0
		lea	CreateBossExpRoutineSet(pc,d0.w),a1
		movea.l	(a1)+,a2
		move.l	a2,address(a0)
		move.l	(a1)+,objoff_34(a0)
		jmp	(a2)
; ---------------------------------------------------------------------------

CreateBossExpRoutineSet:
		dc.l Obj_Wait, Obj_BossExpControl1					; 0
		dc.l Obj_WaitForParent, Obj_BossExpControl1				; 8
		dc.l Obj_Wait, Obj_NormalExpControl					; 10
		dc.l Obj_Wait, Obj_BossExpControl2					; 18
		dc.l Obj_WaitForParent, Obj_BossExpControl2				; 20
		dc.l Obj_WaitForParent, Obj_NormalExpControl				; 28
		dc.l Obj_WaitForParent, Obj_BossExpControlOff				; 30

CreateBossExpParameterIndex:

		; x offset range, y offset range, explosion timer, routine set
		dc.b 64/2, 64/2, $20, 0							; 0
		dc.b 256/2, 256/2, $28, $18						; 2
		dc.b 64/2, 64/2, $80, 8							; 4
		dc.b 32/2, 32/2, 4, 0							; 6
		dc.b 64/2, 64/2, 8, $10							; 8
		dc.b 64/2, 64/2, $20, 0							; A
		dc.b 256/2, 64/2, $40, 0						; C
		dc.b 128/2, 128/2, $80, 8						; E
		dc.b 64/2, 64/2, $20, $18						; 10
		dc.b 64/2, 64/2, $80, $20						; 12
		dc.b 256/2, 64/2, 8, $10						; 14
		dc.b 256/2, 256/2, $80, 8						; 16
		dc.b 256/2, 256/2, $80, $28						; 18
		dc.b 128/2, 128/2, $80, $28						; 1A
		dc.b 256/2, 128/2, $80, 8						; 1C
		dc.b 32/2, 32/2, $80, 8							; 1E
		dc.b 64/2, 64/2, $80, $30						; 20

; =============== S U B R O U T I N E =======================================

Obj_WaitForParent:
		movea.w	parent3(a0),a1							; a1=parent object
		btst	#5,objoff_38(a1)
		bne.s	loc_83EC2
		tst.l	address(a1)							; is object RAM slot empty?
		beq.s	loc_83EC2							; if yes, branch
		move.w	x_pos(a1),x_pos(a0)
		move.w	y_pos(a1),y_pos(a0)
		jmp	(Obj_Wait).w
; ---------------------------------------------------------------------------

Obj_BossExpControl1:
		move.b	objoff_39(a0),d0
		bmi.s	loc_83E7E							; if negative, explosions are constantly created every three frames
		subq.b	#1,d0
		move.b	d0,objoff_39(a0)						; otherwise, continue making explosions until timer runs out
		beq.s	loc_83EC2

loc_83E7E:
		move.w	#2,objoff_2E(a0)						; wait

sub_83E84:
		lea	Child6_MakeBossExplosion1(pc),a2
		jsr	(CreateChild6_Simple).w
		bne.s	locret_83EC0

loc_83E90:
		jsr	(Random_Number).w						; offset the explosion by a random amount capped by an effective range
		moveq	#0,d1
		move.b	objoff_3A(a0),d1
		move.w	d1,d2
		add.w	d2,d2
		subq.w	#1,d2
		and.w	d2,d0
		sub.w	d1,d0
		add.w	d0,x_pos(a1)
		swap	d0
		moveq	#0,d1
		move.b	objoff_3B(a0),d1
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

; ----------------------------------------------------------------------------
; Normal boss explosions control
; ----------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_NormalExpControl:

		; wait
		subq.b	#1,objoff_39(a0)						; same as above, but uses regular explosions (no animals of course)
		beq.s	loc_83EC2
		move.w	#2,objoff_2E(a0)						; wait

		; create
		lea	Child6_MakeNormalExplosion(pc),a2
		jsr	(CreateChild6_Simple).w
		bne.s	locret_83EC0
		bset	#high_priority_bit,art_tile(a1)					; high priority
		bra.s	loc_83E90

; ----------------------------------------------------------------------------
; Boss explosions control 2
; ----------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_BossExpControl2:

		; wait
		subq.b	#1,objoff_39(a0)
		beq.s	loc_83EC2
		move.w	#2,objoff_2E(a0)						; wait

		; create
		lea	Child6_MakeBossExplosion2(pc),a2
		jsr	(CreateChild6_Simple).w
		bne.s	locret_83EC0
		bra.s	loc_83E90

; ----------------------------------------------------------------------------
; Boss explosions control offset
; ----------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_BossExpControlOff:

		; wait
		subq.b	#1,objoff_39(a0)
		beq.s	loc_83EC2
		move.w	#2,objoff_2E(a0)						; wait

		; create
		lea	Child6_MakeBossExplosionOff(pc),a2
		jsr	(CreateChild6_Simple).w
		bne.s	locret_83EC0
		bra.w	loc_83E90

; ----------------------------------------------------------------------------
; Boss explosions 2
; ----------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_BossExplosion2:

		; init
		lea	ObjDat_BossExplosion2(pc),a1
		jsr	(SetUp_ObjAttributes).w
		bra.s	loc_83F52

; ----------------------------------------------------------------------------
; Boss explosions 1
; ----------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_BossExplosion1:

		; init
		lea	ObjDat_BossExplosion1(pc),a1
		jsr	(SetUp_ObjAttributes).w

loc_83F52:
		move.l	#Obj_BossExplosionAnim,address(a0)
		move.l	#Go_Delete_Sprite,objoff_34(a0)
		sfx	sfx_Explode

Obj_BossExplosionAnim:
		lea	AniRaw_BossExplosion(pc),a1
		jsr	(Animate_RawNoSSTMultiDelay).w
		jmp	(Draw_Sprite).w

; ----------------------------------------------------------------------------
; Boss explosions offset
; ----------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_BossExplosionOffset:

		; init
		lea	ObjDat_BossExplosion1(pc),a1
		jsr	(SetUp_ObjAttributes).w
		move.l	#.main,address(a0)
		move.l	#Go_Delete_Sprite,objoff_34(a0)
		sfx	sfx_Explode

.main
		lea	AniRaw_BossExplosion(pc),a1
		jsr	(Animate_RawNoSSTMultiDelay).w
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

; mapping
ObjDat_BossExplosion1:	subObjData Map_BossExplosion, $500, 0, 1, 24, 24, 0, 0, 0
ObjDat_BossExplosion2:	subObjData Map_BossExplosion, $4D2, 0, 1, 24, 24, 0, 0, 0

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
		dc.l Obj_Explosion.skipanimal
Child6_ExplosionSpecial:
		dc.w 1-1
		dc.l Obj_BossExplosionSpecial

AniRaw_BossExplosion:
		dc.b 0, 0	; frame, wait
		dc.b 0, 1
		dc.b 1, 1
		dc.b 2, 2
		dc.b 3, 3
		dc.b 4, 4
		dc.b 5, 4
		dc.b arfJump
	even
; ---------------------------------------------------------------------------

		include "Objects/Main/Explosion/Object Data/Map - Boss Explosion.asm"
