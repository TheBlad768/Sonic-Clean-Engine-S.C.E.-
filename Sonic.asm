; ===========================================================================
; Sonic Clean Engine (SCE)
; ===========================================================================

		; assembler code
		CPU 68000
		include "Settings.asm"										; include assembly options
		include "MacroSetup.asm"									; include a few basic macros
		include "Macros.asm"										; include some simplifying macros and functions
		include "Constants.asm"									; include constants
		include "Variables.asm"									; include RAM variables
		include "Sound/Definitions.asm"							; include sound driver macros and functions
		include "Misc/Debugger/ErrorHandler/Debugger.asm"			; include debugger macros and functions
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

		include "General/Main/VDP.asm"

; ---------------------------------------------------------------------------
; Controllers Subroutine
; ---------------------------------------------------------------------------

		include "General/Main/Controllers.asm"

; ---------------------------------------------------------------------------
; DMA Queue Subroutine
; ---------------------------------------------------------------------------

		include "General/Main/DMA Queue.asm"

; ---------------------------------------------------------------------------
; Plane Map To VRAM Subroutine
; ---------------------------------------------------------------------------

		include "General/Main/Plane Map To VRAM.asm"

; ---------------------------------------------------------------------------
; Decompression Subroutine
; ---------------------------------------------------------------------------

		include "General/Decompression/Enigma Decompression.asm"
		include "General/Decompression/Kosinski Plus Decompression.asm"
		include "General/Decompression/Kosinski Plus Module Decompression.asm"

; ---------------------------------------------------------------------------
; Flamedriver - Functions Subroutine
; ---------------------------------------------------------------------------

		include "Sound/Functions.asm"

; ---------------------------------------------------------------------------
; Fading Palettes Subroutine
; ---------------------------------------------------------------------------

		include "General/Main/Fading Palette.asm"

; ---------------------------------------------------------------------------
; Load Palettes Subroutine
; ---------------------------------------------------------------------------

		include "General/Main/Load Palette.asm"

; ---------------------------------------------------------------------------
; Wait VSync Subroutine
; ---------------------------------------------------------------------------

		include "General/Main/Wait VSync.asm"

; ---------------------------------------------------------------------------
; Pause Subroutine
; ---------------------------------------------------------------------------

		include "General/Main/Pause Game.asm"

; ---------------------------------------------------------------------------
; Random Number Subroutine
; ---------------------------------------------------------------------------

		include "General/Main/Random Number.asm"

; ---------------------------------------------------------------------------
; Oscillatory Subroutine
; ---------------------------------------------------------------------------

		include "General/Main/Oscillatory Routines.asm"

; ---------------------------------------------------------------------------
; HUD Update Subroutine
; ---------------------------------------------------------------------------

		include "General/Main/HUD Update.asm"

; ---------------------------------------------------------------------------
; Load Text Subroutine
; ---------------------------------------------------------------------------

		include "General/Main/Load Text.asm"

; ---------------------------------------------------------------------------
; Objects Process Subroutines
; ---------------------------------------------------------------------------

		include "General/Objects/Process Sprites.asm"
		include "General/Objects/Render Sprites.asm"

; ---------------------------------------------------------------------------
; Load Objects Subroutine
; ---------------------------------------------------------------------------

		include "General/Main/Load Objects.asm"

; ---------------------------------------------------------------------------
; Load HUD Subroutine
; ---------------------------------------------------------------------------

		include "Objects/HUD/Load HUD.asm"

; ---------------------------------------------------------------------------
; Load Rings Subroutine
; ---------------------------------------------------------------------------

		include "General/Main/Load Rings.asm"

; ---------------------------------------------------------------------------
; Draw Level Subroutine
; ---------------------------------------------------------------------------

		include "General/Main/Draw Level.asm"

; ---------------------------------------------------------------------------
; Deform Layer Subroutine
; ---------------------------------------------------------------------------

		include "General/Main/Move Camera.asm"

; ---------------------------------------------------------------------------
; Parallax Engine Subroutine
; ---------------------------------------------------------------------------

		include "General/Main/Deformation Script.asm"

; ---------------------------------------------------------------------------
; Shake Screen Subroutine
; ---------------------------------------------------------------------------

		include "General/Main/Shake Screen.asm"

; ---------------------------------------------------------------------------
; Objects Subroutines
; ---------------------------------------------------------------------------

		include "General/Objects/Animate Raw.asm"
		include "General/Objects/Animate Sprite.asm"
		include "General/Objects/Calc Angle.asm"
		include "General/Objects/Calc Sine.asm"
		include "General/Objects/Draw Sprite.asm"
		include "General/Objects/Delete Object.asm"
		include "General/Objects/Create Sprite.asm"
		include "General/Objects/Move Sprite.asm"
		include "General/Objects/Move Sprite Circular.asm"
		include "General/Objects/Object Swing.asm"
		include "General/Objects/Object Wait.asm"
		include "General/Objects/Change Flip.asm"
		include "General/Objects/Create Child Sprite.asm"
		include "General/Objects/Child Get Priority.asm"
		include "General/Objects/Check Range.asm"
		include "General/Objects/Find Sonic.asm"
		include "General/Objects/Misc.asm"
		include "General/Objects/Palette Script.asm"
		include "General/Objects/Remember State.asm"

; ---------------------------------------------------------------------------
; Objects Functions Subroutines
; ---------------------------------------------------------------------------

		include "General/Objects/Find Floor.asm"
		include "General/Objects/Solid Object.asm"

; ---------------------------------------------------------------------------
; Animate Palette Subroutine
; ---------------------------------------------------------------------------

		include "General/Main/Animate Palette.asm"

; ---------------------------------------------------------------------------
; Animate Level Graphics Subroutine
; ---------------------------------------------------------------------------

		include "General/Main/Animate Tiles.asm"

; ---------------------------------------------------------------------------
; Level Setup Subroutine
; ---------------------------------------------------------------------------

		include "General/Main/Level Setup.asm"

; ---------------------------------------------------------------------------
; Special Events Subroutine
; ---------------------------------------------------------------------------

		include "General/Main/Special Events.asm"

; ---------------------------------------------------------------------------
; Get Level Size Subroutine
; ---------------------------------------------------------------------------

		include "General/Main/Level Start.asm"

; ---------------------------------------------------------------------------
; Resize Events Subroutine
; ---------------------------------------------------------------------------

		include "General/Main/Level Events.asm"

; ---------------------------------------------------------------------------
; Handle On screen Water Height Subroutine
; ---------------------------------------------------------------------------

		include "General/Main/Water Effects.asm"

; ---------------------------------------------------------------------------
; Interrupt Handler Subroutine
; ---------------------------------------------------------------------------

		include "General/Main/Interrupt Handler.asm"

; ---------------------------------------------------------------------------
; Touch Response Subroutine
; ---------------------------------------------------------------------------

		include "General/Objects/Touch Response.asm"

; ---------------------------------------------------------------------------
; Subroutine to load Sonic object
; ---------------------------------------------------------------------------

		include "Objects/Sonic/Sonic.asm"
		include "Objects/Spin Dust/Spin Dust.asm"
		include "Objects/Shields/Shields.asm"

; ---------------------------------------------------------------------------
; Subroutine to load a objects
; ---------------------------------------------------------------------------

		include "Pointers/Objects Data.asm"

; ---------------------------------------------------------------------------
; Level Select screen subroutines
; ---------------------------------------------------------------------------

		include "General/Screens/Level Select/Level Select.asm"

; ---------------------------------------------------------------------------
; Level screen Subroutine
; ---------------------------------------------------------------------------

		include "General/Screens/Level/Level.asm"

	if GameDebug

; ---------------------------------------------------------------------------
; Debug Mode Subroutine
; ---------------------------------------------------------------------------

		if GameDebugAlt
			include "Objects/Sonic/Debug Mode(Crackers).asm"
		else
			include "Objects/Sonic/Debug Mode.asm"
			include "Pointers/Debug Pointers.asm"
		endif

	endif

; ---------------------------------------------------------------------------
; Security Subroutine
; ---------------------------------------------------------------------------

		include "General/Main/Security Startup 1.asm"
		include "General/Main/Security Startup 2.asm"

	if ChecksumCheck

; ---------------------------------------------------------------------------
; Checksum Subroutine
; ---------------------------------------------------------------------------

		include "General/Main/Checksum.asm"

	endif

; ---------------------------------------------------------------------------
; Subroutine to load player object data
; ---------------------------------------------------------------------------

		; Sonic
		include "Objects/Sonic/Object Data/Anim - Sonic.asm"
		include "Objects/Sonic/Object Data/Map - Sonic.asm"
		include "Objects/Sonic/Object Data/DPLC - Sonic.asm"

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
; Object Pointers
; ---------------------------------------------------------------------------

		include "Pointers/Object Pointers.asm"

; ---------------------------------------------------------------------------
; Pattern Load Cues pointers
; ---------------------------------------------------------------------------

		include "Pointers/Pattern Load Cues.asm"

; ---------------------------------------------------------------------------
; Kosinski Plus Module compressed graphics pointers
; ---------------------------------------------------------------------------

		include "Pointers/Kosinski Plus Module Data.asm"

; ---------------------------------------------------------------------------
; Kosinski Plus compressed graphics pointers
; ---------------------------------------------------------------------------

		include "Pointers/Kosinski Plus Data.asm"

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
; Flamewing sound driver subroutines
; ---------------------------------------------------------------------------

		include "Sound/Flamedriver.asm"
		even

; ---------------------------------------------------------------
; Error handling module
; ---------------------------------------------------------------

		include "Misc/Debugger/ErrorHandler/ErrorHandler.asm"

; end of 'ROM'
EndOfROM:

		END
