; ===========================================================================
; Uncompressed player graphics
; ===========================================================================

	align $10000	; for DMA...

ArtUnc_Sonic:					binclude "Objects/Players/Sonic/Uncompressed Art/Sonic.unc"
	even
ArtUnc_DashDust:				binclude "Objects/Players/Spin Dust/Uncompressed Art/Dash Dust.unc"
	even
ArtUnc_SplashDrown:				binclude "Objects/Players/Spin Dust/Uncompressed Art/Splash Drown.unc"
	even
ArtUnc_Invincibility:				bincludeEntry "Objects/Players/Shields/Uncompressed Art/Invincibility.unc"
	even
ArtUnc_InstaShield:				binclude "Objects/Players/Shields/Uncompressed Art/Insta-Shield.unc"
	even
ArtUnc_FireShield:				binclude "Objects/Players/Shields/Uncompressed Art/Fire Shield.unc"
	even
ArtUnc_LightningShield:				binclude "Objects/Players/Shields/Uncompressed Art/Lightning Shield.unc"
	even
ArtUnc_LightningShield_Sparks:			bincludeEntry "Objects/Players/Shields/Uncompressed Art/Sparks.unc"
	even
ArtUnc_BubbleShield:				binclude "Objects/Players/Shields/Uncompressed Art/Bubble Shield.unc"
	even