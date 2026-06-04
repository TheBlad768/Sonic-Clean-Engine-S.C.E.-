; ---------------------------------------------------------------------------
; Sprite mappings - explosion from a badnik or monitor
; ---------------------------------------------------------------------------

Map_Explosion:	mappingsTable
	mappingsTableEntry.w word_1E762
	mappingsTableEntry.w word_1E76A
	mappingsTableEntry.w word_1E772
	mappingsTableEntry.w word_1E77A
	mappingsTableEntry.w word_1E782
	mappingsTableEntry.w word_1E78A		; extra (Sonic 2)
	mappingsTableEntry.w word_1E792

word_1E762:	spriteHeader
	spritePiece	-8, -8, 2, 2, 0, 0, 0, 0, 0
word_1E762_End

word_1E76A:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, 4, 0, 0, 0, 0
word_1E76A_End

word_1E772:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, $14, 0, 0, 0, 0
word_1E772_End

word_1E77A:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, $24, 0, 0, 0, 0
word_1E77A_End

word_1E782:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, $34, 0, 0, 0, 0
word_1E782_End

word_1E78A:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, $44, 0, 0, 0, 0
word_1E78A_End

word_1E792:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, $54, 0, 0, 0, 0
word_1E792_End

	even
