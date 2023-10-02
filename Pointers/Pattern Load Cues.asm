; ===========================================================================
; Level pattern load cues
; Load graphics before and after Title Card
; ===========================================================================

Offs_PLC: offsetTable

		offsetTableEntry.w PLC1_DEZ1_Before
		offsetTableEntry.w PLC2_DEZ1_After
		offsetTableEntry.w PLC1_DEZ2_Before
		offsetTableEntry.w PLC2_DEZ2_After
		offsetTableEntry.w PLC1_DEZ3_Before
		offsetTableEntry.w PLC2_DEZ3_After
		offsetTableEntry.w PLC1_DEZ4_Before
		offsetTableEntry.w PLC2_DEZ4_After

		zonewarning Offs_PLC,(4*4)

; ===========================================================================
; Pattern load cues - Main 1
; ===========================================================================

PLC_Main: plrlistheader
		plreq ArtTile_StarPost, ArtKosM_EnemyPtsStarPost	; starpost
		plreq ArtTile_Ring_Sparks, ArtKosM_Ring_Sparks	; rings
		plreq ArtTile_HUD, ArtKosM_Hud					; HUD
PLC_Main_end

; ===========================================================================
; Pattern load cues - Main 2
; ===========================================================================

PLC_Main2: plrlistheader
		plreq $47E, ArtKosM_GrayButton					; button
		plreq ArtTile_SpikesSprings, ArtKosM_SpikesSprings	; spikes and normal spring
		plreq ArtTile_Monitors, ArtKosM_Monitors			; monitors
		plreq $5A0, ArtKosM_Explosion						; explosion
PLC_Main2_end

; ===========================================================================
; Pattern load cues - Death Egg (Before)
; ===========================================================================

PLC1_DEZ1_Before: plrlistheader
PLC1_DEZ1_Before_end

; ===========================================================================
; Pattern load cues - Death Egg (After)
; ===========================================================================

PLC2_DEZ1_After: plrlistheader
		plreq $500, ArtKosM_Spikebonker					; spikebonker badnik
PLC2_DEZ1_After_end

; ===========================================================================
; Pattern load cues - Death Egg (Before)
; ===========================================================================

PLC1_DEZ2_Before: plrlistheader
PLC1_DEZ2_Before_end

; ===========================================================================
; Pattern load cues - Death Egg (After)
; ===========================================================================

PLC2_DEZ2_After: plrlistheader
		plreq $500, ArtKosM_Spikebonker					; spikebonker badnik
PLC2_DEZ2_After_end

; ===========================================================================
; Pattern load cues - Death Egg (Before)
; ===========================================================================

PLC1_DEZ3_Before: plrlistheader
PLC1_DEZ3_Before_end

; ===========================================================================
; Pattern load cues - Death Egg (After)
; ===========================================================================

PLC2_DEZ3_After: plrlistheader
		plreq $500, ArtKosM_Spikebonker					; spikebonker badnik
PLC2_DEZ3_After_end

; ===========================================================================
; Pattern load cues - Death Egg (Before)
; ===========================================================================

PLC1_DEZ4_Before: plrlistheader
PLC1_DEZ4_Before_end

; ===========================================================================
; Pattern load cues - Death Egg (After)
; ===========================================================================

PLC2_DEZ4_After: plrlistheader
		plreq $500, ArtKosM_Spikebonker					; spikebonker badnik
PLC2_DEZ4_After_end
