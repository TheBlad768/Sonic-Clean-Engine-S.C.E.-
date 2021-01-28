; ===========================================================================
; Level pattern load cues. PLC1 - Nemesis, PLC2 - Kosinski Module.
; ===========================================================================

Offs_PLC: offsetTable

		offsetTableEntry.w PLC1_DEZ1_Misc
		offsetTableEntry.w PLC2_DEZ1_Enemy
		offsetTableEntry.w PLC1_DEZ1_Misc
		offsetTableEntry.w PLC2_DEZ1_Enemy
		offsetTableEntry.w PLC1_DEZ1_Misc
		offsetTableEntry.w PLC2_DEZ1_Enemy
		offsetTableEntry.w PLC1_DEZ1_Misc
		offsetTableEntry.w PLC2_DEZ1_Enemy

		zonewarning Offs_PLC,(4*4)

; ===========================================================================
; Pattern load cues - Main 1
; ===========================================================================

PLC_Main: plrlistheader
		plreq $5E4, ArtNem_Lamp								; Lamppost
		plreq ArtTile_ArtNem_Ring_Sparks, ArtNem_Ring_Sparks	; Rings
		plreq $6C2, ArtNem_Hud								; HUD
PLC_Main_End

; ===========================================================================
; Pattern load cues - Main 2
; ===========================================================================

PLC_Main2: plrlistheader
		plreq $47E, ArtNem_GrayButton					; Button
		plreq $484, ArtNem_SpikesSprings					; Spikes and normal spring
		plreq ArtTile_ArtNem_Powerups, ArtNem_Monitors	; Monitors
		plreq $5A0, ArtNem_Explosion						; Explosion
PLC_Main2_End

; ===========================================================================
; Pattern load cues - Death Egg (Misc)
; ===========================================================================

PLC1_DEZ1_Misc: plrlistheader
PLC1_DEZ1_Misc_End

; ===========================================================================
; Pattern load cues - Death Egg (Enemy)
; ===========================================================================

PLC2_DEZ1_Enemy: plrlistheader
PLC2_DEZ1_Enemy_End
