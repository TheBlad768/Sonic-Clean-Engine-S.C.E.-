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
		bhs.s	locret_1AC36
		add.w	d0,d0
		adda.w	(a1,d0.w),a1
		move.b	(a1),anim_frame_timer(a0)
		moveq	#0,d1
		move.b	anim_frame(a0),d1
		move.b	1(a1,d1.w),d0
		bmi.s	loc_1AC38

loc_1AC1C:
		move.b	d0,mapping_frame(a0)
		moveq	#3,d1
		and.b	status(a0),d1
		andi.b	#-4,render_flags(a0)
		or.b	d1,render_flags(a0)
		addq.b	#1,anim_frame(a0)

locret_1AC36:
		rts
; ---------------------------------------------------------------------------

loc_1AC38:
		addq.b	#1,d0								; code FF - repeat animation from beginning
		bne.s	loc_1AC48
		clr.b	anim_frame(a0)
		move.b	1(a1),d0
		bra.s	loc_1AC1C
; ---------------------------------------------------------------------------

loc_1AC48:
		addq.b	#1,d0								; code FE - repeat animation from earlier point
		bne.s	loc_1AC5C
		move.b	2(a1,d1.w),d0
		sub.b	d0,anim_frame(a0)
		sub.b	d0,d1
		move.b	1(a1,d1.w),d0
		bra.s	loc_1AC1C
; ---------------------------------------------------------------------------

loc_1AC5C:
		addq.b	#1,d0								; code FD - start new animation
		bne.s	loc_1AC68
		move.b	2(a1,d1.w),anim(a0)
		rts
; ---------------------------------------------------------------------------

loc_1AC68:
		addq.b	#1,d0								; code FC - increment routine counter
		bne.s	loc_1AC7A
		addq.b	#2,routine(a0)
		clr.b	anim_frame_timer(a0)
		addq.b	#1,anim_frame(a0)
		rts
; ---------------------------------------------------------------------------

loc_1AC7A:
		addq.b	#1,d0								; code FB - move offscreen
		bne.s	locret_1AC86
		move.w	#$7F00,x_pos(a0)					; delete object
		rts
; ---------------------------------------------------------------------------

locret_1AC86:
		rts

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
		bhs.s	locret_1ACDA
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
		moveq	#3,d1
		and.b	status(a0),d1
		andi.b	#-4,render_flags(a0)
		or.b	d1,render_flags(a0)
		addq.b	#1,anim_frame(a0)

locret_1ACDA:
		rts
; ---------------------------------------------------------------------------

loc_1ACDC:
		addq.b	#1,d0								; code FF - repeat animation from beginning
		bne.s	loc_1ACEA
		moveq	#0,d1
		move.b	d1,anim_frame(a0)
		move.b	(a1),d0
		bra.s	loc_1ACBA
; ---------------------------------------------------------------------------

loc_1ACEA:
		addq.b	#1,d0								; code FE - repeat animation from earlier point
		bne.s	loc_1AD00
		move.b	1(a1,d1.w),d0
		sub.b	d0,anim_frame(a0)
		add.w	d0,d0
		sub.b	d0,d1
		move.b	(a1,d1.w),d0
		bra.s	loc_1ACBA
; ---------------------------------------------------------------------------

loc_1AD00:
		addq.b	#1,d0								; code FD - start new animation
		bne.s	loc_1AD0C
		move.b	1(a1,d1.w),anim(a0)
		rts
; ---------------------------------------------------------------------------

loc_1AD0C:
		addq.b	#1,d0								; code FC - increment routine counter
		bne.s	locret_1AD1E
		addq.b	#2,routine(a0)
		clr.b	anim_frame_timer(a0)
		addq.b	#1,anim_frame(a0)
		rts
; ---------------------------------------------------------------------------

locret_1AD1E:
		rts

; =============== S U B R O U T I N E =======================================

AnimateSprite_Checked:
		moveq	#0,d0
		move.b	anim(a0),d0							; move animation number to d0
		cmp.b	prev_anim(a0),d0						; is animation set to change?
		beq.s	AnimChk_Run						; if not, branch
		move.b	d0,prev_anim(a0)						; set previous animation to current animation
		clr.b	anim_frame(a0)							; reset animation
		clr.b	anim_frame_timer(a0)					; reset frame duration

AnimChk_Run:
		subq.b	#1,anim_frame_timer(a0)				; subtract 1 from frame duration
		bpl.s	AnimChk_Wait						; if time remains, branch
		add.w	d0,d0
		adda.w	(a1,d0.w),a1							; calculate address of appropriate animation script
		move.b	(a1),anim_frame_timer(a0)				; load frame duration
		moveq	#0,d1
		move.b	anim_frame(a0),d1					; load current frame number
		move.b	1(a1,d1.w),d0							; read sprite number from script
		bmi.s	AnimChk_End_FF					; if animation is complete, branch

AnimChk_Next:
		move.b	d0,mapping_frame(a0)				; load sprite number
		addq.b	#1,anim_frame(a0)					; next frame number

AnimChk_Wait:
		moveq	#0,d0								; return 0
		rts
; ---------------------------------------------------------------------------

AnimChk_End_FF:
		addq.b	#1,d0								; is the end flag = $FF?
		bne.s	AnimChk_End_FE					; if not, branch
		clr.b	anim_frame(a0)							; restart the animation
		move.b	1(a1),d0								; read sprite number
		bsr.s	AnimChk_Next
		moveq	#1,d0								; return 1
		rts
; ---------------------------------------------------------------------------

AnimChk_End_FE:
		addq.b	#1,d0								; is the end flag = $FE?
		bne.s	AnimChk_End_FD					; if not, branch
		addq.b	#2,routine(a0)						; jump to next routine
		clr.b	anim_frame_timer(a0)
		addq.b	#1,anim_frame(a0)
		moveq	#1,d0								; return 1
		rts
; ---------------------------------------------------------------------------

AnimChk_End_FD:
		addq.b	#1,d0								; is the end flag = $FD?
		bne.s	AnimChk_End_FC					; if not, branch
		addq.b	#2,routine_secondary(a0)				; jump to next routine
		moveq	#1,d0								; return 1
		rts
; ---------------------------------------------------------------------------

AnimChk_End_FC:
		addq.b	#1,d0								; is the end flag = $FC?
		bne.s	AnimChk_End						; if not, branch
		move.b	#1,anim_frame_timer(a0)				; force frame duration to 1
		moveq	#1,d0								; return 1

AnimChk_End:
		rts

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
		bhs.s	Anim_Wait
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
		addq.b	#1,d0								; code FF - repeat animation from beginning
		bne.s	Anim_End_FE
		clr.b	anim_frame(a0)
		move.b	1(a1),d0
		bra.s	Anim_Next
; ---------------------------------------------------------------------------

Anim_End_FE:
		addq.b	#1,d0								; code FE - repeat animation from earlier point
		bne.s	Anim_End_FD
		move.b	2(a1,d1.w),d0
		sub.b	d0,anim_frame(a0)
		sub.b	d0,d1
		move.b	1(a1,d1.w),d0
		bra.s	Anim_Next
; ---------------------------------------------------------------------------

Anim_End_FD:
		addq.b	#1,d0								; code FD - start new animation
		bne.s	Anim_End_FC
		move.b	2(a1,d1.w),anim(a0)
		rts
; ---------------------------------------------------------------------------

Anim_End_FC:
		addq.b	#1,d0								; code FC - Increment routine counter
		bne.s	Anim_End_FB
		addq.b	#2,routine(a0)
		clr.b	anim_frame_timer(a0)
		addq.b	#1,anim_frame(a0)
		rts
; ---------------------------------------------------------------------------

Anim_End_FB:
		addq.b	#1,d0								; code FB - move offscreen
		bne.s	Anim_End
		move.w	#$7F00,x_pos(a0)					; delete object
		rts
; ---------------------------------------------------------------------------

Anim_End:
		rts
