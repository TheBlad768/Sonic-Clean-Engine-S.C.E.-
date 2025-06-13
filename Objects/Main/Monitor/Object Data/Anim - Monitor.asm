; ---------------------------------------------------------------------------
; Animation script - Monitor
; ---------------------------------------------------------------------------

Ani_Monitor: offsetTable
		offsetTableEntry.w byte_1DB50	; 0 (Null)
		offsetTableEntry.w byte_1DB54	; 1 (Null2)
		offsetTableEntry.w byte_1DB5C	; 2 (Robotnik)
		offsetTableEntry.w byte_1DB64	; 3 (Rings)
		offsetTableEntry.w byte_1DB6C	; 4 (Shoes)
		offsetTableEntry.w byte_1DB74	; 5 (Fire)
		offsetTableEntry.w byte_1DB7C	; 6 (Electro)
		offsetTableEntry.w byte_1DB84	; 7 (Bubble)
		offsetTableEntry.w byte_1DB8C	; 8 (Invincibility)
		offsetTableEntry.w byte_1DB94	; 9 (Super)
		offsetTableEntry.w byte_1DB9C	; A (Break)

byte_1DB50:	dc.b 1, 0, 1, afEnd
byte_1DB54:	dc.b 1, 0, 2, 2, 1, 2, 2, afEnd
byte_1DB5C:	dc.b 1, 0, 3, 3, 1, 3, 3, afEnd
byte_1DB64:	dc.b 1, 0, 4, 4, 1, 4, 4, afEnd
byte_1DB6C:	dc.b 1, 0, 5, 5, 1, 5, 5, afEnd
byte_1DB74:	dc.b 1, 0, 6, 6, 1, 6, 6, afEnd
byte_1DB7C:	dc.b 1, 0, 7, 7, 1, 7, 7, afEnd
byte_1DB84:	dc.b 1, 0, 8, 8, 1, 8, 8, afEnd
byte_1DB8C:	dc.b 1, 0, 9, 9, 1, 9, 9, afEnd
byte_1DB94:	dc.b 1, 0, $A, $A, 1, $A, $A, afEnd
byte_1DB9C:	dc.b 2, 0, 1, $B, afBack, 1
	even