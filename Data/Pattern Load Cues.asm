; ===========================================================================
; Level pattern load cues
; Load main graphics
; ===========================================================================

; ===========================================================================
; Pattern load cues - Sonic
; ===========================================================================

PLC1_Sonic: plrlistheader
		plreq ArtTile_StarPost, ArtKosPlusM_EnemyScoreStarPost			; starpost
		plreq ArtTile_Ring_Sparks, ArtKosPlusM_Ring_Sparks			; rings
		plreq ArtTile_HUD, ArtKosPlusM_HUD					; HUD
		plrlistend

; ===========================================================================
; Pattern load cues 2 - Sonic
; ===========================================================================

PLC2_Sonic: plrlistheader
		plreq ArtTile_SpikesSprings, ArtKosPlusM_SpikesSprings			; spikes and normal spring
		plreq ArtTile_Monitors, ArtKosPlusM_Monitors				; monitors
		plreq ArtTile_Explosion, ArtKosPlusM_Explosion				; explosion
		plrlistend

; ===========================================================================
; Level pattern load cues
; Load graphics before and after Title Card
; ===========================================================================

; ===========================================================================
; Pattern load cues - Death Egg Zone (Before)
; ===========================================================================

PLC1_DEZ1_Before: plrlistheader
		plreq $47E, ArtKosPlusM_GrayButton					; button
		plrlistend

; ===========================================================================
; Pattern load cues - Death Egg Zone (After)
; ===========================================================================

PLC2_DEZ1_After: plrlistheader
		plreq $500, ArtKosPlusM_Spikebonker					; spikebonker badnik
		plrlistend

; ===========================================================================
; Pattern load cues - Death Egg Zone (Before)
; ===========================================================================

PLC1_DEZ2_Before: plrlistheader
		plreq $47E, ArtKosPlusM_GrayButton					; button
		plrlistend

; ===========================================================================
; Pattern load cues - Death Egg Zone (After)
; ===========================================================================

PLC2_DEZ2_After: plrlistheader
		plreq $500, ArtKosPlusM_Spikebonker					; spikebonker badnik
		plrlistend

; ===========================================================================
; Pattern load cues - Death Egg Zone (Before)
; ===========================================================================

PLC1_DEZ3_Before: plrlistheader
		plreq $47E, ArtKosPlusM_GrayButton					; button
		plrlistend

; ===========================================================================
; Pattern load cues - Death Egg Zone (After)
; ===========================================================================

PLC2_DEZ3_After: plrlistheader
		plreq $500, ArtKosPlusM_Spikebonker					; spikebonker badnik
		plrlistend

; ===========================================================================
; Pattern load cues - Death Egg Zone (Before)
; ===========================================================================

PLC1_DEZ4_Before: plrlistheader
		plreq $47E, ArtKosPlusM_GrayButton					; button
		plrlistend

; ===========================================================================
; Pattern load cues - Death Egg Zone (After)
; ===========================================================================

PLC2_DEZ4_After: plrlistheader
		plreq $500, ArtKosPlusM_Spikebonker					; spikebonker badnik
		plrlistend

; ===========================================================================
; Level pattern load cues
; Load animals graphics
; ===========================================================================

; ===========================================================================
; Pattern load cues - Animals (DEZ1)
; ===========================================================================

PLCAnimals_DEZ1: plrlistheader
		plreq $580, ArtKosPlusM_BlueFlicky
		plreq $592, ArtKosPlusM_Chicken
		plrlistend
