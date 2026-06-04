; ---------------------------------------------------------------------------
; Sprite mappings - results
; ---------------------------------------------------------------------------

Map_Results:	mappingsTable
	dc.w 0					; 0 Null
	mappingsTableEntry.w word_2F2E2		; 1 (Number 0)
	mappingsTableEntry.w word_2F2EA		; 2 (Number 1)
	mappingsTableEntry.w word_2F2F2		; 3 (Number 2)
	mappingsTableEntry.w word_2F2FA		; 4 (Number 3)
	mappingsTableEntry.w word_2F302		; 5 (Number 4)
	mappingsTableEntry.w word_2F30A		; 6 (Number 5)
	mappingsTableEntry.w word_2F312		; 7 (Number 6)
	mappingsTableEntry.w word_2F31A		; 8 (Number 7)
	mappingsTableEntry.w word_2F322		; 9 (Number 8)
	mappingsTableEntry.w word_2F32A		; A (Number 9)
	mappingsTableEntry.w word_2F332		; B (Total)
	mappingsTableEntry.w word_2F346		; C (Bonus)
	mappingsTableEntry.w word_2F35A		; D (Ring)
	mappingsTableEntry.w word_2F362		; E (Time)
	mappingsTableEntry.w word_2F36A		; F (ACT)
	mappingsTableEntry.w word_2F378		; 10
	mappingsTableEntry.w word_2F39E		; 11
	mappingsTableEntry.w word_2F3B2		; 12 (SUPER/HYPER)
	mappingsTableEntry.w word_2F3C6		; 13 (SONIC)

word_2F2E2:	spriteHeader
	spritePiece	0, 0, 1, 2, 0, 0, 0, 1, 1
word_2F2E2_End

word_2F2EA:	spriteHeader
	spritePiece	0, 0, 1, 2, 2, 0, 0, 1, 1
word_2F2EA_End

word_2F2F2:	spriteHeader
	spritePiece	0, 0, 1, 2, 4, 0, 0, 1, 1
word_2F2F2_End

word_2F2FA:	spriteHeader
	spritePiece	0, 0, 1, 2, 6, 0, 0, 1, 1
word_2F2FA_End

word_2F302:	spriteHeader
	spritePiece	0, 0, 1, 2, 8, 0, 0, 1, 1
word_2F302_End

word_2F30A:	spriteHeader
	spritePiece	0, 0, 1, 2, $A, 0, 0, 1, 1
word_2F30A_End

word_2F312:	spriteHeader
	spritePiece	0, 0, 1, 2, $C, 0, 0, 1, 1
word_2F312_End

word_2F31A:	spriteHeader
	spritePiece	0, 0, 1, 2, $E, 0, 0, 1, 1
word_2F31A_End

word_2F322:	spriteHeader
	spritePiece	0, 0, 1, 2, $10, 0, 0, 1, 1
word_2F322_End

word_2F32A:	spriteHeader
	spritePiece	0, 0, 1, 2, $12, 0, 0, 1, 1
word_2F32A_End

word_2F332:	spriteHeader
	spritePiece	0, 0, 1, 2, $24, 0, 0, 1, 1
	spritePiece	8, 0, 4, 2, $22, 0, 0, 1, 1
	spritePiece	$24, -$A, 2, 3, $14, 0, 0, 0, 1
word_2F332_End

word_2F346:	spriteHeader
	spritePiece	-1, 0, 4, 2, $1A, 0, 0, 1, 1
	spritePiece	$20, 0, 1, 2, $1C8, 0, 0, 1, 1
	spritePiece	$24, -$A, 2, 3, $14, 0, 0, 0, 1
word_2F346_End

word_2F35A:	spriteHeader
	spritePiece	0, 0, 4, 2, $1CE, 0, 0, 1, 1
word_2F35A_End

word_2F362:	spriteHeader
	spritePiece	0, 0, 4, 2, $1D6, 0, 0, 1, 1
word_2F362_End

word_2F36A:	spriteHeader
	spritePiece	0, $10, 3, 2, $2A, 0, 0, 0, 1
	spritePiece	$11, 0, 4, 4, $66, 0, 0, 0, 1
word_2F36A_End

word_2F378:	spriteHeader
	spritePiece	0, 0, 2, 2, $40, 0, 0, 0, 1
	spritePiece	$10, 0, 2, 2, $34, 0, 0, 0, 1
	spritePiece	$20, 0, 2, 2, $3C, 0, 0, 0, 1
	spritePiece	$30, 0, 2, 2, $38, 0, 0, 0, 1
	spritePiece	$40, 0, 2, 2, $44, 0, 0, 0, 1
	spritePiece	$50, 0, 4, 2, $30, 0, 0, 0, 1
word_2F378_End

word_2F39E:	spriteHeader
	spritePiece	0, 0, 2, 2, $30, 0, 0, 0, 1
	spritePiece	$10, 0, 2, 2, $38, 0, 0, 0, 1
	spritePiece	$1E, 0, 2, 2, $40, 0, 0, 0, 1
word_2F39E_End

word_2F3B2:	spriteHeader
	spritePiece	0, 0, 4, 2, $48, 0, 0, 0, 1
	spritePiece	$20, 0, 4, 2, $50, 0, 0, 0, 1
	spritePiece	$40, 0, 2, 2, $58, 0, 0, 0, 1
word_2F3B2_End

word_2F3C6:	spriteHeader
	spritePiece	1, 0, 4, 2, $48, 0, 0, 0, 1
	spritePiece	$21, 0, 4, 2, $50, 0, 0, 0, 1
	spritePiece	$41, 0, 1, 2, $58, 0, 0, 0, 1
word_2F3C6_End

	even
