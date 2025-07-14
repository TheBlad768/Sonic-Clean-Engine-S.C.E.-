; ---------------------------------------------------------------------------
; Subroutine to animate a sprite using an animation script
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Animate_Sprite:
		moveq	#0,d0
		move.b	anim(a0),d0
		cmp.b	prev_anim(a0),d0
		beq.s	loc_1AC00
		move.b	d0,prev_anim(a0)
		clr.b	anim_frame(a0)
		clr.b	anim_frame_timer(a0)

loc_1AC00:
		subq.b	#1,anim_frame_timer(a0)
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

		moveq	#signextendB( \
			setBit(status.npc.x_flip) | \
			setBit(status.npc.y_flip) \
		),d1

		and.b	status(a0),d1

		andi.b	#~( \
			setBit(render_flags.x_flip) | \
			setBit(render_flags.y_flip) \
		),render_flags(a0)

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
		move.w	#$7F00,x_pos(a0)						; delete object
		rts
; ---------------------------------------------------------------------------

locret_1AC86:
		rts

; =============== S U B R O U T I N E =======================================

Animate_SpriteIrregularDelay:
		moveq	#0,d0
		move.b	anim(a0),d0
		cmp.b	prev_anim(a0),d0
		beq.s	loc_1ACA0
		move.b	d0,prev_anim(a0)
		clr.b	anim_frame(a0)
		clr.b	anim_frame_timer(a0)

loc_1ACA0:
		subq.b	#1,anim_frame_timer(a0)
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

		moveq	#signextendB( \
			setBit(status.npc.x_flip) | \
			setBit(status.npc.y_flip) \
		),d1

		and.b	status(a0),d1

		andi.b	#~( \
			setBit(render_flags.x_flip) | \
			setBit(render_flags.y_flip) \
		),render_flags(a0)

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
		beq.s	AnimChk_Run							; if not, branch
		move.b	d0,prev_anim(a0)						; set previous animation to current animation
		clr.b	anim_frame(a0)							; reset animation
		clr.b	anim_frame_timer(a0)						; reset frame duration

AnimChk_Run:
		subq.b	#1,anim_frame_timer(a0)						; subtract 1 from frame duration
		bpl.s	AnimChk_Wait							; if time remains, branch
		add.w	d0,d0
		adda.w	(a1,d0.w),a1							; calculate address of appropriate animation script
		move.b	(a1),anim_frame_timer(a0)					; load frame duration
		moveq	#0,d1
		move.b	anim_frame(a0),d1						; load current frame number
		move.b	1(a1,d1.w),d0							; read sprite number from script
		bmi.s	AnimChk_End_FF							; if animation is complete, branch

AnimChk_Next:
		move.b	d0,mapping_frame(a0)						; load sprite number
		addq.b	#1,anim_frame(a0)						; next frame number

AnimChk_Wait:
		moveq	#0,d0								; return 0
		rts
; ---------------------------------------------------------------------------

AnimChk_End_FF:
		addq.b	#1,d0								; is the end flag = $FF?
		bne.s	AnimChk_End_FE							; if not, branch
		clr.b	anim_frame(a0)							; restart the animation
		move.b	1(a1),d0							; read sprite number
		bsr.s	AnimChk_Next
		moveq	#1,d0								; return 1
		rts
; ---------------------------------------------------------------------------

AnimChk_End_FE:
		addq.b	#1,d0								; is the end flag = $FE?
		bne.s	AnimChk_End_FD							; if not, branch
		addq.b	#2,routine(a0)							; jump to next routine
		clr.b	anim_frame_timer(a0)
		addq.b	#1,anim_frame(a0)
		moveq	#1,d0								; return 1
		rts
; ---------------------------------------------------------------------------

AnimChk_End_FD:
		addq.b	#1,d0								; is the end flag = $FD?
		bne.s	AnimChk_End_FC							; if not, branch
		addq.b	#2,routine_secondary(a0)					; jump to next routine
		moveq	#1,d0								; return 1
		rts
; ---------------------------------------------------------------------------

AnimChk_End_FC:
		addq.b	#1,d0								; is the end flag = $FC?
		bne.s	AnimChk_End							; if not, branch
		move.b	#1,anim_frame_timer(a0)						; force frame duration to 1
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

		andi.b	#( \
			setBit(status.npc.x_flip) | \
			setBit(status.npc.y_flip) \
		),d1

		andi.b	#~( \
			setBit(render_flags.x_flip) | \
			setBit(render_flags.y_flip) \
		),render_flags(a0)

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
		move.w	#$7F00,x_pos(a0)						; delete object
		rts
; ---------------------------------------------------------------------------

Anim_End:
		rts

; ---------------------------------------------------------------------------
; a1 = animation script pointer
; AnimationArray: up to 8 2-byte entries:
	; 4-bit: anim_ID (1)
	; 4-bit: anim_ID (2) - the relevant one
	; 4-bit: anim_frame
	; 4-bit: anim_timer until next anim_frame
; if anim_ID (1) & (2) are not equal, new animation data is loaded
; a2 = animation script buffer
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Animate_MultiSprite:
		lea	(a1),a4								; save address of animation script
		lea	mapping_frame(a0),a3						; mapframe 1 (main object)
		tst.b	(a3)								; is it 0 frame? (not draw)
		bne.s	.load								; if not, branch
		addq.w	#2,a2								; skip
		bra.s	.main
; ---------------------------------------------------------------------------

.load
		moveq	#0,d6								; set 0 number of child sprites
		bsr.s	.loop

.main
		move.w	mainspr_childsprites(a0),d6					; get number of child sprites
		subq.w	#1,d6								; = amount of iterations to run the code from AnimateBoss_Loop
		bmi.s	.return								; if was 0, don't run
		lea	sub2_mapframe(a0),a3						; mapframe 2

.loop
		lea	(a4),a1								; load address of animation script

	irp	reg, d0,d1,d2
		moveq	#0,reg
	endr

		move.b	(a2)+,d0
		move.b	d0,d1
		lsr.b	#4,d1								; anim_ID (1)
		andi.b	#$F,d0								; anim_ID (2)
		move.b	d0,d2
		cmp.b	d0,d1
		sne	d4								; anim_IDs not equal
		move.b	d0,d5
		lsl.b	#4,d5
		or.b	d0,d5								; anim_ID (2) in both nybbles
		move.b	(a2)+,d0
		move.b	d0,d1
		lsr.b	#4,d1								; anim_frame
		tst.b	d4								; are the anim_IDs equal?
		beq.s	.run

	irp	reg, d0,d1
		moveq	#0,reg								; reset d0,d1 if anim_IDs not equal
	endr

.run
		andi.b	#$F,d0								; timer until next anim_frame
		subq.b	#1,d0
		bpl.s	.next2								; timer not yet at 0, and anim_IDs are equal
		add.w	d2,d2								; anim_ID (2)
		adda.w	(a1,d2.w),a1							; address of animation data with this ID
		move.b	(a1),d0								; animation speed
		move.b	1(a1,d1.w),d2							; mapping_frame of first/next anim_frame
		bmi.s	.chk_end_FF							; if animation command parameter, branch

.next
		andi.b	#$7F,d2
		move.b	d2,(a3)								; store mapping_frame to OST of object
		addq.b	#1,d1								; anim_frame

.next2
		lsl.b	#4,d1
		or.b	d1,d0
		move.b	d0,-1(a2)							; (2nd byte) anim_frame and anim_timer
		move.b	d5,-2(a2)							; (1st byte) anim_ID (both nybbles)
		addq.w	#next_subspr,a3							; mapping_frame of next subobject
		dbf	d6,.loop

.return
		rts
; ---------------------------------------------------------------------------

.chk_end_FF
		addq.b	#1,d2								; code FF - repeat animation from beginning
		bne.s	.chk_end_FE
		moveq	#0,d1
		move.b	1(a1),d2
		bra.s	.next
; ---------------------------------------------------------------------------

.chk_end_FE
		addq.b	#1,d2								; code FE - repeat animation from earlier point
		bne.s	.chk_end_FD
		moveq	#0,d3
		move.b	2(a1,d1.w),d1							; anim_frame
		move.b	1(a1,d1.w),d2							; mapping_frame
		bra.s	.next
; ---------------------------------------------------------------------------

.chk_end_FD
		addq.b	#1,d2								; code FD - start new animation
		bne.s	.chk_end_FC
		andi.b	#$F0,d5								; keep anim_ID (1)
		or.b	2(a1,d1.w),d5							; set anim_ID (2)
		bra.s	.next2
; ---------------------------------------------------------------------------

.chk_end_FC
		addq.b	#1,d2								; code FC - increment routine counter
		bne.s	.return
		addq.b	#2,routine(a0)							; next routine
		rts
