; ---------------------------------------------------------------------------
; DEZ palette cycling
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

AnPal_DEZ:
		lea	(Palette_cycle_counters).w,a0

		; wait
		subq.w	#1,(a0)					; decrement timer
		bpl.s	.anpal2					; if time remains, branch
		addq.w	#4+1,(a0)				; reset timer to 4 frames

		; cycle
		move.w	2(a0),d0
		addq.w	#2*2,2(a0)
		cmpi.w	#12*(2*2),2(a0)
		blo.s		.skip
		clr.w	2(a0)

.skip
		lea	(AnPal_PalDEZ12_1).l,a1
		move.l	(a1,d0.w),(Normal_palette_line_3+$1A).w

.anpal2

		; wait
		subq.w	#1,4(a0)					; decrement timer
		bpl.s	.return					; if time remains, branch
		move.w	#$13,4(a0)				; reset timer to $13 frames

		; cycle
		move.w	6(a0),d0
		addq.w	#4*2,6(a0)
		cmpi.w	#4*(4*2),6(a0)
		blo.s		.skip2
		clr.w	6(a0)

.skip2
		lea	(AnPal_PalDEZ12_2).l,a1
		lea	(Normal_palette_line_3+$10).w,a2
		move.l	(a1,d0.w),(a2)+
		move.l	4(a1,d0.w),(a2)+

.return
		rts
