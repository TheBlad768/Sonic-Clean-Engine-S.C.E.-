; ===========================================================================
; Text (Title Card)
; ===========================================================================

TitleCardLetters_Index: offsetTable
		offsetTableEntry.w TitleCard_DEZ	; 0

		zonewarning TitleCardLetters_Index,(1*2)

; find unique letters and load it to VRAM
TitleCard_DEZ:		titlecardLetters FALSE, "DEATH EGG"
	even