; DAC Equates

dac__First = __ST_SampleID+1

	if SMPS_S1DACSamples||SMPS_S2DACSamples
; Sonic 1 & 2
dKick =				dac81.id
dSnare =			dac82.id
dTimpani =			dac85.id
dHiTimpani =			dac88.id
dMidTimpani =			dac89.id
dLowTimpani =			dac8A.id
dVLowTimpani =			dac8B.id
	endif

	if SMPS_S2DACSamples
; Sonic 2
dClap =				dac83.id
dScratch =			dac84.id
dHiTom =			dac86.id
dVLowBongo =			dac87.id
dMidTom =			dac8C.id
dLowTom =			dac8D.id
dFloorTom =			dac8E.id
dHighBongo =			dac8F.id
dMidBongo =			dac90.id
dLowBongo =			dac91.id

dHiClap =			dHighBongo
dMidClap =			dMidBongo
dLowClap =			dLowBongo
	endif

	if SMPS_S3DACSamples||SMPS_SKDACSamples||SMPS_S3DDACSamples
; Sonic 3 & K & 3D
dSnareS3 =			dac92.id
dHighTom =			dac93.id
dMidTomS3 =			dac94.id
dLowTomS3 =			dac95.id
dFloorTomS3 =			dac96.id
dKickS3 =			dac97.id
dMuffledSnare =			dac98.id
dCrashCymbal =			dac99.id
dRideCymbal =			dac9A.id
dLowMetalHit =			dac9B.id
dMetalHit =			dac9C.id
dHighMetalHit =			dac9D.id
dHigherMetalHit =		dac9E.id
dMidMetalHit =			dac9F.id
dClapS3 =			dacA0.id
dElectricHighTom =		dacA1.id
dElectricMidTom =		dacA2.id
dElectricLowTom =		dacA3.id
dElectricFloorTom =		dacA4.id
dTightSnare =			dacA5.id
dMidpitchSnare =		dacA6.id
dLooseSnare =			dacA7.id
dLooserSnare =			dacA8.id
dHiTimpaniS3 =			dacA9.id
dLowTimpaniS3 =			dacAA.id
dMidTimpaniS3 =			dacAB.id
dQuickLooseSnare =		dacAC.id
dClick =			dacAD.id
dPowerKick =			dacAE.id
dQuickGlassCrash =		dacAF.id
	endif

	if SMPS_S3DACSamples||SMPS_SKDACSamples
; Sonic 3 & K
dGlassCrashSnare =		dacB0.id
dGlassCrash =			dacB1.id
dGlassCrashKick =		dacB2.id
dQuietGlassCrash =		dacB3.id
dOddSnareKick =			dacB4.id
dKickExtraBass =		dacB5.id
dComeOn =			dacB6.id
dDanceSnare =			dacB7.id
dLooseKick =			dacB8.id
dModLooseKick =			dacB9.id
dWoo =				dacBA.id
dGo =				dacBB.id
dSnareGo =			dacBC.id
dPowerTom =			dacBD.id
dHiWoodBlock =			dacBE.id
dLowWoodBlock =			dacBF.id
dHiHitDrum =			dacC0.id
dLowHitDrum =			dacC1.id
dMetalCrashHit =		dacC2.id
dEchoedClapHit =		dacC3.id
dLowerEchoedClapHit =		dacC4.id
dHipHopHitKick =		dacC5.id
dHipHopHitPowerKick =		dacC6.id
dBassHey =			dacC7.id
dDanceStyleKick =		dacC8.id
dHipHopHitKick2 =		dacC9.id
dReverseFadingWind =		dacCA.id
dScratchS3 =			dacCB.id
dLooseSnareNoise =		dacCC.id
dPowerKick2 =			dacCD.id
dCrashingNoiseWoo =		dacCE.id
dQuickHit =			dacCF.id
dKickHey =			dacD0.id
dPowerKickHit =			dacD1.id
dLowPowerKickHit =		dacD2.id
dLowerPowerKickHit =		dacD3.id
dLowestPowerKickHit =		dacD4.id

dHipHopHitKick3 = dHipHopHitKick2
	endif

	if SMPS_S3DDACSamples
; Sonic 3D
dFinalFightMetalCrash =		dacD5.id
dIntroKick =			dacD6.id
	endif

	if SMPS_S3DACSamples
; Sonic 3
dEchoedClapHit_S3 =		dacD7.id
dLowerEchoedClapHit_S3 =	dacD8.id
	endif

	if SMPS_SCDACSamples
; Sonic Crackers
dBeat =				dacD9.id
dSnareSC =			dacDA.id
dHiTimTom =			dacDB.id
dMidTimTom =			dacDC.id
dLowTimTom =			dacDD.id
dLetsGo =			dacDE.id
dHey =				dacDF.id
	endif

dSega =				dacE0.id

dac__Last = dSega
