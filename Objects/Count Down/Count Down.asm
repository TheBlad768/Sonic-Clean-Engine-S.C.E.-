
; =============== S U B R O U T I N E =======================================

Obj_Air_CountDown:
		moveq	#0,d0
		move.b	routine(a0),d0
		move.w	off_18172(pc,d0.w),d1
		jmp	off_18172(pc,d1.w)
; ---------------------------------------------------------------------------

off_18172: offsetTable
		offsetTableEntry.w loc_18184
		offsetTableEntry.w loc_181DC
		offsetTableEntry.w loc_181E8
		offsetTableEntry.w loc_18254
		offsetTableEntry.w loc_1826C
		offsetTableEntry.w Player_TestAirTimer
		offsetTableEntry.w loc_18272
		offsetTableEntry.w loc_182B2
		offsetTableEntry.w loc_1826C
; ---------------------------------------------------------------------------

loc_18184:
		addq.b	#2,routine(a0)
		move.l	#Map_Bubbler,mappings(a0)
		move.w	#$570,art_tile(a0)
		move.b	#$84,render_flags(a0)
		move.b	#$10,width_pixels(a0)
		move.w	#$80,priority(a0)
		move.b	subtype(a0),d0
		bpl.s	loc_181CC
		addq.b	#8,routine(a0)
		andi.w	#$7F,d0
		move.b	d0,$37(a0)
		bra.w	Player_TestAirTimer
; ---------------------------------------------------------------------------

loc_181CC:
		move.b	d0,$20(a0)
		move.w	$10(a0),$34(a0)
		move.w	#-$100,y_vel(a0)

loc_181DC:
		lea	Ani_Shields(pc),a1
		jsr	(Animate_Sprite).l

loc_181E8:
		move.w	(Water_level).w,d0
		cmp.w	$14(a0),d0
		blo.s		loc_1820E
		move.b	#6,5(a0)
		addq.b	#7,$20(a0)
		cmpi.b	#$D,$20(a0)
		beq.s	loc_18254
		bcs.s	loc_18254
		move.b	#$D,$20(a0)
		bra.s	loc_18254
; ---------------------------------------------------------------------------

loc_1820E:
		tst.b	(WindTunnel_flag).w
		beq.s	loc_18218
		addq.w	#4,$34(a0)

loc_18218:
		move.b	$26(a0),d0
		addq.b	#1,$26(a0)
		andi.w	#$7F,d0
		lea	byte_1831E(pc),a1
		move.b	(a1,d0.w),d0
		ext.w	d0
		add.w	$34(a0),d0
		move.w	d0,$10(a0)
		bsr.w	sub_182D2
		jsr	(MoveSprite2).l
		tst.b	4(a0)
		bpl.s	loc_1824E
		jmp	(Draw_Sprite).l
; ---------------------------------------------------------------------------

loc_1824E:
		jmp	(Delete_Current_Sprite).l
; ---------------------------------------------------------------------------

loc_18254:
		bsr.s	sub_182D2
		lea	Ani_Shields(pc),a1
		jsr	(Animate_Sprite).l
		bsr.w	AirCountdown_Load_Art
		jmp	(Draw_Sprite).l
; ---------------------------------------------------------------------------

loc_1826C:
		jmp	(Delete_Current_Sprite).l
; ---------------------------------------------------------------------------

loc_18272:
		movea.l	$40(a0),a2
		cmpi.b	#$C,$2C(a2)
		bhi.s	loc_182AC
		subq.w	#1,$3C(a0)
		bne.s	loc_18290
		move.b	#$E,5(a0)
		addq.b	#7,$20(a0)
		bra.s	loc_18254
; ---------------------------------------------------------------------------

loc_18290:
		lea	Ani_Shields(pc),a1
		jsr	(Animate_Sprite).l
		bsr.w	AirCountdown_Load_Art
		tst.b	4(a0)
		bpl.s	loc_182AC
		jmp	(Draw_Sprite).l
; ---------------------------------------------------------------------------

loc_182AC:
		jmp	(Delete_Current_Sprite).l
; ---------------------------------------------------------------------------

loc_182B2:
		movea.l	$40(a0),a2
		cmpi.b	#$C,$2C(a2)
		bhi.s	loc_1826C
		bsr.s	sub_182D2
		lea	Ani_Shields(pc),a1
		jsr	(Animate_Sprite).l
		jmp	(Draw_Sprite).l

; =============== S U B R O U T I N E =======================================

sub_182D2:
		tst.w	$3C(a0)
		beq.s	locret_1831C
		subq.w	#1,$3C(a0)
		bne.s	locret_1831C
		cmpi.b	#7,$20(a0)
		bhs.s	locret_1831C
		move.w	#$F,$3C(a0)
		clr.w	$1A(a0)
		move.b	#-$80,4(a0)
		move.w	$10(a0),d0
		sub.w	(Camera_X_pos).w,d0
		addi.w	#$80,d0
		move.w	d0,$10(a0)
		move.w	$14(a0),d0
		sub.w	(Camera_Y_pos).w,d0
		addi.w	#$80,d0
		move.w	d0,$14(a0)
		move.b	#$C,5(a0)

locret_1831C:
		rts
; End of function sub_182D2
; ---------------------------------------------------------------------------

byte_1831E:
		dc.b	0,   0,	  0,   0,   0,	 0,   1,   1,	1,   1,	  1,   2,   2,	 2,   2,   2
		dc.b	2,   2,	  3,   3,   3,	 3,   3,   3,	3,   3,	  3,   3,   3,	 3,   3,   3
		dc.b	3,   3,	  3,   3,   3,	 3,   3,   3,	3,   3,	  3,   3,   3,	 3,   3,   2
		dc.b	2,   2,	  2,   2,   2,	 2,   1,   1,	1,   1,	  1,   0,   0,	 0,   0,   0
		dc.b	0, $FF,	$FF, $FF, $FF, $FF, $FE, $FE, $FE, $FE,	$FE, $FD, $FD, $FD, $FD, $FD
		dc.b  $FD, $FD,	$FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC,	$FC, $FC, $FC, $FC, $FC, $FC
		dc.b  $FC, $FC,	$FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC,	$FC, $FC, $FC, $FC, $FC, $FD
		dc.b  $FD, $FD,	$FD, $FD, $FD, $FD, $FE, $FE, $FE, $FE,	$FE, $FF, $FF, $FF, $FF, $FF
		dc.b	0,   0,	  0,   0,   0,	 0,   1,   1,	1,   1,	  1,   2,   2,	 2,   2,   2
		dc.b	2,   2,	  3,   3,   3,	 3,   3,   3,	3,   3,	  3,   3,   3,	 3,   3,   3
		dc.b	3,   3,	  3,   3,   3,	 3,   3,   3,	3,   3,	  3,   3,   3,	 3,   3,   2
		dc.b	2,   2,	  2,   2,   2,	 2,   1,   1,	1,   1,	  1,   0,   0,	 0,   0,   0
		dc.b	0, $FF,	$FF, $FF, $FF, $FF, $FE, $FE, $FE, $FE,	$FE, $FD, $FD, $FD, $FD, $FD
		dc.b  $FD, $FD,	$FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC,	$FC, $FC, $FC, $FC, $FC, $FC
		dc.b  $FC, $FC,	$FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC,	$FC, $FC, $FC, $FC, $FC, $FD
		dc.b  $FD, $FD,	$FD, $FD, $FD, $FD, $FE, $FE, $FE, $FE,	$FE, $FF, $FF, $FF, $FF, $FF

; =============== S U B R O U T I N E =======================================

AirCountdown_Load_Art:
		moveq	#0,d1
		move.b	$22(a0),d1
		cmpi.b	#9,d1
		blo.s		locret_18464
		cmpi.b	#$13,d1
		bhs.s	locret_18464
		cmp.b	$32(a0),d1
		beq.s	locret_18464
		move.b	d1,$32(a0)
		subi.w	#9,d1
		move.w	d1,d0
		add.w	d1,d1
		add.w	d0,d1
		lsl.w	#6,d1
		addi.l	#ArtUnc_AirCountDown,d1
		move.w	#$FC00,d2
		move.w	#$60,d3
		jsr	(Add_To_DMA_Queue).l

locret_18464:
		rts
; End of function AirCountdown_Load_Art
; ---------------------------------------------------------------------------

Player_TestAirTimer:
		movea.l	$40(a0),a2
		tst.w	$30(a0)
		bne.w	loc_1857C
		cmpi.b	#id_SonicDeath,routine(a2)
		bhs.w	locret_18680
		btst	#Status_BublShield,status_secondary(a2)
		bne.w	locret_18680
		btst	#Status_Underwater,status(a2)
		beq.w	locret_18680
		subq.w	#1,$3C(a0)
		bpl.w	loc_18594
		move.w	#$3B,$3C(a0)
		move.w	#1,$3A(a0)
		jsr	(Random_Number).l
		andi.w	#1,d0
		move.b	d0,$38(a0)
		moveq	#0,d0
		move.b	$2C(a2),d0
		cmpi.w	#$19,d0
		beq.s	loc_184FC
		cmpi.w	#$14,d0
		beq.s	loc_184FC
		cmpi.w	#$F,d0
		beq.s	loc_184FC
		cmpi.w	#$C,d0
		bhi.s	loc_1850A
		bne.s	loc_184E8
		moveq	#bgm_Drowning,d0	; Drowning music
		jsr	(Play_Sound).l

loc_184E8:
		subq.b	#1,$36(a0)
		bpl.s	loc_1850A
		move.b	$37(a0),$36(a0)
		bset	#7,$3A(a0)
		bra.s	loc_1850A
; ---------------------------------------------------------------------------

loc_184FC:
		sfx	sfx_Warning,0,0,0

loc_1850A:
		subq.b	#1,$2C(a2)
		bcc.w	loc_18592
		move.b	#-$7F,$2E(a2)
		sfx	sfx_Drown,0,0,0
		move.b	#$A,$38(a0)
		move.w	#1,$3A(a0)
		move.w	#$78,$30(a0)
		movea.l	a2,a1
		bsr.w	Player_ResetAirTimer
		move.l	a0,-(sp)
		movea.l	a2,a0
		bsr.w	Sonic_ResetOnFloor
		move.b	#$17,$20(a0)
		bset	#1,$2A(a0)
		bset	#7,$A(a0)
		move.w	#0,$1A(a0)
		move.w	#0,$18(a0)
		move.w	#0,$1C(a0)
		move.b	#$C,5(a0)
		movea.l	(sp)+,a0
		move.b	#1,(Deform_lock).w
		rts
; ---------------------------------------------------------------------------

loc_1857C:
		move.b	#$17,$20(a2)
		subq.w	#1,$30(a0)
		bne.s	loc_18590
		move.b	#6,5(a2)
		rts
; ---------------------------------------------------------------------------

loc_18590:
		bra.s	loc_18594
; ---------------------------------------------------------------------------

loc_18592:
		bra.s	loc_185A4
; ---------------------------------------------------------------------------

loc_18594:
		tst.w	$3A(a0)
		beq.w	locret_18680
		subq.w	#1,$3E(a0)
		bpl.w	locret_18680

loc_185A4:
		jsr	(Random_Number).l
		andi.w	#$F,d0
		addq.w	#8,d0
		move.w	d0,$3E(a0)
		jsr	(Create_New_Sprite).l
		bne.w	locret_18680
		move.l	(a0),(a1)
		move.w	$10(a2),$10(a1)
		moveq	#6,d0
		btst	#0,$2A(a2)
		beq.s	loc_185D8
		neg.w	d0
		move.b	#$40,$26(a1)

loc_185D8:
		add.w	d0,$10(a1)
		move.w	$14(a2),$14(a1)
		move.l	$40(a0),$40(a1)
		move.b	#6,$2C(a1)
		tst.w	$30(a0)
		beq.w	loc_1862A
		andi.w	#7,$3E(a0)
		addi.w	#0,$3E(a0)
		move.w	$14(a2),d0
		subi.w	#$C,d0
		move.w	d0,$14(a1)
		jsr	(Random_Number).l
		move.b	d0,$26(a1)
		move.w	(Level_frame_counter).w,d0
		andi.b	#3,d0
		bne.s	loc_18676
		move.b	#$E,$2C(a1)
		bra.s	loc_18676
; ---------------------------------------------------------------------------

loc_1862A:
		btst	#7,$3A(a0)
		beq.s	loc_18676
		moveq	#0,d2
		move.b	$2C(a2),d2
		cmpi.b	#$C,d2
		bhs.s	loc_18676
		lsr.w	#1,d2
		jsr	(Random_Number).l
		andi.w	#3,d0
		bne.s	loc_1865E
		bset	#6,$3A(a0)
		bne.s	loc_18676
		move.b	d2,$2C(a1)
		move.w	#$1C,$3C(a1)

loc_1865E:
		tst.b	$38(a0)
		bne.s	loc_18676
		bset	#6,$3A(a0)
		bne.s	loc_18676
		move.b	d2,$2C(a1)
		move.w	#$1C,$3C(a1)

loc_18676:
		subq.b	#1,$38(a0)
		bpl.s	locret_18680
		clr.w	$3A(a0)

locret_18680:
		rts

; =============== S U B R O U T I N E =======================================

Player_ResetAirTimer:
		cmpi.b	#12,air_left(a1)
		bhi.s	+
		move.w	(Level_music).w,d0
		btst	#Status_Invincible,status_secondary(a1)
		beq.s	+
		move.w	#bgm_Invincible,d0	; If invincible, play invincibility music
+		tst.b	(Boss_flag).w
		beq.s	+
		move.w	#bgm_MidBoss,d0	; If boss, play boss music
+		jsr	(Play_Sound).l
+		move.b	#30,air_left(a1)
		rts
; End of function Player_ResetAirTimer
; ---------------------------------------------------------------------------

		include "Objects/Count Down/Object Data/Anim - Shields.asm"