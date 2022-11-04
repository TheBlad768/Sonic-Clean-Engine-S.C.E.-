; ---------------------------------------------------------------------------
; PSG pointers
; ---------------------------------------------------------------------------
PSG_Index:
	if SMPS_S1PSGEnvelopes||SMPS_S2PSGEnvelopes
		; S1 + S2
ptr_s1psg01:	dc.l S1_PSG01
ptr_s1psg02:	dc.l S1_PSG02
ptr_s1psg03:	dc.l S1_PSG03
ptr_s1psg04:	dc.l S1_PSG04
ptr_s1psg05:	dc.l S1_PSG05
ptr_s1psg06:	dc.l S1_PSG06
ptr_s1psg07:	dc.l S1_PSG07
ptr_s1psg08:	dc.l S1_PSG08
ptr_s1psg09:	dc.l S1_PSG09
	endif

	if SMPS_S2PSGEnvelopes
		; S2
ptr_s2psg0A:	dc.l S2_PSG0A
ptr_s2psg0B:	dc.l S2_PSG0B
ptr_s2psg0C:	dc.l S2_PSG0C
ptr_s2psg0D:	dc.l S2_PSG0D
	endif

	if SMPS_S3PSGEnvelopes||SMPS_SKPSGEnvelopes||SMPS_S3DPSGEnvelopes
		; S3 + S&K + S3D
ptr_s3psg01:	dc.l S3_PSG01
ptr_s3psg02:	dc.l S3_PSG02
ptr_s3psg03:	dc.l S3_PSG03
ptr_s3psg05:	dc.l S3_PSG05
ptr_s3psg06:	dc.l S3_PSG06
ptr_s3psg07:	dc.l S3_PSG07
ptr_s3psg08:	dc.l S3_PSG08
ptr_s3psg09:	dc.l S3_PSG09
ptr_s3psg0A:	dc.l S3_PSG0A
ptr_s3psg0B:	dc.l S3_PSG0B
ptr_s3psg0C:	dc.l S3_PSG0C
ptr_s3psg0D:	dc.l S3_PSG0D
ptr_s3psg10:	dc.l S3_PSG10
ptr_s3psg11:	dc.l S3_PSG11
ptr_s3psg14:	dc.l S3_PSG14
ptr_s3psg18:	dc.l S3_PSG18
ptr_s3psg1A:	dc.l S3_PSG1A
ptr_s3psg1C:	dc.l S3_PSG1C
ptr_s3psg1D:	dc.l S3_PSG1D
ptr_s3psg1E:	dc.l S3_PSG1E
ptr_s3psg1F:	dc.l S3_PSG1F
ptr_s3psg20:	dc.l S3_PSG20
ptr_s3psg21:	dc.l S3_PSG21
ptr_s3psg22:	dc.l S3_PSG22
ptr_s3psg23:	dc.l S3_PSG23
ptr_s3psg24:	dc.l S3_PSG24
ptr_s3psg25:	dc.l S3_PSG25
ptr_s3psg27:	dc.l S3_PSG27
	endif

	if SMPS_S3PSGEnvelopes
		; S3 only
ptr_s3psg26:	dc.l S3_PSG26
	endif

	if SMPS_S3PSGEnvelopes||SMPS_SKPSGEnvelopes
		; S3 + S&K
ptr_s3psg04:	dc.l S3_PSG04
	endif

	if SMPS_SKPSGEnvelopes||SMPS_S3DPSGEnvelopes
		; S&K + S3D
ptr_skpsg26:	dc.l SK_PSG26
	endif

	if SMPS_S3DPSGEnvelopes
		; S3D
ptr_s3dpsg04:	dc.l S3D_PSG04
ptr_s3dpsg28:	dc.l S3D_PSG28
	endif

	if SMPS_KCPSGEnvelopes
ptr_kcpsg01:	dc.l KC_PSG01
ptr_kcpsg02:	dc.l KC_PSG02
ptr_kcpsg03:	dc.l KC_PSG03
ptr_kcpsg04:	dc.l KC_PSG04
ptr_kcpsg05:	dc.l KC_PSG05
ptr_kcpsg06:	dc.l KC_PSG06
ptr_kcpsg07:	dc.l KC_PSG07
ptr_kcpsg08:	dc.l KC_PSG08
ptr_kcpsg09:	dc.l KC_PSG09
ptr_kcpsg0A:	dc.l KC_PSG0A
ptr_kcpsg0B:	dc.l KC_PSG0B
ptr_kcpsg0C:	dc.l KC_PSG0C
ptr_kcpsg0D:	dc.l KC_PSG0D
ptr_kcpsg0E:	dc.l KC_PSG0E
	endif

	; Insert custom envelopes' addresses here

; ---------------------------------------------------------------------------
; PSG instruments used in music
; ---------------------------------------------------------------------------
	if SMPS_S1PSGEnvelopes||SMPS_S2PSGEnvelopes
; Envelopes found in S1 and S2
S1_PSG01:	binclude "Sound/PSG/Sonic 1 & 2/PSG 1.bin"
S1_PSG02:	binclude "Sound/PSG/Sonic 1 & 2/PSG 2.bin"
S1_PSG03:	binclude "Sound/PSG/Sonic 1 & 2/PSG 3.bin"
S1_PSG04:	binclude "Sound/PSG/Sonic 1 & 2/PSG 4.bin"
S1_PSG05:	binclude "Sound/PSG/Sonic 1 & 2/PSG 5.bin"
S1_PSG06:	binclude "Sound/PSG/Sonic 1 & 2/PSG 6.bin"
S1_PSG07:	binclude "Sound/PSG/Sonic 1 & 2/PSG 7.bin"
S1_PSG08:	binclude "Sound/PSG/Sonic 1 & 2/PSG 8.bin"
S1_PSG09:	binclude "Sound/PSG/Sonic 1 & 2/PSG 9.bin"
	endif

	if SMPS_S2PSGEnvelopes
; Envelopes found in S2 only
S2_PSG0A:	binclude "Sound/PSG/Sonic 1 & 2/PSG A (S2).bin"
S2_PSG0B:	binclude "Sound/PSG/Sonic 1 & 2/PSG B (S2).bin"
S2_PSG0C:	binclude "Sound/PSG/Sonic 1 & 2/PSG C (S2).bin"
S2_PSG0D:	binclude "Sound/PSG/Sonic 1 & 2/PSG D (S2).bin"
	endif

	if SMPS_S3PSGEnvelopes||SMPS_SKPSGEnvelopes||SMPS_S3DPSGEnvelopes
; Envelopes found in S3, S&K, and S3D (some aren't here, since they're just duplicates)
S3_PSG01:	binclude "Sound/PSG/Sonic 3 & K & 3D/PSG 1.bin"
S3_PSG02:	binclude "Sound/PSG/Sonic 3 & K & 3D/PSG 2.bin"
S3_PSG03:	binclude "Sound/PSG/Sonic 3 & K & 3D/PSG 3.bin"
S3_PSG05:	binclude "Sound/PSG/Sonic 3 & K & 3D/PSG 5.bin"
S3_PSG06:	binclude "Sound/PSG/Sonic 3 & K & 3D/PSG 6.bin"
S3_PSG07:	binclude "Sound/PSG/Sonic 3 & K & 3D/PSG 7.bin"
S3_PSG08:	binclude "Sound/PSG/Sonic 3 & K & 3D/PSG 8.bin"
S3_PSG09:	binclude "Sound/PSG/Sonic 3 & K & 3D/PSG 9.bin"
S3_PSG0A:	binclude "Sound/PSG/Sonic 3 & K & 3D/PSG A.bin"
S3_PSG0B:	binclude "Sound/PSG/Sonic 3 & K & 3D/PSG B.bin"
S3_PSG0C:	binclude "Sound/PSG/Sonic 3 & K & 3D/PSG C.bin"
S3_PSG0D:	binclude "Sound/PSG/Sonic 3 & K & 3D/PSG D.bin"
S3_PSG10:	binclude "Sound/PSG/Sonic 3 & K & 3D/PSG 10.bin"
S3_PSG11:	binclude "Sound/PSG/Sonic 3 & K & 3D/PSG 11.bin"
S3_PSG14:	binclude "Sound/PSG/Sonic 3 & K & 3D/PSG 14.bin"
S3_PSG18:	binclude "Sound/PSG/Sonic 3 & K & 3D/PSG 18.bin"
S3_PSG1A:	binclude "Sound/PSG/Sonic 3 & K & 3D/PSG 1A.bin"
S3_PSG1C:	binclude "Sound/PSG/Sonic 3 & K & 3D/PSG 1C.bin"
S3_PSG1D:	binclude "Sound/PSG/Sonic 3 & K & 3D/PSG 1D.bin"
S3_PSG1E:	binclude "Sound/PSG/Sonic 3 & K & 3D/PSG 1E.bin"
S3_PSG1F:	binclude "Sound/PSG/Sonic 3 & K & 3D/PSG 1F.bin"
S3_PSG20:	binclude "Sound/PSG/Sonic 3 & K & 3D/PSG 20.bin"
S3_PSG21:	binclude "Sound/PSG/Sonic 3 & K & 3D/PSG 21.bin"
S3_PSG22:	binclude "Sound/PSG/Sonic 3 & K & 3D/PSG 22.bin"
S3_PSG23:	binclude "Sound/PSG/Sonic 3 & K & 3D/PSG 23.bin"
S3_PSG24:	binclude "Sound/PSG/Sonic 3 & K & 3D/PSG 24.bin"
S3_PSG25:	binclude "Sound/PSG/Sonic 3 & K & 3D/PSG 25.bin"
S3_PSG27:	binclude "Sound/PSG/Sonic 3 & K & 3D/PSG 27.bin"
	endif

	if SMPS_S3PSGEnvelopes
; Envelopes found in S3 only
S3_PSG26:	binclude "Sound/PSG/Sonic 3 & K & 3D/PSG 26 (S3).bin"
	endif

	if SMPS_S3PSGEnvelopes||SMPS_SKPSGEnvelopes
; Envelopes found in S3 and S&K only
S3_PSG04:	binclude "Sound/PSG/Sonic 3 & K & 3D/PSG 4 (S3, SK).bin"
	endif

	if SMPS_SKPSGEnvelopes||SMPS_S3DPSGEnvelopes
; Envelopes found in S&K and S3D only
SK_PSG26:	binclude "Sound/PSG/Sonic 3 & K & 3D/PSG 26 (SK, S3D).bin"
	endif

	if SMPS_S3DPSGEnvelopes
; Envelopes found in S3D only
S3D_PSG04:	binclude "Sound/PSG/Sonic 3 & K & 3D/PSG 4 (S3D).bin"
S3D_PSG28:	binclude "Sound/PSG/Sonic 3 & K & 3D/PSG 28 (S3D).bin"
	endif

	if SMPS_KCPSGEnvelopes
KC_PSG01:	binclude "Sound/PSG/Knuckles' Chaotix/PSG 1.bin"
KC_PSG02:	binclude "Sound/PSG/Knuckles' Chaotix/PSG 2.bin"
KC_PSG03:	binclude "Sound/PSG/Knuckles' Chaotix/PSG 3.bin"
KC_PSG04:	binclude "Sound/PSG/Knuckles' Chaotix/PSG 4.bin"
KC_PSG05:	binclude "Sound/PSG/Knuckles' Chaotix/PSG 5.bin"
KC_PSG06:	binclude "Sound/PSG/Knuckles' Chaotix/PSG 6.bin"
KC_PSG07:	binclude "Sound/PSG/Knuckles' Chaotix/PSG 7.bin"
KC_PSG08:	binclude "Sound/PSG/Knuckles' Chaotix/PSG 8.bin"
KC_PSG09:	binclude "Sound/PSG/Knuckles' Chaotix/PSG 9.bin"
KC_PSG0A:	binclude "Sound/PSG/Knuckles' Chaotix/PSG A.bin"
KC_PSG0B:	binclude "Sound/PSG/Knuckles' Chaotix/PSG B.bin"
KC_PSG0C:	binclude "Sound/PSG/Knuckles' Chaotix/PSG C.bin"
KC_PSG0D:	binclude "Sound/PSG/Knuckles' Chaotix/PSG D.bin"
KC_PSG0E:	binclude "Sound/PSG/Knuckles' Chaotix/PSG E.bin"
	endif

	; Insert custom envelopes here

	even
