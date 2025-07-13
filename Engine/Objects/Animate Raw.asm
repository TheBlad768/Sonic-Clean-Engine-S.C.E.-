; ---------------------------------------------------------------------------
; Animate raw subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Animate_RawAdjustFlipX:
		movea.l	objoff_30(a0),a1

Animate_RawNoSSTAdjustFlipX:
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	.return
		moveq	#1,d0
		add.b	anim_frame(a0),d0
		move.b	d0,anim_frame(a0)
		moveq	#0,d1
		move.b	1(a1,d0.w),d1
		bmi.s	Animate_RawNoSST.main
		bclr	#6,d1								; $40?
		beq.s	.skip
		bchg	#render_flags.x_flip,render_flags(a0)

.skip
		move.b	(a1),anim_frame_timer(a0)
		move.b	d1,mapping_frame(a0)

.return
		rts

; =============== S U B R O U T I N E =======================================

Animate_RawAdjustFlipY:
		movea.l	objoff_30(a0),a1

Animate_RawNoSSTAdjustFlipY:
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	.return
		moveq	#1,d0
		add.b	anim_frame(a0),d0
		move.b	d0,anim_frame(a0)
		moveq	#0,d1
		move.b	1(a1,d0.w),d1
		bmi.s	Animate_RawNoSST.main
		bclr	#6,d1								; $40?
		beq.s	.skip
		bchg	#render_flags.y_flip,render_flags(a0)

.skip
		move.b	(a1),anim_frame_timer(a0)
		move.b	d1,mapping_frame(a0)

.return
		rts

; =============== S U B R O U T I N E =======================================

Animate_Raw:
		movea.l	objoff_30(a0),a1

Animate_RawNoSST:
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	.return
		moveq	#1,d0
		add.b	anim_frame(a0),d0
		move.b	d0,anim_frame(a0)
		moveq	#0,d1
		move.b	1(a1,d0.w),d1
		bmi.s	.main
		move.b	(a1),anim_frame_timer(a0)
		move.b	d1,mapping_frame(a0)

.return
		rts
; ---------------------------------------------------------------------------

.main
		neg.b	d1
		jmp	.index-2(pc,d1.w)
; ---------------------------------------------------------------------------

.index
		bra.s	.restart							; FE
		bra.s	.change								; FC
; ---------------------------------------------------------------------------

		; jump to custom code							; FA
		clr.b	anim_frame(a0)
		clr.b	anim_frame_timer(a0)
		movea.l	objoff_34(a0),a1
		jmp	(a1)
; ---------------------------------------------------------------------------

.change
		move.b	2(a1,d0.w),d1
		ext.w	d1
		adda.w	d1,a1
		move.l	a1,objoff_30(a0)						; set new animation pointer

.restart
		move.b	1(a1),mapping_frame(a0)
		move.b	(a1),anim_frame_timer(a0)
		clr.b	anim_frame(a0)
		rts

; =============== S U B R O U T I N E =======================================

Animate_RawCheckResult:
		movea.l	objoff_30(a0),a1

Animate_RawNoSSTCheckResult:
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	.exit
		moveq	#1,d0
		add.b	anim_frame(a0),d0
		move.b	d0,anim_frame(a0)
		lea	1(a1,d0.w),a2
		moveq	#0,d1
		move.b	(a2)+,d1
		cmpi.b	#-1,d1								; is raw index flag?
		beq.s	.main								; if yes, branch
		move.b	(a1),anim_frame_timer(a0)
		move.b	d1,mapping_frame(a0)
		moveq	#1,d2								; next frame flag
		rts
; ---------------------------------------------------------------------------

.exit
		moveq	#0,d2								; wait flag
		rts
; ---------------------------------------------------------------------------

.main
		move.b	(a2)+,d1
		neg.b	d1
		jmp	.index-2(pc,d1.w)
; ---------------------------------------------------------------------------

.index
		bra.s	.restart							; FE
		bra.s	.change								; FC
; ---------------------------------------------------------------------------

		; jump to custom code							; FA
		clr.b	anim_frame(a0)
		clr.b	anim_frame_timer(a0)
		movea.l	objoff_34(a0),a1
		jsr	(a1)
		moveq	#-1,d2								; end flag
		rts
; ---------------------------------------------------------------------------

.change
		move.b	(a2)+,d1
		ext.w	d1
		adda.w	d1,a1
		move.l	a1,objoff_30(a0)						; set new animation pointer

.restart
		move.b	1(a1),mapping_frame(a0)
		move.b	(a1),anim_frame_timer(a0)
		clr.b	anim_frame(a0)
		moveq	#-1,d2								; end flag
		rts

; =============== S U B R O U T I N E =======================================

Animate_RawMultiDelayFlipX:
		movea.l	objoff_30(a0),a1

Animate_RawNoSSTMultiDelayFlipX:
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	.exit
		moveq	#2,d0
		add.b	anim_frame(a0),d0
		move.b	d0,anim_frame(a0)
		moveq	#0,d1
		move.b	(a1,d0.w),d1
		bmi.s	Animate_RawNoSSTMultiDelay.main
		bclr	#6,d1								; $40?
		beq.s	.skip
		bchg	#render_flags.x_flip,render_flags(a0)

.skip
		move.b	d1,mapping_frame(a0)
		move.b	1(a1,d0.w),anim_frame_timer(a0)
		moveq	#1,d2								; next frame flag
		rts
; ---------------------------------------------------------------------------

.exit
		moveq	#0,d2								; wait flag
		rts

; =============== S U B R O U T I N E =======================================

Animate_RawMultiDelay:
		movea.l	objoff_30(a0),a1

Animate_RawNoSSTMultiDelay:
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	.exit
		moveq	#2,d0
		add.b	anim_frame(a0),d0
		move.b	d0,anim_frame(a0)
		moveq	#0,d1
		move.b	(a1,d0.w),d1
		bmi.s	.main
		move.b	d1,mapping_frame(a0)
		move.b	1(a1,d0.w),anim_frame_timer(a0)
		moveq	#1,d2								; next frame flag
		rts
; ---------------------------------------------------------------------------

.exit
		moveq	#0,d2								; wait flag
		rts
; ---------------------------------------------------------------------------

.main
		neg.b	d1
		jmp	.index-2(pc,d1.w)
; ---------------------------------------------------------------------------

.index
		bra.s	.restart							; FE
		bra.s	.change								; FC
; ---------------------------------------------------------------------------

		; jump to custom code							; FA
		clr.b	anim_frame(a0)
		clr.b	anim_frame_timer(a0)
		movea.l	objoff_34(a0),a1
		jsr	(a1)
		moveq	#-1,d2								; end flag
		rts
; ---------------------------------------------------------------------------

.change
		move.b	1(a1,d0.w),d1
		ext.w	d1
		adda.w	d1,a1
		move.l	a1,objoff_30(a0)						; set new animation pointer

.restart
		move.b	(a1),mapping_frame(a0)
		move.b	1(a1),anim_frame_timer(a0)
		clr.b	anim_frame(a0)
		moveq	#1,d2								; next frame flag
		rts

; =============== S U B R O U T I N E =======================================

Animate_RawMultiDelayFlipY:
		movea.l	objoff_30(a0),a1

Animate_RawNoSSTMultiDelayFlipY:
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	.exit
		moveq	#2,d0
		add.b	anim_frame(a0),d0
		move.b	d0,anim_frame(a0)
		moveq	#0,d1
		move.b	(a1,d0.w),d1
		bmi.s	Animate_RawNoSSTMultiDelay.main
		bclr	#6,d1								; $40?
		beq.s	.skip
		bchg	#render_flags.y_flip,render_flags(a0)

.skip
		move.b	d1,mapping_frame(a0)
		move.b	1(a1,d0.w),anim_frame_timer(a0)
		moveq	#1,d2								; next frame flag
		rts
; ---------------------------------------------------------------------------

.exit
		moveq	#0,d2								; wait flag
		rts

; =============== S U B R O U T I N E =======================================

Animate_Raw2MultiDelay:
		movea.l	objoff_30(a0),a1

Animate_Raw2NoSSTMultiDelay:
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	.exit
		moveq	#2,d0
		add.b	anim_frame(a0),d0
		move.b	d0,anim_frame(a0)
		lea	(a1,d0.w),a2
		moveq	#0,d1
		move.b	(a2)+,d1
		cmpi.b	#-1,d1								; is raw index flag?
		beq.s	.main								; if yes, branch
		move.b	d1,mapping_frame(a0)
		move.b	1(a1,d0.w),anim_frame_timer(a0)
		moveq	#1,d2								; next frame flag
		rts
; ---------------------------------------------------------------------------

.exit
		moveq	#0,d2								; wait flag
		rts
; ---------------------------------------------------------------------------

.main
		move.b	(a2)+,d1
		neg.b	d1
		jmp	.index-2(pc,d1.w)
; ---------------------------------------------------------------------------

.index
		bra.s	.restart							; FE
		bra.s	.change								; FC
; ---------------------------------------------------------------------------

		; jump to custom code							; FA
		clr.b	anim_frame(a0)
		clr.b	anim_frame_timer(a0)
		movea.l	objoff_34(a0),a1
		jsr	(a1)
		moveq	#-1,d2								; end flag
		rts
; ---------------------------------------------------------------------------

.change
		move.b	(a2)+,d1
		ext.w	d1
		adda.w	d1,a1
		move.l	a1,objoff_30(a0)						; set new animation pointer

.restart
		move.b	(a1),mapping_frame(a0)
		move.b	1(a1),anim_frame_timer(a0)
		clr.b	anim_frame(a0)
		moveq	#-1,d2								; end flag
		rts

; =============== S U B R O U T I N E =======================================

Animate_RawGetFaster:
		movea.l	objoff_30(a0),a1

Animate_RawNoSSTGetFaster:
		bset	#5,objoff_38(a0)
		bne.s	.main
		move.b	(a1),objoff_2E(a0)
		clr.b	objoff_2F(a0)

.main
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	.exit
		move.b	objoff_2E(a0),d2
		moveq	#1,d0
		add.b	anim_frame(a0),d0
		move.b	2(a1,d0.w),d1
		bpl.s	.next

		; check flags
		moveq	#0,d0
		move.b	2(a1),d1
		tst.b	d2
		beq.s	.run
		subq.b	#1,d2
		move.b	d2,objoff_2E(a0)

.next
		move.b	d0,anim_frame(a0)
		move.b	d1,mapping_frame(a0)
		move.b	d2,anim_frame_timer(a0)
		moveq	#1,d2								; next frame flag
		rts
; ---------------------------------------------------------------------------

.exit
		moveq	#0,d2								; wait flag
		rts
; ---------------------------------------------------------------------------

.run
		move.b	d0,anim_frame(a0)
		move.b	d1,mapping_frame(a0)
		move.b	d2,anim_frame_timer(a0)
		move.b	objoff_2F(a0),d0
		addq.b	#1,d0
		move.b	d0,objoff_2F(a0)
		cmp.b	1(a1),d0
		blo.s	.end

		; jump to custom code
		bclr	#5,objoff_38(a0)
		clr.b	objoff_2F(a0)
		movea.l	objoff_34(a0),a2
		jsr	(a2)

.end
		moveq	#-1,d2								; end flag
		rts

; =============== S U B R O U T I N E =======================================

Animate_RawGetSlower:
		movea.l	objoff_30(a0),a1

Animate_RawNoSSTGetSlower:
		bset	#5,objoff_38(a0)
		bne.s	.main
		clr.w	objoff_2E(a0)

.main
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	.return
		move.b	objoff_2E(a0),d2
		moveq	#1,d0
		add.b	anim_frame(a0),d0
		move.b	1(a1,d0.w),d1
		bpl.s	.next
		moveq	#0,d0
		move.b	1(a1),d1
		addq.b	#1,d2

.next
		move.b	d0,anim_frame(a0)
		move.b	d1,mapping_frame(a0)
		move.b	d2,anim_frame_timer(a0)
		cmp.b	(a1),d2
		bhs.s	.run
		move.b	d2,objoff_2E(a0)

.return
		rts
; ---------------------------------------------------------------------------

.run
		move.b	objoff_2F(a0),d0
		addq.b	#1,d0
		move.b	d0,objoff_2F(a0)
		cmp.b	1(a1),d0
		blo.s	.return

		; jump to custom code
		bclr	#5,objoff_38(a0)
		clr.b	objoff_2F(a0)
		movea.l	objoff_34(a0),a2
		jmp	(a2)

; =============== S U B R O U T I N E =======================================

Animate_ExternalPlayerSprite:
		subq.b	#1,anim_frame_timer(a1)
		bpl.s	.plc
		move.b	(a2),anim_frame_timer(a1)
		moveq	#2,d0
		add.b	anim_frame(a1),d0
		move.b	d0,anim_frame(a1)
		move.b	1(a2,d0.w),d1
		beq.s	.custom
		move.b	d1,mapping_frame(a1)
		bclr	#render_flags.x_flip,render_flags(a1)
		tst.b	2(a2,d0.w)
		beq.s	.plc
		bset	#render_flags.x_flip,render_flags(a1)

.plc
		bra.w	Sonic_Load_PLC
; ---------------------------------------------------------------------------

.custom
		bsr.w	Sonic_Load_PLC

		; custom code
		movea.l	objoff_34(a0),a1
		jmp	(a1)

; =============== S U B R O U T I N E =======================================

Set_Raw_Animation:
		move.l	a1,objoff_30(a0)
		clr.b	anim_frame(a0)
		clr.b	anim_frame_timer(a0)
		rts
