; ---------------------------------------------------------------------------
; SFX metadata (pointers, priorities, flags)

; Priority of sound. New music or SFX must have a priority higher than or equal
; to what is stored in v_sndprio or it won't play. If bit 7 of new priority is
; set ($80 and up), the new music or SFX will not set its priority -- meaning
; any music or SFX can override it (as long as it can override whatever was
; playing before). Usually, SFX will only override SFX, special SFX ($D0-$DF)
; will only override special SFX and music will only override music.
; Of course, this isn't the case anymore, as priorities no longer apply to
; special SFX or music.
; TODO Maybe I should make it apply to Special SFX, too.
; ---------------------------------------------------------------------------
SoundIndex:
ptr_snd01:		SMPS_SFX_METADATA	Sound01, $70, 0
ptr_snd02:		SMPS_SFX_METADATA	Sound02, $70, 0
ptr_snd03:		SMPS_SFX_METADATA	Sound03, $70, 0
ptr_snd04:		SMPS_SFX_METADATA	Sound04, $70, 0
ptr_snd05:		SMPS_SFX_METADATA	Sound05, $70, 0
ptr_snd06:		SMPS_SFX_METADATA	Sound06, $70, 0
ptr_snd07:		SMPS_SFX_METADATA	Sound07, $70, 0
ptr_snd08:		SMPS_SFX_METADATA	Sound08, $70, 0
ptr_snd09:		SMPS_SFX_METADATA	Sound09, $70, 0
ptr_snd0A:		SMPS_SFX_METADATA	Sound0A, $70, 0
ptr_snd0B:		SMPS_SFX_METADATA	Sound0B, $70, 0
ptr_snd0C:		SMPS_SFX_METADATA	Sound0C, $70, 0
ptr_snd0D:		SMPS_SFX_METADATA	Sound0D, $70, 0
ptr_snd0E:		SMPS_SFX_METADATA	Sound0E, $70, 0
ptr_snd0F:		SMPS_SFX_METADATA	Sound0F, $70, 0
ptr_snd10:		SMPS_SFX_METADATA	Sound10, $70, 0
ptr_snd11:		SMPS_SFX_METADATA	Sound11, $70, 0
ptr_snd12:		SMPS_SFX_METADATA	Sound12, $70, 0
ptr_snd13:		SMPS_SFX_METADATA	Sound13, $70, 0
ptr_snd14:		SMPS_SFX_METADATA	Sound14, $70, 0
ptr_snd15:		SMPS_SFX_METADATA	Sound15, $70, 0
ptr_snd16:		SMPS_SFX_METADATA	Sound16, $70, 0
ptr_snd17:		SMPS_SFX_METADATA	Sound17, $70, 0
ptr_snd18:		SMPS_SFX_METADATA	Sound18, $70, 0
ptr_snd19:		SMPS_SFX_METADATA	Sound19, $70, 0
ptr_snd1A:		SMPS_SFX_METADATA	Sound1A, $70, 0
ptr_snd1B:		SMPS_SFX_METADATA	Sound1B, $70, 0
ptr_snd1C:		SMPS_SFX_METADATA	Sound1C, $70, 0
ptr_snd1D:		SMPS_SFX_METADATA	Sound1D, $70, 0
ptr_snd1E:		SMPS_SFX_METADATA	Sound1E, $70, 0
ptr_snd1F:		SMPS_SFX_METADATA	Sound1F, $70, 0

ptr_sndend
; ---------------------------------------------------------------------------
; SFX data ($40-$EF)
; ---------------------------------------------------------------------------

Sound01:		include "Sound/SFX/Snd - Ring.asm"
	even
Sound02:		include "Sound/SFX/Snd - Ring Left Speaker.asm"
	even
Sound03:		include "Sound/SFX/Snd - Ring Loss.asm"
	even
Sound04:		include "Sound/SFX/Snd - Jump.asm"
	even
Sound05:		include "Sound/SFX/Snd - Roll.asm"
	even
Sound06:		include "Sound/SFX/Snd - Skid.asm"
	even
Sound07:		include "Sound/SFX/Snd - Death.asm"
	even
Sound08:		include "Sound/SFX/Snd - Spin Dash.asm"
	even
Sound09:		include "Sound/SFX/Snd - Splash.asm"
	even
Sound0A:		include "Sound/SFX/Snd - Insta Attack.asm"
	even
Sound0B:		include "Sound/SFX/Snd - Fire Shield.asm"
	even
Sound0C:		include "Sound/SFX/Snd - Bubble Shield.asm"
	even
Sound0D:		include "Sound/SFX/Snd - Lightning Shield.asm"
	even
Sound0E:		include "Sound/SFX/Snd - Fire Attack.asm"
	even
Sound0F:		include "Sound/SFX/Snd - Bubble Attack.asm"
	even
Sound10:		include "Sound/SFX/Snd - Electric Attack.asm"
	even
Sound11:		include "Sound/SFX/Snd - Spike Hit.asm"
	even
Sound12:		include "Sound/SFX/Snd - Spike Move.asm"
	even
Sound13:		include "Sound/SFX/Snd - Drown.asm"
	even
Sound14:		include "Sound/SFX/Snd - Star Post.asm"
	even
Sound15:		include "Sound/SFX/Snd - Spring.asm"
	even
Sound16:		include "Sound/SFX/Snd - Dash.asm"
	even
Sound17:		include "Sound/SFX/Snd - Break.asm"
	even
Sound18:		include "Sound/SFX/Snd - Boss Hit.asm"
	even
Sound19:		include "Sound/SFX/Snd - Air Ding.asm"
	even
Sound1A:		include "Sound/SFX/Snd - Bubble.asm"
	even
Sound1B:		include "Sound/SFX/Snd - Explode.asm"
	even
Sound1C:		include "Sound/SFX/Snd - Signpost.asm"
	even
Sound1D:		include "Sound/SFX/Snd - Switch.asm"
	even
Sound1E:		include "Sound/SFX/Snd - Register.asm"
	even
Sound1F:		include "Sound/SFX/Snd - Ground Slide.asm"
	even
