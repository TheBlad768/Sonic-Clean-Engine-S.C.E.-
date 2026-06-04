; ---------------------------------------------------------------------------
; Sprite mappings - rings
; ---------------------------------------------------------------------------

Map_Ring:	mappingsTable
	mappingsTableEntry.w Map_Ring_10		; Ring
	mappingsTableEntry.w Map_Ring_30		; Spark 1
	mappingsTableEntry.w Map_Ring_38		; Spark 2
	mappingsTableEntry.w Map_Ring_40		; Spark 3
	mappingsTableEntry.w Map_Ring_48		; Spark 4

Map_Ring_10:	spriteHeader
	spritePiece	-8, -8, 2, 2, 0, 0, 0, 0, 0
Map_Ring_10_End

Map_Ring_30:	spriteHeader
	spritePiece	-8, -8, 2, 2, 8, 0, 0, 0, 0
Map_Ring_30_End

Map_Ring_38:	spriteHeader
	spritePiece	-8, -8, 2, 2, 8, 1, 1, 0, 0
Map_Ring_38_End

Map_Ring_40:	spriteHeader
	spritePiece	-8, -8, 2, 2, 8, 1, 0, 0, 0
Map_Ring_40_End

Map_Ring_48:	spriteHeader
	spritePiece	-8, -8, 2, 2, 8, 0, 1, 0, 0
Map_Ring_48_End

	even
