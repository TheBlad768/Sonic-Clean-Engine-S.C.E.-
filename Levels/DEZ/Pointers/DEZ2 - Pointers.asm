; ---------------------------------------------------------------------------
; DEZ2 level pointer data
; ---------------------------------------------------------------------------

		; Level init
		dc.l AnPal_DEZ								; Animate palette
		dc.l 0										; Resize
		dc.l 0										; Water resize
		dc.l 0										; After boss

		; Level setup
		dc.l DEZ1_ScreenInit							; Screen init
		dc.l DEZ1_BackgroundInit						; Background init
		dc.l DEZ1_ScreenEvent							; Screen event
		dc.l DEZ1_BackgroundEvent					; Background event

		; Animate tiles
		dc.l 0										; Animate art init
		dc.l AnimateTiles_DoAniPLC					; Animate tiles main code
		dc.l AniPLC_DEZ								; Animate tiles PLC scripts

		; Level 1st 8x8 data, 2nd 8x8 data, Blocks pointer, 1st 16x16 data, 2nd 16x16 data, Chunks pointer, 1st 128x128 data, 2nd 128x128 data, Palette, Water palette, Music
		levartptrs \
 		DEZ_8x8_KosPM, \
 		0, \
 		DEZ_16x16_Unc, \
 		0, \
 		0, \
 		Chunk_table, \
 		DEZ_128x128_KosP, \
 		0, \
		PalID_DEZ, \
		PalID_WaterDEZ, \
		mus_DEZ1

		; Level data 2
		dc.l DEZ_Solid								; Level solid
		dc.l DEZ2_Layout								; Level layout
		dc.l DEZ2_Sprites								; Level sprites
		dc.l DEZ2_Rings								; Level rings

		; PLC
		dc.l PLC1_DEZ2_Before						; PLC1
		dc.l PLC2_DEZ2_After							; PLC2
		dc.l PLCAnimals_DEZ1							; PLC animals

		; Level size
		dc.w 0										; Level xstart
		dc.w $A20									; Level xend
		dc.w 0										; Level ystart
		dc.w $4A0									; Level yend

		; Starting water height, Water Sonic palette, Water Knuckles palette
		watpalptrs \
		$1000, \
		PalID_WaterSonic, \
		PalID_WaterSonic

		; Start location
		binclude "Levels/DEZ/Start Location/2.bin"		; Players start location

		; Debug Mode
	if (GameDebug<>0)&&(GameDebugAlt==0)
		dc.l Debug_DEZ1								; Debug Mode
	else
		dc.l 0										; Unused
	endif
