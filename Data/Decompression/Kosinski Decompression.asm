; ---------------------------------------------------------------------------
; Kosinski decompression subroutine
; Inputs:
; a0 = compressed data location
; a1 = destination
; See http://www.segaretro.org/Kosinski_compression for format description
; New faster version by written by Vladikcomper, with additional improvements by MarkeyJester and Flamewing
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

KosArt_To_VDP:
		movea.l	a1,a3						; a1 will be changed by Kos_Decomp, so we're backing it up to a3
		bsr.s	Kos_Decomp
		move.l	a3,d1						; move the backed-up a1 to d1
		andi.l	#$FFFFFF,d1					; d1 will be used in the DMA transfer as the Source Address
		move.l	a1,d3						; move end address of decompressed art to d3
		sub.l	a3,d3						; subtract 'start address of decompressed art' from 'end address of decompressed art', giving you the size of the decompressed art
		lsr.l	#1,d3							; divide size of decompressed art by two, d3 will be used in the DMA transfer as the Transfer Length (size/2)
		move.w	a2,d2						; move VRAM address to d2, d2 will be used in the DMA transfer as the Destination Address
		movea.l	a1,a3						; backup a1, this allows the same address to be used by multiple calls to KosArt_To_VDP without constant redefining
		bsr.w	Add_To_DMA_Queue			; transfer *Transfer Length* of data from *Source Address* to *Destination Address*
		movea.l	a3,a1						; restore a1
		rts
; End of function KosArt_To_VDP

; =============== S U B R O U T I N E =======================================

KosDec:
Kos_Decomp:
		movem.l	d0-d7/a4-a5,-(sp)
		moveq	#(1<<_Kos_LoopUnroll)-1,d7
	if _Kos_UseLUT==1
		moveq	#0,d0
		moveq	#0,d1
		lea	KosDec_ByteMap(pc),a4			; Load LUT pointer.
	endif
		move.b	(a0)+,d0						; Get desc field low-byte.
		move.b	(a0)+,d1						; Get desc field hi-byte.
	if _Kos_UseLUT==1
		move.b	(a4,d0.w),d0					; Invert bit order...
		move.b	(a4,d1.w),d1					; ... for both bytes.
	endif
		moveq	#7,d2						; Set repeat count to 8.
		moveq	#0,d3						; d3 will be desc field switcher.
		bra.s	.FetchNewCode
; ---------------------------------------------------------------------------

.FetchCodeLoop:
		; Code 1 (Uncompressed byte).
	_Kos_RunBitStream
		move.b	(a0)+,(a1)+

.FetchNewCode:
	_Kos_ReadBit
		bcs.s	.FetchCodeLoop				; If code = 1, branch.

		; Codes 00 and 01.
		moveq	#-1,d5
		lea	(a1),a5
	_Kos_RunBitStream
	if _Kos_ExtremeUnrolling==1
	_Kos_ReadBit
		bcs.w	.Code_01

		; Code 00 (Dictionary ref. short).
	_Kos_RunBitStream
	_Kos_ReadBit
		bcs.s	.Copy45
	_Kos_RunBitStream
	_Kos_ReadBit
		bcs.s	.Copy3
	_Kos_RunBitStream
		move.b	(a0)+,d5						; d5 = displacement.
		adda.w	d5,a5
		move.b	(a5)+,(a1)+
		move.b	(a5)+,(a1)+
		bra.s	.FetchNewCode
; ---------------------------------------------------------------------------

.Copy3:
	_Kos_RunBitStream
		move.b	(a0)+,d5						; d5 = displacement.
		adda.w	d5,a5
		move.b	(a5)+,(a1)+
		move.b	(a5)+,(a1)+
		move.b	(a5)+,(a1)+
		bra.w	.FetchNewCode
; ---------------------------------------------------------------------------

.Copy45:
	_Kos_RunBitStream
	_Kos_ReadBit
		bcs.s	.Copy5
	_Kos_RunBitStream
		move.b	(a0)+,d5						; d5 = displacement.
		adda.w	d5,a5
		move.b	(a5)+,(a1)+
		move.b	(a5)+,(a1)+
		move.b	(a5)+,(a1)+
		move.b	(a5)+,(a1)+
		bra.w	.FetchNewCode
; ---------------------------------------------------------------------------

.Copy5:
	_Kos_RunBitStream
		move.b	(a0)+,d5						; d5 = displacement.
		adda.w	d5,a5
		move.b	(a5)+,(a1)+
		move.b	(a5)+,(a1)+
		move.b	(a5)+,(a1)+
		move.b	(a5)+,(a1)+
		move.b	(a5)+,(a1)+
		bra.w	.FetchNewCode
; ---------------------------------------------------------------------------
	else
		moveq	#0,d4						; d4 will contain copy count.
	_Kos_ReadBit
		bcs.s	.Code_01

		; Code 00 (Dictionary ref. short).
	_Kos_RunBitStream
	_Kos_ReadBit
		addx.w	d4,d4
	_Kos_RunBitStream
	_Kos_ReadBit
		addx.w	d4,d4
	_Kos_RunBitStream
		move.b	(a0)+,d5						; d5 = displacement.

.StreamCopy:
		adda.w	d5,a5
		move.b	(a5)+,(a1)+					; Do 1 extra copy (to compensate +1 to copy counter).

.copy:
		move.b	(a5)+,(a1)+
		dbra	d4,.copy
		bra.w	.FetchNewCode
	endif
; ---------------------------------------------------------------------------

.Code_01:
		moveq	#0,d4						; d4 will contain copy count.
		; Code 01 (Dictionary ref. long / special).
	_Kos_RunBitStream
		move.b	(a0)+,d6						; d6 = %LLLLLLLL.
		move.b	(a0)+,d4						; d4 = %HHHHHCCC.
		move.b	d4,d5						; d5 = %11111111 HHHHHCCC.
		lsl.w	#5,d5							; d5 = %111HHHHH CCC00000.
		move.b	d6,d5						; d5 = %111HHHHH LLLLLLLL.
	if _Kos_LoopUnroll==3
		and.w	d7,d4						; d4 = %00000CCC.
	else
		andi.w	#7,d4
	endif
		bne.s	.StreamCopy					; if CCC=0, branch.

		; special mode (extended counter)
		move.b	(a0)+,d4						; Read cnt
		beq.s	.Quit						; If cnt=0, quit decompression.
		subq.b	#1,d4
		beq.w	.FetchNewCode				; If cnt=1, fetch a new code.

		adda.w	d5,a5
		move.b	(a5)+,(a1)+					; Do 1 extra copy (to compensate +1 to copy counter).
		move.w	d4,d6
		not.w	d6
		and.w	d7,d6
		add.w	d6,d6
		lsr.w	#_Kos_LoopUnroll,d4
		jmp	.largecopy(pc,d6.w)
; ---------------------------------------------------------------------------

.largecopy:
	rept (1<<_Kos_LoopUnroll)
		move.b	(a5)+,(a1)+
	endm
		dbra	d4,.largecopy
		bra.w	.FetchNewCode
; ---------------------------------------------------------------------------

	if _Kos_ExtremeUnrolling==1
.StreamCopy:
		adda.w	d5,a5
		move.b	(a5)+,(a1)+					; Do 1 extra copy (to compensate +1 to copy counter).
	if _Kos_LoopUnroll==3
		eor.w	d7,d4
	else
		eori.w	#7,d4
	endif
		add.w	d4,d4
		jmp	.mediumcopy(pc,d4.w)
; ---------------------------------------------------------------------------

.mediumcopy:
	rept 8
		move.b	(a5)+,(a1)+
	endm
		bra.w	.FetchNewCode
	endif
; ---------------------------------------------------------------------------

.Quit:
		movem.l	(sp)+,d0-d7/a4-a5
		rts
; End of function Kos_Decomp
; ---------------------------------------------------------------------------

	if _Kos_UseLUT==1
KosDec_ByteMap:
		dc.b	$00,$80,$40,$C0,$20,$A0,$60,$E0,$10,$90,$50,$D0,$30,$B0,$70,$F0
		dc.b	$08,$88,$48,$C8,$28,$A8,$68,$E8,$18,$98,$58,$D8,$38,$B8,$78,$F8
		dc.b	$04,$84,$44,$C4,$24,$A4,$64,$E4,$14,$94,$54,$D4,$34,$B4,$74,$F4
		dc.b	$0C,$8C,$4C,$CC,$2C,$AC,$6C,$EC,$1C,$9C,$5C,$DC,$3C,$BC,$7C,$FC
		dc.b	$02,$82,$42,$C2,$22,$A2,$62,$E2,$12,$92,$52,$D2,$32,$B2,$72,$F2
		dc.b	$0A,$8A,$4A,$CA,$2A,$AA,$6A,$EA,$1A,$9A,$5A,$DA,$3A,$BA,$7A,$FA
		dc.b	$06,$86,$46,$C6,$26,$A6,$66,$E6,$16,$96,$56,$D6,$36,$B6,$76,$F6
		dc.b	$0E,$8E,$4E,$CE,$2E,$AE,$6E,$EE,$1E,$9E,$5E,$DE,$3E,$BE,$7E,$FE
		dc.b	$01,$81,$41,$C1,$21,$A1,$61,$E1,$11,$91,$51,$D1,$31,$B1,$71,$F1
		dc.b	$09,$89,$49,$C9,$29,$A9,$69,$E9,$19,$99,$59,$D9,$39,$B9,$79,$F9
		dc.b	$05,$85,$45,$C5,$25,$A5,$65,$E5,$15,$95,$55,$D5,$35,$B5,$75,$F5
		dc.b	$0D,$8D,$4D,$CD,$2D,$AD,$6D,$ED,$1D,$9D,$5D,$DD,$3D,$BD,$7D,$FD
		dc.b	$03,$83,$43,$C3,$23,$A3,$63,$E3,$13,$93,$53,$D3,$33,$B3,$73,$F3
		dc.b	$0B,$8B,$4B,$CB,$2B,$AB,$6B,$EB,$1B,$9B,$5B,$DB,$3B,$BB,$7B,$FB
		dc.b	$07,$87,$47,$C7,$27,$A7,$67,$E7,$17,$97,$57,$D7,$37,$B7,$77,$F7
		dc.b	$0F,$8F,$4F,$CF,$2F,$AF,$6F,$EF,$1F,$9F,$5F,$DF,$3F,$BF,$7F,$FF
	endif