; ---------------------------------------------------------------------------
; Target palette loading subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

PalLoad1:
LoadPalette:
		lea	(PalPointers).l,a1
		lsl.w	#3,d0
		adda.w	d0,a1
		movea.l	(a1)+,a2		; get palette data address
		movea.w	(a1)+,a3		; get target RAM address
		adda.w	#Target_palette-Normal_palette,a3	; skip to "Normal_palette" RAM address
		move.w	(a1)+,d7		; get length of palette data

-		move.l	(a2)+,(a3)+	; move data to RAM
		dbf	d7,-
		rts
; End of function LoadPalette
; ---------------------------------------------------------------------------
; Normal palette loading subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

PalLoad2:
LoadPalette_Immediate:
		lea	(PalPointers).l,a1
		lsl.w	#3,d0
		adda.w	d0,a1
		movea.l	(a1)+,a2		; get palette data address
		movea.w	(a1)+,a3		; get target RAM address
		move.w	(a1)+,d7		; get length of palette

-		move.l	(a2)+,(a3)+	; move data to RAM
		dbf	d7,-
		rts
; End of function LoadPalette_Immediate
; ---------------------------------------------------------------------------
; Underwater normal palette loading subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

LoadPalette2:
PalLoad3_Water:
		lea	(PalPointers).l,a1
		lsl.w	#3,d0
		adda.w	d0,a1
		movea.l	(a1)+,a2		; get palette data address
		movea.w	(a1)+,a3		; get target RAM address
		move.w	(a1)+,d7		; get length of palette data

-		move.l	(a2)+,(a3)+	; move data to RAM
		dbf	d7,-
		rts
; End of function LoadPalette2
; ---------------------------------------------------------------------------
; Underwater target palette loading subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

PalLoad4_Water:
LoadPalette2_Immediate:
		lea	(PalPointers).l,a1
		lsl.w	#3,d0
		adda.w	d0,a1
		movea.l	(a1)+,a2		; get palette data address
		movea.w	(a1)+,a3		; get target RAM address
		suba.w	#Water_palette-Target_water_palette,a3	; skip to "Water_palette" RAM address
		move.w	(a1)+,d7		; get length of palette data

-		move.l	(a2)+,(a3)+	; move data to RAM
		dbf	d7,-
		rts
; End of function LoadPalette2_Immediate
; =============== S U B R O U T I N E =======================================

PalTLoad_Line0:
		lea	(Target_palette_line_1).w,a2
		bra.s	PalLoad_Line16
; End of function PalTLoad_Line0

; =============== S U B R O U T I N E =======================================

PalTLoad_Line1:
		lea	(Target_palette_line_2).w,a2
		bra.s	PalLoad_Line16
; End of function PalTLoad_Line1

; =============== S U B R O U T I N E =======================================

PalTLoad_Line2:
		lea	(Target_palette_line_3).w,a2
		bra.s	PalLoad_Line16
; End of function PalTLoad_Line2

; =============== S U B R O U T I N E =======================================

PalTLoad_Line3:
		lea	(Target_palette_line_4).w,a2
		bra.s	PalLoad_Line16
; End of function PalTLoad_Line3

; =============== S U B R O U T I N E =======================================

PalLoad_Line0:
		lea	(Normal_palette_line_1).w,a2
		bra.s	PalLoad_Line16
; End of function PalLoad_Line0

; =============== S U B R O U T I N E =======================================

PalLoad_Line1:
		lea	(Normal_palette_line_2).w,a2
		bra.s	PalLoad_Line16
; End of function PalLoad_Line1

; =============== S U B R O U T I N E =======================================

PalLoad_Line2:
		lea	(Normal_palette_line_3).w,a2
		bra.s	PalLoad_Line16
; End of function PalLoad_Line2

; =============== S U B R O U T I N E =======================================

PalLoad_Line3:
		lea	(Normal_palette_line_4).w,a2
		bra.s	PalLoad_Line16
; End of function PalLoad_Line2

; =============== S U B R O U T I N E =======================================

PalLoad_Line64:
	rept 16/2
		move.l	(a1)+,(a2)+
	endm

PalLoad_Line48:
	rept 16/2
		move.l	(a1)+,(a2)+
	endm

PalLoad_Line32:
	rept 16/2
		move.l	(a1)+,(a2)+
	endm

PalLoad_Line16:
	rept 16/2
		move.l	(a1)+,(a2)+
	endm

		rts
; End of function PalLoad_Line

; =============== S U B R O U T I N E =======================================

Clear_Palette:
		moveq	#0,d0

Clear_Palette2:
		moveq	#(64/2)-1,d1

Clear_Palette3:
		lea	(Target_palette).w,a1
		lea	(Normal_palette).w,a2

-		move.l	d0,(a1)+
		move.l	d0,(a2)+
		dbf	d1,-
		rts
; End of function Clear_Palette
