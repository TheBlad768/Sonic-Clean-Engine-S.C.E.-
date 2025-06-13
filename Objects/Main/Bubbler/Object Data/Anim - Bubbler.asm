; ---------------------------------------------------------------------------
; Animation script - bubbler (LZ)
; ---------------------------------------------------------------------------

Ani_Bubbler: offsetTable
		offsetTableEntry.w byte_2FC90	; 0
		offsetTableEntry.w byte_2FC95	; 1
		offsetTableEntry.w byte_2FC9B	; 2
		offsetTableEntry.w byte_2FCA2	; 3
		offsetTableEntry.w byte_2FCA6	; 4
		offsetTableEntry.w byte_2FCA6	; 5
		offsetTableEntry.w byte_2FCA8	; 6
		offsetTableEntry.w byte_2FCA8	; 7
		offsetTableEntry.w byte_2FCAC	; 8

byte_2FC90:	dc.b $E, 0, 1, 2, afRoutine
byte_2FC95:	dc.b $E, 1, 2, 3, 4, afRoutine
byte_2FC9B:	dc.b $E, 2, 3, 4, 5, 6, afRoutine
byte_2FCA2:	dc.b 2, 5, 6, afRoutine
byte_2FCA6:	dc.b 4, afRoutine
byte_2FCA8:	dc.b 4, 7, 8, afRoutine
byte_2FCAC:	dc.b $F, $13, $14, $15, afEnd
	even