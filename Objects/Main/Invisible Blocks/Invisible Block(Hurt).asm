; ---------------------------------------------------------------------------
; Invisible horizontal shock block (Object)
; Set no flipX to Up/Down hurt
; Set flipX to Left/Right hurt
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_Invisible_ShockBlock:
		bset	#shield_reaction.lightning_shield,shield_reaction(a0)
		bra.s	Obj_Invisible_HurtBlock

; ---------------------------------------------------------------------------
; Invisible horizontal lava block (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_Invisible_LavaBlock:
		bset	#shield_reaction.fire_shield,shield_reaction(a0)

; ---------------------------------------------------------------------------
; Invisible horizontal hurt block (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_Invisible_HurtBlock:

		; init
		move.l	#Map_InvisibleBlock,mappings(a0)
		ori.b	#setBit(render_flags.level),render_flags(a0)			; use screen coordinates

		; set priority and art_tile
		move.l	#words_to_long( \
		priority_4, \
			make_art_tile(ArtTile_Monitors,0,1) \
		),priority(a0)

		bset	#status.npc.no_balancing,status(a0)				; disable player's balance animation

		; set
		move.b	subtype(a0),d0
		move.b	d0,d1
		andi.w	#$F0,d0
		addi.w	#$10,d0
		lsr.w	d0
		move.b	d0,width_pixels(a0)
		andi.w	#$F,d1
		addq.w	#1,d1
		lsl.w	#3,d1
		move.b	d1,height_pixels(a0)

		; check
		btst	#status.npc.x_flip,status(a0)					; is it flipx?
		beq.s	loc_1F448							; if not, branch
		move.l	#loc_1F4C4,address(a0)						; set side hurt
		rts
; ---------------------------------------------------------------------------

loc_1F448:
		btst	#status.npc.y_flip,status(a0)					; is it flipy?
		beq.s	loc_1F458							; if not, branch
		move.l	#loc_1F528,address(a0)						; set bottom hurt

locret_1F456:
		rts
; ---------------------------------------------------------------------------

loc_1F458:
		move.l	#loc_1F45E,address(a0)						; set top hurt

loc_1F45E:
		moveq	#$B,d1
		add.b	width_pixels(a0),d1
		moveq	#0,d2
		move.b	height_pixels(a0),d2
		move.w	d2,d3
		addq.w	#1,d3
		move.w	x_pos(a0),d4
		jsr	(SolidObjectFull2).w
		moveq	#standing_mask,d6
		and.b	status(a0),d6							; is Sonic or Tails standing on the object?
		beq.s	loc_1F4A2							; if not, branch
		move.b	d6,d0
		andi.b	#p1_standing,d0
		beq.s	loc_1F4A2
		lea	(Player_1).w,a1							; a1=character
		bsr.w	sub_1F58C

loc_1F4A2:
		out_of_xrange.w	Obj_Invisible_SolidBlock.offscreen
		tst.w	(Debug_placement_mode).w					; is debug mode on?
		beq.s	locret_1F456							; if not, branch
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

loc_1F4C4:
		moveq	#$B,d1
		add.b	width_pixels(a0),d1
		moveq	#0,d2
		move.b	height_pixels(a0),d2
		move.w	d2,d3
		addq.w	#1,d3
		move.w	x_pos(a0),d4
		jsr	(SolidObjectFull2).w
		swap	d6
		andi.w	#touch_side_mask,d6
		beq.s	loc_1F506
		move.b	d6,d0
		andi.b	#p1_touch_side,d0
		beq.s	loc_1F506
		lea	(Player_1).w,a1							; a1=character
		bsr.s	sub_1F58C

loc_1F506:
		out_of_xrange.w	Obj_Invisible_SolidBlock.offscreen
		tst.w	(Debug_placement_mode).w					; is debug mode on?
		beq.s	locret_1F59E							; if not, branch
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

loc_1F528:
		moveq	#$B,d1
		add.b	width_pixels(a0),d1
		moveq	#0,d2
		move.b	height_pixels(a0),d2
		move.w	d2,d3
		addq.w	#1,d3
		move.w	x_pos(a0),d4
		jsr	(SolidObjectFull2).w
		swap	d6
		andi.w	#touch_bottom_mask,d6
		beq.s	loc_1F56A
		move.b	d6,d0
		andi.b	#p1_touch_bottom,d0
		beq.s	loc_1F56A
		lea	(Player_1).w,a1							; a1=character
		bsr.s	sub_1F58C

loc_1F56A:
		out_of_xrange.w	Obj_Invisible_SolidBlock.offscreen
		tst.w	(Debug_placement_mode).w					; is debug mode on?
		beq.s	locret_1F59E							; if not, branch
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

sub_1F58C:

		; does the player have any shields or is invincible?
		moveq	#signextendB( \
			setBit(status_secondary.shield) | \
			setBit(status_secondary.invincible) | \
			setBit(status_secondary.fire_shield) | \
			setBit(status_secondary.lightning_shield) | \
			setBit(status_secondary.bubble_shield) \
		),d0

		and.b	shield_reaction(a0),d0
		and.b	status_secondary(a1),d0
		bne.s	locret_1F59E							; if so, branch
		bra.w	Touch_ChkHurt3
; ---------------------------------------------------------------------------

locret_1F59E:
		rts
