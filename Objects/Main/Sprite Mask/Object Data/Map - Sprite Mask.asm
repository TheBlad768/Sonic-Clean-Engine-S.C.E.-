; ---------------------------------------------------------------------------
; Sprite mappings - sprite mask
; ---------------------------------------------------------------------------

Map_SpriteMask:	mappingsTable
	dc.w 0						; 0 (null)
	mappingsTableEntry.w word_185982		; 1
	mappingsTableEntry.w word_185990		; 2
	mappingsTableEntry.w word_18599E		; 3
	mappingsTableEntry.w word_1859AC		; 4
	mappingsTableEntry.w word_1859BA		; 5
	mappingsTableEntry.w word_1859D4		; 6
	mappingsTableEntry.w word_1859EE		; 7
	mappingsTableEntry.w word_185A08		; 8
	mappingsTableEntry.w word_185A22		; 9
	mappingsTableEntry.w word_185A48		; A
	mappingsTableEntry.w word_185A6E		; B
	mappingsTableEntry.w word_185A94		; C
	mappingsTableEntry.w word_185ABA		; D
	mappingsTableEntry.w word_185AEC		; E
	mappingsTableEntry.w word_185B1E		; F
	mappingsTableEntry.w word_185B50		; 10

word_185982:	spriteHeader
	spritePiece	8, -4, 1, 1, $7C0, 0, 0, 0, 0
	spritePiece	0, -4, 1, 1, 0, 0, 0, 0, 0
word_185982_End

word_185990:	spriteHeader
	spritePiece	8, -8, 1, 2, $7C0, 0, 0, 0, 0
	spritePiece	0, -8, 1, 2, 0, 0, 0, 0, 0
word_185990_End

word_18599E:	spriteHeader
	spritePiece	8, -$C, 1, 3, $7C0, 0, 0, 0, 0
	spritePiece	0, -$C, 1, 3, 0, 0, 0, 0, 0
word_18599E_End

word_1859AC:	spriteHeader
	spritePiece	8, -$10, 1, 4, $7C0, 0, 0, 0, 0
	spritePiece	0, -$10, 1, 4, 0, 0, 0, 0, 0
word_1859AC_End

word_1859BA:	spriteHeader
	spritePiece	8, -$14, 1, 4, $7C0, 0, 0, 0, 0
	spritePiece	0, -$14, 1, 4, 0, 0, 0, 0, 0
	spritePiece	8, $C, 1, 1, $7C0, 0, 0, 0, 0
	spritePiece	0, $C, 1, 1, 0, 0, 0, 0, 0
word_1859BA_End

word_1859D4:	spriteHeader
	spritePiece	8, -$18, 1, 4, $7C0, 0, 0, 0, 0
	spritePiece	0, -$18, 1, 4, 0, 0, 0, 0, 0
	spritePiece	8, 8, 1, 2, $7C0, 0, 0, 0, 0
	spritePiece	0, 8, 1, 2, 0, 0, 0, 0, 0
word_1859D4_End

word_1859EE:	spriteHeader
	spritePiece	8, -$1C, 1, 4, $7C0, 0, 0, 0, 0
	spritePiece	0, -$1C, 1, 4, 0, 0, 0, 0, 0
	spritePiece	8, 4, 1, 3, $7C0, 0, 0, 0, 0
	spritePiece	0, 4, 1, 3, 0, 0, 0, 0, 0
word_1859EE_End

word_185A08:	spriteHeader
	spritePiece	8, -$20, 1, 4, $7C0, 0, 0, 0, 0
	spritePiece	0, -$20, 1, 4, 0, 0, 0, 0, 0
	spritePiece	8, 0, 1, 4, $7C0, 0, 0, 0, 0
	spritePiece	0, 0, 1, 4, 0, 0, 0, 0, 0
word_185A08_End

word_185A22:	spriteHeader
	spritePiece	8, -$24, 1, 4, $7C0, 0, 0, 0, 0
	spritePiece	0, -$24, 1, 4, 0, 0, 0, 0, 0
	spritePiece	8, -4, 1, 4, $7C0, 0, 0, 0, 0
	spritePiece	0, -4, 1, 4, 0, 0, 0, 0, 0
	spritePiece	8, $1C, 1, 1, $7C0, 0, 0, 0, 0
	spritePiece	0, $1C, 1, 1, 0, 0, 0, 0, 0
word_185A22_End

word_185A48:	spriteHeader
	spritePiece	8, -$28, 1, 4, $7C0, 0, 0, 0, 0
	spritePiece	0, -$28, 1, 4, 0, 0, 0, 0, 0
	spritePiece	8, -8, 1, 4, $7C0, 0, 0, 0, 0
	spritePiece	0, -8, 1, 4, 0, 0, 0, 0, 0
	spritePiece	8, $18, 1, 2, $7C0, 0, 0, 0, 0
	spritePiece	0, $18, 1, 2, 0, 0, 0, 0, 0
word_185A48_End

word_185A6E:	spriteHeader
	spritePiece	8, -$2C, 1, 4, $7C0, 0, 0, 0, 0
	spritePiece	0, -$2C, 1, 4, 0, 0, 0, 0, 0
	spritePiece	8, -$C, 1, 4, $7C0, 0, 0, 0, 0
	spritePiece	0, -$C, 1, 4, 0, 0, 0, 0, 0
	spritePiece	8, $14, 1, 3, $7C0, 0, 0, 0, 0
	spritePiece	0, $14, 1, 3, 0, 0, 0, 0, 0
word_185A6E_End

word_185A94:	spriteHeader
	spritePiece	8, -$30, 1, 4, $7C0, 0, 0, 0, 0
	spritePiece	0, -$30, 1, 4, 0, 0, 0, 0, 0
	spritePiece	8, -$10, 1, 4, $7C0, 0, 0, 0, 0
	spritePiece	0, -$10, 1, 4, 0, 0, 0, 0, 0
	spritePiece	8, $10, 1, 4, $7C0, 0, 0, 0, 0
	spritePiece	0, $10, 1, 4, 0, 0, 0, 0, 0
word_185A94_End

word_185ABA:	spriteHeader
	spritePiece	8, -$34, 1, 4, $7C0, 0, 0, 0, 0
	spritePiece	0, -$34, 1, 4, 0, 0, 0, 0, 0
	spritePiece	8, -$14, 1, 4, $7C0, 0, 0, 0, 0
	spritePiece	0, -$14, 1, 4, 0, 0, 0, 0, 0
	spritePiece	8, $C, 1, 4, $7C0, 0, 0, 0, 0
	spritePiece	0, $C, 1, 4, 0, 0, 0, 0, 0
	spritePiece	8, $2C, 1, 1, $7C0, 0, 0, 0, 0
	spritePiece	0, $2C, 1, 1, 0, 0, 0, 0, 0
word_185ABA_End

word_185AEC:	spriteHeader
	spritePiece	8, -$38, 1, 4, $7C0, 0, 0, 0, 0
	spritePiece	0, -$38, 1, 4, 0, 0, 0, 0, 0
	spritePiece	8, -$18, 1, 4, $7C0, 0, 0, 0, 0
	spritePiece	0, -$18, 1, 4, 0, 0, 0, 0, 0
	spritePiece	8, 8, 1, 4, $7C0, 0, 0, 0, 0
	spritePiece	0, 8, 1, 4, 0, 0, 0, 0, 0
	spritePiece	8, $28, 1, 2, $7C0, 0, 0, 0, 0
	spritePiece	0, $28, 1, 2, 0, 0, 0, 0, 0
word_185AEC_End

word_185B1E:	spriteHeader
	spritePiece	8, -$3C, 1, 4, $7C0, 0, 0, 0, 0
	spritePiece	0, -$3C, 1, 4, 0, 0, 0, 0, 0
	spritePiece	8, -$1C, 1, 4, $7C0, 0, 0, 0, 0
	spritePiece	0, -$1C, 1, 4, 0, 0, 0, 0, 0
	spritePiece	8, 4, 1, 4, $7C0, 0, 0, 0, 0
	spritePiece	0, 4, 1, 4, 0, 0, 0, 0, 0
	spritePiece	8, $24, 1, 3, $7C0, 0, 0, 0, 0
	spritePiece	0, $24, 1, 3, 0, 0, 0, 0, 0
word_185B1E_End

word_185B50:	spriteHeader
	spritePiece	8, -$40, 1, 4, $7C0, 0, 0, 0, 0
	spritePiece	0, -$40, 1, 4, 0, 0, 0, 0, 0
	spritePiece	8, -$20, 1, 4, $7C0, 0, 0, 0, 0
	spritePiece	0, -$20, 1, 4, 0, 0, 0, 0, 0
	spritePiece	8, 0, 1, 4, $7C0, 0, 0, 0, 0
	spritePiece	0, 0, 1, 4, 0, 0, 0, 0, 0
	spritePiece	8, $20, 1, 4, $7C0, 0, 0, 0, 0
	spritePiece	0, $20, 1, 4, 0, 0, 0, 0, 0
word_185B50_End

	even
