; ----------------------------------------------------------------------------
; Small bubbles from Sonic's face while underwater
; ----------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_AirCountdown:

		; init
		movem.l	ObjDat_AirCountdown(pc),d0-d3					; copy data to d0-d3
		movem.l	d0-d3,address(a0)						; set data from d0-d3 to current object
		move.b	#1,objoff_37(a0)

.countdown
		lea	(Player_1).w,a2							; a2=character
		tst.w	objoff_30(a0)
		bne.w	loc_1857C
		cmpi.b	#PlayerID_Death,routine(a2)					; has player just died?
		bhs.w	locret_1857A							; if yes, branch
		btst	#status_secondary.bubble_shield,status_secondary(a2)
		bne.w	locret_1857A
		btst	#status.player.underwater,status(a2)
		beq.w	locret_1857A

		; wait
		subq.w	#1,objoff_3C(a0)
		bpl.w	loc_18594
		move.w	#60-1,objoff_3C(a0)

		move.w	#1,objoff_3A(a0)
		jsr	(Random_Number).w
		andi.w	#1,d0
		move.b	d0,objoff_38(a0)
		moveq	#0,d0
		move.b	air_left(a2),d0							; check air remaining
		cmpi.w	#25,d0
		beq.s	AirCountdown_WarnSound						; play ding sound if air is 25
		cmpi.w	#20,d0
		beq.s	AirCountdown_WarnSound						; play ding sound if air is 20
		cmpi.w	#15,d0
		beq.s	AirCountdown_WarnSound						; play ding sound if air is 15
		cmpi.w	#12,d0
		bhi.s	AirCountdown_ReduceAir
		bne.s	loc_184E8
		music	mus_Drowning							; play drowning music

loc_184E8:
		subq.b	#1,objoff_36(a0)
		bpl.s	AirCountdown_ReduceAir
		move.b	objoff_37(a0),objoff_36(a0)
		bset	#7,objoff_3A(a0)
		bra.s	AirCountdown_ReduceAir
; ---------------------------------------------------------------------------

AirCountdown_WarnSound:
		sfx	sfx_AirDing							; play air ding sound

AirCountdown_ReduceAir:
		subq.b	#1,air_left(a2)
		bhs.w	AirCountdown_MakeItem
		move.b	#$81,object_control(a2)
		sfx	sfx_Drown							; play drown sound
		move.b	#10,objoff_38(a0)
		move.w	#1,objoff_3A(a0)
		move.w	#2*60,objoff_30(a0)
		movea.w	a2,a1
		bsr.w	Player_ResetAirTimer
		move.w	a0,-(sp)
		movea.w	a2,a0
		jsr	(Sonic_TouchFloor).l
		movea.w	(sp)+,a0

		; drown character
		bset	#status.player.in_air,status(a2)
		clr.l	x_vel(a2)
		clr.w	ground_vel(a2)
		move.b	#AniIDSonAni_Drown,anim(a2)
		move.b	#PlayerID_Drown,routine(a2)
		cmpa.w	#Player_1,a2
		bne.s	.notp1
		move.l	priority(a2),(Debug_saved_priority).w				; save priority and art_tile
		clr.w	priority(a2)
		st	(Deform_lock).w

.notp1
		bset	#high_priority_bit,art_tile(a2)					; high priority

locret_1857A:
		rts
; ---------------------------------------------------------------------------

loc_1857C:
		move.b	#AniIDSonAni_Drown,anim(a2)
		subq.w	#1,objoff_30(a0)
		bne.s	loc_18594
		move.b	#PlayerID_Death,routine(a2)

locret_1858E:
		rts
; ---------------------------------------------------------------------------

loc_18594:
		tst.w	objoff_3A(a0)
		beq.s	locret_1858E
		subq.w	#1,objoff_3E(a0)
		bpl.s	locret_1858E

AirCountdown_MakeItem:
		jsr	(Random_Number).w
		andi.w	#$F,d0
		addq.w	#8,d0
		move.w	d0,objoff_3E(a0)

		; create bubbles
		jsr	(Create_New_Sprite).w
		bne.s	locret_1858E
		move.l	#Obj_AirCountdown_Bubbles,address(a1)
		move.l	mappings(a0),mappings(a1)
		move.w	art_tile(a0),art_tile(a1)
		move.w	priority(a0),priority(a1)
		move.w	height_pixels(a0),height_pixels(a1)				; set height and width
		move.w	x_pos(a2),x_pos(a1)						; copy player X position to object
		moveq	#6,d0
		btst	#status.player.x_flip,status(a2)
		beq.s	.notflipx
		neg.w	d0
		move.b	#$40,angle(a1)

.notflipx
		add.w	d0,x_pos(a1)
		move.w	y_pos(a2),y_pos(a1)
		move.b	#6,subtype(a1)
		tst.w	objoff_30(a0)
		beq.s	loc_1862A
		andi.w	#7,objoff_3E(a0)
		subi.w	#12,y_pos(a1)
		jsr	(Random_Number).w
		move.b	d0,angle(a1)
		moveq	#3,d0
		and.w	(Level_frame_counter).w,d0
		bne.s	loc_18676
		move.b	#$E,subtype(a1)
		bra.s	loc_18676

; ---------------------------------------------------------------------------
; has something to do with making bubbles come out less regularly
; when Sonic is almost drowning
; ---------------------------------------------------------------------------

loc_1862A:
		btst	#7,objoff_3A(a0)
		beq.s	loc_18676
		moveq	#0,d2
		move.b	air_left(a2),d2
		cmpi.b	#12,d2
		bhs.s	loc_18676
		lsr.w	d2
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
		bpl.s	.return
		clr.w	objoff_3A(a0)

.return
		rts

; ----------------------------------------------------------------------------
; Small bubbles from Sonic's face while underwater (Bubbles)
; ----------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_AirCountdown_Bubbles:
		move.b	subtype(a0),anim(a0)

		; use screen coordinates
		move.b	#( \
			setBit(render_flags.level) | \
			setBit(render_flags.on_screen) \
		),render_flags(a0)

		move.w	x_pos(a0),objoff_34(a0)
		move.w	#-$100,y_vel(a0)
		move.l	#.animate,address(a0)

.animate
		lea	Ani_AirCountdown(pc),a1
		jsr	(Animate_Sprite).w
		tst.b	routine(a0)
		beq.s	.chkwater
		clr.b	routine(a0)
		move.l	#.chkwater,address(a0)

.chkwater
		move.w	(Water_level).w,d0
		cmp.w	y_pos(a0),d0							; has bubble reached the water surface?
		blo.s	AirCountdown_Wobble						; if not, branch

		; pop the bubble
		move.l	#AirCountdown_Display,address(a0)
		addq.b	#7,anim(a0)
		cmpi.b	#$D,anim(a0)
		beq.s	AirCountdown_Display
		blo.s	AirCountdown_Display
		move.b	#$D,anim(a0)
		bra.s	AirCountdown_Display
; ---------------------------------------------------------------------------

AirCountdown_Wobble:
		tst.b	(WindTunnel_flag).w
		beq.s	loc_18218
		addq.w	#4,objoff_34(a0)

loc_18218:
		moveq	#$7F,d0
		and.b	angle(a0),d0
		addq.b	#1,angle(a0)
		lea	AirCountdown_WobbleData(pc),a1
		move.b	(a1,d0.w),d0
		ext.w	d0
		add.w	objoff_34(a0),d0
		move.w	d0,x_pos(a0)
		bsr.w	AirCountdown_ShowNumber
		jsr	(MoveSprite2).w
		tst.b	render_flags(a0)						; object visible on the screen?
		bpl.s	AirCountdown_Delete						; if not, branch
		jmp	(Draw_Sprite).w

; ---------------------------------------------------------------------------
; AirCountdown_Display and AirCountdown_DisplayNumber were split in this
; game, unlike Sonic 2, to fix a bug where the countdown numbers corrupted
; if they reached the surface of the water.
; (The start of ARZ Act 1 is a good place to see this).
; ---------------------------------------------------------------------------

AirCountdown_Display:
		lea	(Player_1).w,a2							; a2=character
		cmpi.b	#12,air_left(a2)						; check air remaining
		bhi.s	AirCountdown_Delete						; if higher than 12, branch
		bsr.s	AirCountdown_ShowNumber
		lea	Ani_AirCountdown(pc),a1
		jsr	(Animate_Sprite).w
		tst.b	routine(a0)
		bne.s	AirCountdown_Delete
		bsr.w	AirCountdown_Load_Art
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

AirCountdown_Delete:
		jmp	(Delete_Current_Sprite).w

; =============== S U B R O U T I N E =======================================

AirCountdown_AirLeft:
		lea	(Player_1).w,a2							; a2=character
		cmpi.b	#12,air_left(a2)						; check air remaining
		bhi.s	AirCountdown_Delete						; if higher than 12, branch
		subq.w	#1,objoff_3C(a0)
		bne.s	AirCountdown_Display2
		move.l	#AirCountdown_DisplayNumber,address(a0)
		addq.b	#7,anim(a0)
		bra.s	AirCountdown_Display
; ---------------------------------------------------------------------------

AirCountdown_Display2:
		lea	Ani_AirCountdown(pc),a1
		jsr	(Animate_Sprite).w
		tst.b	routine(a0)
		bne.s	AirCountdown_Delete
		bsr.s	AirCountdown_Load_Art
		tst.b	render_flags(a0)						; object visible on the screen?
		bpl.s	AirCountdown_Delete						; if not, branch
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

AirCountdown_DisplayNumber:
		lea	(Player_1).w,a2							; a2=character
		cmpi.b	#12,air_left(a2)						; check air remaining
		bhi.s	AirCountdown_Delete						; if higher than 12, branch
		bsr.s	AirCountdown_ShowNumber
		lea	Ani_AirCountdown(pc),a1
		jsr	(Animate_Sprite).w
		tst.b	routine(a0)
		bne.s	AirCountdown_Delete
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

AirCountdown_ShowNumber:
		tst.w	objoff_3C(a0)
		beq.s	.return
		subq.w	#1,objoff_3C(a0)
		bne.s	.return
		cmpi.b	#7,anim(a0)
		bhs.s	.return
		move.w	#15,objoff_3C(a0)
		clr.w	y_vel(a0)
		move.w	#$80,d1
		move.b	d1,render_flags(a0)
		move.w	x_pos(a0),d0
		sub.w	(Camera_X_pos).w,d0
		add.w	d1,d0
		move.w	d0,x_pos(a0)
		move.w	y_pos(a0),d0
		sub.w	(Camera_Y_pos).w,d0
		add.w	d1,d0
		move.w	d0,y_pos(a0)
		move.l	#AirCountdown_AirLeft,address(a0)

.return
		rts

; =============== S U B R O U T I N E =======================================

AirCountdown_Load_Art:
		moveq	#0,d1
		move.b	mapping_frame(a0),d1
		cmpi.b	#9,d1
		blo.s	AirCountdown_ShowNumber.return
		cmpi.b	#$13,d1
		bhs.s	AirCountdown_ShowNumber.return
		cmp.b	objoff_32(a0),d1
		beq.s	AirCountdown_ShowNumber.return
		move.b	d1,objoff_32(a0)
		subi.w	#9,d1
		move.w	d1,d0								; multiply by $C0/2
		add.w	d1,d1
		add.w	d0,d1
		lsl.w	#5,d1
		addi.l	#dmaSource(ArtUnc_AirCountDown),d1
		move.w	#tiles_to_bytes(ArtTile_DashDust),d2				; 1P

		; size of art (in words) ; we only need one frame
		moveq	#tiles_to_bytes( \
		dmaLength(6) \
		),d3

		jmp	(Add_To_DMA_Queue).w

; ----------------------------------------------------------------------------
; Reset player air timer
; ----------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Player_ResetAirTimer:
		cmpi.b	#12,air_left(a1)
		bhi.s	.end								; branch if countdown hasn't started yet
		cmpa.w	#Player_1,a1
		bne.s	.end								; branch if it isn't player 1
		move.w	(Current_music).w,d0						; prepare to play current level's music
		tst.b	(Boss_flag).w
		bne.s	.notinvincible							; branch if in a boss fight
		btst	#status_secondary.invincible,status_secondary(a1)
		beq.s	.notinvincible							; branch if Sonic is not invincible
		moveq	#signextendB(mus_Invincible),d0					; prepare to play invincibility music

.notinvincible
		jsr	(Play_Music).w

.end
		move.b	#30,air_left(a1)						; reset air to full
		rts

; ----------------------------------------------------------------------------
; Wobble data
; ----------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

AirCountdown_WobbleData:	binclude "Objects/Main/Count Down/Object Data/Wobble Data.bin"
	even

; =============== S U B R O U T I N E =======================================

; mapping
ObjDat_AirCountdown:		subObjMainData \
				Obj_AirCountdown.countdown, \
					setBit(render_flags.level) | \
					setBit(render_flags.on_screen), \
				0, 32, 32, 1, $348, 0, 0, Map_Bubbler
; ---------------------------------------------------------------------------

		include "Objects/Main/Count Down/Object Data/Anim - Air Countdown.asm"
