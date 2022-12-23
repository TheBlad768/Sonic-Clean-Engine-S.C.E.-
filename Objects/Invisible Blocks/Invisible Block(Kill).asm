; ---------------------------------------------------------------------------
; Invisible vertical kill block (Object)
; Set no flipX to Up/Down kill
; Set flipX to Left/Right kill
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_Invisible_KillBlock:
		move.l	#Map_InvisibleBlock,mappings(a0)
		move.w	#make_art_tile(ArtTile_Monitors,0,1),art_tile(a0)
		ori.b	#4,render_flags(a0)
		move.w	#$200,priority(a0)
		bset	#7,status(a0)
		move.b	subtype(a0),d0
		move.b	d0,d1
		andi.w	#$F0,d0
		addi.w	#$10,d0
		lsr.w	#1,d0
		move.b	d0,width_pixels(a0)
		andi.w	#$F,d1
		addq.w	#1,d1
		lsl.w	#3,d1
		move.b	d1,height_pixels(a0)
		btst	#0,status(a0)
		beq.s	loc_1F5F0
		move.l	#loc_1F66C,address(a0)
		rts
; ---------------------------------------------------------------------------

loc_1F5F0:
		btst	#1,status(a0)
		beq.s	loc_1F600
		move.l	#loc_1F6D0,address(a0)

locret_1F5FE:
		rts
; ---------------------------------------------------------------------------

loc_1F600:
		move.l	#loc_1F606,address(a0)

loc_1F606:
		moveq	#$B,d1
		add.b	width_pixels(a0),d1
		moveq	#0,d2
		move.b	height_pixels(a0),d2
		move.w	d2,d3
		addq.w	#1,d3
		move.w	x_pos(a0),d4
		jsr	(SolidObjectFull2).w
		move.b	status(a0),d6
		andi.b	#$18,d6
		beq.s	loc_1F64A
		move.b	d6,d0
		andi.b	#8,d0
		beq.s	loc_1F64A
		lea	(Player_1).w,a1
		bsr.w	sub_1F734

loc_1F64A:
		out_of_xrange.w	loc_1EBAA
		tst.w	(Debug_placement_mode).w
		beq.s	locret_1F5FE
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
		andi.w	#3,d6
		beq.s	loc_1F6AE
		move.b	d6,d0
		andi.b	#1,d0
		beq.s	loc_1F6AE
		lea	(Player_1).w,a1
		bsr.s	sub_1F734

loc_1F6AE:
		out_of_xrange.w	loc_1EBAA
		tst.w	(Debug_placement_mode).w
		beq.s	locret_1F742
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
		andi.w	#$C,d6
		beq.s	loc_1F712
		move.b	d6,d0
		andi.b	#4,d0
		beq.s	loc_1F712
		lea	(Player_1).w,a1
		bsr.s	sub_1F734

loc_1F712:
		out_of_xrange.w	loc_1EBAA
		tst.w	(Debug_placement_mode).w
		beq.s	locret_1F742
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

sub_1F734:
		movem.w	d6/a0,-(sp)
		movea.w	a1,a0
		jsr	Kill_Character(pc)
		movem.w	(sp)+,d6/a0

locret_1F742:
		rts
