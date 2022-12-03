; ---------------------------------------------------------------------------
; Path Swapper (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_PathSwap:
		move.l	#Map_PathSwap,mappings(a0)
		move.w	#make_art_tile(ArtTile_Ring,1,0),art_tile(a0)
		ori.b	#4,render_flags(a0)
		move.w	#bytes_to_word(128/2,128/2),height_pixels(a0)	; set height and width
		move.w	#$280,priority(a0)
		move.b	subtype(a0),d0
		btst	#2,d0
		beq.s	loc_1CD3C
		andi.w	#7,d0
		move.b	d0,mapping_frame(a0)
		andi.w	#3,d0
		add.w	d0,d0
		move.w	word_1CD34(pc,d0.w),objoff_32(a0)
		move.w	y_pos(a0),d1
		lea	(Player_1).w,a1
		cmp.w	y_pos(a1),d1
		bcc.s	+
		move.b	#1,objoff_34(a0)
+		move.l	#loc_1CEF2,address(a0)
		bra.w	loc_1CEF2
; ---------------------------------------------------------------------------

word_1CD34:
		dc.w $20
		dc.w $40
		dc.w $80
		dc.w $100
; ---------------------------------------------------------------------------

loc_1CD3C:
		andi.w	#3,d0
		move.b	d0,mapping_frame(a0)
		add.w	d0,d0
		move.w	word_1CD34(pc,d0.w),objoff_32(a0)
		move.w	x_pos(a0),d1
		lea	(Player_1).w,a1
		cmp.w	x_pos(a1),d1
		bcc.s	+
		move.b	#1,objoff_34(a0)
+		move.l	#+,address(a0)
+		tst.w	(Debug_placement_mode).w
		bne.s	+
		move.w	x_pos(a0),d1
		lea	objoff_34(a0),a2
		lea	(Player_1).w,a1
		bsr.s	sub_1CDDA
		jmp	(Delete_Sprite_If_Not_In_Range).w
; ---------------------------------------------------------------------------
+		jmp	(Sprite_OnScreen_Test).w

; =============== S U B R O U T I N E =======================================

sub_1CDDA:
		tst.b	(a2)+
		bne.s	loc_1CE6C
		cmp.w	x_pos(a1),d1
		bhi.s	locret_1CE6A
		move.b	#1,-1(a2)
		move.w	y_pos(a0),d2
		move.w	d2,d3
		move.w	objoff_32(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	y_pos(a1),d4
		cmp.w	d2,d4
		blt.s		locret_1CE6A
		cmp.w	d3,d4
		bge.s	locret_1CE6A
		move.b	subtype(a0),d0
		bpl.s	loc_1CE1C
		btst	#Status_InAir,status(a1)
		bne.s	locret_1CE6A

loc_1CE1C:
		move.w	x_pos(a1),d2
		sub.w	d1,d2
		bcc.s	loc_1CE26
		neg.w	d2

loc_1CE26:
		cmpi.w	#$40,d2
		bcc.s	locret_1CE6A
		btst	#0,render_flags(a0)
		bne.s	loc_1CE54
		move.b	#$C,top_solid_bit(a1)
		move.b	#$D,lrb_solid_bit(a1)
		btst	#3,d0
		beq.s	loc_1CE54
		move.b	#$E,top_solid_bit(a1)
		move.b	#$F,lrb_solid_bit(a1)

loc_1CE54:
		andi.w	#$7FFF,art_tile(a1)
		btst	#5,d0
		beq.s	locret_1CE6A
		ori.w	#$8000,art_tile(a1)

locret_1CE6A:
		rts
; ---------------------------------------------------------------------------

loc_1CE6C:
		cmp.w	x_pos(a1),d1
		bls.s		locret_1CEF0
		clr.b	-1(a2)
		move.w	y_pos(a0),d2
		move.w	d2,d3
		move.w	objoff_32(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	y_pos(a1),d4
		cmp.w	d2,d4
		blt.s		locret_1CEF0
		cmp.w	d3,d4
		bge.s	locret_1CEF0
		move.b	subtype(a0),d0
		bpl.s	loc_1CEA8
		btst	#Status_InAir,status(a1)
		bne.s	locret_1CEF0

loc_1CEA8:
		move.w	x_pos(a1),d2
		sub.w	d1,d2
		bcc.s	loc_1CEB2
		neg.w	d2

loc_1CEB2:
		cmpi.w	#$40,d2
		bcc.s	locret_1CEF0
		btst	#0,render_flags(a0)
		bne.s	loc_1CEDE
		move.b	#$C,top_solid_bit(a1)
		move.b	#$D,lrb_solid_bit(a1)
		btst	#4,d0
		beq.s	loc_1CEDE
		move.b	#$E,top_solid_bit(a1)
		move.b	#$F,lrb_solid_bit(a1)

loc_1CEDE:
		andi.w	#$7FFF,art_tile(a1)
		btst	#6,d0
		beq.s	locret_1CEF0
		ori.w	#$8000,art_tile(a1)

locret_1CEF0:
		rts
; ---------------------------------------------------------------------------

loc_1CEF2:
		tst.w	(Debug_placement_mode).w
		bne.s	+
		move.w	y_pos(a0),d1
		lea	objoff_34(a0),a2
		lea	(Player_1).w,a1
		bsr.s	sub_1CF42
		jmp	(Delete_Sprite_If_Not_In_Range).w
; ---------------------------------------------------------------------------
+		jmp	(Sprite_OnScreen_Test).w

; =============== S U B R O U T I N E =======================================

sub_1CF42:
		tst.b	(a2)+
		bne.s	loc_1CFD4
		cmp.w	y_pos(a1),d1
		bhi.s	locret_1CFD2
		move.b	#1,-1(a2)
		move.w	x_pos(a0),d2
		move.w	d2,d3
		move.w	objoff_32(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	x_pos(a1),d4
		cmp.w	d2,d4
		blt.s		locret_1CFD2
		cmp.w	d3,d4
		bge.s	locret_1CFD2
		move.b	subtype(a0),d0
		bpl.s	loc_1CF84
		btst	#Status_InAir,status(a1)
		bne.s	locret_1CFD2

loc_1CF84:
		move.w	y_pos(a1),d2
		sub.w	d1,d2
		bcc.s	loc_1CF8E
		neg.w	d2

loc_1CF8E:
		cmpi.w	#$40,d2
		bcc.s	locret_1CFD2
		btst	#0,render_flags(a0)
		bne.s	loc_1CFBC
		move.b	#$C,top_solid_bit(a1)
		move.b	#$D,lrb_solid_bit(a1)
		btst	#3,d0
		beq.s	loc_1CFBC
		move.b	#$E,top_solid_bit(a1)
		move.b	#$F,lrb_solid_bit(a1)

loc_1CFBC:
		andi.w	#$7FFF,art_tile(a1)
		btst	#5,d0
		beq.s	locret_1CFD2
		ori.w	#$8000,art_tile(a1)

locret_1CFD2:
		rts
; ---------------------------------------------------------------------------

loc_1CFD4:
		cmp.w	y_pos(a1),d1
		bls.s		locret_1D058
		clr.b	-1(a2)
		move.w	x_pos(a0),d2
		move.w	d2,d3
		move.w	objoff_32(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	x_pos(a1),d4
		cmp.w	d2,d4
		blt.s		locret_1D058
		cmp.w	d3,d4
		bge.s	locret_1D058
		move.b	subtype(a0),d0
		bpl.s	loc_1D010
		btst	#Status_InAir,status(a1)
		bne.s	locret_1D058

loc_1D010:
		move.w	y_pos(a1),d2
		sub.w	d1,d2
		bcc.s	loc_1D01A
		neg.w	d2

loc_1D01A:
		cmpi.w	#$40,d2
		bcc.s	locret_1D058
		btst	#0,render_flags(a0)
		bne.s	loc_1D046
		move.b	#$C,top_solid_bit(a1)
		move.b	#$D,lrb_solid_bit(a1)
		btst	#4,d0
		beq.s	loc_1D046
		move.b	#$E,top_solid_bit(a1)
		move.b	#$F,lrb_solid_bit(a1)

loc_1D046:
		andi.w	#$7FFF,art_tile(a1)
		btst	#6,d0
		beq.s	locret_1D058
		ori.w	#$8000,art_tile(a1)

locret_1D058:
		rts
; ---------------------------------------------------------------------------

		include "Objects/PathSwap/Object Data/Map - Path Swap.asm"
