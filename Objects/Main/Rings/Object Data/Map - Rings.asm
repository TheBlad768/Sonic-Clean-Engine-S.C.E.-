; ---------------------------------------------------------------------------
; Sprite mappings - rings
; ---------------------------------------------------------------------------

Map_Ring:
		dc.w Map_Ring_10-Map_Ring	; Ring
		dc.w Map_Ring_30-Map_Ring	; Spark 1
		dc.w Map_Ring_38-Map_Ring	; Spark 2
		dc.w Map_Ring_40-Map_Ring	; Spark 3
		dc.w Map_Ring_48-Map_Ring	; Spark 4
Map_Ring_10:
		dc.w 1
		dc.b $F8, 5, 0, 0, $FF, $F8
Map_Ring_30:
		dc.w 1
		dc.b $F8, 5, 0, 4, $FF, $F8
Map_Ring_38:
		dc.w 1
		dc.b $F8, 5, $18, 4, $FF, $F8
Map_Ring_40:
		dc.w 1
		dc.b $F8, 5, 8, 4, $FF, $F8
Map_Ring_48:
		dc.w 1
		dc.b $F8, 5, $10, 4, $FF, $F8
	even