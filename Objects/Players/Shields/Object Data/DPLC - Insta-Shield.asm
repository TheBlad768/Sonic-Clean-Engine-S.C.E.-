; ---------------------------------------------------------------------------
; DPLC mappings - Insta Shield
; ---------------------------------------------------------------------------

DPLC_InstaShield:	mappingsTable
	mappingsTableEntry.w DPLC_InstaShield_10
	mappingsTableEntry.w DPLC_InstaShield_10
	mappingsTableEntry.w DPLC_InstaShield_10
	mappingsTableEntry.w DPLC_InstaShield_16
	mappingsTableEntry.w DPLC_InstaShield_16
	mappingsTableEntry.w DPLC_InstaShield_16
	mappingsTableEntry.w DPLC_InstaShield_16
	mappingsTableEntry.w DPLC_InstaShield_16

DPLC_InstaShield_10:	dplcHeader
	dplcEntry	$10, 0
	dplcEntry	7, $10
DPLC_InstaShield_10_End

DPLC_InstaShield_16:	dplcHeader
	dplcEntry	$10, $17
	dplcEntry	$D, $27
DPLC_InstaShield_16_End

	even
