; DAC Equates
offset :=	MegaPCM_DAC_Table
ptrsize :=	8
idstart :=	$81

dac__First = idstart

	if SMPS_S1DACSamples||SMPS_S2DACSamples
; Sonic 1 & 2
dKick =						SMPS_id(ptr_dac81)
dSnare =						SMPS_id(ptr_dac82)
dTimpani =					SMPS_id(ptr_dac85)
dHiTimpani =				SMPS_id(ptr_dac88)
dMidTimpani =				SMPS_id(ptr_dac89)
dLowTimpani =				SMPS_id(ptr_dac8A)
dVLowTimpani =				SMPS_id(ptr_dac8B)
	endif

	if SMPS_S2DACSamples
; Sonic 2
dClap =						SMPS_id(ptr_dac83)
dScratch =					SMPS_id(ptr_dac84)
dHiTom =					SMPS_id(ptr_dac86)
dVLowBongo =				SMPS_id(ptr_dac87)
dMidTom =					SMPS_id(ptr_dac8C)
dLowTom =					SMPS_id(ptr_dac8D)
dFloorTom =					SMPS_id(ptr_dac8E)
dHighBongo =				SMPS_id(ptr_dac8F)
dMidBongo =					SMPS_id(ptr_dac90)
dLowBongo =					SMPS_id(ptr_dac91)

dHiClap = dHighBongo
dMidClap = dMidBongo
dLowClap = dLowBongo
	endif

	if SMPS_S3DACSamples||SMPS_SKDACSamples||SMPS_S3DDACSamples
; Sonic 3 & K & 3D
dSnareS3 =					SMPS_id(ptr_dac92)
dHighTom =					SMPS_id(ptr_dac93)
dMidTomS3 =				SMPS_id(ptr_dac94)
dLowTomS3 =				SMPS_id(ptr_dac95)
dFloorTomS3 =				SMPS_id(ptr_dac96)
dKickS3 =					SMPS_id(ptr_dac97)
dMuffledSnare =				SMPS_id(ptr_dac98)
dCrashCymbal =				SMPS_id(ptr_dac99)
dRideCymbal =				SMPS_id(ptr_dac9A)
dLowMetalHit =				SMPS_id(ptr_dac9B)
dMetalHit =					SMPS_id(ptr_dac9C)
dHighMetalHit =				SMPS_id(ptr_dac9D)
dHigherMetalHit =			SMPS_id(ptr_dac9E)
dMidMetalHit =				SMPS_id(ptr_dac9F)
dClapS3 =					SMPS_id(ptr_dacA0)
dElectricHighTom =			SMPS_id(ptr_dacA1)
dElectricMidTom =			SMPS_id(ptr_dacA2)
dElectricLowTom =			SMPS_id(ptr_dacA3)
dElectricFloorTom =			SMPS_id(ptr_dacA4)
dTightSnare =				SMPS_id(ptr_dacA5)
dMidpitchSnare =				SMPS_id(ptr_dacA6)
dLooseSnare =				SMPS_id(ptr_dacA7)
dLooserSnare =				SMPS_id(ptr_dacA8)
dHiTimpaniS3 =				SMPS_id(ptr_dacA9)
dLowTimpaniS3 =				SMPS_id(ptr_dacAA)
dMidTimpaniS3 =				SMPS_id(ptr_dacAB)
dQuickLooseSnare =			SMPS_id(ptr_dacAC)
dClick =						SMPS_id(ptr_dacAD)
dPowerKick =					SMPS_id(ptr_dacAE)
dQuickGlassCrash =			SMPS_id(ptr_dacAF)
	endif

	if SMPS_S3DACSamples||SMPS_SKDACSamples
; Sonic 3 & K
dGlassCrashSnare =			SMPS_id(ptr_dacB0)
dGlassCrash =				SMPS_id(ptr_dacB1)
dGlassCrashKick =			SMPS_id(ptr_dacB2)
dQuietGlassCrash =			SMPS_id(ptr_dacB3)
dOddSnareKick =				SMPS_id(ptr_dacB4)
dKickExtraBass =				SMPS_id(ptr_dacB5)
dComeOn =					SMPS_id(ptr_dacB6)
dDanceSnare =				SMPS_id(ptr_dacB7)
dLooseKick =					SMPS_id(ptr_dacB8)
dModLooseKick =				SMPS_id(ptr_dacB9)
dWoo =						SMPS_id(ptr_dacBA)
dGo =						SMPS_id(ptr_dacBB)
dSnareGo =					SMPS_id(ptr_dacBC)
dPowerTom =				SMPS_id(ptr_dacBD)
dHiWoodBlock =				SMPS_id(ptr_dacBE)
dLowWoodBlock =				SMPS_id(ptr_dacBF)
dHiHitDrum =				SMPS_id(ptr_dacC0)
dLowHitDrum =				SMPS_id(ptr_dacC1)
dMetalCrashHit =				SMPS_id(ptr_dacC2)
dEchoedClapHit =				SMPS_id(ptr_dacC3)
dLowerEchoedClapHit =		SMPS_id(ptr_dacC4)
dHipHopHitKick =			SMPS_id(ptr_dacC5)
dHipHopHitPowerKick =		SMPS_id(ptr_dacC6)
dBassHey =					SMPS_id(ptr_dacC7)
dDanceStyleKick =			SMPS_id(ptr_dacC8)
dHipHopHitKick2 =			SMPS_id(ptr_dacC9)
dReverseFadingWind =			SMPS_id(ptr_dacCA)
dScratchS3 =					SMPS_id(ptr_dacCB)
dLooseSnareNoise =			SMPS_id(ptr_dacCC)
dPowerKick2 =				SMPS_id(ptr_dacCD)
dCrashingNoiseWoo =			SMPS_id(ptr_dacCE)
dQuickHit =					SMPS_id(ptr_dacCF)
dKickHey =					SMPS_id(ptr_dacD0)
dPowerKickHit =				SMPS_id(ptr_dacD1)
dLowPowerKickHit =			SMPS_id(ptr_dacD2)
dLowerPowerKickHit =			SMPS_id(ptr_dacD3)
dLowestPowerKickHit =		SMPS_id(ptr_dacD4)

dHipHopHitKick3 = dHipHopHitKick2
	endif

	if SMPS_S3DDACSamples
; Sonic 3D
dFinalFightMetalCrash =		SMPS_id(ptr_dacD5)
dIntroKick =					SMPS_id(ptr_dacD6)
	endif

	if SMPS_S3DACSamples
; Sonic 3
dEchoedClapHit_S3 =			SMPS_id(ptr_dacD7)
dLowerEchoedClapHit_S3 =	SMPS_id(ptr_dacD8)
	endif

	if SMPS_SCDACSamples
; Sonic Crackers
dBeat =						SMPS_id(ptr_dacD9)
dSnareSC =					SMPS_id(ptr_dacDA)
dHiTimTom =				SMPS_id(ptr_dacDB)
dMidTimTom =				SMPS_id(ptr_dacDC)
dLowTimTom =				SMPS_id(ptr_dacDD)
dLetsGo =					SMPS_id(ptr_dacDE)
dHey =						SMPS_id(ptr_dacDF)
	endif

; Sonic 2
dSega_S2 =					SMPS_id(ptr_dacE0)

dac__Last = dSega_S2
