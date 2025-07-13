; ---------------------------------------------------------------------------
; AutoSpin (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_AutoSpin:

		; init
		move.l	#Map_PathSwap,mappings(a0)
		move.w	#make_art_tile(ArtTile_Ring,0,0),art_tile(a0)
		ori.b	#setBit(render_flags.level),render_flags(a0)			; use screen coordinates
		move.l	#bytes_word_to_long(256/2,256/2,priority_5),height_pixels(a0)	; set height, width and priority

		; check
		move.b	subtype(a0),d0
		btst	#2,d0
		beq.s	AutoSpin_CheckX
		andi.w	#7,d0
		move.b	d0,mapping_frame(a0)
		andi.w	#3,d0
		add.w	d0,d0
		move.w	word_1E854(pc,d0.w),objoff_32(a0)
		move.w	y_pos(a0),d1
		lea	(Player_1).w,a1							; a1=character
		cmp.w	y_pos(a1),d1
		bhs.s	loc_1E84A
		move.b	#1,objoff_34(a0)

loc_1E84A:

		; next
		lea	AutoSpin_MainY(pc),a1
		move.l	a1,address(a0)
		jmp	(a1)
; ---------------------------------------------------------------------------

word_1E854:
		dc.w $20	; 0
		dc.w $40	; 1
		dc.w $80	; 2
		dc.w $100	; 3
; ---------------------------------------------------------------------------

AutoSpin_CheckX:
		andi.w	#3,d0
		move.b	d0,mapping_frame(a0)
		add.w	d0,d0
		move.w	word_1E854(pc,d0.w),objoff_32(a0)
		move.w	x_pos(a0),d1
		lea	(Player_1).w,a1							; a1=character
		cmp.w	x_pos(a1),d1
		bhs.s	loc_1E890
		move.b	#1,objoff_34(a0)

loc_1E890:
		move.l	#AutoSpin_MainX,address(a0)

; =============== S U B R O U T I N E =======================================

AutoSpin_MainX:
		tst.w	(Debug_placement_mode).w					; is debug mode on?
		bne.s	loc_1E8C0							; if yes, branch
		move.w	x_pos(a0),d1
		lea	objoff_34(a0),a2
		lea	(Player_1).w,a1							; a1=character
		bsr.s	sub_1E8C6
		jmp	(Delete_Sprite_If_Not_In_Range).w
; ---------------------------------------------------------------------------

loc_1E8C0:
		jmp	(Sprite_OnScreen_Test).w

; =============== S U B R O U T I N E =======================================

sub_1E8C6:
		tst.b	(a2)+
		bne.s	AutoSpin_MainX_Alt
		cmp.w	x_pos(a1),d1
		bhi.s	locret_1E942
		move.b	#1,-1(a2)
		move.w	y_pos(a0),d2
		move.w	d2,d3
		move.w	objoff_32(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	y_pos(a1),d4
		cmp.w	d2,d4
		blo.s	locret_1E942
		cmp.w	d3,d4
		bhs.s	locret_1E942
		btst	#5,subtype(a0)
		beq.s	loc_1E908
		btst	#status.player.in_air,status(a1)				; is the player in the air?
		bne.s	locret_1E942							; if yes, branch

loc_1E908:
		btst	#render_flags.x_flip,render_flags(a0)
		bne.s	loc_1E934
		btst	#4,subtype(a0)
		bne.s	loc_1E930
		move.w	#$580,ground_vel(a1)
		move.b	#1,spin_dash_flag(a1)
		tst.b	subtype(a0)
		bpl.s	loc_1E930
		move.b	#$81,spin_dash_flag(a1)

loc_1E930:
		bra.s	sub_1E9B6
; ---------------------------------------------------------------------------

loc_1E934:
		btst	#4,subtype(a0)
		bne.s	locret_1E942
		clr.b	spin_dash_flag(a1)

locret_1E942:
		rts

; =============== S U B R O U T I N E =======================================

AutoSpin_MainX_Alt:
		cmp.w	x_pos(a1),d1
		bls.s	locret_1E942
		clr.b	-1(a2)
		move.w	y_pos(a0),d2
		move.w	d2,d3
		move.w	objoff_32(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	y_pos(a1),d4
		cmp.w	d2,d4
		blo.s	locret_1E9B4
		cmp.w	d3,d4
		bhs.s	locret_1E9B4
		btst	#5,subtype(a0)
		beq.s	loc_1E97C
		btst	#status.player.in_air,status(a1)				; is the player in the air?
		bne.s	locret_1E9B4							; if yes, branch

loc_1E97C:
		btst	#render_flags.x_flip,render_flags(a0)
		beq.s	loc_1E9A6
		btst	#4,subtype(a0)
		bne.s	loc_1E9A4
		move.w	#-$580,ground_vel(a1)
		move.b	#1,spin_dash_flag(a1)
		tst.b	subtype(a0)
		bpl.s	loc_1E9A4
		move.b	#$81,spin_dash_flag(a1)

loc_1E9A4:
		bra.s	sub_1E9B6
; ---------------------------------------------------------------------------

loc_1E9A6:
		btst	#4,subtype(a0)
		bne.s	locret_1E9B4
		clr.b	spin_dash_flag(a1)

locret_1E9B4:
		rts

; =============== S U B R O U T I N E =======================================

sub_1E9B6:
		btst	#status.player.rolling,status(a1)
		beq.s	loc_1E9C0
		rts
; ---------------------------------------------------------------------------

loc_1E9C0:
		bset	#status.player.rolling,status(a1)
		move.w	#bytes_to_word(28/2,14/2),y_radius(a1)				; set y_radius and x_radius
		move.b	#AniIDSonAni_Roll,anim(a1)
		addq.w	#5,y_pos(a1)
		sfx	sfx_Roll,1

; =============== S U B R O U T I N E =======================================

AutoSpin_MainY:
		tst.w	(Debug_placement_mode).w					; is debug mode on?
		bne.s	loc_1EA0E							; if yes, branch
		move.w	y_pos(a0),d1
		lea	objoff_34(a0),a2
		lea	(Player_1).w,a1							; a1=character
		bsr.s	sub_1EA14
		jmp	(Delete_Sprite_If_Not_In_Range).w
; ---------------------------------------------------------------------------

loc_1EA0E:
		jmp	(Sprite_OnScreen_Test).w

; =============== S U B R O U T I N E =======================================

sub_1EA14:
		tst.b	(a2)+
		bne.w	AutoSpin_MainY_Alt
		cmp.w	y_pos(a1),d1
		bhi.w	locret_1EAAE
		move.b	#1,-1(a2)
		move.w	x_pos(a0),d2
		move.w	d2,d3
		move.w	objoff_32(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	x_pos(a1),d4
		cmp.w	d2,d4
		blo.s	locret_1EAAE
		cmp.w	d3,d4
		bhs.s	locret_1EAAE
		btst	#5,subtype(a0)
		beq.s	loc_1EA58
		btst	#status.player.in_air,status(a1)				; is the player in the air?
		bne.s	locret_1EAAE							; if yes, branch

loc_1EA58:
		btst	#render_flags.x_flip,render_flags(a0)
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
		bclr	#status.player.in_air,status(a1)
		move.b	#$40,angle(a1)
		move.w	y_vel(a1),ground_vel(a1)
		clr.w	x_vel(a1)

loc_1EA9A:
		bra.w	sub_1E9B6
; ---------------------------------------------------------------------------

loc_1EA9E:
		btst	#4,subtype(a0)
		bne.s	locret_1EAAE
		clr.b	spin_dash_flag(a1)

locret_1EAAE:
		rts

; =============== S U B R O U T I N E =======================================

AutoSpin_MainY_Alt:
		cmp.w	y_pos(a1),d1
		bls.s	locret_1EAAE
		clr.b	-1(a2)
		move.w	x_pos(a0),d2
		move.w	d2,d3
		move.w	objoff_32(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	x_pos(a1),d4
		cmp.w	d2,d4
		blo.s	locret_1EB30
		cmp.w	d3,d4
		bhs.s	locret_1EB30
		btst	#5,subtype(a0)
		beq.s	loc_1EAE8
		btst	#status.player.in_air,status(a1)				; is the player in the air?
		bne.s	locret_1EB30							; if yes, branch

loc_1EAE8:
		btst	#render_flags.x_flip,render_flags(a0)
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
		bclr	#status.player.in_air,status(a1)
		move.b	#$40,angle(a1)

loc_1EB1E:
		bra.w	sub_1E9B6
; ---------------------------------------------------------------------------

loc_1EB22:
		btst	#4,subtype(a0)
		bne.s	locret_1EB30
		clr.b	spin_dash_flag(a1)

locret_1EB30:
		rts
