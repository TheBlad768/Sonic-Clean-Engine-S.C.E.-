; ---------------------------------------------------------------------------
; Invisible barrier (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_Invisible_SolidBlock:
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
		move.l	#loc_1EC6C,address(a0)

loc_1EC6C:
		moveq	#$B,d1
		add.b	width_pixels(a0),d1
		moveq	#0,d2
		move.b	height_pixels(a0),d2
		move.w	d2,d3
		addq.w	#1,d3
		move.w	x_pos(a0),d4
		jsr	(SolidObjectFull2).w
		out_of_xrange.s	loc_1EBAA
		tst.w	(Debug_placement_mode).w
		beq.s	locret_1ECA8
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

locret_1ECA8:
		rts
; ---------------------------------------------------------------------------

loc_1EBAA:
		move.w	respawn_addr(a0),d0
		beq.s	loc_1EBB6
		movea.w	d0,a2
		bclr	#7,(a2)

loc_1EBB6:
		jmp	(Delete_Current_Sprite).w
; ---------------------------------------------------------------------------

		include "Objects/Invisible Blocks/Object Data/Map - Invisible Block.asm"
