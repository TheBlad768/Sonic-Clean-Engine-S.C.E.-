
; =============== S U B R O U T I N E =======================================

Animate_Raw:
		movea.l	objoff_30(a0),a1

Animate_RawNoSST:
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	+
		moveq	#0,d0
		move.b	anim_frame(a0),d0
		addq.w	#1,d0
		move.b	d0,anim_frame(a0)
		moveq	#0,d1
		move.b	1(a1,d0.w),d1
		bmi.s	loc_84428
		move.b	(a1),anim_frame_timer(a0)
		move.b	d1,mapping_frame(a0)
+		rts
; ---------------------------------------------------------------------------

loc_84428:
		neg.b	d1
		jsr	AnimateRaw_Index-4(pc,d1.w)
		clr.b	anim_frame(a0)
		rts
; ---------------------------------------------------------------------------

AnimateRaw_Index:
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
		move.l	a1,objoff_30(a0)

AnimateRaw_Restart:
		move.b	1(a1),mapping_frame(a0)
		move.b	(a1),anim_frame_timer(a0)
		rts
; ---------------------------------------------------------------------------

AnimateRaw_CustomCode:
		clr.b	anim_frame_timer(a0)
		movea.l	$34(a0),a1
		jmp	(a1)

; =============== S U B R O U T I N E =======================================

Animate_RawAdjustFlipX:
		movea.l	objoff_30(a0),a1

Animate_RawNoSSTAdjustFlipX:
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	++
		moveq	#0,d0
		move.b	anim_frame(a0),d0
		addq.w	#1,d0
		move.b	d0,anim_frame(a0)
		moveq	#0,d1
		move.b	1(a1,d0.w),d1
		bmi.s	loc_84428
		bclr	#6,d1
		beq.s	+
		bchg	#0,render_flags(a0)
+		move.b	(a1),anim_frame_timer(a0)
		move.b	d1,mapping_frame(a0)
+		rts

; =============== S U B R O U T I N E =======================================

Animate_RawAdjustFlipY:
		movea.l	objoff_30(a0),a1

Animate_RawNoSSTAdjustFlipY:
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	++
		moveq	#0,d0
		move.b	anim_frame(a0),d0
		addq.w	#1,d0
		move.b	d0,anim_frame(a0)
		moveq	#0,d1
		move.b	1(a1,d0.w),d1
		bmi.w	loc_84428
		bclr	#6,d1
		beq.s	+
		bchg	#1,render_flags(a0)
+		move.b	(a1),anim_frame_timer(a0)
		move.b	d1,mapping_frame(a0)
+		rts

; =============== S U B R O U T I N E =======================================

Animate_RawCheckResult:
		movea.l	objoff_30(a0),a1

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
		jsr	Animate_RawCheckResult_Index-4(pc,d1.w)
		clr.b	anim_frame(a0)
		moveq	#-1,d2
		rts
; ---------------------------------------------------------------------------

Animate_RawCheckResult_Index:
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
		move.l	a1,objoff_30(a0)

loc_8456A:
		move.b	1(a1),mapping_frame(a0)
		move.b	(a1),anim_frame_timer(a0)
		rts
; ---------------------------------------------------------------------------

loc_84576:
		clr.b	anim_frame_timer(a0)
		movea.l	$34(a0),a1
		jmp	(a1)

; =============== S U B R O U T I N E =======================================

Animate_RawMultiDelay:
		movea.l	objoff_30(a0),a1

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
		jsr	Animate_RawMultiDelay_Index-4(pc,d1.w)
		clr.b	anim_frame(a0)
		rts
; ---------------------------------------------------------------------------

Animate_RawMultiDelay_Index:
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
		move.l	a1,objoff_30(a0)

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

; =============== S U B R O U T I N E =======================================

Animate_RawMultiDelayFlipX:
		movea.l	objoff_30(a0),a1

Animate_RawNoSSTMultiDelayFlipX:
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	++
		moveq	#0,d0
		move.b	anim_frame(a0),d0
		addq.w	#2,d0
		move.b	d0,anim_frame(a0)
		moveq	#0,d1
		move.b	(a1,d0.w),d1
		bmi.s	loc_845CC
		bclr	#6,d1
		beq.s	+
		bchg	#0,render_flags(a0)
+		move.b	d1,mapping_frame(a0)
		move.b	1(a1,d0.w),anim_frame_timer(a0)
		moveq	#1,d2
		rts
; ---------------------------------------------------------------------------
+		moveq	#0,d2
		rts

; =============== S U B R O U T I N E =======================================

Animate_RawMultiDelayFlipY:
		movea.l	objoff_30(a0),a1
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	++
		moveq	#0,d0
		move.b	anim_frame(a0),d0
		addq.w	#2,d0
		move.b	d0,anim_frame(a0)
		moveq	#0,d1
		move.b	(a1,d0.w),d1
		bmi.w	loc_845CC
		bclr	#6,d1
		beq.s	+
		bchg	#1,render_flags(a0)
+		move.b	d1,mapping_frame(a0)
		move.b	1(a1,d0.w),anim_frame_timer(a0)
		moveq	#1,d2
		rts
; ---------------------------------------------------------------------------
+		moveq	#0,d2
		rts

; =============== S U B R O U T I N E =======================================

Animate_Raw2MultiDelay:
		movea.l	objoff_30(a0),a1

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
		jsr	Animate_Raw2MultiDelay_Index-4(pc,d1.w)
		clr.b	anim_frame(a0)
		rts
; ---------------------------------------------------------------------------

Animate_Raw2MultiDelay_Index:
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
		move.l	a1,objoff_30(a0)

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

; =============== S U B R O U T I N E =======================================

Animate_RawGetFaster:
		movea.l	objoff_30(a0),a1

Animate_RawNoSSTGetFaster:
		bset	#5,$38(a0)
		bne.s	+
		move.b	(a1),$2E(a0)
		clr.b	$2F(a0)
+		subq.b	#1,anim_frame_timer(a0)
		bpl.s	++
		move.b	$2E(a0),d2
		moveq	#0,d0
		move.b	anim_frame(a0),d0
		addq.b	#1,d0
		move.b	2(a1,d0.w),d1
		bpl.s	+
		moveq	#0,d0
		move.b	2(a1),d1
		tst.b	d2
		beq.s	+++
		subq.b	#1,d2
		move.b	d2,$2E(a0)
+		move.b	d0,anim_frame(a0)
		move.b	d1,mapping_frame(a0)
		move.b	d2,anim_frame_timer(a0)
		moveq	#1,d2
		rts
; ---------------------------------------------------------------------------
+		moveq	#0,d2
		rts
; ---------------------------------------------------------------------------
+		move.b	d0,anim_frame(a0)
		move.b	d1,mapping_frame(a0)
		move.b	d2,anim_frame_timer(a0)
		move.b	$2F(a0),d0
		addq.b	#1,d0
		move.b	d0,$2F(a0)
		cmp.b	1(a1),d0
		blo.s		+
		bclr	#5,$38(a0)
		clr.b	$2F(a0)
		movea.l	$34(a0),a2
		jsr	(a2)
+		moveq	#-1,d2
		rts

; =============== S U B R O U T I N E =======================================

Animate_RawGetSlower:
		movea.l	objoff_30(a0),a1

Animate_RawNoSSTGetSlower:
		bset	#5,$38(a0)
		bne.s	+
		clr.w	$2E(a0)
+		subq.b	#1,anim_frame_timer(a0)
		bpl.s	++
		move.b	$2E(a0),d2
		moveq	#0,d0
		move.b	anim_frame(a0),d0
		addq.b	#1,d0
		move.b	1(a1,d0.w),d1
		bpl.s	+
		moveq	#0,d0
		move.b	1(a1),d1
		addq.b	#1,d2
+		move.b	d0,anim_frame(a0)
		move.b	d1,mapping_frame(a0)
		move.b	d2,anim_frame_timer(a0)
		cmp.b	(a1),d2
		bhs.s	++
		move.b	d2,$2E(a0)
-
+		rts
; ---------------------------------------------------------------------------
+		move.b	$2F(a0),d0
		addq.b	#1,d0
		move.b	d0,$2F(a0)
		cmp.b	1(a1),d0
		blo.s		-
		bclr	#5,$38(a0)
		clr.b	$2F(a0)
		movea.l	$34(a0),a2
		jmp	(a2)

; =============== S U B R O U T I N E =======================================

Animate_ExternalPlayerSprite:
		subq.b	#1,anim_frame_timer(a1)
		bpl.s	loc_84500
		move.b	(a2),anim_frame_timer(a1)
		moveq	#0,d0
		move.b	anim_frame(a1),d0
		addq.b	#2,d0
		move.b	d0,anim_frame(a1)
		move.b	1(a2,d0.w),d1
		beq.s	loc_84504
		move.b	d1,mapping_frame(a1)
		bclr	#0,render_flags(a1)
		tst.b	2(a2,d0.w)
		beq.s	loc_84500
		bset	#0,render_flags(a1)

loc_84500:
		jmp	Sonic_Load_PLC2(pc)
; ---------------------------------------------------------------------------

loc_84504:
		jsr	Sonic_Load_PLC2(pc)
		movea.l	objoff_34(a0),a1
		jmp	(a1)

; =============== S U B R O U T I N E =======================================

Set_Raw_Animation:
		move.l	a1,objoff_30(a0)
		clr.b	anim_frame(a0)
		clr.b	anim_frame_timer(a0)
		rts
