; ---------------------------------------------------------------------------
; Subroutine to change synchronised animation variables (rings, giant rings)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

ChangeRingFrame:
		cmpi.b	#id_SonicDeath,(Player_1+routine).w		; has Sonic just died?
		bhs.s	.syncend									; if yes, branch

; Used for rings and giant rings
.syncrings
		subq.b	#1,(Rings_frame_timer).w
		bpl.s	.syncrings2
		move.b	#4,(Rings_frame_timer).w
		addq.b	#1,(Rings_frame).w
		andi.b	#7,(Rings_frame).w

; Dynamic graphics
		moveq	#0,d0
		move.l	#ArtUnc_Ring>>1,d1						; Load art source
		move.b	(Rings_frame).w,d0
		lsl.w	#6,d0
		add.l	d0,d1									; Get next frame
		move.w	#tiles_to_bytes(ArtTile_Ring),d2			; Load art destination
		move.w	#$80/2,d3								; Size of art (in words)	; We only need one frame
		bsr.w	Add_To_DMA_Queue

; Used for bouncing rings
.syncrings2
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

OscillateNumInit:
		lea	Osc_Data(pc),a2
		lea	(Oscillating_Numbers).w,a1
		moveq	#bytesToWcnt(Osc_Data_End-Osc_Data),d1

.copy
		move.w	(a2)+,(a1)+
		dbf	d1,.copy
		rts
; ---------------------------------------------------------------------------

Osc_Data:
		dc.w %0000000001111101		; oscillation direction bitfield
		dc.w $80, 0					; baseline values
		dc.w $80, 0
		dc.w $80, 0
		dc.w $80, 0
		dc.w $80, 0
		dc.w $80, 0
		dc.w $80, 0
		dc.w $80, 0
		dc.w $80, 0
		dc.w $3848, $EE
		dc.w $2080, $B4
		dc.w $3080,$10E
		dc.w $5080,$1C2
		dc.w $7080,$276
		dc.w $80, 0
		dc.w $4000, $FE
Osc_Data_End

; =============== S U B R O U T I N E =======================================

; Oscillate values

OscillateNumDo:
		cmpi.b	#id_SonicDeath,(Player_1+routine).w	; has Sonic just died?
		bhs.s	OscillateNumDo_Return				; if yes, branch
		lea	Osc_Data2(pc),a2
		lea	(Oscillating_Numbers).w,a1
		move.w	(a1)+,d3								; get oscillation direction bitfield
		moveq	#bytesToLcnt(Osc_Data2_End-Osc_Data2),d1

-		move.w	(a2)+,d2								; get frequency
		move.w	(a2)+,d4								; get amplitude
		btst	d1,d3									; check oscillation direction
		bne.s	+									; branch if 1
		move.w	2(a1),d0								; get current rate
		add.w	d2,d0								; add frequency
		move.w	d0,2(a1)
		add.w	d0,(a1)								; add rate to value
		cmp.b	(a1),d4
		bhi.s	++
		bset	d1,d3
		bra.s	++
+		move.w	2(a1),d0
		sub.w	d2,d0
		move.w	d0,2(a1)
		add.w	d0,(a1)
		cmp.b	(a1),d4
		bls.s		+
		bclr	d1,d3
+		addq.w	#4,a1
		dbf	d1,-
		move.w	d3,(Oscillation_Control).w

OscillateNumDo_Return:
		rts
; ---------------------------------------------------------------------------

Osc_Data2:
		dc.w	 2, $10
		dc.w	 2, $18
		dc.w	 2, $20
		dc.w	 2, $30
		dc.w	 4, $20
		dc.w	 8,   8
		dc.w	 8, $40
		dc.w	 4, $40
		dc.w	 2, $38
		dc.w	 2, $38
		dc.w	 2, $20
		dc.w	 3, $30
		dc.w	 5, $50
		dc.w	 7, $70
		dc.w	 2, $40
		dc.w	 2, $40
Osc_Data2_End
