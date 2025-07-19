; ---------------------------------------------------------------------------
; Monitor (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_Monitor:

		; init
		move.l	#Map_Monitor,mappings(a0)
		move.w	#make_art_tile(ArtTile_Monitors,0,0),art_tile(a0)
		ori.b	#setBit(render_flags.level),render_flags(a0)			; use screen coordinates
		move.l	#bytes_word_to_long(32/2,28/2,priority_3),height_pixels(a0)	; set height, width and priority

		; check broken
		move.w	respawn_addr(a0),d0						; get address in respawn table
		beq.s	.notbroken							; if it's zero, it isn't remembered
		movea.w	d0,a2								; load address into a2
		btst	#0,(a2)								; is this monitor broken?
		beq.s	.notbroken							; if not, branch

		; set broken
		move.b	#$B,mapping_frame(a0)						; use 'broken monitor' frame

		; draw
		lea	(Sprite_OnScreen_Test).w,a1
		move.l	a1,address(a0)
		jmp	(a1)
; ---------------------------------------------------------------------------

.notbroken
		move.w	#bytes_to_word(30/2,30/2),y_radius(a0)				; set y_radius and x_radius
		move.b	#6|collision_flags.npc.item,collision_flags(a0)
		move.b	subtype(a0),anim(a0)						; subtype determines what powerup is inside
		move.l	#.main,address(a0)

.main
		bsr.s	Obj_MonitorFall

		; solid
		moveq	#(28/2)+$B,d1							; monitor's width
		moveq	#32/2,d2
		move.w	d2,d3								; monitor's height
		addq.w	#1,d3
		move.w	x_pos(a0),d4

		; check p1
		lea	(Player_1).w,a1							; a1=character
		moveq	#p1_standing_bit,d6
		bsr.s	SolidObject_Monitor_SonicKnux

		; anim
		Add_SpriteToCollisionResponseList a1
		lea	Ani_Monitor(pc),a1
		jsr	(Animate_Sprite).w

.draw
		jmp	(Sprite_OnScreen_Test).w

; =============== S U B R O U T I N E =======================================

Obj_MonitorFall:
		move.b	routine_secondary(a0),d0
		beq.s	Obj_MonitorFallUpsideUp.return
		btst	#render_flags.y_flip,render_flags(a0)				; is monitor upside down?
		bne.s	Obj_MonitorFallUpsideDown					; if so, branch

Obj_MonitorFallUpsideUp:
		jsr	(MoveSprite).w
		tst.w	y_vel(a0)							; is monitor moving up?
		bmi.s	.return								; if so, return
		jsr	(ObjCheckFloorDist).w
		tst.w	d1								; is monitor in the ground?
		beq.s	.inground							; if so, branch
		bpl.s	.return								; if not, return

.inground
		add.w	d1,y_pos(a0)							; move monitor out of the ground
		clr.w	y_vel(a0)
		clr.b	routine_secondary(a0)						; stop monitor from falling

.return
		rts
; ---------------------------------------------------------------------------

Obj_MonitorFallUpsideDown:
		jsr	(MoveSprite_ReverseGravity).w
		tst.w	y_vel(a0)							; is monitor moving down?
		bmi.s	.return								; if so, return
		jsr	(ObjCheckCeilingDist).w
		tst.w	d1								; is monitor in the ground (ceiling)?
		beq.s	.inground							; if so, branch
		bpl.s	.return								; if not, return

.inground
		sub.w	d1,y_pos(a0)							; move monitor out of the ground
		clr.w	y_vel(a0)
		clr.b	routine_secondary(a0)						; stop monitor from falling

.return
		rts

; =============== S U B R O U T I N E =======================================

SolidObject_Monitor_SonicKnux:
		btst	d6,status(a0)							; is Sonic/Knux standing on the monitor?
		bne.s	Monitor_ChkOverEdge						; if so, branch
		cmpi.b	#AniIDSonAni_Roll,anim(a1)					; is Sonic/Knux in their rolling animation?
		beq.s	Obj_MonitorFallUpsideDown.return				; if so, return

		; solid
		jmp	(SolidObject_cont).w

; =============== S U B R O U T I N E =======================================

Monitor_ChkOverEdge:
		move.w	d1,d2
		add.w	d2,d2
		btst	#status.player.in_air,status(a1)				; is the character in the air?
		bne.s	.notonmonitor							; if so, branch

		; check if character is standing on
		move.w	x_pos(a1),d0
		sub.w	x_pos(a0),d0
		add.w	d1,d0
		bmi.s	.notonmonitor							; branch, if character is behind the left edge of the monitor
		cmp.w	d2,d0
		blo.s	Monitor_CharStandOn						; branch, if character is not beyond the right edge of the monitor

.notonmonitor

		; if the character isn't standing on the monitor
		bclr	#status.player.on_object,status(a1)				; clear 'on object' bit
		bset	#status.player.in_air,status(a1)				; set 'in air' bit
		bclr	d6,status(a0)							; clear 'standing on' bit for the current character
		moveq	#0,d4
		rts
; ---------------------------------------------------------------------------

Monitor_CharStandOn:
		move.w	d4,d2
		jsr	(MvSonicOnPtfm).w
		moveq	#0,d4
		rts

; =============== S U B R O U T I N E =======================================

Obj_MonitorBreak:
		moveq	#standing_mask|pushing_mask,d0					; is someone touching the monitor?
		and.b	status(a0),d0
		beq.s	Obj_MonitorSpawnIcon						; if not, branch
		move.b	d0,d1
		andi.b	#p1_standing|p1_pushing,d1					; is it the main character?
		beq.s	Obj_MonitorSpawnIcon						; if not, branch

		andi.b	#~( \
			setBit(status.player.on_object) | \
			setBit(status.player.pushing) \
		),(Player_1+status).w

		ori.b	#setBit(status.player.in_air),(Player_1+status).w		; prevent main character from walking in the air

Obj_MonitorSpawnIcon:

		andi.b	#( \
			setBit(status.npc.x_flip) | \
			setBit(status.npc.y_flip) \
		),status(a0)

		clr.b	collision_flags(a0)
		jsr	(Create_New_Sprite3).w
		bne.s	.skipiconcreation
		move.l	#Obj_MonitorContents,address(a1)
		move.b	render_flags(a0),render_flags(a1)
		move.w	x_pos(a0),x_pos(a1)						; set icon's position
		move.w	y_pos(a0),y_pos(a1)
		move.b	anim(a0),anim(a1)
		move.b	status(a0),status(a1)

.skipiconcreation
		jsr	(Create_New_Sprite3).w
		bne.s	.skipexplosioncreation
		move.l	#Obj_Explosion.skipanimal,address(a1)
		move.w	x_pos(a0),x_pos(a1)						; set explosion's position
		move.w	y_pos(a0),y_pos(a1)

.skipexplosioncreation
		move.w	respawn_addr(a0),d0						; get address in respawn table
		beq.s	.notremembered							; if it's zero, it isn't remembered
		movea.w	d0,a2								; load address into a2
		bset	#0,(a2)								; mark monitor as destroyed

.notremembered
		move.b	#$A,anim(a0)							; display 'broken' animation
		move.l	#Obj_MonitorAnimate,address(a0)
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

Obj_MonitorAnimate:
		cmpi.b	#$B,mapping_frame(a0)						; is monitor broken?
		bne.s	.notbroken							; if not, branch
		move.l	#Obj_Monitor.draw,address(a0)

.notbroken
		lea	Ani_Monitor(pc),a1
		jsr	(Animate_Sprite).w
		jmp	(Sprite_OnScreen_Test).w

; ---------------------------------------------------------------------------
; Monitor contents (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_MonitorContents:

		; init
		move.w	#make_art_tile(ArtTile_Monitors,0,0),art_tile(a0)

		; set screen coordinates and static mapping flag
		ori.b	#( \
			setBit(render_flags.level) | \
			setBit(render_flags.static_mappings) \
		),render_flags(a0)

		move.l	#bytes_word_to_long(16/2,16/2,priority_3),height_pixels(a0)	; set height, width and priority
		move.l	#.main,address(a0)

		; set move
		move.w	#-$300,y_vel(a0)
		btst	#render_flags.y_flip,render_flags(a0)				; is monitor upside down?
		beq.s	.notflipy							; if not, branch
		neg.w	y_vel(a0)

.notflipy
		moveq	#1,d0
		add.b	anim(a0),d0
		move.b	d0,mapping_frame(a0)
		add.b	d0,d0
		lea	Map_Monitor(pc),a1
		adda.w	(a1,d0.w),a1
		addq.w	#2,a1								; skip the number of sprite tiles
		move.l	a1,mappings(a0)

.main
		bsr.s	sub_1D820
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.waitdel
		subq.w	#1,anim_frame_timer(a0)
		bmi.s	.delete
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.delete
		jmp	(Delete_Current_Sprite).w

; =============== S U B R O U T I N E =======================================

sub_1D820:
		btst	#render_flags.y_flip,render_flags(a0)				; is monitor upside down?
		bne.s	loc_1D83C							; if so, branch
		tst.w	y_vel(a0)
		bpl.s	loc_1D850
		moveq	#$18,d1
		jmp	(MoveSprite_CustomGravity).w
; ---------------------------------------------------------------------------

loc_1D83C:
		tst.w	y_vel(a0)
		bmi.s	loc_1D850
		moveq	#-$18,d1
		jmp	(MoveSprite_CustomGravity).w
; ---------------------------------------------------------------------------

loc_1D850:
		move.w	#30-1,anim_frame_timer(a0)
		move.l	#Obj_MonitorContents.waitdel,address(a0)

		; give powerup
		lea	(Player_1).w,a1							; a1=character
		moveq	#0,d0
		move.b	anim(a0),d0
		add.w	d0,d0
		add.w	d0,d0
		jmp	.index(pc,d0.w)
; ---------------------------------------------------------------------------

.index
		bra.s	Monitor_Give_Eggman						; 0
		rts									; nop
		bra.s	Monitor_Give_Eggman						; 2
		rts									; nop
		bra.s	Monitor_Give_Eggman						; 4
		rts									; nop
		bra.s	Monitor_Give_Rings						; 6
		rts									; nop
		bra.s	Monitor_Give_SpeedShoes						; 8
		rts									; nop
		bra.s	Monitor_Give_Fire_Shield					; A
		rts									; nop
		bra.s	Monitor_Give_Lightning_Shield					; C
		rts									; nop
		bra.s	Monitor_Give_Bubble_Shield					; E
		rts									; nop
		bra.w	Monitor_Give_Invincibility					; 10
; ---------------------------------------------------------------------------

Monitor_Give_Eggman:									; 12
		jmp	Touch_ChkHurt3(pc)
; ---------------------------------------------------------------------------

Monitor_Give_Rings:
		moveq	#10,d0								; add 10 rings
		jmp	(AddRings).w
; ---------------------------------------------------------------------------

Monitor_Give_SpeedShoes:
		bset	#status_secondary.speed_shoes,status_secondary(a1)
		move.b	#(20*60)/8,speed_shoes_timer(a1)

		; set player speed
		lea	(Max_speed).w,a4
		move.w	#$C00,Max_speed-Max_speed(a4)					; set max speed
		move.w	#$18,Acceleration-Max_speed(a4)					; set acceleration
		move.w	#$80,Deceleration-Max_speed(a4)					; set deceleration
		tempo	8,1								; speed up the music
; ---------------------------------------------------------------------------

Monitor_Give_Fire_Shield:

		; sets Status_Shield, Status_FireShield, Status_LtngShield, and Status_BublShield to 0
		andi.b	#~( \
			setBit(status_secondary.shield) | \
			setBit(status_secondary.fire_shield) | \
			setBit(status_secondary.lightning_shield) | \
			setBit(status_secondary.bubble_shield) \
		),status_secondary(a1)

		bset	#status_secondary.shield,status_secondary(a1)
		bset	#status_secondary.fire_shield,status_secondary(a1)
		move.l	#Obj_FireShield,(Shield+address).w
		sfx	sfx_FireShield,1
; ---------------------------------------------------------------------------

Monitor_Give_Lightning_Shield:

		; sets Status_Shield, Status_FireShield, Status_LtngShield, and Status_BublShield to 0
		andi.b	#~( \
			setBit(status_secondary.shield) | \
			setBit(status_secondary.fire_shield) | \
			setBit(status_secondary.lightning_shield) | \
			setBit(status_secondary.bubble_shield) \
		),status_secondary(a1)

		bset	#status_secondary.shield,status_secondary(a1)
		bset	#status_secondary.lightning_shield,status_secondary(a1)
		move.l	#Obj_LightningShield,(Shield+address).w
		sfx	sfx_LightningShield,1
; ---------------------------------------------------------------------------

Monitor_Give_Bubble_Shield:

		; sets Status_Shield, Status_FireShield, Status_LtngShield, and Status_BublShield to 0
		andi.b	#~( \
			setBit(status_secondary.shield) | \
			setBit(status_secondary.fire_shield) | \
			setBit(status_secondary.lightning_shield) | \
			setBit(status_secondary.bubble_shield) \
		),status_secondary(a1)

		bset	#status_secondary.shield,status_secondary(a1)
		bset	#status_secondary.bubble_shield,status_secondary(a1)
		move.l	#Obj_BubbleShield,(Shield+address).w
		sfx	sfx_BubbleShield,1
; ---------------------------------------------------------------------------

Monitor_Give_Invincibility:
		bset	#status_secondary.invincible,status_secondary(a1)
		move.b	#(20*60)/8,invincibility_timer(a1)
		tst.b	(Music_results_flag).w						; don't change music if level is end
		bne.s	.skipmusic
		tst.b	(Boss_flag).w
		bne.s	.skipmusic
		cmpi.b	#12,air_left(a1)
		bls.s	.skipmusic
		music	mus_Invincible							; if invincible, play invincibility music

.skipmusic
		move.l	#Obj_Invincibility,(Invincibility_stars+address).w
		rts
; ---------------------------------------------------------------------------

		include "Objects/Main/Monitor/Object Data/Anim - Monitor.asm"
		include "Objects/Main/Monitor/Object Data/Map - Monitor.asm"
