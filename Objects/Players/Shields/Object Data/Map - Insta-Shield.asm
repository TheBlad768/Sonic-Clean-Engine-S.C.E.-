; ---------------------------------------------------------------------------
; Sprite mappings - insta shield
; ---------------------------------------------------------------------------

Map_InstaShield:
Map_InstaShield_0: 	dc.w Map_InstaShield_10-Map_InstaShield
Map_InstaShield_2: 	dc.w Map_InstaShield_24-Map_InstaShield
Map_InstaShield_4: 	dc.w Map_InstaShield_38-Map_InstaShield
Map_InstaShield_6: 	dc.w Map_InstaShield_46-Map_InstaShield
Map_InstaShield_8: 	dc.w Map_InstaShield_5A-Map_InstaShield
Map_InstaShield_A: 	dc.w Map_InstaShield_6E-Map_InstaShield
Map_InstaShield_C: 	dc.w Map_InstaShield_82-Map_InstaShield
Map_InstaShield_E: 	dc.w Map_InstaShield_84-Map_InstaShield
Map_InstaShield_10: 	dc.b $0, $3
	dc.b $E8, $8, $0, $0, $FF, $F0
	dc.b $F0, $4, $0, $3, $FF, $F8
	dc.b $F8, $0, $0, $5, $0, $0
Map_InstaShield_24: 	dc.b $0, $3
	dc.b $F0, $4, $0, $6, $0, $8
	dc.b $F8, $8, $0, $8, $0, $0
	dc.b $0, $4, $0, $B, $0, $0
Map_InstaShield_38: 	dc.b $0, $2
	dc.b $0, $9, $0, $D, $0, $0
	dc.b $10, $C, $0, $13, $FF, $F8
Map_InstaShield_46: 	dc.b $0, $3
	dc.b $F0, $C, $0, $0, $FF, $E8
	dc.b $F8, $8, $0, $4, $FF, $E8
	dc.b $0, $6, $0, $7, $FF, $E8
Map_InstaShield_5A: 	dc.b $0, $3
	dc.b $E8, $4, $0, $D, $FF, $F0
	dc.b $E8, $B, $0, $F, $0, $0
	dc.b $8, $4, $0, $1B, $0, $8
Map_InstaShield_6E: 	dc.b $0, $3
	dc.b $F0, $4, $18, $1B, $FF, $E8
	dc.b $F8, $B, $18, $F, $FF, $E8
	dc.b $10, $4, $18, $D, $0, $0
Map_InstaShield_82: 	dc.b $0, $0
Map_InstaShield_84: 	dc.b $0, $0
	even