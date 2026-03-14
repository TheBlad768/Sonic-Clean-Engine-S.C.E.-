; ---------------------------------------------------------------------------
; Sound IDs
; ---------------------------------------------------------------------------
; Background music
offset :=	MusicIndex
ptrsize :=	4
idstart :=	1
; $00 is reserved for silence

mus__First = idstart
; Levels
mus_DEZ1 =			SMPS_id(ptr_mus01)

; Bosses
mus_MidBoss =			SMPS_id(ptr_mus02)
mus_ZoneBoss =			SMPS_id(ptr_mus03)

; Misc
mus_Invincible =		SMPS_id(ptr_mus04)
mus_GotThrough =		SMPS_id(ptr_mus05)
mus_Drowning =			SMPS_id(ptr_mus06)

mus__Last =			SMPS_id(ptr_musend)-1

; Sound effects
offset :=	SoundIndex
ptrsize :=	4
idstart :=	$40

sfx__First = idstart
sfx_RingRight =			SMPS_id(ptr_snd01)
sfx_RingLeft =			SMPS_id(ptr_snd02)
sfx_RingLoss =			SMPS_id(ptr_snd03)
sfx_Jump =			SMPS_id(ptr_snd04)
sfx_Roll =			SMPS_id(ptr_snd05)
sfx_Skid =			SMPS_id(ptr_snd06)
sfx_Death =			SMPS_id(ptr_snd07)
sfx_SpinDash =			SMPS_id(ptr_snd08)
sfx_Splash =			SMPS_id(ptr_snd09)
sfx_InstaAttack =		SMPS_id(ptr_snd0A)
sfx_FireShield =		SMPS_id(ptr_snd0B)
sfx_BubbleShield =		SMPS_id(ptr_snd0C)
sfx_LightningShield =		SMPS_id(ptr_snd0D)
sfx_FireAttack =		SMPS_id(ptr_snd0E)
sfx_BubbleAttack =		SMPS_id(ptr_snd0F)
sfx_ElectricAttack =		SMPS_id(ptr_snd10)
sfx_SpikeHit =			SMPS_id(ptr_snd11)
sfx_SpikeMove =			SMPS_id(ptr_snd12)
sfx_Drown =			SMPS_id(ptr_snd13)
sfx_StarPost =			SMPS_id(ptr_snd14)
sfx_Spring =			SMPS_id(ptr_snd15)
sfx_Dash =			SMPS_id(ptr_snd16)
sfx_Break =			SMPS_id(ptr_snd17)
sfx_BossHit =			SMPS_id(ptr_snd18)
sfx_AirDing =			SMPS_id(ptr_snd19)
sfx_Bubble =			SMPS_id(ptr_snd1A)
sfx_Explode =			SMPS_id(ptr_snd1B)
sfx_Signpost =			SMPS_id(ptr_snd1C)
sfx_Switch =			SMPS_id(ptr_snd1D)
sfx_Register =			SMPS_id(ptr_snd1E)
sfx_GroundSlide =		SMPS_id(ptr_snd1F)

sfx__Last =			SMPS_id(ptr_sndend)-1

; Sound commands
offset :=	Sound_ExIndex
ptrsize :=	2
idstart :=	$F9

flg__First = idstart
specsfx_Stop =			SMPS_id(ptr_flgF9)
sfx_Stop =			SMPS_id(ptr_flgFA)
mus_Fade =			SMPS_id(ptr_flgFB)
sfx_Sega =			SMPS_id(ptr_flgFC)
mus_Speedup =			SMPS_id(ptr_flgFD)
mus_Slowdown =			SMPS_id(ptr_flgFE)
mus_Stop =			SMPS_id(ptr_flgFF)
flg__Last =			SMPS_id(ptr_flgend)-1
