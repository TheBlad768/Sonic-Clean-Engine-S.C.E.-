; ===========================================================================
; Sonic: TEST GAME
; ===========================================================================

; Assembly options
ZoneCount:				= 1	; discrete zones are: DEZ
GameDebug:				= 1	; if 1, enable debug mode for Sonic
GameDebugAlt:			= 0	; if 1, enable alt debug mode for Sonic
Lagometer:				= 1	; if 1, enable debug lagometer
ExtendedCamera:			= 0	; if 1, enable extended camera
RollInAir:				= 1	; if 1, enable roll in air for Sonic
OptimiseSound:	  		= 1	; change to 1 to optimise sound queuing
OptimiseStopZ80:	  		= 2	; if 1, remove stopZ80 and startZ80, if 2, use only for controllers(ignores sound driver)
ZeroOffsetOptimization:	= 1	; if 1, makes a handful of zero-offset instructions smaller
AllOptimizations:			= 1	; if 1, enables all optimizations
EnableSRAM:				= 0	; change to 1 to enable SRAM
BackupSRAM:			= 0
AddressSRAM:			= 0	; 0 = odd+even; 2 = even only; 3 = odd only
; ---------------------------------------------------------------------------

; Assembler code
		cpu 68000
		include "MacroSetup.asm"			; include a few basic macros
		include "Macros.asm"				; include some simplifying macros and functions
		include "Constants.asm"			; include constants
		include "Variables.asm"			; include RAM variables
		include "Sound/Definitions.asm"	; include sound driver macros and functions
		include "Misc Data/Debugger/ErrorHandler/Debugger.asm"	; include debugger macros and functions
; ---------------------------------------------------------------------------

StartOfROM:
	if * <> 0
		fatal "StartOfROM was $\{*} but it should be 0"
	endif
Vectors:
		dc.l System_stack, EntryPoint, BusError, AddressError		; 0
		dc.l IllegalInstr, ZeroDivide, ChkInstr, TrapvInstr			; 4
		dc.l PrivilegeViol, Trace, Line1010Emu, Line1111Emu		; 8
		dc.l ErrorExcept, ErrorExcept, ErrorExcept, ErrorExcept	; 12
		dc.l ErrorExcept, ErrorExcept, ErrorExcept, ErrorExcept	; 16
		dc.l ErrorExcept, ErrorExcept, ErrorExcept, ErrorExcept	; 20
		dc.l ErrorExcept, ErrorTrap, ErrorTrap, ErrorTrap			; 24
		dc.l H_int_jump, ErrorTrap, V_int_jump, ErrorTrap		; 28
		dc.l ErrorTrap, ErrorTrap, ErrorTrap, ErrorTrap			; 32
		dc.l ErrorTrap, ErrorTrap, ErrorTrap, ErrorTrap			; 36
		dc.l ErrorTrap, ErrorTrap, ErrorTrap, ErrorTrap			; 40
		dc.l ErrorTrap, ErrorTrap, ErrorTrap, ErrorTrap			; 44
		dc.l ErrorTrap, ErrorTrap, ErrorTrap, ErrorTrap			; 48
		dc.l ErrorTrap, ErrorTrap, ErrorTrap, ErrorTrap			; 52
		dc.l ErrorTrap, ErrorTrap, ErrorTrap, ErrorTrap			; 56
		dc.l ErrorTrap, ErrorTrap, ErrorTrap, ErrorTrap			; 60
Header:			dc.b "SEGA GENESIS    "
Copyright:		dc.b "(C)SEGA XXXX.XXX"
Domestic_Name:	dc.b "SONIC THE               HEDGEHOG                "
Overseas_Name:	dc.b "SONIC THE               HEDGEHOG                "
Serial_Number:	dc.b "GM MK-0000 -00"
Checksum:		dc.w 0
Input:			dc.b "J               "
RomStartLoc:		dc.l StartOfROM
RomEndLoc:		dc.l EndOfROM-1
RamStartLoc:		dc.l (RAM_start&$FFFFFF)
RamEndLoc:		dc.l (RAM_start&$FFFFFF)+$FFFF
SRAMSupport:
	if EnableSRAM=1
CartRAM_Info:	dc.b "RA"
CartRAM_Type:	dc.b $A0+(BackupSRAM<<6)+(AddressSRAM<<3), $20
CartRAMStartLoc:dc.l SRAM_Size|SRAM_Type.SRAM_Start	; SRAM start ($200000)
CartRAMEndLoc:	dc.l SRAM_Size|SRAM_Type.SRAM_End		; SRAM end ($20xxxx)
	else
CartRAM_Info:	dc.b "  "
CartRAM_Type:	dc.w %10000000100000
CartRAMStartLoc:dc.l $20202020	; SRAM start ($200000)
CartRAMEndLoc:	dc.l $20202020	; SRAM end ($20xxxx)
	endif
Modem_Info:		dc.b "                                                    "
Country_Code:	dc.b "JUE             "
EndOfHeader:

; ---------------------------------------------------------------------------
; Security Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/Security Startup.asm"

; ---------------------------------------------------------------------------
; VDP Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/VDP.asm"

; ---------------------------------------------------------------------------
; Controllers Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/Controllers.asm"

; ---------------------------------------------------------------------------
; DMA Queue Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/DMA Queue.asm"

; ---------------------------------------------------------------------------
; Plane Map To VRAM Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/Plane Map To VRAM.asm"

; ---------------------------------------------------------------------------
; Decompression Subroutine
; ---------------------------------------------------------------------------

		include "Data/Decompression/Enigma Decompression.asm"
		include "Data/Decompression/Kosinski Decompression.asm"
		include "Data/Decompression/Kosinski Module Decompression.asm"

; ---------------------------------------------------------------------------
; Clone Driver - Functions Subroutine
; ---------------------------------------------------------------------------

		include "Sound/Engine/Functions.asm"

; ---------------------------------------------------------------------------
; Fading Palettes Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/Fading Palette.asm"

; ---------------------------------------------------------------------------
; Load Palettes Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/Load Palette.asm"

; ---------------------------------------------------------------------------
; Wait VSync Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/Wait VSync.asm"

; ---------------------------------------------------------------------------
; Pause Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/Pause Game.asm"

; ---------------------------------------------------------------------------
; Random Number Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/Random Number.asm"

; ---------------------------------------------------------------------------
; Oscillatory Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/Oscillatory Routines.asm"

; ---------------------------------------------------------------------------
; HUD Update Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/HUD Update.asm"

; ---------------------------------------------------------------------------
; Load Text Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/Load Text.asm"

; ---------------------------------------------------------------------------
; Objects Process Subroutines
; ---------------------------------------------------------------------------

		include "Data/Objects/Process Sprites.asm"
		include "Data/Objects/Render Sprites.asm"

; ---------------------------------------------------------------------------
; Load Objects Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/Load Objects.asm"

; ---------------------------------------------------------------------------
; Load HUD Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/Load HUD.asm"

; ---------------------------------------------------------------------------
; Load Rings Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/Load Rings.asm"

; ---------------------------------------------------------------------------
; Draw Level Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/DrawLevel.asm"

; ---------------------------------------------------------------------------
; Deform Layer Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/DeformBgLayer.asm"

; ---------------------------------------------------------------------------
; Parallax Engine Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/Deformation Script.asm"

; ---------------------------------------------------------------------------
; Shake Screen Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/Shake Screen.asm"

; ---------------------------------------------------------------------------
; Objects Subroutines
; ---------------------------------------------------------------------------

		include "Data/Objects/AnimateRaw.asm"
		include "Data/Objects/AnimateSprite.asm"
		include "Data/Objects/CalcAngle.asm"
		include "Data/Objects/CalcSine.asm"
		include "Data/Objects/DisplaySprite.asm"
		include "Data/Objects/FindFreeObj.asm"
		include "Data/Objects/DeleteObject.asm"
		include "Data/Objects/MoveSprite.asm"
		include "Data/Objects/MoveSprite Circular.asm"
		include "Data/Objects/Object Swing.asm"
		include "Data/Objects/Object Wait.asm"
		include "Data/Objects/ChangeFlip.asm"
		include "Data/Objects/CreateChildSprite.asm"
		include "Data/Objects/ChildGetPriority.asm"
		include "Data/Objects/CheckRange.asm"
		include "Data/Objects/FindSonic.asm"
		include "Data/Objects/Misc.asm"
		include "Data/Objects/Palette Script.asm"
		include "Data/Objects/RememberState.asm"

; ---------------------------------------------------------------------------
; Objects Functions Subroutines
; ---------------------------------------------------------------------------

		include "Data/Objects/FindFloor.asm"
		include "Data/Objects/SolidObject.asm"
		include "Data/Objects/TouchResponse.asm"

; ---------------------------------------------------------------------------
; Resize Events Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/DoResizeEvents.asm"

; ---------------------------------------------------------------------------
; Handle On screen Water Height Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/HandleOnscreenWaterHeight.asm"

; ---------------------------------------------------------------------------
; Animate Palette Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/Animate Palette.asm"

; ---------------------------------------------------------------------------
; Animate Level Graphics Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/Animate Tiles.asm"

; ---------------------------------------------------------------------------
; Get Level Size Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/GetLevelSizeStart.asm"

; ---------------------------------------------------------------------------
; Level Setup Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/LevelSetup.asm"

; ---------------------------------------------------------------------------
; Interrupt Handler Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/Interrupt Handler.asm"

; ---------------------------------------------------------------------------
; Subroutine to load Sonic object
; ---------------------------------------------------------------------------

		include "Objects/Sonic/Sonic.asm"
		include "Objects/Spin Dust/SpinDust.asm"
		include "Objects/Shields/Shields.asm"

; ---------------------------------------------------------------------------
; Subroutine to load a objects
; ---------------------------------------------------------------------------

		include "Pointers/Objects Data.asm"

; ---------------------------------------------------------------------------
; AfterBoss Cleanup Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/AfterBoss Cleanup.asm"

; ---------------------------------------------------------------------------
; Load PLC Animals Subroutine
; ---------------------------------------------------------------------------

		include "Data/Misc/Load Animals.asm"

; ---------------------------------------------------------------------------
; Level Select screen subroutines
; ---------------------------------------------------------------------------

		include "Data/Screens/Level Select/Level Select.asm"

; ---------------------------------------------------------------------------
; Level screen Subroutine
; ---------------------------------------------------------------------------

		include "Data/Screens/Level/Level.asm"

; ---------------------------------------------------------------------------
; Pattern Load Cues pointers
; ---------------------------------------------------------------------------

		include "Pointers/Pattern Load Cues.asm"

	if GameDebug
; ---------------------------------------------------------------------------
; Debug Mode Subroutine
; ---------------------------------------------------------------------------

		if GameDebugAlt
			include "Objects/Sonic/DebugMode(Crackers).asm"
		else
			include "Objects/Sonic/DebugMode.asm"
		endif

	endif

; ---------------------------------------------------------------------------
; Object Pointers
; ---------------------------------------------------------------------------

		include "Pointers/Object Pointers.asm"

; ---------------------------------------------------------------------------
; Subroutine to load Sonic object data
; ---------------------------------------------------------------------------

		include "Objects/Sonic/Object Data/Anim - Sonic.asm"
		include "Objects/Sonic/Object Data/Map - Sonic.asm"
		include "Objects/Sonic/Object Data/Sonic pattern load cues.asm"

; ---------------------------------------------------------------------------
; Subroutine to load level events
; ---------------------------------------------------------------------------

		include "Pointers/Levels Events.asm"

; ---------------------------------------------------------------------------
; Levels data pointers
; ---------------------------------------------------------------------------

		include "Pointers/Levels Data.asm"

; ---------------------------------------------------------------------------
; Palette data
; ---------------------------------------------------------------------------

		include "Pointers/Palette Pointers.asm"
		include "Pointers/Palette Data.asm"

; ---------------------------------------------------------------------------
; Kosinski Module compressed graphics pointers
; ---------------------------------------------------------------------------

		include "Pointers/Kosinski Module Data.asm"

; ---------------------------------------------------------------------------
; Kosinski compressed graphics pointers
; ---------------------------------------------------------------------------

		include "Pointers/Kosinski Data.asm"

; ---------------------------------------------------------------------------
; Enigma compressed graphics pointers
; ---------------------------------------------------------------------------

		include "Pointers/Enigma Data.asm"

; ---------------------------------------------------------------------------
; Uncompressed player graphics pointers
; ---------------------------------------------------------------------------

		include "Pointers/Uncompressed Player Data.asm"

; ---------------------------------------------------------------------------
; Uncompressed graphics pointers
; ---------------------------------------------------------------------------

		include "Pointers/Uncompressed Data.asm"

; ---------------------------------------------------------------------------
; Music playlist Subroutine
; ---------------------------------------------------------------------------

		include "Misc Data/Music playlist.asm"

; ---------------------------------------------------------------------------
; Clone sound driver subroutines
; ---------------------------------------------------------------------------

		include "Sound/Engine/Sonic 2 Clone Driver v2.asm"

; ---------------------------------------------------------------------------
; MegaCD Driver
; ---------------------------------------------------------------------------

		include "Sound/MSU/MSU.asm"

; ---------------------------------------------------------------
; Error handling module
; ---------------------------------------------------------------

		include "Misc Data/Debugger/ErrorHandler/ErrorHandler.asm"

; end of 'ROM'
EndOfROM:

		END
