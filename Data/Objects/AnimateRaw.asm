
; =============== S U B R O U T I N E =======================================

Animate_Raw:
		movea.l	$30(a0),a1

Animate_RawNoSST:
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	locret_84426
		moveq	#0,d0
		move.b	anim_frame(a0),d0
		addq.w	#1,d0
		move.b	d0,anim_frame(a0)
		moveq	#0,d1
		move.b	1(a1,d0.w),d1
		bmi.s	loc_84428
		move.b	(a1),anim_frame_timer(a0)
		move.b	d1,mapping_frame(a0)

locret_84426:
		rts
; ---------------------------------------------------------------------------

loc_84428:
		neg.b	d1
		jsr	loc_8442E+2(pc,d1.w)

loc_8442E:
		clr.b	anim_frame(a0)
		rts
; ---------------------------------------------------------------------------
		bra.w	AnimateRaw_Restart		; FC
; ---------------------------------------------------------------------------
		bra.w	AnimateRaw_Jump		; F8
; ---------------------------------------------------------------------------
		bra.w	AnimateRaw_CustomCode	; F4
; ---------------------------------------------------------------------------

AnimateRaw_Jump:
		move.b	2(a1,d0.w),d1
		ext.w	d1
		lea	(a1,d1.w),a1
		move.l	a1,$30(a0)

AnimateRaw_Restart:
		move.b	1(a1),mapping_frame(a0)
		move.b	(a1),anim_frame_timer(a0)
		rts
; ---------------------------------------------------------------------------

AnimateRaw_CustomCode:
		clr.b	anim_frame_timer(a0)
		movea.l	$34(a0),a1
		jmp	(a1)
; End of function Animate_Raw

; =============== S U B R O U T I N E =======================================

Animate_RawAdjustFlipX:
		movea.l	$30(a0),a1

Animate_RawNoSSTAdjustFlipX:
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	locret_84496
		moveq	#0,d0
		move.b	anim_frame(a0),d0
		addq.w	#1,d0
		move.b	d0,anim_frame(a0)
		moveq	#0,d1
		move.b	1(a1,d0.w),d1
		bmi.s	loc_84428
		bclr	#6,d1
		beq.s	loc_8448E
		bchg	#0,render_flags(a0)

loc_8448E:
		move.b	(a1),anim_frame_timer(a0)
		move.b	d1,mapping_frame(a0)

locret_84496:
		rts
; End of function Animate_RawAdjustFlipX

; =============== S U B R O U T I N E =======================================

Animate_RawAdjustFlipY:
		movea.l	$30(a0),a1

Animate_RawNoSSTAdjustFlipY:
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	locret_844CC
		moveq	#0,d0
		move.b	anim_frame(a0),d0
		addq.w	#1,d0
		move.b	d0,anim_frame(a0)
		moveq	#0,d1
		move.b	1(a1,d0.w),d1
		bmi.w	loc_84428
		bclr	#6,d1
		beq.s	loc_844C4
		bchg	#1,render_flags(a0)

loc_844C4:
		move.b	(a1),anim_frame_timer(a0)
		move.b	d1,mapping_frame(a0)

locret_844CC:
		rts
; End of function Animate_RawAdjustFlipY

; =============== S U B R O U T I N E =======================================

Animate_RawCheckResult:
		movea.l	$30(a0),a1

Animate_RawNoSSTCheckResult:
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	loc_8453E
		moveq	#0,d0
		move.b	anim_frame(a0),d0
		addq.w	#1,d0
		move.b	d0,anim_frame(a0)
		lea	1(a1,d0.w),a2
		moveq	#0,d1
		move.b	(a2)+,d1
		cmpi.b	#-1,d1
		beq.s	loc_84542
		move.b	(a1),anim_frame_timer(a0)
		move.b	d1,mapping_frame(a0)
		moveq	#1,d2
		rts
; ---------------------------------------------------------------------------

loc_8453E:
		moveq	#0,d2
		rts
; ---------------------------------------------------------------------------

loc_84542:
		move.b	(a2)+,d1
		neg.b	d1
		jsr	loc_8454E(pc,d1.w)
		clr.b	anim_frame(a0)

loc_8454E:
		moveq	#-1,d2
		rts
; ---------------------------------------------------------------------------
		bra.w	loc_8456A
; ---------------------------------------------------------------------------
		bra.w	loc_8455E
; ---------------------------------------------------------------------------
		bra.w	loc_84576
; ---------------------------------------------------------------------------

loc_8455E:
		move.b	(a2)+,d1
		ext.w	d1
		lea	(a1,d1.w),a1
		move.l	a1,$30(a0)

loc_8456A:
		move.b	1(a1),mapping_frame(a0)
		move.b	(a1),anim_frame_timer(a0)
		rts
; ---------------------------------------------------------------------------

loc_84576:
		clr.b	anim_frame_timer(a0)
		movea.l	$34(a0),a1
		jmp	(a1)
; End of function Animate_RawCheckResult

; =============== S U B R O U T I N E =======================================

Animate_RawMultiDelay:
		movea.l	$30(a0),a1

Animate_RawNoSSTMultiDelay:
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	loc_845C8
		moveq	#0,d0
		move.b	anim_frame(a0),d0
		addq.w	#2,d0
		move.b	d0,anim_frame(a0)
		moveq	#0,d1
		move.b	(a1,d0.w),d1
		bmi.s	loc_845CC
		move.b	d1,mapping_frame(a0)
		move.b	1(a1,d0.w),anim_frame_timer(a0)
		moveq	#1,d2
		rts
; ---------------------------------------------------------------------------

loc_845C8:
		moveq	#0,d2
		rts
; ---------------------------------------------------------------------------

loc_845CC:
		neg.b	d1
		jsr	loc_845D2+2(pc,d1.w)

loc_845D2:
		clr.b	anim_frame(a0)
		rts
; ---------------------------------------------------------------------------
		bra.w	loc_845F2
; ---------------------------------------------------------------------------
		bra.w	loc_845E4
; ---------------------------------------------------------------------------
		bra.w	loc_84600
; ---------------------------------------------------------------------------

loc_845E4:
		move.b	1(a1,d0.w),d1
		ext.w	d1
		lea	(a1,d1.w),a1
		move.l	a1,$30(a0)

loc_845F2:
		move.b	(a1),mapping_frame(a0)
		move.b	1(a1),anim_frame_timer(a0)
		moveq	#1,d2
		rts
; ---------------------------------------------------------------------------

loc_84600:
		clr.b	anim_frame_timer(a0)
		movea.l	$34(a0),a1
		jsr	(a1)
		moveq	#-1,d2
		rts
; End of function Animate_RawMultiDelay

; =============== S U B R O U T I N E =======================================

Animate_RawMultiDelayFlipX:
		movea.l	$30(a0),a1

Animate_RawNoSSTMultiDelayFlipX:
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	loc_84646
		moveq	#0,d0
		move.b	anim_frame(a0),d0
		addq.w	#2,d0
		move.b	d0,anim_frame(a0)
		moveq	#0,d1
		move.b	(a1,d0.w),d1
		bmi.s	loc_845CC
		bclr	#6,d1
		beq.s	loc_84638
		bchg	#0,render_flags(a0)

loc_84638:
		move.b	d1,mapping_frame(a0)
		move.b	1(a1,d0.w),anim_frame_timer(a0)
		moveq	#1,d2
		rts
; ---------------------------------------------------------------------------

loc_84646:
		moveq	#0,d2
		rts
; End of function Animate_RawNoSSTMultiDelayFlipX

; =============== S U B R O U T I N E =======================================

Animate_RawMultiDelayFlipY:
		movea.l	$30(a0),a1
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	loc_84684
		moveq	#0,d0
		move.b	anim_frame(a0),d0
		addq.w	#2,d0
		move.b	d0,anim_frame(a0)
		moveq	#0,d1
		move.b	(a1,d0.w),d1
		bmi.w	loc_845CC
		bclr	#6,d1
		beq.s	loc_84676
		bchg	#1,render_flags(a0)

loc_84676:
		move.b	d1,mapping_frame(a0)
		move.b	1(a1,d0.w),anim_frame_timer(a0)
		moveq	#1,d2
		rts
; ---------------------------------------------------------------------------

loc_84684:
		moveq	#0,d2
		rts
; End of function Animate_RawMultiDelayFlipY

; =============== S U B R O U T I N E =======================================

Animate_Raw2MultiDelay:
		movea.l	$30(a0),a1

Animate_Raw2NoSSTMultiDelay:
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	loc_846BA
		moveq	#0,d0
		move.b	anim_frame(a0),d0
		addq.w	#2,d0
		move.b	d0,anim_frame(a0)
		lea	(a1,d0.w),a2
		moveq	#0,d1
		move.b	(a2)+,d1
		cmpi.b	#-1,d1
		beq.s	loc_846BE
		move.b	d1,mapping_frame(a0)
		move.b	1(a1,d0.w),anim_frame_timer(a0)
		moveq	#1,d2
		rts
; ---------------------------------------------------------------------------

loc_846BA:
		moveq	#0,d2
		rts
; ---------------------------------------------------------------------------

loc_846BE:
		move.b	(a2)+,d1
		neg.b	d1
		jsr	loc_846C6+2(pc,d1.w)

loc_846C6:
		clr.b	anim_frame(a0)
		rts
; ---------------------------------------------------------------------------
		bra.w	loc_846E4
; ---------------------------------------------------------------------------
		bra.w	loc_846D8
; ---------------------------------------------------------------------------
		bra.w	loc_846F2
; ---------------------------------------------------------------------------

loc_846D8:
		move.b	(a2)+,d1
		ext.w	d1
		lea	(a1,d1.w),a1
		move.l	a1,$30(a0)

loc_846E4:
		move.b	(a1),mapping_frame(a0)
		move.b	1(a1),anim_frame_timer(a0)
		moveq	#-1,d2
		rts
; ---------------------------------------------------------------------------

loc_846F2:
		clr.b	anim_frame_timer(a0)
		movea.l	$34(a0),a1
		jsr	(a1)
		moveq	#-1,d2
		rts
; End of function Animate_Raw2MultiDelay

; =============== S U B R O U T I N E =======================================

Animate_RawGetFaster:
		movea.l	$30(a0),a1

Animate_RawNoSSTGetFaster:
		bset	#5,$38(a0)
		bne.s	loc_84714
		move.b	(a1),$2E(a0)
		clr.b	$2F(a0)

loc_84714:
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	loc_8474C
		move.b	$2E(a0),d2
		moveq	#0,d0
		move.b	anim_frame(a0),d0
		addq.b	#1,d0
		move.b	2(a1,d0.w),d1
		bpl.s	loc_8473C
		moveq	#0,d0
		move.b	2(a1),d1
		tst.b	d2
		beq.s	loc_84750
		subq.b	#1,d2
		move.b	d2,$2E(a0)

loc_8473C:
		move.b	d0,anim_frame(a0)
		move.b	d1,mapping_frame(a0)
		move.b	d2,anim_frame_timer(a0)
		moveq	#1,d2
		rts
; ---------------------------------------------------------------------------

loc_8474C:
		moveq	#0,d2
		rts
; ---------------------------------------------------------------------------

loc_84750:
		move.b	d0,anim_frame(a0)
		move.b	d1,mapping_frame(a0)
		move.b	d2,anim_frame_timer(a0)
		move.b	$2F(a0),d0
		addq.b	#1,d0
		move.b	d0,$2F(a0)
		cmp.b	1(a1),d0
		blo.s		loc_8477C
		bclr	#5,$38(a0)
		clr.b	$2F(a0)
		movea.l	$34(a0),a2
		jsr	(a2)

loc_8477C:
		moveq	#-1,d2
		rts
; End of function Animate_RawGetFaster

; =============== S U B R O U T I N E =======================================

Animate_RawGetSlower:
		movea.l	$30(a0),a1

Animate_RawNoSSTGetSlower:
		bset	#5,$38(a0)
		bne.s	loc_84790
		clr.w	$2E(a0)

loc_84790:
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	locret_847C4
		move.b	$2E(a0),d2
		moveq	#0,d0
		move.b	anim_frame(a0),d0
		addq.b	#1,d0
		move.b	1(a1,d0.w),d1
		bpl.s	loc_847B0
		moveq	#0,d0
		move.b	1(a1),d1
		addq.b	#1,d2

loc_847B0:
		move.b	d0,anim_frame(a0)
		move.b	d1,mapping_frame(a0)
		move.b	d2,anim_frame_timer(a0)
		cmp.b	(a1),d2
		bhs.s	loc_847C6
		move.b	d2,$2E(a0)

locret_847C4:
		rts
; ---------------------------------------------------------------------------

loc_847C6:
		move.b	$2F(a0),d0
		addq.b	#1,d0
		move.b	d0,$2F(a0)
		cmp.b	1(a1),d0
		blo.s		locret_847C4
		bclr	#5,$38(a0)
		clr.b	$2F(a0)
		movea.l	$34(a0),a2
		jmp	(a2)
; End of function Animate_RawGetSlower

; =============== S U B R O U T I N E =======================================

Set_Raw_Animation:
		move.l	a1,$30(a0)
		clr.b	anim_frame(a0)
		clr.b	anim_frame_timer(a0)
		rts
; End of function Set_Raw_Animation
