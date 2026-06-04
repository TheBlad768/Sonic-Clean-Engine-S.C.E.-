; ---------------------------------------------------------------------------
; Sprite mappings - animals
; ---------------------------------------------------------------------------

Map_Animals2:	mappingsTable
	mappingsTableEntry.w word_2CEE6
	mappingsTableEntry.w word_2CEEE
	mappingsTableEntry.w word_2CEDE

word_2CEDE:	spriteHeader
	spritePiece	-8, -$C, 2, 3, 0, 0, 0, 0, 0
word_2CEDE_End

word_2CEE6:	spriteHeader
	spritePiece	-$C, -8, 3, 2, 6, 0, 0, 0, 0
word_2CEE6_End

word_2CEEE:	spriteHeader
	spritePiece	-$C, -8, 3, 2, $C, 0, 0, 0, 0
word_2CEEE_End

	even
