; ---------------------------------------------------------------
; DAC Samples Files
; ---------------------------------------------------------------

;			| Filename	| Folder
		incdac	SegaPCM, "Sound/DAC/SegaPCM.pcm"

    if SMPS_S1DACSamples||SMPS_S2DACSamples
		incdac	Kick, "Sound/DAC/Sonic 1 & 2/Kick.pcm"
		incdac	Snare, "Sound/DAC/Sonic 1 & 2/Snare.pcm"
		incdac	Timpani, "Sound/DAC/Sonic 1 & 2/Timpani.pcm"
    endif

    if SMPS_S2DACSamples
		incdac	Clap, "Sound/DAC/Sonic 1 & 2/Clap.pcm"
		incdac	Scratch, "Sound/DAC/Sonic 1 & 2/Scratch.pcm"
		incdac	Tom, "Sound/DAC/Sonic 1 & 2/Tom.pcm"
		incdac	Bongo, "Sound/DAC/Sonic 1 & 2/Bongo.pcm"
    endif

    if SMPS_S3DACSamples||SMPS_SKDACSamples||SMPS_S3DDACSamples
		incdac	SnareS3, "Sound/DAC/Sonic 3 & K & 3D/SnareS3.pcm"
		incdac	TomS3, "Sound/DAC/Sonic 3 & K & 3D/TomS3.pcm"
		incdac	KickS3, "Sound/DAC/Sonic 3 & K & 3D/KickS3.pcm"
		incdac	MuffledSnare, "Sound/DAC/Sonic 3 & K & 3D/MuffledSnare.pcm"
		incdac	CrashCymbal, "Sound/DAC/Sonic 3 & K & 3D/CrashCymbal.pcm"
		incdac	RideCymbal, "Sound/DAC/Sonic 3 & K & 3D/RideCymbal.pcm"
		incdac	MetalHit, "Sound/DAC/Sonic 3 & K & 3D/MetalHit.pcm"
		incdac	MetalHit2, "Sound/DAC/Sonic 3 & K & 3D/MetalHit2.pcm"
		incdac	MetalHit3, "Sound/DAC/Sonic 3 & K & 3D/MetalHit3.pcm"
		incdac	ClapS3, "Sound/DAC/Sonic 3 & K & 3D/ClapS3.pcm"
		incdac	ElectricTom, "Sound/DAC/Sonic 3 & K & 3D/ElectricTom.pcm"
		incdac	SnareS32, "Sound/DAC/Sonic 3 & K & 3D/SnareS32.pcm"
		incdac	TimpaniS3, "Sound/DAC/Sonic 3 & K & 3D/TimpaniS3.pcm"
		incdac	SnareS33, "Sound/DAC/Sonic 3 & K & 3D/SnareS33.pcm"
		incdac	Click, "Sound/DAC/Sonic 3 & K & 3D/Click.pcm"
		incdac	PowerKick, "Sound/DAC/Sonic 3 & K & 3D/PowerKick.pcm"
		incdac	QuickGlassCrash, "Sound/DAC/Sonic 3 & K & 3D/QuickGlassCrash.pcm"
    endif

    if SMPS_S3DACSamples||SMPS_SKDACSamples
		incdac	GlassCrashSnare, "Sound/DAC/Sonic 3 & K & 3D/GlassCrashSnare.pcm"
		incdac	GlassCrash, "Sound/DAC/Sonic 3 & K & 3D/GlassCrash.pcm"
		incdac	GlassCrashKick, "Sound/DAC/Sonic 3 & K & 3D/GlassCrashKick.pcm"
		incdac	QuietGlassCrash, "Sound/DAC/Sonic 3 & K & 3D/QuietGlassCrash.pcm"
		incdac	SnareKick, "Sound/DAC/Sonic 3 & K & 3D/SnareKick.pcm"
		incdac	KickBass, "Sound/DAC/Sonic 3 & K & 3D/KickBass.pcm"
		incdac	ComeOn, "Sound/DAC/Sonic 3 & K & 3D/ComeOn.pcm"
		incdac	DanceSnare, "Sound/DAC/Sonic 3 & K & 3D/DanceSnare.pcm"
		incdac	LooseKick, "Sound/DAC/Sonic 3 & K & 3D/LooseKick.pcm"
		incdac	LooseKick2, "Sound/DAC/Sonic 3 & K & 3D/LooseKick2.pcm"
		incdac	Woo, "Sound/DAC/Sonic 3 & K & 3D/Woo.pcm"
		incdac	Go, "Sound/DAC/Sonic 3 & K & 3D/Go.pcm"
		incdac	SnareGo, "Sound/DAC/Sonic 3 & K & 3D/SnareGo.pcm"
		incdac	PowerTom, "Sound/DAC/Sonic 3 & K & 3D/PowerTom.pcm"
		incdac	WoodBlock, "Sound/DAC/Sonic 3 & K & 3D/WoodBlock.pcm"
		incdac	HitDrum, "Sound/DAC/Sonic 3 & K & 3D/HitDrum.pcm"
		incdac	MetalCrashHit, "Sound/DAC/Sonic 3 & K & 3D/MetalCrashHit.pcm"
		incdac	EchoedClapHit, "Sound/DAC/Sonic 3 & K & 3D/EchoedClapHit.pcm"
		incdac	HipHopHitKick, "Sound/DAC/Sonic 3 & K & 3D/HipHopHitKick.pcm"
		incdac	HipHopPowerKick, "Sound/DAC/Sonic 3 & K & 3D/HipHopPowerKick.pcm"
		incdac	BassHey, "Sound/DAC/Sonic 3 & K & 3D/BassHey.pcm"
		incdac	DanceStyleKick, "Sound/DAC/Sonic 3 & K & 3D/DanceStyleKick.pcm"
		incdac	HipHopHitKick2, "Sound/DAC/Sonic 3 & K & 3D/HipHopHitKick2.pcm"
		incdac	RevFadingWind, "Sound/DAC/Sonic 3 & K & 3D/RevFadingWind.pcm"
		incdac	ScratchS3, "Sound/DAC/Sonic 3 & K & 3D/ScratchS3.pcm"
		incdac	LooseSnareNoise, "Sound/DAC/Sonic 3 & K & 3D/LooseSnareNoise.pcm"
		incdac	PowerKick2, "Sound/DAC/Sonic 3 & K & 3D/PowerKick2.pcm"
		incdac	CrashNoiseWoo, "Sound/DAC/Sonic 3 & K & 3D/CrashNoiseWoo.pcm"
		incdac	QuickHit, "Sound/DAC/Sonic 3 & K & 3D/QuickHit.pcm"
		incdac	KickHey, "Sound/DAC/Sonic 3 & K & 3D/KickHey.pcm"
    endif

    if SMPS_S3DDACSamples
		incdac	MetalCrashS3D, "Sound/DAC/Sonic 3 & K & 3D/MetalCrashS3D.pcm"
		incdac	IntroKickS3D, "Sound/DAC/Sonic 3 & K & 3D/IntroKickS3D.pcm"
    endif

    if SMPS_S3DACSamples
		incdac	EchoedClapHitS3, "Sound/DAC/Sonic 3 & K & 3D/EchoedClapHitS3.pcm"
    endif

    if SMPS_SCDACSamples
		incdac	Beat, "Sound/DAC/Sonic Crackers/Beat.pcm"
		incdac	SnareSC, "Sound/DAC/Sonic Crackers/SnareSC.pcm"
		incdac	TimTom, "Sound/DAC/Sonic Crackers/TimTom.pcm"
		incdac	LetsGo, "Sound/DAC/Sonic Crackers/LetsGo.pcm"
		incdac	Hey, "Sound/DAC/Sonic Crackers/Hey.pcm"
    endif
	even
