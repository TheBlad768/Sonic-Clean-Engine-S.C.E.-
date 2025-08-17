; ---------------------------------------------------------------------------
; Palette cycling routine loading subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Animate_Palette:
		tst.w	(Palette_fade_timer).w
		bmi.s	AnimatePalette_NULL
		beq.s	.load
		subq.w	#1,(Palette_fade_timer).w
		jmp	(Pal_FromBlack).w
; ---------------------------------------------------------------------------

.load
		lea	(Level_data_addr_RAM.AnimatePalette).w,a0

		; check
		tst.l	(a0)								; is there animated palette in here?
		beq.s	AnimatePalette_NULL						; if not, branch

		; jump
		movea.l	(a0)+,a1
		movea.l	(a0),a2								; get palette scripts
		jmp	(a1)
; ---------------------------------------------------------------------------

AnimatePalette_NULL:
		rts

; =============== S U B R O U T I N E =======================================

AnimatePalette_DoAniPal:
		lea	(Palette_cycle_counters).w,a3

AnimatePalette_DoAniPal_GetNumber:
		move.w	(a2)+,d6							; get number of scripts in list
		bmi.s	AnimatePalette_NULL						; if no scripts, return

AnimatePalette_DoAniPal_Part2:

.loop
		subq.b	#1,(a3)								; tick down frame duration
		bhs.s	.nextscript							; if frame isn't over, move on to next script

		; next frame
		moveq	#0,d0
		move.b	1(a3),d0							; get current frame
		cmp.b	6(a2),d0							; have we processed the last frame in the script?
		blo.s	.notlastframe
		moveq	#0,d0								; if so, reset to first frame
		move.b	d0,1(a3)

.notlastframe
		addq.b	#1,1(a3)							; consider this frame processed; set counter to next frame
		move.b	(a2),(a3)							; set frame duration to global duration value
		bpl.s	.globalduration

		; if script uses per-frame durations, use those instead
		add.w	d0,d0
		move.b	9(a2,d0.w),(a3)							; set frame duration to current frame's duration value

.globalduration

		; get current color
		movea.l	(a2),a0								; get start address of palette
		move.b	8(a2,d0.w),d0							; get color id
		add.w	d0,d0								; multiply by 2
		adda.w	d0,a0								; offset into palette

		; get current position
		movea.w	4(a2),a1							; load palette RAM

		; copy palette
		moveq	#-16,d0								; max palette size (16 colors)
		add.b	7(a2),d0							; get size of palette
		neg.w	d0								; get total size of palette
		add.w	d0,d0								; multiply by 2
		jmp	.copy(pc,d0.w)
; ---------------------------------------------------------------------------

.copy

	rept 16
		move.w	(a0)+,(a1)+
	endr

.nextscript
		move.b	6(a2),d0							; get total size of frame data
		tst.b	(a2)								; is per-frame duration data present?
		bpl.s	.globalduration2						; if not, keep the current size; it's correct
		add.b	d0,d0								; double size to account for the additional frame duration data

.globalduration2
		addq.b	#1,d0
		andi.w	#$FE,d0								; round to next even address, if it isn't already
		lea	8(a2,d0.w),a2							; advance to next script in list
		addq.w	#2,a3								; advance to next script's slot in a3 (usually Palette_cycle_counters)
		dbf	d6,.loop
		rts
