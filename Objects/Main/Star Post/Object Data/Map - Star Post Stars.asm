; ---------------------------------------------------------------------------
; Sprite mappings - starpost stars
; ---------------------------------------------------------------------------

Map_StarPostStars:	mappingsTable
	mappingsTableEntry.w word_2D3B0
	mappingsTableEntry.w word_2D3B8
	mappingsTableEntry.w word_2D3C0

word_2D3B0:	spriteHeader
	spritePiece	-8, -8, 2, 2, 0, 0, 0, 0, 0
word_2D3B0_End

word_2D3B8:	spriteHeader
	spritePiece	-4, -4, 1, 1, 4, 0, 0, 0, 0
word_2D3B8_End

word_2D3C0:	spriteHeader
	spritePiece	-4, -4, 1, 1, 5, 0, 0, 0, 0
word_2D3C0_End

	even
