; ---------------------------------------------------------------------------
; Sprite mappings - switches
; ---------------------------------------------------------------------------

Map_Button:	mappingsTable
	mappingsTableEntry.w word_2C724
	mappingsTableEntry.w word_2C732
	mappingsTableEntry.w word_2C73A

word_2C724:	spriteHeader
	spritePiece	-$10, -$C, 4, 1, 0, 0, 0, 0, 0
	spritePiece	-8, -4, 2, 1, 4, 0, 0, 0, 0
word_2C724_End

word_2C732:	spriteHeader
	spritePiece	-$10, -4, 4, 1, 0, 0, 0, 0, 0
word_2C732_End

word_2C73A:	spriteHeader
	spritePiece	-$10, -8, 4, 1, 0, 0, 0, 0, 0
	spritePiece	-8, 0, 2, 1, 4, 0, 0, 0, 0
word_2C73A_End

	even
