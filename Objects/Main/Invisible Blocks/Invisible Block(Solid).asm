; ---------------------------------------------------------------------------
; Invisible barrier (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_Invisible_SolidBlock:

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
		move.l	#.solid,address(a0)

.solid
		moveq	#$B,d1
		add.b	width_pixels(a0),d1
		moveq	#0,d2
		move.b	height_pixels(a0),d2
		move.w	d2,d3
		addq.w	#1,d3
		move.w	x_pos(a0),d4
		jsr	(SolidObjectFull2).w

		; check
		out_of_xrange.s	.offscreen
		tst.w	(Debug_placement_mode).w					; is debug mode on?
		beq.s	.return								; if not, branch
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.return
		rts
; ---------------------------------------------------------------------------

.offscreen
		move.w	respawn_addr(a0),d0						; get address in respawn table
		beq.s	.delete								; if it's zero, it isn't remembered
		movea.w	d0,a2								; load address into a2
		bclr	#7,(a2)

.delete
		jmp	(Delete_Current_Sprite).w
; ---------------------------------------------------------------------------

		include "Objects/Main/Invisible Blocks/Object Data/Map - Invisible Block.asm"
