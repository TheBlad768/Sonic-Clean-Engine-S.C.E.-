; ----------------------------------------------------------------------------
; Small bubbles from Sonic's face while underwater
; ----------------------------------------------------------------------------

; dynamic object variables

	dsset animations								; pretend we're in the RAM

aircountdown.drown_timer		ds.w 1						; current time remaining (2 bytes)
aircountdown.warn_timer			ds.w 1						; current time remaining (2 bytes)
aircountdown.spawn_delay		ds.w 1						; time delay (2 bytes)
aircountdown.timer			ds.b 1						; current time remaining (1 byte)
aircountdown.bubble_count		ds.b 1						; (1 byte)
aircountdown.state_flags		ds.b 1						; (1 byte)

	dsreset										; stop pretending and reset the program counter

; =============== S U B R O U T I N E =======================================

Obj_AirCountdown:

		; init
		movem.l	ObjDat_AirCountdown(pc),d0-d3					; copy data to d0-d3
		movem.l	d0-d3,code_addr(a0)						; set data from d0-d3 to current object

.countdown
		lea	(Player_1).w,a2							; a2=character

		; if the player has drowned, and the object is waiting until the
		; world should pause, then go deal with that
		tst.w	aircountdown.drown_timer(a0)					; is timer over?
		bne.w	.drowning							; if not, branch

		; check player
		cmpi.b	#PlayerID_Death,routine(a2)					; has player just died?
		bhs.w	.return								; if yes, branch
		btst	#status_secondary.bubble_shield,status_secondary(a2)		; does Sonic have a Bubble Shield?
		bne.w	.return								; if yes, branch
		btst	#status.player.underwater,status(a2)
		beq.w	.return

		; wait a second
		subq.w	#1,aircountdown.warn_timer(a0)					; subtract 1 from time delay
		bpl.w	.checkcreate							; if time still remains, branch
		move.w	#(1*60)-1,aircountdown.warn_timer(a0)				; reset time delay
		bset	#0,aircountdown.state_flags(a0)

		; randomly spawn either one or two bubbles
		jsr	(Random_Number).w
		andi.w	#1,d0
		move.b	d0,aircountdown.bubble_count(a0)

		; check air left
		move.b	air_left(a2),d0							; check air remaining
		cmpi.b	#25,d0
		beq.s	.warnsound							; play ding sound if air is 25
		cmpi.b	#20,d0
		beq.s	.warnsound							; play ding sound if air is 20
		cmpi.b	#15,d0
		beq.s	.warnsound							; play ding sound if air is 15
		cmpi.b	#12,d0
		bhi.s	.reduceair							; if higher than 12, branch
		bne.s	.checktimer							; play drowning theme when there are 12 seconds left

		; play countdown music
		music	mus_Drowning							; play drowning music

.checktimer

		; wait
		subq.b	#1,aircountdown.timer(a0)					; decrement timer
		bpl.s	.reduceair							; if time remains, branch
		addq.b	#1+1,aircountdown.timer(a0)					; reset timer to 1 frames

		; next
		bset	#7,aircountdown.state_flags(a0)					; set the flag to create a number
		bra.s	.reduceair
; ---------------------------------------------------------------------------

.warnsound

		; play the "ding-ding" warning sound
		sfx	sfx_AirDing							; play air ding sound

.reduceair

		; check air left
		subq.b	#1,air_left(a2)							; subtract 1 from air remaining
		bhs.w	.create								; if air is above 0, branch

		; drown the player
		move.b	#$81,object_control(a2)						; lock controls
		sfx	sfx_Drown							; play drowning sound
		move.b	#10,aircountdown.bubble_count(a0)				; spawn ten bubbles
		bset	#0,aircountdown.state_flags(a0)
		move.w	#2*60,aircountdown.drown_timer(a0)				; two seconds until the world pauses
		movea.w	a2,a1								; a1=character
		bsr.w	Player_ResetAirTimer
		move.w	a0,-(sp)
		movea.w	a2,a0								; a0=character
		jsr	(Sonic_TouchFloor).l
		movea.w	(sp)+,a0

		; set
		bset	#status.player.in_air,status(a2)
		clr.l	x_vel(a2)
		clr.w	ground_vel(a2)
		move.b	#AniIDSonAni_Drown,anim(a2)					; use Sonic's drowning animation
		move.b	#PlayerID_Drown,routine(a2)

		; check p1
		cmpa.w	#Player_1,a2
		bne.s	.notp1
		move.l	priority(a2),(Debug_saved_priority).w				; save priority and art_tile
		clr.w	priority(a2)
		st	(Deform_lock).w

.notp1
		bset	#high_priority_bit,art_tile(a2)					; high priority

.return
		rts
; ---------------------------------------------------------------------------

.drowning
		move.b	#AniIDSonAni_Drown,anim(a2)					; use Sonic's drowning animation

		; check time
		subq.w	#1,aircountdown.drown_timer(a0)					; subtract 1 from time delay
		bne.s	.checkcreate							; if time still remains, branch
		move.b	#PlayerID_Death,routine(a2)					; signal that the player is dead

.return2
		rts
; ---------------------------------------------------------------------------

.checkcreate
		tst.b	aircountdown.state_flags(a0)
		beq.s	.return2
		subq.w	#1,aircountdown.spawn_delay(a0)					; subtract 1 from time delay
		bpl.s	.return2							; if time still remains, branch

.create

		; set wait time
		jsr	(Random_Number).w
		andi.w	#$F,d0
		addq.w	#8,d0
		move.w	d0,aircountdown.spawn_delay(a0)

		; create bubbles
		jsr	(Create_New_Object).w
		bne.s	.return2
		move.l	#Obj_AirCountdown_Bubbles,code_addr(a1)
		move.l	mappings(a0),mappings(a1)
		move.w	art_tile(a0),art_tile(a1)
		move.l	height_pixels(a0),height_pixels(a1)				; set height, width and priority

		; set xypos
		moveq	#6,d0
		btst	#status.player.x_flip,status(a2)
		beq.s	.notflipx
		neg.w	d0
		move.b	#$40,angle(a1)

.notflipx
		add.w	x_pos(a2),d0
		move.w	d0,x_pos(a1)						; copy player X position to object
		move.w	y_pos(a2),y_pos(a1)
		move.b	#6,subtype(a1)

		; check
		tst.w	aircountdown.drown_timer(a0)
		beq.s	.check
		andi.w	#7,aircountdown.spawn_delay(a0)
		subi.w	#12,y_pos(a1)
		jsr	(Random_Number).w
		move.b	d0,angle(a1)
		moveq	#3,d0
		and.w	(Level_frame_counter).w,d0
		bne.s	.checkcount
		move.b	#$E,subtype(a1)
		bra.s	.checkcount

; ---------------------------------------------------------------------------
; has something to do with making bubbles come out less regularly
; when Sonic is almost drowning
; ---------------------------------------------------------------------------

.check
		; the player has not drowned

		; if it's not time to create a number bubble, then skip this
		btst	#7,aircountdown.state_flags(a0)
		beq.s	.checkcount
		moveq	#0,d2
		move.b	air_left(a2),d2							; check air remaining
		cmpi.b	#12,d2
		bhs.s	.checkcount							; if higher than 12, branch

		; this player is about to drown
		lsr.w	d2								; division by 2
		jsr	(Random_Number).w
		andi.w	#3,d0
		bne.s	.check2
		bset	#6,aircountdown.state_flags(a0)					; this flag prevents more than one number bubble from spawning at once
		bne.s	.checkcount
		move.b	d2,subtype(a1)
		move.w	#28,aircountdown_bubbles.number_timer(a1)			; make this bubble turn into a number later

.check2
		tst.b	aircountdown.bubble_count(a0)
		bne.s	.checkcount
		bset	#6,aircountdown.state_flags(a0)					; this flag prevents more than one number bubble from spawning at once
		bne.s	.checkcount
		move.b	d2,subtype(a1)
		move.w	#28,aircountdown_bubbles.number_timer(a1)			; make this bubble turn into a number later

.checkcount
		subq.b	#1,aircountdown.bubble_count(a0)				; subtract 1 from time delay
		bpl.s	.return3							; if time still remains, branch
		clr.b	aircountdown.state_flags(a0)					; don't spawn any more bubbles

.return3
		rts

; ----------------------------------------------------------------------------
; Small bubbles from Sonic's face while underwater (Bubbles)
; ----------------------------------------------------------------------------

; dynamic object variables

	dsset animations								; pretend we're in the RAM

aircountdown_bubbles.origX		ds.w 1						; original x-axis position (2 bytes)
aircountdown_bubbles.number_timer	ds.w 1						; current time remaining (2 bytes)
aircountdown_bubbles.prev_frame		ds.b 1						; (1 byte)

	dsreset										; stop pretending and reset the program counter

; =============== S U B R O U T I N E =======================================

Obj_AirCountdown_Bubbles:
		move.b	subtype(a0),anim(a0)

		; use screen coordinates
		move.b	#( \
			setBit(render_flags.level) | \
			setBit(render_flags.on_screen) \
		),render_flags(a0)

		move.w	x_pos(a0),aircountdown_bubbles.origX(a0)
		move.w	#-$100,y_vel(a0)
		move.l	#.animate,code_addr(a0)

.animate
		lea	Ani_AirCountdown(pc),a1
		jsr	(Animate_SpriteNoSST).w
		tst.b	routine(a0)							; changed by Animate_Sprite
		beq.s	.chkwater
		clr.b	routine(a0)
		move.l	#.chkwater,code_addr(a0)

.chkwater

		; check water
		move.w	(Water_level).w,d0
		cmp.w	y_pos(a0),d0							; has bubble reached the water surface?
		blo.s	.wobble								; if not, branch

		; burst the bubble
		addq.b	#7,anim(a0)							; burst animation
		move.l	#.airleft,code_addr(a0)

		; check animation
		cmpi.b	#$D,anim(a0)
		beq.s	.airleft
		blo.s	.airleft
		move.b	#$D,anim(a0)
		bra.s	.airleft
; ---------------------------------------------------------------------------

.wobble

		; if in a wind-tunnel, then make the bubbles move to the right
		tst.b	(WindTunnel_flag).w
		beq.s	.notwindtunnel
		addq.w	#4,aircountdown_bubbles.origX(a0)

.notwindtunnel

		; wiggle the bubble left and right
		moveq	#$7F,d0
		and.b	angle(a0),d0
		addq.b	#1,angle(a0)							; next
		lea	AirCountdown_WobbleData(pc),a1
		move.b	(a1,d0.w),d0
		ext.w	d0
		add.w	aircountdown_bubbles.origX(a0),d0
		move.w	d0,x_pos(a0)

		; draw
		bsr.w	AirCountdown_ShowNumber
		jsr	(MoveSprite2).w
		tst.b	render_flags(a0)						; object visible on the screen?
		bpl.s	.delete								; if not, branch
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.airleft
		lea	(Player_1).w,a2							; a2=character
		cmpi.b	#12,air_left(a2)						; check air remaining
		bhi.s	.delete								; if higher than 12, branch
		bsr.s	AirCountdown_ShowNumber

		; draw
		lea	Ani_AirCountdown(pc),a1
		jsr	(Animate_SpriteNoSST).w
		tst.b	routine(a0)							; changed by Animate_Sprite
		bne.s	.delete
		bsr.w	AirCountdown_Load_Art
		tst.b	render_flags(a0)						; object visible on the screen?
		bpl.s	.delete								; if not, branch
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.delete
		jmp	(Delete_Current_Object).w
; ---------------------------------------------------------------------------

.airleft2
		lea	(Player_1).w,a2							; a2=character
		cmpi.b	#12,air_left(a2)						; check air remaining
		bhi.s	.delete								; if higher than 12, branch

		; check timer
		subq.w	#1,aircountdown_bubbles.number_timer(a0)
		bne.s	.draw
		move.l	#.airleft3,code_addr(a0)
		addq.b	#7,anim(a0)							; burst animation
		bra.s	.airleft
; ---------------------------------------------------------------------------

.draw
		lea	Ani_AirCountdown(pc),a1
		jsr	(Animate_SpriteNoSST).w
		tst.b	routine(a0)							; changed by Animate_Sprite
		bne.s	.delete
		bsr.s	AirCountdown_Load_Art
		tst.b	render_flags(a0)						; object visible on the screen?
		bpl.s	.delete								; if not, branch
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.airleft3
		lea	(Player_1).w,a2							; a2=character
		cmpi.b	#12,air_left(a2)						; check air remaining
		bhi.s	.delete								; if higher than 12, branch

		; draw
		bsr.s	AirCountdown_ShowNumber
		lea	Ani_AirCountdown(pc),a1
		jsr	(Animate_SpriteNoSST).w
		tst.b	routine(a0)							; changed by Animate_Sprite
		bne.s	.delete
		tst.b	render_flags(a0)						; object visible on the screen?
		bpl.s	.delete								; if not, branch
		jmp	(Draw_Sprite).w

; ----------------------------------------------------------------------------
; Show number
; ----------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

AirCountdown_ShowNumber:

		; check timer
		tst.w	aircountdown_bubbles.number_timer(a0)
		beq.s	.return
		subq.w	#1,aircountdown_bubbles.number_timer(a0)
		bne.s	.return

		; check anim
		cmpi.b	#7,anim(a0)
		bhs.s	.return

		; turn this bubble into a number
		move.w	#15,aircountdown_bubbles.number_timer(a0)
		clr.w	y_vel(a0)
		move.w	#$80,d1
		move.b	d1,render_flags(a0)						; render_flags.on_screen
		move.w	x_pos(a0),d0
		sub.w	(Camera_X_pos).w,d0
		add.w	d1,d0
		move.w	d0,x_pos(a0)
		move.w	y_pos(a0),d0
		sub.w	(Camera_Y_pos).w,d0
		add.w	d1,d0
		move.w	d0,y_pos(a0)
		move.l	#Obj_AirCountdown_Bubbles.airleft2,code_addr(a0)

.return
		rts

; ----------------------------------------------------------------------------
; Load number art
; ----------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

AirCountdown_Load_Art:
		moveq	#0,d1
		move.b	mapping_frame(a0),d1
		cmpi.b	#9,d1
		blo.s	AirCountdown_ShowNumber.return
		cmpi.b	#$13,d1
		bhs.s	AirCountdown_ShowNumber.return

		; check prev frame
		cmp.b	aircountdown_bubbles.prev_frame(a0),d1
		beq.s	AirCountdown_ShowNumber.return
		move.b	d1,aircountdown_bubbles.prev_frame(a0)
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

		; check air left
		cmpi.b	#12,air_left(a1)
		bhi.s	.reset								; branch if countdown hasn't started yet
		cmpa.w	#Player_1,a1
		bne.s	.reset								; branch if it isn't player 1
		move.w	(Current_music).w,d0						; prepare to play current level's music

		; check boss
		tst.b	(Boss_flag).w
		bne.s	.notinvincible							; branch if in a boss fight
		btst	#status_secondary.invincible,status_secondary(a1)
		beq.s	.notinvincible							; branch if Sonic is not invincible
		moveq	#signextendB(mus_Invincible),d0					; prepare to play invincibility music

.notinvincible
		jsr	(Play_Music).w							; play music

.reset
		move.b	#30,air_left(a1)						; reset air to full (30 seconds)
		rts

; ----------------------------------------------------------------------------
; Wobble data
; ----------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

		incfile.ba	AirCountdown_WobbleData, "Objects/Main/Count Down/Object Data/Wobble Data.bin"

; =============== S U B R O U T I N E =======================================

; init
ObjDat_AirCountdown:		subObjMainData \
				Obj_AirCountdown.countdown, \
					setBit(render_flags.level) | \
					setBit(render_flags.on_screen), \
				0, 32, 32, 1, $348, 0, FALSE, Map_Bubbler
; ---------------------------------------------------------------------------

		; mappings
		include "Objects/Main/Count Down/Object Data/Anim - Air Countdown.asm"
