; ---------------------------------------------------------------------------
; Animation script - Spring
; ---------------------------------------------------------------------------

Ani_Spring: offsetTable
		offsetTableEntry.w byte_2372E	; 0
		offsetTableEntry.w byte_23731	; 1
		offsetTableEntry.w byte_2373D	; 2
		offsetTableEntry.w byte_23740	; 3
		offsetTableEntry.w byte_2374C	; 4
		offsetTableEntry.w byte_2374F	; 5

byte_2372E:	dc.b $F, 0, afEnd
byte_23731:	dc.b 0, 1, 0, 0, 2, 2, 2, 2, 2, 2, afChange, 0
byte_2373D:	dc.b $F, 3, afEnd
byte_23740:	dc.b 0, 4, 3, 3, 5, 5, 5, 5, 5, 5, afChange, 2
byte_2374C:	dc.b $F, 7, afEnd
byte_2374F:	dc.b 0, 8, 7, 7, 9, 9, 9, 9, 9, 9, afChange, 4
	even