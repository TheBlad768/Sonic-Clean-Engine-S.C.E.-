; ---------------------------------------------------------------------------
; DPLC mappings - insta shield
; ---------------------------------------------------------------------------

DPLC_InstaShield:
DPLC_InstaShield_0: 	dc.w DPLC_InstaShield_10-DPLC_InstaShield
DPLC_InstaShield_2: 	dc.w DPLC_InstaShield_10-DPLC_InstaShield
DPLC_InstaShield_4: 	dc.w DPLC_InstaShield_10-DPLC_InstaShield
DPLC_InstaShield_6: 	dc.w DPLC_InstaShield_16-DPLC_InstaShield
DPLC_InstaShield_8: 	dc.w DPLC_InstaShield_16-DPLC_InstaShield
DPLC_InstaShield_A: 	dc.w DPLC_InstaShield_16-DPLC_InstaShield
DPLC_InstaShield_C: 	dc.w DPLC_InstaShield_16-DPLC_InstaShield
DPLC_InstaShield_E: 	dc.w DPLC_InstaShield_16-DPLC_InstaShield
DPLC_InstaShield_10: 	dc.b $0, $1
	dc.b $0, $F
	dc.b $1, $6
DPLC_InstaShield_16: 	dc.b $0, $1
	dc.b $1, $7F
	dc.b $2, $7C
	even