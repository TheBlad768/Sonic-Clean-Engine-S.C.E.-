; ---------------------------------------------------------------------------
; Subroutine to react to collision flags
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

TouchResponse:
		bsr.w	RingTouchResponse						; check touch rings
		bsr.w	ShieldTouchResponse						; check touch shields

		; check
		tst.b	character_id(a0)						; is the player Sonic?
		bne.s	.Touch_NoInstaShield						; if not, branch

		; does the player have any shields or is invincible?
		moveq	#signextendB( \
			setBit(status_secondary.shield) | \
			setBit(status_secondary.invincible) | \
			setBit(status_secondary.fire_shield) | \
			setBit(status_secondary.lightning_shield) | \
			setBit(status_secondary.bubble_shield) \
		),d0

		and.b	status_secondary(a0),d0
		bne.s	.Touch_NoInstaShield						; if so, branch

		; by this point, we're focussing purely on the Insta-Shield
		cmpi.b	#1,double_jump_flag(a0)						; is the Insta-Shield currently in its 'attacking' mode?
		bne.s	.Touch_NoInstaShield						; if not, branch
		bset	#status_secondary.invincible,status_secondary(a0)		; make the player invincible
		moveq	#-(48/2),d2							; subtract width of Insta-Shield
		add.w	x_pos(a0),d2							; get player's x_pos
		moveq	#-(48/2),d3							; subtract height of Insta-Shield
		add.w	y_pos(a0),d3							; get player's y_pos
		moveq	#96/2,d4							; player's width
		moveq	#96/2,d5							; player's height
		bsr.s	.Touch_Process
		bclr	#status_secondary.invincible,status_secondary(a0)		; make the player vulnerable again
		rts
; ---------------------------------------------------------------------------

.Touch_NoInstaShield
		move.w	x_pos(a0),d2							; get player's x_pos
		move.w	y_pos(a0),d3							; get player's y_pos
		subq.w	#16/2,d2
		moveq	#0,d5
		move.b	y_radius(a0),d5							; load player's height
		subq.b	#6/2,d5
		sub.w	d5,d3
		cmpi.b	#AniIDSonAni_Duck,anim(a0)					; is player ducking?
		bne.s	.Touch_NotDuck							; if not, branch
		addi.w	#24/2,d3							; fix player's y_pos
		moveq	#20/2,d5							; set player's height

.Touch_NotDuck
		moveq	#32/2,d4							; player's collision width
		add.w	d5,d5								; double player's height value

.Touch_Process
		lea	(Collision_response_list).w,a4
		move.w	(a4)+,d6							; get number of objects queued
		beq.s	Touch_Return							; if there are none, return

Touch_Loop:
		movea.w	(a4)+,a1							; get address of first object's RAM
		tst.b	render_flags(a1)						; is the object visible on the screen?
		bpl.s	Touch_NextObj							; if not, branch
		tst.b	collision_type(a1)						; check collision type
		bne.s	Touch_Width							; if it actually has collision, branch

Touch_NextObj:
		subq.w	#2,d6								; count the object as done
		bne.s	Touch_Loop							; if there are still objects left, loop

Touch_Return:
		rts
; ---------------------------------------------------------------------------

Touch_Width:

		; get
		moveq	#0,d1
		move.b	collision_width(a1),d1						; get width value
		move.w	x_pos(a1),d0							; get object's x_pos
		sub.w	d1,d0								; subtract object's width
		sub.w	d2,d0								; subtract player's left collision boundary
		bhs.s	.checkrightside							; if player's left side is to the left of the object, branch
		add.w	d1,d1								; double object's width value
		add.w	d1,d0								; add object's width*2 (now at right of object)
		blo.s	Touch_Height							; if carry, branch (player is within the object's boundaries)
		bra.s	Touch_NextObj							; if not, loop and check next object
; ---------------------------------------------------------------------------

.checkrightside
		cmp.w	d4,d0								; is player's right side to the left of the object?
		bhi.s	Touch_NextObj							; if so, loop and check next object

Touch_Height:
		moveq	#0,d1
		move.b	collision_height(a1),d1						; get height value
		move.w	y_pos(a1),d0							; get object's y_pos
		sub.w	d1,d0								; subtract object's height
		sub.w	d3,d0								; subtract player's bottom collision boundary
		bhs.s	.checktop							; if bottom of player is under the object, branch
		add.w	d1,d1								; double object's height value
		add.w	d1,d0								; add object's height*2 (now at top of object)
		blo.s	Touch_ChkValue							; if carry, branch (player is within the object's boundaries)
		bra.s	Touch_NextObj							; if not, loop and check next object
; ---------------------------------------------------------------------------

.checktop
		cmp.w	d5,d0								; is top of player under the object?
		bhi.s	Touch_NextObj							; if so, loop and check next object

Touch_ChkValue:

		; load
		moveq	#0,d0
		move.b	collision_type(a1),d0
		move.w	Touch_Index-2(pc,d0.w),d0
		jmp	Touch_Index(pc,d0.w)
; ---------------------------------------------------------------------------

Touch_Index: offsetTable
		ptrTableEntry.w Touch_Enemy						; 2
		ptrTableEntry.w Touch_Harmful						; 4
		ptrTableEntry.w Touch_ChkDouble						; 6
		ptrTableEntry.w Touch_Ring						; 8
		ptrTableEntry.w Touch_Monitor						; A

; ---------------------------------------------------------------------------
; Touch ring
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Touch_Ring:

		; check the main character's invulnerability_timer
		cmpi.b	#(1*60)+30,(Player_1+invulnerability_timer).w			; is there more than 90 frames on the timer remaining?
		bhs.s	.return								; if so, branch
		move.l	#Obj_Ring_Collect,code_addr(a1)

.return
		rts

; ---------------------------------------------------------------------------
; Touch monitor
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Touch_Monitor:
		move.w	y_vel(a0),d0							; get player's y_vel
		tst.b	(Reverse_gravity_flag).w					; are we in reverse gravity mode?
		beq.s	.normalgravity							; if not, branch
		neg.w	d0								; negate player's y_vel

.normalgravity
		btst	#render_flags.y_flip,render_flags(a1)				; is the monitor upside down?
		beq.s	.monitornotupsidedown						; if not, branch
		tst.w	d0
		beq.s	.checkdestroy							; if player isn't moving up or down at all, branch
		bmi.s	.checkdestroy							; if player is moving up, branch
		bra.s	.checkfall							; if player is moving down, branch
; ---------------------------------------------------------------------------

.monitornotupsidedown
		tst.w	d0
		bpl.s	.checkdestroy							; if player is moving down, branch

.checkfall

		; this check is responsible for S&K's monitors not falling if hit from below (but only in regular gravity. see below)

	if ~~MonitorFall
		btst	#status.npc.y_flip,status(a1)					; is the monitor upside down (different way of checking)?
		beq.s	.checkdestroy							; if not, branch
	endif

		btst	#render_flags.y_flip,render_flags(a1)				; is the monitor upside down?
		bne.s	.monitorupsidedown						; if so, branch
		moveq	#-16,d0								; subtract height of monitor from it
		add.w	y_pos(a0),d0							; get player's y_pos
		cmp.w	y_pos(a1),d0
		blo.s	.return								; if new value is lower than monitor's y_pos, return
		bra.s	.monitorfall
; ---------------------------------------------------------------------------

.monitorupsidedown
		moveq	#16,d0								; add height of monitor from it
		add.w	y_pos(a0),d0							; get player's y_pos
		cmp.w	y_pos(a1),d0
		bhs.s	.return								; if new value is higher than monitor's y_pos, return

.monitorfall

		; fun fact: In S3, like the games before it, hitting a monitor from below would make it fall
		; in S&K, that was removed, and they are destroyed as normal
		; however, according to this code, if a monitor is upside down, and player is in reverse gravity,
		; hitting the monitor from below will still make it fall
		; playing with Debug Mode confirms this

		neg.w	y_vel(a0)							; reverse Sonic's y-motion
		move.w	#-$180,y_vel(a1)
		tst.b	routine_secondary(a1)
		bne.s	.return
		st	routine_secondary(a1)						; set the monitor's routine_secondary counter

.return
		rts
; ---------------------------------------------------------------------------

.checkdestroy
		cmpi.b	#AniIDSonAni_Roll,anim(a0)					; is Sonic rolling/jumping?
		bne.s	.return								; if not, branch

		; okaytodestroy
		neg.w	y_vel(a0)
		move.l	#Monitor_Break,code_addr(a1)
		rts

; ---------------------------------------------------------------------------
; Touch enemy
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Touch_Enemy:
		btst	#status_secondary.invincible,status_secondary(a0)		; is player invincible?
		bne.s	.checkhurtenemy							; if so, branch
		cmpi.b	#AniIDSonAni_SpinDash,anim(a0)					; is player in their spin dash animation?
		beq.s	.checkhurtenemy							; if so, branch
		cmpi.b	#AniIDSonAni_Roll,anim(a0)					; is player in their rolling animation?
		beq.s	.checkhurtenemy							; if so, branch

		; check Knuckles
		cmpi.b	#PlayerID_Knuckles,character_id(a0)				; is player Knuckles?
		bne.s	.notKnuckles							; if not, branch
		cmpi.b	#1,double_jump_flag(a0)						; is Knuckles gliding?
		beq.s	.checkhurtenemy							; if so, branch
		cmpi.b	#3,double_jump_flag(a0)						; is Knuckles sliding across the ground after gliding?
		beq.s	.checkhurtenemy							; if so, branch
		bra.w	Touch_Harmful
; ---------------------------------------------------------------------------

.notKnuckles
		cmpi.b	#PlayerID_Tails,character_id(a0)				; is player Tails?
		bne.w	Touch_Harmful							; if not, branch
		tst.b	double_jump_flag(a0)						; is Tails flying? ("gravity-affected")
		beq.w	Touch_Harmful							; if not, branch
		btst	#status.player.underwater,status(a0)				; is Tails underwater?
		bne.w	Touch_Harmful							; if so, branch

		; check Tails attack
		move.w	x_pos(a0),d1
		move.w	y_pos(a0),d2
		sub.w	x_pos(a1),d1
		sub.w	y_pos(a1),d2
		bsr.w	GetArcTan
		subi.b	#$20,d0
		cmpi.b	#$40,d0
		bhs.w	Touch_Harmful

.checkhurtenemy

		; boss related? could be special enemies in general
		tst.b	boss_hitcount(a1)
		beq.s	Touch_EnemyNormal

		; boss
		neg.w	x_vel(a0)							; bounce player directly off boss
		neg.w	y_vel(a0)
		neg.w	ground_vel(a0)
		move.b	collision_type(a1),boss_saved_collision(a1)			; save current collision type
		move.w	a0,d0								; save value of RAM address of which player hit the boss
		move.b	d0,boss_saved_player(a1)					; $00 for main character, $50 for sidekick
		clr.b	collision_type(a1)						; remove collision

	if BossDebug
		clr.b	boss_hitcount(a1)
	else
		subq.b	#1,boss_hitcount(a1)
		bne.s	.bossnotdefeated
	endif

		bset	#status.npc.defeated,status(a1)					; set "boss defeated" flag

.bossnotdefeated
		rts
; ---------------------------------------------------------------------------

Touch_EnemyNormal:

		; check DPLC slot
		btst	#status.npc.dplc_slot,status(a1)				; was this object slot turned on?
		beq.s	.notDPLC							; if not, branch

		; Remove_From_TrackingSlot
		move.b	ros_bit(a1),d0							; slot bit
		movea.w	ros_addr(a1),a2							; slot address
		bclr	d0,(a2)								; turn off this slot (SetUp_ObjAttributesSlotted)

.notDPLC
		bset	#status.npc.defeated,status(a1)					; set "boss defeated" flag
		moveq	#0,d0								; clear d0 for HUD_AddToScore
		move.w	(Chain_bonus_counter).w,d0					; get copy of chain bonus counter
		addq.w	#2,(Chain_bonus_counter).w					; add 2 to item bonus counter
		cmpi.w	#(Enemy_Points_end-Enemy_Points)-2,d0				; has the counter already surpassed 5?
		blo.s	.notreachedlimit						; if not, branch
		moveq	#(Enemy_Points_end-Enemy_Points)-2,d0				; cap counter at 6

.notreachedlimit
		move.w	d0,explosion.bonus_counter(a1)
		move.w	Enemy_Points(pc,d0.w),d0					; get appropriate number of points
		cmpi.w	#16*2,(Chain_bonus_counter).w					; have 16 enemies been destroyed?
		blo.s	.notreachedlimit2						; if not, branch
		move.w	#1000,d0							; fix bonus to 10000
		move.w	#10,explosion.bonus_counter(a1)

.notreachedlimit2
		bsr.w	HUD_AddToScore
		move.l	#Obj_Explosion,code_addr(a1)					; change object to explosion
		tst.w	y_vel(a0)
		bmi.s	.bouncedown
		move.w	y_pos(a0),d0
		cmp.w	y_pos(a1),d0							; was player above, or at the same height as, the enemy when it was destroyed
		bhs.s	.bounceup
		neg.w	y_vel(a0)
		rts
; ---------------------------------------------------------------------------

.bouncedown
		addi.w	#$100,y_vel(a0)							; bounce down
		rts
; ---------------------------------------------------------------------------

.bounceup
		subi.w	#$100,y_vel(a0)							; bounce up
		rts
; ---------------------------------------------------------------------------

Enemy_Points:

		; 100, 200, 500, 1000 points
		dc.w 10, 20, 50, 100							; points awarded div 10
Enemy_Points_end

; ---------------------------------------------------------------------------
; subroutine for checking if Sonic/Tails/Knuckles should be hurt and hurting them if so
; note: character must be at a0
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Touch_Harmful:

		; does player have any shields or is invincible?
		moveq	#signextendB( \
			setBit(status_secondary.shield) | \
			setBit(status_secondary.invincible) | \
			setBit(status_secondary.fire_shield) | \
			setBit(status_secondary.lightning_shield) | \
			setBit(status_secondary.bubble_shield) \
		),d0

		and.b	status_secondary(a0),d0
		beq.s	Touch_Harmful_NoPowerUp						; if not, branch
		and.b	shield_reaction(a1),d0						; does one of the player's shields grant immunity to this object??
		bne.s	Touch_Harmful_Return						; if so, branch
		btst	#status_secondary.shield,status_secondary(a0)			; does the player have a shield (strange time to ask)
		bne.s	Touch_Harmful_HaveShield					; if so, branch

Touch_Harmful2:
		btst	#status_secondary.invincible,status_secondary(a0)		; does Sonic have invincibility?
		beq.s	Touch_Hurt							; if not, branch

Touch_Harmful_Return:
		rts
; ---------------------------------------------------------------------------

Touch_Harmful_NoPowerUp:

		; note that this check could apply to the Insta-Shield,
		; but the check that branches to this requires the player not be invincible.
		; the Insta-Shield grants temporary invincibility. see the problem?

		cmpi.b	#1,double_jump_flag(a0)						; is player Insta-Shield-attacking (Sonic), flying (Tails) or gliding (Knuckles)?
		bne.s	Touch_Harmful2							; if not, branch

Touch_Harmful_HaveShield:
		moveq	#setBit(shield_reaction.all_shields),d0				; should the object be bounced away by a shield?
		and.b	shield_reaction(a1),d0
		beq.s	Touch_Harmful2							; if not, branch

Touch_Harmful_Bounce_Projectile:
		move.w	x_pos(a0),d1
		move.w	y_pos(a0),d2
		sub.w	x_pos(a1),d1
		sub.w	y_pos(a1),d2
		bsr.w	GetArcTan
		bsr.w	GetSineCosine
		move.w	#-$800,d2
		muls.w	d2,d1
		asr.l	#8,d1
		move.w	d1,x_vel(a1)
		muls.w	d2,d0
		asr.l	#8,d0
		move.w	d0,y_vel(a1)
		clr.b	collision_type(a1)						; remove collision
		rts
; ---------------------------------------------------------------------------

Touch_Hurt:
		tst.b	invulnerability_timer(a0)					; is the player invulnerable?
		bne.s	Touch_Harmful_Return						; if so, branch
		movea.w	a1,a2								; load current object to a2

; continue straight to HurtCharacter
; ---------------------------------------------------------------------------
; Hurting Sonic/Tails/Knuckles subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

HurtCharacter:
		move.w	(Ring_count).w,d0
		btst	#status_secondary.shield,status_secondary(a0)			; does Sonic have shield?
		bne.s	.hasshield							; if yes, branch
		tst.b	status_tertiary(a0)
		bmi.s	.bounce
		tst.w	d0								; does Sonic have any rings?
		beq.w	.norings							; if not, branch

		; create
		bsr.w	Create_New_Object
		bne.s	.hasshield
		move.l	#Obj_Bouncing_Ring,code_addr(a1)				; load bouncing multi rings object
		move.w	x_pos(a0),x_pos(a1)
		move.w	y_pos(a0),y_pos(a1)

.hasshield

		andi.b	#~( \
			setBit(status_secondary.shield) | \
			setBit(status_secondary.fire_shield) | \
			setBit(status_secondary.lightning_shield) | \
			setBit(status_secondary.bubble_shield) \
		),status_secondary(a0)

.bounce
		move.b	#PlayerID_Hurt,routine(a0)
		bsr.w	Sonic_TouchFloor
		bset	#status.player.in_air,status(a0)
		move.l	#words_to_long(-$200,-$400),x_vel(a0)				; make Sonic bounce away from the object
		btst	#status.player.underwater,status(a0)				; is Sonic underwater?
		beq.s	.isdry								; if not, branch
		move.l	#words_to_long(-$100,-$200),x_vel(a0)				; slower bounce

.isdry
		move.w	x_pos(a0),d0
		cmp.w	x_pos(a2),d0
		blo.s	.isleft								; if Sonic is left of the object, branch
		neg.w	x_vel(a0)							; if Sonic is right of the object, reverse

.isleft
		clr.w	ground_vel(a0)
		move.b	#AniIDSonAni_Hurt2,anim(a0)					; set hurt anim
		move.b	#2*60,invulnerability_timer(a0)					; set temp invincible time to 2 seconds

		; check
		moveq	#signextendB(sfx_SpikeHit),d0					; load spikes damage sound
		move.l	mappings_addr(a2),d1
		cmpi.l	#Map_Spikes,d1							; was damage caused by spikes?
		beq.s	.sound								; if yes, branch
		moveq	#signextendB(sfx_Death),d0					; load normal damage sound

.sound
		jmp	(Play_SFX).w
; ---------------------------------------------------------------------------

.norings

		; check
		moveq	#signextendB(sfx_SpikeHit),d0					; load spikes damage sound
		move.l	mappings_addr(a2),d1
		cmpi.l	#Map_Spikes,d1							; was damage caused by spikes?
		beq.s	Kill_Character.main						; if yes, branch

		; next
		bra.s	Kill_Character.sfx

; ---------------------------------------------------------------------------
; Killing Sonic/Tails/Knuckles subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Kill_Character:
		tst.w	(Debug_placement_mode).w					; is debug mode active?
		bne.s	.dontdie							; if yes, branch

.sfx
		moveq	#signextendB(sfx_Death),d0					; play normal death sound

.main
		clr.b	status_secondary(a0)
		clr.b	status_tertiary(a0)
		move.b	#PlayerID_Death,routine(a0)
		move.w	d0,-(sp)
		bsr.w	Sonic_TouchFloor
		move.w	(sp)+,d0
		bset	#status.player.in_air,status(a0)
		move.w	#-$700,y_vel(a0)
		clr.w	x_vel(a0)
		clr.w	ground_vel(a0)
		move.b	#AniIDSonAni_Death,anim(a0)
		move.l	priority(a0),(Debug_saved_priority).w				; save priority and art_tile
		clr.w	priority(a0)
		bset	#high_priority_bit,art_tile(a0)					; high priority
		jmp	(Play_SFX).w
; ---------------------------------------------------------------------------

.dontdie
		rts

; ---------------------------------------------------------------------------
; Touch check double
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Touch_ChkDouble:
		move.w	a0,d1								; get RAM address of what object hit this
		subi.w	#Object_RAM,d1
		beq.s	.ismaincharacter						; if the main character hit it, branch
		addq.b	#1,collision_property(a1)					; otherwise, it seems everything else does double

.ismaincharacter
		addq.b	#1,collision_property(a1)					; so hitting a boss with your tails sidekick does double damage?
		rts

; ---------------------------------------------------------------------------
; Subroutine to react to shield collision
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

ShieldTouchResponse:

		; does the player have any shields?
		moveq	#signextendB( \
			setBit(status_secondary.shield) | \
			setBit(status_secondary.fire_shield) | \
			setBit(status_secondary.lightning_shield) | \
			setBit(status_secondary.bubble_shield) \
		),d0

		and.b	status_secondary(a0),d0
		beq.s	ShieldTouch_Return
		moveq	#-(48/2),d2							; subtract width of shield
		add.w	x_pos(a0),d2							; get player's x_pos
		moveq	#-(48/2),d3							; subtract height of shield
		add.w	y_pos(a0),d3							; get player's y_pos
		moveq	#96/2,d4							; player's width
		moveq	#96/2,d5							; player's height

		; find
		lea	(Collision_response_list).w,a4
		move.w	(a4)+,d6							; get number of objects queued
		beq.s	ShieldTouch_Return						; if there are none, return

ShieldTouch_Loop:
		movea.w	(a4)+,a1							; get address of first object's RAM
		tst.b	render_flags(a1)						; is the object visible on the screen?
		bpl.s	ShieldTouch_NextObj						; if not, branch
		cmpi.b	#collision_type.npc.hurt,collision_type(a1)			; is only the high bit set ("harmful")?
		beq.s	ShieldTouch_Width						; if so, branch

ShieldTouch_NextObj:
		subq.w	#2,d6								; count the object as done
		bne.s	ShieldTouch_Loop						; if there are still objects left, loop

ShieldTouch_Return:
		rts
; ---------------------------------------------------------------------------

ShieldTouch_Width:
		moveq	#setBit(shield_reaction.all_shields),d0				; should the object be bounced away by a shield?
		and.b	shield_reaction(a1),d0
		beq.s	ShieldTouch_NextObj						; if not, branch

		; get
		moveq	#0,d1
		move.b	collision_width(a1),d1						; get width value
		move.w	x_pos(a1),d0							; get object's x_pos
		sub.w	d1,d0								; subtract object's width
		sub.w	d2,d0								; subtract player's left collision boundary
		bhs.s	.checkrightside							; if player's left side is to the left of the object, branch
		add.w	d1,d1								; double object's width value
		add.w	d1,d0								; add object's width*2 (now at right of object)
		blo.s	ShieldTouch_Height						; if carry, branch (player is within the object's boundaries)
		bra.s	ShieldTouch_NextObj						; if not, loop and check next object
; ---------------------------------------------------------------------------

.checkrightside
		cmp.w	d4,d0								; is player's right side to the left of the object?
		bhi.s	ShieldTouch_NextObj						; if so, loop and check next object

ShieldTouch_Height:
		moveq	#0,d1
		move.b	collision_height(a1),d1						; get height value
		move.w	y_pos(a1),d0							; get object's y_pos
		sub.w	d1,d0								; subtract object's height
		sub.w	d3,d0								; subtract player's bottom collision boundary
		bhs.s	.checktop							; if bottom of player is under the object, branch
		add.w	d1,d1								; double object's height value
		add.w	d1,d0								; add object's height*2 (now at top of object)
		blo.s	.deflect							; if carry, branch (player is within the object's boundaries)
		bra.s	ShieldTouch_NextObj						; if not, loop and check next object
; ---------------------------------------------------------------------------

.checktop
		cmp.w	d5,d0								; is top of player under the object?
		bhi.s	ShieldTouch_NextObj						; if so, loop and check next object

.deflect
		move.w	x_pos(a0),d1
		move.w	y_pos(a0),d2
		sub.w	x_pos(a1),d1
		sub.w	y_pos(a1),d2
		bsr.w	GetArcTan
		bsr.w	GetSineCosine
		move.w	#-$800,d2
		muls.w	d2,d1
		asr.l	#8,d1
		move.w	d1,x_vel(a1)
		muls.w	d2,d0
		asr.l	#8,d0
		move.w	d0,y_vel(a1)
		clr.b	collision_type(a1)						; remove collision
		rts

; ---------------------------------------------------------------------------
; Reset collision (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_ResetCollisionResponseList:
		clr.w	(Collision_response_list).w
		rts
