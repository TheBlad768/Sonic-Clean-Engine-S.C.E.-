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
; Configuration
; ===========================================================================

; ---------------------------------------------------------------------------
; Approximate size of compressed sound driver.
Size_of_Snd_driver_guess = $1200
; Used by SMPS2ASM include file.
SonicDriverVer			= 5
; Set the following to non-zero to use all S2 DAC samples, or to zero otherwise.
; The S1 samples are a subset of this.
use_s2_samples			= 1
; Set the following to non-zero to use all S3D DAC samples, or to zero
; otherwise. Most of the S3D samples are also present in S3/S&K, but
; there are two samples specific to S3D.
use_s3d_samples			= 1
; Set the following to non-zero to use all S3 DAC samples,
; or to zero otherwise.
use_s3_samples			= 1
; Set the following to non-zero to use all S&K DAC samples,
; or to zero otherwise.
use_sk_samples			= 1
; Don't define constants for DAC samples and use those from the DAC table.
skip_sample_equates		= 1
; ---------------------------------------------------------------------------
; The prefixes for music, SFX, and driver command IDs.
; For S1 use "bgm", "sfx", "cmd", and "cmd".
; For S2 use "MusID", "SndID", "FadeID", and "MusID".
; For S3 use "mus", "sfx", "cmd", and "cmd".
mus_prefix = "mus"
sfx_prefix = "sfx"
fade_prefix = "cmd"
cmd_prefix = "cmd"
; New thing in Flamedriver: play a sample as an SFX. Currently, no way to really
; specify any, but you can specify the prefix.
pcm_prefix = "PCMID"
; ---------------------------------------------------------------------------
	include "Sound/_smps2asm_inc.asm"
; ---------------------------------------------------------------------------
