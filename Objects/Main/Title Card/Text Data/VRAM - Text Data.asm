; ===========================================================================
; Text VRAM (Title Card)
; ===========================================================================

TitleCardVRAMLetters_Index: offsetTable
		offsetTableEntry.w VRAM_TitleCard_DEZ	; 0

		zonewarning TitleCardVRAMLetters_Index,(1*2)

; find unique letters and load it to VRAM
VRAM_TitleCard_ZONE:		titlecardVRAMLetters FALSE, TRUE, "ZONE"
VRAM_TitleCard_DEZ:		titlecardVRAMLetters FALSE, FALSE, "DEATH EGG"
	even
