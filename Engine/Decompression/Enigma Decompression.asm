; ---------------------------------------------------------------------------
; Enigma decompression subroutine by Devon Artmeier
; Inputs:
; a0 = compressed data location
; a1 = destination (in RAM)
; d0 = starting art tile
; See https://segaretro.org/Enigma_compression for format description
; See https://github.com/devon-artmeier/genesis-decompression
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Eni_Decomp:
		pea	(a1)									; save current RAM buffer (we save RAM buffer so that we don't duplicate it after decompressing is done)
		movea.w	d0,a2									; save base tile properties
		moveq	#0,d4									; get number of tile bits
		move.b	(a0)+,d4
		move.b	(a0)+,d0								; get tile flags
		lsl.b	#3,d0
		movea.w	d0,a3
		movea.w	(a0)+,a4								; get incrementing tile
		adda.w	a2,a4
		movea.w	(a0)+,a5								; get static tile
		adda.w	a2,a5
		move.w	(a0)+,d5								; get first word
		moveq	#16,d6

EniDec_GetCode:
		subq.w	#1,d6									; does the next code involve using an inline tile?
		rol.w	d5
		blo.s	.InlineTileCode								; if so, branch
		subq.w	#1,d6									; should we copy the static tile?
		rol.w	d5
		blo.s	.Mode01									; if so, branch

.Mode00
		subq.w	#4,d6									; get copy length
		rol.w	#4,d5
		move.w	d5,d0
		andi.w	#$F,d0

.Mode00Copy
		move.w	a4,(a1)+								; copy incrementing tile
		addq.w	#1,a4									; increment
		dbf	d0,.Mode00Copy								; loop until enough is copied
		bra.s	.NextCode								; process next code
; ---------------------------------------------------------------------------

.Mode01
		subq.w	#4,d6									; get copy length
		rol.w	#4,d5
		move.w	d5,d0
		andi.w	#$F,d0

.Mode01Copy
		move.w	a5,(a1)+								; copy static tile
		dbf	d0,.Mode01Copy								; loop until enough is copied

.NextCode
		cmpi.w	#8,d6									; should we get another byte?
		bhi.s	.GoToNextCode								; if not, branch
		move.w	d6,d7									; get number of bits read past byte
		subq.w	#8,d7
		neg.w	d7
		ror.w	d7,d5									; read another byte
		move.b	(a0)+,d5
		rol.w	d7,d5
		addq.w	#8,d6

.GoToNextCode
		bra.s	EniDec_GetCode								; process next code
; ---------------------------------------------------------------------------

.InlineTileCode
		subq.w	#2,d6									; get code
		rol.w	#2,d5
		move.w	d5,d1
		andi.w	#%11,d1
		subq.w	#4,d6									; get copy length
		rol.w	#4,d5
		move.w	d5,d0
		andi.w	#$F,d0
		cmpi.w	#8,d6									; should we get another byte?
		bhi.s	.HandleCode								; if not, branch
		move.w	d6,d7									; get number of bits read past byte
		subq.w	#8,d7
		neg.w	d7
		ror.w	d7,d5									; read another byte
		move.b	(a0)+,d5
		rol.w	d7,d5
		addq.w	#8,d6

.HandleCode
		add.w	d1,d1									; handle code
		jsr	.InlineCodes(pc,d1.w)
		bra.s	EniDec_GetCode								; process next code
; ---------------------------------------------------------------------------

.InlineCodes
		bra.s	EniDec_InlineMode00
		bra.s	EniDec_InlineMode01
		bra.s	EniDec_InlineMode10
; ---------------------------------------------------------------------------

		; InlineMode11
		cmpi.w	#$F,d0									; are we at the end?
		beq.s	EniDec_Done								; if so, branch

.Copy
		bsr.s	EniDec_GetInlineTile							; get tile
		move.w	d1,(a1)+								; store tile
		dbf	d0,.Copy								; loop until enough is copied
		rts
; ---------------------------------------------------------------------------

EniDec_Done:
		addq.w	#4,sp									; discard return address
		subq.w	#1,a0									; discard trailing byte
		cmpi.w	#16,d6									; are there 2 trailing bytes?
		bne.s	.End									; if not, branch
		subq.w	#1,a0									; if so, discard the other byte

.End
		movea.l	(sp)+,a1								; return saved RAM buffer
		rts
; ---------------------------------------------------------------------------

EniDec_InlineMode00:
		bsr.s	EniDec_GetInlineTile							; get tile

.Copy
		move.w	d1,(a1)+								; copy tile
		dbf	d0,.Copy								; loop until enough is copied
		rts
; ---------------------------------------------------------------------------

EniDec_InlineMode01:
		bsr.s	EniDec_GetInlineTile							; get tile

.Copy
		move.w	d1,(a1)+								; copy tile
		addq.w	#1,d1									; increment
		dbf	d0,.Copy								; loop until enough is copied
		rts
; ---------------------------------------------------------------------------

EniDec_InlineMode10:
		bsr.s	EniDec_GetInlineTile							; get tile

.Copy
		move.w	d1,(a1)+								; copy tile
		subq.w	#1,d1									; decrement
		dbf	d0,.Copy								; loop until enough is copied
		rts
; ---------------------------------------------------------------------------

EniDec_GetInlineTile:
		move.w	a3,d7									; get tile flags
		move.w	a2,d3									; get base tile properties
		add.b	d7,d7									; is the priority flag set?
		bhs.s	.CheckPalette0								; if not, branch
		subq.w	#1,d6									; does this tile have its priority flag set?
		rol.w	d5
		bhs.s	.CheckPalette0								; if not, branch
		ori.w	#setBit(15),d3								; set priority flag in base tile properties

.CheckPalette0
		add.b	d7,d7									; is the high palette bit set?
		bhs.s	.CheckPalette1								; if not, branch
		subq.w	#1,d6									; does this tile have its high palette bit set?
		rol.w	d5
		bhs.s	.CheckPalette1								; if not, branch
		addi.w	#setBit(14),d3								; offset palette in base tile properties

.CheckPalette1
		add.b	d7,d7									; is the low palette bit set?
		bhs.s	.CheckYFlip								; if not, branch
		subq.w	#1,d6									; does this tile have its low palette bit set?
		rol.w	d5
		bhs.s	.CheckYFlip								; if not, branch
		addi.w	#setBit(13),d3								; offset palette in base tile properties

.CheckYFlip
		add.b	d7,d7									; is the Y flip flag set?
		bhs.s	.CheckXFlip								; if not, branch
		subq.w	#1,d6									; does this tile have its Y flip bit set?
		rol.w	d5
		bhs.s	.CheckXFlip								; if not, branch
		ori.w	#setBit(12),d3								; set Y flip flag in base tile properties

.CheckXFlip
		add.b	d7,d7									; is the X flip flag set?
		bhs.s	.GotFlags								; if not, branch
		subq.w	#1,d6									; does this tile have its X flip bit set?
		rol.w	d5
		bhs.s	.GotFlags								; if not, branch
		ori.w	#setBit(11),d3								; set X flip flag in base tile properties

.GotFlags
		cmpi.w	#8,d6									; should we get another byte?
		bhi.s	.GetTileID								; if not, branch
		move.w	d6,d7									; get number of bits read past byte
		subq.w	#8,d7
		neg.w	d7
		ror.w	d7,d5									; read another byte
		move.b	(a0)+,d5
		rol.w	d7,d5
		addq.w	#8,d6

.GetTileID
		moveq	#0,d2									; reset upper bits
		move.w	d4,d1									; get number of bits in a tile id
		cmpi.w	#8,d1									; is it more than 8 bits?
		bls.s	.GotTileID								; if not, branch
		rol.w	#8,d5									; get first 8 bits of tile id
		move.b	d5,d2
		subq.w	#8,d1									; get remaining number of bits
		lsl.w	d1,d2
		move.w	d6,d7									; get number of bits read past byte
		subi.w	#16,d7
		neg.w	d7
		ror.w	d7,d5									; read another byte
		move.b	(a0)+,d5
		rol.w	d7,d5

.GotTileID
		sub.w	d1,d6									; get tile id bits
		rol.w	d1,d5
		move.w	d1,d7									; apply mask and base tile properties
		add.w	d7,d7
		move.w	d5,d1
		and.w	.masks-2(pc,d7.w),d1
		or.w	d2,d1
		add.w	d3,d1
		cmpi.w	#8,d6									; should we get another byte?
		bhi.s	.End									; if not, branch
		move.w	d6,d7									; get number of bits read past byte
		subq.w	#8,d7
		neg.w	d7
		ror.w	d7,d5									; read another byte
		move.b	(a0)+,d5
		rol.w	d7,d5
		addq.w	#8,d6

.End
		rts
; ---------------------------------------------------------------------------

.masks
		dc.w %0000000000000001
		dc.w %0000000000000011
		dc.w %0000000000000111
		dc.w %0000000000001111
		dc.w %0000000000011111
		dc.w %0000000000111111
		dc.w %0000000001111111
		dc.w %0000000011111111
		dc.w %0000000111111111
		dc.w %0000001111111111
		dc.w %0000011111111111
		dc.w %0000111111111111
		dc.w %0001111111111111
		dc.w %0011111111111111
		dc.w %0111111111111111
		dc.w %1111111111111111
