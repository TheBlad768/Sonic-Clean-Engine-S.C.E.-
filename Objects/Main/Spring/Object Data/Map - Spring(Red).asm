; ---------------------------------------------------------------------------
; Sprite mappings - springs (red)
; ---------------------------------------------------------------------------

Map_Spring:
		dc.w word_23788-Map_Spring	; Normal
		dc.w word_23796-Map_Spring
		dc.w word_2379E-Map_Spring
		dc.w word_237D0-Map_Spring
		dc.w word_237DE-Map_Spring
		dc.w word_237E6-Map_Spring
		dc.w word_23818-Map_Spring
		dc.w word_23834-Map_Spring
		dc.w word_2384E-Map_Spring	; Diagonal Spring
		dc.w word_23862-Map_Spring	; Diagonal Spring
		dc.w word_23882-Map_Spring	; Diagonal Spring
word_23788:
		dc.w 2
		dc.b $F8, $C, 0, 0, $FF, $F0
		dc.b 0, 4, 0, 4, $FF, $F8
word_23796:
		dc.w 1
		dc.b 0, $C, 0, 0, $FF, $F0
word_2379E:
		dc.w 2
		dc.b $E8, $C, 0, 0, $FF, $F0
		dc.b $F0, 6, 0, 6, $FF, $F8
word_237D0:
		dc.w 2
		dc.b $F0, 3, 0, 0, 0, 0
		dc.b $F8, 1, 0, 4, $FF, $F8
word_237DE:
		dc.w 1
		dc.b $F0, 3, 0, 0, $FF, $F8
word_237E6:
		dc.w 2
		dc.b $F0, 3, 0, 0, 0, $10
		dc.b $F8, 9, 0, 6, $FF, $F8
word_23818:
		dc.w 2
		dc.b 0, $C, $10, 0, $FF, $F0
		dc.b $F8, 4, $10, 4, $FF, $F8
word_23834:
		dc.w 4
		dc.b $F1, 8, 0, 0, $FF, $EB
		dc.b $F9, 8, 0, 3, $FF, $F3
		dc.b 1, 5, 0, 6, $FF, $FB
		dc.b $FB, 5, 0, $B, $FF, $F1
word_2384E:
		dc.w 3
		dc.b $F7, 8, 0, 0, $FF, $E6
		dc.b $FF, 8, 0, 3, $FF, $EE
		dc.b 7, 5, 0, 6, $FF, $F6
word_23862:
		dc.w 5
		dc.b $E6, 8, 0, 0, $FF, $F6
		dc.b $EE, 8, 0, 3, $FF, $FE
		dc.b $F6, 5, 0, 6, 0, 6
		dc.b $F5, 4, 0, $F, $FF, $FA
		dc.b $FD, 4, 0, $11, $FF, $F2
word_23882:
		dc.w 4
		dc.b 7, 8, $10, 0, $FF, $EB
		dc.b $FF, 8, $10, 3, $FF, $F3
		dc.b $EF, 5, $10, 6, $FF, $FB
		dc.b $F5, 5, $10, $B, $FF, $F1
	even