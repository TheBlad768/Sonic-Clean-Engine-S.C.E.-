; ---------------------------------------------------------------
; DAC Samples Files
; ---------------------------------------------------------------

;			| Filename	| Extension	| Folder (if any)
	IncludeDAC	SegaPCM,	snd

    if SMPS_S1DACSamples||SMPS_S2DACSamples
	IncludeDAC	Kick,		dpcm,		Sonic 1 & 2
	IncludeDAC	Snare,		dpcm,		Sonic 1 & 2
	IncludeDAC	Timpani,	dpcm,		Sonic 1 & 2
    endif

    if SMPS_S2DACSamples
	IncludeDAC	Clap,		dpcm,		Sonic 1 & 2
	IncludeDAC	Scratch,	dpcm,		Sonic 1 & 2
	IncludeDAC	Tom,		dpcm,		Sonic 1 & 2
	IncludeDAC	Bongo,		dpcm,		Sonic 1 & 2
    endif

    if SMPS_S3DACSamples||SMPS_SKDACSamples||SMPS_S3DDACSamples
	IncludeDAC	SnareS3,	dpcm,		Sonic 3 & K & 3D
	IncludeDAC	TomS3,		dpcm,		Sonic 3 & K & 3D
	IncludeDAC	KickS3,		dpcm,		Sonic 3 & K & 3D
	IncludeDAC	MuffledSnare,	dpcm,		Sonic 3 & K & 3D
	IncludeDAC	CrashCymbal,	dpcm,		Sonic 3 & K & 3D
	IncludeDAC	RideCymbal,	dpcm,		Sonic 3 & K & 3D
	IncludeDAC	MetalHit,	dpcm,		Sonic 3 & K & 3D
	IncludeDAC	MetalHit2,	dpcm,		Sonic 3 & K & 3D
	IncludeDAC	MetalHit3,	dpcm,		Sonic 3 & K & 3D
	IncludeDAC	ClapS3,		dpcm,		Sonic 3 & K & 3D
	IncludeDAC	ElectricTom,	dpcm,		Sonic 3 & K & 3D
	IncludeDAC	SnareS32,	dpcm,		Sonic 3 & K & 3D
	IncludeDAC	TimpaniS3,	dpcm,		Sonic 3 & K & 3D
	IncludeDAC	SnareS33,	dpcm,		Sonic 3 & K & 3D
	IncludeDAC	Click,		dpcm,		Sonic 3 & K & 3D
	IncludeDAC	PowerKick,	dpcm,		Sonic 3 & K & 3D
	IncludeDAC	QuickGlassCrash,dpcm,		Sonic 3 & K & 3D
    endif

    if SMPS_S3DACSamples||SMPS_SKDACSamples
	IncludeDAC	GlassCrashSnare,dpcm,		Sonic 3 & K & 3D
	IncludeDAC	GlassCrash,	dpcm,		Sonic 3 & K & 3D
	IncludeDAC	GlassCrashKick,	dpcm,		Sonic 3 & K & 3D
	IncludeDAC	QuietGlassCrash,dpcm,		Sonic 3 & K & 3D
	IncludeDAC	SnareKick,	dpcm,		Sonic 3 & K & 3D
	IncludeDAC	KickBass,	dpcm,		Sonic 3 & K & 3D
	IncludeDAC	ComeOn,		dpcm,		Sonic 3 & K & 3D
	IncludeDAC	DanceSnare,	dpcm,		Sonic 3 & K & 3D
	IncludeDAC	LooseKick,	dpcm,		Sonic 3 & K & 3D
	IncludeDAC	LooseKick2,	dpcm,		Sonic 3 & K & 3D
	IncludeDAC	Woo,		dpcm,		Sonic 3 & K & 3D
	IncludeDAC	Go,		dpcm,		Sonic 3 & K & 3D
	IncludeDAC	SnareGo,	dpcm,		Sonic 3 & K & 3D
	IncludeDAC	PowerTom,	dpcm,		Sonic 3 & K & 3D
	IncludeDAC	WoodBlock,	dpcm,		Sonic 3 & K & 3D
	IncludeDAC	HitDrum,	dpcm,		Sonic 3 & K & 3D
	IncludeDAC	MetalCrashHit,	dpcm,		Sonic 3 & K & 3D
	IncludeDAC	EchoedClapHit,	dpcm,		Sonic 3 & K & 3D
	IncludeDAC	HipHopHitKick,	dpcm,		Sonic 3 & K & 3D
	IncludeDAC	HipHopPowerKick,dpcm,		Sonic 3 & K & 3D
	IncludeDAC	BassHey,	dpcm,		Sonic 3 & K & 3D
	IncludeDAC	DanceStyleKick,	dpcm,		Sonic 3 & K & 3D
	IncludeDAC	HipHopHitKick2,	dpcm,		Sonic 3 & K & 3D
	IncludeDAC	RevFadingWind,	dpcm,		Sonic 3 & K & 3D
	IncludeDAC	ScratchS3,	dpcm,		Sonic 3 & K & 3D
	IncludeDAC	LooseSnareNoise,dpcm,		Sonic 3 & K & 3D
	IncludeDAC	PowerKick2,	dpcm,		Sonic 3 & K & 3D
	IncludeDAC	CrashNoiseWoo,	dpcm,		Sonic 3 & K & 3D
	IncludeDAC	QuickHit,	dpcm,		Sonic 3 & K & 3D
	IncludeDAC	KickHey,	dpcm,		Sonic 3 & K & 3D
    endif

    if SMPS_S3DDACSamples
	IncludeDAC	MetalCrashS3D,	dpcm,		Sonic 3 & K & 3D
	IncludeDAC	IntroKickS3D,	dpcm,		Sonic 3 & K & 3D
    endif

    if SMPS_S3DACSamples
	IncludeDAC	EchoedClapHitS3,dpcm,		Sonic 3 & K & 3D
    endif

    if SMPS_SCDACSamples
	IncludeDAC	Beat,		dpcm,		Sonic Crackers
	IncludeDAC	SnareSC,	dpcm,		Sonic Crackers
	IncludeDAC	TimTom,		dpcm,		Sonic Crackers
	IncludeDAC	LetsGo,		dpcm,		Sonic Crackers
	IncludeDAC	Hey,		dpcm,		Sonic Crackers
    endif
	even
