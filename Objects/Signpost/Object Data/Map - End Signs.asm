; ---------------------------------------------------------------------------
; Sprite mappings - signpost
; ---------------------------------------------------------------------------

Map_EndSigns:
Map_EndSigns_0: 	dc.w Map_EndSigns_10-Map_EndSigns
Map_EndSigns_2: 	dc.w Map_EndSigns_1E-Map_EndSigns
Map_EndSigns_4: 	dc.w Map_EndSigns_2C-Map_EndSigns
Map_EndSigns_6: 	dc.w Map_EndSigns_3A-Map_EndSigns
Map_EndSigns_8: 	dc.w Map_EndSigns_48-Map_EndSigns
Map_EndSigns_A: 	dc.w Map_EndSigns_56-Map_EndSigns
Map_EndSigns_C: 	dc.w Map_EndSigns_5E-Map_EndSigns
Map_EndSigns_E: 	dc.w Map_EndSigns_66-Map_EndSigns
Map_EndSigns_10: 	dc.b $0, $2
	dc.b $F0, $B, $0, $0, $FF, $E8
	dc.b $F0, $B, $0, $C, $0, $0
Map_EndSigns_1E: 	dc.b $0, $2
	dc.b $F0, $B, $0, $0, $FF, $E8
	dc.b $F0, $B, $0, $C, $0, $0
Map_EndSigns_2C: 	dc.b $0, $2
	dc.b $F0, $B, $0, $0, $FF, $E8
	dc.b $F0, $B, $0, $C, $0, $0
Map_EndSigns_3A: 	dc.b $0, $2
	dc.b $F0, $B, $0, $0, $FF, $E8
	dc.b $F0, $B, $8, $C, $0, $0
Map_EndSigns_48: 	dc.b $0, $2
	dc.b $F0, $B, $0, $0, $FF, $E8
	dc.b $F0, $B, $8, $C, $0, $0
Map_EndSigns_56: 	dc.b $0, $1
	dc.b $F0, $F, $0, $0, $FF, $F0
Map_EndSigns_5E: 	dc.b $0, $1
	dc.b $F0, $3, $0, $0, $FF, $FC
Map_EndSigns_66: 	dc.b $0, $1
	dc.b $F0, $F, $8, $0, $FF, $F0
	even