; ---------------------------------------------------------------------------
; Path Swapper (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_PathSwap:

		; init
		move.l	#Map_PathSwap,mappings(a0)
		move.w	#make_art_tile(ArtTile_Ring,1,0),art_tile(a0)
		ori.b	#setBit(render_flags.level),render_flags(a0)			; use screen coordinates
		move.l	#bytes_word_to_long(128/2,128/2,priority_5),height_pixels(a0)	; set height, width and priority

		; check
		move.b	subtype(a0),d0
		btst	#2,d0
		beq.s	loc_1CD3C
		andi.w	#7,d0
		move.b	d0,mapping_frame(a0)
		andi.w	#3,d0
		add.w	d0,d0
		move.w	word_1CD34(pc,d0.w),objoff_32(a0)
		move.w	y_pos(a0),d1
		lea	(Player_1).w,a1							; a1=character
		cmp.w	y_pos(a1),d1
		bhs.s	loc_1CD16
		move.b	#1,objoff_34(a0)

loc_1CD16:

		; next
		lea	sub_1CEF2(pc),a1
		move.l	a1,address(a0)
		jmp	(a1)
; ---------------------------------------------------------------------------

word_1CD34:
		dc.w $20	; 0
		dc.w $40	; 1
		dc.w $80	; 2
		dc.w $100	; 3
; ---------------------------------------------------------------------------

loc_1CD3C:
		andi.w	#3,d0
		move.b	d0,mapping_frame(a0)
		add.w	d0,d0
		move.w	word_1CD34(pc,d0.w),objoff_32(a0)
		move.w	x_pos(a0),d1
		lea	(Player_1).w,a1							; a1=character
		cmp.w	x_pos(a1),d1
		bhs.s	loc_1CD70
		move.b	#1,objoff_34(a0)

loc_1CD70:
		move.l	#loc_1CD8A,address(a0)

; =============== S U B R O U T I N E =======================================

loc_1CD8A:
		tst.w	(Debug_placement_mode).w					; is debug mode on?
		bne.s	loc_1CDAC							; if yes, branch
		move.w	x_pos(a0),d1
		lea	objoff_34(a0),a2
		lea	(Player_1).w,a1							; a1=character
		bsr.s	sub_1CDDA
		jmp	(Delete_Sprite_If_Not_In_Range).w
; ---------------------------------------------------------------------------

loc_1CDAC:
		jmp	(Sprite_OnScreen_Test).w

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
		blt.s	locret_1CE6A
		cmp.w	d3,d4
		bge.s	locret_1CE6A
		move.b	subtype(a0),d0
		bpl.s	loc_1CE1C
		btst	#status.player.in_air,status(a1)				; is the player in the air?
		bne.s	locret_1CE6A							; if yes, branch

loc_1CE1C:
		move.w	x_pos(a1),d2
		sub.w	d1,d2
		bhs.s	loc_1CE26
		neg.w	d2

loc_1CE26:
		cmpi.w	#$40,d2
		bhs.s	locret_1CE6A
		btst	#render_flags.x_flip,render_flags(a0)
		bne.s	loc_1CE54
		move.w	#bytes_to_word($C,$D),top_solid_bit(a1)
		btst	#3,d0
		beq.s	loc_1CE54
		move.w	#bytes_to_word($E,$F),top_solid_bit(a1)

loc_1CE54:
		andi.w	#drawing_mask,art_tile(a1)
		btst	#5,d0
		beq.s	locret_1CE6A
		ori.w	#high_priority,art_tile(a1)

locret_1CE6A:
		rts

; =============== S U B R O U T I N E =======================================

loc_1CE6C:
		cmp.w	x_pos(a1),d1
		bls.s	locret_1CEF0
		clr.b	-1(a2)
		move.w	y_pos(a0),d2
		move.w	d2,d3
		move.w	objoff_32(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	y_pos(a1),d4
		cmp.w	d2,d4
		blt.s	locret_1CEF0
		cmp.w	d3,d4
		bge.s	locret_1CEF0
		move.b	subtype(a0),d0
		bpl.s	loc_1CEA8
		btst	#status.player.in_air,status(a1)				; is the player in the air?
		bne.s	locret_1CEF0							; if yes, branch

loc_1CEA8:
		move.w	x_pos(a1),d2
		sub.w	d1,d2
		bhs.s	loc_1CEB2
		neg.w	d2

loc_1CEB2:
		cmpi.w	#$40,d2
		bhs.s	locret_1CEF0
		btst	#render_flags.x_flip,render_flags(a0)
		bne.s	loc_1CEDE
		move.w	#bytes_to_word($C,$D),top_solid_bit(a1)
		btst	#4,d0
		beq.s	loc_1CEDE
		move.w	#bytes_to_word($E,$F),top_solid_bit(a1)

loc_1CEDE:
		andi.w	#drawing_mask,art_tile(a1)
		btst	#6,d0
		beq.s	locret_1CEF0
		ori.w	#high_priority,art_tile(a1)

locret_1CEF0:
		rts

; =============== S U B R O U T I N E =======================================

sub_1CEF2:
		tst.w	(Debug_placement_mode).w					; is debug mode on?
		bne.s	loc_1CF14							; if yes, branch
		move.w	y_pos(a0),d1
		lea	objoff_34(a0),a2
		lea	(Player_1).w,a1							; a1=character
		bsr.s	sub_1CF42
		jmp	(Delete_Sprite_If_Not_In_Range).w
; ---------------------------------------------------------------------------

loc_1CF14:
		jmp	(Sprite_OnScreen_Test).w

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
		blt.s	locret_1CFD2
		cmp.w	d3,d4
		bge.s	locret_1CFD2
		move.b	subtype(a0),d0
		bpl.s	loc_1CF84
		btst	#status.player.in_air,status(a1)				; is the player in the air?
		bne.s	locret_1CFD2							; if yes, branch

loc_1CF84:
		move.w	y_pos(a1),d2
		sub.w	d1,d2
		bhs.s	loc_1CF8E
		neg.w	d2

loc_1CF8E:
		cmpi.w	#$40,d2
		bhs.s	locret_1CFD2
		btst	#render_flags.x_flip,render_flags(a0)
		bne.s	loc_1CFBC
		move.w	#bytes_to_word($C,$D),top_solid_bit(a1)
		btst	#3,d0
		beq.s	loc_1CFBC
		move.w	#bytes_to_word($E,$F),top_solid_bit(a1)

loc_1CFBC:
		andi.w	#drawing_mask,art_tile(a1)
		btst	#5,d0
		beq.s	locret_1CFD2
		ori.w	#high_priority,art_tile(a1)

locret_1CFD2:
		rts

; =============== S U B R O U T I N E =======================================

loc_1CFD4:
		cmp.w	y_pos(a1),d1
		bls.s	locret_1D058
		clr.b	-1(a2)
		move.w	x_pos(a0),d2
		move.w	d2,d3
		move.w	objoff_32(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	x_pos(a1),d4
		cmp.w	d2,d4
		blt.s	locret_1D058
		cmp.w	d3,d4
		bge.s	locret_1D058
		move.b	subtype(a0),d0
		bpl.s	loc_1D010
		btst	#status.player.in_air,status(a1)				; is the player in the air?
		bne.s	locret_1D058							; if yes, branch

loc_1D010:
		move.w	y_pos(a1),d2
		sub.w	d1,d2
		bhs.s	loc_1D01A
		neg.w	d2

loc_1D01A:
		cmpi.w	#$40,d2
		bhs.s	locret_1D058
		btst	#render_flags.x_flip,render_flags(a0)
		bne.s	loc_1D046
		move.w	#bytes_to_word($C,$D),top_solid_bit(a1)
		btst	#4,d0
		beq.s	loc_1D046
		move.w	#bytes_to_word($E,$F),top_solid_bit(a1)

loc_1D046:
		andi.w	#drawing_mask,art_tile(a1)
		btst	#6,d0
		beq.s	locret_1D058
		ori.w	#high_priority,art_tile(a1)

locret_1D058:
		rts
; ---------------------------------------------------------------------------

		include "Objects/Main/Path Swap/Object Data/Map - Path Swap.asm"
