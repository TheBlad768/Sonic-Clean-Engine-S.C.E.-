; ---------------------------------------------------------------------------
; Subroutine to animate level graphics
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Animate_Tiles:
		lea	(Level_data_addr_RAM.AnimateTiles).w,a0

		; check
		tst.l	(a0)								; is there animated art in here?
		beq.s	AnimateTiles_NULL						; if not, branch

		; jump
		movea.l	(a0)+,a1
		movea.l	(a0),a2								; get PLC scripts
		jmp	(a1)

; =============== S U B R O U T I N E =======================================

AnimateTiles_DoAniPLC:
		lea	(Anim_Counters).w,a3

AnimateTiles_DoAniPLC_GetNumber:
		move.w	(a2)+,d6							; get number of scripts in list
		bmi.s	AnimateTiles_NULL						; if no scripts, return

AnimateTiles_DoAniPLC_Part2:

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

		; prepare for DMA transfer
		; get relative address of frame's art
		move.b	8(a2,d0.w),d0							; get tile id
		lsl.w	#4,d0								; turn it into an offset

		; get VRAM destination address
		move.w	4(a2),d2

		; get ROM source address
		move.l	(a2),d1								; get start address of animated tile art
		add.l	d0,d1								; offset into art, to get the address of new frame

		; get size of art to be transferred
		moveq	#0,d3
		move.b	7(a2),d3
		lsl.w	#4,d3								; turn it into actual size (in words)

		; use d1, d2 and d3 to queue art for transfer
		jsr	(Add_To_DMA_Queue).w

.nextscript
		move.b	6(a2),d0							; get total size of frame data
		tst.b	(a2)								; is per-frame duration data present?
		bpl.s	.globalduration2						; if not, keep the current size; it's correct
		add.b	d0,d0								; double size to account for the additional frame duration data

.globalduration2
		addq.b	#1,d0
		andi.w	#$FE,d0								; round to next even address, if it isn't already
		lea	8(a2,d0.w),a2							; advance to next script in list
		addq.w	#2,a3								; advance to next script's slot in a3 (usually Anim_Counters)
		dbf	d6,.loop

AnimateTiles_NULL:
		rts
