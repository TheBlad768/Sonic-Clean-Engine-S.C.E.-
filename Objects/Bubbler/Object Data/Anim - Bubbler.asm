Ani_Bubbler: offsetTable
		offsetTableEntry.w byte_2FC90
		offsetTableEntry.w byte_2FC95
		offsetTableEntry.w byte_2FC9B
		offsetTableEntry.w byte_2FCA2
		offsetTableEntry.w byte_2FCA6
		offsetTableEntry.w byte_2FCA6
		offsetTableEntry.w byte_2FCA8
		offsetTableEntry.w byte_2FCA8
		offsetTableEntry.w byte_2FCAC
byte_2FC90:	dc.b   $E,   0,	  1,   2, afRoutine
byte_2FC95:	dc.b   $E,   1,	  2,   3,   4, afRoutine
byte_2FC9B:	dc.b   $E,   2,	  3,   4,   5,	 6, afRoutine
byte_2FCA2:	dc.b	2,   5,	  6, afRoutine
byte_2FCA6:	dc.b	4, afRoutine
byte_2FCA8:	dc.b	4,   7,	  8, afRoutine
byte_2FCAC:	dc.b   $F, $13,	$14, $15, afEnd
	even