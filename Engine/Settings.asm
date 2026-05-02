; ===========================================================================
; Settings
; ===========================================================================

; system options
ChecksumCheck =						0				; if 1, enable checksum checking
OptimiseStopZ80 =					2				; if 1, remove stopZ80 and startZ80, if 2, use only for controllers (no effect on sound driver)
MSUMode =						0				; if 1, enable MSU

; player options
GameDebug =						1				; if 1, enable debug mode for player
GameDebugAlt =						0				; if 1, enable alt debug mode for player
RollInAir =						1				; if 1, enable roll in air for players
PlayerMoveLock =					0				; if 1, lock control during the fall animation (Android, Mania, Origins style)
ExtendedCamera =					0				; if 1, enable extended camera

; level main options
ZoneCount =						1				; set discrete zones are: DEZ
HUDScroll =						1				; if 1, enable HUD scrolling movement on level start/finish
HUDCentiseconds =					1				; if 1, enable centiseconds in the HUD

; level misc options
MonitorFall =						0				; if 1, monitor will fall after being hit from below

; level boss options
BossDebug =						0				; if 1, set one hit on all bosses

; SRAM options
EnableSRAM =						0				; if 1, enable SRAM
BackupSRAM =						0				; if 1, enable Backup SRAM
AddressSRAM =						0				; 0 = odd+even, 2 = even only, 3 = odd only

; assembly options
DEBUG_PassCheck =					1				; if 1, check the number of assembly passes
DEBUG_PassError =					1				; if 1, raise an error if there are more than max assembly passes here
DEBUG_PassMax =						2				; set the maximum number of assembly passes for a pass error

; error handler debugging options (only available in DEBUG builds)
DEBUG_ALL =						1				; if 1, enable all debugging checks
DEBUG_DMA =						0|DEBUG_ALL			; if 1, check DMA buffer overflow
DEBUG_DrawLevel =					0|DEBUG_ALL			; if 1, check plane buffer overflow
DEBUG_KosinskiPlus =					0|DEBUG_ALL			; if 1, check kosinki plus buffer overflow
DEBUG_KosinskiPlusModule =				0|DEBUG_ALL			; if 1, check kosinki plus module buffer overflow
DEBUG_LoadObjects =					0|DEBUG_ALL			; if 1, check object respawn table overflow
DEBUG_LoadRings =					0|DEBUG_ALL			; if 1, check ring status table overflow
DEBUG_RingTouchResponse =				0|DEBUG_ALL			; if 1, check ring xy wrap position
DEBUG_RingTouchResponse_Consume =			0|DEBUG_ALL			; if 1, check ring consumption list overflow
DEBUG_RenderSprites =					0|DEBUG_ALL			; if 1, check object and mappings address are valid
