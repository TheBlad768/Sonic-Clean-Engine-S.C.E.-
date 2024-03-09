; ===========================================================================
; Levels pointer data
; ===========================================================================

LevelLoadPointer:

		; DEZ1
		dc.l AnPal_DEZ, LevelPointer_Null, LevelPointer_Null, LevelPointer_Null										; Animate Palette, Resize, WaterResize, AfterBoss
		dc.l DEZ1_ScreenInit, DEZ1_BackgroundInit, DEZ1_ScreenEvent, DEZ1_BackgroundEvent						; ScreenInit, BackgroundInit, ScreenEvent, BackgroundEvent
		dc.l LevelPointer_Null, AnimateTiles_DoAniPLC, AniPLC_DEZ												; Animate init, Animate tiles main code, Animate tiles PLC scripts
		levartptrs DEZ_8x8_KosM, DEZ_16x16_Unc, DEZ_128x128_Kos, palid_DEZ, palid_WaterDEZ, mus_DEZ1			; Level 1st 8x8 data, 1st 16x16 data, 1st 128x128 data, palette, music
		dc.l DEZ1_Solid, DEZ1_Layout, DEZ1_Sprites, DEZ1_Rings													; Level solid, Level layout, Level sprites, Level rings
		dc.l PLC1_DEZ1_Before, PLC2_DEZ1_After, PLCAnimals_DEZ1												; PLC1, PLC2, Animals
		dc.w 0, $A20, 0, $4A0																					; Level xstart, Level xend, Level ystart, Level yend
		watpalptrs $1000, palid_WaterSonic, palid_WaterSonic													; Starting water height, Water Sonic palette, unused
		binclude "Levels/DEZ/Start Location/1.bin"																; Players start location
		dc.l Debug_DEZ1																						; Debug Mode

		; DEZ2
		dc.l AnPal_DEZ, LevelPointer_Null, LevelPointer_Null, LevelPointer_Null										; Animate Palette, Resize, WaterResize, AfterBoss
		dc.l DEZ1_ScreenInit, DEZ1_BackgroundInit, DEZ1_ScreenEvent, DEZ1_BackgroundEvent						; ScreenInit, BackgroundInit, ScreenEvent, BackgroundEvent
		dc.l LevelPointer_Null, AnimateTiles_DoAniPLC, AniPLC_DEZ												; Animate init, Animate tiles main code, Animate tiles PLC scripts
		levartptrs DEZ_8x8_KosM, DEZ_16x16_Unc, DEZ_128x128_Kos, palid_DEZ, palid_WaterDEZ, mus_DEZ1			; Level 1st 8x8 data, 1st 16x16 data, 1st 128x128 data, palette, music
		dc.l DEZ1_Solid, DEZ1_Layout, DEZ1_Sprites, DEZ1_Rings													; Level solid, Level layout, Level sprites, Level rings
		dc.l PLC1_DEZ2_Before, PLC2_DEZ2_After, PLCAnimals_DEZ1												; PLC1, PLC2, Animals
		dc.w 0, $A20, 0, $4A0																					; Level xstart, Level xend, Level ystart, Level yend
		watpalptrs $1000, palid_WaterSonic, palid_WaterSonic													; Starting water height, Water Sonic palette, unused
		binclude "Levels/DEZ/Start Location/1.bin"																; Players start location
		dc.l Debug_DEZ1																						; Debug Mode

		; DEZ3
		dc.l AnPal_DEZ, LevelPointer_Null, LevelPointer_Null, LevelPointer_Null										; Animate Palette, Resize, WaterResize, AfterBoss
		dc.l DEZ1_ScreenInit, DEZ1_BackgroundInit, DEZ1_ScreenEvent, DEZ1_BackgroundEvent						; ScreenInit, BackgroundInit, ScreenEvent, BackgroundEvent
		dc.l LevelPointer_Null, AnimateTiles_DoAniPLC, AniPLC_DEZ												; Animate init, Animate tiles main code, Animate tiles PLC scripts
		levartptrs DEZ_8x8_KosM, DEZ_16x16_Unc, DEZ_128x128_Kos, palid_DEZ, palid_WaterDEZ, mus_DEZ1			; Level 1st 8x8 data, 1st 16x16 data, 1st 128x128 data, palette, music
		dc.l DEZ1_Solid, DEZ1_Layout, DEZ1_Sprites, DEZ1_Rings													; Level solid, Level layout, Level sprites, Level rings
		dc.l PLC1_DEZ3_Before, PLC2_DEZ3_After, PLCAnimals_DEZ1												; PLC1, PLC2, Animals
		dc.w 0, $A20, 0, $4A0																					; Level xstart, Level xend, Level ystart, Level yend
		watpalptrs $1000, palid_WaterSonic, palid_WaterSonic													; Starting water height, Water Sonic palette, unused
		binclude "Levels/DEZ/Start Location/1.bin"																; Players start location
		dc.l Debug_DEZ1																						; Debug Mode

		; DEZ4
		dc.l AnPal_DEZ, LevelPointer_Null, LevelPointer_Null, LevelPointer_Null										; Animate Palette, Resize, WaterResize, AfterBoss
		dc.l DEZ1_ScreenInit, DEZ1_BackgroundInit, DEZ1_ScreenEvent, DEZ1_BackgroundEvent						; ScreenInit, BackgroundInit, ScreenEvent, BackgroundEvent
		dc.l LevelPointer_Null, AnimateTiles_DoAniPLC, AniPLC_DEZ												; Animate init, Animate tiles main code, Animate tiles PLC scripts
		levartptrs DEZ_8x8_KosM, DEZ_16x16_Unc, DEZ_128x128_Kos, palid_DEZ, palid_WaterDEZ, mus_DEZ1			; Level 1st 8x8 data, 1st 16x16 data, 1st 128x128 data, palette, music
		dc.l DEZ1_Solid, DEZ1_Layout, DEZ1_Sprites, DEZ1_Rings													; Level solid, Level layout, Level sprites, Level rings
		dc.l PLC1_DEZ4_Before, PLC2_DEZ4_After, PLCAnimals_DEZ1												; PLC1, PLC2, Animals
		dc.w 0, $A20, 0, $4A0																					; Level xstart, Level xend, Level ystart, Level yend
		watpalptrs $1000, palid_WaterSonic, palid_WaterSonic													; Starting water height, Water Sonic palette, unused
		binclude "Levels/DEZ/Start Location/1.bin"																; Players start location
		dc.l Debug_DEZ1																						; Debug Mode

		zonewarning LevelLoadPointer,(104*4)

; ===========================================================================
; Compressed level graphics - tile, primary patterns and block mappings
; ===========================================================================

DEZ_8x8_KosM:		binclude "Levels/DEZ/Tiles/Primary.bin"
	even
DEZ_16x16_Unc:		binclude "Levels/DEZ/Blocks/Primary.bin"
	even
DEZ_128x128_Kos:	binclude "Levels/DEZ/Chunks/Primary.bin"
	even

; ===========================================================================
; Collision data
; ===========================================================================

AngleArray:			binclude "Misc Data/Angle Map.bin"
	even
HeightMaps:			binclude "Misc Data/Height Maps.bin"
	even
HeightMapsRot:		binclude "Misc Data/Height Maps Rotated.bin"
	even

; ===========================================================================
; Level collision data
; ===========================================================================

DEZ1_Solid:			binclude "Levels/DEZ/Collision/1.bin"
	even

; ===========================================================================
; Level layout data
; ===========================================================================

DEZ1_Layout:		binclude "Levels/DEZ/Layout/1.bin"
	even

; ===========================================================================
; Level object data
; ===========================================================================

	ObjectLayoutBoundary
DEZ1_Sprites:		binclude "Levels/DEZ/Object Pos/1.bin"
	ObjectLayoutBoundary
	even

; ===========================================================================
; Level ring data
; ===========================================================================

	RingLayoutBoundary
DEZ1_Rings:			binclude "Levels/DEZ/Ring Pos/1.bin"
	RingLayoutBoundary
	even
