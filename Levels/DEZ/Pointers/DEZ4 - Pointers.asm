; ---------------------------------------------------------------------------
; DEZ4 level pointer data
; ---------------------------------------------------------------------------

		; Level init
		dc.l 0									; Resize
		dc.l 0									; Water resize
		dc.l 0									; After boss

		; Animate palette
		dc.l AnimatePalette_DoAniPal						; Animate palette main code
		dc.l AniPalette_DEZ							; Animate palette scripts

		; Level setup
		dc.l DEZ1_ScreenInit							; Screen init
		dc.l DEZ1_BackgroundInit						; Background init
		dc.l DEZ1_ScreenEvent							; Screen event
		dc.l DEZ1_BackgroundEvent						; Background event

		; Animate tiles
		dc.l 0									; Animate art init
		dc.l AnimateTiles_DoAniPLC						; Animate tiles main code
		dc.l AniPLC_DEZ								; Animate tiles PLC scripts

		; Art 1st 8x8 data, 2nd 8x8 data
		; Blocks pointer, 1st 16x16 data, 2nd 16x16 data
		; Chunks pointer, 1st 128x128 data, 2nd 128x128 data
		; Layout pointer, 1st data, 2nd data
		; Solid pointer, 1st data, 2nd data
		; Objects pointer, 1st data, 2nd data
		; Rings pointer, 1st data, 2nd data
		; Palette, Water palette, Music
		levartptrs \
		DEZ_8x8_KosPM, \
		0, \
		DEZ_16x16_Unc, \
		0, \
		0, \
		Chunk_table, \
		DEZ_128x128_KosP, \
		0, \
		DEZ4_Layout_Unc, \
		0, \
		0, \
		DEZ_Solid_Unc, \
		0, \
		0, \
		DEZ4_Objects_Unc, \
		0, \
		0, \
		DEZ4_Rings_Unc, \
		0, \
		0, \
		PalID_DEZ, \
		PalID_WaterDEZ, \
		mus_DEZ1

		; PLC
		dc.l PLC1_DEZ4_Before							; PLC1
		dc.l PLC2_DEZ4_After							; PLC2
		dc.l PLCAnimals_DEZ1							; PLC animals

		; Level size
		dc.w 0									; Level xstart
		dc.w $A20								; Level xend
		dc.w 0									; Level ystart
		dc.w $4A0								; Level yend

		; Starting water height
		dc.w $1000

		; Sonic palette, Knuckles palette
		dc.b PalID_Sonic
		dc.b PalID_Sonic							; Unused

		; Water Sonic palette, Water Knuckles palette
		dc.b PalID_WaterSonic
		dc.b PalID_WaterSonic							; Unused

		; Players start location
		binclude "Levels/DEZ/Start Location/4.bin"

		; Debug Mode
	if (GameDebug)&&(~~GameDebugAlt)
		dc.l Debug_DEZ1								; Debug Mode
	else
		dc.l 0									; Unused
	endif
