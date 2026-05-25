; ===========================================================================
; Sonic Clean Engine (SCE)
; ===========================================================================

; ---------------------------------------------------------------------------
; Engine definitions (WARNING! DO NOT move this)
; ---------------------------------------------------------------------------

		include "Engine/Definitions.asm"

; ---------------------------------------------------------------------------
; ROM Header (WARNING! DO NOT move this)
; ---------------------------------------------------------------------------

		include "Engine/Header.asm"

; ---------------------------------------------------------------------------
; VDP modules
; ---------------------------------------------------------------------------

		include "Engine/Core/VDP.asm"

; ---------------------------------------------------------------------------
; DMA Queue modules
; ---------------------------------------------------------------------------

		include "Engine/Core/DMA Queue.asm"

; ---------------------------------------------------------------------------
; Plane mappings to VRAM modules
; ---------------------------------------------------------------------------

		include "Engine/Core/Plane Map To VRAM.asm"

; ---------------------------------------------------------------------------
; Decompression modules
; ---------------------------------------------------------------------------

		include "Engine/Decompression/Enigma Decompression.asm"
		include "Engine/Decompression/Kosinski Plus Decompression.asm"
		include "Engine/Decompression/Kosinski Plus Moduled Decompression.asm"

; ---------------------------------------------------------------------------
; Flamedriver - Functions modules
; ---------------------------------------------------------------------------

		include "Sound/Functions.asm"

; ---------------------------------------------------------------------------
; Fading palettes modules
; ---------------------------------------------------------------------------

		include "Engine/Core/Fading Palette.asm"

; ---------------------------------------------------------------------------
; Load palettes modules
; ---------------------------------------------------------------------------

		include "Engine/Core/Load Palette.asm"

; ---------------------------------------------------------------------------
; Wait VSync module
; ---------------------------------------------------------------------------

		include "Engine/Core/Wait VSync.asm"

; ---------------------------------------------------------------------------
; Pause module
; ---------------------------------------------------------------------------

		include "Engine/Core/Pause Game.asm"

; ---------------------------------------------------------------------------
; Random number module
; ---------------------------------------------------------------------------

		include "Engine/Core/Random Number.asm"

; ---------------------------------------------------------------------------
; Oscillatory modules
; ---------------------------------------------------------------------------

		include "Engine/Core/Oscillatory Routines.asm"

; ---------------------------------------------------------------------------
; HUD update modules
; ---------------------------------------------------------------------------

		include "Engine/Core/HUD Update.asm"

; ---------------------------------------------------------------------------
; Draw text on the plane module
; ---------------------------------------------------------------------------

		include "Engine/Core/Draw Text.asm"

; ---------------------------------------------------------------------------
; Objects process modules
; ---------------------------------------------------------------------------

		include "Engine/Objects/Process Objects.asm"
		include "Engine/Objects/Render Sprites.asm"

; ---------------------------------------------------------------------------
; Load level objects modules
; ---------------------------------------------------------------------------

		include "Engine/Core/Load Objects.asm"

; ---------------------------------------------------------------------------
; Load level rings modules
; ---------------------------------------------------------------------------

		include "Engine/Core/Load Rings.asm"

; ---------------------------------------------------------------------------
; Draw level tiles modules
; ---------------------------------------------------------------------------

		include "Engine/Core/Draw Level.asm"

; ---------------------------------------------------------------------------
; Load level modules
; ---------------------------------------------------------------------------

		include "Engine/Core/Load Level.asm"

; ---------------------------------------------------------------------------
; Deformation layer modules
; ---------------------------------------------------------------------------

		include "Engine/Core/Move Camera.asm"

; ---------------------------------------------------------------------------
; Parallax engine modules
; ---------------------------------------------------------------------------

		include "Engine/Core/Deformation Script.asm"

; ---------------------------------------------------------------------------
; Shake screen modules
; ---------------------------------------------------------------------------

		include "Engine/Core/Shake Screen.asm"

; ---------------------------------------------------------------------------
; Objects modules
; ---------------------------------------------------------------------------

		include "Engine/Objects/Animate Raw.asm"
		include "Engine/Objects/Animate Sprite.asm"
		include "Engine/Objects/Calc Angle.asm"
		include "Engine/Objects/Calc Root.asm"
		include "Engine/Objects/Calc Sine.asm"
		include "Engine/Objects/Draw Sprite.asm"
		include "Engine/Objects/Delete Object.asm"
		include "Engine/Objects/Create Object.asm"
		include "Engine/Objects/Move Sprite.asm"
		include "Engine/Objects/Move Sprite Circular.asm"
		include "Engine/Objects/Swing Object.asm"
		include "Engine/Objects/Check Wait.asm"
		include "Engine/Objects/Change Flip.asm"
		include "Engine/Objects/Create Child Object.asm"
		include "Engine/Objects/Child Get Priority.asm"
		include "Engine/Objects/Check Range.asm"
		include "Engine/Objects/Find Player.asm"
		include "Engine/Objects/Misc.asm"
		include "Engine/Objects/Palette Script.asm"
		include "Engine/Objects/Remember State.asm"

; ---------------------------------------------------------------------------
; Objects functions modules
; ---------------------------------------------------------------------------

		include "Engine/Objects/Find Floor.asm"
		include "Engine/Objects/Solid Object.asm"

; ---------------------------------------------------------------------------
; Animate palette modules
; ---------------------------------------------------------------------------

		include "Engine/Core/Animate Palette.asm"

; ---------------------------------------------------------------------------
; Animate level graphics modules
; ---------------------------------------------------------------------------

		include "Engine/Core/Animate Tiles.asm"

; ---------------------------------------------------------------------------
; Level setup modules
; ---------------------------------------------------------------------------

		include "Engine/Core/Level Setup.asm"

; ---------------------------------------------------------------------------
; Special events modules
; ---------------------------------------------------------------------------

		include "Engine/Core/Special Events.asm"

; ---------------------------------------------------------------------------
; Get level size modules
; ---------------------------------------------------------------------------

		include "Engine/Core/Level Start.asm"

; ---------------------------------------------------------------------------
; Resize events modules
; ---------------------------------------------------------------------------

		include "Engine/Core/Level Events.asm"

; ---------------------------------------------------------------------------
; Handle on screen water height modules
; ---------------------------------------------------------------------------

		include "Engine/Core/Water Effects.asm"

; ---------------------------------------------------------------------------
; Touch response modules
; ---------------------------------------------------------------------------

		include "Engine/Objects/Touch Response.asm"

; ---------------------------------------------------------------------------
; Player object (Sonic) modules
; ---------------------------------------------------------------------------

		include "Objects/Players/Sonic/Sonic.asm"
		include "Objects/Players/Spin Dust/Spin Dust.asm"
		include "Objects/Players/Shields/Shields.asm"

; ---------------------------------------------------------------------------
; Objects data pointers
; ---------------------------------------------------------------------------

		include "Data/Objects Data.asm"

; ---------------------------------------------------------------------------
; Level Select screen modules
; ---------------------------------------------------------------------------

		include "Screens/Level Select/Level Select.asm"

; ---------------------------------------------------------------------------
; Level screen modules
; ---------------------------------------------------------------------------

		include "Screens/Level/Level.asm"

	if GameDebug

; ---------------------------------------------------------------------------
; Debug Mode modules
; ---------------------------------------------------------------------------

		if GameDebugAlt
			include "Objects/Players/Debug Mode/Debug Mode(Crackers).asm"
		else
			include "Objects/Players/Debug Mode/Debug Mode.asm"
			include "Data/Debug Pointers.asm"
		endif

	endif

; ---------------------------------------------------------------------------
; Security modules
; ---------------------------------------------------------------------------

		include "Engine/Core/Security Startup 1.asm"
		include "Engine/Core/Security Startup 2.asm"

; ---------------------------------------------------------------------------
; Controllers modules
; ---------------------------------------------------------------------------

		include "Engine/Core/Controllers.asm"

; ---------------------------------------------------------------------------
; Interrupt Handler modules
; ---------------------------------------------------------------------------

		include "Engine/Core/Interrupt Handler.asm"

	if ChecksumCheck

; ---------------------------------------------------------------------------
; Checksum modules
; ---------------------------------------------------------------------------

		include "Engine/Core/Checksum.asm"

	endif

; ---------------------------------------------------------------------------
; Player mappings data
; ---------------------------------------------------------------------------

		; Sonic
		include "Objects/Players/Sonic/Object Data/Anim - Sonic.asm"
		include "Objects/Players/Sonic/Object Data/Map - Sonic.asm"
		include "Objects/Players/Sonic/Object Data/DPLC - Sonic.asm"

; ---------------------------------------------------------------------------
; Levels events modules
; ---------------------------------------------------------------------------

		include "Data/Levels Events.asm"

; ---------------------------------------------------------------------------
; Levels data pointers
; ---------------------------------------------------------------------------

		include "Data/Levels Data.asm"

; ---------------------------------------------------------------------------
; Palette data pointers
; ---------------------------------------------------------------------------

		include "Data/Palette Data.asm"
		include "Data/Palette Pointers.asm"

; ---------------------------------------------------------------------------
; Object pointers
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
; Flamewing sound driver modules
; ---------------------------------------------------------------------------

		include "Sound/Flamedriver.asm"
		even

; --------------------------------------------------------------
; Debugging modules (WARNING! DO NOT move this)
; --------------------------------------------------------------

		include "Engine/Debugger/ErrorHandler/ErrorHandler.asm"

; ---------------------------------------------------------------
; WARNING!
;	DO NOT put any data from now on! DO NOT use ROM padding!
;	Symbol data should be appended here after ROM is compiled
;	by ConvSym utility, otherwise debugger modules won't be able
;	to resolve symbol names.
; ---------------------------------------------------------------

; end of 'ROM'
EndOfROM:

    if DEBUG_PassCheck
		message "[Macro AS] Pass \{MOMPASS}"
	if DEBUG_PassError
	    if MOMPASS>DEBUG_PassMax
		warning "[Macro AS] Pass ERROR: There should be no more than \{DEBUG_PassMax} passes here, but there are \{MOMPASS}!"
	    endif
	endif
    endif

		END
