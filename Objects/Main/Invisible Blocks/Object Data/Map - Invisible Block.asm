; ---------------------------------------------------------------------------
; Sprite mappings - invisible solid blocks
; ---------------------------------------------------------------------------

Map_InvisibleBlock:	mappingsTable
	mappingsTableEntry.w word_1ECCC
	mappingsTableEntry.w word_1ECE6
	mappingsTableEntry.w word_1ED00

word_1ECCC:	spriteHeader
	spritePiece	-$10, -$10, 2, 2, $1C, 0, 0, 0, 0
	spritePiece	0, -$10, 2, 2, $1C, 0, 0, 0, 0
	spritePiece	-$10, 0, 2, 2, $1C, 0, 0, 0, 0
	spritePiece	0, 0, 2, 2, $1C, 0, 0, 0, 0
word_1ECCC_End

word_1ECE6:	spriteHeader
	spritePiece	-$40, -$20, 2, 2, $1C, 0, 0, 0, 0
	spritePiece	$30, -$20, 2, 2, $1C, 0, 0, 0, 0
	spritePiece	-$40, $10, 2, 2, $1C, 0, 0, 0, 0
	spritePiece	$30, $10, 2, 2, $1C, 0, 0, 0, 0
word_1ECE6_End

word_1ED00:	spriteHeader
	spritePiece	-$80, -$20, 2, 2, $1C, 0, 0, 0, 0
	spritePiece	$70, -$20, 2, 2, $1C, 0, 0, 0, 0
	spritePiece	-$80, $10, 2, 2, $1C, 0, 0, 0, 0
	spritePiece	$70, $10, 2, 2, $1C, 0, 0, 0, 0
word_1ED00_End

	even
