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
		offsetTableEntry.w AirCountdown_Init				; 0
		offsetTableEntry.w AirCountdown_Animate			; 2
		offsetTableEntry.w AirCountdown_ChkWater			; 4
		offsetTableEntry.w AirCountdown_Display			; 6
		offsetTableEntry.w AirCountdown_Delete				; 8
		offsetTableEntry.w AirCountdown_Countdown			; A
		offsetTableEntry.w AirCountdown_AirLeft			; C
		offsetTableEntry.w AirCountdown_DisplayNumber		; E
		offsetTableEntry.w AirCountdown_Delete				; 10
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
		move.b	d0,objoff_37(a0)
		bra.w	AirCountdown_Countdown
; ---------------------------------------------------------------------------

loc_181CC:
		move.b	d0,anim(a0)
		move.w	x_pos(a0),objoff_34(a0)
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
		addq.w	#4,objoff_34(a0)

loc_18218:
		move.b	angle(a0),d0
		addq.b	#1,angle(a0)
		andi.w	#$7F,d0
		lea	AirCountdown_WobbleData(pc),a1
		move.b	(a1,d0.w),d0
		ext.w	d0
		add.w	objoff_34(a0),d0
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
		subq.w	#1,objoff_3C(a0)
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
		tst.w	objoff_3C(a0)
		beq.s	locret_1831C
		subq.w	#1,objoff_3C(a0)
		bne.s	locret_1831C
		cmpi.b	#7,anim(a0)
		bhs.s	locret_1831C
		move.w	#$F,objoff_3C(a0)
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
		cmp.b	objoff_32(a0),d1
		beq.s	locret_18464
		move.b	d1,objoff_32(a0)
		subi.w	#9,d1
		move.w	d1,d0
		add.w	d1,d1
		add.w	d0,d1
		lsl.w	#5,d1
		addi.l	#ArtUnc_AirCountDown>>1,d1
		move.w	#tiles_to_bytes(ArtTile_DashDust),d2
		move.w	#$C0/2,d3
		jmp	(Add_To_DMA_Queue).w
; ---------------------------------------------------------------------------

locret_18464:
		rts
; ---------------------------------------------------------------------------

AirCountdown_Countdown:
		lea	(Player_1).w,a2
		tst.w	objoff_30(a0)
		bne.w	loc_1857C
		cmpi.b	#id_SonicDeath,routine(a2)
		bhs.s	locret_18464
		btst	#Status_BublShield,status_secondary(a2)
		bne.s	locret_18464
		btst	#Status_Underwater,status(a2)
		beq.s	locret_18464
		subq.w	#1,objoff_3C(a0)
		bpl.w	loc_18594
		move.w	#$3B,objoff_3C(a0)
		move.w	#1,objoff_3A(a0)
		jsr	(Random_Number).w
		andi.w	#1,d0
		move.b	d0,objoff_38(a0)
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
		music	mus_Drowning	; Drowning music

loc_184E8:
		subq.b	#1,objoff_36(a0)
		bpl.s	loc_1850A
		move.b	objoff_37(a0),objoff_36(a0)
		bset	#7,objoff_3A(a0)
		bra.s	loc_1850A
; ---------------------------------------------------------------------------

loc_184FC:
		sfx	sfx_AirDing

loc_1850A:
		subq.b	#1,air_left(a2)
		bcc.w	loc_18592
		move.b	#$81,object_control(a2)
		sfx	sfx_Drown
		move.b	#10,objoff_38(a0)
		move.w	#1,objoff_3A(a0)
		move.w	#120,objoff_30(a0)
		movea.w	a2,a1
		bsr.w	Player_ResetAirTimer
		move.w	a0,-(sp)
		movea.w	a2,a0
		jsr	Sonic_ResetOnFloor(pc)
		move.b	#id_Drown,anim(a0)
		bset	#Status_InAir,status(a0)
		bset	#7,art_tile(a0)
		clr.l	x_vel(a0)
		clr.w	ground_vel(a0)
		move.b	#id_SonicDrown,routine(a0)
		movea.w	(sp)+,a0
		st	(Deform_lock).w
		rts
; ---------------------------------------------------------------------------

loc_1857C:
		move.b	#id_Drown,anim(a2)
		subq.w	#1,objoff_30(a0)
		bne.s	loc_18590
		move.b	#id_SonicDeath,routine(a2)

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
		tst.w	objoff_3A(a0)
		beq.s	locret_1858E
		subq.w	#1,objoff_3E(a0)
		bpl.s	locret_1858E

loc_185A4:
		jsr	(Random_Number).w
		andi.w	#$F,d0
		addq.w	#8,d0
		move.w	d0,objoff_3E(a0)
		jsr	(Create_New_Sprite).w
		bne.s	locret_1858E
		move.l	address(a0),address(a1)
		move.w	x_pos(a2),x_pos(a1)
		moveq	#6,d0
		btst	#Status_Facing,status(a2)
		beq.s	+
		neg.w	d0
		move.b	#$40,angle(a1)
+		add.w	d0,x_pos(a1)
		move.w	y_pos(a2),y_pos(a1)
		move.b	#6,subtype(a1)
		tst.w	objoff_30(a0)
		beq.s	loc_1862A
		andi.w	#7,objoff_3E(a0)
		move.w	y_pos(a2),d0
		subi.w	#$C,d0
		move.w	d0,y_pos(a1)
		jsr	(Random_Number).w
		move.b	d0,angle(a1)
		move.w	(Level_frame_counter).w,d0
		andi.b	#3,d0
		bne.s	loc_18676
		move.b	#$E,subtype(a1)
		bra.s	loc_18676
; ---------------------------------------------------------------------------

loc_1862A:
		btst	#7,objoff_3A(a0)
		beq.s	loc_18676
		moveq	#0,d2
		move.b	air_left(a2),d2
		cmpi.b	#12,d2
		bhs.s	loc_18676
		lsr.w	#1,d2
		jsr	(Random_Number).w
		andi.w	#3,d0
		bne.s	loc_1865E
		bset	#6,objoff_3A(a0)
		bne.s	loc_18676
		move.b	d2,subtype(a1)
		move.w	#$1C,objoff_3C(a1)

loc_1865E:
		tst.b	objoff_38(a0)
		bne.s	loc_18676
		bset	#6,objoff_3A(a0)
		bne.s	loc_18676
		move.b	d2,subtype(a1)
		move.w	#$1C,objoff_3C(a1)

loc_18676:
		subq.b	#1,objoff_38(a0)
		bpl.s	+
		clr.w	objoff_3A(a0)
+		rts
; ----------------------------------------------------------------------------
; Reset player air timer
; ----------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Player_ResetAirTimer:
		cmpi.b	#12,air_left(a1)
		bhi.s	.end								; branch if countdown hasn't started yet
		move.w	(Current_music).w,d0				; prepare to play current level's music
		tst.b	(Boss_flag).w
		bne.s	.notinvincible						; branch if in a boss fight
		btst	#Status_Invincible,status_secondary(a1)
		beq.s	.notinvincible						; branch if Sonic is not invincible
		moveq	#signextendB(mus_Invincible),d0	; prepare to play invincibility music

.notinvincible
		jsr	(SMPS_QueueSound1).w

.end
		move.b	#30,air_left(a1)					; reset air to full
		rts
; ---------------------------------------------------------------------------

		include "Objects/Count Down/Object Data/Anim - Shields.asm"
