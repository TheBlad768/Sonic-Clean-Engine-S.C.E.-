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

DEZ_8x8_KosPM:		binclude "Levels/DEZ/Tiles/Primary.kospm"
	even
DEZ_16x16_Unc:			binclude "Levels/DEZ/Blocks/Primary.bin"
	even
DEZ_128x128_KosP:		binclude "Levels/DEZ/Chunks/Primary.kosp"
	even

; ===========================================================================
; Collision data
; ===========================================================================

AngleArray:				binclude "Misc Data/Angle Map.bin"
	even
HeightMaps:				binclude "Misc Data/Height Maps.bin"
	even
HeightMapsRot:			binclude "Misc Data/Height Maps Rotated.bin"
	even

; ===========================================================================
; Level collision data
; ===========================================================================

DEZ_Solid:				binclude "Levels/DEZ/Collision/1.bin"
	even

; ===========================================================================
; Level layout data
; ===========================================================================

DEZ1_Layout:			bincludeEntry "Levels/DEZ/Layout/1.bin"
	even
DEZ2_Layout:			bincludeEntry "Levels/DEZ/Layout/2.bin"
	even
DEZ3_Layout:			bincludeEntry "Levels/DEZ/Layout/3.bin"
	even
DEZ4_Layout:			bincludeEntry "Levels/DEZ/Layout/4.bin"
	even

; ===========================================================================
; Level objects data
; ===========================================================================

	ObjectLayoutBoundary
DEZ1_Sprites:			binclude "Levels/DEZ/Object Pos/1.bin"
	ObjectLayoutBoundary
DEZ2_Sprites:			binclude "Levels/DEZ/Object Pos/2.bin"
	ObjectLayoutBoundary
DEZ3_Sprites:			binclude "Levels/DEZ/Object Pos/3.bin"
	ObjectLayoutBoundary
DEZ4_Sprites:			binclude "Levels/DEZ/Object Pos/4.bin"
	ObjectLayoutBoundary
	even

; ===========================================================================
; Level rings data
; ===========================================================================

	RingLayoutBoundary
DEZ1_Rings:				binclude "Levels/DEZ/Ring Pos/1.bin"
	RingLayoutBoundary
DEZ2_Rings:				binclude "Levels/DEZ/Ring Pos/2.bin"
	RingLayoutBoundary
DEZ3_Rings:				binclude "Levels/DEZ/Ring Pos/3.bin"
	RingLayoutBoundary
DEZ4_Rings:				binclude "Levels/DEZ/Ring Pos/4.bin"
	RingLayoutBoundary
	even
