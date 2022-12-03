; ---------------------------------------------------------------------------
; AutoSpin (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_AutoSpin:
		move.l	#Map_PathSwap,mappings(a0)
		move.w	#make_art_tile(ArtTile_Ring,0,0),art_tile(a0)
		ori.b	#4,render_flags(a0)
		move.w	#$280,priority(a0)
		move.w	#bytes_to_word(256/2,256/2),height_pixels(a0)		; set height and width
		move.b	subtype(a0),d0
		btst	#2,d0
		beq.s	loc_1E85C
		andi.w	#7,d0
		move.b	d0,mapping_frame(a0)
		andi.w	#3,d0
		add.w	d0,d0
		move.w	word_1E854(pc,d0.w),$32(a0)
		move.w	y_pos(a0),d1
		lea	(Player_1).w,a1
		cmp.w	y_pos(a1),d1
		bcc.s	+
		move.b	#1,$34(a0)
+		move.l	#loc_1E9E6,address(a0)
		bra.w	loc_1E9E6
; ---------------------------------------------------------------------------

word_1E854:
		dc.w $20
		dc.w $40
		dc.w $80
		dc.w $100
; ---------------------------------------------------------------------------

loc_1E85C:
		andi.w	#3,d0
		move.b	d0,mapping_frame(a0)
		add.w	d0,d0
		move.w	word_1E854(pc,d0.w),$32(a0)
		move.w	x_pos(a0),d1
		lea	(Player_1).w,a1
		cmp.w	x_pos(a1),d1
		bcc.s	loc_1E890
		move.b	#1,$34(a0)

loc_1E890:
		move.l	#loc_1E896,address(a0)

loc_1E896:
		tst.w	(Debug_placement_mode).w
		bne.s	loc_1E8C0
		move.w	x_pos(a0),d1
		lea	$34(a0),a2
		lea	(Player_1).w,a1
		bsr.s	sub_1E8C6
		jmp	(Delete_Sprite_If_Not_In_Range).w
; ---------------------------------------------------------------------------

loc_1E8C0:
		jmp	(Sprite_OnScreen_Test).w

; =============== S U B R O U T I N E =======================================

sub_1E8C6:
		tst.b	(a2)+
		bne.s	loc_1E944
		cmp.w	x_pos(a1),d1
		bhi.w	locret_1E9B4
		move.b	#1,-1(a2)
		move.w	y_pos(a0),d2
		move.w	d2,d3
		move.w	$32(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	y_pos(a1),d4
		cmp.w	d2,d4
		bcs.w	locret_1E9B4
		cmp.w	d3,d4
		bcc.w	locret_1E9B4
		btst	#5,subtype(a0)
		beq.s	loc_1E908
		btst	#Status_InAir,status(a1)
		bne.w	locret_1E9B4

loc_1E908:
		btst	#0,render_flags(a0)
		bne.s	loc_1E934
		btst	#4,subtype(a0)
		bne.s	loc_1E930
		move.w	#$580,ground_vel(a1)
		move.b	#1,spin_dash_flag(a1)
		tst.b	subtype(a0)
		bpl.s	loc_1E930
		move.b	#$81,spin_dash_flag(a1)

loc_1E930:
		bra.s	loc_1E9B6
; ---------------------------------------------------------------------------

loc_1E934:
		btst	#4,subtype(a0)
		bne.s	locret_1E9B4
		clr.b	spin_dash_flag(a1)
		rts
; ---------------------------------------------------------------------------

loc_1E944:
		cmp.w	x_pos(a1),d1
		bls.s		locret_1E9B4
		clr.b	-1(a2)
		move.w	y_pos(a0),d2
		move.w	d2,d3
		move.w	$32(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	y_pos(a1),d4
		cmp.w	d2,d4
		bcs.s	locret_1E9B4
		cmp.w	d3,d4
		bcc.s	locret_1E9B4
		btst	#5,subtype(a0)
		beq.s	loc_1E97C
		btst	#Status_InAir,status(a1)
		bne.s	locret_1E9B4

loc_1E97C:
		btst	#0,render_flags(a0)
		beq.s	loc_1E9A6
		btst	#4,subtype(a0)
		bne.s	loc_1E9A4
		move.w	#-$580,ground_vel(a1)
		move.b	#1,spin_dash_flag(a1)
		tst.b	subtype(a0)
		bpl.s	loc_1E9A4
		move.b	#$81,spin_dash_flag(a1)

loc_1E9A4:
		bra.s	loc_1E9B6
; ---------------------------------------------------------------------------

loc_1E9A6:
		btst	#4,subtype(a0)
		bne.s	locret_1E9B4
		clr.b	spin_dash_flag(a1)

locret_1E9B4:
		rts
; ---------------------------------------------------------------------------

loc_1E9B6:
		btst	#Status_Roll,status(a1)
		beq.s	loc_1E9C0
		rts
; ---------------------------------------------------------------------------

loc_1E9C0:
		bset	#Status_Roll,status(a1)
		move.w	#bytes_to_word(28/2,14/2),y_radius(a1)	; set y_radius and x_radius
		move.b	#id_Roll,anim(a1)
		addq.w	#5,y_pos(a1)
		sfx	sfx_Roll,1
; ---------------------------------------------------------------------------

loc_1E9E6:
		tst.w	(Debug_placement_mode).w
		bne.s	loc_1EA0E
		move.w	y_pos(a0),d1
		lea	$34(a0),a2
		lea	(Player_1).w,a1
		bsr.s	sub_1EA14
		jmp	(Delete_Sprite_If_Not_In_Range).w
; ---------------------------------------------------------------------------

loc_1EA0E:
		jmp	(Sprite_OnScreen_Test).w

; =============== S U B R O U T I N E =======================================

sub_1EA14:
		tst.b	(a2)+
		bne.w	loc_1EAB0
		cmp.w	y_pos(a1),d1
		bhi.w	locret_1EB30
		move.b	#1,-1(a2)
		move.w	x_pos(a0),d2
		move.w	d2,d3
		move.w	$32(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	x_pos(a1),d4
		cmp.w	d2,d4
		bcs.w	locret_1EB30
		cmp.w	d3,d4
		bcc.w	locret_1EB30
		btst	#5,subtype(a0)
		beq.s	loc_1EA58
		btst	#Status_InAir,status(a1)
		bne.w	locret_1EB30

loc_1EA58:
		btst	#0,render_flags(a0)
		bne.s	loc_1EA9E
		btst	#4,subtype(a0)
		bne.s	loc_1EA9A
		move.b	#1,spin_dash_flag(a1)
		tst.b	subtype(a0)
		bpl.s	loc_1EA7A
		move.b	#$81,spin_dash_flag(a1)

loc_1EA7A:
		btst	#6,subtype(a0)
		beq.s	loc_1EA9A
		bclr	#Status_InAir,status(a1)
		move.b	#$40,angle(a1)
		move.w	y_vel(a1),ground_vel(a1)
		clr.w	x_vel(a1)

loc_1EA9A:
		bra.w	loc_1E9B6
; ---------------------------------------------------------------------------

loc_1EA9E:
		btst	#4,subtype(a0)
		bne.w	locret_1EB30
		clr.b	spin_dash_flag(a1)
		rts
; ---------------------------------------------------------------------------

loc_1EAB0:
		cmp.w	y_pos(a1),d1
		bls.s		locret_1EB30
		clr.b	-1(a2)
		move.w	x_pos(a0),d2
		move.w	d2,d3
		move.w	$32(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	x_pos(a1),d4
		cmp.w	d2,d4
		bcs.s	locret_1EB30
		cmp.w	d3,d4
		bcc.s	locret_1EB30
		btst	#5,subtype(a0)
		beq.s	loc_1EAE8
		btst	#Status_InAir,status(a1)
		bne.s	locret_1EB30

loc_1EAE8:
		btst	#0,render_flags(a0)
		beq.s	loc_1EB22
		btst	#4,subtype(a0)
		bne.s	loc_1EB1E
		move.b	#1,spin_dash_flag(a1)
		tst.b	subtype(a0)
		bpl.s	loc_1EB0A
		move.b	#$81,spin_dash_flag(a1)

loc_1EB0A:
		btst	#6,subtype(a0)
		beq.s	loc_1EB1E
		bclr	#Status_InAir,status(a1)
		move.b	#$40,angle(a1)

loc_1EB1E:
		bra.w	loc_1E9B6
; ---------------------------------------------------------------------------

loc_1EB22:
		btst	#4,subtype(a0)
		bne.s	locret_1EB30
		clr.b	spin_dash_flag(a1)

locret_1EB30:
		rts
