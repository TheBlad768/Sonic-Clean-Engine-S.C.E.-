; ---------------------------------------------------------------
; DAC Samples Table
; ---------------------------------------------------------------

MegaPCM_DAC_Table:
	if SMPS_S1DACSamples||SMPS_S2DACSamples
			; Sonic 1 & 2
			; type	pointer	Hz
dac81:	dcSample	TYPE_PCM, Kick, 8201				; $81	- Kick
dac82:	dcSample	TYPE_PCM, Snare, 23784				; $82	- Snare
dac85:	dcSample	TYPE_PCM, Timpani, 7328				; $85	- Timpani
dac88:	dcSample	TYPE_PCM, Timpani, 9635				; $88	- Hi-Timpani
dac89:	dcSample	TYPE_PCM, Timpani, 8720				; $89	- Mid-Timpani
dac8A:	dcSample	TYPE_PCM, Timpani, 7138				; $8A	- Low-Timpani
dac8B:	dcSample	TYPE_PCM, Timpani, 6957				; $8B	- Very Low-Timpani
	endif

	if SMPS_S2DACSamples
			; Sonic 2
dac83:	dcSample	TYPE_PCM, Clap, 17127				; $83	- Clap
dac84:	dcSample	TYPE_PCM, Scratch, 15232			; $84	- Scratch
dac86:	dcSample	TYPE_PCM, Tom, 13714				; $86	- Hi-Tom
dac87:	dcSample	TYPE_PCM, Bongo, 7426				; $87	- Very Low-Bongo
dac8C:	dcSample	TYPE_PCM, Tom, 22799				; $8C	- Mid-Tom
dac8D:	dcSample	TYPE_PCM, Tom, 18262				; $8D	- Low-Tom
dac8E:	dcSample	TYPE_PCM, Tom, 15232				; $8E	- Floor-Tom
dac8F:	dcSample	TYPE_PCM, Bongo, 15232				; $8F	- Hi-Bongo
dac90:	dcSample	TYPE_PCM, Bongo, 13064				; $90	- Mid-Bongo
dac91:	dcSample	TYPE_PCM, Bongo, 9806				; $91	- Low-Bongo
	endif

	if SMPS_S3DACSamples||SMPS_SKDACSamples||SMPS_S3DDACSamples
			; Sonic 3 & K & 3D
dac92:	dcSample	TYPE_PCM, SnareS3, 19090			; $92	- Snare (S3)
dac93:	dcSample	TYPE_PCM, TomS3, 11274				; $93	- Hi-Tom (S3)
dac94:	dcSample	TYPE_PCM, TomS3, 9050				; $94	- Mid-Tom (S3)
dac95:	dcSample	TYPE_PCM, TomS3, 7599				; $95	- Low Tom (S3)
dac96:	dcSample	TYPE_PCM, TomS3, 6490				; $96	- Floor-Tom (S3)
dac97:	dcSample	TYPE_PCM, KickS3, 19090				; $97	- Kick (S3)
dac98:	dcSample	TYPE_PCM, MuffledSnare, 19090			; $98	- Muffled Snare
dac99:	dcSample	TYPE_PCM, CrashCymbal, 16766			; $99	- Crash Cymbal
dac9A:	dcSample	TYPE_PCM, RideCymbal, 13482			; $9A	- Ride Cymbal
dac9B:	dcSample	TYPE_PCM, MetalHit, 9050			; $9B	- Low-Metal Hit
dac9C:	dcSample	TYPE_PCM, MetalHit, 7357			; $9C	- Metal Hit
dac9D:	dcSample	TYPE_PCM, MetalHit2, 14945			; $9D	- High-Metal Hit
dac9E:	dcSample	TYPE_PCM, MetalHit3, 12852			; $9E	- Higher-Metal Hit
dac9F:	dcSample	TYPE_PCM, MetalHit3, 10040			; $9F	- Mid-Metal Hit
dacA0:	dcSample	TYPE_PCM, ClapS3, 14945				; $A0	- Clap (S3)
dacA1:	dcSample	TYPE_PCM, ElectricTom, 20513			; $A1	- Electric High-Tom
dacA2:	dcSample	TYPE_PCM, ElectricTom, 15803			; $A2	- Electric Mid-Tom
dacA3:	dcSample	TYPE_PCM, ElectricTom, 13482			; $A3	- Electric Low-Tom
dacA4:	dcSample	TYPE_PCM, ElectricTom, 11274			; $A4	- Electric Floor-Tom
dacA5:	dcSample	TYPE_PCM, SnareS32, 16766			; $A5	- Mid-Pitch Snare
dacA6:	dcSample	TYPE_PCM, SnareS32, 13482			; $A6	- Tight Snare
dacA7:	dcSample	TYPE_PCM, SnareS32, 11755			; $A7	- Loose Snare
dacA8:	dcSample	TYPE_PCM, SnareS32, 9687			; $A8	- Looser Snare
dacA9:	dcSample	TYPE_PCM, TimpaniS3, 12852			; $A9	- Hi-Timpani (S3)
dacAA:	dcSample	TYPE_PCM, TimpaniS3, 9358			; $AA	- Low-Timpani (S3)
dacAB:	dcSample	TYPE_PCM, TimpaniS3, 8492			; $AB	- Mid-Timpani (S3)
dacAC:	dcSample	TYPE_PCM, SnareS33, 12279			; $AC	- Quick Loose Snare
dacAD:	dcSample	TYPE_PCM, Click, 13482				; $AD	- Click
dacAE:	dcSample	TYPE_PCM, PowerKick, 7998			; $AE	- Power Kick
dacAF:	dcSample	TYPE_PCM, QuickGlassCrash, 7998			; $AF	- Quick Glass Crash
	endif

	if SMPS_S3DACSamples||SMPS_SKDACSamples
			; Sonic 3 & K
dacB0:	dcSample	TYPE_PCM, GlassCrashSnare, 12279		; $B0	- Glass Crash Snare
dacB1:	dcSample	TYPE_PCM, GlassCrash, 12279			; $B1	- Glass Crash
dacB2:	dcSample	TYPE_PCM, GlassCrashKick, 13482			; $B2	- Glass Crash Kick
dacB3:	dcSample	TYPE_PCM, QuietGlassCrash, 13482		; $B3	- Quiet Glass Crash
dacB4:	dcSample	TYPE_PCM, SnareKick, 7998			; $B4	- Snare + Kick
dacB5:	dcSample	TYPE_PCM, KickBass, 7998			; $B5	- Bassy Kick
dacB6:	dcSample	TYPE_PCM, ComeOn, 12279				; $B6	- "Come On!"
dacB7:	dcSample	TYPE_PCM, DanceSnare, 14176			; $B7	- Dance Snare
dacB8:	dcSample	TYPE_PCM, LooseKick, 7998			; $B8	- Loose Kick
dacB9:	dcSample	TYPE_PCM, LooseKick2, 7998			; $B9	- Mod Loose Kick
dacBA:	dcSample	TYPE_PCM, Woo, 12279				; $BA	- "Woo!"
dacBB:	dcSample	TYPE_PCM, Go, 13482				; $BB	- "Go!"
dacBC:	dcSample	TYPE_PCM, SnareGo, 11755			; $BC	- Snare (S3) + "Go!"
dacBD:	dcSample	TYPE_PCM, PowerTom, 16766			; $BD	- Power Tom
dacBE:	dcSample	TYPE_PCM, WoodBlock, 10420			; $BE	- Hi-Wood Block
dacBF:	dcSample	TYPE_PCM, WoodBlock, 7998			; $BF	- Low-Wood Block
dacC0:	dcSample	TYPE_PCM, HitDrum, 14176			; $C0	- Hi-Hit Drum
dacC1:	dcSample	TYPE_PCM, HitDrum, 9687				; $C1	- Low-Hit Drum
dacC2:	dcSample	TYPE_PCM, MetalCrashHit, 7998			; $C2	- Metal Crash Hit
dacC3:	dcSample	TYPE_PCM, EchoedClapHit, 8492			; $C3	- Echoed Clap Hit
dacC4:	dcSample	TYPE_PCM, EchoedClapHit, 6520			; $C4	- Lower Echoed Clap Hit
dacC5:	dcSample	TYPE_PCM, HipHopHitKick, 12279			; $C5	- HipHop Hit Kick
dacC6:	dcSample	TYPE_PCM, HipHopPowerKick, 12279		; $C6	- HipHop Hit Power Kick
dacC7:	dcSample	TYPE_PCM, BassHey, 12279			; $C7	- Bass + "Hey!"
dacC8:	dcSample	TYPE_PCM, DanceStyleKick, 7998			; $C8	- Dance-Style Kick
dacC9:	dcSample	TYPE_PCM, HipHopHitKick2, 12279			; $C9	- HipHop Hit Kick 2
dacCA:	dcSample	TYPE_PCM, RevFadingWind, 7998			; $CA	- Reverse Fading Wind
dacCB:	dcSample	TYPE_PCM, ScratchS3, 7998			; $CB	- Scratch (S3)
dacCC:	dcSample	TYPE_PCM, LooseSnareNoise, 7998			; $CC	- Loose-Snare Noise
dacCD:	dcSample	TYPE_PCM, PowerKick2, 12279			; $CD	- Power Kick 2
dacCE:	dcSample	TYPE_PCM, CrashNoiseWoo, 12279			; $CE	- Crash Noise + "Woo!"
dacCF:	dcSample	TYPE_PCM, QuickHit, 7166			; $CF	- Quick Hit
dacD0:	dcSample	TYPE_PCM, KickHey, 12852			; $D0	- Kick (S3) + "Hey!"
dacD1:	dcSample	TYPE_PCM, HipHopHitKick, 10830			; $D1	- Power Kick Hit
dacD2:	dcSample	TYPE_PCM, HipHopHitKick, 10040			; $D2	- Low Power Kick Hit
dacD3:	dcSample	TYPE_PCM, HipHopHitKick, 9687			; $D3	- Lower Power Kick Hit
dacD4:	dcSample	TYPE_PCM, HipHopHitKick, 12852			; $D4	- Lowest Power Kick Hit
	endif

	if SMPS_S3DDACSamples
			; Sonic 3D
dacD5:	dcSample	TYPE_PCM, MetalCrashS3D, 24104			; $D5	- Final Fight Metal Crash
dacD6:	dcSample	TYPE_PCM, MetalCrashS3D, 9687			; $D6	- Intro Kick
	endif

	if SMPS_S3DACSamples
			; Sonic 3
dacD7:	dcSample	TYPE_PCM, EchoedClapHitS3, 8492			; $D7	- Echoed Clap Hit (S3)
dacD8:	dcSample	TYPE_PCM, EchoedClapHitS3, 6490			; $D8	- Lower Echoed Clap Hit(S3)	; Clownacy | Good golly, we're close to reaching Mega PCM's limit...
	endif

	if SMPS_SCDACSamples
			; Sonic Crackers
dacD9:	dcSample	TYPE_PCM, Beat, 4728				; $D9	- Beat
dacDA:	dcSample	TYPE_PCM, SnareSC, 13610			; $DA	- Snare (SC)
dacDB:	dcSample	TYPE_PCM, TimTom, 13610				; $DB	- Hi Timpani/Tom (SC)
dacDC:	dcSample	TYPE_PCM, TimTom, 11363				; $DC	- Mid Timpani/Tom (SC)
dacDD:	dcSample	TYPE_PCM, TimTom, 10497				; $DD	- Low Timpani/Tom (SC)
dacDE:	dcSample	TYPE_PCM, LetsGo, 13610				; $DE	- "Let's Go!"
dacDF:	dcSample	TYPE_PCM, Hey, 13610				; $DF	- "Hey!"	; Clownacy | X_X Extending the DAC range is going to take some creativity...
	endif

dacE0:	dcSample	TYPE_PCM, SegaPCM, 16000, FLAGS_SFX		; $E0	- Sega!
			dc.w -1						; end marker
