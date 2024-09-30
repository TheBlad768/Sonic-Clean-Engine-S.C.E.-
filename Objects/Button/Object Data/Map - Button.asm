; ---------------------------------------------------------------------------
; Sprite mappings - switches
; ---------------------------------------------------------------------------

Map_Button:
		dc.w word_2C724-Map_Button
		dc.w word_2C732-Map_Button
		dc.w word_2C73A-Map_Button
word_2C724:
		dc.w 2
		dc.b $F4, $C, 0, 0, $FF, $F0
		dc.b $FC, 4, 0, 4, $FF, $F8
word_2C732:
		dc.w 1
		dc.b $FC, $C, 0, 0, $FF, $F0
word_2C73A:
		dc.w 2
		dc.b $F8, $C, 0, 0, $FF, $F0
		dc.b 0, 4, 0, 4, $FF, $F8
	even