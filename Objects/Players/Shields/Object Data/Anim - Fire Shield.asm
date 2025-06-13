; ---------------------------------------------------------------------------
; Animation script - Fire shield
; ---------------------------------------------------------------------------

Ani_FireShield: offsetTable
		offsetTableEntry.w byte_19A06	; 0
		offsetTableEntry.w byte_19A1A	; 1

byte_19A06:	dc.b 1, 0, $F, 1, $10, 2, $11, 3, $12, 4, $13, 5, $14, 6, $15, 7, $16, 8, $17, afEnd
byte_19A1A:	dc.b 1, 9, $A, $B, $C, $D, $E, 9, $A, $B, $C, $D, $E, afChange, 0
	even