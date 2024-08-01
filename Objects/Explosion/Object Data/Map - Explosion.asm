; ---------------------------------------------------------------------------
; Sprite mappings - explosion from a badnik or monitor
; ---------------------------------------------------------------------------

Map_Explosion:
		dc.w word_1E762-Map_Explosion
		dc.w word_1E76A-Map_Explosion
		dc.w word_1E772-Map_Explosion
		dc.w word_1E77A-Map_Explosion
		dc.w word_1E782-Map_Explosion
		dc.w word_1E78A-Map_Explosion	; extra (s2)
		dc.w word_1E792-Map_Explosion
word_1E762:
		dc.w 1
		dc.b $F8, 5, 0, 0, $FF, $F8
word_1E76A:
		dc.w 1
		dc.b $F0, $F, 0, 4, $FF, $F0
word_1E772:
		dc.w 1
		dc.b $F0, $F, 0, $14, $FF, $F0
word_1E77A:
		dc.w 1
		dc.b $F0, $F, 0, $24, $FF, $F0
word_1E782:
		dc.w 1
		dc.b $F0, $F, 0, $34, $FF, $F0
word_1E78A:
		dc.w 1
		dc.b $F0, $F, 0, $44, $FF, $F0
word_1E792:
		dc.w 1
		dc.b $F0, $F, 0, $54, $FF, $F0
	even