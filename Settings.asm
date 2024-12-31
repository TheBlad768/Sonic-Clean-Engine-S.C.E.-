; ===========================================================================
; Settings
; ===========================================================================

; assembly options
ZoneCount:				= 1	; discrete zones are: DEZ
GameDebug:				= 1	; if 1, enable debug mode for Sonic
GameDebugAlt:			= 0	; if 1, enable alt debug mode for Sonic
Lagometer:				= 1	; if 1, enable debug lagometer
BossDebug:				= 0	; if 1, one hit for all bosses
ExtendedCamera:			= 0	; if 1, enable extended camera
RollInAir:				= 1	; if 1, enable roll in air for Sonic
MSUMode:				= 0	; if 1, enable MSU
OptimiseStopZ80:			= 2	; if 1, remove stopZ80 and startZ80, if 2, use only for controllers (ignores sound driver)
ZeroOffsetOptimization:	= 1	; if 1, makes a handful of zero-offset instructions smaller
AllOptimizations:			= 1	; if 1, enables all optimizations
ChecksumCheck:			= 0	; if 1, enable checksum checking
EnableSRAM:				= 0	; change to 1 to enable SRAM
BackupSRAM:			= 0
AddressSRAM:			= 0	; 0 = odd+even; 2 = even only; 3 = odd only