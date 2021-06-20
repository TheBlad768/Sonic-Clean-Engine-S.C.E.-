Map_TitleCard:
		dc.w 0							; Null
		dc.w word_2EE3C-Map_TitleCard	; Red ACT
		dc.w word_2EE9E-Map_TitleCard	; ACT
		dc.w word_2EEAC-Map_TitleCard	; ZONE
		dc.w word_2EEC6-Map_TitleCard	; DEATH EGG
word_2EE3C:
		dc.w $10
		dc.b  $58, 9, $84, $90, $FF, $E8
		dc.b  $58, 9, $84, $96, 0, 0
		dc.b  $90,  $F, $84, $80, $FF, $E0
		dc.b  $90,  $F, $84, $80, 0, 0
		dc.b  $B0,  $F, $84, $80, $FF, $E0
		dc.b  $B0,  $F, $84, $80, 0, 0
		dc.b  $D0,  $F, $84, $80, $FF, $E0
		dc.b  $D0,  $F, $84, $80, 0, 0
		dc.b  $F0,  $F, $84, $80, $FF, $E0
		dc.b  $F0,  $F, $84, $80, 0, 0
		dc.b  $10,  $F, $84, $80, $FF, $E0
		dc.b  $10,  $F, $84, $80, 0, 0
		dc.b  $30,  $F, $84, $80, $FF, $E0
		dc.b  $30,  $F, $84, $80, 0, 0
		dc.b  $50,  $F, $84, $80, $FF, $E0
		dc.b  $50,  $F, $84, $80, 0, 0
word_2EE9E:
		dc.w 2
		dc.b  $10, 9, $84, $B7, $FF, $E4
		dc.b	0,  $F, $84, $BD, $FF, $F5
word_2EEAC:
		dc.w 4
		dc.b	0, 6, $84, $B1, $FF, $DC		; Z
		dc.b	0,  $A, $84, $A8, $FF, $EC		; O
		dc.b	0, 6, $84, $A2, 0, 4			; N
		dc.b	0, 6, $84, $9C, 0, $14			; E
word_2EEC6:
		dc.w 8
		dc.b	0, 6, $84, $D3, $FF, $F8		; D
		dc.b	0, 6, $84, $9C, 0, 8			; E
		dc.b	0, 6, $84, $CD, 0, $18			; A
		dc.b	0, 6, $84, $E5, 0, $28			; T
		dc.b	0, 6, $84, $DF, 0, $38			; H
		dc.b	0, 6, $84, $9C, 0, $50			; E
		dc.b	0, 6, $84, $D9, 0, $60			; G
		dc.b	0, 6, $84, $D9, 0, $70			; G