; ---------------------------------------------------------------------------
; Subroutine to change synchronised animation variables (rings, giant rings)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

ChangeRingFrame:
		cmpi.b	#PlayerID_Death,(Player_1+routine).w				; has player just died?
		bhs.s	.syncend							; if yes, branch

.syncrings

		; used for rings and giant rings
		subq.b	#1,(Rings_frame_timer).w
		bpl.s	.syncrings2
		addq.b	#4+1,(Rings_frame_timer).w
		addq.b	#1,(Rings_frame).w
		andi.b	#7,(Rings_frame).w

		; dynamic ring graphics
		moveq	#0,d1
		move.b	(Rings_frame).w,d1
		lsl.w	#6,d1								; multiply by $40
		addi.l	#dmaSource(ArtUnc_Ring),d1					; get next frame
		move.w	#tiles_to_bytes(ArtTile_Ring),d2				; load art destination

		; size of art (in words) ; we only need one frame
		moveq	#tiles_to_bytes( \
		dmaLength(4) \
		),d3

		bsr.w	Add_To_DMA_Queue

.syncrings2

		; used for bouncing rings
		tst.b	(Ring_spill_anim_counter).w
		beq.s	.syncend
		moveq	#0,d0
		move.b	(Ring_spill_anim_counter).w,d0
		add.w	(Ring_spill_anim_accum).w,d0
		move.w	d0,(Ring_spill_anim_accum).w
		rol.w	#7,d0
		andi.w	#3,d0
		move.b	d0,(Ring_spill_anim_frame).w
		subq.b	#1,(Ring_spill_anim_counter).w

.syncend
		rts

; ---------------------------------------------------------------------------
; Oscillating number subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Osc_Data:

		; oscillation direction bitfield
		; set to initial state
		dc.w \
			setBit(0) | \
			setBit(2) | \
			setBit(3) | \
			setBit(4) | \
			setBit(5) | \
			setBit(6)

		; baseline values
		dc.w $80, 0								; bit F
		dc.w $80, 0								; bit E
		dc.w $80, 0								; bit D
		dc.w $80, 0								; bit C
		dc.w $80, 0								; bit B
		dc.w $80, 0								; bit A
		dc.w $80, 0								; bit 9
		dc.w $80, 0								; bit 8
		dc.w $80, 0								; bit 7
		dc.w $3848, $EE								; bit 6
		dc.w $2080, $B4								; bit 5
		dc.w $3080,$10E								; bit 4
		dc.w $5080,$1C2								; bit 3
		dc.w $7080,$276								; bit 2
		dc.w $80, 0								; bit 1
		dc.w $4000, $FE								; bit 0
Osc_Data_end
; ---------------------------------------------------------------------------

OscillateNumInit:
		lea	Osc_Data(pc),a2
		lea	(Oscillating_Numbers).w,a1

	rept bytesTo2Lcnt(Osc_Data_end-Osc_Data)
		move.l	(a2)+,(a1)+							; copy baseline values to RAM
	endr
	if (Osc_Data_end-Osc_Data)&2
		move.w	(a2)+,(a1)+							; copy baseline values to RAM
	endif
		rts

; =============== S U B R O U T I N E =======================================

; Oscillate values

OscillateNumDo:
		cmpi.b	#PlayerID_Death,(Player_1+routine).w				; has player just died?
		bhs.s	.return								; if yes, branch
		lea	Osc_Data2(pc),a2
		lea	(Oscillating_Numbers).w,a1
		move.w	(a1)+,d3							; get oscillation direction bitfield
		moveq	#bytesToLcnt(Osc_Data2_end-Osc_Data2),d1

.loop
		move.w	(a2)+,d2							; get frequency
		move.w	(a2)+,d4							; get amplitude
		btst	d1,d3								; check oscillation direction
		bne.s	.down								; branch if 1

		; up
		move.w	2(a1),d0							; get current rate
		add.w	d2,d0								; add frequency
		move.w	d0,2(a1)
		add.w	d0,(a1)								; add rate to value
		cmp.b	(a1),d4
		bhi.s	.next
		bset	d1,d3								; set bit
		bra.s	.next
; ---------------------------------------------------------------------------

.down
		move.w	2(a1),d0
		sub.w	d2,d0
		move.w	d0,2(a1)
		add.w	d0,(a1)
		cmp.b	(a1),d4
		bls.s	.next
		bclr	d1,d3								; clr bit

.next
		addq.w	#4,a1
		dbf	d1,.loop
		move.w	d3,(Oscillation_Control).w

.return
		rts
; ---------------------------------------------------------------------------

Osc_Data2:										; frequency, amplitude
		dc.w 2, $10								; bit F
		dc.w 2, $18								; bit E
		dc.w 2, $20								; bit D
		dc.w 2, $30								; bit C
		dc.w 4, $20								; bit B
		dc.w 8, 8								; bit A
		dc.w 8, $40								; bit 9
		dc.w 4, $40								; bit 8
		dc.w 2, $38								; bit 7
		dc.w 2, $38								; bit 6
		dc.w 2, $20								; bit 5
		dc.w 3, $30								; bit 4
		dc.w 5, $50								; bit 3
		dc.w 7, $70								; bit 2
		dc.w 2, $40								; bit 1
		dc.w 2, $40								; bit 0
Osc_Data2_end
