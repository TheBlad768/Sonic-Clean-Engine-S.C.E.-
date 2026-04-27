; ---------------------------------------------------------------------------
; Spikes (Object)
; ---------------------------------------------------------------------------

; dynamic object variables

	dsset animations								; pretend we're in the RAM

; main
spikes.origX				ds.w 1						; original x-axis position (2 bytes)
spikes.origY				ds.w 1						; original y-axis position (2 bytes)
spikes.retract_offset			ds.w 1						; actual position relative to base position (2 bytes)
spikes.retract_state			ds.w 1						; 0 = positive offset, 1 = original position (2 bytes)
spikes.retract_timer			ds.w 1						; delay, before spikes move again (2 bytes)
spikes.push_timer			ds.w 1						; how many pixels can the spikes be moved (2 bytes)
spikes.push_max				ds.w 1						; how many pixels can the spikes be moved (2 bytes)

; players
spikes.p1_status			ds.b 1						; Sonic's status (1 byte)

	dsreset										; stop pretending and reset the program counter

; =============== S U B R O U T I N E =======================================

Spikes_InitData:

		; height, width
		dc.b 32/2, 32/2		; 0
		dc.b 32/2, 64/2		; 1
		dc.b 32/2, 96/2		; 2
		dc.b 32/2, 128/2	; 3
		dc.b 32/2, 32/2		; 4
		dc.b 64/2, 32/2		; 5
		dc.b 96/2, 32/2		; 6
		dc.b 128/2, 32/2	; 7
; ---------------------------------------------------------------------------

Obj_Spikes:

		; init
		ori.b	#setBit(render_flags.level),render_flags(a0)			; use screen coordinates
		move.b	subtype.byte(a0),d0
		andi.w	#$F0,d0
		lsr.w	#3,d0
		move.w	Spikes_InitData(pc,d0.w),height_pixels(a0)			; set height and width
		move.l	#sub_24090,code_addr(a0)					; face up or down
		move.l	#Map_Spikes,mappings(a0)

		; set priority and art_tile
		move.l	#words_to_long( \
		priority_4, \
			make_art_tile(ArtTile_SpikesSprings,0,FALSE) \
		),priority(a0)

		lsr.w	d0
		move.b	d0,mapping_frame(a0)
		cmpi.b	#4,d0
		blo.s	loc_23FE8
		move.l	#sub_240E2,code_addr(a0)						; sideways

loc_23FE8:
		move.b	status(a0),d0
		tst.b	(Reverse_gravity_flag).w					; are we in reverse gravity mode?
		beq.s	.notgrav							; if not, branch
		eori.b	#setBit(status.npc.y_flip),d0

.notgrav
		andi.b	#setBit(status.npc.y_flip),d0
		beq.s	loc_24002
		move.l	#sub_2413E,code_addr(a0)

loc_24002:
		move.w	#32,spikes.push_max(a0)						; push time
		move.w	x_pos(a0),spikes.origX(a0)
		move.w	y_pos(a0),spikes.origY(a0)
		moveq	#$F,d0
		and.b	subtype.byte(a0),d0
		add.b	d0,d0
		move.b	d0,subtype.byte(a0)
		rts

; =============== S U B R O U T I N E =======================================

sub_24090:										; face up or down
		bsr.w	MoveSpikes
		moveq	#$B,d1
		add.b	width_pixels(a0),d1
		moveq	#0,d2
		move.b	height_pixels(a0),d2
		move.w	d2,d3
		addq.w	#1,d3
		move.w	x_pos(a0),d4
		jsr	(SolidObjectFull).w

		; check standing
		moveq	#standing_mask,d6
		and.b	status(a0),d6							; is Sonic or Tails standing on the object?
		beq.s	.draw								; if not, branch
		move.b	d6,d0
		andi.b	#p1_standing,d0							; is Sonic standing on the object?
		beq.s	.draw								; if not, branch
		lea	(Player_1).w,a1							; a1=character
		bsr.w	Touch_ChkHurt3

.draw
		moveq	#-$80,d0							; round down to nearest $80
		and.w	spikes.origX(a0),d0						; get object position
		jmp	(Sprite_OnScreen_Test2).w

; =============== S U B R O U T I N E =======================================

sub_240E2:										; sideways
		bsr.w	MoveSpikes
		moveq	#$B,d1
		add.b	width_pixels(a0),d1
		moveq	#0,d2
		move.b	height_pixels(a0),d2
		move.w	d2,d3
		addq.w	#1,d3
		move.w	x_pos(a0),d4
		jsr	(SolidObjectFull).w
		swap	d6

		; check side
		andi.w	#touch_side_mask,d6						; are Sonic or Tails pushing against the side?
		beq.s	.draw								; if not, branch
		move.b	d6,d0
		andi.b	#p1_touch_side,d0						; is Sonic pushing against the side?
		beq.s	.draw								; if not, branch
		lea	(Player_1).w,a1							; a1=character
		bsr.s	Touch_ChkHurt3
		bclr	#p1_pushing_bit,status(a0)

.draw
		moveq	#-$80,d0							; round down to nearest $80
		and.w	spikes.origX(a0),d0						; get object position
		jmp	(Sprite_OnScreen_Test2).w

; =============== S U B R O U T I N E =======================================

sub_2413E:
		bsr.s	MoveSpikes
		moveq	#$B,d1
		add.b	width_pixels(a0),d1
		moveq	#0,d2
		move.b	height_pixels(a0),d2
		move.w	d2,d3
		addq.w	#1,d3
		move.w	x_pos(a0),d4
		jsr	(SolidObjectFull).w
		swap	d6

		; check bottom
		andi.w	#touch_bottom_mask,d6						; are Sonic or Tails touching the bottom?
		beq.s	.draw								; if not, branch
		move.b	d6,d0
		andi.b	#p1_touch_bottom,d0						; is Sonic touching the bottom?
		beq.s	.draw								; if not, branch
		lea	(Player_1).w,a1							; a1=character
		bsr.s	Touch_ChkHurt3

.draw
		moveq	#-$80,d0							; round down to nearest $80
		and.w	spikes.origX(a0),d0						; get object position
		jmp	(Sprite_OnScreen_Test2).w
; ---------------------------------------------------------------------------

Obj_Spikes_end

; =============== S U B R O U T I N E =======================================

Touch_ChkHurt3:
		tst.w	(Debug_placement_mode).w					; is debug mode on?
		bne.s	.return								; if yes, branch
		tst.b	object_control(a1)
		bmi.s	.return
		btst	#status_secondary.invincible,status_secondary(a1)		; is character invincible?
		bne.s	.return								; if yes, branch
		tst.b	invulnerability_timer(a1)					; is character invulnerable?
		bne.s	.return								; if yes, branch
		cmpi.b	#PlayerID_Hurt,routine(a1)					; is the character hurt, dying, etc. ?
		bhs.s	.return								; if yes, branch

		; hurt player
		move.l	y_pos(a1),d3
		move.w	y_vel(a1),d0
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d3
		move.l	d3,y_pos(a1)
		movea.w	a0,a2								; save current object
		movea.w	a1,a0								; a0=character
		jsr	HurtCharacter(pc)
		movea.w	a2,a0								; restore current object

.return
		rts

; =============== S U B R O U T I N E =======================================

MoveSpikes:
		moveq	#0,d0
		move.b	subtype.byte(a0),d0
		beq.s	.return								; 0 (static)
		jmp	.index-2(pc,d0.w)
; ---------------------------------------------------------------------------

.index
		bra.s	.vertical							; 2
		bra.s	.horizontal							; 4

; =============== S U B R O U T I N E =======================================

.push											; 6 (pushable spikes) ; FBZ
		moveq	#pushing_mask,d3
		and.b	status(a0),d3
		beq.s	.notp1
		move.w	x_pos(a0),d2
		lea	(Player_1).w,a1							; a1=character
		move.b	spikes.p1_status(a0),d0
		moveq	#p1_pushing_bit,d6
		bsr.s	.movepush

.notp1
		move.b	(Player_1+status).w,spikes.p1_status(a0)
		rts

; =============== S U B R O U T I N E =======================================

.movepush
		btst	d6,d3								; is Sonic or Tails pushing the object?
		beq.s	.return								; if not, branch
		cmp.w	x_pos(a1),d2
		blo.s	.return
		btst	#status.player.pushing,d0
		beq.s	.return

		; wait
		subq.w	#1,spikes.push_timer(a0)
		bpl.s	.return
		move.w	#16,spikes.push_timer(a0)

		; push max
		tst.w	spikes.push_max(a0)
		beq.s	.return
		subq.w	#1,spikes.push_max(a0)
		addq.w	#1,x_pos(a0)
		addq.w	#1,x_pos(a1)

.return
		rts

; =============== S U B R O U T I N E =======================================

.vertical
		bsr.s	MoveSpikes_Delay
		moveq	#0,d0
		move.b	spikes.retract_offset(a0),d0
		add.w	spikes.origY(a0),d0						; apply offset to y-position
		move.w	d0,y_pos(a0)
		rts

; =============== S U B R O U T I N E =======================================

.horizontal
		bsr.s	MoveSpikes_Delay
		moveq	#0,d0
		move.b	spikes.retract_offset(a0),d0
		add.w	spikes.origX(a0),d0						; apply offset to x-position
		move.w	d0,x_pos(a0)
		rts

; =============== S U B R O U T I N E =======================================

MoveSpikes_Delay:
		tst.w	spikes.retract_timer(a0)					; is it time for spikes to move again?
		beq.s	.chkdir								; if yes, branch
		subq.w	#1,spikes.retract_timer(a0)					; else, decrement timer
		bne.s	.return								; branch, if timer didn't reach 0
		tst.b	render_flags(a0)						; are spikes on screen?
		bpl.s	.return								; if not, branch
		sfx	sfx_SpikeMove,1							; play spike movement sount
; ---------------------------------------------------------------------------

.chkdir
		tst.w	spikes.retract_state(a0)					; do spikes need to move away from initial position?
		beq.s	.retract							; if yes, branch
		subi.w	#$800,spikes.retract_offset(a0)					; subtract 8 pixels from offset
		bhs.s	.return								; branch, if offset is not yet 0
		clr.l	spikes.retract_offset(a0)					; switch state
		move.w	#1*60,spikes.retract_timer(a0)					; reset timer
		rts
; ---------------------------------------------------------------------------

.retract
		addi.w	#$800,spikes.retract_offset(a0)					; add 8 pixels to offset
		cmpi.w	#$2000,spikes.retract_offset(a0)				; is offset the width of one spike block (32 pixels)?
		blo.s	.return								; if not, branch
		move.w	#$2000,spikes.retract_offset(a0)
		move.w	#1,spikes.retract_state(a0)					; switch state
		move.w	#1*60,spikes.retract_timer(a0)					; reset timer

.return
		rts
; ---------------------------------------------------------------------------

		; mappings
		include "Objects/Main/Spikes/Object Data/Map - Spikes.asm"
