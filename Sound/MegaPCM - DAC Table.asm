; ---------------------------------------------------------------
; DAC Samples Table
; ---------------------------------------------------------------

MegaPCM_DAC_Table:
	if SMPS_S1DACSamples||SMPS_S2DACSamples
		; Sonic 1 & 2
						; type	pointer	Hz
ptr_dac81:	dcSample	TYPE_PCM, Kick, 8201					; $81	- Kick
ptr_dac82:	dcSample	TYPE_PCM, Snare, 23784					; $82	- Snare
ptr_dac85:	dcSample	TYPE_PCM, Timpani, 7328					; $85	- Timpani
ptr_dac88:	dcSample	TYPE_PCM, Timpani, 9635					; $88	- Hi-Timpani
ptr_dac89:	dcSample	TYPE_PCM, Timpani, 8720					; $89	- Mid-Timpani
ptr_dac8A:	dcSample	TYPE_PCM, Timpani, 7138					; $8A	- Low-Timpani
ptr_dac8B:	dcSample	TYPE_PCM, Timpani, 6957					; $8B	- Very Low-Timpani
	endif

	if SMPS_S2DACSamples
		; Sonic 2
ptr_dac83:	dcSample	TYPE_PCM, Clap, 17127					; $83	- Clap
ptr_dac84:	dcSample	TYPE_PCM, Scratch, 15232					; $84	- Scratch
ptr_dac86:	dcSample	TYPE_PCM, Tom, 13714					; $86	- Hi-Tom
ptr_dac87:	dcSample	TYPE_PCM, Bongo, 7426					; $87	- Very Low-Bongo
ptr_dac8C:	dcSample	TYPE_PCM, Tom, 22799					; $8C	- Mid-Tom
ptr_dac8D:	dcSample	TYPE_PCM, Tom, 18262					; $8D	- Low-Tom
ptr_dac8E:	dcSample	TYPE_PCM, Tom, 15232					; $8E	- Floor-Tom
ptr_dac8F:	dcSample	TYPE_PCM, Bongo, 15232					; $8F	- Hi-Bongo
ptr_dac90:	dcSample	TYPE_PCM, Bongo, 13064					; $90	- Mid-Bongo
ptr_dac91:	dcSample	TYPE_PCM, Bongo, 9806					; $91	- Low-Bongo
	endif

	if SMPS_S3DACSamples||SMPS_SKDACSamples||SMPS_S3DDACSamples
		; Sonic 3 & K & 3D
ptr_dac92:	dcSample	TYPE_PCM, SnareS3, 19090				; $92	- Snare (S3)
ptr_dac93:	dcSample	TYPE_PCM, TomS3, 11274					; $93	- Hi-Tom (S3)
ptr_dac94:	dcSample	TYPE_PCM, TomS3, 9050					; $94	- Mid-Tom (S3)
ptr_dac95:	dcSample	TYPE_PCM, TomS3, 7599					; $95	- Low Tom (S3)
ptr_dac96:	dcSample	TYPE_PCM, TomS3, 6490					; $96	- Floor-Tom (S3)
ptr_dac97:	dcSample	TYPE_PCM, KickS3, 19090					; $97	- Kick (S3)
ptr_dac98:	dcSample	TYPE_PCM, MuffledSnare, 19090			; $98	- Muffled Snare
ptr_dac99:	dcSample	TYPE_PCM, CrashCymbal, 16766			; $99	- Crash Cymbal
ptr_dac9A:	dcSample	TYPE_PCM, RideCymbal, 13482				; $9A	- Ride Cymbal
ptr_dac9B:	dcSample	TYPE_PCM, MetalHit, 9050				; $9B	- Low-Metal Hit
ptr_dac9C:	dcSample	TYPE_PCM, MetalHit, 7357					; $9C	- Metal Hit
ptr_dac9D:	dcSample	TYPE_PCM, MetalHit2, 14945				; $9D	- High-Metal Hit
ptr_dac9E:	dcSample	TYPE_PCM, MetalHit3, 12852				; $9E	- Higher-Metal Hit
ptr_dac9F:	dcSample	TYPE_PCM, MetalHit3, 10040				; $9F	- Mid-Metal Hit
ptr_dacA0:	dcSample	TYPE_PCM, ClapS3, 14945					; $A0	- Clap (S3)
ptr_dacA1:	dcSample	TYPE_PCM, ElectricTom, 20513				; $A1	- Electric High-Tom
ptr_dacA2:	dcSample	TYPE_PCM, ElectricTom, 15803				; $A2	- Electric Mid-Tom
ptr_dacA3:	dcSample	TYPE_PCM, ElectricTom, 13482				; $A3	- Electric Low-Tom
ptr_dacA4:	dcSample	TYPE_PCM, ElectricTom, 11274				; $A4	- Electric Floor-Tom
ptr_dacA5:	dcSample	TYPE_PCM, SnareS32, 16766				; $A5	- Mid-Pitch Snare
ptr_dacA6:	dcSample	TYPE_PCM, SnareS32, 13482				; $A6	- Tight Snare
ptr_dacA7:	dcSample	TYPE_PCM, SnareS32, 11755				; $A7	- Loose Snare
ptr_dacA8:	dcSample	TYPE_PCM, SnareS32, 9687				; $A8	- Looser Snare
ptr_dacA9:	dcSample	TYPE_PCM, TimpaniS3, 12852				; $A9	- Hi-Timpani (S3)
ptr_dacAA:	dcSample	TYPE_PCM, TimpaniS3, 9358				; $AA	- Low-Timpani (S3)
ptr_dacAB:	dcSample	TYPE_PCM, TimpaniS3, 8492				; $AB	- Mid-Timpani (S3)
ptr_dacAC:	dcSample	TYPE_PCM, SnareS33, 12279				; $AC	- Quick Loose Snare
ptr_dacAD:	dcSample	TYPE_PCM, Click, 13482					; $AD	- Click
ptr_dacAE:	dcSample	TYPE_PCM, PowerKick, 7998				; $AE	- Power Kick
ptr_dacAF:	dcSample	TYPE_PCM, QuickGlassCrash, 7998			; $AF	- Quick Glass Crash
	endif

	if SMPS_S3DACSamples||SMPS_SKDACSamples
		; Sonic 3 & K
ptr_dacB0:	dcSample	TYPE_PCM, GlassCrashSnare, 12279			; $B0	- Glass Crash Snare
ptr_dacB1:	dcSample	TYPE_PCM, GlassCrash, 12279				; $B1	- Glass Crash
ptr_dacB2:	dcSample	TYPE_PCM, GlassCrashKick, 13482			; $B2	- Glass Crash Kick
ptr_dacB3:	dcSample	TYPE_PCM, QuietGlassCrash, 13482			; $B3	- Quiet Glass Crash
ptr_dacB4:	dcSample	TYPE_PCM, SnareKick, 7998				; $B4	- Snare + Kick
ptr_dacB5:	dcSample	TYPE_PCM, KickBass, 7998				; $B5	- Bassy Kick
ptr_dacB6:	dcSample	TYPE_PCM, ComeOn, 12279				; $B6	- "Come On!"
ptr_dacB7:	dcSample	TYPE_PCM, DanceSnare, 14176				; $B7	- Dance Snare
ptr_dacB8:	dcSample	TYPE_PCM, LooseKick, 7998				; $B8	- Loose Kick
ptr_dacB9:	dcSample	TYPE_PCM, LooseKick2, 7998				; $B9	- Mod Loose Kick
ptr_dacBA:	dcSample	TYPE_PCM, Woo, 12279					; $BA	- "Woo!"
ptr_dacBB:	dcSample	TYPE_PCM, Go, 13482						; $BB	- "Go!"
ptr_dacBC:	dcSample	TYPE_PCM, SnareGo, 11755				; $BC	- Snare (S3) + "Go!"
ptr_dacBD:	dcSample	TYPE_PCM, PowerTom, 16766				; $BD	- Power Tom
ptr_dacBE:	dcSample	TYPE_PCM, WoodBlock, 10420				; $BE	- Hi-Wood Block
ptr_dacBF:	dcSample	TYPE_PCM, WoodBlock, 7998				; $BF	- Low-Wood Block
ptr_dacC0:	dcSample	TYPE_PCM, HitDrum, 14176				; $C0	- Hi-Hit Drum
ptr_dacC1:	dcSample	TYPE_PCM, HitDrum, 9687				; $C1	- Low-Hit Drum
ptr_dacC2:	dcSample	TYPE_PCM, MetalCrashHit, 7998			; $C2	- Metal Crash Hit
ptr_dacC3:	dcSample	TYPE_PCM, EchoedClapHit, 8492			; $C3	- Echoed Clap Hit
ptr_dacC4:	dcSample	TYPE_PCM, EchoedClapHit, 6520			; $C4	- Lower Echoed Clap Hit
ptr_dacC5:	dcSample	TYPE_PCM, HipHopHitKick, 12279			; $C5	- HipHop Hit Kick
ptr_dacC6:	dcSample	TYPE_PCM, HipHopPowerKick, 12279		; $C6	- HipHop Hit Power Kick
ptr_dacC7:	dcSample	TYPE_PCM, BassHey, 12279				; $C7	- Bass + "Hey!"
ptr_dacC8:	dcSample	TYPE_PCM, DanceStyleKick, 7998			; $C8	- Dance-Style Kick
ptr_dacC9:	dcSample	TYPE_PCM, HipHopHitKick2, 12279			; $C9	- HipHop Hit Kick 2
ptr_dacCA:	dcSample	TYPE_PCM, RevFadingWind, 7998			; $CA	- Reverse Fading Wind
ptr_dacCB:	dcSample	TYPE_PCM, ScratchS3, 7998				; $CB	- Scratch (S3)
ptr_dacCC:	dcSample	TYPE_PCM, LooseSnareNoise, 7998			; $CC	- Loose-Snare Noise
ptr_dacCD:	dcSample	TYPE_PCM, PowerKick2, 12279				; $CD	- Power Kick 2
ptr_dacCE:	dcSample	TYPE_PCM, CrashNoiseWoo, 12279			; $CE	- Crash Noise + "Woo!"
ptr_dacCF:	dcSample	TYPE_PCM, QuickHit, 7166				; $CF	- Quick Hit
ptr_dacD0:	dcSample	TYPE_PCM, KickHey, 12852				; $D0	- Kick (S3) + "Hey!"
ptr_dacD1:	dcSample	TYPE_PCM, HipHopHitKick, 10830			; $D1	- Power Kick Hit
ptr_dacD2:	dcSample	TYPE_PCM, HipHopHitKick, 10040			; $D2	- Low Power Kick Hit
ptr_dacD3:	dcSample	TYPE_PCM, HipHopHitKick, 9687			; $D3	- Lower Power Kick Hit
ptr_dacD4:	dcSample	TYPE_PCM, HipHopHitKick, 12852			; $D4	- Lowest Power Kick Hit
	endif

	if SMPS_S3DDACSamples
		; Sonic 3D
ptr_dacD5:	dcSample	TYPE_PCM, MetalCrashS3D, 24104			; $D5	- Final Fight Metal Crash
ptr_dacD6:	dcSample	TYPE_PCM, MetalCrashS3D, 9687			; $D6	- Intro Kick
	endif

	if SMPS_S3DACSamples
		; Sonic 3
ptr_dacD7:	dcSample	TYPE_PCM, EchoedClapHitS3, 8492			; $D7	- Echoed Clap Hit (S3)
ptr_dacD8:	dcSample	TYPE_PCM, EchoedClapHitS3, 6490			; $D8	- Lower Echoed Clap Hit(S3)	; Clownacy | Good golly, we're close to reaching Mega PCM's limit...
	endif

	if SMPS_SCDACSamples
		; Sonic Crackers
ptr_dacD9:	dcSample	TYPE_PCM, Beat, 4728					; $D9	- Beat
ptr_dacDA:	dcSample	TYPE_PCM, SnareSC, 13610				; $DA	- Snare (SC)
ptr_dacDB:	dcSample	TYPE_PCM, TimTom, 13610				; $DB	- Hi Timpani/Tom (SC)
ptr_dacDC:	dcSample	TYPE_PCM, TimTom, 11363				; $DC	- Mid Timpani/Tom (SC)
ptr_dacDD:	dcSample	TYPE_PCM, TimTom, 10497				; $DD	- Low Timpani/Tom (SC)
ptr_dacDE:	dcSample	TYPE_PCM, LetsGo, 13610					; $DE	- "Let's Go!"
ptr_dacDF:	dcSample	TYPE_PCM, Hey, 13610					; $DF	- "Hey!"	; Clownacy | X_X Extending the DAC range is going to take some creativity...
	endif

ptr_dacE0:	dcSample	TYPE_PCM, SegaPCM, 16000				; $E0	- Sega!
			dc.w -1												; end marker
