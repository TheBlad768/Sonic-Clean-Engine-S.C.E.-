; ---------------------------------------------------------------------------
; Sprite mappings - spikebonker
; ---------------------------------------------------------------------------

Map_Spikebonker:	mappingsTable
	mappingsTableEntry.w word_184E64
	mappingsTableEntry.w word_184E72
	mappingsTableEntry.w word_184E7A
	mappingsTableEntry.w word_184E82

word_184E64:	spriteHeader
	spritePiece	-$B, -$10, 4, 3, 0, 0, 0, 0, 0
	spritePiece	-$B, 8, 3, 2, $C, 0, 0, 0, 0
word_184E64_End

word_184E72:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, $12, 0, 0, 0, 0
word_184E72_End

word_184E7A:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, $22, 0, 0, 0, 0
word_184E7A_End

word_184E82:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, $32, 0, 0, 0, 0
word_184E82_End

	even
