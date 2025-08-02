; ---------------------------------------------------------------------------
; Invisible vertical kill block (Object)
; Set no flipX to Up/Down kill
; Set flipX to Left/Right kill
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_Invisible_KillBlock:

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
		btst	#status.npc.x_flip,status(a0)					; is it flipx?
		beq.s	loc_1F5F0							; if not, branch
		move.l	#loc_1F66C,address(a0)						; set side kill
		rts
; ---------------------------------------------------------------------------

loc_1F5F0:
		btst	#status.npc.y_flip,status(a0)					; is it flipy?
		beq.s	loc_1F600							; if not, branch
		move.l	#loc_1F6D0,address(a0)						; set bottom kill

locret_1F5FE:
		rts
; ---------------------------------------------------------------------------

loc_1F600:
		move.l	#loc_1F606,address(a0)						; set top kill

loc_1F606:
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
		beq.s	loc_1F64A							; if not, branch
		move.b	d6,d0
		andi.b	#p1_standing,d0
		beq.s	loc_1F64A
		lea	(Player_1).w,a1							; a1=character
		bsr.w	sub_1F734

loc_1F64A:
		out_of_xrange.w	Obj_Invisible_SolidBlock.offscreen
		tst.w	(Debug_placement_mode).w					; is debug mode on?
		beq.s	locret_1F5FE							; if not, branch
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

loc_1F66C:
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
		beq.s	loc_1F6AE
		move.b	d6,d0
		andi.b	#p1_touch_side,d0
		beq.s	loc_1F6AE
		lea	(Player_1).w,a1							; a1=character
		bsr.s	sub_1F734

loc_1F6AE:
		out_of_xrange.w	Obj_Invisible_SolidBlock.offscreen
		tst.w	(Debug_placement_mode).w					; is debug mode on?
		beq.s	locret_1F742							; if not, branch
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

loc_1F6D0:
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
		beq.s	loc_1F712
		move.b	d6,d0
		andi.b	#p1_touch_bottom,d0
		beq.s	loc_1F712
		lea	(Player_1).w,a1							; a1=character
		bsr.s	sub_1F734

loc_1F712:
		out_of_xrange.w	Obj_Invisible_SolidBlock.offscreen
		tst.w	(Debug_placement_mode).w					; is debug mode on?
		beq.s	locret_1F742							; if not, branch
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

sub_1F734:
		movem.w	d6/a0,-(sp)
		movea.w	a0,a2								; load current object to a2
		movea.w	a1,a0								; load player to a0
		jsr	Kill_Character(pc)						; "
		movem.w	(sp)+,d6/a0

locret_1F742:
		rts
