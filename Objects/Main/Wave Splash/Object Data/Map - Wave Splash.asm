; ---------------------------------------------------------------------------
; Sprite mappings - water surface
; ---------------------------------------------------------------------------

Map_WaveSplash:
		dc.w word_1F2DC-Map_WaveSplash		; 0 (duplicate)
		dc.w word_1F2DC-Map_WaveSplash		; 1 (duplicate)
		dc.w word_1F2F0-Map_WaveSplash		; 2
		dc.w word_1F304-Map_WaveSplash		; 3
		dc.w word_1F318-Map_WaveSplash		; 4
		dc.w word_1F33E-Map_WaveSplash		; 5
		dc.w word_1F364-Map_WaveSplash		; 6
word_1F2DC:	dc.w 3
		dc.b $FD, $D, 0, 0, $FF, $A0
		dc.b $FD, $D, 0, 0, $FF, $E0
		dc.b $FD, $D, 0, 0, 0, $20
word_1F2F0:	dc.w 3
		dc.b $FD, $D, 0, 8, $FF, $A0
		dc.b $FD, $D, 0, 8, $FF, $E0
		dc.b $FD, $D, 0, 8, 0, $20
word_1F304:	dc.w 3
		dc.b $FD, $D, 8, 0, $FF, $A0
		dc.b $FD, $D, 8, 0, $FF, $E0
		dc.b $FD, $D, 8, 0, 0, $20
word_1F318:	dc.w 6
		dc.b $FD, $D, 0, 0, $FF, $A0
		dc.b $FD, $D, 0, 0, $FF, $C0
		dc.b $FD, $D, 0, 0, $FF, $E0
		dc.b $FD, $D, 0, 0, 0, 0
		dc.b $FD, $D, 0, 0, 0, $20
		dc.b $FD, $D, 0, 0, 0, $40
word_1F33E:	dc.w 6
		dc.b $FD, $D, 0, 8, $FF, $A0
		dc.b $FD, $D, 0, 8, $FF, $C0
		dc.b $FD, $D, 0, 8, $FF, $E0
		dc.b $FD, $D, 0, 8, 0, 0
		dc.b $FD, $D, 0, 8, 0, $20
		dc.b $FD, $D, 0, 8, 0, $40
word_1F364:	dc.w 6
		dc.b $FD, $D, 8, 0, $FF, $A0
		dc.b $FD, $D, 8, 0, $FF, $C0
		dc.b $FD, $D, 8, 0, $FF, $E0
		dc.b $FD, $D, 8, 0, 0, 0
		dc.b $FD, $D, 8, 0, 0, $20
		dc.b $FD, $D, 8, 0, 0, $40
	even