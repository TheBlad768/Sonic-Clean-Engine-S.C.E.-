; ---------------------------------------------------------------
; DAC Samples Table
; ---------------------------------------------------------------

MegaPCM_DAC_Table:
	if SMPS_S1DACSamples||SMPS_S2DACSamples
		; Sonic 1 & 2
ptr_dac81:	DAC_Entry	 8201, Kick,				MegaPCM_pcm	; $81	- Kick
ptr_dac82:	DAC_Entry	23784, Snare,				MegaPCM_pcm	; $82	- Snare
ptr_dac85:	DAC_Entry	 7328, Timpani,			MegaPCM_pcm	; $85	- Timpani
ptr_dac88:	DAC_Entry	 9635, Timpani,			MegaPCM_pcm	; $88	- Hi-Timpani
ptr_dac89:	DAC_Entry	 8720, Timpani,			MegaPCM_pcm	; $89	- Mid-Timpani
ptr_dac8A:	DAC_Entry	 7138, Timpani,			MegaPCM_pcm	; $8A	- Low-Timpani
ptr_dac8B:	DAC_Entry	 6957, Timpani,			MegaPCM_pcm	; $8B	- Very Low-Timpani
	endif

	if SMPS_S2DACSamples
		; Sonic 2
ptr_dac83:	DAC_Entry	17127, Clap,				MegaPCM_pcm	; $83	- Clap
ptr_dac84:	DAC_Entry	15232, Scratch,			MegaPCM_pcm	; $84	- Scratch
ptr_dac86:	DAC_Entry	13714, Tom,				MegaPCM_pcm	; $86	- Hi-Tom
ptr_dac87:	DAC_Entry	 7426, Bongo,				MegaPCM_pcm	; $87	- Very Low-Bongo
ptr_dac8C:	DAC_Entry	22799, Tom,				MegaPCM_pcm	; $8C	- Mid-Tom
ptr_dac8D:	DAC_Entry	18262, Tom,				MegaPCM_pcm	; $8D	- Low-Tom
ptr_dac8E:	DAC_Entry	15232, Tom,				MegaPCM_pcm	; $8E	- Floor-Tom
ptr_dac8F:	DAC_Entry	15232, Bongo,				MegaPCM_pcm	; $8F	- Hi-Bongo
ptr_dac90:	DAC_Entry	13064, Bongo,			MegaPCM_pcm	; $90	- Mid-Bongo
ptr_dac91:	DAC_Entry	 9806, Bongo,				MegaPCM_pcm	; $91	- Low-Bongo
	endif

	if SMPS_S3DACSamples||SMPS_SKDACSamples||SMPS_S3DDACSamples
		; Sonic 3 & K & 3D
ptr_dac92:	DAC_Entry	19090, SnareS3,			MegaPCM_pcm	; $92	- Snare (S3)
ptr_dac93:	DAC_Entry	11274, TomS3,			MegaPCM_pcm	; $93	- Hi-Tom (S3)
ptr_dac94:	DAC_Entry	 9050, TomS3,			MegaPCM_pcm	; $94	- Mid-Tom (S3)
ptr_dac95:	DAC_Entry	 7599, TomS3,			MegaPCM_pcm	; $95	- Low Tom (S3)
ptr_dac96:	DAC_Entry	 6490, TomS3,			MegaPCM_pcm	; $96	- Floor-Tom (S3)
ptr_dac97:	DAC_Entry	19090, KickS3,			MegaPCM_pcm	; $97	- Kick (S3)
ptr_dac98:	DAC_Entry	19090, MuffledSnare,		MegaPCM_pcm	; $98	- Muffled Snare
ptr_dac99:	DAC_Entry	16766, CrashCymbal,		MegaPCM_pcm	; $99	- Crash Cymbal 
ptr_dac9A:	DAC_Entry	13482, RideCymbal,		MegaPCM_pcm	; $9A	- Ride Cymbal
ptr_dac9B:	DAC_Entry	 9050, MetalHit,			MegaPCM_pcm	; $9B	- Low-Metal Hit
ptr_dac9C:	DAC_Entry	 7357, MetalHit,			MegaPCM_pcm	; $9C	- Metal Hit
ptr_dac9D:	DAC_Entry	14945, MetalHit2,			MegaPCM_pcm	; $9D	- High-Metal Hit
ptr_dac9E:	DAC_Entry	12852, MetalHit3,			MegaPCM_pcm	; $9E	- Higher-Metal Hit
ptr_dac9F:	DAC_Entry	10040, MetalHit3,			MegaPCM_pcm	; $9F	- Mid-Metal Hit
ptr_dacA0:	DAC_Entry	14945, ClapS3,			MegaPCM_pcm	; $A0	- Clap (S3)
ptr_dacA1:	DAC_Entry	20513, ElectricTom,		MegaPCM_pcm	; $A1	- Electric High-Tom
ptr_dacA2:	DAC_Entry	15803, ElectricTom,		MegaPCM_pcm	; $A2	- Electric Mid-Tom
ptr_dacA3:	DAC_Entry	13482, ElectricTom,		MegaPCM_pcm	; $A3	- Electric Low-Tom
ptr_dacA4:	DAC_Entry	11274, ElectricTom,		MegaPCM_pcm	; $A4	- Electric Floor-Tom
ptr_dacA5:	DAC_Entry	16766, SnareS32,			MegaPCM_pcm	; $A5	- Mid-Pitch Snare
ptr_dacA6:	DAC_Entry	13482, SnareS32,			MegaPCM_pcm	; $A6	- Tight Snare
ptr_dacA7:	DAC_Entry	11755, SnareS32,			MegaPCM_pcm	; $A7	- Loose Snare
ptr_dacA8:	DAC_Entry	 9687, SnareS32,			MegaPCM_pcm	; $A8	- Looser Snare
ptr_dacA9:	DAC_Entry	12852, TimpaniS3,		MegaPCM_pcm	; $A9	- Hi-Timpani (S3)
ptr_dacAA:	DAC_Entry	 9358, TimpaniS3,			MegaPCM_pcm	; $AA	- Low-Timpani (S3)
ptr_dacAB:	DAC_Entry	 8492, TimpaniS3,			MegaPCM_pcm	; $AB	- Mid-Timpani (S3)
ptr_dacAC:	DAC_Entry	12279, SnareS33,			MegaPCM_pcm	; $AC	- Quick Loose Snare
ptr_dacAD:	DAC_Entry	13482, Click,				MegaPCM_pcm	; $AD	- Click
ptr_dacAE:	DAC_Entry	 7998, PowerKick,			MegaPCM_pcm	; $AE	- Power Kick
ptr_dacAF:	DAC_Entry	 7998, QuickGlassCrash,	MegaPCM_pcm	; $AF	- Quick Glass Crash
	endif

	if SMPS_S3DACSamples||SMPS_SKDACSamples
		; Sonic 3 & K
ptr_dacB0:	DAC_Entry	12279, GlassCrashSnare,	MegaPCM_pcm	; $B0	- Glass Crash Snare
ptr_dacB1:	DAC_Entry	12279, GlassCrash,		MegaPCM_pcm	; $B1	- Glass Crash
ptr_dacB2:	DAC_Entry	13482, GlassCrashKick,		MegaPCM_pcm	; $B2	- Glass Crash Kick
ptr_dacB3:	DAC_Entry	13482, QuietGlassCrash,	MegaPCM_pcm	; $B3	- Quiet Glass Crash
ptr_dacB4:	DAC_Entry	 7998, SnareKick,			MegaPCM_pcm	; $B4	- Snare + Kick
ptr_dacB5:	DAC_Entry	 7998, KickBass,			MegaPCM_pcm	; $B5	- Bassy Kick
ptr_dacB6:	DAC_Entry	12279, ComeOn,			MegaPCM_pcm	; $B6	- "Come On!"
ptr_dacB7:	DAC_Entry	14176, DanceSnare,		MegaPCM_pcm	; $B7	- Dance Snare
ptr_dacB8:	DAC_Entry	 7998, LooseKick,			MegaPCM_pcm	; $B8	- Loose Kick
ptr_dacB9:	DAC_Entry	 7998, LooseKick2,		MegaPCM_pcm	; $B9	- Mod Loose Kick
ptr_dacBA:	DAC_Entry	12279, Woo,				MegaPCM_pcm	; $BA	- "Woo!"
ptr_dacBB:	DAC_Entry	13482, Go,				MegaPCM_pcm	; $BB	- "Go!"
ptr_dacBC:	DAC_Entry	11755, SnareGo,			MegaPCM_pcm	; $BC	- Snare (S3) + "Go!"
ptr_dacBD:	DAC_Entry	16766, PowerTom,			MegaPCM_pcm	; $BD	- Power Tom
ptr_dacBE:	DAC_Entry	10420, WoodBlock,		MegaPCM_pcm	; $BE	- Hi-Wood Block
ptr_dacBF:	DAC_Entry	 7998, WoodBlock,			MegaPCM_pcm	; $BF	- Low-Wood Block
ptr_dacC0:	DAC_Entry	14176, HitDrum,			MegaPCM_pcm	; $C0	- Hi-Hit Drum
ptr_dacC1:	DAC_Entry	 9687, HitDrum,			MegaPCM_pcm	; $C1	- Low-Hit Drum
ptr_dacC2:	DAC_Entry	 7998, MetalCrashHit,		MegaPCM_pcm	; $C2	- Metal Crash Hit
ptr_dacC3:	DAC_Entry	 8492, EchoedClapHit,		MegaPCM_pcm	; $C3	- Echoed Clap Hit
ptr_dacC4:	DAC_Entry	 6520, EchoedClapHit,		MegaPCM_pcm	; $C4	- Lower Echoed Clap Hit
ptr_dacC5:	DAC_Entry	12279, HipHopHitKick,	MegaPCM_pcm	; $C5	- HipHop Hit Kick
ptr_dacC6:	DAC_Entry	12279, HipHopPowerKick,	MegaPCM_pcm	; $C6	- HipHop Hit Power Kick
ptr_dacC7:	DAC_Entry	12279, BassHey,			MegaPCM_pcm	; $C7	- Bass + "Hey!"
ptr_dacC8:	DAC_Entry	 7998, DanceStyleKick,		MegaPCM_pcm	; $C8	- Dance-Style Kick
ptr_dacC9:	DAC_Entry	12279, HipHopHitKick2,	MegaPCM_pcm	; $C9	- HipHop Hit Kick 2
ptr_dacCA:	DAC_Entry	 7998, RevFadingWind,	MegaPCM_pcm	; $CA	- Reverse Fading Wind
ptr_dacCB:	DAC_Entry	 7998, ScratchS3,			MegaPCM_pcm	; $CB	- Scratch (S3)
ptr_dacCC:	DAC_Entry	 7998, LooseSnareNoise,	MegaPCM_pcm	; $CC	- Loose-Snare Noise
ptr_dacCD:	DAC_Entry	12279, PowerKick2,		MegaPCM_pcm	; $CD	- Power Kick 2
ptr_dacCE:	DAC_Entry	12279, CrashNoiseWoo,	MegaPCM_pcm	; $CE	- Crash Noise + "Woo!"
ptr_dacCF:	DAC_Entry	 7166, QuickHit,			MegaPCM_pcm	; $CF	- Quick Hit
ptr_dacD0:	DAC_Entry	12852, KickHey,			MegaPCM_pcm	; $D0	- Kick (S3) + "Hey!"
ptr_dacD1:	DAC_Entry	10830, HipHopHitKick,	MegaPCM_pcm	; $D1	- Power Kick Hit
ptr_dacD2:	DAC_Entry	10040, HipHopHitKick,	MegaPCM_pcm	; $D2	- Low Power Kick Hit
ptr_dacD3:	DAC_Entry	 9687, HipHopHitKick,		MegaPCM_pcm	; $D3	- Lower Power Kick Hit
ptr_dacD4:	DAC_Entry	12852, HipHopHitKick,	MegaPCM_pcm	; $D4	- Lowest Power Kick Hit
	endif

	if SMPS_S3DDACSamples
		; Sonic 3D
ptr_dacD5:	DAC_Entry	24104, MetalCrashS3D,	MegaPCM_pcm	; $D5	- Final Fight Metal Crash
ptr_dacD6:	DAC_Entry	 9687, IntroKickS3D,		MegaPCM_pcm	; $D6	- Intro Kick
	endif

	if SMPS_S3DACSamples
		; Sonic 3
ptr_dacD7:	DAC_Entry	 8492, EchoedClapHitS3,	MegaPCM_pcm	; $D7	- Echoed Clap Hit (S3)
ptr_dacD8:	DAC_Entry	 6490, EchoedClapHitS3,	MegaPCM_pcm	; $D8	- Lower Echoed Clap Hit(S3)	; Clownacy | Good golly, we're close to reaching Mega PCM's limit...
	endif

	if SMPS_SCDACSamples
		; Sonic Crackers
ptr_dacD9:	DAC_Entry	 4728, Beat,				MegaPCM_pcm	; $D9	- Beat
ptr_dacDA:	DAC_Entry	13610, SnareSC,			MegaPCM_pcm	; $DA	- Snare (SC)
ptr_dacDB:	DAC_Entry	13610, TimTom,			MegaPCM_pcm	; $DB	- Hi Timpani/Tom (SC)
ptr_dacDC:	DAC_Entry	11363, TimTom,			MegaPCM_pcm	; $DC	- Mid Timpani/Tom (SC)
ptr_dacDD:	DAC_Entry	10497, TimTom,			MegaPCM_pcm	; $DD	- Low Timpani/Tom (SC)
ptr_dacDE:	DAC_Entry	13610, LetsGo,			MegaPCM_pcm	; $DE	- "Let's Go!"
ptr_dacDF:	DAC_Entry	13610, Hey,				MegaPCM_pcm	; $DF	- "Hey!"	; Clownacy | X_X Extending the DAC range is going to take some creativity...
	endif

ptr_dacE0:	DAC_Entry2	0Bh, SegaPCM,			MegaPCM_pcm|MegaPCM_panLR	; $E0	- Sega!
