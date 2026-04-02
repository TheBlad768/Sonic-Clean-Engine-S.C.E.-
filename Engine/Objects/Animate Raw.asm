; ---------------------------------------------------------------------------
; Animate raw adjust x flip subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Animate_RawAdjustFlipX:
		movea.l	animations(a0),a1						; load animation script to a1

Animate_RawNoSSTAdjustFlipX:

		; wait
		subq.b	#1,anim_frame_timer(a0)						; subtract 1 from frame duration
		bpl.s	.return								; if time remains, branch

		; run
		moveq	#1,d0
		add.b	anim_frame(a0),d0
		move.b	d0,anim_frame(a0)						; next frame number
		moveq	#0,d1
		move.b	1(a1,d0.w),d1							; read mapping frame from script
		bmi.s	Animate_RawNoSST.main						; if animation is complete, branch
		bclr	#6,d1								; $40?
		beq.s	.skip
		bchg	#render_flags.x_flip,render_flags(a0)				; change xflip

.skip
		move.b	(a1),anim_frame_timer(a0)					; set anim frame timer
		move.b	d1,mapping_frame(a0)						; set mapping frame

.return
		rts

; ---------------------------------------------------------------------------
; Animate raw adjust y flip subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Animate_RawAdjustFlipY:
		movea.l	animations(a0),a1						; load animation script to a1

Animate_RawNoSSTAdjustFlipY:

		; wait
		subq.b	#1,anim_frame_timer(a0)						; subtract 1 from frame duration
		bpl.s	.return								; if time remains, branch

		; run
		moveq	#1,d0
		add.b	anim_frame(a0),d0
		move.b	d0,anim_frame(a0)						; next frame number
		moveq	#0,d1
		move.b	1(a1,d0.w),d1							; read mapping frame from script
		bmi.s	Animate_RawNoSST.main						; if animation is complete, branch
		bclr	#6,d1								; $40?
		beq.s	.skip
		bchg	#render_flags.y_flip,render_flags(a0)				; change yflip

.skip
		move.b	(a1),anim_frame_timer(a0)					; set anim frame timer
		move.b	d1,mapping_frame(a0)						; set mapping frame

.return
		rts

; ---------------------------------------------------------------------------
; Animate raw subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Animate_Raw:
		movea.l	animations(a0),a1						; load animation script to a1

Animate_RawNoSST:

		; wait
		subq.b	#1,anim_frame_timer(a0)						; subtract 1 from frame duration
		bpl.s	.return								; if time remains, branch

		; run
		moveq	#1,d0
		add.b	anim_frame(a0),d0
		move.b	d0,anim_frame(a0)						; next frame number
		moveq	#0,d1
		move.b	1(a1,d0.w),d1							; read mapping frame from script
		bmi.s	.main								; if animation is complete, branch
		move.b	(a1),anim_frame_timer(a0)					; set anim frame timer
		move.b	d1,mapping_frame(a0)						; set mapping frame

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
		clr.b	anim_frame(a0)							; reset anim frame
		clr.b	anim_frame_timer(a0)						; reset anim frame timer
		movea.l	wait_addr(a0),a1
		jmp	(a1)
; ---------------------------------------------------------------------------

.change
		move.b	2(a1,d0.w),d1							; get jump byte
		ext.w	d1								; sign extension
		adda.w	d1,a1								; add result to a1
		move.l	a1,animations(a0)						; set new animation pointer

.restart
		move.b	1(a1),mapping_frame(a0)						; set mapping frame
		move.b	(a1),anim_frame_timer(a0)					; set anim frame timer
		clr.b	anim_frame(a0)							; reset anim frame
		rts

; ---------------------------------------------------------------------------
; Animate raw check result subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Animate_RawCheckResult:
		movea.l	animations(a0),a1						; load animation script to a1

Animate_RawNoSSTCheckResult:

		; wait
		subq.b	#1,anim_frame_timer(a0)						; subtract 1 from frame duration
		bpl.s	.exit								; if time remains, branch

		; run
		moveq	#1,d0
		add.b	anim_frame(a0),d0
		move.b	d0,anim_frame(a0)						; next frame number
		lea	1(a1,d0.w),a2
		moveq	#0,d1
		move.b	(a2)+,d1							; read mapping frame from script
		cmpi.b	#-1,d1								; is raw index flag?
		beq.s	.main								; if yes, branch
		move.b	(a1),anim_frame_timer(a0)					; set anim frame timer
		move.b	d1,mapping_frame(a0)						; set mapping frame

		; exit
		moveq	#1,d2								; next frame flag
		rts
; ---------------------------------------------------------------------------

.exit
		moveq	#0,d2								; wait flag
		rts
; ---------------------------------------------------------------------------

.main
		move.b	(a2)+,d1							; get index byte
		neg.b	d1
		jmp	.index-2(pc,d1.w)
; ---------------------------------------------------------------------------

.index
		bra.s	.restart							; FE
		bra.s	.change								; FC
; ---------------------------------------------------------------------------

		; jump to custom code							; FA
		clr.b	anim_frame(a0)							; reset anim frame
		clr.b	anim_frame_timer(a0)						; reset anim frame timer
		movea.l	wait_addr(a0),a1
		jsr	(a1)

		; exit
		moveq	#-1,d2								; end flag
		rts
; ---------------------------------------------------------------------------

.change
		move.b	(a2)+,d1							; get jump byte
		ext.w	d1								; sign extension
		adda.w	d1,a1								; add result to a1
		move.l	a1,animations(a0)						; set new animation pointer

.restart
		move.b	1(a1),mapping_frame(a0)						; set mapping frame
		move.b	(a1),anim_frame_timer(a0)					; set anim frame timer
		clr.b	anim_frame(a0)							; reset anim frame

		; exit
		moveq	#-1,d2								; end flag
		rts

; ---------------------------------------------------------------------------
; Animate raw multi-delay x flip subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Animate_RawMultiDelayFlipX:
		movea.l	animations(a0),a1						; load animation script to a1

Animate_RawNoSSTMultiDelayFlipX:

		; wait
		subq.b	#1,anim_frame_timer(a0)						; subtract 1 from frame duration
		bpl.s	.exit								; if time remains, branch

		; run
		moveq	#2,d0
		add.b	anim_frame(a0),d0
		move.b	d0,anim_frame(a0)						; next frame number
		moveq	#0,d1
		move.b	(a1,d0.w),d1							; read mapping frame from script
		bmi.s	Animate_RawNoSSTMultiDelay.main					; if animation is complete, branch
		bclr	#6,d1								; $40?
		beq.s	.skip
		bchg	#render_flags.x_flip,render_flags(a0)				; change xflip

.skip
		move.b	d1,mapping_frame(a0)						; set mapping frame
		move.b	1(a1,d0.w),anim_frame_timer(a0)					; set anim frame timer

		; exit
		moveq	#1,d2								; next frame flag
		rts
; ---------------------------------------------------------------------------

.exit
		moveq	#0,d2								; wait flag
		rts

; ---------------------------------------------------------------------------
; Animate raw multi-delay subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Animate_RawMultiDelay:
		movea.l	animations(a0),a1						; load animation script to a1

Animate_RawNoSSTMultiDelay:

		; wait
		subq.b	#1,anim_frame_timer(a0)						; subtract 1 from frame duration
		bpl.s	.exit								; if time remains, branch

		; run
		moveq	#2,d0
		add.b	anim_frame(a0),d0
		move.b	d0,anim_frame(a0)						; next frame number
		moveq	#0,d1
		move.b	(a1,d0.w),d1							; read mapping frame from script
		bmi.s	.main								; if animation is complete, branch
		move.b	d1,mapping_frame(a0)						; set mapping frame
		move.b	1(a1,d0.w),anim_frame_timer(a0)					; set anim frame timer

		; exit
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
		clr.b	anim_frame(a0)							; reset anim frame
		clr.b	anim_frame_timer(a0)						; reset anim frame timer
		movea.l	wait_addr(a0),a1
		jsr	(a1)

		; exit
		moveq	#-1,d2								; end flag
		rts
; ---------------------------------------------------------------------------

.change
		move.b	1(a1,d0.w),d1							; get jump byte
		ext.w	d1								; sign extension
		adda.w	d1,a1								; add result to a1
		move.l	a1,animations(a0)						; set new animation pointer

.restart
		move.b	(a1),mapping_frame(a0)						; set mapping frame
		move.b	1(a1),anim_frame_timer(a0)					; set anim frame timer
		clr.b	anim_frame(a0)							; reset anim frame

		; exit
		moveq	#1,d2								; next frame flag
		rts

; ---------------------------------------------------------------------------
; Animate raw multi-delay y flip subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Animate_RawMultiDelayFlipY:
		movea.l	animations(a0),a1						; load animation script to a1

Animate_RawNoSSTMultiDelayFlipY:

		; wait
		subq.b	#1,anim_frame_timer(a0)						; subtract 1 from frame duration
		bpl.s	.exit								; if time remains, branch

		; run
		moveq	#2,d0
		add.b	anim_frame(a0),d0
		move.b	d0,anim_frame(a0)						; next frame number
		moveq	#0,d1
		move.b	(a1,d0.w),d1							; read mapping frame from script
		bmi.s	Animate_RawNoSSTMultiDelay.main					; if animation is complete, branch
		bclr	#6,d1								; $40?
		beq.s	.skip
		bchg	#render_flags.y_flip,render_flags(a0)				; change yflip

.skip
		move.b	d1,mapping_frame(a0)						; set mapping frame
		move.b	1(a1,d0.w),anim_frame_timer(a0)					; set anim frame timer

		; exit
		moveq	#1,d2								; next frame flag
		rts
; ---------------------------------------------------------------------------

.exit
		moveq	#0,d2								; wait flag
		rts

; ---------------------------------------------------------------------------
; Animate raw 2 multi-delay subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Animate_Raw2MultiDelay:
		movea.l	animations(a0),a1						; load animation script to a1

Animate_Raw2NoSSTMultiDelay:

		; wait
		subq.b	#1,anim_frame_timer(a0)						; subtract 1 from frame duration
		bpl.s	.exit								; if time remains, branch

		; run
		moveq	#2,d0
		add.b	anim_frame(a0),d0
		move.b	d0,anim_frame(a0)						; next frame number
		lea	(a1,d0.w),a2
		moveq	#0,d1
		move.b	(a2)+,d1							; read mapping frame from script
		cmpi.b	#-1,d1								; is raw index flag?
		beq.s	.main								; if yes, branch
		move.b	d1,mapping_frame(a0)						; set mapping frame
		move.b	1(a1,d0.w),anim_frame_timer(a0)					; set anim frame timer

		; exit
		moveq	#1,d2								; next frame flag
		rts
; ---------------------------------------------------------------------------

.exit
		moveq	#0,d2								; wait flag
		rts
; ---------------------------------------------------------------------------

.main
		move.b	(a2)+,d1							; get index byte
		neg.b	d1
		jmp	.index-2(pc,d1.w)
; ---------------------------------------------------------------------------

.index
		bra.s	.restart							; FE
		bra.s	.change								; FC
; ---------------------------------------------------------------------------

		; jump to custom code							; FA
		clr.b	anim_frame(a0)							; reset anim frame
		clr.b	anim_frame_timer(a0)						; reset anim frame timer
		movea.l	wait_addr(a0),a1
		jsr	(a1)

		; exit
		moveq	#-1,d2								; end flag
		rts
; ---------------------------------------------------------------------------

.change
		move.b	(a2)+,d1							; get jump byte
		ext.w	d1								; sign extension
		adda.w	d1,a1								; add result to a1
		move.l	a1,animations(a0)						; set new animation pointer

.restart
		move.b	(a1),mapping_frame(a0)						; set mapping frame
		move.b	1(a1),anim_frame_timer(a0)					; set anim frame timer
		clr.b	anim_frame(a0)							; reset anim frame

		; exit
		moveq	#-1,d2								; end flag
		rts

; ---------------------------------------------------------------------------
; Animate raw get faster subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Animate_RawGetFaster:
		movea.l	animations(a0),a1						; load animation script to a1

Animate_RawNoSSTGetFaster:

		; check
		bset	#5,state_flags(a0)						; set state flag
		bne.s	.main								; if state flag has already been set, branch
		move.b	(a1),aniraw_frame_timer(a0)					; set aniraw frame timer
		clr.b	aniraw_wait_timer(a0)						; reset aniraw wait timer

.main

		; wait
		subq.b	#1,anim_frame_timer(a0)						; subtract 1 from frame duration
		bpl.s	.exit								; if time remains, branch

		; run
		move.b	aniraw_frame_timer(a0),d2
		moveq	#1,d0
		add.b	anim_frame(a0),d0
		move.b	2(a1,d0.w),d1							; read mapping frame from script
		bpl.s	.next

		; check flags
		moveq	#0,d0
		move.b	2(a1),d1							; read mapping frame from script
		tst.b	d2
		beq.s	.run
		subq.b	#1,d2
		move.b	d2,aniraw_frame_timer(a0)					; set aniraw frame timer

.next
		move.b	d0,anim_frame(a0)						; set anim frame
		move.b	d1,mapping_frame(a0)						; set mapping frame
		move.b	d2,anim_frame_timer(a0)						; set anim frame timer

		; exit
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

		; check
		move.b	aniraw_wait_timer(a0),d0
		addq.b	#1,d0
		move.b	d0,aniraw_wait_timer(a0)
		cmp.b	1(a1),d0
		blo.s	.end

		; jump to custom code
		bclr	#5,state_flags(a0)
		clr.b	aniraw_wait_timer(a0)						; reset aniraw wait timer
		movea.l	wait_addr(a0),a2
		jsr	(a2)

.end
		moveq	#-1,d2								; end flag
		rts

; ---------------------------------------------------------------------------
; Animate raw get slower subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Animate_RawGetSlower:
		movea.l	animations(a0),a1						; load animation script to a1

Animate_RawNoSSTGetSlower:

		; check
		bset	#5,state_flags(a0)						; set state flag
		bne.s	.main								; if state flag has already been set, branch
		clr.w	aniraw_frame_timer(a0)						; reset frame timer and wait timer

.main

		; wait
		subq.b	#1,anim_frame_timer(a0)						; subtract 1 from frame duration
		bpl.s	.return								; if time remains, branch

		; run
		move.b	aniraw_frame_timer(a0),d2
		moveq	#1,d0
		add.b	anim_frame(a0),d0
		move.b	1(a1,d0.w),d1							; read mapping frame from script
		bpl.s	.next
		moveq	#0,d0
		move.b	1(a1),d1							; read mapping frame from script
		addq.b	#1,d2

.next
		move.b	d0,anim_frame(a0)						; set anim frame
		move.b	d1,mapping_frame(a0)						; set mapping frame
		move.b	d2,anim_frame_timer(a0)						; set anim frame timer
		cmp.b	(a1),d2
		bhs.s	.run
		move.b	d2,aniraw_frame_timer(a0)					; set aniraw frame timer

.return
		rts
; ---------------------------------------------------------------------------

.run

		; check
		move.b	aniraw_wait_timer(a0),d0
		addq.b	#1,d0
		move.b	d0,aniraw_wait_timer(a0)
		cmp.b	1(a1),d0
		blo.s	.return

		; jump to custom code
		bclr	#5,state_flags(a0)
		clr.b	aniraw_wait_timer(a0)						; reset aniraw wait timer
		movea.l	wait_addr(a0),a2
		jmp	(a2)

; ---------------------------------------------------------------------------
; Animate external player sprite subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Animate_ExternalPlayerSprite:

		; wait
		subq.b	#1,anim_frame_timer(a1)						; subtract 1 from frame duration
		bpl.s	.plc								; if time remains, branch
		move.b	(a2),anim_frame_timer(a1)					; load frame duration

		; run
		moveq	#2,d0
		add.b	anim_frame(a1),d0
		move.b	d0,anim_frame(a1)						; next frame number
		move.b	1(a2,d0.w),d1							; read mapping frame from script
		beq.s	.custom								; if animation is complete, branch
		move.b	d1,mapping_frame(a1)						; set mapping frame

		; set xflip
		bclr	#render_flags.x_flip,render_flags(a1)
		tst.b	2(a2,d0.w)
		beq.s	.plc
		bset	#render_flags.x_flip,render_flags(a1)

.plc
		bra.w	Sonic_Load_PLC
; ---------------------------------------------------------------------------

.custom
		bsr.w	Sonic_Load_PLC

		; jump to custom code
		movea.l	wait_addr(a0),a1
		jmp	(a1)

; ---------------------------------------------------------------------------
; Set raw animation subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Set_Raw_Animation:
		move.l	a1,animations(a0)						; set animation script
		clr.b	anim_frame(a0)							; reset anim frame
		clr.b	anim_frame_timer(a0)						; reset anim frame timer
		rts
