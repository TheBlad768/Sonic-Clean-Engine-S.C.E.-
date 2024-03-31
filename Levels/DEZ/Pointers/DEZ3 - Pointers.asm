; ---------------------------------------------------------------------------
; DEZ levels pointer data
; ---------------------------------------------------------------------------

		; DEZ3
		dc.l AnPal_DEZ, LevelPointer_Null, LevelPointer_Null, LevelPointer_Null										; Animate Palette, Resize, WaterResize, AfterBoss
		dc.l DEZ1_ScreenInit, DEZ1_BackgroundInit, DEZ1_ScreenEvent, DEZ1_BackgroundEvent						; ScreenInit, BackgroundInit, ScreenEvent, BackgroundEvent
		dc.l LevelPointer_Null, AnimateTiles_DoAniPLC, AniPLC_DEZ												; Animate init, Animate tiles main code, Animate tiles PLC scripts
		levartptrs DEZ_8x8_KosM, DEZ_16x16_Unc, DEZ_128x128_Kos, palid_DEZ, palid_WaterDEZ, mus_DEZ1			; Level 1st 8x8 data, 1st 16x16 data, 1st 128x128 data, palette, music
		dc.l DEZ1_Solid, DEZ3_Layout, DEZ3_Sprites, DEZ3_Rings													; Level solid, Level layout, Level sprites, Level rings
		dc.l PLC1_DEZ3_Before, PLC2_DEZ3_After, PLCAnimals_DEZ1												; PLC1, PLC2, Animals
		dc.w 0, $A20, 0, $4A0																					; Level xstart, Level xend, Level ystart, Level yend
		watpalptrs $1000, palid_WaterSonic, palid_WaterSonic													; Starting water height, Water Sonic palette, unused
		binclude "Levels/DEZ/Start Location/3.bin"																; Players start location

	if GameDebug
		dc.l Debug_DEZ1																						; Debug Mode
	else
		dc.l 0																								; Unused
	endif