; ---------------------------------------------------------------------------
; Button (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_Button:
		move.l	#Map_Button,mappings(a0)
		move.w	#$47E,art_tile(a0)
		move.b	#4,render_flags(a0)
		move.w	#bytes_to_word(16/2,32/2),height_pixels(a0)		; set height and width
		move.w	#$200,priority(a0)
		addq.w	#4,y_pos(a0)
		btst	#5,subtype(a0)									; $20?
		beq.s	loc_2C5B8
		move.l	#sub_2C62C,address(a0)						; HCZ only?
		bra.s	sub_2C62C
; ---------------------------------------------------------------------------

loc_2C5B8:
		move.l	#loc_2C5BE,address(a0)

loc_2C5BE:
		tst.b	render_flags(a0)
		bpl.s	loc_2C626
		moveq	#(32/2)+$B,d1								; width
		moveq	#8/2,d2										; height
		moveq	#(8/2)+1,d3									; height+1
		move.w	x_pos(a0),d4
		jsr	(SolidObjectFull).w
		clr.b	mapping_frame(a0)
		moveq	#$F,d0
		and.b	subtype(a0),d0
		lea	(Level_trigger_array).w,a3
		adda.w	d0,a3
		moveq	#0,d3
		btst	#6,subtype(a0)									; $40?
		beq.s	+
		moveq	#7,d3
+		moveq	#standing_mask,d0
		and.b	status(a0),d0									; is Sonic or Tails standing on the object?
		bne.s	loc_2C612									; if not, branch
		btst	#4,subtype(a0)									; $10?
		bne.s	loc_2C626
		bclr	d3,(a3)
		bra.s	loc_2C626
; ---------------------------------------------------------------------------

loc_2C612:
		tst.b	(a3)
		bne.s	+
		sfx	sfx_Switch
+		bset	d3,(a3)
		move.b	#1,mapping_frame(a0)

loc_2C626:
		jmp	(Sprite_OnScreen_Test).w

; =============== S U B R O U T I N E =======================================

sub_2C62C:
		tst.b	render_flags(a0)
		bpl.s	loc_2C690
		moveq	#32/2,d1										; width
		moveq	#(10/2)+1,d3									; height+1
		move.w	x_pos(a0),d4
		jsr	(SolidObjectTop).w
		clr.b	mapping_frame(a0)
		moveq	#$F,d0
		and.b	subtype(a0),d0
		lea	(Level_trigger_array).w,a3
		adda.w	d0,a3
		moveq	#0,d3
		btst	#6,subtype(a0)									; $40?
		beq.s	+
		moveq	#7,d3
+		moveq	#standing_mask,d0
		and.b	status(a0),d0									; is Sonic or Tails standing on the object?
		bne.s	loc_2C67C									; if not, branch
		btst	#4,subtype(a0)									; $10?
		bne.s	loc_2C690
		bclr	d3,(a3)
		bra.s	loc_2C690
; ---------------------------------------------------------------------------

loc_2C67C:
		tst.b	(a3)
		bne.s	+
		sfx	sfx_Switch
+		bset	d3,(a3)
		move.b	#1,mapping_frame(a0)

loc_2C690:
		jmp	(Sprite_OnScreen_Test).w
; ---------------------------------------------------------------------------

		include "Objects/Button/Object Data/Map - Button.asm"
