Ani_DashSplashDrown: offsetTable
		offsetTableEntry.w byte_18DCA		; 0 (null)
		offsetTableEntry.w byte_18DCD		; 1 (splash)
		offsetTableEntry.w byte_18DD9		; 2 (spindash dust)
		offsetTableEntry.w byte_18DE2		; 3 (skid dust)
		offsetTableEntry.w byte_18DE8		; 4 (from ground)

byte_18DCA:	dc.b $1F, 0, afEnd
byte_18DCD:	dc.b 3, 1, 2, 3, 4, 5, 6, 7, 8, 9, afChange, 0
byte_18DD9:	dc.b 1, $A, $B, $C, $D, $E, $F, $10, afEnd
byte_18DE2:	dc.b 3, $11, $12, $13, $14, afRoutine
byte_18DE8:	dc.b 5, $16, $17, $18, $19, $1A, $1B, $1C, $1D, afChange, 0
	even