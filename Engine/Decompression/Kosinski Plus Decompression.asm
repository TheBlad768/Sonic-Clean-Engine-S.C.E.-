; ---------------------------------------------------------------------------
; Kosinski Plus decompression subroutine
; Inputs:
; a0 = compressed data location
; a1 = destination
; See https://segaretro.org/Kosinski_compression for format description
; Created originally by Flamewing and vladikcomper, further improvements by Clownacy
; See https://github.com/flamewing/mdcomp
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

KosPlusArt_To_VDP:
		lea	(a1),a3							; a1 will be changed by KosPlus_Decomp, so we're backing it up to a3
		bsr.s	KosPlus_Decomp						; "
		move.l	a3,d1							; move the backed-up a1 to d1. d1 will be used in the DMA transfer as the Source Address
		lsr.l	d1							; divide source address by 2
		move.l	a1,d3							; move end address of decompressed art to d3
		sub.l	a3,d3							; subtract 'start address of decompressed art' from 'end address of decompressed art', giving you the size of the decompressed art
		lsr.l	d3							; divide size of decompressed art by two, d3 will be used in the DMA transfer as the Transfer Length (size/2)
		move.w	a2,d2							; move VRAM address to d2, d2 will be used in the DMA transfer as the Destination Address
		lea	(a1),a3							; backup a1, this allows the same address to be used by multiple calls to KosArt_To_VDP without constant redefining
		bsr.w	Add_To_DMA_Queue					; transfer *Transfer Length* of data from *Source Address* to *Destination Address*
		lea	(a3),a1							; restore a1
		rts

; =============== S U B R O U T I N E =======================================

KosPlus_Decomp:		include "Engine/Decompression/Kosinski Plus Internal.asm"
		rts