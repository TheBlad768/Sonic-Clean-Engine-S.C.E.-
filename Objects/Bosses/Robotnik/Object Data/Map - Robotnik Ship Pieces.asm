; ---------------------------------------------------------------------------
; Sprite mappings - Robotnik ship pieces (boss levels)
; ---------------------------------------------------------------------------

Map_RobotnikShipPieces:	mappingsTable
	mappingsTableEntry.w word_7D6E0
	mappingsTableEntry.w word_7D6EE
	mappingsTableEntry.w word_7D6F6
	mappingsTableEntry.w word_7D704

word_7D6E0:	spriteHeader
	spritePiece	-$1C, -$14, 4, 1, $36, 0, 0, 0, 0
	spritePiece	-$14, -$1C, 2, 1, $5D, 0, 0, 0, 0
word_7D6E0_End

word_7D6EE:	spriteHeader
	spritePiece	4, -$14, 3, 1, $3A, 0, 0, 0, 0
word_7D6EE_End

word_7D6F6:	spriteHeader
	spritePiece	-$1C, -$C, 4, 3, $3D, 0, 0, 0, 0
	spritePiece	-$14, $C, 3, 1, $52, 0, 0, 0, 0
word_7D6F6_End

word_7D704:	spriteHeader
	spritePiece	4, -$C, 3, 3, $49, 0, 0, 0, 0
	spritePiece	4, $C, 2, 1, $55, 0, 0, 0, 0
word_7D704_End

	even
