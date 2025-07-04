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

DEZ_8x8_KosPM:			binclude "Levels/DEZ/Tiles/Primary.kospm"
	even
DEZ_16x16_Unc:			binclude "Levels/DEZ/Blocks/Primary.unc"
	even
DEZ_128x128_KosP:		binclude "Levels/DEZ/Chunks/Primary.kosp"
	even

; ===========================================================================
; Collision data
; ===========================================================================

AngleArray:			binclude "Data/Misc/Floor/Angle Map.bin"
	even
HeightMaps:			binclude "Data/Misc/Floor/Height Maps.bin"
	even
HeightMapsRot:			binclude "Data/Misc/Floor/Height Maps Rotated.bin"
	even

; ===========================================================================
; Level collision data
; ===========================================================================

DEZ_Solid_Unc:			binclude "Levels/DEZ/Collision/1.unc"
	even

; ===========================================================================
; Level layout data
; ===========================================================================

DEZ1_Layout_Unc:		bincludeEntry "Levels/DEZ/Layout/1.unc"
	even
DEZ2_Layout_Unc:		bincludeEntry "Levels/DEZ/Layout/2.unc"
	even
DEZ3_Layout_Unc:		bincludeEntry "Levels/DEZ/Layout/3.unc"
	even
DEZ4_Layout_Unc:		bincludeEntry "Levels/DEZ/Layout/4.unc"
	even

; ===========================================================================
; Level objects data
; ===========================================================================

	ObjectLayoutBoundary
DEZ1_Objects_Unc:		binclude "Levels/DEZ/Object Pos/1.unc"
	ObjectLayoutBoundary
DEZ2_Objects_Unc:		binclude "Levels/DEZ/Object Pos/2.unc"
	ObjectLayoutBoundary
DEZ3_Objects_Unc:		binclude "Levels/DEZ/Object Pos/3.unc"
	ObjectLayoutBoundary
DEZ4_Objects_Unc:		binclude "Levels/DEZ/Object Pos/4.unc"
	ObjectLayoutBoundary
	even

; ===========================================================================
; Level rings data
; ===========================================================================

	RingLayoutBoundary
DEZ1_Rings_Unc:			binclude "Levels/DEZ/Ring Pos/1.unc"
	RingLayoutBoundary
DEZ2_Rings_Unc:			binclude "Levels/DEZ/Ring Pos/2.unc"
	RingLayoutBoundary
DEZ3_Rings_Unc:			binclude "Levels/DEZ/Ring Pos/3.unc"
	RingLayoutBoundary
DEZ4_Rings_Unc:			binclude "Levels/DEZ/Ring Pos/4.unc"
	RingLayoutBoundary
	even
