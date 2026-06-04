; ---------------------------------------------------------------------------
; Sprite mappings - title card
; ---------------------------------------------------------------------------

Map_TitleCard:	mappingsTable
		dc.w 0						; null
		mappingsTableEntry.w Map_TitleCard_RedBanner	; red banner
		mappingsTableEntry.w Map_TitleCard_ACT		; ACT
		mappingsTableEntry.w Map_TitleCard_ZONE		; ZONE

.levels
		mappingsTableEntry.w Map_TitleCard_DEZ		; DEATH EGG

		zonewarning Map_TitleCard.levels,(1*2)

Map_TitleCard_RedBanner:	spriteHeader
	spritePiece	-$18, $58, 3, 2, $10, 0, 0, 0, 1
	spritePiece	0, $58, 3, 2, $16, 0, 0, 0, 1
	spritePiece	-$20, -$70, 4, 4, 0, 0, 0, 0, 1
	spritePiece	0, -$70, 4, 4, 0, 0, 0, 0, 1
	spritePiece	-$20, -$50, 4, 4, 0, 0, 0, 0, 1
	spritePiece	0, -$50, 4, 4, 0, 0, 0, 0, 1
	spritePiece	-$20, -$30, 4, 4, 0, 0, 0, 0, 1
	spritePiece	0, -$30, 4, 4, 0, 0, 0, 0, 1
	spritePiece	-$20, -$10, 4, 4, 0, 0, 0, 0, 1
	spritePiece	0, -$10, 4, 4, 0, 0, 0, 0, 1
	spritePiece	-$20, $10, 4, 4, 0, 0, 0, 0, 1
	spritePiece	0, $10, 4, 4, 0, 0, 0, 0, 1
	spritePiece	-$20, $30, 4, 4, 0, 0, 0, 0, 1
	spritePiece	0, $30, 4, 4, 0, 0, 0, 0, 1
	spritePiece	-$20, $50, 4, 4, 0, 0, 0, 0, 1
	spritePiece	0, $50, 4, 4, 0, 0, 0, 0, 1
Map_TitleCard_RedBanner_End

Map_TitleCard_ACT:	spriteHeader
	spritePiece	-$1C, $10, 3, 2, $1C, 0, 0, 0, 1
	spritePiece	-$B, 0, 4, 4, $3D, 0, 0, 0, 1
Map_TitleCard_ACT_End

	even
