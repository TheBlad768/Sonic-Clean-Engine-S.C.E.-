; PSG volume envelope equates
offset :=	PSG_Index
ptrsize :=	4
idstart :=	1

	if SMPS_S1PSGEnvelopes||SMPS_S2PSGEnvelopes
; S1/S2
fTone_01 =		SMPS_id(ptr_s1psg01)
fTone_02 =		SMPS_id(ptr_s1psg02)
fTone_03 =		SMPS_id(ptr_s1psg03)
fTone_04 =		SMPS_id(ptr_s1psg04)
fTone_05 =		SMPS_id(ptr_s1psg05)
fTone_06 =		SMPS_id(ptr_s1psg06)
fTone_07 =		SMPS_id(ptr_s1psg07)
fTone_08 =		SMPS_id(ptr_s1psg08)
fTone_09 =		SMPS_id(ptr_s1psg09)
	endif

	if SMPS_S2PSGEnvelopes
; S2
fTone_0A =		SMPS_id(ptr_s2psg0A)
fTone_0B =		SMPS_id(ptr_s2psg0B)
fTone_0C =		SMPS_id(ptr_s2psg0C)
fTone_0D =		SMPS_id(ptr_s2psg0D)
	endif

	if SMPS_S3PSGEnvelopes||SMPS_SKPSGEnvelopes||SMPS_S3DPSGEnvelopes
; S3/S&K/S3D
sTone_01 =		SMPS_id(ptr_s3psg01)
sTone_02 =		SMPS_id(ptr_s3psg02)
sTone_03 =		SMPS_id(ptr_s3psg03)
sTone_05 =		SMPS_id(ptr_s3psg05)
sTone_06 =		SMPS_id(ptr_s3psg06)
sTone_07 =		SMPS_id(ptr_s3psg07)
sTone_08 =		SMPS_id(ptr_s3psg08)
sTone_09 =		SMPS_id(ptr_s3psg09)
sTone_0A =		SMPS_id(ptr_s3psg0A)
sTone_0B =		SMPS_id(ptr_s3psg0B)
sTone_0C =		SMPS_id(ptr_s3psg0C)
sTone_0D =		SMPS_id(ptr_s3psg0D)
sTone_10 =		SMPS_id(ptr_s3psg10)
sTone_11 =		SMPS_id(ptr_s3psg11)
sTone_14 =		SMPS_id(ptr_s3psg14)
sTone_18 =		SMPS_id(ptr_s3psg18)
sTone_1A =		SMPS_id(ptr_s3psg1A)
sTone_1C =		SMPS_id(ptr_s3psg1C)
sTone_1D =		SMPS_id(ptr_s3psg1D)
sTone_1E =		SMPS_id(ptr_s3psg1E)
sTone_1F =		SMPS_id(ptr_s3psg1F)
sTone_20 =		SMPS_id(ptr_s3psg20)
sTone_21 =		SMPS_id(ptr_s3psg21)
sTone_22 =		SMPS_id(ptr_s3psg22)
sTone_23 =		SMPS_id(ptr_s3psg23)
sTone_24 =		SMPS_id(ptr_s3psg24)
sTone_25 =		SMPS_id(ptr_s3psg25)
sTone_27 =		SMPS_id(ptr_s3psg27)
	endif

	if SMPS_S3PSGEnvelopes
; S3
sTone_26a =		SMPS_id(ptr_s3psg26)
	endif

	if SMPS_S3PSGEnvelopes||SMPS_SKPSGEnvelopes
; S3/S&K
sTone_04a =		SMPS_id(ptr_s3psg04)
sTone_04 =	sTone_04a
	endif

	if SMPS_SKPSGEnvelopes||SMPS_S3DPSGEnvelopes
; S&K/S3D
sTone_26b =		SMPS_id(ptr_skpsg26)
sTone_26 =	sTone_26b
	endif

	if SMPS_S3DPSGEnvelopes
; S3D
sTone_04b =		SMPS_id(ptr_s3dpsg04)
sTone_28 =		SMPS_id(ptr_s3dpsg28)
	endif

	if SMPS_S3PSGEnvelopes||SMPS_SKPSGEnvelopes||SMPS_S3DPSGEnvelopes
; Duplicates
sTone_0E = sTone_01
sTone_0F = sTone_02
sTone_12 = sTone_05
sTone_13 = sTone_06
sTone_15 = sTone_08
sTone_16 = sTone_09
sTone_17 = sTone_0A
sTone_19 = sTone_0C
sTone_1B = sTone_0C
	endif

    if SMPS_KCPSGEnvelopes
; Knuckles' Chaotix
KCVolEnv_01 =		SMPS_id(ptr_kcpsg01)
KCVolEnv_02 =		SMPS_id(ptr_kcpsg02)
KCVolEnv_03 =		SMPS_id(ptr_kcpsg03)
KCVolEnv_04 =		SMPS_id(ptr_kcpsg04)
KCVolEnv_05 =		SMPS_id(ptr_kcpsg05)
KCVolEnv_06 =		SMPS_id(ptr_kcpsg06)
KCVolEnv_07 =		SMPS_id(ptr_kcpsg07)
KCVolEnv_08 =		SMPS_id(ptr_kcpsg08)
KCVolEnv_09 =		SMPS_id(ptr_kcpsg09)
KCVolEnv_0A =		SMPS_id(ptr_kcpsg0A)
KCVolEnv_0B =		SMPS_id(ptr_kcpsg0B)
KCVolEnv_0C =		SMPS_id(ptr_kcpsg0C)
KCVolEnv_0D =		SMPS_id(ptr_kcpsg0D)
KCVolEnv_0E =		SMPS_id(ptr_kcpsg0E)
	endif

	; Insert custom equates here
