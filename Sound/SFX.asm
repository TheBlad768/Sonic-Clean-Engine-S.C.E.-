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
ptr_snd40:	SMPS_SFX_METADATA	Sound40, $70, 0
ptr_snd41:	SMPS_SFX_METADATA	Sound41, $70, 0
ptr_snd42:	SMPS_SFX_METADATA	Sound42, $70, 0
ptr_snd43:	SMPS_SFX_METADATA	Sound43, $70, 0
ptr_snd44:	SMPS_SFX_METADATA	Sound44, $70, 0
ptr_snd45:	SMPS_SFX_METADATA	Sound45, $70, 0
ptr_snd46:	SMPS_SFX_METADATA	Sound46, $70, 0
ptr_snd47:	SMPS_SFX_METADATA	Sound47, $70, 0
ptr_snd48:	SMPS_SFX_METADATA	Sound48, $70, 0
ptr_snd49:	SMPS_SFX_METADATA	Sound49, $70, 0
ptr_snd4A:	SMPS_SFX_METADATA	Sound4A, $70, 0
ptr_snd4B:	SMPS_SFX_METADATA	Sound4B, $70, 0
ptr_snd4C:	SMPS_SFX_METADATA	Sound4C, $70, 0
ptr_snd4D:	SMPS_SFX_METADATA	Sound4D, $70, 0
ptr_snd4E:	SMPS_SFX_METADATA	Sound4E, $70, 0
ptr_snd4F:	SMPS_SFX_METADATA	Sound4F, $70, 0
ptr_snd50:	SMPS_SFX_METADATA	Sound50, $70, 0
ptr_snd51:	SMPS_SFX_METADATA	Sound51, $70, 0
ptr_snd52:	SMPS_SFX_METADATA	Sound52, $70, 0
ptr_snd53:	SMPS_SFX_METADATA	Sound53, $70, 0
ptr_snd54:	SMPS_SFX_METADATA	Sound54, $70, 0
ptr_snd55:	SMPS_SFX_METADATA	Sound55, $70, 0
ptr_snd56:	SMPS_SFX_METADATA	Sound56, $70, 0
ptr_snd57:	SMPS_SFX_METADATA	Sound57, $70, 0
ptr_snd58:	SMPS_SFX_METADATA	Sound58, $70, 0
ptr_snd59:	SMPS_SFX_METADATA	Sound59, $70, 0
ptr_snd5A:	SMPS_SFX_METADATA	Sound5A, $70, 0
ptr_snd5B:	SMPS_SFX_METADATA	Sound5B, $70, 0
ptr_snd5C:	SMPS_SFX_METADATA	Sound5C, $70, 0
ptr_snd5D:	SMPS_SFX_METADATA	Sound5D, $70, 0

ptr_sndend
; ---------------------------------------------------------------------------
; SFX data ($40-$EF)
; ---------------------------------------------------------------------------

Sound40:	include	"Sound/SFX/Snd - Ring.asm"
	even
Sound41:		include	"Sound/SFX/Snd - Ring Left Speaker.asm"
	even
Sound42:	include	"Sound/SFX/Snd - Ring Loss.asm"
	even
Sound43:	include	"Sound/SFX/Snd - Jump.asm"
	even
Sound44:	include	"Sound/SFX/Snd - Roll.asm"
	even
Sound45:	include	"Sound/SFX/Snd - Skid.asm"
	even
Sound46:	include	"Sound/SFX/Snd - Death.asm"
	even
Sound47:	include	"Sound/SFX/Snd - SpinDash.asm"
	even
Sound48:	include	"Sound/SFX/Snd - Splash.asm"
	even
Sound49:	include	"Sound/SFX/Snd - Insta Attack.asm"
	even
Sound4A:	include	"Sound/SFX/Snd - Fire Shield.asm"
	even
Sound4B:	include	"Sound/SFX/Snd - Bubble Shield.asm"
	even
Sound4C:	include	"Sound/SFX/Snd - Lightning Shield.asm"
	even
Sound4D:	include	"Sound/SFX/Snd - Fire Attack.asm"
	even
Sound4E:	include	"Sound/SFX/Snd - Bubble Attack.asm"
	even
Sound4F:	include	"Sound/SFX/Snd - Electric Attack.asm"
	even
Sound50:	include	"Sound/SFX/Snd - Spike Hit.asm"
	even
Sound51:		include	"Sound/SFX/Snd - Spike Move.asm"
	even
Sound52:	include	"Sound/SFX/Snd - Drown.asm"
	even
Sound53:	include	"Sound/SFX/Snd - StarPost.asm"
	even
Sound54:	include	"Sound/SFX/Snd - Spring.asm"
	even
Sound55:	include	"Sound/SFX/Snd - Dash.asm"
	even
Sound56:	include	"Sound/SFX/Snd - Break.asm"
	even
Sound57:	include	"Sound/SFX/Snd - Boss Hit.asm"
	even
Sound58:	include	"Sound/SFX/Snd - Air Ding.asm"
	even
Sound59:	include	"Sound/SFX/Snd - Bubble.asm"
	even
Sound5A:	include	"Sound/SFX/Snd - Explode.asm"
	even
Sound5B:	include	"Sound/SFX/Snd - Signpost.asm"
	even
Sound5C:	include	"Sound/SFX/Snd - Switch.asm"
	even
Sound5D:	include	"Sound/SFX/Snd - Register.asm"
	even