; ---------------------------------------------------------------------------
; Sprite mappings - bubbler
; ---------------------------------------------------------------------------

Map_Bubbler:	mappingsTable
	mappingsTableEntry.w word_2FD0E
	mappingsTableEntry.w word_2FD16
	mappingsTableEntry.w word_2FD1E
	mappingsTableEntry.w word_2FD26
	mappingsTableEntry.w word_2FD2E
	mappingsTableEntry.w word_2FD36
	mappingsTableEntry.w word_2FD3E
	mappingsTableEntry.w word_2FD46
	mappingsTableEntry.w word_2FD60
	mappingsTableEntry.w word_2FD7A
	mappingsTableEntry.w word_2FD7A
	mappingsTableEntry.w word_2FD7A
	mappingsTableEntry.w word_2FD7A
	mappingsTableEntry.w word_2FD7A
	mappingsTableEntry.w word_2FD7A
	mappingsTableEntry.w word_2FD7A
	mappingsTableEntry.w word_2FD7A
	mappingsTableEntry.w word_2FD7A
	mappingsTableEntry.w word_2FD7A
	mappingsTableEntry.w word_2FD82
	mappingsTableEntry.w word_2FD8A
	mappingsTableEntry.w word_2FD92
	mappingsTableEntry.w word_2FD9A

word_2FD0E:	spriteHeader
	spritePiece	-4, -4, 1, 1, 0, 0, 0, 0, 0
word_2FD0E_End

word_2FD16:	spriteHeader
	spritePiece	-4, -4, 1, 1, 1, 0, 0, 0, 0
word_2FD16_End

word_2FD1E:	spriteHeader
	spritePiece	-4, -4, 1, 1, 2, 0, 0, 0, 0
word_2FD1E_End

word_2FD26:	spriteHeader
	spritePiece	-8, -8, 2, 2, 3, 0, 0, 0, 0
word_2FD26_End

word_2FD2E:	spriteHeader
	spritePiece	-8, -8, 2, 2, 7, 0, 0, 0, 0
word_2FD2E_End

word_2FD36:	spriteHeader
	spritePiece	-$C, -$C, 3, 3, $B, 0, 0, 0, 0
word_2FD36_End

word_2FD3E:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, $14, 0, 0, 0, 0
word_2FD3E_End

word_2FD46:	spriteHeader
	spritePiece	-$10, -$10, 2, 2, $24, 0, 0, 0, 0
	spritePiece	0, -$10, 2, 2, $24, 1, 0, 0, 0
	spritePiece	-$10, 0, 2, 2, $24, 0, 1, 0, 0
	spritePiece	0, 0, 2, 2, $24, 1, 1, 0, 0
word_2FD46_End

word_2FD60:	spriteHeader
	spritePiece	-$10, -$10, 2, 2, $28, 0, 0, 0, 0
	spritePiece	0, -$10, 2, 2, $28, 1, 0, 0, 0
	spritePiece	-$10, 0, 2, 2, $28, 0, 1, 0, 0
	spritePiece	0, 0, 2, 2, $28, 1, 1, 0, 0
word_2FD60_End

word_2FD7A:	spriteHeader
	spritePiece	-8, -$C, 2, 3, $280, 0, 0, 0, 0
word_2FD7A_End

word_2FD82:	spriteHeader
	spritePiece	-8, -8, 2, 2, $2C, 0, 0, 0, 0
word_2FD82_End

word_2FD8A:	spriteHeader
	spritePiece	-8, -8, 2, 2, $30, 0, 0, 0, 0
word_2FD8A_End

word_2FD92:	spriteHeader
	spritePiece	-8, -8, 2, 2, $34, 0, 0, 0, 0
word_2FD92_End

word_2FD9A:	spriteHeader
word_2FD9A_End

word_2FD9C:	spriteHeader
	spritePiece	-8, -$C, 2, 3, $394, 0, 0, 0, 0
word_2FD9C_End

	even
