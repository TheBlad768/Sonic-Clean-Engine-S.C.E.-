; ---------------------------------------------------------------------------
; Sprite mappings - animals
; ---------------------------------------------------------------------------

Map_Animals4:	mappingsTable
	mappingsTableEntry.w word_2CF22
	mappingsTableEntry.w word_2CF2A
	mappingsTableEntry.w word_2CF1A

word_2CF1A:	spriteHeader
	spritePiece	-8, -8, 2, 3, 0, 0, 0, 0, 0
word_2CF1A_End

word_2CF22:	spriteHeader
	spritePiece	-8, -4, 2, 2, 6, 0, 0, 0, 0
word_2CF22_End

word_2CF2A:	spriteHeader
	spritePiece	-8, -4, 2, 2, $A, 0, 0, 0, 0
word_2CF2A_End

	even
