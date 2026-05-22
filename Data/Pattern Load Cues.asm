; ===========================================================================
; Level pattern load cues
; Load main graphics
; ===========================================================================

; ===========================================================================
; Pattern load cues - Main (Primary)
; ===========================================================================

PLC_Main_Primary: plrlistheader
		plreq ArtTile_StarPost, ArtKosPlusM_EnemyScoreStarPost			; starpost
		plreq ArtTile_Ring_Sparks, ArtKosPlusM_Ring_Sparks			; rings
		plreq ArtTile_HUD, ArtKosPlusM_HUD					; HUD
		plrlistend								; end marker

; ===========================================================================
; Pattern load cues - Main (Secondary)
; ===========================================================================

PLC_Main_Secondary: plrlistheader
		plreq ArtTile_SpikesSprings, ArtKosPlusM_SpikesSprings			; spikes and normal spring
		plreq ArtTile_Monitors, ArtKosPlusM_Monitors				; monitors
		plreq ArtTile_Explosion, ArtKosPlusM_Explosion				; explosion
		plrlistend								; end marker

; ===========================================================================
; Level pattern load cues
; Load graphics before and after Title Card
; ===========================================================================

; ===========================================================================
; Pattern load cues - Death Egg Zone (Primary)
; ===========================================================================

PLC_DEZ1_Primary: plrlistheader
		plreq $47E, ArtKosPlusM_GrayButton					; button
		plrlistend								; end marker

; ===========================================================================
; Pattern load cues - Death Egg Zone (Secondary)
; ===========================================================================

PLC_DEZ1_Secondary: plrlistheader
		plreq $500, ArtKosPlusM_Spikebonker					; spikebonker badnik
		plrlistend								; end marker

; ===========================================================================
; Pattern load cues - Death Egg Zone (Primary)
; ===========================================================================

PLC_DEZ2_Primary: plrlistheader
		plreq $47E, ArtKosPlusM_GrayButton					; button
		plrlistend								; end marker

; ===========================================================================
; Pattern load cues - Death Egg Zone (Secondary)
; ===========================================================================

PLC_DEZ2_Secondary: plrlistheader
		plreq $500, ArtKosPlusM_Spikebonker					; spikebonker badnik
		plrlistend								; end marker

; ===========================================================================
; Pattern load cues - Death Egg Zone (Primary)
; ===========================================================================

PLC_DEZ3_Primary: plrlistheader
		plreq $47E, ArtKosPlusM_GrayButton					; button
		plrlistend								; end marker

; ===========================================================================
; Pattern load cues - Death Egg Zone (Secondary)
; ===========================================================================

PLC_DEZ3_Secondary: plrlistheader
		plreq $500, ArtKosPlusM_Spikebonker					; spikebonker badnik
		plrlistend								; end marker

; ===========================================================================
; Pattern load cues - Death Egg Zone (Primary)
; ===========================================================================

PLC_DEZ4_Primary: plrlistheader
		plreq $47E, ArtKosPlusM_GrayButton					; button
		plrlistend								; end marker

; ===========================================================================
; Pattern load cues - Death Egg Zone (Secondary)
; ===========================================================================

PLC_DEZ4_Secondary: plrlistheader
		plreq $500, ArtKosPlusM_Spikebonker					; spikebonker badnik
		plrlistend								; end marker

; ===========================================================================
; Level pattern load cues
; Load animals graphics
; ===========================================================================

; ===========================================================================
; Pattern load cues - Animals (DEZ1)
; ===========================================================================

PLC_Animals_DEZ1: plrlistheader
		plreq $580, ArtKosPlusM_BlueFlicky					; blue flicky animal
		plreq $592, ArtKosPlusM_Chicken						; chicken animal
		plrlistend								; end marker
