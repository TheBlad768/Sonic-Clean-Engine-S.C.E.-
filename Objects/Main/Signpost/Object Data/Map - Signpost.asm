; ---------------------------------------------------------------------------
; Sprite mappings - signpost
; ---------------------------------------------------------------------------

Map_Signpost:	mappingsTable
	mappingsTableEntry.w word_83BAC
	mappingsTableEntry.w word_83BBA
	mappingsTableEntry.w word_83BC8
	mappingsTableEntry.w word_83BD6
	mappingsTableEntry.w word_83BE4
	mappingsTableEntry.w word_83BEC
	mappingsTableEntry.w word_83BF4

word_83BAC:	spriteHeader
	spritePiece	-$18, -$10, 3, 4, 0, 0, 0, 0, 0
	spritePiece	0, -$10, 3, 4, $C, 0, 0, 0, 0
word_83BAC_End

word_83BBA:	spriteHeader
	spritePiece	-$18, -$10, 3, 4, 0, 0, 0, 0, 0
	spritePiece	0, -$10, 3, 4, $C, 0, 0, 0, 0
word_83BBA_End

word_83BC8:	spriteHeader
	spritePiece	-$18, -$10, 3, 4, 0, 0, 0, 0, 0
	spritePiece	0, -$10, 3, 4, $C, 0, 0, 0, 0
word_83BC8_End

word_83BD6:	spriteHeader
	spritePiece	-$18, -$10, 3, 4, 0, 0, 0, 0, 0
	spritePiece	0, -$10, 3, 4, $C, 1, 0, 0, 0
word_83BD6_End

word_83BE4:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, 0, 0, 0, 0, 0
word_83BE4_End

word_83BEC:	spriteHeader
	spritePiece	-4, -$10, 1, 4, 0, 0, 0, 0, 0
word_83BEC_End

word_83BF4:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, 0, 1, 0, 0, 0
word_83BF4_End

	even
