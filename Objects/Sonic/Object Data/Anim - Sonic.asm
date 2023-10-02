; ---------------------------------------------------------------------------
; Sonic Animation Script
; ---------------------------------------------------------------------------

AniSonic:
Ani_Sonic: offsetTable
		offsetTableEntry.w SonAni_Walk		; 0
		offsetTableEntry.w SonAni_Run			; 1
		offsetTableEntry.w SonAni_Roll			; 2
		offsetTableEntry.w SonAni_Roll2		; 3
		offsetTableEntry.w SonAni_Push		; 4
		offsetTableEntry.w SonAni_Wait		; 5
		offsetTableEntry.w SonAni_Balance		; 6
		offsetTableEntry.w SonAni_LookUp		; 7
		offsetTableEntry.w SonAni_Duck		; 8
		offsetTableEntry.w SonAni_SpinDash	; 9
		offsetTableEntry.w SonAni_Whistle		; A	(Unused)
		offsetTableEntry.w AniSonic0B			; B	(Unused?)
		offsetTableEntry.w SonAni_Balance2		; C
		offsetTableEntry.w SonAni_Stop			; D
		offsetTableEntry.w SonAni_Float1		; E
		offsetTableEntry.w SonAni_Float2		; F
		offsetTableEntry.w SonAni_Spring		; 10
		offsetTableEntry.w SonAni_Hang		; 11
		offsetTableEntry.w AniSonic12			; 12	(Unused?)
		offsetTableEntry.w SonAni_Landing		; 13
		offsetTableEntry.w SonAni_Hang2		; 14
		offsetTableEntry.w SonAni_GetAir		; 15
		offsetTableEntry.w SonAni_DeathBW	; 16	(Unused)
		offsetTableEntry.w SonAni_Drown		; 17
		offsetTableEntry.w SonAni_Death		; 18
		offsetTableEntry.w SonAni_Hurt			; 19
		offsetTableEntry.w SonAni_Hurt2		; 1A
		offsetTableEntry.w SonAni_Slide		; 1B
		offsetTableEntry.w SonAni_Blank		; 1C
		offsetTableEntry.w SonAni_Hurt3		; 1D
		offsetTableEntry.w SonAni_Float3		; 1E
		offsetTableEntry.w SonAni_Transform	; 1F
		offsetTableEntry.w AniSonic20			; 20	(Unused?)
		offsetTableEntry.w AniSonic21			; 21	(Unused?)
		offsetTableEntry.w SonAni_Carry		; 22
		offsetTableEntry.w SonAni_Carry2		; 23

SonAni_Walk:		dc.b  $FF,   7,   8,   1,   2,   3,   4,   5,   6, $FF
SonAni_Run:			dc.b  $FF, $21, $22, $23, $24, $FF, $FF, $FF, $FF, $FF
SonAni_Roll:			dc.b  $FE, $96, $97, $96, $98, $96, $99, $96, $9A, $FF
SonAni_Roll2:		dc.b  $FE, $96, $97, $96, $98, $96, $99, $96, $9A, $FF
SonAni_Push:		dc.b  $FD, $B6, $B7, $B8, $B9, $FF, $FF, $FF, $FF, $FF
SonAni_Wait:		dc.b    5, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA
					dc.b  $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA
					dc.b  $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA
					dc.b  $BA, $BA, $BA, $BB, $BC, $BC, $BD, $BD, $BE, $BE, $BD, $BD, $BE, $BE, $BD, $BD
					dc.b  $BE, $BE, $BD, $BD, $BE, $BE, $BD, $BD, $BE, $BE, $BD, $BD, $BE, $BE, $BD, $BD
					dc.b  $BE, $BE, $BD, $BD, $BE, $BE, $AD, $AD, $AD, $AD, $AD, $AD, $AE, $AE, $AE, $AE
					dc.b  $AE, $AE, $AF, $D9, $D9, $D9, $D9, $D9, $D9, $AF, $AF, $FE, $35
SonAni_Balance:		dc.b    7, $A4, $A5, $A6, $FF
SonAni_LookUp:		dc.b    5, $C3, $C4, $FE,   1
SonAni_Duck:		dc.b    5, $9B, $9C, $FE,   1
SonAni_SpinDash:	dc.b    0, $86, $87, $86, $88, $86, $89, $86, $8A, $86, $8B, $FF
SonAni_Whistle:		dc.b    9, $BA, $C5, $C6, $C6, $C6, $C6, $C6, $C6, $C7, $C7, $C7, $C7, $C7, $C7, $C7
					dc.b  $C7, $C7, $C7, $C7, $C7, $FD,   0
AniSonic0B:			dc.b   $F, $8F, $FF
SonAni_Balance2:		dc.b    5, $A1, $A2, $A3, $FF
SonAni_Stop:			dc.b    3, $9D, $9E, $9F, $A0, $FD,   0
SonAni_Float1:		dc.b    7, $C8, $FF
SonAni_Float2:		dc.b    7, $C8, $C9, $CA, $CB, $CC, $CD, $CE, $CF, $FF
SonAni_Spring:		dc.b  $2F, $8E, $FD,   0
SonAni_Hang:		dc.b    1, $AA, $AB, $FF
AniSonic12:			dc.b   $F, $43, $43, $43, $FE,   1
SonAni_Landing:		dc.b    7, $B0, $B2, $B2, $B2, $B2, $B2, $B2, $B1, $B2, $B3, $B2, $FE,   4
SonAni_Hang2:		dc.b  $13, $91, $FF
SonAni_GetAir:		dc.b   $B, $AC, $AC,   3,   4, $FD,   0
SonAni_DeathBW:	dc.b  $20, $A8, $FF
SonAni_Drown:		dc.b  $20, $A9, $FF
SonAni_Death:		dc.b  $20, $A7, $FF
SonAni_Hurt:		dc.b    9, $D7, $D8, $FF
SonAni_Hurt2:		dc.b  $40, $8D, $FF
SonAni_Slide:		dc.b    9, $8C, $8D, $FF
SonAni_Blank:		dc.b  $77,   0, $FF
SonAni_Hurt3:		dc.b  $13, $D0, $D1, $FF
SonAni_Float3:		dc.b    3, $CF, $C8, $C9, $CA, $CB, $FE,   4
SonAni_Transform:	dc.b    2, $D2, $D2, $D3, $D3, $D4, $D5, $D6, $D5, $D6, $D5, $D6, $D5, $D6, $FD,   0
AniSonic20:			dc.b    9,   8,   9, $FF
AniSonic21:			dc.b    3,   7, $FD,   0
SonAni_Carry:		dc.b   $B, $90, $91, $92, $91, $FF
SonAni_Carry2:		dc.b   $B, $90, $91, $92, $91, $FD,   0
	even

id_Walk:			equ 0
id_Run:			equ 1
id_Roll:			equ 2
id_Roll2:			equ 3
id_Push:			equ 4
id_Wait:			equ 5
id_Balance:		equ 6
id_LookUp:		equ 7
id_Duck:			equ 8
id_SpinDash:		equ 9
id_Whistle:		equ $A
;				equ $B
id_Balance2:		equ $C
id_Stop:			equ $D
id_Float1:		equ $E
id_Float2:		equ $F
id_Spring:		equ $10
id_Hang:		equ $11
;				equ $12
id_Landing:		equ $13
id_Hang2:		equ $14
id_GetAir:		equ $15
id_DeathBW:		equ $16
id_Drown:		equ $17
id_Death:		equ $18
id_Hurt:			equ $19
id_Hurt2:		equ $1A
id_Slide:			equ $1B
id_Blank:		equ $1C
id_Hurt3:		equ $1D
id_Float3:		equ $1E
id_Transform:	equ $1F
;				equ $20
;				equ $21
id_Carry:		equ $22
id_Carry2:		equ $23
