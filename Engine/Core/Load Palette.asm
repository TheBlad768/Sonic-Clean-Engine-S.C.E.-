; ---------------------------------------------------------------------------
; Target palette loading subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

LoadPalette:
		lea	(PalPointers).l,a1
		lsl.w	#3,d0								; multiply by 8
		adda.w	d0,a1

.load
		movea.l	(a1)+,a2							; get palette data address
		movea.w	(a1)+,a3							; get target RAM address
		move.w	(a1)+,d0							; get length of palette data
		lea	Target_palette-Normal_palette(a3),a3				; skip to "Normal_palette" RAM address

.copy
		move.l	(a2)+,(a3)+							; move data to RAM
		dbf	d0,.copy
		rts

; ---------------------------------------------------------------------------
; Normal palette loading subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

LoadPalette_Immediate:
		lea	(PalPointers).l,a1
		lsl.w	#3,d0								; multiply by 8
		adda.w	d0,a1

.load
		movea.l	(a1)+,a2							; get palette data address
		movea.w	(a1)+,a3							; get target RAM address
		move.w	(a1)+,d0							; get length of palette

.copy
		move.l	(a2)+,(a3)+							; move data to RAM
		dbf	d0,.copy
		rts

; ---------------------------------------------------------------------------
; Underwater normal palette loading subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

LoadPalette2:
		lea	(PalPointers).l,a1
		lsl.w	#3,d0								; multiply by 8
		adda.w	d0,a1

.load
		movea.l	(a1)+,a2							; get palette data address
		movea.w	(a1)+,a3							; get target RAM address
		move.w	(a1)+,d0							; get length of palette data
		lea	-(Normal_palette-Water_palette)(a3),a3				; skip to "Water_palette" RAM address

.copy
		move.l	(a2)+,(a3)+							; move data to RAM
		dbf	d0,.copy
		rts

; ---------------------------------------------------------------------------
; Underwater target palette loading subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

LoadPalette2_Immediate:
		lea	(PalPointers).l,a1
		lsl.w	#3,d0								; multiply by 8
		adda.w	d0,a1

.load
		movea.l	(a1)+,a2							; get palette data address
		movea.w	(a1)+,a3							; get target RAM address
		move.w	(a1)+,d0							; get length of palette data
		lea	-(Normal_palette-Target_water_palette)(a3),a3			; skip to "Target_water_palette" RAM address

.copy
		move.l	(a2)+,(a3)+							; move data to RAM
		dbf	d0,.copy
		rts

; ---------------------------------------------------------------------------
; Load palette
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

PalLoad_Line64:

	rept 16/2
		move.l	(a1)+,(a2)+
	endr

PalLoad_Line48:

	rept 16/2
		move.l	(a1)+,(a2)+
	endr

PalLoad_Line32:

	rept 16/2
		move.l	(a1)+,(a2)+
	endr

PalLoad_Line16:

	rept 16/2
		move.l	(a1)+,(a2)+
	endr

		rts

; ---------------------------------------------------------------------------
; Clear palette
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Clear_Palette:
		moveq	#cBlack,d0

Clear_Palette2:
		moveq	#bytesToXcnt(64,8),d1

Clear_Palette3:
		lea	(Target_palette).w,a1
		lea	(Normal_palette).w,a2

.clear

	rept 8
		move.l	d0,(a1)+
		move.l	d0,(a2)+
	endr

		dbf	d1,.clear
		rts
