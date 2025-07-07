	if _KosPlus_LoopUnroll>0
		moveq	#(1<<_KosPlus_LoopUnroll)-1,d7
	endif
		moveq	#0,d2								; flag as having no bits left.
		bra.s	.FetchNewCode
; ---------------------------------------------------------------------------

.FetchCodeLoop

		; code 1 (Uncompressed byte).
		move.b	(a0)+,(a1)+

.FetchNewCode
	_KosPlus_ReadBit
		blo.s	.FetchCodeLoop							; if code = 1, branch.

		; codes 00 and 01.
		moveq	#-1,d5
		lea	(a1),a5
	_KosPlus_ReadBit
		blo.s	.Code_01

		; code 00 (Dictionary ref. short).
		move.b	(a0)+,d5							; d5 = displacement.
		adda.w	d5,a5

		; always copy at least two bytes.
		move.b	(a5)+,(a1)+
		move.b	(a5)+,(a1)+
	_KosPlus_ReadBit
		bhs.s	.Copy_01
		move.b	(a5)+,(a1)+
		move.b	(a5)+,(a1)+

.Copy_01
	_KosPlus_ReadBit
		bhs.s	.FetchNewCode
		move.b	(a5)+,(a1)+
		bra.s	.FetchNewCode
; ---------------------------------------------------------------------------

.Code_01
		moveq	#0,d4								; d4 will contain copy count.

		; code 01 (Dictionary ref. long / special).
		move.b	(a0)+,d4							; d4 = %HHHHHCCC.
		move.b	d4,d5								; d5 = %11111111 HHHHHCCC.
		lsl.w	#5,d5								; d5 = %111HHHHH CCC00000.
		move.b	(a0)+,d5							; d5 = %111HHHHH LLLLLLLL.

	if _KosPlus_LoopUnroll==3
		and.w	d7,d4								; d4 = %00000CCC.
	else
		andi.w	#7,d4
	endif

	if _KosPlus_LoopUnroll>0
		bne.s	.StreamCopy							; if CCC=0, branch.

		; special mode (extended counter)
		move.b	(a0)+,d4							; read cnt
		beq.s	.Quit								; if cnt=0, quit decompression.

		adda.w	d5,a5
		move.w	d4,d6
		not.w	d6
		and.w	d7,d6
		add.w	d6,d6
		lsr.w	#_KosPlus_LoopUnroll,d4
		jmp	.largecopy(pc,d6.w)
	else
		beq.s	.dolargecopy
	endif
; ---------------------------------------------------------------------------

.StreamCopy
		adda.w	d5,a5
		move.b	(a5)+,(a1)+							; do 1 extra copy (to compensate +1 to copy counter).
		add.w	d4,d4
		jmp	.mediumcopy-2(pc,d4.w)
; ---------------------------------------------------------------------------

	if _KosPlus_LoopUnroll==0
.dolargecopy

		; special mode (extended counter)
		move.b	(a0)+,d4							; read cnt
		beq.s	.Quit								; if cnt=0, quit decompression.
		adda.w	d5,a5
	endif

.largecopy

	rept (1<<_KosPlus_LoopUnroll)
		move.b	(a5)+,(a1)+
	endr

		dbf	d4,.largecopy

.mediumcopy

	rept 8
		move.b	(a5)+,(a1)+
	endr

		bra.w	.FetchNewCode
; ---------------------------------------------------------------------------

.Quit