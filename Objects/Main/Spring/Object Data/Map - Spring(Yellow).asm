; ---------------------------------------------------------------------------
; Sprite mappings - springs (yellow)
; ---------------------------------------------------------------------------

Map_Spring2:
		dc.w word_237AC-Map_Spring2	; Normal
		dc.w word_237BA-Map_Spring2
		dc.w word_237C2-Map_Spring2
		dc.w word_237F4-Map_Spring2
		dc.w word_23802-Map_Spring2
		dc.w word_2380A-Map_Spring2
		dc.w word_23826-Map_Spring2
		dc.w word_2389C-Map_Spring2
		dc.w word_238B6-Map_Spring2	; Diagonal Spring
		dc.w word_238CA-Map_Spring2	; Diagonal Spring
		dc.w word_238EA-Map_Spring2	; Diagonal Spring
word_237AC:
		dc.w 2
		dc.b $F8, $C, $20, 0, $FF, $F0
		dc.b 0, 4, 0, 4, $FF, $F8
word_237BA:
		dc.w 1
		dc.b 0, $C, $20, 0, $FF, $F0
word_237C2:
		dc.w 2
		dc.b $E8, $C, $20, 0, $FF, $F0
		dc.b $F0, 6, 0, 6, $FF, $F8
word_237F4:
		dc.w 2
		dc.b $F0, 3, $20, 0, 0, 0
		dc.b $F8, 1, 0, 4, $FF, $F8
word_23802:
		dc.w 1
		dc.b $F0, 3, $20, 0, $FF, $F8
word_2380A:
		dc.w 2
		dc.b $F0, 3, $20, 0, 0, $10
		dc.b $F8, 9, 0, 6, $FF, $F8
word_23826:
		dc.w 2
		dc.b 0, $C, $30, 0, $FF, $F0
		dc.b $F8, 4, $10, 4, $FF, $F8
word_2389C:
		dc.w 4
		dc.b $F1, 8, $20, $A, $FF, $EB
		dc.b $F9, 8, $20, $D, $FF, $F3
		dc.b 1, 5, $20, $10, $FF, $FB
		dc.b $FB, 5, 0, $B, $FF, $F1
word_238B6:
		dc.w 3
		dc.b $F7, 8, $20, 0, $FF, $E6
		dc.b $FF, 8, $20, 3, $FF, $EE
		dc.b 7, 5, $20, 6, $FF, $F6
word_238CA:
		dc.w 5
		dc.b $E6, 8, $20, 0, $FF, $F6
		dc.b $EE, 8, $20, 3, $FF, $FE
		dc.b $F6, 5, $20, 6, 0, 6
		dc.b $F5, 4, 0, $F, $FF, $FA
		dc.b $FD, 4, 0, $11, $FF, $F2
word_238EA:
		dc.w 4
		dc.b 7, 8, $30, 0, $FF, $EB
		dc.b $FF, 8, $30, 3, $FF, $F3
		dc.b $EF, 5, $30, 6, $FF, $FB
		dc.b $F5, 5, $10, $B, $FF, $F1
	even