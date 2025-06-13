; ---------------------------------------------------------------------------
; Sprite mappings - results
; ---------------------------------------------------------------------------

Map_Results:
		dc.w 0					; 0 Null
		dc.w word_2F2E2-Map_Results		; 1 (Number 0)
		dc.w word_2F2EA-Map_Results		; 2 (Number 1)
		dc.w word_2F2F2-Map_Results		; 3 (Number 2)
		dc.w word_2F2FA-Map_Results		; 4 (Number 3)
		dc.w word_2F302-Map_Results		; 5 (Number 4)
		dc.w word_2F30A-Map_Results		; 6 (Number 5)
		dc.w word_2F312-Map_Results		; 7 (Number 6)
		dc.w word_2F31A-Map_Results		; 8 (Number 7)
		dc.w word_2F322-Map_Results		; 9 (Number 8)
		dc.w word_2F32A-Map_Results		; A (Number 9)
		dc.w word_2F332-Map_Results		; B
		dc.w word_2F346-Map_Results		; C (Bonus)
		dc.w word_2F35A-Map_Results		; D (Ring)
		dc.w word_2F362-Map_Results		; E (Time)
		dc.w word_2F36A-Map_Results		; F (ACT)
		dc.w word_2F378-Map_Results		; 10
		dc.w word_2F39E-Map_Results		; 11
		dc.w word_2F3B2-Map_Results		; 12 (Special Stage Name?)
		dc.w word_2F3C6-Map_Results		; 13 (SONIC)
word_2F2E2:
		dc.w 1
		dc.b 0, 1, $A0, 0, 0, 0
word_2F2EA:
		dc.w 1
		dc.b 0, 1, $A0, 2, 0, 0
word_2F2F2:
		dc.w 1
		dc.b 0, 1, $A0, 4, 0, 0
word_2F2FA:
		dc.w 1
		dc.b 0, 1, $A0, 6, 0, 0
word_2F302:
		dc.w 1
		dc.b 0, 1, $A0, 8, 0, 0
word_2F30A:
		dc.w 1
		dc.b 0, 1, $A0, $A, 0, 0
word_2F312:
		dc.w 1
		dc.b 0, 1, $A0, $C, 0, 0
word_2F31A:
		dc.w 1
		dc.b 0, 1, $A0, $E, 0, 0
word_2F322:
		dc.w 1
		dc.b 0, 1, $A0, $10, 0, 0
word_2F32A:
		dc.w 1
		dc.b 0, 1, $A0, $12, 0, 0
word_2F332:
		dc.w 3
		dc.b 0, 1, $A0, $24, 0, 0
		dc.b 0, $D, $A0, $22, 0, 8
		dc.b $F6, 6, $80, $14, 0, $24		; (Drop Art)
word_2F346:						; Bonus
		dc.w 3
		dc.b 0, $D, $A0, $1A, $FF, $FF
		dc.b 0, 1, $A1, $C4, 0, $20		; HUD address
		dc.b $F6, 6, $80, $14, 0, $24		; (Drop Art)
word_2F35A:
		dc.w 1	; Ring
		dc.b 0, $D, $A1, $CC, 0, 0		; HUD address
word_2F362:
		dc.w 1	; Time
		dc.b 0, $D, $A1, $D4, 0, 0		; HUD address
word_2F36A:		; ACT
		dc.w 2
		dc.b $10, 9, $80, $2A, 0, 0		; ACT
		dc.b 0, $F, $80, $66, 0, $11		; (Number)
word_2F378:
		dc.w 6
		dc.b 0, 5, $80, $40, 0, 0
		dc.b 0, 5, $80, $34, 0, $10
		dc.b 0, 5, $80, $3C, 0, $20
		dc.b 0, 5, $80, $38, 0, $30
		dc.b 0, 5, $80, $44, 0, $40
		dc.b 0, $D, $80, $30, 0, $50
word_2F39E:
		dc.w 3
		dc.b 0, 5, $80, $30, 0, 0
		dc.b 0, 5, $80, $38, 0, $10
		dc.b 0, 5, $80, $40, 0, $1E
word_2F3B2:		; Special Stage Name?
		dc.w 3
		dc.b 0, $D, $80, $48, 0, 0
		dc.b 0, $D, $80, $50, 0, $20
		dc.b 0, 5, $80, $58, 0, $40
word_2F3C6:		; SONIC
		dc.w 3
		dc.b 0, $D, $80, $48, 0, 1
		dc.b 0, $D, $80, $50, 0, $21
		dc.b 0, 1, $80, $58, 0, $41
	even