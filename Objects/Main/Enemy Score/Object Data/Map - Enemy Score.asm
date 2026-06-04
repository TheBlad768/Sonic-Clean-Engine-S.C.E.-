; ---------------------------------------------------------------------------
; Sprite mappings - enemy score
; ---------------------------------------------------------------------------

Map_EnemyScore:	mappingsTable
	mappingsTableEntry.w word_2CF5E
	mappingsTableEntry.w word_2CF66
	mappingsTableEntry.w word_2CF6E
	mappingsTableEntry.w word_2CF76
	mappingsTableEntry.w word_2CF84
	mappingsTableEntry.w word_2CF8C
	mappingsTableEntry.w word_2CF9A

word_2CF5E:	spriteHeader
	spritePiece	-6, -4, 2, 1, 0, 0, 0, 0, 0
word_2CF5E_End

word_2CF66:	spriteHeader
	spritePiece	-8, -4, 2, 1, 2, 0, 0, 0, 0
word_2CF66_End

word_2CF6E:	spriteHeader
	spritePiece	-8, -4, 2, 1, 4, 0, 0, 0, 0
word_2CF6E_End

word_2CF76:	spriteHeader
	spritePiece	-8, -4, 1, 1, 0, 0, 0, 0, 0
	spritePiece	0, -4, 2, 1, 6, 0, 0, 0, 0
word_2CF76_End

word_2CF84:	spriteHeader
	spritePiece	-4, -4, 1, 1, 0, 0, 0, 0, 0
word_2CF84_End

word_2CF8C:	spriteHeader
	spritePiece	-8, -4, 2, 1, 0, 0, 0, 0, 0
	spritePiece	5, -4, 2, 1, 6, 0, 0, 0, 0
word_2CF8C_End

word_2CF9A:	spriteHeader
	spritePiece	-8, -4, 2, 1, 4, 0, 0, 0, 0
	spritePiece	7, -4, 2, 1, 6, 0, 0, 0, 0
word_2CF9A_End

	even
