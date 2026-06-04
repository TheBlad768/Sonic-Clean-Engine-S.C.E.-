; ---------------------------------------------------------------------------
; Sprite mappings - animals
; ---------------------------------------------------------------------------

Map_Animals5:	mappingsTable
	mappingsTableEntry.w word_2CF40
	mappingsTableEntry.w word_2CF48
	mappingsTableEntry.w word_2CF38

word_2CF38:	spriteHeader
	spritePiece	-8, -$C, 2, 3, 0, 0, 0, 0, 0
word_2CF38_End

word_2CF40:	spriteHeader
	spritePiece	-8, -$C, 2, 3, 6, 0, 0, 0, 0
word_2CF40_End

word_2CF48:	spriteHeader
	spritePiece	-8, -$C, 2, 3, $C, 0, 0, 0, 0
word_2CF48_End

	even
