; ---------------------------------------------------------------------------
; Subroutine to animate a sprite using an animation script
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

AnimateSprite:
Animate_Sprite:
		moveq	#0,d0
		move.b	anim(a0),d0
		cmp.b	prev_anim(a0),d0
		beq.s	+
		move.b	d0,prev_anim(a0)
		clr.b	anim_frame(a0)
		clr.b	anim_frame_timer(a0)
+		subq.b	#1,anim_frame_timer(a0)
		bcc.s	locret_1AC36
		add.w	d0,d0
		adda.w	(a1,d0.w),a1
		move.b	(a1),anim_frame_timer(a0)
		moveq	#0,d1
		move.b	anim_frame(a0),d1
		move.b	1(a1,d1.w),d0
		bmi.s	loc_1AC38

loc_1AC1C:
		move.b	d0,mapping_frame(a0)
		move.b	status(a0),d1
		andi.b	#3,d1
		andi.b	#-4,render_flags(a0)
		or.b	d1,render_flags(a0)
		addq.b	#1,anim_frame(a0)

locret_1AC36:
		rts
; ---------------------------------------------------------------------------

loc_1AC38:
		addq.b	#1,d0			; Code FF - Repeat animation from beginning
		bne.s	loc_1AC48
		clr.b	anim_frame(a0)
		move.b	1(a1),d0
		bra.s	loc_1AC1C
; ---------------------------------------------------------------------------

loc_1AC48:
		addq.b	#1,d0			; Code FE - Repeat animation from earlier point
		bne.s	loc_1AC5C
		move.b	2(a1,d1.w),d0
		sub.b	d0,anim_frame(a0)
		sub.b	d0,d1
		move.b	1(a1,d1.w),d0
		bra.s	loc_1AC1C
; ---------------------------------------------------------------------------

loc_1AC5C:
		addq.b	#1,d0			; Code FD - Start new animation
		bne.s	loc_1AC68
		move.b	2(a1,d1.w),anim(a0)
		rts
; ---------------------------------------------------------------------------

loc_1AC68:
		addq.b	#1,d0			; Code FC - Increment routine counter
		bne.s	loc_1AC7A
		addq.b	#2,routine(a0)
		clr.b	anim_frame_timer(a0)
		addq.b	#1,anim_frame(a0)
		rts
; ---------------------------------------------------------------------------

loc_1AC7A:
		addq.b	#1,d0			; Code FB - Move offscreen (?)
		bne.s	locret_1AC86
		move.w	#$7F00,x_pos(a0)
		rts
; ---------------------------------------------------------------------------

locret_1AC86:
		rts
; End of function Animate_Sprite

; =============== S U B R O U T I N E =======================================

Animate_SpriteIrregularDelay:
		moveq	#0,d0
		move.b	anim(a0),d0
		cmp.b	prev_anim(a0),d0
		beq.s	+
		move.b	d0,prev_anim(a0)
		clr.b	anim_frame(a0)
		clr.b	anim_frame_timer(a0)
+		subq.b	#1,anim_frame_timer(a0)
		bcc.s	locret_1ACDA
		add.w	d0,d0
		adda.w	(a1,d0.w),a1
		moveq	#0,d1
		move.b	anim_frame(a0),d1
		add.w	d1,d1
		move.b	(a1,d1.w),d0
		bmi.s	loc_1ACDC

loc_1ACBA:
		move.b	1(a1,d1.w),anim_frame_timer(a0)
		move.b	d0,mapping_frame(a0)
		move.b	status(a0),d1
		andi.b	#3,d1
		andi.b	#-4,render_flags(a0)
		or.b	d1,render_flags(a0)
		addq.b	#1,anim_frame(a0)

locret_1ACDA:
		rts
; ---------------------------------------------------------------------------

loc_1ACDC:
		addq.b	#1,d0
		bne.s	loc_1ACEA
		moveq	#0,d1
		move.b	d1,anim_frame(a0)
		move.b	(a1),d0
		bra.s	loc_1ACBA
; ---------------------------------------------------------------------------

loc_1ACEA:
		addq.b	#1,d0
		bne.s	loc_1AD00
		move.b	1(a1,d1.w),d0
		sub.b	d0,anim_frame(a0)
		add.w	d0,d0
		sub.b	d0,d1
		move.b	(a1,d1.w),d0
		bra.s	loc_1ACBA
; ---------------------------------------------------------------------------

loc_1AD00:
		addq.b	#1,d0
		bne.s	loc_1AD0C
		move.b	1(a1,d1.w),anim(a0)
		rts
; ---------------------------------------------------------------------------

loc_1AD0C:
		addq.b	#1,d0
		bne.s	locret_1AD1E
		addq.b	#2,routine(a0)
		clr.b	anim_frame_timer(a0)
		addq.b	#1,anim_frame(a0)
		rts
; ---------------------------------------------------------------------------

locret_1AD1E:
		rts
; End of function Animate_SpriteIrregularDelay

; =============== S U B R O U T I N E =======================================

AnimateSprite_Reverse:
		moveq	#0,d0
		move.b	anim(a0),d0
		cmp.b	prev_anim(a0),d0
		beq.s	Anim_Run
		move.b	d0,prev_anim(a0)
		clr.b	anim_frame(a0)
		clr.b	anim_frame_timer(a0)

Anim_Run:
		subq.b	#1,anim_frame_timer(a0)
		bcc.s	Anim_Wait
		add.w	d0,d0
		adda.w	(a1,d0.w),a1
		move.b	(a1),anim_frame_timer(a0)
		moveq	#0,d1
		move.b	anim_frame(a0),d1
		move.b	1(a1,d1.w),d0
		bmi.s	Anim_End_FF

Anim_Next:
		move.b	d0,d1
		andi.b	#$1F,d0
		move.b	d0,mapping_frame(a0)
		move.b	status(a0),d0
		rol.b	#3,d1
		eor.b	d0,d1
		andi.b	#3,d1
		andi.b	#-4,render_flags(a0)
		or.b	d1,render_flags(a0)
		addq.b	#1,anim_frame(a0)

Anim_Wait:
		rts
; ---------------------------------------------------------------------------

Anim_End_FF:
		addq.b	#1,d0			; Code FF - Repeat animation from beginning
		bne.s	Anim_End_FE
		clr.b	anim_frame(a0)
		move.b	1(a1),d0
		bra.s	Anim_Next
; ---------------------------------------------------------------------------

Anim_End_FE:
		addq.b	#1,d0			; Code FE - Repeat animation from earlier point
		bne.s	Anim_End_FD
		move.b	2(a1,d1.w),d0
		sub.b	d0,anim_frame(a0)
		sub.b	d0,d1
		move.b	1(a1,d1.w),d0
		bra.s	Anim_Next
; ---------------------------------------------------------------------------

Anim_End_FD:
		addq.b	#1,d0			; Code FD - Start new animation
		bne.s	Anim_End_FC
		move.b	2(a1,d1.w),anim(a0)
		rts
; ---------------------------------------------------------------------------

Anim_End_FC:
		addq.b	#1,d0			; Code FC - Increment routine counter
		bne.s	Anim_End_FB
		addq.b	#2,routine(a0)
		clr.b	anim_frame_timer(a0)
		addq.b	#1,anim_frame(a0)
		rts
; ---------------------------------------------------------------------------

Anim_End_FB:
		addq.b	#1,d0			; Code FB - Move offscreen (?)
		bne.s	Anim_End
		move.w	#$7F00,x_pos(a0)
		rts
; ---------------------------------------------------------------------------

Anim_End:
		rts
; End of function AnimateSprite_Reverse
