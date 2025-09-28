; ===========================================================================
; Levels pointer data
; ===========================================================================

LevelLoadPointer:

		; DEZ
		include "Levels/DEZ/Pointers/DEZ1 - Pointers.asm"
		include "Levels/DEZ/Pointers/DEZ2 - Pointers.asm"
		include "Levels/DEZ/Pointers/DEZ3 - Pointers.asm"
		include "Levels/DEZ/Pointers/DEZ4 - Pointers.asm"

		zonewarning LevelLoadPointer,((Level_data_addr_RAM_end-Level_data_addr_RAM)*4)

; ===========================================================================
; Compressed level graphics - tile, primary patterns and block mappings
; ===========================================================================

;		Attribute	| Filename	| Folder

		incfile.b	DEZ_8x8_KosPM, "Levels/DEZ/Tiles/Primary.kospm"
		incfile.b	DEZ_16x16_Unc, "Levels/DEZ/Blocks/Primary.unc"
		incfile.b	DEZ_128x128_KosP, "Levels/DEZ/Chunks/Primary.kosp"

; ===========================================================================
; Collision data
; ===========================================================================

		incfile.b	AngleArray, "Data/Misc/Floor/Angle Map.bin"
		incfile.b	HeightMaps, "Data/Misc/Floor/Height Maps.bin"
		incfile.b	HeightMapsRot, "Data/Misc/Floor/Height Maps Rotated.bin"

; ===========================================================================
; Level collision data
; ===========================================================================

;		Attribute	| Filename	| Folder

		incfile.b	DEZ_Solid_Unc, "Levels/DEZ/Collision/1.unc"

; ===========================================================================
; Level layout data
; ===========================================================================

;		Attribute	| Filename	| Folder

		incfile.b	DEZ1_Layout_Unc, "Levels/DEZ/Layout/1.unc"
		incfile.b	DEZ2_Layout_Unc, "Levels/DEZ/Layout/2.unc"
		incfile.b	DEZ3_Layout_Unc, "Levels/DEZ/Layout/3.unc"
		incfile.b	DEZ4_Layout_Unc, "Levels/DEZ/Layout/4.unc"

; ===========================================================================
; Level objects data
; ===========================================================================

		; ObjectTerminat
		ObjectLayoutBoundary

;		Attribute	| Filename	| Folder

		incfile.bo	DEZ1_Objects_Unc, "Levels/DEZ/Object Pos/1.unc"
		incfile.bo	DEZ2_Objects_Unc, "Levels/DEZ/Object Pos/2.unc"
		incfile.bo	DEZ3_Objects_Unc, "Levels/DEZ/Object Pos/3.unc"
		incfile.bo	DEZ4_Objects_Unc, "Levels/DEZ/Object Pos/4.unc"

; ===========================================================================
; Level rings data
; ===========================================================================

		; RingTerminat
		RingLayoutBoundary

;		Attribute	| Filename	| Folder

		incfile.br	DEZ1_Rings_Unc, "Levels/DEZ/Ring Pos/1.unc"
		incfile.br	DEZ2_Rings_Unc, "Levels/DEZ/Ring Pos/2.unc"
		incfile.br	DEZ3_Rings_Unc, "Levels/DEZ/Ring Pos/3.unc"
		incfile.br	DEZ4_Rings_Unc, "Levels/DEZ/Ring Pos/4.unc"
