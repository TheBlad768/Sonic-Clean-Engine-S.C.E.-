; ---------------------------------------------------------------------------
; Animation script - Bubble shield
; ---------------------------------------------------------------------------

Ani_BubbleShield: offsetTable
		offsetTableEntry.w byte_19A80	; 0
		offsetTableEntry.w byte_19AB8	; 1
		offsetTableEntry.w byte_19ABF	; 2

byte_19A80:
		dc.b 1, 0, 9, 0, 9, 0, 9, 1, $A, 1, $A, 1, $A, 2, 9, 2, 9, 2, 9, 3
		dc.b $A, 3, $A, 3, $A, 4, 9, 4, 9, 4, 9, 5, $A, 5, $A, 5, $A, 6, 9, 6
		dc.b 9, 6, 9, 7, $A, 7, $A, 7, $A, 8, 9, 8, 9, 8, 9, afEnd
byte_19AB8:	dc.b 5, 9, $B, $B, $B, afChange, 0
byte_19ABF:	dc.b 5, $C, $C, $B, afChange, 0
	even