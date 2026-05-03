; ---------------------------------------------------------------------------
; Sonic Animation Script
; ---------------------------------------------------------------------------

AniSonic: offsetTable
		ptrTableEntry.w SonAni_Walk		; 0
		ptrTableEntry.w SonAni_Run		; 1
		ptrTableEntry.w SonAni_Roll		; 2
		ptrTableEntry.w SonAni_Roll2		; 3
		ptrTableEntry.w SonAni_Push		; 4
		ptrTableEntry.w SonAni_Wait		; 5
		ptrTableEntry.w SonAni_Balance		; 6
		ptrTableEntry.w SonAni_LookUp		; 7
		ptrTableEntry.w SonAni_Duck		; 8
		ptrTableEntry.w SonAni_SpinDash		; 9
		ptrTableEntry.w SonAni_Whistle		; A (Unused)
		ptrTableEntry.w AniSonic0B		; B (Unused?)
		ptrTableEntry.w SonAni_Balance2		; C
		ptrTableEntry.w SonAni_Stop		; D
		ptrTableEntry.w SonAni_Float1		; E
		ptrTableEntry.w SonAni_Float2		; F
		ptrTableEntry.w SonAni_Spring		; 10
		ptrTableEntry.w SonAni_Hang		; 11
		ptrTableEntry.w AniSonic12		; 12 (Unused?)
		ptrTableEntry.w SonAni_Landing		; 13
		ptrTableEntry.w SonAni_Hang2		; 14
		ptrTableEntry.w SonAni_GetAir		; 15
		ptrTableEntry.w SonAni_DeathBW		; 16 (Unused)
		ptrTableEntry.w SonAni_Drown		; 17
		ptrTableEntry.w SonAni_Death		; 18
		ptrTableEntry.w SonAni_Hurt		; 19
		ptrTableEntry.w SonAni_Hurt2		; 1A
		ptrTableEntry.w SonAni_Slide		; 1B
		ptrTableEntry.w SonAni_Blank		; 1C
		ptrTableEntry.w SonAni_Hurt3		; 1D
		ptrTableEntry.w SonAni_Float3		; 1E
		ptrTableEntry.w SonAni_Transform	; 1F
		ptrTableEntry.w AniSonic20		; 20 (Unused?)
		ptrTableEntry.w AniSonic21		; 21 (Unused?)
		ptrTableEntry.w SonAni_Carry		; 22
		ptrTableEntry.w SonAni_Carry2		; 23

SonAni_Walk:			dc.b $FF, 7, 8, 1, 2, 3, 4, 5, 6, afEnd
SonAni_Run:			dc.b $FF, $21, $22, $23, $24, afEnd, afEnd, afEnd, afEnd, afEnd
SonAni_Roll:			dc.b $FE, $96, $97, $96, $98, $96, $99, $96, $9A, afEnd
SonAni_Roll2:			dc.b $FE, $96, $97, $96, $98, $96, $99, $96, $9A, afEnd
SonAni_Push:			dc.b $FD, $B6, $B7, $B8, $B9, afEnd, afEnd, afEnd, afEnd, afEnd
SonAni_Wait:			dc.b 5, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA
				dc.b $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA
				dc.b $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA, $BA
				dc.b $BA, $BA, $BA, $BB, $BC, $BC, $BD, $BD, $BE, $BE, $BD, $BD, $BE, $BE, $BD, $BD
				dc.b $BE, $BE, $BD, $BD, $BE, $BE, $BD, $BD, $BE, $BE, $BD, $BD, $BE, $BE, $BD, $BD
				dc.b $BE, $BE, $BD, $BD, $BE, $BE, $AD, $AD, $AD, $AD, $AD, $AD, $AE, $AE, $AE, $AE
				dc.b $AE, $AE, $AF, $D9, $D9, $D9, $D9, $D9, $D9, $AF, $AF, afBack, $35
SonAni_Balance:			dc.b 7, $A4, $A5, $A6, afEnd
SonAni_LookUp:			dc.b 5, $C3, $C4, afBack, 1
SonAni_Duck:			dc.b 5, $9B, $9C, afBack, 1
SonAni_SpinDash:		dc.b 0, $86, $87, $86, $88, $86, $89, $86, $8A, $86, $8B, afEnd
SonAni_Whistle:			dc.b 9, $BA, $C5, $C6, $C6, $C6, $C6, $C6, $C6, $C7, $C7, $C7, $C7, $C7, $C7, $C7
				dc.b $C7, $C7, $C7, $C7, $C7, afChange, 0
AniSonic0B:			dc.b $F, $8F, afEnd
SonAni_Balance2:		dc.b 5, $A1, $A2, $A3, afEnd
SonAni_Stop:			dc.b 3, $9D, $9E, $9F, $A0, afChange, 0
SonAni_Float1:			dc.b 7, $C8, afEnd
SonAni_Float2:			dc.b 7, $C8, $C9, $CA, $CB, $CC, $CD, $CE, $CF, afEnd
SonAni_Spring:			dc.b $2F, $8E, afChange, 0
SonAni_Hang:			dc.b 1, $AA, $AB, afEnd
AniSonic12:			dc.b $F, $43, $43, $43, afBack, 1
SonAni_Landing:			dc.b 7, $B0, $B2, $B2, $B2, $B2, $B2, $B2, $B1, $B2, $B3, $B2, afBack, 4
SonAni_Hang2:			dc.b $13, $91, afEnd
SonAni_GetAir:			dc.b $B, $AC, $AC, 3, 4, afChange, 0
SonAni_DeathBW:			dc.b $20, $A8, afEnd
SonAni_Drown:			dc.b $20, $A9, afEnd
SonAni_Death:			dc.b $20, $A7, afEnd
SonAni_Hurt:			dc.b 9, $D7, $D8, afEnd
SonAni_Hurt2:			dc.b $40, $8D, afEnd
SonAni_Slide:			dc.b 9, $8C, $8D, afEnd
SonAni_Blank:			dc.b $77, 0, afEnd
SonAni_Hurt3:			dc.b $13, $D0, $D1, afEnd
SonAni_Float3:			dc.b 3, $CF, $C8, $C9, $CA, $CB, afBack, 4
SonAni_Transform:		dc.b 2, $D2, $D2, $D3, $D3, $D4, $D5, $D6, $D5, $D6, $D5, $D6, $D5, $D6, afChange, 0
AniSonic20:			dc.b 9, 8, 9, afEnd
AniSonic21:			dc.b 3, 7, afChange, 0
SonAni_Carry:			dc.b $B, $90, $91, $92, $91, afEnd
SonAni_Carry2:			dc.b $B, $90, $91, $92, $91, afChange, 0
	even
