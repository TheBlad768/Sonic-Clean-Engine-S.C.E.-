; ---------------------------------------------------------------------------
; Animation script - Insta shield
; ---------------------------------------------------------------------------

Ani_InstaShield: offsetTable
		offsetTableEntry.w byte_199EE	; 0
		offsetTableEntry.w byte_199F1	; 1

byte_199EE:	dc.b $1F, 6, afEnd
byte_199F1:	dc.b 0, 0, 1, 2, 3, 4, 5, 6, 6, 6, 6, 6, 6, 6, 7, afChange, 0
	even