; ===========================================================================
; Text VRAM (Title Card)
; ===========================================================================

TitleCardVRAMLetters_Index: offsetTable
		offsetTableEntry.w VRAM_TitleCard_DEZ	; 0

		zonewarning TitleCardVRAMLetters_Index,(1*2)

; find unique letters and load it to VRAM
VRAM_TitleCard_ZONE:		titlecardVRAMLetters FALSE, TRUE, TitleCardName_ZONE
VRAM_TitleCard_DEZ:		titlecardVRAMLetters FALSE, FALSE, TitleCardName_DEZ
	even
