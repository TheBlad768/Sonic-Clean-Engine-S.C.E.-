; ---------------------------------------------------------------------------
; Sprite mappings - springs (red)
; ---------------------------------------------------------------------------

Map_Spring:	mappingsTable
	mappingsTableEntry.w word_23788		; Normal
	mappingsTableEntry.w word_23796
	mappingsTableEntry.w word_2379E
	mappingsTableEntry.w word_237D0
	mappingsTableEntry.w word_237DE
	mappingsTableEntry.w word_237E6
	mappingsTableEntry.w word_23818
	mappingsTableEntry.w word_23834		; Diagonal Spring
	mappingsTableEntry.w word_2384E		; Diagonal Spring
	mappingsTableEntry.w word_23862		; Diagonal Spring
	mappingsTableEntry.w word_23882		; Diagonal Spring

word_23788:	spriteHeader
	spritePiece	-$10, -8, 4, 1, $10, 0, 0, 0, 0
	spritePiece	-8, 0, 2, 1, $14, 0, 0, 0, 0
word_23788_End

word_23796:	spriteHeader
	spritePiece	-$10, 0, 4, 1, $10, 0, 0, 0, 0
word_23796_End

word_2379E:	spriteHeader
	spritePiece	-$10, -$18, 4, 1, $10, 0, 0, 0, 0
	spritePiece	-8, -$10, 2, 3, $16, 0, 0, 0, 0
word_2379E_End

word_237D0:	spriteHeader
	spritePiece	0, -$10, 1, 4, $1C, 0, 0, 0, 0
	spritePiece	-8, -8, 1, 2, $20, 0, 0, 0, 0
word_237D0_End

word_237DE:	spriteHeader
	spritePiece	-8, -$10, 1, 4, $1C, 0, 0, 0, 0
word_237DE_End

word_237E6:	spriteHeader
	spritePiece	$10, -$10, 1, 4, $1C, 0, 0, 0, 0
	spritePiece	-8, -8, 3, 2, $22, 0, 0, 0, 0
word_237E6_End

word_23818:	spriteHeader
	spritePiece	-$10, 0, 4, 1, $10, 0, 1, 0, 0
	spritePiece	-8, -8, 2, 1, $14, 0, 1, 0, 0
word_23818_End

word_23834:	spriteHeader
	spritePiece	-$15, -$F, 3, 1, 0, 0, 0, 0, 0
	spritePiece	-$D, -7, 3, 1, 3, 0, 0, 0, 0
	spritePiece	-5, 1, 2, 2, 6, 0, 0, 0, 0
	spritePiece	-$F, -5, 2, 2, $B, 0, 0, 0, 0
word_23834_End

word_2384E:	spriteHeader
	spritePiece	-$1A, -9, 3, 1, 0, 0, 0, 0, 0
	spritePiece	-$12, -1, 3, 1, 3, 0, 0, 0, 0
	spritePiece	-$A, 7, 2, 2, 6, 0, 0, 0, 0
word_2384E_End

word_23862:	spriteHeader
	spritePiece	-$A, -$1A, 3, 1, 0, 0, 0, 0, 0
	spritePiece	-2, -$12, 3, 1, 3, 0, 0, 0, 0
	spritePiece	6, -$A, 2, 2, 6, 0, 0, 0, 0
	spritePiece	-6, -$B, 2, 1, $F, 0, 0, 0, 0
	spritePiece	-$E, -3, 2, 1, $11, 0, 0, 0, 0
word_23862_End

word_23882:	spriteHeader
	spritePiece	-$15, 7, 3, 1, 0, 0, 1, 0, 0
	spritePiece	-$D, -1, 3, 1, 3, 0, 1, 0, 0
	spritePiece	-5, -$11, 2, 2, 6, 0, 1, 0, 0
	spritePiece	-$F, -$B, 2, 2, $B, 0, 1, 0, 0
word_23882_End

	even
