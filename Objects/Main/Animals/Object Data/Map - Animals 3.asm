; ---------------------------------------------------------------------------
; Sprite mappings - animals
; ---------------------------------------------------------------------------

Map_Animals3:	mappingsTable
	mappingsTableEntry.w word_2CF04
	mappingsTableEntry.w word_2CF0C
	mappingsTableEntry.w word_2CEFC

word_2CEFC:	spriteHeader
	spritePiece	-8, -$C, 2, 3, 0, 0, 0, 0, 0
word_2CEFC_End

word_2CF04:	spriteHeader
	spritePiece	-$C, -8, 3, 2, 6, 0, 0, 0, 0
word_2CF04_End

word_2CF0C:	spriteHeader
	spritePiece	-$C, -8, 3, 2, $C, 0, 0, 0, 0
word_2CF0C_End

	even
