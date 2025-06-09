; ===========================================================================
; Level pattern load cues
; Load main graphics
; ===========================================================================

; ===========================================================================
; Pattern load cues - Sonic
; ===========================================================================

PLC1_Sonic: plrlistheader
		plreq ArtTile_StarPost, ArtKosPM_EnemyPtsStarPost		; starpost
		plreq ArtTile_Ring_Sparks, ArtKosPM_Ring_Sparks			; rings
		plreq ArtTile_HUD, ArtKosPM_HUD					; HUD
PLC1_Sonic_end

; ===========================================================================
; Pattern load cues 2 - Sonic
; ===========================================================================

PLC2_Sonic: plrlistheader
		plreq ArtTile_SpikesSprings, ArtKosPM_SpikesSprings		; spikes and normal spring
		plreq ArtTile_Monitors, ArtKosPM_Monitors			; monitors
		plreq ArtTile_Explosion, ArtKosPM_Explosion			; explosion
PLC2_Sonic_end

; ===========================================================================
; Level pattern load cues
; Load graphics before and after Title Card
; ===========================================================================

; ===========================================================================
; Pattern load cues - Death Egg (Before)
; ===========================================================================

PLC1_DEZ1_Before: plrlistheader
		plreq $47E, ArtKosPM_GrayButton					; button
PLC1_DEZ1_Before_end

; ===========================================================================
; Pattern load cues - Death Egg (After)
; ===========================================================================

PLC2_DEZ1_After: plrlistheader
		plreq $500, ArtKosPM_Spikebonker				; spikebonker badnik
PLC2_DEZ1_After_end

; ===========================================================================
; Pattern load cues - Death Egg (Before)
; ===========================================================================

PLC1_DEZ2_Before: plrlistheader
		plreq $47E, ArtKosPM_GrayButton					; button
PLC1_DEZ2_Before_end

; ===========================================================================
; Pattern load cues - Death Egg (After)
; ===========================================================================

PLC2_DEZ2_After: plrlistheader
		plreq $500, ArtKosPM_Spikebonker				; spikebonker badnik
PLC2_DEZ2_After_end

; ===========================================================================
; Pattern load cues - Death Egg (Before)
; ===========================================================================

PLC1_DEZ3_Before: plrlistheader
		plreq $47E, ArtKosPM_GrayButton					; button
PLC1_DEZ3_Before_end

; ===========================================================================
; Pattern load cues - Death Egg (After)
; ===========================================================================

PLC2_DEZ3_After: plrlistheader
		plreq $500, ArtKosPM_Spikebonker				; spikebonker badnik
PLC2_DEZ3_After_end

; ===========================================================================
; Pattern load cues - Death Egg (Before)
; ===========================================================================

PLC1_DEZ4_Before: plrlistheader
		plreq $47E, ArtKosPM_GrayButton					; button
PLC1_DEZ4_Before_end

; ===========================================================================
; Pattern load cues - Death Egg (After)
; ===========================================================================

PLC2_DEZ4_After: plrlistheader
		plreq $500, ArtKosPM_Spikebonker				; spikebonker badnik
PLC2_DEZ4_After_end

; ===========================================================================
; Level pattern load cues
; Load animals graphics
; ===========================================================================

; ===========================================================================
; Pattern load cues - Animals (DEZ1)
; ===========================================================================

PLCAnimals_DEZ1: plrlistheader
		plreq $580, ArtKosPM_BlueFlicky
		plreq $592, ArtKosPM_Chicken
PLCAnimals_DEZ1_end
