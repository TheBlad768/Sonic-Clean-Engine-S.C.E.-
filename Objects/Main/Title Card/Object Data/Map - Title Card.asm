; ---------------------------------------------------------------------------
; Sprite mappings - title card
; ---------------------------------------------------------------------------

Map_TitleCard:
		dc.w 0						; null
		dc.w Map_TitleCardRBanner-Map_TitleCard		; red banner
		dc.w Map_TitleCardAct-Map_TitleCard		; ACT
		dc.w Map_TitleCardZone-Map_TitleCard		; ZONE
		dc.w Map_TitleCardDEZ-Map_TitleCard		; DEATH EGG
Map_TitleCardRBanner:
		dc.w $10
		dc.b $58, 9, $80, $10, $FF, $E8
		dc.b $58, 9, $80, $16, 0, 0
		dc.b $90, $F, $80, 0, $FF, $E0
		dc.b $90, $F, $80, 0, 0, 0
		dc.b $B0, $F, $80, 0, $FF, $E0
		dc.b $B0, $F, $80, 0, 0, 0
		dc.b $D0, $F, $80, 0, $FF, $E0
		dc.b $D0, $F, $80, 0, 0, 0
		dc.b $F0, $F, $80, 0, $FF, $E0
		dc.b $F0, $F, $80, 0, 0, 0
		dc.b $10, $F, $80, 0, $FF, $E0
		dc.b $10, $F, $80, 0, 0, 0
		dc.b $30, $F, $80, 0, $FF, $E0
		dc.b $30, $F, $80, 0, 0, 0
		dc.b $50, $F, $80, 0, $FF, $E0
		dc.b $50, $F, $80, 0, 0, 0
Map_TitleCardAct:
		dc.w 2
		dc.b $10, 9, $80, $37, $FF, $E4
		dc.b 0, $F, $80, $3D, $FF, $F5
Map_TitleCardZone:
		dc.w 4
		dc.b 0, 6, $80, $31, $FF, $DC			; Z
		dc.b 0, $A, $80, $28, $FF, $EC			; O
		dc.b 0, 6, $80, $22, 0, 4			; N
		dc.b 0, 6, $80, $1C, 0, $14			; E
Map_TitleCardDEZ:
		dc.w 8
		dc.b 0, 6, $80, $53, $FF, $F8			; D
		dc.b 0, 6, $80, $1C, 0, 8			; E
		dc.b 0, 6, $80, $4D, 0, $18			; A
		dc.b 0, 6, $80, $65, 0, $28			; T
		dc.b 0, 6, $80, $5F, 0, $38			; H
		dc.b 0, 6, $80, $1C, 0, $50			; E
		dc.b 0, 6, $80, $59, 0, $60			; G
		dc.b 0, 6, $80, $59, 0, $70			; G
	even
