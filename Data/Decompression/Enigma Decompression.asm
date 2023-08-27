; ---------------------------------------------------------------------------
; Enigma decompression subroutine
; Inputs:
; a0 = compressed data location
; a1 = destination (in RAM)
; d0 = starting art tile
; See http://www.segaretro.org/Enigma_compression for format description
; See https://github.com/flamewing/mdcomp
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

EniDec:
Eni_Decomp:
		movem.l	d0-d7/a1-a5,-(sp)
		movea.w	d0,a3					; store starting art tile
		move.b	(a0)+,d0
		ext.w	d0
		movea.w	d0,a5					; store first byte, extended to word
		move.b	(a0)+,d4					; store second byte
		lsl.b	#3,d4						; multiply by 8
		movea.w	(a0)+,a2					; store third and fourth byte
		adda.w	a3,a2					; add starting art tile
		movea.w	(a0)+,a4					; store fifth and sixth byte
		adda.w	a3,a4					; add starting art tile
		move.b	(a0)+,d5					; store seventh byte
		asl.w	#8,d5					; shift up by a byte
		move.b	(a0)+,d5					; store eighth byte in lower register byte
		moveq	#16,d6					; 16 bits = 2 bytes

Eni_Decomp_Loop:
		moveq	#7,d0					; process 7 bits at a time
		move.w	d6,d7
		sub.w	d0,d7
		move.w	d5,d1
		lsr.w	d7,d1
		andi.w	#$7F,d1					; keep only lower 7 bits
		move.w	d1,d2
		cmpi.w	#$40,d1					; is bit 6 set?
		bhs.s	.got_field				; if it is, branch
		moveq	#6,d0					; if not, process 6 bits instead of 7
		lsr.w	#1,d2					; bitfield now becomes TTSSSS instead of TTTSSSS

.got_field:
		bsr.w	Eni_Decomp_ChkGetNextByte
		andi.w	#$F,d2					; keep only lower nybble
		lsr.w	#4,d1					; store upper nybble (max value = 7)
		add.w	d1,d1
		jmp	Eni_Decomp_JmpTable(pc,d1.w)
; ---------------------------------------------------------------------------

Eni_Decomp_Sub0:
		move.w	a2,(a1)+					; write to destination
		addq.w	#1,a2					; increment
		dbra	d2,Eni_Decomp_Sub0		; repeat
		bra.s	Eni_Decomp_Loop
; ---------------------------------------------------------------------------

Eni_Decomp_Sub4:
		move.w	a4,(a1)+					; write to destination
		dbra	d2,Eni_Decomp_Sub4		; repeat
		bra.s	Eni_Decomp_Loop
; ---------------------------------------------------------------------------

Eni_Decomp_Sub8:
		bsr.s	Eni_Decomp_GetInlineCopyVal

.loop:
		move.w	d1,(a1)+
		dbra	d2,.loop
	
		bra.s	Eni_Decomp_Loop
; ---------------------------------------------------------------------------

Eni_Decomp_SubA:
		bsr.s	Eni_Decomp_GetInlineCopyVal

.loop:
		move.w	d1,(a1)+
		addq.w	#1,d1
		dbra	d2,.loop

		bra.s	Eni_Decomp_Loop
; ---------------------------------------------------------------------------

Eni_Decomp_SubC:
		bsr.s	Eni_Decomp_GetInlineCopyVal

.loop:
		move.w	d1,(a1)+
		subq.w	#1,d1
		dbra	d2,.loop

		bra.s	Eni_Decomp_Loop
; ---------------------------------------------------------------------------

Eni_Decomp_SubE:
		cmpi.w	#$F,d2
		beq.s	Eni_Decomp_End

.loop:
		bsr.s	Eni_Decomp_GetInlineCopyVal
		move.w	d1,(a1)+
		dbra	d2,.loop

		bra.s	Eni_Decomp_Loop
; ---------------------------------------------------------------------------

Eni_Decomp_JmpTable:
		bra.s	Eni_Decomp_Sub0
; ---------------------------------------------------------------------------
		bra.s	Eni_Decomp_Sub0
; ---------------------------------------------------------------------------
		bra.s	Eni_Decomp_Sub4
; ---------------------------------------------------------------------------
		bra.s	Eni_Decomp_Sub4
; ---------------------------------------------------------------------------
		bra.s	Eni_Decomp_Sub8
; ---------------------------------------------------------------------------
		bra.s	Eni_Decomp_SubA
; ---------------------------------------------------------------------------
		bra.s	Eni_Decomp_SubC
; ---------------------------------------------------------------------------
		bra.s	Eni_Decomp_SubE
; ---------------------------------------------------------------------------

Eni_Decomp_End:
		subq.w	#1,a0
		cmpi.w	#16,d6		; were we going to start on a completely new byte?
		bne.s	.got_byte	; if not, branch
		subq.w	#1,a0

.got_byte:
		move.w	a0,d0
		lsr.w	#1,d0		; are we on an odd byte?
		bhs.s	.even_loc		; if not, branch
		addq.w	#1,a0		; ensure we're on an even byte

.even_loc:
		movem.l	(sp)+,d0-d7/a1-a5
		rts

; ---------------------------------------------------------------------------
; Part of the Enigma decompressor
; Fetches an inline copy value and stores it in d1
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Eni_Decomp_GetInlineCopyVal:
		move.w	a3,d3				; store starting art tile
		move.b	d4,d1
		add.b	d1,d1
		bhs.s	.skip_pri				; if d4 was < $80
		subq.w	#1,d6				; get next bit number
		btst	d6,d5					; is the bit set?
		beq.s	.skip_pri				; if not, branch
		ori.w	#high_priority,d3		; set high priority bit

.skip_pri:
		add.b	d1,d1
		bhs.s	.skip_pal2			; if d4 was < $40
		subq.w	#1,d6				; get next bit number
		btst	d6,d5
		beq.s	.skip_pal2
		addi.w	#palette_line_2,d3	; set second palette line bit

.skip_pal2:
		add.b	d1,d1
		bhs.s	.skip_pal1			; if d4 was < $20
		subq.w	#1,d6				; get next bit number
		btst	d6,d5
		beq.s	.skip_pal1
		addi.w	#palette_line_1,d3		; set first palette line bit

.skip_pal1:
		add.b	d1,d1
		bhs.s	.skip_flipy			; if d4 was < $10
		subq.w	#1,d6				; get next bit number
		btst	d6,d5
		beq.s	.skip_flipy
		ori.w	#flip_y,d3			; set Y-flip bit

.skip_flipy:
		add.b	d1,d1
		bhs.s	.skip_flipx			; if d4 was < 8
		subq.w	#1,d6
		btst	d6,d5
		beq.s	.skip_flipx
		ori.w	#flip_x,d3			; set X-flip bit

.skip_flipx:
		move.w	d5,d1
		move.w	d6,d7				; get remaining bits
		sub.w	a5,d7				; subtract minimum bit number
		bhs.s	.got_enough			; if we're beyond that, branch
		move.w	d7,d6
		addi.w	#16,d6				; 16 bits = 2 bytes
		neg.w	d7					; calculate bit deficit
		lsl.w	d7,d1					; make space for this many bits
		move.b	(a0),d5				; get next byte
		rol.b	d7,d5					; make the upper X bits the lower X bits
		add.w	d7,d7
		and.w	Eni_Decomp_AndVals-2(pc,d7.w),d5	; only keep X lower bits
		add.w	d5,d1				; compensate for the bit deficit

.got_field:
		move.w	a5,d0
		add.w	d0,d0
		and.w	Eni_Decomp_AndVals-2(pc,d0.w),d1	; only keep as many bits as required
		add.w	d3,d1				; add starting art tile
		move.b	(a0)+,(sp)			; get current byte, move onto next byte
		move.w	(sp),d5				; shift up by a byte
		move.b	(a0)+,d5				; store next byte in lower register byte
		rts
; ---------------------------------------------------------------------------

.got_enough:
		beq.s	.got_exact			; if the exact number of bits are leftover, branch
		lsr.w	d7,d1				; remove unneeded bits
		move.w	a5,d0
		add.w	d0,d0
		and.w	Eni_Decomp_AndVals-2(pc,d0.w),d1	; only keep as many bits as required
		add.w	d3,d1				; add starting art tile
		move.w	a5,d0				; store number of bits used up by inline copy
		bra.s	Eni_Decomp_ChkGetNextByte	; move onto next byte
; ---------------------------------------------------------------------------

.got_exact:
		moveq	#16,d6				; 16 bits = 2 bytes
		bra.s	.got_field
; ---------------------------------------------------------------------------

Eni_Decomp_AndVals:
		dc.w 1
		dc.w 3
		dc.w 7
		dc.w $F
		dc.w $1F
		dc.w $3F
		dc.w $7F
		dc.w $FF
		dc.w $1FF
		dc.w $3FF
		dc.w $7FF
		dc.w $FFF
		dc.w $1FFF
		dc.w $3FFF
		dc.w $7FFF
		dc.w $FFFF

; ---------------------------------------------------------------------------
; Part of the Enigma decompressor, fetches the next byte if needed
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Eni_Decomp_ChkGetNextByte:
		sub.w	d0,d6
		cmpi.w	#9,d6
		bhs.s	.done
		addq.w	#8,d6		; 8 bits = 1 byte
		asl.w	#8,d5		; shift up by a byte
		move.b	(a0)+,d5		; store next byte in lower register byte

.done:
		rts
