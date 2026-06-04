; ---------------------------------------------------------------------------
; Sprite mappings - SCORE, TIME, RINGS
; ---------------------------------------------------------------------------

Map_HUD:	mappingsTable
	mappingsTableEntry.w word_DBC2		; 0 ; normal
	mappingsTableEntry.w word_DC00		; 1 ; hide rings
	mappingsTableEntry.w word_DC32		; 2 ; hide time
	mappingsTableEntry.w word_DC6A		; 3 ; hide rings and time
	mappingsTableEntry.w word_DC96		; 4 ; draw rings only (Bonus Stage)
	mappingsTableEntry.w word_DCB6		; 5 ; hide rings (Bonus Stage)

word_DBC2:	spriteHeader
	spritePiece	0, -$80, 4, 2, 0, 0, 0, 1, 0
	spritePiece	$20, -$80, 4, 2, $14, 0, 0, 1, 0
	spritePiece	$40, -$80, 4, 2, $1C, 0, 0, 1, 0
	spritePiece	0, -$70, 4, 2, $E, 0, 0, 1, 0
	spritePiece	$28, -$70, 4, 2, $24, 0, 0, 1, 0
	spritePiece	0, -$60, 4, 2, 6, 0, 0, 1, 0
	spritePiece	$20, -$60, 1, 2, 0, 0, 0, 1, 0
	spritePiece	$30, -$60, 3, 2, $32, 0, 0, 1, 0
word_DBC2_End

word_DC00:	spriteHeader
	spritePiece	0, -$80, 4, 2, 0, 0, 0, 1, 0
	spritePiece	$20, -$80, 4, 2, $14, 0, 0, 1, 0
	spritePiece	$40, -$80, 4, 2, $1C, 0, 0, 1, 0
	spritePiece	0, -$70, 4, 2, $E, 0, 0, 1, 0
	spritePiece	$28, -$70, 4, 2, $24, 0, 0, 1, 0
	spritePiece	$30, -$60, 3, 2, $32, 0, 0, 1, 0
word_DC00_End

word_DC32:	spriteHeader
	spritePiece	0, -$80, 4, 2, 0, 0, 0, 1, 0
	spritePiece	$20, -$80, 4, 2, $14, 0, 0, 1, 0
	spritePiece	$40, -$80, 4, 2, $1C, 0, 0, 1, 0
	spritePiece	$28, -$70, 4, 2, $24, 0, 0, 1, 0
	spritePiece	0, -$60, 4, 2, 6, 0, 0, 1, 0
	spritePiece	$20, -$60, 1, 2, 0, 0, 0, 1, 0
	spritePiece	$30, -$60, 3, 2, $32, 0, 0, 1, 0
word_DC32_End

word_DC6A:	spriteHeader
	spritePiece	0, -$80, 4, 2, 0, 0, 0, 1, 0
	spritePiece	$20, -$80, 4, 2, $14, 0, 0, 1, 0
	spritePiece	$40, -$80, 4, 2, $1C, 0, 0, 1, 0
	spritePiece	$28, -$70, 4, 2, $24, 0, 0, 1, 0
	spritePiece	$30, -$60, 3, 2, $32, 0, 0, 1, 0
word_DC6A_End

word_DC96:	spriteHeader
	spritePiece	0, -$80, 4, 2, 6, 0, 0, 1, 0
	spritePiece	$20, -$80, 1, 2, 0, 0, 0, 1, 0
	spritePiece	$30, -$80, 3, 2, $32, 0, 0, 1, 0
word_DC96_End

word_DCB6:	spriteHeader
	spritePiece	$30, -$80, 3, 2, $32, 0, 0, 1, 0
word_DCB6_End

	even
