; ---------------------------------------------------------------------------
; Simple horizontal deformation
; Inputs:
; a2 = config: initial pixel+buffer, speed, deformation size
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

HScroll_Deform:
		move.w	(a2)+,d6
-		movea.w	(a2)+,a1
		move.w	(a2)+,d2
		move.w	(a2)+,d7
		ext.l	d2
		asl.l	#8,d2
-		add.l	d2,(a1)+
		dbf	d7,-
		dbf	d6,--
		rts
; End of function HScroll_Deform
; ---------------------------------------------------------------------------
; Simple vertical deformation
; Inputs:
; a1 = deformation buffer
; a2 = config: speed
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

VScroll_Deform:
		lea	(VDP_data_port).l,a6
		move.l	#vdpComm($0000,VSRAM,WRITE),VDP_control_port-VDP_data_port(a6)
		moveq	#((320*2)/16)-1,d6
-		move.w	(a2)+,d2
		ext.l	d2
		asl.l	#8,d2
		add.l	d2,(a1)
		move.w	(a1)+,VDP_data_port-VDP_data_port(a6)
		dbf	d6,-
		rts
; End of function VScroll_Deform
; ---------------------------------------------------------------
; Vladikcomper's Parallax Engine
; Version 0.50
; ---------------------------------------------------------------
; 2014, Vladikcomper
; ---------------------------------------------------------------

; for Parallax Engine
_normal		= $0000		; mode, speed
_moving		= $0200
_linear		= $0400
; ---------------------------------------------------------------
; Main routine that runs the script
; ---------------------------------------------------------------
; INPUT:
; a1	Script
; ---------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

ExecuteParallaxScript:
		lea	(H_scroll_buffer).w,a0
		move.w	(Camera_X_pos_copy).w,d0	; d0 = BG Position
		swap	d0
		clr.w	d0
		moveq	#0,d7

.ProcessBlock:
		move.b	(a1)+,d7						; load scrolling mode for the current block in script
		bmi.s	.Return						; if end of list reached, branch
		move.w	.ParallaxRoutines(pc,d7.w),d6
		move.b	(a1)+,d7						; load scrolling mode parameter
		jmp	.ParallaxRoutines(pc,d6.w)
; ---------------------------------------------------------------

.Return:
		rts
; ---------------------------------------------------------------

.ParallaxRoutines:
		dc.w	.Parallax_Normal-.ParallaxRoutines
		dc.w	.Parallax_Moving-.ParallaxRoutines
		dc.w	.Parallax_Linear-.ParallaxRoutines
; ---------------------------------------------------------------
; Scrolling routine: Static solid block
; ---------------------------------------------------------------
; Input:
; d7.w	$00PP, where PP is parameter
;
; Notice:
; Don't pollute the high byte of d7!
; ---------------------------------------------------------------

.Parallax_Normal:
		; Calculate positions
		move.l	d0,d1						; d1 = X (16.16)
		swap	d1							; d1 = X (Int)
		mulu.w	(a1)+,d1						; d1 = X*Coef (24.8)
		lsl.l	#8,d1							; d1 = X*Coef (16.16)
		move.w	(Camera_X_pos_copy).w,d1
		neg.w	d1
		swap	d1
		neg.w	d1							; d1 = $00BB, where BB is -X*Coef

		; Execute code according to number of lines set
		move.w	(a1)+,d6						; d6 = N, where N is Number of lines
		move.w	d6,d5						; d5 = N
		lsr.w	#5,d5						; d5 = N/32
		andi.w	#31,d6						; d6 = N%32
		neg.w	d6							; d6 = -N%32
		addi.w	#32,d6						; d6 = 32-N%32
		add.w	d6,d6
		jmp	.loop(pc,d6.w)
; ---------------------------------------------------------------

		; Main functional block (2 bytes per loop)
.loop:
	rept	32
		move.l	d1,(a0)+
	endm
		dbf	d5,.loop

		jmp	.ProcessBlock(pc)					; process next bloku!
; ---------------------------------------------------------------
; Scrolling routine: Moving solid block
; ---------------------------------------------------------------
; Input:
; d7.w	$00PP, where PP is parameter
;
; Notice:
; Don't pollute the high byte of d7!
; ---------------------------------------------------------------

.Parallax_Moving:
		; Calculate positions
		move.l	d0,d1						; d1 = X (16.16)
		swap	d1							; d1 = X (Int)
		mulu.w	(a1)+,d1						; d1 = X*Coef (24.8)
		lsl.l	#8,d1							; d1 = X*Coef (16.16)
		move.w	(Camera_X_pos_copy).w,d1
		neg.w	d1
		swap	d1
		neg.w	d1							; d1 = $00BB, where BB is -X*Coef

		; Add frame factor
		move.w	(Level_frame_counter).w,d3
		lsr.w	d7,d3
		sub.w	d3,d1

		; Execute code according to number of lines set
		move.w	(a1)+,d6						; d6 = N, where N is Number of lines
		move.w	d6,d5						; d5 = N
		lsr.w	#5,d5						; d5 = N/32
		andi.w	#31,d6						; d6 = N%32
		neg.w	d6							; d6 = -N%32
		addi.w	#32,d6						; d6 = 32-N%32
		add.w	d6,d6
		jmp	.loop(pc,d6.w)
; ---------------------------------------------------------------
; Scrolling routine: Linear Parallax / Psedo-surface
; ---------------------------------------------------------------
; Input:
; d7.w	$00PP, where PP is parameter
;
; Notice:
; Don't pollute the high byte of d7!
; ---------------------------------------------------------------

.Parallax_Linear:
		; Calculate positions
		move.l	d0,d1						; d1 = X (16.16)
		swap	d1							; d1 = X (Int)
		mulu.w	(a1)+,d1						; d1 = X*Coef (24.8)
		lsl.l	#8,d1							; d1 = X*Coef (16.16)
		neg.l	d1							; d1 = Initial position
		move.l	d1,d2
		asr.l	d7,d2							; d2 = Linear factor

		move.w	(Camera_X_pos_copy).w,d3
		neg.w	d3
		swap	d3

		; Execute code according to number of lines set
		move.w	(a1)+,d6						; d6 = N, where N is Number of lines
		move.w	d6,d5						; d5 = N
		lsr.w	#4,d5						; d5 = N/16
		andi.w	#15,d6						; d6 = N%16
		neg.w	d6							; d6 = -N%16
		addi.w	#16,d6						; d6 = 16-N%16
		move.w	d6,d4
		add.w	d6,d6
		add.w	d6,d6
		add.w	d4,d6
		add.w	d6,d6
		jmp	.loop2(pc,d6.w)
; ---------------------------------------------------------------

		; Main functional block (10 bytes per loop)
.loop2:
	rept	16
		swap	d1
		move.w	d1,d3
		move.l	d3,(a0)+
		swap	d1
		add.l	d2,d1
	endm
		dbf	d5,.loop2

		jmp	.ProcessBlock(pc)					; process next bloku!
; ---------------------------------------------------------------
; Special deformation routines
; ---------------------------------------------------------------

Parallax_DeformStatic:
		move.w	d7,d6
		lsr.w	#5,d6						; d6 = Lines / 32
		andi.w	#$1F,d7						; d7 = Lines % 32
		add.w	d7,d7						; d7 = (Lines % 32) * 2
		neg.w	d7
		jmp	.proc_base(pc,d7.w)
; ---------------------------------------------------------------

.proc:
	rept 32
		move.l	d0,(a1)+
	endm

.proc_base:
		dbf	d6,.proc
		rts
; ---------------------------------------------------------------

Parallax_DeformLinear:
		move.w	d7,d6
		lsr.w	#3,d6						; d6 = Lines / 8
		andi.w	#7,d7						; d7 = Lines % 8
		mulu.w	#10,d7						; d7 = (Lines % 8) * 10
		neg.w	d7
		jmp	.proc_base(pc,d7.w)
; ---------------------------------------------------------------

.proc:
	rept 8
		add.l	d2,d1
		swap	d1
		move.w	d1,d0
		move.l	d0,(a1)+
		swap	d1
	endm

.proc_base:
		dbf	d6,.proc
		rts
; End of function ExecuteParallaxScript
