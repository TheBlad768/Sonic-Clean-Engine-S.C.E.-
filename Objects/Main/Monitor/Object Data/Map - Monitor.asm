; ---------------------------------------------------------------------------
; Sprite mappings - monitors
; ---------------------------------------------------------------------------

Map_Monitor:	mappingsTable
	mappingsTableEntry.w word_1DBBA
	mappingsTableEntry.w word_1DBC2
	mappingsTableEntry.w word_1DBD0
	mappingsTableEntry.w word_1DBDE
	mappingsTableEntry.w word_1DBEC
	mappingsTableEntry.w word_1DBFA
	mappingsTableEntry.w word_1DC08
	mappingsTableEntry.w word_1DC16
	mappingsTableEntry.w word_1DC24
	mappingsTableEntry.w word_1DC32
	mappingsTableEntry.w word_1DC40
	mappingsTableEntry.w word_1DC4E

word_1DBBA:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, 0, 0, 0, 0, 0
word_1DBBA_End

word_1DBC2:	spriteHeader
	spritePiece	-8, -$D, 2, 2, $18, 0, 0, 0, 0
	spritePiece	-$10, -$10, 4, 4, 0, 0, 0, 0, 0
word_1DBC2_End

word_1DBD0:	spriteHeader
	spritePiece	-8, -$D, 2, 2, $328, 0, 0, 0, 0
	spritePiece	-$10, -$10, 4, 4, 0, 0, 0, 0, 0
word_1DBD0_End

word_1DBDE:	spriteHeader
	spritePiece	-8, -$D, 2, 2, $1C, 0, 0, 0, 0
	spritePiece	-$10, -$10, 4, 4, 0, 0, 0, 0, 0
word_1DBDE_End

word_1DBEC:	spriteHeader
	spritePiece	-8, -$D, 2, 2, $20, 0, 0, 1, 0
	spritePiece	-$10, -$10, 4, 4, 0, 0, 0, 0, 0
word_1DBEC_End

word_1DBFA:	spriteHeader
	spritePiece	-8, -$D, 2, 2, $24, 0, 0, 0, 0
	spritePiece	-$10, -$10, 4, 4, 0, 0, 0, 0, 0
word_1DBFA_End

word_1DC08:	spriteHeader
	spritePiece	-8, -$D, 2, 2, $30, 0, 0, 0, 0
	spritePiece	-$10, -$10, 4, 4, 0, 0, 0, 0, 0
word_1DC08_End

word_1DC16:	spriteHeader
	spritePiece	-8, -$D, 2, 2, $2C, 0, 0, 0, 0
	spritePiece	-$10, -$10, 4, 4, 0, 0, 0, 0, 0
word_1DC16_End

word_1DC24:	spriteHeader
	spritePiece	-8, -$D, 2, 2, $34, 0, 0, 0, 0
	spritePiece	-$10, -$10, 4, 4, 0, 0, 0, 0, 0
word_1DC24_End

word_1DC32:	spriteHeader
	spritePiece	-8, -$D, 2, 2, $28, 0, 0, 0, 0
	spritePiece	-$10, -$10, 4, 4, 0, 0, 0, 0, 0
word_1DC32_End

word_1DC40:	spriteHeader
	spritePiece	-8, -$D, 2, 2, $38, 0, 0, 0, 0
	spritePiece	-$10, -$10, 4, 4, 0, 0, 0, 0, 0
word_1DC40_End

word_1DC4E:	spriteHeader
	spritePiece	-$10, 0, 4, 2, $10, 0, 0, 0, 0
word_1DC4E_End

	even
