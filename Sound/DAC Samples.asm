; ---------------------------------------------------------------
; DAC Samples Files
; ---------------------------------------------------------------

;			| Filename	| Extension	| Folder (if any)
	IncludeDAC	SegaPCM,	snd

    if SMPS_S1DACSamples||SMPS_S2DACSamples
	IncludeDAC	Kick,		snd,		Sonic 1 & 2
	IncludeDAC	Snare,		snd,		Sonic 1 & 2
	IncludeDAC	Timpani,	snd,		Sonic 1 & 2
    endif

    if SMPS_S2DACSamples
	IncludeDAC	Clap,		snd,		Sonic 1 & 2
	IncludeDAC	Scratch,	snd,		Sonic 1 & 2
	IncludeDAC	Tom,		snd,		Sonic 1 & 2
	IncludeDAC	Bongo,		snd,		Sonic 1 & 2
    endif

    if SMPS_S3DACSamples||SMPS_SKDACSamples||SMPS_S3DDACSamples
	IncludeDAC	SnareS3,	snd,		Sonic 3 & K & 3D
	IncludeDAC	TomS3,		snd,		Sonic 3 & K & 3D
	IncludeDAC	KickS3,		snd,		Sonic 3 & K & 3D
	IncludeDAC	MuffledSnare,	snd,		Sonic 3 & K & 3D
	IncludeDAC	CrashCymbal,	snd,		Sonic 3 & K & 3D
	IncludeDAC	RideCymbal,	snd,		Sonic 3 & K & 3D
	IncludeDAC	MetalHit,	snd,		Sonic 3 & K & 3D
	IncludeDAC	MetalHit2,	snd,		Sonic 3 & K & 3D
	IncludeDAC	MetalHit3,	snd,		Sonic 3 & K & 3D
	IncludeDAC	ClapS3,		snd,		Sonic 3 & K & 3D
	IncludeDAC	ElectricTom,	snd,		Sonic 3 & K & 3D
	IncludeDAC	SnareS32,	snd,		Sonic 3 & K & 3D
	IncludeDAC	TimpaniS3,	snd,		Sonic 3 & K & 3D
	IncludeDAC	SnareS33,	snd,		Sonic 3 & K & 3D
	IncludeDAC	Click,		snd,		Sonic 3 & K & 3D
	IncludeDAC	PowerKick,	snd,		Sonic 3 & K & 3D
	IncludeDAC	QuickGlassCrash,snd,		Sonic 3 & K & 3D
    endif

    if SMPS_S3DACSamples||SMPS_SKDACSamples
	IncludeDAC	GlassCrashSnare,snd,		Sonic 3 & K & 3D
	IncludeDAC	GlassCrash,	snd,		Sonic 3 & K & 3D
	IncludeDAC	GlassCrashKick,	snd,		Sonic 3 & K & 3D
	IncludeDAC	QuietGlassCrash,snd,		Sonic 3 & K & 3D
	IncludeDAC	SnareKick,	snd,		Sonic 3 & K & 3D
	IncludeDAC	KickBass,	snd,		Sonic 3 & K & 3D
	IncludeDAC	ComeOn,		snd,		Sonic 3 & K & 3D
	IncludeDAC	DanceSnare,	snd,		Sonic 3 & K & 3D
	IncludeDAC	LooseKick,	snd,		Sonic 3 & K & 3D
	IncludeDAC	LooseKick2,	snd,		Sonic 3 & K & 3D
	IncludeDAC	Woo,		snd,		Sonic 3 & K & 3D
	IncludeDAC	Go,		snd,		Sonic 3 & K & 3D
	IncludeDAC	SnareGo,	snd,		Sonic 3 & K & 3D
	IncludeDAC	PowerTom,	snd,		Sonic 3 & K & 3D
	IncludeDAC	WoodBlock,	snd,		Sonic 3 & K & 3D
	IncludeDAC	HitDrum,	snd,		Sonic 3 & K & 3D
	IncludeDAC	MetalCrashHit,	snd,		Sonic 3 & K & 3D
	IncludeDAC	EchoedClapHit,	snd,		Sonic 3 & K & 3D
	IncludeDAC	HipHopHitKick,	snd,		Sonic 3 & K & 3D
	IncludeDAC	HipHopPowerKick,snd,		Sonic 3 & K & 3D
	IncludeDAC	BassHey,	snd,		Sonic 3 & K & 3D
	IncludeDAC	DanceStyleKick,	snd,		Sonic 3 & K & 3D
	IncludeDAC	HipHopHitKick2,	snd,		Sonic 3 & K & 3D
	IncludeDAC	RevFadingWind,	snd,		Sonic 3 & K & 3D
	IncludeDAC	ScratchS3,	snd,		Sonic 3 & K & 3D
	IncludeDAC	LooseSnareNoise,snd,		Sonic 3 & K & 3D
	IncludeDAC	PowerKick2,	snd,		Sonic 3 & K & 3D
	IncludeDAC	CrashNoiseWoo,	snd,		Sonic 3 & K & 3D
	IncludeDAC	QuickHit,	snd,		Sonic 3 & K & 3D
	IncludeDAC	KickHey,	snd,		Sonic 3 & K & 3D
    endif

    if SMPS_S3DDACSamples
	IncludeDAC	MetalCrashS3D,	snd,		Sonic 3 & K & 3D
	IncludeDAC	IntroKickS3D,	snd,		Sonic 3 & K & 3D
    endif

    if SMPS_S3DACSamples
	IncludeDAC	EchoedClapHitS3,snd,		Sonic 3 & K & 3D
    endif

    if SMPS_SCDACSamples
	IncludeDAC	Beat,		snd,		Sonic Crackers
	IncludeDAC	SnareSC,	snd,		Sonic Crackers
	IncludeDAC	TimTom,		snd,		Sonic Crackers
	IncludeDAC	LetsGo,		snd,		Sonic Crackers
	IncludeDAC	Hey,		snd,		Sonic Crackers
    endif
	even
