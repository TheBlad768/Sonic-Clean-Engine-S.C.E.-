; ---------------------------------------------------------------------------
; Sprite mappings - springs (yellow)
; ---------------------------------------------------------------------------

Map_Spring2:	mappingsTable
	mappingsTableEntry.w word_237AC		; Normal
	mappingsTableEntry.w word_237BA
	mappingsTableEntry.w word_237C2
	mappingsTableEntry.w word_237F4
	mappingsTableEntry.w word_23802
	mappingsTableEntry.w word_2380A
	mappingsTableEntry.w word_23826
	mappingsTableEntry.w word_2389C		; Diagonal Spring
	mappingsTableEntry.w word_238B6		; Diagonal Spring
	mappingsTableEntry.w word_238CA		; Diagonal Spring
	mappingsTableEntry.w word_238EA		; Diagonal Spring

word_237AC:	spriteHeader
	spritePiece	-$10, -8, 4, 1, $10, 0, 0, 1, 0
	spritePiece	-8, 0, 2, 1, $14, 0, 0, 0, 0
word_237AC_End

word_237BA:	spriteHeader
	spritePiece	-$10, 0, 4, 1, $10, 0, 0, 1, 0
word_237BA_End

word_237C2:	spriteHeader
	spritePiece	-$10, -$18, 4, 1, $10, 0, 0, 1, 0
	spritePiece	-8, -$10, 2, 3, $16, 0, 0, 0, 0
word_237C2_End

word_237F4:	spriteHeader
	spritePiece	0, -$10, 1, 4, $1C, 0, 0, 1, 0
	spritePiece	-8, -8, 1, 2, $20, 0, 0, 0, 0
word_237F4_End

word_23802:	spriteHeader
	spritePiece	-8, -$10, 1, 4, $1C, 0, 0, 1, 0
word_23802_End

word_2380A:	spriteHeader
	spritePiece	$10, -$10, 1, 4, $1C, 0, 0, 1, 0
	spritePiece	-8, -8, 3, 2, $22, 0, 0, 0, 0
word_2380A_End

word_23826:	spriteHeader
	spritePiece	-$10, 0, 4, 1, $10, 0, 1, 1, 0
	spritePiece	-8, -8, 2, 1, $14, 0, 1, 0, 0
word_23826_End

word_2389C:	spriteHeader
	spritePiece	-$15, -$F, 3, 1, 0, 0, 0, 1, 0
	spritePiece	-$D, -7, 3, 1, 3, 0, 0, 1, 0
	spritePiece	-5, 1, 2, 2, 6, 0, 0, 1, 0
	spritePiece	-$F, -5, 2, 2, $B, 0, 0, 0, 0
word_2389C_End

word_238B6:	spriteHeader
	spritePiece	-$1A, -9, 3, 1, 0, 0, 0, 1, 0
	spritePiece	-$12, -1, 3, 1, 3, 0, 0, 1, 0
	spritePiece	-$A, 7, 2, 2, 6, 0, 0, 1, 0
word_238B6_End

word_238CA:	spriteHeader
	spritePiece	-$A, -$1A, 3, 1, 0, 0, 0, 1, 0
	spritePiece	-2, -$12, 3, 1, 3, 0, 0, 1, 0
	spritePiece	6, -$A, 2, 2, 6, 0, 0, 1, 0
	spritePiece	-6, -$B, 2, 1, $F, 0, 0, 0, 0
	spritePiece	-$E, -3, 2, 1, $11, 0, 0, 0, 0
word_238CA_End

word_238EA:	spriteHeader
	spritePiece	-$15, 7, 3, 1, 0, 0, 1, 1, 0
	spritePiece	-$D, -1, 3, 1, 3, 0, 1, 1, 0
	spritePiece	-5, -$11, 2, 2, 6, 0, 1, 1, 0
	spritePiece	-$F, -$B, 2, 2, $B, 0, 1, 0, 0
word_238EA_End

	even
