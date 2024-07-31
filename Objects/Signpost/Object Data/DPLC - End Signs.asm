; ---------------------------------------------------------------------------
; DPLC mappings - signpost
; ---------------------------------------------------------------------------

DPLC_EndSigns:
DPLC_EndSigns_0: 	dc.w DPLC_EndSigns_10-DPLC_EndSigns
DPLC_EndSigns_2: 	dc.w DPLC_EndSigns_16-DPLC_EndSigns
DPLC_EndSigns_4: 	dc.w DPLC_EndSigns_1C-DPLC_EndSigns
DPLC_EndSigns_6: 	dc.w DPLC_EndSigns_22-DPLC_EndSigns
DPLC_EndSigns_8: 	dc.w DPLC_EndSigns_28-DPLC_EndSigns
DPLC_EndSigns_A: 	dc.w DPLC_EndSigns_2E-DPLC_EndSigns
DPLC_EndSigns_C: 	dc.w DPLC_EndSigns_32-DPLC_EndSigns
DPLC_EndSigns_E: 	dc.w DPLC_EndSigns_36-DPLC_EndSigns
DPLC_EndSigns_10: 	dc.b $0, $1
	dc.b $0, $B
	dc.b $0, $CB
DPLC_EndSigns_16: 	dc.b $0, $1
	dc.b $1, $8B
	dc.b $2, $4B
DPLC_EndSigns_1C: 	dc.b $0, $1
	dc.b $3, $B
	dc.b $3, $CB
DPLC_EndSigns_22: 	dc.b $0, $1
	dc.b $4, $8B
	dc.b $4, $8B
DPLC_EndSigns_28: 	dc.b $0, $1
	dc.b $5, $4B
	dc.b $6, $B
DPLC_EndSigns_2E: 	dc.b $0, $0
	dc.b $6, $CF
DPLC_EndSigns_32: 	dc.b $0, $0
	dc.b $7, $C3
DPLC_EndSigns_36: 	dc.b $0, $0
	dc.b $6, $CF
	even