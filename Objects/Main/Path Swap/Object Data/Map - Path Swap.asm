; ---------------------------------------------------------------------------
; Sprite mappings - path swap
; ---------------------------------------------------------------------------

Map_PathSwap:	mappingsTable
	mappingsTableEntry.w word_1D06A
	mappingsTableEntry.w word_1D084
	mappingsTableEntry.w word_1D09E
	mappingsTableEntry.w word_1D09E
	mappingsTableEntry.w word_1D0B8
	mappingsTableEntry.w word_1D0D2
	mappingsTableEntry.w word_1D0EC
	mappingsTableEntry.w word_1D0EC

word_1D06A:	spriteHeader
	spritePiece	-8, -$20, 2, 2, 0, 0, 0, 0, 0
	spritePiece	-8, -$10, 2, 2, 0, 0, 0, 0, 0
	spritePiece	-8, 0, 2, 2, 0, 0, 0, 0, 0
	spritePiece	-8, $10, 2, 2, 0, 0, 0, 0, 0
word_1D06A_End

word_1D084:	spriteHeader
	spritePiece	-8, -$40, 2, 2, 0, 0, 0, 0, 0
	spritePiece	-8, -$20, 2, 2, 0, 0, 0, 0, 0
	spritePiece	-8, 0, 2, 2, 0, 0, 0, 0, 0
	spritePiece	-8, $30, 2, 2, 0, 0, 0, 0, 0
word_1D084_End

word_1D09E:	spriteHeader
	spritePiece	-8, -$80, 2, 2, 0, 0, 0, 0, 0
	spritePiece	-8, -$20, 2, 2, 0, 0, 0, 0, 0
	spritePiece	-8, 0, 2, 2, 0, 0, 0, 0, 0
	spritePiece	-8, $70, 2, 2, 0, 0, 0, 0, 0
word_1D09E_End

word_1D0B8:	spriteHeader
	spritePiece	-$20, -8, 2, 2, 0, 0, 0, 0, 0
	spritePiece	-$10, -8, 2, 2, 0, 0, 0, 0, 0
	spritePiece	0, -8, 2, 2, 0, 0, 0, 0, 0
	spritePiece	$10, -8, 2, 2, 0, 0, 0, 0, 0
word_1D0B8_End

word_1D0D2:	spriteHeader
	spritePiece	-$40, -8, 2, 2, 0, 0, 0, 0, 0
	spritePiece	-$20, -8, 2, 2, 0, 0, 0, 0, 0
	spritePiece	0, -8, 2, 2, 0, 0, 0, 0, 0
	spritePiece	$30, -8, 2, 2, 0, 0, 0, 0, 0
word_1D0D2_End

word_1D0EC:	spriteHeader
	spritePiece	-$80, -8, 2, 2, 0, 0, 0, 0, 0
	spritePiece	-$20, -8, 2, 2, 0, 0, 0, 0, 0
	spritePiece	0, -8, 2, 2, 0, 0, 0, 0, 0
	spritePiece	$70, -8, 2, 2, 0, 0, 0, 0, 0
word_1D0EC_End

	even
