; ---------------------------------------------------------------------------
; Egg Capsule (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_EggCapsule:
		moveq	#0,d0
		move.b	routine(a0),d0
		move.w	off_86566(pc,d0.w),d1
		move.w	x_pos(a0),-(sp)
		jsr	off_86566(pc,d1.w)
		moveq	#$2B,d1
		moveq	#$18,d2
		moveq	#$18,d3
		move.w	(sp)+,d4
		jsr	(SolidObjectFull).w
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

off_86566: offsetTable
		offsetTableEntry.w loc_8657A
		offsetTableEntry.w loc_865D0
		offsetTableEntry.w loc_8661E
		offsetTableEntry.w loc_86626
		offsetTableEntry.w loc_8662A
		offsetTableEntry.w loc_866BA
		offsetTableEntry.w loc_866CC
		offsetTableEntry.w loc_866DA
		offsetTableEntry.w loc_866EC
		offsetTableEntry.w loc_86716
; ---------------------------------------------------------------------------

loc_8657A:
		lea	PLC_EggCapsule(pc),a5
		jsr	(LoadPLC_Raw_KosM).w
		lea	ObjDat3_86B32(pc),a1
		jsr	(SetUp_ObjAttributes).w
		btst	#1,render_flags(a0)
		bne.s	loc_86592
		lea	ChildObjDat_86B5C(pc),a2
		jmp	(CreateChild1_Normal).w
; ---------------------------------------------------------------------------

loc_86592:
		move.b	#8,routine(a0)
		move.w	(Camera_X_pos).w,d0
		addi.w	#$A0,d0
		move.w	d0,x_pos(a0)
		move.w	d0,$3E(a0)
		move.w	(Camera_Y_pos).w,d0
		subi.w	#$40,d0
		move.w	d0,y_pos(a0)
		move.w	#1,$3A(a0)
		jsr	(Swing_Setup1).w
		lea	ChildObjDat_86B64(pc),a2
		jsr	(CreateChild1_Normal).w
		lea	ChildObjDat_86B6C(pc),a2
		jmp	(CreateChild1_Normal).w
; ---------------------------------------------------------------------------

loc_865D0:
		btst	#1,$38(a0)
		beq.s	locret_8661C
		move.b	#4,routine(a0)

sub_865DE:
		move.b	#1,mapping_frame(a0)
		move.w	#$40,$2E(a0)
		lea	ChildObjDat_86B7A(pc),a2
		jsr	(CreateChild1_Normal).w
		lea	ChildObjDat_86B9A(pc),a2
		jsr	(CreateChild1_Normal).w
		lea	Child6_CreateBossExplosion(pc),a2
		jsr	(CreateChild6_Simple).w
		bne.s	locret_8661C
		move.b	#8,subtype(a1)

locret_8661C:
		rts
; ---------------------------------------------------------------------------

loc_8661E:
		move.b	#6,d0
		bra.w	sub_868F8
; ---------------------------------------------------------------------------

loc_86626:
		rts
; ---------------------------------------------------------------------------

loc_8662A:
		move.w	(Camera_X_pos).w,d0
		move.w	$3A(a0),d1
		bmi.s	loc_86642
		addi.w	#$110,d0
		cmp.w	x_pos(a0),d0
		bcs.s	loc_8664C
		bra.w	loc_8664E
; ---------------------------------------------------------------------------

loc_86642:
		addi.w	#$30,d0
		cmp.w	x_pos(a0),d0
		bcs.s	loc_8664E

loc_8664C:
		neg.w	d1

loc_8664E:
		move.w	d1,$3A(a0)
		add.w	d1,x_pos(a0)
		move.w	(Camera_Y_pos).w,d0
		addi.w	#$40,d0
		move.l	#$4000,d1
		cmp.w	y_pos(a0),d0
		bhi.s	loc_86678
		neg.l	d1

loc_86678:
		add.l	d1,y_pos(a0)
		btst	#1,$38(a0)
		beq.s	loc_86698
		moveq	#0,d0
		move.b	(Current_zone).w,d0
		move.b	byte_866A2(pc,d0.w),routine(a0)
		move.w	a1,$44(a0)
		bsr.w	sub_865DE

loc_86698:
		jsr	(Swing_UpAndDown).w
		jmp	(MoveSprite2).w
; ---------------------------------------------------------------------------

byte_866A2:
		dc.b $A	; DEZ
		dc.b $A	; Null
; ---------------------------------------------------------------------------

loc_866BA:
		move.b	#$C,d0
		bsr.w	sub_868F8
		bra.s	loc_86698
; ---------------------------------------------------------------------------

loc_866CC:
		bra.s	loc_86698
; ---------------------------------------------------------------------------

loc_866DA:
		move.b	#$C,d0
		bsr.w	sub_86984
		bra.s	loc_86698
; ---------------------------------------------------------------------------

loc_866EC:
		move.b	#$12,d0
		bsr.w	sub_868F8

loc_866F4:
		jsr	(Swing_UpAndDown).w
		move.w	(Camera_X_pos).w,d0
		subi.w	#$60,d0
		cmp.w	x_pos(a0),d0
		bcs.s	loc_8670C
		rts
; ---------------------------------------------------------------------------

loc_8670C:
		subq.w	#2,x_pos(a0)
		jmp	(MoveSprite2).w
; ---------------------------------------------------------------------------

loc_86716:
		bra.s	loc_866F4
; ---------------------------------------------------------------------------

loc_8671C:
		move.l	#loc_8672A,address(a0)
		lea	word_86B3E(pc),a1
		jmp	(SetUp_ObjAttributes3).w
; ---------------------------------------------------------------------------

loc_8672A:
		bsr.w	sub_86A3E
		move.b	$2A(a0),d0
		andi.b	#$18,d0
		beq.s	loc_86750
		move.l	#loc_86754,address(a0)
		movea.w	$46(a0),a1
		bset	#1,$38(a1)
		move.b	#$C,mapping_frame(a0)

loc_86750:
		jmp	(Child_Draw_Sprite).w
; ---------------------------------------------------------------------------

loc_86754:
		bsr.w	sub_86A3E
		jmp	(Child_Draw_Sprite).w
; ---------------------------------------------------------------------------

loc_8675C:
		move.l	#loc_86770,address(a0)
		bset	#1,render_flags(a0)
		lea	word_86B3E(pc),a1
		jmp	(SetUp_ObjAttributes3).w
; ---------------------------------------------------------------------------

loc_86770:
		jsr	(Refresh_ChildPosition).w
		bsr.w	sub_86A54
		lea	word_867C2(pc),a1
		jsr	(Check_PlayerInRange).w
		tst.l	d0
		beq.s	loc_867BE
		tst.w	d0
		beq.s	loc_867A0
		movea.w	d0,a1
		tst.w	y_vel(a1)
		bpl.s	loc_867A0
		cmpi.b	#id_Roll,anim(a1)
		beq.s	loc_867AA
		cmpi.b	#1,$38(a1)
		beq.s	loc_867AA

loc_867A0:
		swap	d0
		movea.w	d0,a1
		tst.w	y_vel(a1)
		bpl.s	loc_867BE

loc_867AA:
		move.l	#loc_867CA,address(a0)
		subq.b	#8,$43(a0)
		movea.w	$46(a0),a1
		bset	#1,$38(a1)

loc_867BE:
		jmp	(Child_Draw_Sprite).w
; ---------------------------------------------------------------------------
word_867C2:	dc.w  $FFE6,   $34, $FFE4,   $38
; ---------------------------------------------------------------------------

loc_867CA:
		jsr	(Refresh_ChildPosition).w
		bsr.w	sub_86A54
		jmp	(Child_Draw_Sprite).w
; ---------------------------------------------------------------------------

loc_867D6:
		lea	ObjDat3_86B44(pc),a1
		jsr	(SetUp_ObjAttributes).w
		move.l	#Obj_FlickerMove,address(a0)
		bsr.w	sub_86A64
		moveq	#4,d0
		jsr	(Set_IndexedVelocity).w
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

loc_86802:
		lea	word_86B56(pc),a1
		jsr	(SetUp_ObjAttributes3).w
		move.l	#loc_86810,address(a0)

loc_86810:
		jsr	(Refresh_ChildPosition).w
		lea	AniRaw_86BF6(pc),a1
		jsr	(Animate_RawNoSST).w
		jmp	(Child_Draw_Sprite).w
; ---------------------------------------------------------------------------

loc_86820:
		lea	word_86B50(pc),a1
		jsr	(SetUp_ObjAttributes3).w
		move.l	#loc_8683E,address(a0)
		move.b	#16/2,y_radius(a0)
		bsr.w	sub_86A7A
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

loc_8683E:
		subq.w	#1,$2E(a0)
		bpl.s	loc_86850
		move.l	#loc_86854,address(a0)
		move.w	#$80,priority(a0)

loc_86850:
		jmp	(Sprite_CheckDelete).w
; ---------------------------------------------------------------------------

loc_86854:
		jsr	(MoveSprite_LightGravity).w
		jsr	(ObjHitFloor).w
		tst.w	d1
		bpl.s	loc_86888
		add.w	d1,y_pos(a0)
		move.w	$3E(a0),y_vel(a0)
		jsr	(Find_Sonic).w
		move.w	#-$200,d1
		tst.b	(Level_end_flag).w
		beq.s	loc_86880
		tst.w	d0
		beq.s	loc_86880
		neg.w	d1

loc_86880:
		move.w	d1,x_vel(a0)
		jsr	(Change_FlipXWithVelocity2).w

loc_86888:
		moveq	#0,d0
		btst	#3,(V_int_run_count+3).w
		bne.s	loc_86894
		moveq	#1,d0

loc_86894:
		move.b	d0,mapping_frame(a0)
		jmp	(Sprite_CheckDelete).w
; ---------------------------------------------------------------------------

loc_8689C:
		jsr	(Refresh_ChildPosition).w
		subq.w	#1,$2E(a0)
		bpl.s	loc_868B2
		move.l	#loc_868B6,address(a0)
		move.w	#$80,priority(a0)

loc_868B2:
		jmp	(Sprite_CheckDelete).w
; ---------------------------------------------------------------------------

loc_868B6:
		lea	(Player_1).w,a1
		move.w	#$300,d0
		move.w	#$100,d1
		moveq	#$10,d2
		moveq	#0,d3
		move.w	#-$30,d4
		sub.b	subtype(a0),d4
		bsr.w	sub_869F6
		jsr	(MoveSprite2).w
		jsr	(Change_FlipXWithVelocity2).w
		tst.b	(Level_end_flag).w
		bne.s	loc_868F0
		move.l	#loc_868F2,address(a0)
		bset	#0,render_flags(a0)

loc_868F0:
		bra.s	loc_86888
; ---------------------------------------------------------------------------

loc_868F2:
		subq.w	#2,x_pos(a0)
		bra.s	loc_86888

; =============== S U B R O U T I N E =======================================

sub_86A3E:
		moveq	#$1B,d1
		moveq	#4,d2
		moveq	#6,d3
		move.w	x_pos(a0),d4
		jmp	(SolidObjectFull).w

; =============== S U B R O U T I N E =======================================

sub_86A54:
		moveq	#$1B,d1
		moveq	#5,d2
		moveq	#9,d3
		move.w	x_pos(a0),d4
		jmp	(SolidObjectFull).w

; =============== S U B R O U T I N E =======================================

sub_86A64:
		moveq	#0,d0
		move.b	subtype(a0),d0
		lsr.w	#1,d0
		move.b	byte_86A74(pc,d0.w),mapping_frame(a0)
		rts
; ---------------------------------------------------------------------------

byte_86A74:
		dc.b 2
		dc.b 3
		dc.b $A
		dc.b 4
		dc.b $B
		dc.b 0

; =============== S U B R O U T I N E =======================================

sub_868F8:
		subq.w	#1,$2E(a0)
		bpl.s	locret_86930
		lea	(Player_1).w,a1
		btst	#7,status(a1)
		bne.s	locret_86930
		btst	#Status_InAir,status(a1)
		bne.s	locret_86930
		cmpi.b	#id_SonicDeath,routine(a1)
		bcc.s	locret_86930
		move.b	d0,routine(a0)
		jsr	(Set_PlayerEndingPose).w
		jsr	(Create_New_Sprite).w
		bne.s	locret_86930
		move.l	#Obj_LevelResults,address(a1)

locret_86930:
		rts

; =============== S U B R O U T I N E =======================================

sub_86984:
		subq.w	#1,$2E(a0)
		bpl.s	locret_869C4
		lea	(Player_1).w,a1
		cmpi.b	#id_SonicDeath,routine(a1)
		bhs.s	locret_869C4
		tst.b	render_flags(a1)
		bpl.s	locret_869C4
		move.w	#-$100,x_vel(a0)
		move.b	d0,routine(a0)
		jsr	(Create_New_Sprite).w
		bne.s	loc_869C2
		move.l	#Obj_LevelResults,address(a1)

loc_869C2:
		moveq	#1,d0

locret_869C4:
		rts

; =============== S U B R O U T I N E =======================================

sub_869F6:
		move.w	d2,d5
		move.w	x_pos(a1),d6
		add.w	d3,d6
		cmp.w	x_pos(a0),d6
		bhs.s	loc_86A06
		neg.w	d2

loc_86A06:
		move.w	x_vel(a0),d6
		add.w	d2,d6
		cmp.w	d0,d6
		bgt.s	loc_86A1A
		neg.w	d0
		cmp.w	d0,d6
		blt.s		loc_86A1A
		move.w	d6,x_vel(a0)

loc_86A1A:
		move.w	y_pos(a1),d6
		add.w	d4,d6
		cmp.w	y_pos(a0),d6
		bhs.s	loc_86A28
		neg.w	d5

loc_86A28:
		move.w	y_vel(a0),d6
		add.w	d5,d6
		cmp.w	d1,d6
		bgt.s	locret_86A3C
		neg.w	d1
		cmp.w	d1,d6
		blt.s		loc_86A1A
		move.w	d6,y_vel(a0)

locret_86A3C:
		rts

; =============== S U B R O U T I N E =======================================

sub_86A7A:
		moveq	#0,d0
		move.b	subtype(a0),d0
		move.w	d0,d1
		andi.w	#6,d0
		lea	word_86B0E(pc),a1
		move.w	(a1,d0.w),d2
		move.w	d2,y_vel(a0)
		move.w	d2,$3E(a0)
		movea.w	$46(a0),a1
		btst	#1,render_flags(a1)
		beq.s	loc_86AB0
		move.l	#loc_8689C,address(a0)
		addq.b	#8,$43(a0)
		clr.w	y_vel(a0)

loc_86AB0:
		andi.w	#2,d0
		move.w	d0,d2
		move.w	word_86B16(pc,d2.w),art_tile(a0)
		moveq	#0,d2
		move.b	(Current_zone).w,d2
		add.w	d2,d2
		lea	byte_2C7BA(pc),a1
		adda.w	d2,a1
		lsr.w	#1,d0
		move.b	(a1,d0.w),d0
		lsl.w	#3,d0
		lea	word_2C7EA(pc),a2
		move.l	4(a2,d0.w),mappings(a0)
		lsl.w	#2,d1
		move.w	d1,$2E(a0)
		movea.w	$46(a0),a1
		move.w	x_pos(a0),d0
		move.w	#$200,d1
		cmp.w	x_pos(a1),d0
		bhs.s	loc_86B04
		neg.w	d1

loc_86B04:
		move.w	d1,x_vel(a0)
		jmp	(Change_FlipXWithVelocity2).w

; =============== S U B R O U T I N E =======================================

Load_EggCapsule:
		st	(LastAct_end_flag).w
		st	(Level_end_flag).w
		clr.b	(Boss_flag).w
		lea	ChildObjDat_EggCapsule(pc),a2
		jmp	(CreateChild6_Simple).w
; ---------------------------------------------------------------------------

word_86B0E:
		dc.w -$380
		dc.w -$300
		dc.w -$280
		dc.w -$200
word_86B16:
		dc.w $8580
		dc.w $8592
		dc.w $842E
		dc.w $8440
ObjDat3_86B32:
		dc.l Map_EggCapsule
		dc.w $843E
		dc.w $200
		dc.b $20
		dc.b $20
		dc.b 0
		dc.b 0
word_86B3E:
		dc.w $200
		dc.b $10
		dc.b 8
		dc.b 5
		dc.b 0
ObjDat3_86B44:
		dc.l Map_EggCapsule
		dc.w $843E
		dc.w $180
		dc.b $C
		dc.b $C
		dc.b 0
		dc.b 0
word_86B50:
		dc.w $280
		dc.b 8
		dc.b 8
		dc.b 2
		dc.b 0
word_86B56:
		dc.w $200
		dc.b $14
		dc.b 4
		dc.b 6
		dc.b 0
ChildObjDat_EggCapsule:
		dc.w 1-1
		dc.l Obj_EggCapsule
ChildObjDat_86B5C:
		dc.w 1-1
		dc.l loc_8671C
		dc.w $DC
ChildObjDat_86B64:
		dc.w 1-1
		dc.l loc_8675C
		dc.w $24
ChildObjDat_86B6C:
		dc.w 2-1
		dc.l loc_86802
		dc.w $ECDC
		dc.l loc_86802
		dc.w $14DC
ChildObjDat_86B7A:
		dc.w 5-1
		dc.l loc_867D6
		dc.w $F8
		dc.l loc_867D6
		dc.w $F0F8
		dc.l loc_867D6
		dc.w $10F8
		dc.l loc_867D6
		dc.w $E8F8
		dc.l loc_867D6
		dc.w $18F8
ChildObjDat_86B9A:
		dc.w 9-1			; why not 15-1?
		dc.l loc_86820
		dc.w $FC
		dc.l loc_86820
		dc.w $F8FC
		dc.l loc_86820
		dc.w $8FC
		dc.l loc_86820
		dc.w $10FC
		dc.l loc_86820
		dc.w $F0FC
		dc.l loc_86820
		dc.w $E8FC
		dc.l loc_86820
		dc.w $18FC
		dc.l loc_86820
		dc.w $FCFC
		dc.l loc_86820
		dc.w $4FC
		dc.l loc_86820
		dc.w $CFC
		dc.l loc_86820
		dc.w $F4FC
		dc.l loc_86820
		dc.w $ECFC
		dc.l loc_86820
		dc.w $14FC
		dc.l loc_86820
		dc.w $1CFC
		dc.l loc_86820
		dc.w $E4FC
AniRaw_86BF6:
		dc.b 0
		dc.b 6
		dc.b 7
		dc.b 8
		dc.b 9
		dc.b arfEnd
PLC_EggCapsule: plrlistheader
		plreq $43E, ArtKosM_EggCapsule
		plreq $5A0, ArtKosM_Explosion
PLC_EggCapsule_end
; ---------------------------------------------------------------------------

		include "Objects/Egg Capsule/Object Data/Map - Egg Capsule.asm"
