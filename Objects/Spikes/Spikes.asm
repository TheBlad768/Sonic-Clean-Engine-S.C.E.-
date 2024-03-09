; ---------------------------------------------------------------------------
; Spikes (Object)
; ---------------------------------------------------------------------------

byte_23F74:				; width, height
		dc.b 32/2, 32/2	; 0
		dc.b 64/2, 32/2	; 1
		dc.b 96/2, 32/2	; 2
		dc.b 128/2, 32/2	; 3
		dc.b 32/2, 32/2	; 4
		dc.b 32/2, 64/2	; 5
		dc.b 32/2, 96/2	; 6
		dc.b 32/2, 128/2	; 7

; =============== S U B R O U T I N E =======================================

Obj_Spikes:
		ori.b	#4,render_flags(a0)
		move.w	#$200,priority(a0)
		move.b	subtype(a0),d0
		andi.w	#$F0,d0
		lsr.w	#3,d0
		lea	byte_23F74(pc,d0.w),a1
		move.b	(a1)+,width_pixels(a0)
		move.b	(a1)+,height_pixels(a0)
		move.l	#loc_24090,address(a0)
		move.l	#Map_Spikes,mappings(a0)
		move.w	#make_art_tile(ArtTile_SpikesSprings+8,0,0),art_tile(a0)
		lsr.w	d0
		move.b	d0,mapping_frame(a0)
		cmpi.b	#4,d0
		blo.s		loc_23FE8
		move.l	#loc_240E2,address(a0)
		move.w	#make_art_tile(ArtTile_SpikesSprings,0,0),art_tile(a0)

loc_23FE8:
		move.b	status(a0),d0
		tst.b	(Reverse_gravity_flag).w
		beq.s	loc_23FF6
		eori.b	#2,d0

loc_23FF6:
		andi.b	#2,d0
		beq.s	loc_24002
		move.l	#loc_2413E,address(a0)

loc_24002:
		move.w	#$20,objoff_3C(a0)
		move.w	x_pos(a0),objoff_30(a0)
		move.w	y_pos(a0),objoff_32(a0)
		moveq	#$F,d0
		and.b	subtype(a0),d0
		add.b	d0,d0
		move.b	d0,subtype(a0)
		rts
; ---------------------------------------------------------------------------

loc_24090:									;  face up or down
		bsr.w	sub_242B6
		moveq	#$B,d1
		add.b	width_pixels(a0),d1
		moveq	#0,d2
		move.b	height_pixels(a0),d2
		move.w	d2,d3
		addq.w	#1,d3
		move.w	x_pos(a0),d4
		jsr	SolidObjectFull(pc)
		moveq	#standing_mask,d6
		and.b	status(a0),d6					; is Sonic or Tails standing on the object?
		beq.s	loc_240D8					; if not, branch
		move.b	d6,d0
		andi.b	#p1_standing,d0
		beq.s	loc_240D8
		lea	(Player_1).w,a1
		bsr.w	sub_24280

loc_240D8:
		move.w	objoff_30(a0),d0
		jmp	(Sprite_OnScreen_Test2).w
; ---------------------------------------------------------------------------

loc_240E2:									; sideways
		bsr.w	sub_242B6
		moveq	#$B,d1
		add.b	width_pixels(a0),d1
		moveq	#0,d2
		move.b	height_pixels(a0),d2
		move.w	d2,d3
		addq.w	#1,d3
		move.w	x_pos(a0),d4
		jsr	SolidObjectFull(pc)
		swap	d6
		andi.w	#touch_side_mask,d6
		beq.s	loc_24134
		move.b	d6,d0
		andi.b	#p1_touch_side,d0
		beq.s	loc_24134
		lea	(Player_1).w,a1
		bsr.s	sub_24280
		bclr	#p1_pushing_bit,status(a0)

loc_24134:
		move.w	objoff_30(a0),d0
		jmp	(Sprite_OnScreen_Test2).w
; ---------------------------------------------------------------------------

loc_2413E:
		bsr.s	sub_242B6
		moveq	#$B,d1
		add.b	width_pixels(a0),d1
		moveq	#0,d2
		move.b	height_pixels(a0),d2
		move.w	d2,d3
		addq.w	#1,d3
		move.w	x_pos(a0),d4
		jsr	SolidObjectFull(pc)
		swap	d6
		andi.w	#touch_bottom_mask,d6
		beq.s	loc_24184
		move.b	d6,d0
		andi.b	#p1_touch_bottom,d0
		beq.s	loc_24184
		lea	(Player_1).w,a1
		bsr.s	sub_24280

loc_24184:
		move.w	objoff_30(a0),d0
		jmp	(Sprite_OnScreen_Test2).w
; ---------------------------------------------------------------------------

Obj_Spikes_end

; =============== S U B R O U T I N E =======================================

sub_24280:
		tst.w	(Debug_placement_mode).w
		bne.s	.return
		btst	#Status_Invincible,status_secondary(a1)
		bne.s	.return
		tst.b	invulnerability_timer(a1)
		bne.s	.return
		cmpi.b	#id_SonicHurt,routine(a1)
		bhs.s	.return
		move.l	y_pos(a1),d3
		move.w	y_vel(a1),d0
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d3
		move.l	d3,y_pos(a1)
		movea.w	a0,a2
		movea.w	a1,a0
		jsr	HurtCharacter(pc)
		movea.w	a2,a0

.return
		rts

; =============== S U B R O U T I N E =======================================

sub_242B6:
		moveq	#0,d0
		move.b	subtype(a0),d0
		move.w	off_242C4(pc,d0.w),d0
		jmp	off_242C4(pc,d0.w)
; ---------------------------------------------------------------------------

off_242C4: offsetTable
		offsetTableEntry.w locret_242CC	; 0
		offsetTableEntry.w loc_242CE		; 2
		offsetTableEntry.w loc_242E2		; 4
		offsetTableEntry.w loc_24356		; 6
; ---------------------------------------------------------------------------

loc_242CE:
		bsr.s	sub_242F6
		moveq	#0,d0
		move.b	objoff_34(a0),d0
		add.w	objoff_32(a0),d0
		move.w	d0,y_pos(a0)

locret_242CC:
		rts
; ---------------------------------------------------------------------------

loc_242E2:
		bsr.s	sub_242F6
		moveq	#0,d0
		move.b	objoff_34(a0),d0
		add.w	objoff_30(a0),d0
		move.w	d0,x_pos(a0)
		rts

; =============== S U B R O U T I N E =======================================

sub_242F6:
		tst.w	objoff_38(a0)
		beq.s	loc_24312
		subq.w	#1,objoff_38(a0)
		bne.s	locret_24354
		tst.b	render_flags(a0)
		bpl.s	locret_24354
		sfx	sfx_SpikeMove,1
; ---------------------------------------------------------------------------

loc_24312:
		tst.w	objoff_36(a0)
		beq.s	loc_24334
		subi.w	#$800,objoff_34(a0)
		bcc.s	locret_24354
		clr.l	objoff_34(a0)
		move.w	#60,objoff_38(a0)
		rts
; ---------------------------------------------------------------------------

loc_24334:
		addi.w	#$800,objoff_34(a0)
		cmpi.w	#$2000,objoff_34(a0)
		blo.s		locret_24354
		move.w	#$2000,objoff_34(a0)
		move.w	#1,objoff_36(a0)
		move.w	#60,objoff_38(a0)

locret_24354:
		rts
; ---------------------------------------------------------------------------

loc_24356:
		moveq	#pushing_mask,d3
		and.b	status(a0),d3
		beq.s	loc_2437C
		move.w	x_pos(a0),d2
		lea	(Player_1).w,a1
		move.b	objoff_3E(a0),d0
		moveq	#p1_pushing_bit,d6
		bsr.s	sub_2438A

loc_2437C:
		move.b	(Player_1+status).w,objoff_3E(a0)
		rts

; =============== S U B R O U T I N E =======================================

sub_2438A:
		btst	d6,d3
		beq.s	.return
		cmp.w	x_pos(a1),d2
		blo.s		.return
		btst	#Status_Push,d0
		beq.s	.return

		; wait
		subq.w	#1,objoff_3A(a0)
		bpl.s	.return
		move.w	#16,objoff_3A(a0)

		tst.w	objoff_3C(a0)
		beq.s	.return
		subq.w	#1,objoff_3C(a0)
		addq.w	#1,x_pos(a0)
		addq.w	#1,x_pos(a1)

.return
		rts
; ---------------------------------------------------------------------------

		include "Objects/Spikes/Object Data/Map - Spikes.asm"
