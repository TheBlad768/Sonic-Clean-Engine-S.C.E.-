; ===========================================================================
; ║                                                                         ║
; ║                             SONIC&K SOUND DRIVER                        ║
; ║                         Modified SMPS Z80 Type 2 DAC                    ║
; ║                                                                         ║
; ===========================================================================
; Disassembled by MarkeyJester
; Routines, pointers and stuff by Linncaki
; Thoroughly commented and improved (including optional bugfixes) by Flamewing
; ===========================================================================
; Permission to use, copy, modify, and/or distribute this software for any
; purpose with or without fee is hereby granted.
;
; THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
; WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
; MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
; ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
; WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
; ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT
; OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
; ===========================================================================
; DAC Banks
; ===========================================================================

	if (use_s3_samples<>0)||(use_sk_samples<>0)||(use_s3d_samples<>0)
; ---------------------------------------------------------------------------
; DAC Bank 1
; ---------------------------------------------------------------------------
DacBank1:			startBank
	DAC_Master_Table

DAC_86_Data:			DACBINCLUDE "Sound/DAC/86.dpcm"
DAC_81_Data:			DACBINCLUDE "Sound/DAC/81.dpcm"
DAC_82_83_84_85_Data:	DACBINCLUDE "Sound/DAC/82-85.dpcm"
DAC_94_95_96_97_Data:	DACBINCLUDE "Sound/DAC/94-97.dpcm"
DAC_90_91_92_93_Data:	DACBINCLUDE "Sound/DAC/90-93.dpcm"
DAC_88_Data:			DACBINCLUDE "Sound/DAC/88.dpcm"
DAC_8A_8B_Data:			DACBINCLUDE "Sound/DAC/8A-8B.dpcm"
DAC_8C_Data:			DACBINCLUDE "Sound/DAC/8C.dpcm"
DAC_8D_8E_Data:			DACBINCLUDE "Sound/DAC/8D-8E.dpcm"
DAC_87_Data:			DACBINCLUDE "Sound/DAC/87.dpcm"
DAC_8F_Data:			DACBINCLUDE "Sound/DAC/8F.dpcm"
DAC_89_Data:			DACBINCLUDE "Sound/DAC/89.dpcm"
DAC_98_99_9A_Data:		DACBINCLUDE "Sound/DAC/98-9A.dpcm"
DAC_9B_Data:			DACBINCLUDE "Sound/DAC/9B.dpcm"
	endif

	if (use_s3_samples<>0)||(use_sk_samples<>0)
DAC_B2_B3_Data:			DACBINCLUDE "Sound/DAC/B2-B3.dpcm"

	if (use_s3_samples<>0)
DAC_D8_D9_Data:			DACBINCLUDE "Sound/DAC/D8-D9.dpcm"
	endif

	finishBank

; ---------------------------------------------------------------------------
; Dac Bank 2
; ---------------------------------------------------------------------------
DacBank2:			startBank
	DAC_Master_Table
	endif

	if (use_s3_samples<>0)||(use_sk_samples<>0)||(use_s3d_samples<>0)
DAC_9C_Data:			DACBINCLUDE "Sound/DAC/9C.dpcm"
DAC_9D_Data:			DACBINCLUDE "Sound/DAC/9D.dpcm"
DAC_9E_Data:			DACBINCLUDE "Sound/DAC/9E.dpcm"
	endif

	if (use_s3_samples<>0)||(use_sk_samples<>0)
DAC_9F_Data:			DACBINCLUDE "Sound/DAC/9F.dpcm"
DAC_A0_Data:			DACBINCLUDE "Sound/DAC/A0.dpcm"
DAC_A1_Data:			DACBINCLUDE "Sound/DAC/A1.dpcm"
DAC_A2_Data:			DACBINCLUDE "Sound/DAC/A2.dpcm"
DAC_A3_Data:			DACBINCLUDE "Sound/DAC/A3.dpcm"
DAC_A4_Data:			DACBINCLUDE "Sound/DAC/A4.dpcm"
DAC_A5_Data:			DACBINCLUDE "Sound/DAC/A5.dpcm"
DAC_A6_Data:			DACBINCLUDE "Sound/DAC/A6.dpcm"
DAC_A7_Data:			DACBINCLUDE "Sound/DAC/A7.dpcm"
DAC_A8_Data:			DACBINCLUDE "Sound/DAC/A8.dpcm"
DAC_A9_Data:			DACBINCLUDE "Sound/DAC/A9.dpcm"
DAC_AA_Data:			DACBINCLUDE "Sound/DAC/AA.dpcm"

	finishBank

; ---------------------------------------------------------------------------
; Dac Bank 3
; ---------------------------------------------------------------------------
DacBank3:			startBank
	DAC_Master_Table

DAC_AB_Data:			DACBINCLUDE "Sound/DAC/AB.dpcm"
DAC_AC_Data:			DACBINCLUDE "Sound/DAC/AC.dpcm"
DAC_AD_AE_Data:			DACBINCLUDE "Sound/DAC/AD-AE.dpcm"
DAC_AF_B0_Data:			DACBINCLUDE "Sound/DAC/AF-B0.dpcm"
DAC_B1_Data:			DACBINCLUDE "Sound/DAC/B1.dpcm"
DAC_B4_C1_C2_C3_C4_Data:DACBINCLUDE "Sound/DAC/B4C1-C4.dpcm"
DAC_B5_Data:			DACBINCLUDE "Sound/DAC/B5.dpcm"
DAC_B6_Data:			DACBINCLUDE "Sound/DAC/B6.dpcm"
DAC_B7_Data:			DACBINCLUDE "Sound/DAC/B7.dpcm"
DAC_B8_B9_Data:			DACBINCLUDE "Sound/DAC/B8-B9.dpcm"
DAC_BA_Data:			DACBINCLUDE "Sound/DAC/BA.dpcm"
DAC_BB_Data:			DACBINCLUDE "Sound/DAC/BB.dpcm"
DAC_BC_Data:			DACBINCLUDE "Sound/DAC/BC.dpcm"
DAC_BD_Data:			DACBINCLUDE "Sound/DAC/BD.dpcm"
DAC_BE_Data:			DACBINCLUDE "Sound/DAC/BE.dpcm"
DAC_BF_Data:			DACBINCLUDE "Sound/DAC/BF.dpcm"
DAC_C0_Data:			DACBINCLUDE "Sound/DAC/C0.dpcm"

	finishBank
	endif

	if (use_s2_samples<>0)||(use_s3d_samples<>0)
; ---------------------------------------------------------------------------
; Dac Bank 4
; ---------------------------------------------------------------------------
DacBank4:			startBank
	DAC_Master_Table
	if (use_s2_samples<>0)
DAC_C5_Data:			DACBINCLUDE "Sound/DAC/C5.dpcm"
DAC_C6_Data:			DACBINCLUDE "Sound/DAC/C6.dpcm"
DAC_C7_Data:			DACBINCLUDE "Sound/DAC/C7.dpcm"
DAC_C8_Data:			DACBINCLUDE "Sound/DAC/C8.dpcm"
DAC_C9_CC_CD_CE_CF_Data:DACBINCLUDE "Sound/DAC/C9CC-CF.dpcm"
DAC_CA_D0_D1_D2_Data:	DACBINCLUDE "Sound/DAC/CAD0-D2.dpcm"
DAC_CB_D3_D4_D5_Data:	DACBINCLUDE "Sound/DAC/CBD3-D5.dpcm"
	endif

	if (use_s3d_samples<>0)
DAC_D6_Data:			DACBINCLUDE "Sound/DAC/D6.dpcm"
DAC_D7_Data:			DACBINCLUDE "Sound/DAC/D7.dpcm"
	endif

	finishBank
	endif
; ---------------------------------------------------------------------------
