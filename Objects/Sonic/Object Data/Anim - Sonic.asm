; ---------------------------------------------------------------------------
; Sonic Animation Script
; ---------------------------------------------------------------------------

AniSonic:
Ani_Sonic:
		dc.w SonAni_Walk-Ani_Sonic			; 0
		dc.w SonAni_Run-Ani_Sonic			; 1
		dc.w SonAni_Roll-Ani_Sonic			; 2
		dc.w SonAni_Roll2-Ani_Sonic			; 3
		dc.w SonAni_Push-Ani_Sonic			; 4
		dc.w SonAni_Wait-Ani_Sonic			; 5
		dc.w SonAni_Balance-Ani_Sonic		; 6
		dc.w SonAni_LookUp-Ani_Sonic		; 7
		dc.w SonAni_Duck-Ani_Sonic			; 8
		dc.w SonAni_Spin_Dash-Ani_Sonic		; 9
		dc.w byte_12BA8-Ani_Sonic			; A
		dc.w byte_12BBF-Ani_Sonic			; B
		dc.w SonAni_Balance2-Ani_Sonic		; C
		dc.w SonAni_Stop-Ani_Sonic			; D
		dc.w SonAni_Float1-Ani_Sonic			; E
		dc.w SonAni_Float2-Ani_Sonic			; F
		dc.w SonAni_Spring-Ani_Sonic			; 10
		dc.w SonAni_LZHang-Ani_Sonic		; 11
		dc.w SonAni_Leap1-Ani_Sonic			; 12
		dc.w SonAni_Landing-Ani_Sonic		; 13
		dc.w SonAni_Surf-Ani_Sonic			; 14
		dc.w SonAni_Bubble-Ani_Sonic			; 15
		dc.w SonAni_Death1-Ani_Sonic			; 16
		dc.w SonAni_Drown-Ani_Sonic			; 17
		dc.w SonAni_Death2-Ani_Sonic			; 18
		dc.w SonAni_Shrink-Ani_Sonic			; 19
		dc.w SonAni_Hurt-Ani_Sonic			; 1A
		dc.w SonAni_Blank-Ani_Sonic			; 1B
		dc.w SonAni_Float3-Ani_Sonic			; 1C
		dc.w SonAni_Float4-Ani_Sonic			; 1D
		dc.w SonAni_Run2-Ani_Sonic			; 1E

SonAni_Walk:		dc.b  $FF,   7,	  8,   1,   2,	 3,   4,   5,	6, $FF
SonAni_Run:			dc.b  $FF, $21,	$22, $23, $24, $FF, $FF, $FF, $FF, $FF
SonAni_Roll:			dc.b  $FE, $96,	$97, $96, $98, $96, $99, $96, $9A, $FF
SonAni_Roll2:		dc.b  $FE, $96,	$97, $96, $98, $96, $99, $96, $9A, $FF
SonAni_Push:		dc.b  $FD, $B6,	$B7, $B8, $B9, $FF, $FF, $FF, $FF, $FF
SonAni_Wait:		dc.b    5, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA
					dc.b  $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA
					dc.b  $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BB, $BC, $BC, $BD, $BD, $BE, $BE, $BD, $BD
					dc.b  $BE, $BE, $BD, $BD, $BE, $BE, $BD, $BD, $BE, $BE, $BD, $BD, $BE, $BE, $BD, $BD, $BE, $BE, $BD, $BD
					dc.b  $BE, $BE, $BD, $BD, $BE, $BE, $AD, $AD, $AD, $AD, $AD, $AD, $AE, $AE, $AE, $AE, $AE, $AE, $AF, $D9
					dc.b  $D9, $D9, $D9, $D9, $D9, $AF, $AF, $FE, $35
SonAni_Balance:		dc.b	7, $A4,	$A5, $A6, $FF
SonAni_LookUp:		dc.b	5, $C3,	$C4, $FE,   1
SonAni_Duck:		dc.b	5, $9B,	$9C, $FE,   1
SonAni_Spin_Dash:	dc.b	0, $86,	$87, $86, $88, $86, $89, $86, $8A, $86,	$8B, $FF

byte_12BA8:			dc.b	9, $BA,	$C5, $C6, $C6, $C6, $C6, $C6, $C6, $C7,	$C7, $C7, $C7, $C7, $C7, $C7, $C7, $C7,	$C7, $C7
					dc.b  $C7, $FD,   0
byte_12BBF:			dc.b   $F, $8F,	$FF
SonAni_Balance2:		dc.b	5, $A1,	$A2, $A3, $FF

SonAni_Stop:			dc.b	3, $9D,	$9E, $9F, $A0, $FD,   0
SonAni_Float1:		dc.b	7, $C8,	$FF
SonAni_Float2:		dc.b	7, $C8,	$C9, $CA, $CB, $CC, $CD, $CE, $CF, $FF
SonAni_Spring:		dc.b  $2F, $8E,	$FD,   0
SonAni_LZHang:		dc.b	1, $AA,	$AB, $FF
SonAni_Leap1:		dc.b   $F, $43,	$43, $43, $FE,	 1
SonAni_Landing:		dc.b	7, $B0,	$B2, $B2, $B2, $B2, $B2, $B2, $B1, $B2,	$B3, $B2, $FE,	 4
SonAni_Surf:			dc.b  $13, $91,	$FF
SonAni_Bubble:		dc.b   $B, $AC,	$AC,   3,   4, $FD,   0
SonAni_Death1:		dc.b  $20, $A8,	$FF
SonAni_Drown:		dc.b  $20, $A7,	$FF
SonAni_Death2:		dc.b	$20, $A7,	$FF
SonAni_Shrink:		dc.b  $40, $8D,	$FF
SonAni_Hurt:		dc.b 9, $8C, $8D, $FF
SonAni_Blank:		dc.b $77,   0,	$FF
SonAni_Float3:		dc.b 3,	$3C, $3D, $53, $3E, $54, $FF, 0
SonAni_Float4:		dc.b 3,	$3C, $FD, 0
SonAni_Run2:		dc.b  2, $21,	$22, $23, $24, $FF
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
id_Blink			equ $A
id_GetUp		equ $B
id_Balance2:		equ $C
id_Stop:			equ $D
id_Float1:		equ $E
id_Float2:		equ $F
id_Spring:		equ $10
id_Hang:		equ $11
id_Leap1:		equ $12
id_Landing:		equ $13
id_Surf:			equ $14
id_GetAir:		equ $15
id_Burnt:		equ $16
id_Drown:		equ $17
id_Death:		equ $18
id_Shrink:		equ $19
id_Hurt:			equ $1A
id_Null:			equ $1B
id_Float3:		equ $1C
id_Float4:		equ $1D
id_Run2:		equ $1E