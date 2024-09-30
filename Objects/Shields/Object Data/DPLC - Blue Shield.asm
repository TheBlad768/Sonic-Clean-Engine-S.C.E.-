; ---------------------------------------------------------------------------
; DPLC mappings - blue shield
; ---------------------------------------------------------------------------

DPLC_BlueShield:
DPLC_BlueShield_0: 	dc.w DPLC_BlueShield_C-DPLC_BlueShield
DPLC_BlueShield_2: 	dc.w DPLC_BlueShield_10-DPLC_BlueShield
DPLC_BlueShield_4: 	dc.w DPLC_BlueShield_14-DPLC_BlueShield
DPLC_BlueShield_6: 	dc.w DPLC_BlueShield_18-DPLC_BlueShield
DPLC_BlueShield_8: 	dc.w DPLC_BlueShield_1C-DPLC_BlueShield
DPLC_BlueShield_A: 	dc.w DPLC_BlueShield_20-DPLC_BlueShield
DPLC_BlueShield_C: 	dc.b $0, $1
	dc.b $30, $0
DPLC_BlueShield_10: 	dc.b $0, $1
	dc.b $30, $4
DPLC_BlueShield_14: 	dc.b $0, $1
	dc.b $30, $8
DPLC_BlueShield_18: 	dc.b $0, $1
	dc.b $30, $C
DPLC_BlueShield_1C: 	dc.b $0, $1
	dc.b $30, $10
DPLC_BlueShield_20: 	dc.b $0, $1
	dc.b $B0, $14
	even