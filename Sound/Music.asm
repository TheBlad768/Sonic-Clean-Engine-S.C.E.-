; ---------------------------------------------------------------------------
; Music metadata (pointers, speed shoes tempos, flags)
; ---------------------------------------------------------------------------
MusicIndex:
; Levels
ptr_mus01:		SMPS_MUSIC_METADATA	Music01, s3TempotoS1($FF), 0

; Boss
ptr_mus02:		SMPS_MUSIC_METADATA	Music02, s3TempotoS1($FF), 0
ptr_mus03:		SMPS_MUSIC_METADATA	Music03, s3TempotoS1($FF), 0

; Misc
ptr_mus04:		SMPS_MUSIC_METADATA	Music04, s3TempotoS1($FF), 0
ptr_mus05:		SMPS_MUSIC_METADATA	Music05, s3TempotoS1($FF), 0
ptr_mus06:		SMPS_MUSIC_METADATA	Music06, s3TempotoS1($02), SMPS_MUSIC_METADATA_FORCE_PAL_SPEED

ptr_musend

; ---------------------------------------------------------------------------
; Music data ($01-$3F)
; ---------------------------------------------------------------------------

Music01:		include "Sound/Music/Mus - DEZ1.asm"
	even
Music02:		include "Sound/Music/Mus - Miniboss.asm"
	even
Music03:		include "Sound/Music/Mus - Zone Boss.asm"
	even
Music04:		include "Sound/Music/Mus - Invincibility.asm"
	even
Music05: 		include "Sound/Music/Mus - Sonic Got Through.asm"
	even
Music06:		include "Sound/Music/Mus - Drowning.asm"
	even