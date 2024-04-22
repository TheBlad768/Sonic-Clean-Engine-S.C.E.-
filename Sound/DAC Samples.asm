; ---------------------------------------------------------------
; DAC Samples Files
; ---------------------------------------------------------------

;			| Filename	| Folder
		incdac	SegaPCM, "Sound/DAC/SegaPCM.snd"

    if SMPS_S1DACSamples||SMPS_S2DACSamples
		incdac	Kick, "Sound/DAC/Sonic 1 & 2/Kick.snd"
		incdac	Snare, "Sound/DAC/Sonic 1 & 2/Snare.snd"
		incdac	Timpani, "Sound/DAC/Sonic 1 & 2/Timpani.snd"
    endif

    if SMPS_S2DACSamples
		incdac	Clap, "Sound/DAC/Sonic 1 & 2/Clap.snd"
		incdac	Scratch, "Sound/DAC/Sonic 1 & 2/Scratch.snd"
		incdac	Tom, "Sound/DAC/Sonic 1 & 2/Tom.snd"
		incdac	Bongo, "Sound/DAC/Sonic 1 & 2/Bongo.snd"
    endif

    if SMPS_S3DACSamples||SMPS_SKDACSamples||SMPS_S3DDACSamples
		incdac	SnareS3, "Sound/DAC/Sonic 3 & K & 3D/SnareS3.snd"
		incdac	TomS3, "Sound/DAC/Sonic 3 & K & 3D/TomS3.snd"
		incdac	KickS3, "Sound/DAC/Sonic 3 & K & 3D/KickS3.snd"
		incdac	MuffledSnare, "Sound/DAC/Sonic 3 & K & 3D/MuffledSnare.snd"
		incdac	CrashCymbal, "Sound/DAC/Sonic 3 & K & 3D/CrashCymbal.snd"
		incdac	RideCymbal, "Sound/DAC/Sonic 3 & K & 3D/RideCymbal.snd"
		incdac	MetalHit, "Sound/DAC/Sonic 3 & K & 3D/MetalHit.snd"
		incdac	MetalHit2, "Sound/DAC/Sonic 3 & K & 3D/MetalHit2.snd"
		incdac	MetalHit3, "Sound/DAC/Sonic 3 & K & 3D/MetalHit3.snd"
		incdac	ClapS3, "Sound/DAC/Sonic 3 & K & 3D/ClapS3.snd"
		incdac	ElectricTom, "Sound/DAC/Sonic 3 & K & 3D/ElectricTom.snd"
		incdac	SnareS32, "Sound/DAC/Sonic 3 & K & 3D/SnareS32.snd"
		incdac	TimpaniS3, "Sound/DAC/Sonic 3 & K & 3D/TimpaniS3.snd"
		incdac	SnareS33, "Sound/DAC/Sonic 3 & K & 3D/SnareS33.snd"
		incdac	Click, "Sound/DAC/Sonic 3 & K & 3D/Click.snd"
		incdac	PowerKick, "Sound/DAC/Sonic 3 & K & 3D/PowerKick.snd"
		incdac	QuickGlassCrash, "Sound/DAC/Sonic 3 & K & 3D/QuickGlassCrash.snd"
    endif

    if SMPS_S3DACSamples||SMPS_SKDACSamples
		incdac	GlassCrashSnare, "Sound/DAC/Sonic 3 & K & 3D/GlassCrashSnare.snd"
		incdac	GlassCrash, "Sound/DAC/Sonic 3 & K & 3D/GlassCrash.snd"
		incdac	GlassCrashKick, "Sound/DAC/Sonic 3 & K & 3D/GlassCrashKick.snd"
		incdac	QuietGlassCrash, "Sound/DAC/Sonic 3 & K & 3D/QuietGlassCrash.snd"
		incdac	SnareKick, "Sound/DAC/Sonic 3 & K & 3D/SnareKick.snd"
		incdac	KickBass, "Sound/DAC/Sonic 3 & K & 3D/KickBass.snd"
		incdac	ComeOn, "Sound/DAC/Sonic 3 & K & 3D/ComeOn.snd"
		incdac	DanceSnare, "Sound/DAC/Sonic 3 & K & 3D/DanceSnare.snd"
		incdac	LooseKick, "Sound/DAC/Sonic 3 & K & 3D/LooseKick.snd"
		incdac	LooseKick2, "Sound/DAC/Sonic 3 & K & 3D/LooseKick2.snd"
		incdac	Woo, "Sound/DAC/Sonic 3 & K & 3D/Woo.snd"
		incdac	Go, "Sound/DAC/Sonic 3 & K & 3D/Go.snd"
		incdac	SnareGo, "Sound/DAC/Sonic 3 & K & 3D/SnareGo.snd"
		incdac	PowerTom, "Sound/DAC/Sonic 3 & K & 3D/PowerTom.snd"
		incdac	WoodBlock, "Sound/DAC/Sonic 3 & K & 3D/WoodBlock.snd"
		incdac	HitDrum, "Sound/DAC/Sonic 3 & K & 3D/HitDrum.snd"
		incdac	MetalCrashHit, "Sound/DAC/Sonic 3 & K & 3D/MetalCrashHit.snd"
		incdac	EchoedClapHit, "Sound/DAC/Sonic 3 & K & 3D/EchoedClapHit.snd"
		incdac	HipHopHitKick, "Sound/DAC/Sonic 3 & K & 3D/HipHopHitKick.snd"
		incdac	HipHopPowerKick, "Sound/DAC/Sonic 3 & K & 3D/HipHopPowerKick.snd"
		incdac	BassHey, "Sound/DAC/Sonic 3 & K & 3D/BassHey.snd"
		incdac	DanceStyleKick, "Sound/DAC/Sonic 3 & K & 3D/DanceStyleKick.snd"
		incdac	HipHopHitKick2, "Sound/DAC/Sonic 3 & K & 3D/HipHopHitKick2.snd"
		incdac	RevFadingWind, "Sound/DAC/Sonic 3 & K & 3D/RevFadingWind.snd"
		incdac	ScratchS3, "Sound/DAC/Sonic 3 & K & 3D/ScratchS3.snd"
		incdac	LooseSnareNoise, "Sound/DAC/Sonic 3 & K & 3D/LooseSnareNoise.snd"
		incdac	PowerKick2, "Sound/DAC/Sonic 3 & K & 3D/PowerKick2.snd"
		incdac	CrashNoiseWoo, "Sound/DAC/Sonic 3 & K & 3D/CrashNoiseWoo.snd"
		incdac	QuickHit, "Sound/DAC/Sonic 3 & K & 3D/QuickHit.snd"
		incdac	KickHey, "Sound/DAC/Sonic 3 & K & 3D/KickHey.snd"
    endif

    if SMPS_S3DDACSamples
		incdac	MetalCrashS3D, "Sound/DAC/Sonic 3 & K & 3D/MetalCrashS3D.snd"
		incdac	IntroKickS3D, "Sound/DAC/Sonic 3 & K & 3D/IntroKickS3D.snd"
    endif

    if SMPS_S3DACSamples
		incdac	EchoedClapHitS3, "Sound/DAC/Sonic 3 & K & 3D/EchoedClapHitS3.snd"
    endif

    if SMPS_SCDACSamples
		incdac	Beat, "Sound/DAC/Sonic Crackers/Beat.snd"
		incdac	SnareSC, "Sound/DAC/Sonic Crackers/SnareSC.snd"
		incdac	TimTom, "Sound/DAC/Sonic Crackers/TimTom.snd"
		incdac	LetsGo, "Sound/DAC/Sonic Crackers/LetsGo.snd"
		incdac	Hey, "Sound/DAC/Sonic Crackers/Hey.snd"
    endif
	even
