; ---------------------------------------------------------------------------
; Animation script - Spin Dust
; ---------------------------------------------------------------------------

Ani_DashSplashDrown: offsetTable
		offsetTableEntry.w .null	; 0 (null)
		offsetTableEntry.w .splash	; 1 (splash)
		offsetTableEntry.w .spindash	; 2 (spindash dust)
		offsetTableEntry.w .ground	; 3 (from ground)
		offsetTableEntry.w .skid	; 4 (skid dust)

.null		dc.b $7F, 0, afEnd
.splash		dc.b 3, 1, 2, 3, 4, 5, 6, 7, 8, 9, afChange, 0
.spindash	dc.b 1, $A, $B, $C, $D, $E, $F, $10, afEnd
.ground		dc.b 5, $16, $17, $18, $19, $1A, $1B, $1C, $1D, afChange, 0
.skid		dc.b 3, $11, $12, $13, $14, afRoutine
	even