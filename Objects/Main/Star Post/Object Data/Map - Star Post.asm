; ---------------------------------------------------------------------------
; Sprite mappings - starpost
; ---------------------------------------------------------------------------

Map_StarPost:	mappingsTable
	mappingsTableEntry.w word_2D36C
	mappingsTableEntry.w word_2D380
	mappingsTableEntry.w word_2D388

word_2D36C:	spriteHeader
	spritePiece	-4, -$18, 1, 2, $16, 0, 0, 0, 0
	spritePiece	-8, -8, 1, 4, $18, 0, 0, 0, 0
	spritePiece	0, -8, 1, 4, $18, 1, 0, 0, 0
word_2D36C_End

word_2D380:	spriteHeader
	spritePiece	-8, -8, 2, 2, $E, 0, 0, 0, 0
word_2D380_End

word_2D388:	spriteHeader
	spritePiece	-8, -8, 2, 2, $12, 0, 0, 0, 0
word_2D388_End

	even
