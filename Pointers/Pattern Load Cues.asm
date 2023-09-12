; ===========================================================================
; Level pattern load cues
; ===========================================================================

Offs_PLC: offsetTable

		offsetTableEntry.w PLC1_DEZ1_Misc
		offsetTableEntry.w PLC2_DEZ1_Enemy
		offsetTableEntry.w PLC1_DEZ2_Misc
		offsetTableEntry.w PLC2_DEZ2_Enemy
		offsetTableEntry.w PLC1_DEZ3_Misc
		offsetTableEntry.w PLC2_DEZ3_Enemy
		offsetTableEntry.w PLC1_DEZ4_Misc
		offsetTableEntry.w PLC2_DEZ4_Enemy

		zonewarning Offs_PLC,(4*4)

; ===========================================================================
; Pattern load cues - Main 1
; ===========================================================================

PLC_Main: plrlistheader
		plreq ArtTile_StarPost, ArtKosM_EnemyPtsStarPost	; StarPost
		plreq ArtTile_Ring_Sparks, ArtKosM_Ring_Sparks	; Rings
		plreq ArtTile_HUD, ArtKosM_Hud					; HUD
PLC_Main_end

; ===========================================================================
; Pattern load cues - Main 2
; ===========================================================================

PLC_Main2: plrlistheader
		plreq $47E, ArtKosM_GrayButton					; Button
		plreq ArtTile_SpikesSprings, ArtKosM_SpikesSprings	; Spikes and normal spring
		plreq ArtTile_Monitors, ArtKosM_Monitors			; Monitors
		plreq $5A0, ArtKosM_Explosion						; Explosion
PLC_Main2_end

; ===========================================================================
; Pattern load cues - Death Egg (Misc)
; ===========================================================================

PLC1_DEZ1_Misc: plrlistheader
PLC1_DEZ1_Misc_end

; ===========================================================================
; Pattern load cues - Death Egg (Enemy)
; ===========================================================================

PLC2_DEZ1_Enemy: plrlistheader
		plreq $500, ArtKosM_Spikebonker					; Spikebonker badnik
PLC2_DEZ1_Enemy_end

; ===========================================================================
; Pattern load cues - Death Egg (Misc)
; ===========================================================================

PLC1_DEZ2_Misc: plrlistheader
PLC1_DEZ2_Misc_end

; ===========================================================================
; Pattern load cues - Death Egg (Enemy)
; ===========================================================================

PLC2_DEZ2_Enemy: plrlistheader
		plreq $500, ArtKosM_Spikebonker					; Spikebonker badnik
PLC2_DEZ2_Enemy_end

; ===========================================================================
; Pattern load cues - Death Egg (Misc)
; ===========================================================================

PLC1_DEZ3_Misc: plrlistheader
PLC1_DEZ3_Misc_end

; ===========================================================================
; Pattern load cues - Death Egg (Enemy)
; ===========================================================================

PLC2_DEZ3_Enemy: plrlistheader
		plreq $500, ArtKosM_Spikebonker					; Spikebonker badnik
PLC2_DEZ3_Enemy_end

; ===========================================================================
; Pattern load cues - Death Egg (Misc)
; ===========================================================================

PLC1_DEZ4_Misc: plrlistheader
PLC1_DEZ4_Misc_end

; ===========================================================================
; Pattern load cues - Death Egg (Enemy)
; ===========================================================================

PLC2_DEZ4_Enemy: plrlistheader
		plreq $500, ArtKosM_Spikebonker					; Spikebonker badnik
PLC2_DEZ4_Enemy_end
