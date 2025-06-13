; ---------------------------------------------------------------------------
; Animation script - air countdown
; ---------------------------------------------------------------------------

Ani_AirCountdown: offsetTable
		offsetTableEntry.w byte_186E2	; 0
		offsetTableEntry.w byte_186EB	; 1
		offsetTableEntry.w byte_186F4	; 2
		offsetTableEntry.w byte_186FD	; 3
		offsetTableEntry.w byte_18706	; 4
		offsetTableEntry.w byte_1870F	; 5
		offsetTableEntry.w byte_18718	; 6
		offsetTableEntry.w byte_1871D	; 7
		offsetTableEntry.w byte_18725	; 8
		offsetTableEntry.w byte_1872D	; 9
		offsetTableEntry.w byte_18735	; A
		offsetTableEntry.w byte_1873D	; B
		offsetTableEntry.w byte_18745	; C
		offsetTableEntry.w byte_1874D	; D
		offsetTableEntry.w byte_1874F	; E

byte_186E2:	dc.b 5, 0, 1, 2, 3, 4, 9, $D, afRoutine
byte_186EB:	dc.b 5, 0, 1, 2, 3, 4, $C, $12, afRoutine
byte_186F4:	dc.b 5, 0, 1, 2, 3, 4, $C, $11, afRoutine
byte_186FD:	dc.b 5, 0, 1, 2, 3, 4, $B, $10, afRoutine
byte_18706:	dc.b 5, 0, 1, 2, 3, 4, $C, $F, afRoutine
byte_1870F:	dc.b 5, 0, 1, 2, 3, 4, $A, $E, afRoutine
byte_18718:	dc.b $E, 0, 1, 2, afRoutine
byte_1871D:	dc.b 7, $16, $D, $16, $D, $16, $D, afRoutine
byte_18725:	dc.b 7, $16, $12, $16, $12, $16, $12, afRoutine
byte_1872D:	dc.b 7, $16, $11, $16, $11, $16, $11, afRoutine
byte_18735:	dc.b 7, $16, $10, $16, $10, $16, $10, afRoutine
byte_1873D:	dc.b 7, $16, $F, $16, $F, $16, $F, afRoutine
byte_18745:	dc.b 7, $16, $E, $16, $E, $16, $E, afRoutine
byte_1874D:	dc.b $E, afRoutine
byte_1874F:	dc.b $E, 1, 2, 3, 4, afRoutine, afEnd
	even