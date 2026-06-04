; ---------------------------------------------------------------------------
; Sprite mappings - Invincibility
; ---------------------------------------------------------------------------

Map_Invincibility:	mappingsTable
	dc.w 0
	mappingsTableEntry.w Map_Invincibility_12
	mappingsTableEntry.w Map_Invincibility_1A
	mappingsTableEntry.w Map_Invincibility_22
	mappingsTableEntry.w Map_Invincibility_2A
	mappingsTableEntry.w Map_Invincibility_32
	mappingsTableEntry.w Map_Invincibility_3A
	mappingsTableEntry.w Map_Invincibility_42
	mappingsTableEntry.w Map_Invincibility_4A

Map_Invincibility_12:	spriteHeader
	spritePiece	-4, -8, 1, 1, 0, 0, 0, 0, 0
Map_Invincibility_12_End

Map_Invincibility_1A:	spriteHeader
	spritePiece	-4, -8, 1, 1, 1, 0, 0, 0, 0
Map_Invincibility_1A_End

Map_Invincibility_22:	spriteHeader
	spritePiece	-4, -8, 1, 2, 2, 0, 0, 0, 0
Map_Invincibility_22_End

Map_Invincibility_2A:	spriteHeader
	spritePiece	-4, -8, 1, 2, 4, 0, 0, 0, 0
Map_Invincibility_2A_End

Map_Invincibility_32:	spriteHeader
	spritePiece	-4, -8, 1, 2, 6, 0, 0, 0, 0
Map_Invincibility_32_End

Map_Invincibility_3A:	spriteHeader
	spritePiece	-8, -8, 2, 2, 8, 0, 0, 0, 0
Map_Invincibility_3A_End

Map_Invincibility_42:	spriteHeader
	spritePiece	-8, -8, 2, 2, $C, 0, 0, 0, 0
Map_Invincibility_42_End

Map_Invincibility_4A:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, $10, 0, 0, 0, 0
Map_Invincibility_4A_End

	even
