; ===========================================================================
; Sonic Clean Engine (SCE)
; ===========================================================================

		; assembler code
		CPU 68000
		include "Engine/Settings.asm"								; include assembly options
		include "Engine/MacroSetup.asm"							; include a few basic macros
		include "Engine/Macros.asm"								; include some simplifying macros and functions
		include "Engine/Constants.asm"								; include constants
		include "Engine/Variables.asm"								; include RAM variables
		include "Sound/Definitions.asm"							; include sound driver macros and functions
		include "Engine/Debugger/ErrorHandler/Debugger.asm"		; include debugger macros and functions
; ---------------------------------------------------------------------------

StartOfROM:

	if * <> 0
		fatal "StartOfROM was $\{*} but it should be 0"
	endif

Vectors:
		dc.l System_stack			; initial stack pointer value
		dc.l EntryPoint			; start of program
		dc.l BusError				; bus error
		dc.l AddressError			; address error (4)
		dc.l IllegalInstr			; illegal instruction
		dc.l ZeroDivide			; division by zero
		dc.l ChkInstr				; chk exception
		dc.l TrapvInstr			; trapv exception (8)
		dc.l PrivilegeViol			; privilege violation
		dc.l Trace				; trace exception
		dc.l Line1010Emu			; line-a emulator
		dc.l Line1111Emu			; line-f emulator (12)
		dc.l ErrorExcept			; unused (reserved)
		dc.l ErrorExcept			; unused (reserved)
		dc.l ErrorExcept			; unused (reserved)
		dc.l ErrorExcept			; unused (reserved) (16)
		dc.l ErrorExcept			; unused (reserved)
		dc.l ErrorExcept			; unused (reserved)
		dc.l ErrorExcept			; unused (reserved)
		dc.l ErrorExcept			; unused (reserved) (20)
		dc.l ErrorExcept			; unused (reserved)
		dc.l ErrorExcept			; unused (reserved)
		dc.l ErrorExcept			; unused (reserved)
		dc.l ErrorExcept			; unused (reserved) (24)
		dc.l ErrorExcept			; spurious exception
		dc.l ErrorTrap			; irq level 1
		dc.l ErrorTrap			; irq level 2
		dc.l ErrorTrap			; irq level 3 (28)
		dc.l H_int_jump			; irq level 4 (horizontal retrace interrupt)
		dc.l ErrorTrap			; irq level 5
		dc.l V_int_jump			; irq level 6 (vertical retrace interrupt)
		dc.l ErrorTrap			; irq level 7 (32)
		dc.l ErrorTrap			; trap #00 exception
		dc.l ErrorTrap			; trap #01 exception
		dc.l ErrorTrap			; trap #02 exception
		dc.l ErrorTrap			; trap #03 exception (36)
		dc.l ErrorTrap			; trap #04 exception
		dc.l ErrorTrap			; trap #05 exception
		dc.l ErrorTrap			; trap #06 exception
		dc.l ErrorTrap			; trap #07 exception (40)
		dc.l ErrorTrap			; trap #08 exception
		dc.l ErrorTrap			; trap #09 exception
		dc.l ErrorTrap			; trap #10 exception
		dc.l ErrorTrap			; trap #11 exception (44)
		dc.l ErrorTrap			; trap #12 exception
		dc.l ErrorTrap			; trap #13 exception
		dc.l ErrorTrap			; trap #14 exception
		dc.l ErrorTrap			; trap #15 exception (48)
		dc.l ErrorTrap			; unused (reserved)
		dc.l ErrorTrap			; unused (reserved)
		dc.l ErrorTrap			; unused (reserved)
		dc.l ErrorTrap			; unused (reserved) (52)
		dc.l ErrorTrap			; unused (reserved)
		dc.l ErrorTrap			; unused (reserved)
		dc.l ErrorTrap			; unused (reserved)
		dc.l ErrorTrap			; unused (reserved) (56)
		dc.l ErrorTrap			; unused (reserved)
		dc.l ErrorTrap			; unused (reserved)
		dc.l ErrorTrap			; unused (reserved)
		dc.l ErrorTrap			; unused (reserved) (60)
		dc.l ErrorTrap			; unused (reserved)
		dc.l ErrorTrap			; unused (reserved)
		dc.l ErrorTrap			; unused (reserved)
		dc.l ErrorTrap			; unused (reserved) (64)

Header:				dc.b "SEGA GENESIS    "
Copyright:			dc.b "(C)SEGA XXXX.XXX"
Domestic_Name:		dc.b "SONIC THE               HEDGEHOG                "
Overseas_Name:		dc.b "SONIC THE               HEDGEHOG                "
Serial_Number:		dc.b "GM MK-0000 -00"
Checksum:			dc.w 0
Input:				dc.b "J               "
ROMStartLoc:		dc.l StartOfROM
ROMEndLoc:			dc.l EndOfROM-1
RAMStartLoc:		dc.l (RAM_start&$FFFFFF)
RAMEndLoc:			dc.l (RAM_start&$FFFFFF)+$FFFF
SRAMSupport:

	if EnableSRAM
CartRAM_Info:		dc.b "RA"
CartRAM_Type:		dc.b $A0+(BackupSRAM<<6)+(AddressSRAM<<3), $20
CartRAMStartLoc:	dc.l SRAM_Start				; SRAM start ($200000)
CartRAMEndLoc:		dc.l SRAM_Start+SRAM_End	; SRAM end ($20xxxx)
	else
CartRAM_Info:		dc.b "  "
CartRAM_Type:		dc.w %10000000100000
CartRAMStartLoc:	dc.b "    "						; SRAM start ($200000)
CartRAMEndLoc:		dc.b "    "						; SRAM end ($20xxxx)
	endif

Modem_Info:			dc.b "                                                    "
Country_Code:		dc.b "JUE             "
EndOfHeader

; ---------------------------------------------------------------------------
; VDP Subroutine
; ---------------------------------------------------------------------------

		include "Engine/Core/VDP.asm"

; ---------------------------------------------------------------------------
; Controllers Subroutine
; ---------------------------------------------------------------------------

		include "Engine/Core/Controllers.asm"

; ---------------------------------------------------------------------------
; DMA Queue Subroutine
; ---------------------------------------------------------------------------

		include "Engine/Core/DMA Queue.asm"

; ---------------------------------------------------------------------------
; Plane Map To VRAM Subroutine
; ---------------------------------------------------------------------------

		include "Engine/Core/Plane Map To VRAM.asm"

; ---------------------------------------------------------------------------
; Decompression Subroutine
; ---------------------------------------------------------------------------

		include "Engine/Decompression/Enigma Decompression.asm"
		include "Engine/Decompression/Kosinski Plus Decompression.asm"
		include "Engine/Decompression/Kosinski Plus Module Decompression.asm"

; ---------------------------------------------------------------------------
; Flamedriver - Functions Subroutine
; ---------------------------------------------------------------------------

		include "Sound/Functions.asm"

; ---------------------------------------------------------------------------
; Fading Palettes Subroutine
; ---------------------------------------------------------------------------

		include "Engine/Core/Fading Palette.asm"

; ---------------------------------------------------------------------------
; Load Palettes Subroutine
; ---------------------------------------------------------------------------

		include "Engine/Core/Load Palette.asm"

; ---------------------------------------------------------------------------
; Wait VSync Subroutine
; ---------------------------------------------------------------------------

		include "Engine/Core/Wait VSync.asm"

; ---------------------------------------------------------------------------
; Pause Subroutine
; ---------------------------------------------------------------------------

		include "Engine/Core/Pause Game.asm"

; ---------------------------------------------------------------------------
; Random Number Subroutine
; ---------------------------------------------------------------------------

		include "Engine/Core/Random Number.asm"

; ---------------------------------------------------------------------------
; Oscillatory Subroutine
; ---------------------------------------------------------------------------

		include "Engine/Core/Oscillatory Routines.asm"

; ---------------------------------------------------------------------------
; HUD Update Subroutine
; ---------------------------------------------------------------------------

		include "Engine/Core/HUD Update.asm"

; ---------------------------------------------------------------------------
; Load Text Subroutine
; ---------------------------------------------------------------------------

		include "Engine/Core/Load Text.asm"

; ---------------------------------------------------------------------------
; Objects Process Subroutines
; ---------------------------------------------------------------------------

		include "Engine/Objects/Process Sprites.asm"
		include "Engine/Objects/Render Sprites.asm"

; ---------------------------------------------------------------------------
; Load Objects Subroutine
; ---------------------------------------------------------------------------

		include "Engine/Core/Load Objects.asm"

; ---------------------------------------------------------------------------
; Load Rings Subroutine
; ---------------------------------------------------------------------------

		include "Engine/Core/Load Rings.asm"

; ---------------------------------------------------------------------------
; Draw Level Subroutine
; ---------------------------------------------------------------------------

		include "Engine/Core/Draw Level.asm"

; ---------------------------------------------------------------------------
; Deform Layer Subroutine
; ---------------------------------------------------------------------------

		include "Engine/Core/Move Camera.asm"

; ---------------------------------------------------------------------------
; Parallax Engine Subroutine
; ---------------------------------------------------------------------------

		include "Engine/Core/Deformation Script.asm"

; ---------------------------------------------------------------------------
; Shake Screen Subroutine
; ---------------------------------------------------------------------------

		include "Engine/Core/Shake Screen.asm"

; ---------------------------------------------------------------------------
; Objects Subroutines
; ---------------------------------------------------------------------------

		include "Engine/Objects/Animate Raw.asm"
		include "Engine/Objects/Animate Sprite.asm"
		include "Engine/Objects/Calc Angle.asm"
		include "Engine/Objects/Calc Sine.asm"
		include "Engine/Objects/Draw Sprite.asm"
		include "Engine/Objects/Delete Object.asm"
		include "Engine/Objects/Create Sprite.asm"
		include "Engine/Objects/Move Sprite.asm"
		include "Engine/Objects/Move Sprite Circular.asm"
		include "Engine/Objects/Object Swing.asm"
		include "Engine/Objects/Object Wait.asm"
		include "Engine/Objects/Change Flip.asm"
		include "Engine/Objects/Create Child Sprite.asm"
		include "Engine/Objects/Child Get Priority.asm"
		include "Engine/Objects/Check Range.asm"
		include "Engine/Objects/Find Sonic.asm"
		include "Engine/Objects/Misc.asm"
		include "Engine/Objects/Palette Script.asm"
		include "Engine/Objects/Remember State.asm"

; ---------------------------------------------------------------------------
; Objects Functions Subroutines
; ---------------------------------------------------------------------------

		include "Engine/Objects/Find Floor.asm"
		include "Engine/Objects/Solid Object.asm"

; ---------------------------------------------------------------------------
; Animate Palette Subroutine
; ---------------------------------------------------------------------------

		include "Engine/Core/Animate Palette.asm"

; ---------------------------------------------------------------------------
; Animate Level Graphics Subroutine
; ---------------------------------------------------------------------------

		include "Engine/Core/Animate Tiles.asm"

; ---------------------------------------------------------------------------
; Level Setup Subroutine
; ---------------------------------------------------------------------------

		include "Engine/Core/Level Setup.asm"

; ---------------------------------------------------------------------------
; Special Events Subroutine
; ---------------------------------------------------------------------------

		include "Engine/Core/Special Events.asm"

; ---------------------------------------------------------------------------
; Get Level Size Subroutine
; ---------------------------------------------------------------------------

		include "Engine/Core/Level Start.asm"

; ---------------------------------------------------------------------------
; Resize Events Subroutine
; ---------------------------------------------------------------------------

		include "Engine/Core/Level Events.asm"

; ---------------------------------------------------------------------------
; Handle On screen Water Height Subroutine
; ---------------------------------------------------------------------------

		include "Engine/Core/Water Effects.asm"

; ---------------------------------------------------------------------------
; Interrupt Handler Subroutine
; ---------------------------------------------------------------------------

		include "Engine/Core/Interrupt Handler.asm"

; ---------------------------------------------------------------------------
; Touch Response Subroutine
; ---------------------------------------------------------------------------

		include "Engine/Objects/Touch Response.asm"

; ---------------------------------------------------------------------------
; Subroutine to load Sonic object
; ---------------------------------------------------------------------------

		include "Objects/Players/Sonic/Sonic.asm"
		include "Objects/Players/Spin Dust/Spin Dust.asm"
		include "Objects/Players/Shields/Shields.asm"

; ---------------------------------------------------------------------------
; Subroutine to load a objects
; ---------------------------------------------------------------------------

		include "Data/Objects Data.asm"

; ---------------------------------------------------------------------------
; Level Select screen subroutines
; ---------------------------------------------------------------------------

		include "Screens/Level Select/Level Select.asm"

; ---------------------------------------------------------------------------
; Level screen Subroutine
; ---------------------------------------------------------------------------

		include "Screens/Level/Level.asm"

	if GameDebug

; ---------------------------------------------------------------------------
; Debug Mode Subroutine
; ---------------------------------------------------------------------------

		if GameDebugAlt
			include "Objects/Players/Sonic/Debug Mode(Crackers).asm"
		else
			include "Objects/Players/Sonic/Debug Mode.asm"
			include "Data/Debug Pointers.asm"
		endif

	endif

; ---------------------------------------------------------------------------
; Security Subroutine
; ---------------------------------------------------------------------------

		include "Engine/Core/Security Startup 1.asm"
		include "Engine/Core/Security Startup 2.asm"

	if ChecksumCheck

; ---------------------------------------------------------------------------
; Checksum Subroutine
; ---------------------------------------------------------------------------

		include "Engine/Core/Checksum.asm"

	endif

; ---------------------------------------------------------------------------
; Subroutine to load player object data
; ---------------------------------------------------------------------------

		; Sonic
		include "Objects/Players/Sonic/Object Data/Anim - Sonic.asm"
		include "Objects/Players/Sonic/Object Data/Map - Sonic.asm"
		include "Objects/Players/Sonic/Object Data/DPLC - Sonic.asm"

; ---------------------------------------------------------------------------
; Subroutine to load level events
; ---------------------------------------------------------------------------

		include "Data/Levels Events.asm"

; ---------------------------------------------------------------------------
; Levels data pointers
; ---------------------------------------------------------------------------

		include "Data/Levels Data.asm"

; ---------------------------------------------------------------------------
; Palette data
; ---------------------------------------------------------------------------

		include "Data/Palette Pointers.asm"
		include "Data/Palette Data.asm"

; ---------------------------------------------------------------------------
; Object Pointers
; ---------------------------------------------------------------------------

		include "Data/Object Pointers.asm"

; ---------------------------------------------------------------------------
; Pattern Load Cues pointers
; ---------------------------------------------------------------------------

		include "Data/Pattern Load Cues.asm"

; ---------------------------------------------------------------------------
; Kosinski Plus Module compressed graphics pointers
; ---------------------------------------------------------------------------

		include "Data/Kosinski Plus Module Data.asm"

; ---------------------------------------------------------------------------
; Kosinski Plus compressed graphics pointers
; ---------------------------------------------------------------------------

		include "Data/Kosinski Plus Data.asm"

; ---------------------------------------------------------------------------
; Enigma compressed graphics pointers
; ---------------------------------------------------------------------------

		include "Data/Enigma Data.asm"

; ---------------------------------------------------------------------------
; Uncompressed player graphics pointers
; ---------------------------------------------------------------------------

		include "Data/Uncompressed Player Data.asm"

; ---------------------------------------------------------------------------
; Uncompressed graphics pointers
; ---------------------------------------------------------------------------

		include "Data/Uncompressed Data.asm"

; ---------------------------------------------------------------------------
; Flamewing sound driver subroutines
; ---------------------------------------------------------------------------

		include "Sound/Flamedriver.asm"
		even

; ---------------------------------------------------------------
; Error handling module
; ---------------------------------------------------------------

		include "Engine/Debugger/ErrorHandler/ErrorHandler.asm"

; end of 'ROM'
EndOfROM:

		END
