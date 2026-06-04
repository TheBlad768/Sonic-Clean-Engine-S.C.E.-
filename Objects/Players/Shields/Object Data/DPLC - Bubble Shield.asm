; ---------------------------------------------------------------------------
; DPLC mappings - Bubble Shield
; ---------------------------------------------------------------------------

DPLC_BubbleShield:	mappingsTable
	mappingsTableEntry.w DPLC_BubbleShield_1A
	mappingsTableEntry.w DPLC_BubbleShield_1E
	mappingsTableEntry.w DPLC_BubbleShield_22
	mappingsTableEntry.w DPLC_BubbleShield_26
	mappingsTableEntry.w DPLC_BubbleShield_2A
	mappingsTableEntry.w DPLC_BubbleShield_2E
	mappingsTableEntry.w DPLC_BubbleShield_32
	mappingsTableEntry.w DPLC_BubbleShield_36
	mappingsTableEntry.w DPLC_BubbleShield_3A
	mappingsTableEntry.w DPLC_BubbleShield_3E
	mappingsTableEntry.w DPLC_BubbleShield_44
	mappingsTableEntry.w DPLC_BubbleShield_4A
	mappingsTableEntry.w DPLC_BubbleShield_52

DPLC_BubbleShield_1A:	dplcHeader
	dplcEntry	4, 0
DPLC_BubbleShield_1A_End

DPLC_BubbleShield_1E:	dplcHeader
	dplcEntry	6, 4
DPLC_BubbleShield_1E_End

DPLC_BubbleShield_22:	dplcHeader
	dplcEntry	9, $A
DPLC_BubbleShield_22_End

DPLC_BubbleShield_26:	dplcHeader
	dplcEntry	9, $13
DPLC_BubbleShield_26_End

DPLC_BubbleShield_2A:	dplcHeader
	dplcEntry	$C, $1C
DPLC_BubbleShield_2A_End

DPLC_BubbleShield_2E:	dplcHeader
	dplcEntry	9, $13
DPLC_BubbleShield_2E_End

DPLC_BubbleShield_32:	dplcHeader
	dplcEntry	9, $A
DPLC_BubbleShield_32_End

DPLC_BubbleShield_36:	dplcHeader
	dplcEntry	6, 4
DPLC_BubbleShield_36_End

DPLC_BubbleShield_3A:	dplcHeader
	dplcEntry	2, 0
DPLC_BubbleShield_3A_End

DPLC_BubbleShield_3E:	dplcHeader
	dplcEntry	9, $28
	dplcEntry	9, $31
DPLC_BubbleShield_3E_End

DPLC_BubbleShield_44:	dplcHeader
	dplcEntry	9, $3A
	dplcEntry	9, $43
DPLC_BubbleShield_44_End

DPLC_BubbleShield_4A:	dplcHeader
	dplcEntry	8, $4C
	dplcEntry	6, $54
	dplcEntry	$C, $5A
DPLC_BubbleShield_4A_End

DPLC_BubbleShield_52:	dplcHeader
	dplcEntry	$10, $66
	dplcEntry	4, $76
	dplcEntry	$10, $7A
DPLC_BubbleShield_52_End

	even
