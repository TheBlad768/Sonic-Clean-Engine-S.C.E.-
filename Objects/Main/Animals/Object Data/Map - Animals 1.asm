; ---------------------------------------------------------------------------
; Sprite mappings - animals
; ---------------------------------------------------------------------------

Map_Animals1:	mappingsTable
	mappingsTableEntry.w word_2CEC8
	mappingsTableEntry.w word_2CED0
	mappingsTableEntry.w word_2CEC0

word_2CEC0:	spriteHeader
	spritePiece	-8, -$C, 2, 3, 0, 0, 0, 0, 0
word_2CEC0_End

word_2CEC8:	spriteHeader
	spritePiece	-8, -8, 2, 2, 6, 0, 0, 0, 0
word_2CEC8_End

word_2CED0:	spriteHeader
	spritePiece	-8, -8, 2, 2, $A, 0, 0, 0, 0
word_2CED0_End

	even
