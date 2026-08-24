; ===========================================================================
; ║                                                                         ║
; ║                             SONIC&K SOUND DRIVER                        ║
; ║                         Modified SMPS Z80 Type 2 DAC                    ║
; ║                                                                         ║
; ===========================================================================
; Disassembled by MarkeyJester
; Routines, pointers and stuff by Linncaki
; Thoroughly commented and improved (including optional bugfixes) by Flamewing
; ===========================================================================
; Permission to use, copy, modify, and/or distribute this software for any
; purpose with or without fee is hereby granted.
;
; THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
; WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
; MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
; ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
; WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
; ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT
; OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
; ===========================================================================
; Sound Bank
; ===========================================================================
SndBank:			startBank

; ===========================================================================
; SFX Pointers
; ===========================================================================
		Snd_Master_Table
; ---------------------------------------------------------------------------
SEGA_PCM:	binclude "Sound/Sega PCM.pcm"
SEGA_PCM_End
		even

; Normal
Sound_RingRight:			include "Sound/SFX/Snd - Ring (Right).asm"
Sound_RingLeft:				include "Sound/SFX/Snd - Ring (Left).asm"
Sound_RingLoss:				include "Sound/SFX/Snd - Ring Loss.asm"
Sound_Jump:				include "Sound/SFX/Snd - Jump.asm"
Sound_Roll:				include "Sound/SFX/Snd - Roll.asm"
Sound_Skid:				include "Sound/SFX/Snd - Skid.asm"
Sound_Death:				include "Sound/SFX/Snd - Death.asm"
Sound_Spindash:				include "Sound/SFX/Snd - Spin Dash.asm"
Sound_Splash:				include "Sound/SFX/Snd - Splash.asm"
Sound_InstaAttack:			include "Sound/SFX/Snd - Insta Attack.asm"
Sound_FireShield:			include "Sound/SFX/Snd - Fire Shield.asm"
Sound_BubbleShield:			include "Sound/SFX/Snd - Bubble Shield.asm"
Sound_LightningShield:			include "Sound/SFX/Snd - Lightning Shield.asm"
Sound_FireAttack:			include "Sound/SFX/Snd - Fire Attack.asm"
Sound_BubbleAttack:			include "Sound/SFX/Snd - Bubble Attack.asm"
Sound_ElectricAttack:			include "Sound/SFX/Snd - Electric Attack.asm"
Sound_SpikeHit:				include "Sound/SFX/Snd - Spike Hit.asm"
Sound_SpikeMove:			include "Sound/SFX/Snd - Spike Move.asm"
Sound_Drown:				include "Sound/SFX/Snd - Drown.asm"
Sound_StarPost:				include "Sound/SFX/Snd - Star Post.asm"
Sound_Spring:				include "Sound/SFX/Snd - Spring.asm"
Sound_Dash:				include "Sound/SFX/Snd - Dash.asm"
Sound_Break:				include "Sound/SFX/Snd - Break.asm"
Sound_BossHit:				include "Sound/SFX/Snd - Boss Hit.asm"
Sound_AirDing:				include "Sound/SFX/Snd - Air Ding.asm"
Sound_Bubble:				include "Sound/SFX/Snd - Bubble.asm"
Sound_Explode:				include "Sound/SFX/Snd - Explode.asm"
Sound_Signpost:				include "Sound/SFX/Snd - Signpost.asm"
Sound_Switch:				include "Sound/SFX/Snd - Switch.asm"
Sound_Register:				include "Sound/SFX/Snd - Register.asm"
Sound_GroundSlide:			include "Sound/SFX/Snd - Ground Slide.asm"

	finishBank
; ---------------------------------------------------------------------------
