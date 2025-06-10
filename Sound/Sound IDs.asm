; ---------------------------------------------------------------------------
; Sound commands list
; ---------------------------------------------------------------------------

	phase $E1
mus__FirstCmd =				*		; ID of the first sound command
mus_Fade =				*		; $E1 - fade out music
mus_FadeOut				ds.b 1		; $E1 - fade out music
mus_Stop				ds.b 1		; $E2 - stop music and sound effects
mus_MutePSG				ds.b 1		; $E3 - mute all PSG channels
mus_StopSFX				ds.b 1		; $E4 - stop all sound effects
mus_FadeOut2				ds.b 1		; $E5 - fade out music (duplicate)
mus__EndCmd =				*		; next ID after last sound command

mus_FA =				$FA		; $FA - ???
mus_StopSEGA =				$FE		; $FE - Stop SEGA sound
mus_SEGA =				$FF		; $FF - Play SEGA sound

	dephase

; ---------------------------------------------------------------------------
; Music ID's list. These do not affect the sound driver, be careful
; ---------------------------------------------------------------------------

	phase $01
mus__First =				*		; ID of the first music

; Levels
mus_DEZ1				ds.b 1		; $01

; Bosses
mus_MidBoss				ds.b 1		; $02
mus_ZoneBoss				ds.b 1		; $03

; Misc
mus_Invincible				ds.b 1		; $04
mus_GotThrough				ds.b 1		; $05
mus_Drowning				ds.b 1		; $06

mus_ExtraLife				= $00		; not used

mus__End =				*		; next ID after last music

	dephase

; ---------------------------------------------------------------------------
; Sound effect ID's list. These do not affect the sound driver, be careful
; ---------------------------------------------------------------------------

	phase $01
sfx__First =				*		; ID of the first sound effect

sfx_RingRight				ds.b 1		; $01
sfx_RingLeft				ds.b 1		; $02
sfx_RingLoss				ds.b 1		; $03
sfx_Jump				ds.b 1		; $04
sfx_Roll				ds.b 1		; $05
sfx_Skid				ds.b 1		; $06
sfx_Death				ds.b 1		; $07
sfx_SpinDash				ds.b 1		; $08
sfx_Splash				ds.b 1		; $09
sfx_InstaAttack				ds.b 1		; $0A
sfx_FireShield				ds.b 1		; $0B
sfx_BubbleShield			ds.b 1		; $0C
sfx_LightningShield			ds.b 1		; $0D
sfx_FireAttack				ds.b 1		; $0E
sfx_BubbleAttack			ds.b 1		; $0F
sfx_ElectricAttack			ds.b 1		; $10
sfx_SpikeHit				ds.b 1		; $11
sfx_SpikeMove				ds.b 1		; $12
sfx_Drown				ds.b 1		; $13
sfx_StarPost				ds.b 1		; $14
sfx_Spring				ds.b 1		; $15
sfx_Dash				ds.b 1		; $16
sfx_Break				ds.b 1		; $17
sfx_BossHit				ds.b 1		; $18
sfx_AirDing				ds.b 1		; $19
sfx_Bubble				ds.b 1		; $1A
sfx_Explode				ds.b 1		; $1B
sfx_Signpost				ds.b 1		; $1C
sfx_Switch				ds.b 1		; $1D
sfx_Register				ds.b 1		; $1E

; Continuous
sfx__FirstContinuous =			*		; ID of the first continuous sound effect


sfx__End =				*		; next ID after the last sound effect

	dephase
	!org 0						; make sure we reset the ROM position to 0
