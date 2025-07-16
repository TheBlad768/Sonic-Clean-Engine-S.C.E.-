; ===========================================================================
; Settings
; ===========================================================================

; assembly options
ZoneCount:				= 1	; discrete zones are: DEZ
GameDebug:				= 1	; if 1, enable debug mode for Sonic
GameDebugAlt:				= 0	; if 1, enable alt debug mode for Sonic
BossDebug:				= 0	; if 1, set one hit on all bosses
ExtendedCamera:				= 0	; if 1, enable extended camera
RollInAir:				= 1	; if 1, enable roll in air for Sonic
PlayerMoveLock:				= 0	; if 1, lock control during the fall animation (Android, Mania, Origins style...)
OptimiseStopZ80:			= 2	; if 1, remove stopZ80 and startZ80, if 2, use only for controllers (no effect on sound driver)
ChecksumCheck:				= 0	; if 1, enable checksum checking
EnableSRAM:				= 0	; change to 1 to enable SRAM
BackupSRAM:				= 0
AddressSRAM:				= 0	; 0 = odd+even; 2 = even only; 3 = odd only