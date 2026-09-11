; ---------------------------------------------------------------------------
; Init object
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

SetUp_ObjAttributes:
		move.l	(a1)+,mappings_addr(a0)						; mapping address

SetUp_ObjAttributes2:
		move.w	(a1)+,art_tile(a0)						; VRAM offset

SetUp_ObjAttributes3:
		move.l	(a1)+,height_pixels(a0)						; height, width and priority
		move.b	(a1)+,mapping_frame(a0)						; frame number
		move.b	(a1)+,collision_type(a0)					; collision type
		move.w	(a1)+,collision_height(a0)					; collision height and width

		; set
		bset	#render_flags.level,render_flags(a0)				; use screen coordinates
		addq.b	#2,routine(a0)							; next routine
		rts

; ---------------------------------------------------------------------------
; Init object for perform DPLC (slot system)
; Create the object only in the current slot
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

SetUp_ObjAttributesSlotted:
		moveq	#0,d0
		movem.w	(a1)+,d1/d3-d5							; copy data to d1,d3-d5

		; check
		lea	(Slotted_object_bits).w,a2
		adda.w	d5,a2								; get the address of the array to use
		move.b	(a2),d5
		beq.s	.create								; if array is clear, just make the object

.find
		lsr.b	d5								; check slot (each bit)
		bhs.s	.create								; if clear, make object
		addq.w	#1,d0								; increment bit number
		add.w	d4,d3								; add VRAM offset
		dbf	d1,.find							; repeat max times

		; delete object
		moveq	#0,d0
		move.l	d0,code_addr(a0)
		move.l	d0,x_pos(a0)
		move.l	d0,y_pos(a0)
		move.b	d0,render_flags(a0)
		move.w	d0,status(a0)							; if no open slots, then destroy this object period
		move.w	d0,subtype(a0)
		addq.w	#4*2,sp								; exit from current object
		rts
; ---------------------------------------------------------------------------

.create
		bset	d0,(a2)								; turn this slot on
		move.b	d0,ros_bit(a0)
		move.w	a2,ros_addr(a0)							; keep track of slot address and bit number
		move.w	d3,art_tile(a0)							; use correct VRAM offset
		move.l	(a1)+,mappings_addr(a0)						; mapping address
		move.l	(a1)+,height_pixels(a0)						; height, width and priority
		move.b	(a1)+,mapping_frame(a0)						; frame number
		move.b	(a1)+,collision_type(a0)					; collision type
		move.w	(a1)+,collision_height(a0)					; collision height and width
		st	ros_prev_frame(a0)						; reset DPLC frame (used by Perform_DPLC)

		; set
		moveq	#2,d0
		add.b	d0,routine(a0)							; next routine
		bset	d0,render_flags(a0)						; use screen coordinates
		bset	d0,status(a0)							; turn object slotting on
		rts

; ---------------------------------------------------------------------------
; Perform DPLC (custom format)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Perform_DPLC:
		moveq	#0,d0
		move.b	mapping_frame(a0),d0						; get the frame number
		cmp.b	ros_prev_frame(a0),d0						; if frame number remains the same as before, don't do anything
		beq.s	.return
		move.b	d0,ros_prev_frame(a0)

		; load
		add.w	d0,d0								; multiply by 2
		movea.l	(a2)+,a3							; source address of art
		movea.l	(a2)+,a2							; address of DPLC script
		adda.w	(a2,d0.w),a2							; apply offset to script
		move.w	(a2)+,d5							; get number of DMA transactions
		bmi.s	.return								; skip if zero queues
		move.w	art_tile(a0),d4							; get art tile to d4
		andi.w	#tile_mask,d4							; isolate tile location offset
		lsl.w	#5,d4								; convert to VRAM address
		moveq	#0,d3

.loop
		move.w	(a2)+,d3							; art source offset
		move.l	d3,d1
		andi.w	#$FFF0,d1							; isolate all but lower 4 bits
		add.l	a3,d1								; get final source address of art
		move.w	d4,d2								; destination VRAM address
		andi.w	#$F,d3
		addq.w	#1,d3
		lsl.w	#4,d3								; d3 is the total number of words to transfer (maximum 16 tiles per transaction)
		add.w	d3,d4
		add.w	d3,d4
		bsr.w	Add_To_DMA_Queue						; add to queue
		dbf	d5,.loop							; keep going

.return
		rts

; ---------------------------------------------------------------------------
; Set indexed velocity
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Set_IndexedVelocity:
		move.w	subtype(a0),d1
		add.w	d1,d1								; multiply by 2
		add.w	d1,d0
		move.l	.index(pc,d0.w),x_vel(a0)

		; check flipx
		btst	#render_flags.x_flip,render_flags(a0)
		beq.s	.return
		neg.w	x_vel(a0)

.return
		rts
; ---------------------------------------------------------------------------

.index
		dc.w -$100, -$100	; 0
		dc.w $100, -$100	; 4
		dc.w -$200, -$200	; 8
		dc.w $200, -$200	; C
		dc.w -$300, -$200	; 10
		dc.w $300, -$200	; 14
		dc.w -$200, -$200	; 18
		dc.w 0, -$200		; 1C
		dc.w -$400, -$300	; 20
		dc.w $400, -$300	; 24
		dc.w $300, -$300	; 28
		dc.w -$400, -$300	; 2C
		dc.w $400, -$300	; 30
		dc.w -$200, -$200	; 34
		dc.w $200, -$200	; 38
		dc.w 0, -$100		; 3C
		dc.w -$40, -$700	; 40
		dc.w -$80, -$700	; 44
		dc.w -$180, -$700	; 48
		dc.w -$100, -$700	; 4C
		dc.w -$200, -$700	; 50
		dc.w -$280, -$700	; 54
		dc.w -$300, -$700	; 58
		dc.w 0, -$100		; 5C
		dc.w -$100, -$100	; 60
		dc.w $100, -$100	; 64
		dc.w -$200, -$100	; 68
		dc.w $200, -$100	; 6C
		dc.w -$200, -$200	; 70
		dc.w $200, -$200	; 74
		dc.w -$300, -$200	; 78
		dc.w $300, -$200	; 7C
		dc.w -$300, -$300	; 80
		dc.w $300, -$300	; 84
		dc.w -$400, -$300	; 88
		dc.w $400, -$300	; 8C
		dc.w -$200, -$300	; 90
		dc.w $200, -$300	; 94

; ---------------------------------------------------------------------------
; Restore level music
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Restore_LevelMusic:
		lea	(Level_data_addr_RAM.Music).w,a2				; load music
		moveq	#0,d0
		move.b	(a2),d0
		move.w	d0,(Current_music).w
		btst	#status_secondary.invincible,(Player_1+status_secondary).w
		beq.s	.play								; branch if Sonic is not invincible
		moveq	#signextendB(mus_Invincible),d0					; prepare to play invincibility music

.play
		bra.w	Play_Music							; play music

; ---------------------------------------------------------------------------
; Hurt character
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

HurtCharacter_Directly2:
		tst.b	object_control(a1)
		bmi.s	HurtCharacter_Directly.return
		btst	#status_secondary.invincible,status_secondary(a1)		; is character invincible?
		bne.s	HurtCharacter_Directly.return					; if yes, branch
		tst.b	invulnerability_timer(a1)					; is character invulnerable?
		bne.s	HurtCharacter_Directly.return					; if yes, branch
		cmpi.b	#PlayerID_Hurt,routine(a1)					; is the character hurt, dying, etc. ?
		bhs.s	HurtCharacter_Directly.return					; if yes, branch

HurtCharacter_Directly:
		tst.w	(Debug_placement_mode).w					; is debug mode on?
		bne.s	.return								; if yes, branch

		; hurt character
		movea.w	a0,a2								; load current object to a2
		movea.w	a1,a0								; load player to a0
		bsr.w	HurtCharacter							; "
		movea.w	a2,a0								; return current object to a0

.return
		rts

; ---------------------------------------------------------------------------
; Enemy defeated
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

EnemyDefeated:
		bsr.s	EnemyDefeat_Score
		movea.w	parent4(a0),a1							; a1=character
		tst.w	y_vel(a1)							; is Sonic moving vertically?
		bmi.s	.bouncedown							; if moving upwards, branch

		; check
		move.w	y_pos(a1),d0
		cmp.w	y_pos(a0),d0							; is the object above Sonic?
		bhs.s	.bounceup							; if yes, branch
		neg.w	y_vel(a1)
		rts
; ---------------------------------------------------------------------------

.bouncedown
		addi.w	#$100,y_vel(a1)							; bounce down
		rts
; ---------------------------------------------------------------------------

.bounceup
		subi.w	#$100,y_vel(a1)							; bounce up
		rts

; ---------------------------------------------------------------------------
; Enemy defeat add score
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

EnemyDefeat_Score:
		bset	#status.npc.defeated,status(a0)					; set "boss defeated" flag
		clr.b	collision_type(a0)						; remove collision
		moveq	#0,d0								; clear d0 for HUD_AddToScore
		move.w	(Chain_bonus_counter).w,d0					; get copy of chain bonus counter
		addq.w	#2,(Chain_bonus_counter).w					; add 2 to item bonus counter
		cmpi.w	#(Enemy_Points_end-Enemy_Points)-2,d0				; has the counter already surpassed 5?
		blo.s	.notreachedlimit						; if not, branch
		moveq	#(Enemy_Points_end-Enemy_Points)-2,d0				; cap counter at 6

.notreachedlimit
		move.w	d0,explosion.bonus_counter(a0)
		lea	Enemy_Points(pc),a2
		move.w	(a2,d0.w),d0							; get appropriate number of points
		cmpi.w	#16*2,(Chain_bonus_counter).w					; have 16 enemies been destroyed?
		blo.s	.notreachedlimit2						; if not, branch
		move.w	#1000,d0							; fix bonus to 10000
		move.w	#10,explosion.bonus_counter(a0)

.notreachedlimit2
		move.l	#Obj_Explosion,code_addr(a0)					; change object to explosion
		bra.w	HUD_AddToScore

; ---------------------------------------------------------------------------
; Hurt character (without damage)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

HurtCharacter_WithoutDamage:
		lea	(Player_1).w,a1							; a1=character
		move.b	#PlayerID_Hurt,routine(a1)					; hit animation
		bclr	#status.player.on_object,status(a1)
		bclr	#status.player.pushing,status(a1)				; player is not standing on/pushing an object

	if PlayerRollJumpLock
		bclr	#status.player.rolljumping,status(a1)
	endif

		bset	#status.player.in_air,status(a1)
		move.l	#words_to_long(-$200,-$300),x_vel(a1)				; set speed of player
		clr.w	ground_vel(a1)							; zero out inertia
		move.b	#AniIDSonAni_Hurt,anim(a1)					; set falling animation
		sfx	sfx_Death,1							; play death sound

; ---------------------------------------------------------------------------
; Launch character
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

LaunchCharacter:
		move.w	d0,y_vel(a1)							; set y velocity
		bset	#status.player.in_air,status(a1)				; set character airborne flag
		bclr	#status.player.on_object,status(a1)				; clear character on object flag
		clr.b	jumping(a1)							; clear character jumping flag
		clr.b	spin_dash_flag(a1)						; clear spin dash flag
		move.b	#AniIDSonAni_Spring,anim(a1)					; change Sonic's animation to "spring" ($10)
		move.b	#PlayerID_Control,routine(a1)					; set character to airborne state
		sfx	sfx_Spring,1							; play spring sound

; ---------------------------------------------------------------------------
; Check player attack
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Check_PlayerAttack:

		; check
		btst	#status_secondary.invincible,status_secondary(a1)		; is character invincible?
		bne.s	.hit								; if so, branch
		cmpi.b	#AniIDSonAni_SpinDash,anim(a1)					; is player in their spin dash animation?
		beq.s	.hit								; if so, branch
		cmpi.b	#AniIDSonAni_Roll,anim(a1)					; is player in their rolling animation?
		beq.s	.hit								; if so, branch

		; check player
		moveq	#0,d0
		move.b	character_id(a1),d0
		add.w	d0,d0								; multiply by 2
		jmp	.index(pc,d0.w)
; ---------------------------------------------------------------------------

.index
		bra.s	.fail								; 0 - Sonic
		bra.s	.fail								; 1 - Tails
		bra.s	.fail								; 2 - Knuckles
; ---------------------------------------------------------------------------

.hit
		moveq	#1,d0								; player attack
		rts
; ---------------------------------------------------------------------------

.fail
		moveq	#0,d0								; player doesn't attack
		rts

; ---------------------------------------------------------------------------
; Check player collision
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Check_PlayerCollision:
		move.b	collision_property(a0),d0
		beq.s	.return
		clr.b	collision_property(a0)
		andi.w	#3,d0
		add.w	d0,d0								; multiply by 2
		movea.w	.players(pc,d0.w),a1
		move.w	a1,parent4(a0)							; save player address
		moveq	#1,d1								; set touch

.return
		rts
; ---------------------------------------------------------------------------

.players	dc.w Player_1&$FFFF, Player_1&$FFFF, Player_1&$FFFF, Player_1&$FFFF

; ---------------------------------------------------------------------------
; Load level results
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Load_LevelResults:
		lea	(Player_1).w,a1							; a1=character
		btst	#7,status(a1)
		bne.s	.return
		btst	#status.player.in_air,status(a1)				; is the player in the air?
		bne.s	.return								; if yes, branch
		cmpi.b	#PlayerID_Death,routine(a1)					; is player dead?
		bhs.s	.return								; if yes, branch
		bsr.s	Set_PlayerEndingPose
		clr.b	(End_of_level_flag).w

		; create
		bsr.w	Create_New_Object
		bne.s	.return
		move.l	#Obj_LevelResults,code_addr(a1)

.return
		rts

; ---------------------------------------------------------------------------
; Set player ending pose
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Set_PlayerEndingPose:
		move.b	#$81,object_control(a1)
		move.b	#AniIDSonAni_Landing,anim(a1)					; set landing animation
		clr.l	x_vel(a1)
		clr.w	ground_vel(a1)
		clr.b	spin_dash_flag(a1)
		bclr	#p1_pushing_bit,status(a0)
		bclr	#p2_pushing_bit,status(a0)
		bclr	#status.player.pushing,status(a1)

	if PlayerRollJumpLock
		bclr	#status.player.rolljumping,status(a1)
	endif

		bclr	#status.player.rolling,status(a1)
		beq.s	.return								; if the player doesn't roll, branch

		; fix player ypos
		move.b	y_radius(a1),d0
		move.w	default_y_radius(a1),y_radius(a1)				; set y_radius and x_radius
		sub.b	default_y_radius(a1),d0
		ext.w	d0
		tst.b	(Reverse_gravity_flag).w					; are we in reverse gravity mode?
		beq.s	.notgrav							; if not, branch
		neg.w	d0

.notgrav
		add.w	d0,y_pos(a1)

.return
		rts

; ---------------------------------------------------------------------------
; Restore player control
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Restore_PlayerControl:
		lea	(Player_1).w,a1							; a1=character

Restore_PlayerControl2:
		clr.b	object_control(a1)
		bclr	#status.player.in_air,status(a1)
		move.w	#bytes_to_word(AniIDSonAni_Wait,AniIDSonAni_Wait),anim(a1)
		clr.b	anim_frame(a1)
		clr.b	anim_frame_timer(a1)
		rts

; ---------------------------------------------------------------------------
; Start new level
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

StartNewLevel:
		move.w	d0,(Current_zone_and_act).w
		move.w	d0,(Apparent_zone_and_act).w
		st	(Restart_level_flag).w
		clr.b	(Last_star_post_hit).w

.return
		rts

; ---------------------------------------------------------------------------
; Play sfx continuous
; ---------------------------------------------------------------------------
;
; Input:
; d0 = sfx id
; d1 = wait count

; =============== S U B R O U T I N E =======================================

Play_SFX_Continuous:
		moveq	#$F,d1								; play sound every 16th frame

.main
		and.b	(V_int_run_count.byte).w,d1
		bne.s	StartNewLevel.return
		bra.w	Play_SFX							; play continuous sfx

; ---------------------------------------------------------------------------
; Player intro right move
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Player_IntroRightMove:
		move.w	#bytes_to_word(btnR,btnR),d0					; set right move
		tst.w	wait_timer(a0)							; is timer over?
		beq.s	.notjump							; if yes, branch
		subq.w	#1,wait_timer(a0)						; decrement timer
		move.w	#bytes_to_word(btnA+btnR,btnR),d0				; keep jumping

.notjump
		btst	#status.player.pushing,status(a1)				; player hitting a solid?
		beq.s	.notpush							; if not, branch
		move.w	#$1F,wait_timer(a0)						; set timer
		move.w	#bytes_to_word(btnA+btnR,btnA+btnR),d0				; set player jump

.notpush
		move.w	d0,(Ctrl_1_logical).w
		rts

; ---------------------------------------------------------------------------
; Check left/right controller press
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Check_LRControllerShake:

		; wait
		subq.b	#1,objoff_3D(a0)						; decrement timer
		bpl.s	.skip								; if time remains, branch
		move.w	#bytes_to_word((6-1),(1*60)),objoff_3C(a0)			; reset direction changes counter and timer

.skip
		movea.w	objoff_3E(a0),a2						; load controller address to a2

		; check buttons
		moveq	#btnLR,d0							; mask for left/right buttons
		and.w	(a2),d0								; is left/right being pressed?
		beq.s	.return								; if not, branch
		move.w	objoff_3A(a0),d1						; load previous controller state
		move.w	d0,objoff_3A(a0)						; save current controller state

		; check buttons changes
		andi.w	#btnLR,d1							; mask for left/right buttons
		eor.w	d1,d0								; has direction changes counter changed?
		beq.s	.return								; if not, branch

		; wait
		subq.b	#1,objoff_3C(a0)						; decrement remaining required direction changes
		bmi.s	.return								; if minus, branch (success)

		; fail
		moveq	#0,d0								; set flag to 0

.return
		rts

; ---------------------------------------------------------------------------
; Subtract ring from the player
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

SubtractRings_Process:

		; wait
		subq.w	#1,wait_timer(a0)						; decrement timer
		bpl.s	.check								; if time remains, branch
		move.w	#(1*60)-1,wait_timer(a0)					; reset timer

		; this checks if the ring counter needs to be blanked
		; for example, this ticks '10' down to ' 9' instead of '19' (yes, this does happen)
		ori.b	#1,(Update_HUD_ring_count).w					; update ring counter
		bset	#7,state_flags(a0)
		move.w	(Ring_count).w,d0
		subq.w	#1,d0
		bmi.s	.killplayer
		beq.s	.resetHUD
		cmpi.w	#10,(Ring_count).w
		beq.s	.resetHUD
		cmpi.w	#100,(Ring_count).w
		bne.s	.updateHUD

.resetHUD
		ori.b	#$80,(Update_HUD_ring_count).w					; re-init ring counter

.updateHUD
		move.w	d0,(Ring_count).w
		sfx	sfx_RingRight							; play ring sound

		; fail
		moveq	#0,d0								; set flag to 0
		rts
; ---------------------------------------------------------------------------

.check
		bclr	#7,state_flags(a0)
		beq.s	.fail
		andi.b	#~(1)&$FF,(Update_HUD_ring_count).w

.fail

		; fail
		moveq	#0,d0								; set flag to 0
		rts
; ---------------------------------------------------------------------------

.killplayer
		movea.w	a0,a2								; load current object to a2
		movea.w	parent4(a0),a1							; a1=character
		movea.w	a1,a0								; load player to a0
		jsr	(Kill_Character).w						; "
		movea.w	a2,a0

		; success
		moveq	#1,d0								; set flag to 1
		rts

; ---------------------------------------------------------------------------
; Boss defeated
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

BossDefeated_StopTimer:
		clr.b	(Update_HUD_timer).w						; stop update time counter

BossDefeated:
		move.w	#$40-1,wait_timer(a0)						; set timer

BossDefeated_NoTime:
		bclr	#render_flags.on_screen,render_flags(a0)
		moveq	#100,d0
		bra.w	HUD_AddToScore							; add 1000 to score

; ---------------------------------------------------------------------------
; Boss flash
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

BossFlash:
		lea	.palram(pc),a1
		lea	.palcycle(pc,d0.w),a2
		bra.s	CopyWordData_3
; ---------------------------------------------------------------------------

.palram
		dc.w (Normal_palette_line_1+$C)&$FFFF
		dc.w (Normal_palette_line_1+$1C)&$FFFF
		dc.w (Normal_palette_line_1+$1E)&$FFFF
.palcycle
		dc.w 8, $866, cBlack
		dc.w $888, $CCC, cWhite

; ---------------------------------------------------------------------------
; Copy colors to the palette line
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

CopyWordData_8:
		movea.w	(a1)+,a3							; load palette address
		move.w	(a2)+,(a3)+							; set color

CopyWordData_7:
		movea.w	(a1)+,a3							; load palette address
		move.w	(a2)+,(a3)+							; set color

CopyWordData_6:
		movea.w	(a1)+,a3							; load palette address
		move.w	(a2)+,(a3)+							; set color

CopyWordData_5:
		movea.w	(a1)+,a3							; load palette address
		move.w	(a2)+,(a3)+							; set color

CopyWordData_4:
		movea.w	(a1)+,a3							; load palette address
		move.w	(a2)+,(a3)+							; set color

CopyWordData_3:
		movea.w	(a1)+,a3							; load palette address
		move.w	(a2)+,(a3)+							; set color

CopyWordData_2:
		movea.w	(a1)+,a3							; load palette address
		move.w	(a2)+,(a3)+							; set color

CopyWordData_1:
		movea.w	(a1)+,a3							; load palette address
		move.w	(a2)+,(a3)+							; set color
		rts

; ---------------------------------------------------------------------------
; Reset players and objects position
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Reset_ObjectsPosition3:
		bsr.s	Reset_ObjectsPosition2
		move.w	(Camera_X_pos).w,(Camera_min_X_pos).w
		move.w	(Camera_X_pos).w,(Camera_max_X_pos).w
		move.w	(Camera_Y_pos).w,(Camera_min_Y_pos).w
		move.w	(Camera_Y_pos).w,(Camera_max_Y_pos).w
		rts
; ---------------------------------------------------------------------------

Reset_ObjectsPosition2:
		sub.w	d1,(Player_1+y_pos).w
		sub.w	d0,(Player_1+x_pos).w
		sub.w	d0,(Camera_X_pos).w
		sub.w	d1,(Camera_Y_pos).w
		sub.w	d0,(Camera_X_pos_copy).w
		sub.w	d1,(Camera_Y_pos_copy).w
		move.w	(Camera_max_Y_pos).w,(Camera_target_max_Y_pos).w
		bra.s	Offset_ObjectsDuringTransition
; ---------------------------------------------------------------------------

Reset_ObjectsPosition:
		move.w	(Camera_X_pos).w,d0

Reset_ObjectsPosition4:
		sub.w	d1,(Player_1+y_pos).w
		sub.w	d0,(Player_1+x_pos).w
		sub.w	d0,(Camera_X_pos).w
		sub.w	d1,(Camera_Y_pos).w
		sub.w	d0,(Camera_X_pos_copy).w
		sub.w	d1,(Camera_Y_pos_copy).w
		sub.w	d0,(Camera_min_X_pos).w
		sub.w	d0,(Camera_max_X_pos).w
		sub.w	d1,(Camera_min_Y_pos).w
		sub.w	d1,(Camera_max_Y_pos).w
		move.w	(Camera_max_Y_pos).w,(Camera_target_max_Y_pos).w

; =============== S U B R O U T I N E =======================================

Offset_ObjectsDuringTransition:

		; all objects in this range
		lea	(Dynamic_object_RAM).w,a1
		moveq	#bytesToXcnt(Dynamic_object_RAM_end-Dynamic_object_RAM,object_size),d2

.check
		tst.l	code_addr(a1)							; is this object slot occupied?
		beq.s	.nextobj							; if not, branch
		btst	#render_flags.level,render_flags(a1)				; is this object using screen coordinates?
		beq.s	.nextobj							; if not, branch
		sub.w	d0,x_pos(a1)
		sub.w	d1,y_pos(a1)

.nextobj
		lea	next_object(a1),a1						; next object slot
		dbf	d2,.check
		rts
