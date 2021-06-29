; ----------------------------------------------------------------------------
; Small bubbles from Sonic's face while underwater
; ----------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_Air_CountDown:
		moveq	#0,d0
		move.b	routine(a0),d0
		move.w	AirCountdown_Index(pc,d0.w),d1
		jmp	AirCountdown_Index(pc,d1.w)
; ---------------------------------------------------------------------------

AirCountdown_Index: offsetTable
		offsetTableEntry.w AirCountdown_Init
		offsetTableEntry.w AirCountdown_Animate
		offsetTableEntry.w AirCountdown_ChkWater
		offsetTableEntry.w AirCountdown_Display
		offsetTableEntry.w AirCountdown_Delete
		offsetTableEntry.w AirCountdown_Countdown
		offsetTableEntry.w AirCountdown_AirLeft
		offsetTableEntry.w AirCountdown_DisplayNumber
		offsetTableEntry.w AirCountdown_Delete
; ---------------------------------------------------------------------------

AirCountdown_Init:
		addq.b	#2,routine(a0)
		move.l	#Map_Bubbler,mappings(a0)
		move.w	#$570,art_tile(a0)
		move.b	#$84,render_flags(a0)
		move.b	#32/2,width_pixels(a0)
		move.w	#$80,priority(a0)
		move.b	subtype(a0),d0
		bpl.s	loc_181CC
		addq.b	#8,routine(a0)
		andi.w	#$7F,d0
		move.b	d0,$37(a0)
		bra.w	AirCountdown_Countdown
; ---------------------------------------------------------------------------

loc_181CC:
		move.b	d0,anim(a0)
		move.w	x_pos(a0),$34(a0)
		move.w	#-$100,y_vel(a0)

AirCountdown_Animate:
		lea	Ani_Shields(pc),a1
		jsr	(Animate_Sprite).w

AirCountdown_ChkWater:
		move.w	(Water_level).w,d0
		cmp.w	y_pos(a0),d0
		blo.s		loc_1820E
		move.b	#6,routine(a0)
		addq.b	#7,anim(a0)
		cmpi.b	#$D,anim(a0)
		beq.s	AirCountdown_Display
		bcs.s	AirCountdown_Display
		move.b	#$D,anim(a0)
		bra.s	AirCountdown_Display
; ---------------------------------------------------------------------------

loc_1820E:
		tst.b	(WindTunnel_flag).w
		beq.s	loc_18218
		addq.w	#4,$34(a0)

loc_18218:
		move.b	angle(a0),d0
		addq.b	#1,angle(a0)
		andi.w	#$7F,d0
		lea	AirCountdown_WobbleData(pc),a1
		move.b	(a1,d0.w),d0
		ext.w	d0
		add.w	$34(a0),d0
		move.w	d0,x_pos(a0)
		bsr.w	AirCountdown_ShowNumber
		jsr	(MoveSprite2).w
		tst.b	render_flags(a0)
		bpl.s	loc_1824E
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

loc_1824E:
		jmp	(Delete_Current_Sprite).w
; ---------------------------------------------------------------------------
; AirCountdown_Display and AirCountdown_DisplayNumber were split in this
; game, unlike Sonic 2, to fix a bug where the countdown numbers corrupted
; if they reached the surface of the water.
; (The start of ARZ Act 1 is a good place to see this).

AirCountdown_Display:
		bsr.s	AirCountdown_ShowNumber
		lea	Ani_Shields(pc),a1
		jsr	(Animate_Sprite).w
		bsr.w	AirCountdown_Load_Art
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

AirCountdown_Delete:
		jmp	(Delete_Current_Sprite).w
; ---------------------------------------------------------------------------

AirCountdown_AirLeft:
		lea	(Player_1).w,a2
		cmpi.b	#12,air_left(a2)
		bhi.s	loc_182AC
		subq.w	#1,$3C(a0)
		bne.s	loc_18290
		move.b	#$E,routine(a0)
		addq.b	#7,anim(a0)
		bra.s	AirCountdown_Display
; ---------------------------------------------------------------------------

loc_18290:
		lea	Ani_Shields(pc),a1
		jsr	(Animate_Sprite).w
		bsr.w	AirCountdown_Load_Art
		tst.b	render_flags(a0)
		bpl.s	loc_182AC
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

loc_182AC:
		jmp	(Delete_Current_Sprite).w
; ---------------------------------------------------------------------------

AirCountdown_DisplayNumber:
		lea	(Player_1).w,a2
		cmpi.b	#12,air_left(a2)
		bhi.s	AirCountdown_Delete
		bsr.s	AirCountdown_ShowNumber
		lea	Ani_Shields(pc),a1
		jsr	(Animate_Sprite).w
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

AirCountdown_ShowNumber:
		tst.w	$3C(a0)
		beq.s	locret_1831C
		subq.w	#1,$3C(a0)
		bne.s	locret_1831C
		cmpi.b	#7,anim(a0)
		bhs.s	locret_1831C
		move.w	#$F,$3C(a0)
		clr.w	y_vel(a0)
		move.b	#$80,render_flags(a0)
		move.w	x_pos(a0),d0
		sub.w	(Camera_X_pos).w,d0
		addi.w	#$80,d0
		move.w	d0,x_pos(a0)
		move.w	y_pos(a0),d0
		sub.w	(Camera_Y_pos).w,d0
		addi.w	#$80,d0
		move.w	d0,y_pos(a0)
		move.b	#$C,routine(a0)

locret_1831C:
		rts
; End of function AirCountdown_ShowNumber
; ---------------------------------------------------------------------------

AirCountdown_WobbleData:
		dc.b  0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2
		dc.b  2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
		dc.b  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2
		dc.b  2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0
		dc.b  0,-1,-1,-1,-1,-1,-2,-2,-2,-2,-2,-3,-3,-3,-3,-3
		dc.b -3,-3,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4
		dc.b -4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-3
		dc.b -3,-3,-3,-3,-3,-3,-2,-2,-2,-2,-2,-1,-1,-1,-1,-1

; =============== S U B R O U T I N E =======================================

AirCountdown_Load_Art:
		moveq	#0,d1
		move.b	mapping_frame(a0),d1
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
		lsl.w	#5,d1
		addi.l	#ArtUnc_AirCountDown>>1,d1
		move.w	#tiles_to_bytes(ArtTile_DashDust),d2
		move.w	#$C0/2,d3
		jsr	(Add_To_DMA_Queue).w

locret_18464:
		rts
; End of function AirCountdown_Load_Art
; ---------------------------------------------------------------------------

AirCountdown_Countdown:
		lea	(Player_1).w,a2
		tst.w	$30(a0)
		bne.w	loc_1857C
		cmpi.b	#id_SonicDeath,routine(a2)
		bhs.s	locret_18464
		btst	#Status_BublShield,status_secondary(a2)
		bne.s	locret_18464
		btst	#Status_Underwater,status(a2)
		beq.s	locret_18464
		subq.w	#1,$3C(a0)
		bpl.w	loc_18594
		move.w	#$3B,$3C(a0)
		move.w	#1,$3A(a0)
		jsr	(Random_Number).w
		andi.w	#1,d0
		move.b	d0,$38(a0)
		moveq	#0,d0
		move.b	air_left(a2),d0
		cmpi.w	#25,d0
		beq.s	loc_184FC
		cmpi.w	#20,d0
		beq.s	loc_184FC
		cmpi.w	#15,d0
		beq.s	loc_184FC
		cmpi.w	#12,d0
		bhi.s	loc_1850A
		bne.s	loc_184E8
		music	bgm_Drowning,0,0,0	; Drowning music

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
		subq.b	#1,air_left(a2)
		bcc.w	loc_18592
		move.b	#-$7F,object_control(a2)
		sfx	sfx_Drown,0,0,0
		move.b	#$A,$38(a0)
		move.w	#1,$3A(a0)
		move.w	#$78,$30(a0)
		movea.l	a2,a1
		bsr.w	Player_ResetAirTimer
		move.l	a0,-(sp)
		movea.l	a2,a0
		bsr.w	Sonic_ResetOnFloor
		move.b	#id_Drown,anim(a0)
		bset	#Status_InAir,status(a0)
		bset	#7,art_tile(a0)
		clr.l	x_vel(a0)
		clr.w	ground_vel(a0)
		move.b	#id_SonicDrown,routine(a0)
		movea.l	(sp)+,a0
		st	(Deform_lock).w
		rts
; ---------------------------------------------------------------------------

loc_1857C:
		move.b	#id_Drown,anim(a2)
		subq.w	#1,$30(a0)
		bne.s	loc_18590
		move.b	#6,routine(a2)

locret_1858E:
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
		beq.s	locret_1858E
		subq.w	#1,$3E(a0)
		bpl.s	locret_1858E

loc_185A4:
		jsr	(Random_Number).w
		andi.w	#$F,d0
		addq.w	#8,d0
		move.w	d0,$3E(a0)
		jsr	(Create_New_Sprite).w
		bne.s	locret_1858E
		move.l	address(a0),address(a1)
		move.w	x_pos(a2),x_pos(a1)
		moveq	#6,d0
		btst	#Status_Facing,status(a2)
		beq.s	+
		neg.w	d0
		move.b	#$40,$26(a1)
+		add.w	d0,x_pos(a1)
		move.w	y_pos(a2),y_pos(a1)
		move.b	#6,$2C(a1)
		tst.w	$30(a0)
		beq.s	loc_1862A
		andi.w	#7,$3E(a0)
		move.w	y_pos(a2),d0
		subi.w	#$C,d0
		move.w	d0,y_pos(a1)
		jsr	(Random_Number).w
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
		move.b	air_left(a2),d2
		cmpi.b	#12,d2
		bhs.s	loc_18676
		lsr.w	#1,d2
		jsr	(Random_Number).w
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
		move.b	d2,subtype(a1)
		move.w	#$1C,$3C(a1)

loc_18676:
		subq.b	#1,$38(a0)
		bpl.s	+
		clr.w	$3A(a0)
+		rts

; =============== S U B R O U T I N E =======================================

Player_ResetAirTimer:
		cmpi.b	#12,air_left(a1)
		bhi.s	+++
		move.w	(Level_music).w,d0
		btst	#Status_Invincible,status_secondary(a1)
		beq.s	+
		moveq	#bgm_Invincible,d0	; If invincible, play invincibility music
+		tst.b	(Boss_flag).w
		beq.s	+
		moveq	#bgm_MidBoss,d0	; If boss, play boss music
+		move.b	d0,(Clone_Driver_RAM+SMPS_RAM.variables.queue.v_playsnd1).w
+		move.b	#30,air_left(a1)
		rts
; End of function Player_ResetAirTimer
; ---------------------------------------------------------------------------

		include "Objects/Count Down/Object Data/Anim - Shields.asm"