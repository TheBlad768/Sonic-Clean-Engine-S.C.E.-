; ---------------------------------------------------------------------------
; Sprite mappings - Robotnik ship pieces (boss levels)
; ---------------------------------------------------------------------------

Map_RobotnikShipPieces:
		dc.w word_7D6E0-Map_RobotnikShipPieces
		dc.w word_7D6EE-Map_RobotnikShipPieces
		dc.w word_7D6F6-Map_RobotnikShipPieces
		dc.w word_7D704-Map_RobotnikShipPieces
word_7D6E0:
		dc.w 2
		dc.b $EC, $C, 0, $36, $FF, $E4
		dc.b $E4, 4, 0, $5D, $FF, $EC
word_7D6EE:
		dc.w 1
		dc.b $EC, 8, 0, $3A, 0, 4
word_7D6F6:
		dc.w 2
		dc.b $F4, $E, 0, $3D, $FF, $E4
		dc.b $C, 8, 0, $52, $FF, $EC
word_7D704:
		dc.w 2
		dc.b $F4, $A, 0, $49, 0, 4
		dc.b $C, 4, 0, $55, 0, 4
	even