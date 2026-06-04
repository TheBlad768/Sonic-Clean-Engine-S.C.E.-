; ---------------------------------------------------------------------------
; Sprite mappings - explosion from a boss
; ---------------------------------------------------------------------------

Map_BossExplosion:	mappingsTable
	mappingsTableEntry.w word_84008
	mappingsTableEntry.w word_84010
	mappingsTableEntry.w word_84018
	mappingsTableEntry.w word_84020
	mappingsTableEntry.w word_84028
	mappingsTableEntry.w word_84030

word_84008:	spriteHeader
	spritePiece	-8, -8, 2, 2, 0, 0, 0, 0, 0
word_84008_End

word_84010:	spriteHeader
	spritePiece	-$C, -$C, 3, 3, 4, 0, 0, 0, 0
word_84010_End

word_84018:	spriteHeader
	spritePiece	-$C, -$C, 3, 3, $D, 0, 0, 0, 0
word_84018_End

word_84020:	spriteHeader
	spritePiece	-$C, -$C, 3, 3, $16, 0, 0, 0, 0
word_84020_End

word_84028:	spriteHeader
	spritePiece	-$C, -$D, 3, 3, $1F, 0, 0, 0, 0
word_84028_End

word_84030:	spriteHeader
	spritePiece	-$C, -$A, 3, 2, $28, 0, 0, 0, 0
word_84030_End

	even
