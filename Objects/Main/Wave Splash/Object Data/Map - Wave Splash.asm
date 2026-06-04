; ---------------------------------------------------------------------------
; Sprite mappings - water surface
; ---------------------------------------------------------------------------

Map_WaveSplash:	mappingsTable
	mappingsTableEntry.w word_1F2DC		; 0 (duplicate)
	mappingsTableEntry.w word_1F2DC		; 1 (duplicate)
	mappingsTableEntry.w word_1F2F0		; 2
	mappingsTableEntry.w word_1F304		; 3
	mappingsTableEntry.w word_1F318		; 4
	mappingsTableEntry.w word_1F33E		; 5
	mappingsTableEntry.w word_1F364		; 6

word_1F2DC:	spriteHeader
	spritePiece	-$60, -3, 4, 2, 0, 0, 0, 0, 0
	spritePiece	-$20, -3, 4, 2, 0, 0, 0, 0, 0
	spritePiece	$20, -3, 4, 2, 0, 0, 0, 0, 0
word_1F2DC_End

word_1F2F0:	spriteHeader
	spritePiece	-$60, -3, 4, 2, 8, 0, 0, 0, 0
	spritePiece	-$20, -3, 4, 2, 8, 0, 0, 0, 0
	spritePiece	$20, -3, 4, 2, 8, 0, 0, 0, 0
word_1F2F0_End

word_1F304:	spriteHeader
	spritePiece	-$60, -3, 4, 2, 0, 1, 0, 0, 0
	spritePiece	-$20, -3, 4, 2, 0, 1, 0, 0, 0
	spritePiece	$20, -3, 4, 2, 0, 1, 0, 0, 0
word_1F304_End

word_1F318:	spriteHeader
	spritePiece	-$60, -3, 4, 2, 0, 0, 0, 0, 0
	spritePiece	-$40, -3, 4, 2, 0, 0, 0, 0, 0
	spritePiece	-$20, -3, 4, 2, 0, 0, 0, 0, 0
	spritePiece	0, -3, 4, 2, 0, 0, 0, 0, 0
	spritePiece	$20, -3, 4, 2, 0, 0, 0, 0, 0
	spritePiece	$40, -3, 4, 2, 0, 0, 0, 0, 0
word_1F318_End

word_1F33E:	spriteHeader
	spritePiece	-$60, -3, 4, 2, 8, 0, 0, 0, 0
	spritePiece	-$40, -3, 4, 2, 8, 0, 0, 0, 0
	spritePiece	-$20, -3, 4, 2, 8, 0, 0, 0, 0
	spritePiece	0, -3, 4, 2, 8, 0, 0, 0, 0
	spritePiece	$20, -3, 4, 2, 8, 0, 0, 0, 0
	spritePiece	$40, -3, 4, 2, 8, 0, 0, 0, 0
word_1F33E_End

word_1F364:	spriteHeader
	spritePiece	-$60, -3, 4, 2, 0, 1, 0, 0, 0
	spritePiece	-$40, -3, 4, 2, 0, 1, 0, 0, 0
	spritePiece	-$20, -3, 4, 2, 0, 1, 0, 0, 0
	spritePiece	0, -3, 4, 2, 0, 1, 0, 0, 0
	spritePiece	$20, -3, 4, 2, 0, 1, 0, 0, 0
	spritePiece	$40, -3, 4, 2, 0, 1, 0, 0, 0
word_1F364_End

	even
