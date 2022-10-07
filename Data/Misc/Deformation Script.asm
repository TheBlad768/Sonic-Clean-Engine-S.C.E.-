; ---------------------------------------------------------------------------
; Simple horizontal deformation
; Inputs:
; a2 = config: initial pixel+buffer, speed, deformation size
; a3 = deformation buffer
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

HScroll_Deform:
		move.w	(a2)+,d6

.loop2
		movea.w	(a2)+,a1
		move.w	(a2)+,d2
		move.w	(a2)+,d5
		ext.l	d2
		asl.l	#8,d2

.loop
		add.l	d2,(a3)
		move.w	(a3)+,(a1)
		addq.w	#4,a1
		addq.w	#2,a3
		dbf	d5,.loop
		dbf	d6,.loop2
		rts

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
		moveq	#bytesToXcnt((320*2),16),d6

.loop
		move.w	(a2)+,d2
		ext.l	d2
		asl.l	#8,d2
		add.l	d2,(a1)
		move.w	(a1)+,VDP_data_port-VDP_data_port(a6)
		dbf	d6,.loop
		rts

; ---------------------------------------------------------------------------
; Plain deformation
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

PlainDeformation:
		lea	(H_scroll_buffer).w,a1
		move.w	(Camera_X_pos_copy).w,d0
		neg.w	d0
		swap	d0
		move.w	(Camera_X_pos_BG_copy).w,d0
		neg.w	d0
		moveq	#bytesToXcnt(224,8),d1

.loop
	rept 8
		move.l	d0,(a1)+
	endr
		dbf	d1,.loop
		rts

; ---------------------------------------------------------------------------
; Plain deformation (flipped)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

PlainDeformation_Flipped:
		lea	(H_scroll_buffer).w,a1
		move.w	(Camera_X_pos_BG_copy).w,d0
		neg.w	d0
		swap	d0
		move.w	(Camera_X_pos_copy).w,d0
		neg.w	d0
		moveq	#bytesToXcnt(224,8),d1

.loop
	rept 8
		move.l	d0,(a1)+
	endr
		dbf	d1,.loop
		rts

; ---------------------------------------------------------------------------
; FG deform
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

MakeFGDeformArray:
		move.w	d1,d0
		lsr.w	#1,d0
		bcc.s	.skip

.loop
		move.w	(a6)+,d5
		add.w	d6,d5
		move.w	d5,(a1)+

.skip
		move.w	(a6)+,d5
		add.w	d6,d5
		move.w	d5,(a1)+
		dbf	d0,.loop
		rts

; ---------------------------------------------------------------------------
; Foreground scrolling
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

FGScroll_Deformation:
		lea	(HScroll_Shift).w,a1

.main
		move.w	(a1)+,d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,(a1)	; HScroll_Shift+2

.scroll
		move.w	(a1),d0	; HScroll_Shift+2
		neg.w	d0
		lea	(H_scroll_buffer).w,a1
		moveq	#bytesToXcnt(224,8),d1

.loop

	rept	8
		move.w	(a1),d2
		add.w	d0,d2
		move.w	d2,(a1)
		addq.w	#4,a1		; skip FBG
	endr

		dbf	d1,.loop
		rts

; =============== S U B R O U T I N E =======================================

ApplyDeformation:
		move.w	#224-1,d1

ApplyDeformation3:
		lea	(H_scroll_buffer).w,a1
		move.w	(Camera_Y_pos_BG_copy).w,d0
		move.w	(Camera_X_pos_copy).w,d3

ApplyDeformation2:
		move.w	(a4)+,d2
		smi	d4
		bpl.s	loc_4F0E8
		andi.w	#$7FFF,d2

loc_4F0E8:
		sub.w	d2,d0
		bmi.s	loc_4F0FA
		addq.w	#2,a5
		tst.b	d4
		beq.s	ApplyDeformation2
		subq.w	#2,a5
		add.w	d2,d2
		adda.w	d2,a5
		bra.s	ApplyDeformation2
; ---------------------------------------------------------------------------

loc_4F0FA:
		tst.b	d4
		beq.s	loc_4F104
		add.w	d0,d2
		add.w	d2,d2
		adda.w	d2,a5

loc_4F104:
		neg.w	d0
		move.w	d1,d2
		sub.w	d0,d2
		bcc.s	loc_4F110
		move.w	d1,d0
		addq.w	#1,d0

loc_4F110:
		neg.w	d3
		swap	d3

loc_4F114:
		subq.w	#1,d0

loc_4F116:
		tst.b	d4
		beq.s	loc_4F130
		lsr.w	#1,d0
		bcc.s	loc_4F124

loc_4F11E:
		move.w	(a5)+,d3
		neg.w	d3
		move.l	d3,(a1)+

loc_4F124:
		move.w	(a5)+,d3
		neg.w	d3
		move.l	d3,(a1)+
		dbf	d0,loc_4F11E
		bra.s	loc_4F140
; ---------------------------------------------------------------------------

loc_4F130:
		move.w	(a5)+,d3
		neg.w	d3
		lsr.w	#1,d0
		bcc.s	loc_4F13A

loc_4F138:
		move.l	d3,(a1)+

loc_4F13A:
		move.l	d3,(a1)+
		dbf	d0,loc_4F138

loc_4F140:
		tst.w	d2
		bmi.s	locret_4F158
		move.w	(a4)+,d0
		smi	d4
		bpl.s	loc_4F14E
		andi.w	#$7FFF,d0

loc_4F14E:
		move.w	d2,d3
		sub.w	d0,d2
		bpl.s	loc_4F114
		move.w	d3,d0
		bra.s	loc_4F116
; ---------------------------------------------------------------------------

locret_4F158:
		rts

; =============== S U B R O U T I N E =======================================

ApplyFGDeformation:
		move.w	#224-1,d1

ApplyFGDeformation3:
		lea	(H_scroll_buffer).w,a1
		move.w	(Camera_Y_pos_copy).w,d0
		move.w	(Camera_X_pos_BG_copy).w,d3

ApplyFGDeformation2:
		move.w	(a4)+,d2
		smi	d4
		bpl.s	loc_4F174
		andi.w	#$7FFF,d2

loc_4F174:
		sub.w	d2,d0
		bmi.s	loc_4F186
		addq.w	#2,a5
		tst.b	d4
		beq.s	ApplyFGDeformation2
		subq.w	#2,a5
		add.w	d2,d2
		adda.w	d2,a5
		bra.s	ApplyFGDeformation2
; ---------------------------------------------------------------------------

loc_4F186:
		tst.b	d4
		beq.s	loc_4F190
		add.w	d0,d2
		add.w	d2,d2
		adda.w	d2,a5

loc_4F190:
		neg.w	d0
		move.w	d1,d2
		sub.w	d0,d2
		bcc.s	loc_4F19C
		move.w	d1,d0
		addq.w	#1,d0

loc_4F19C:
		neg.w	d3

loc_4F19E:
		subq.w	#1,d0

loc_4F1A0:
		tst.b	d4
		beq.s	loc_4F1C2
		lsr.w	#1,d0
		bcc.s	loc_4F1B2

loc_4F1A8:
		swap	d3
		move.w	(a5)+,d3
		neg.w	d3
		swap	d3
		move.l	d3,(a1)+

loc_4F1B2:
		swap	d3
		move.w	(a5)+,d3
		neg.w	d3
		swap	d3
		move.l	d3,(a1)+
		dbf	d0,loc_4F1A8
		bra.s	loc_4F1D6
; ---------------------------------------------------------------------------

loc_4F1C2:
		swap	d3
		move.w	(a5)+,d3
		neg.w	d3
		swap	d3
		lsr.w	#1,d0
		bcc.s	loc_4F1D0

loc_4F1CE:
		move.l	d3,(a1)+

loc_4F1D0:
		move.l	d3,(a1)+
		dbf	d0,loc_4F1CE

loc_4F1D6:
		tst.w	d2
		bmi.s	locret_4F1EE
		move.w	(a4)+,d0
		smi	d4
		bpl.s	loc_4F1E4
		andi.w	#$7FFF,d0

loc_4F1E4:
		move.w	d2,d1
		sub.w	d0,d2
		bpl.s	loc_4F19E
		move.w	d1,d0
		bra.s	loc_4F1A0
; ---------------------------------------------------------------------------

locret_4F1EE:
		rts

; =============== S U B R O U T I N E =======================================

ApplyFGandBGDeformation:
		swap	d7
		swap	d3

ApplyFGandBGDeformation2:
		move.w	(a4)+,d3
		smi	d7
		bpl.s	loc_4F1FE
		andi.w	#$7FFF,d3

loc_4F1FE:
		sub.w	d3,d0
		bmi.s	loc_4F210
		addq.w	#2,a5
		tst.b	d7
		beq.s	ApplyFGandBGDeformation2
		subq.w	#2,a5
		add.w	d3,d3
		adda.w	d3,a5
		bra.s	ApplyFGandBGDeformation2
; ---------------------------------------------------------------------------

loc_4F210:
		tst.b	d7
		beq.s	loc_4F21A
		add.w	d0,d3
		add.w	d3,d3
		adda.w	d3,a5

loc_4F21A:
		swap	d3
		neg.w	d0
		move.w	d1,d4
		sub.w	d0,d4
		bcc.s	loc_4F228
		move.w	d1,d0
		addq.w	#1,d0

loc_4F228:
		subq.w	#1,d0

loc_4F22A:
		tst.b	d7
		beq.s	loc_4F250
		lsr.w	#1,d0
		bcc.s	loc_4F23E

loc_4F232:
		move.w	(a2)+,d6
		swap	d6
		move.w	(a5)+,d6
		neg.w	d6
		add.w	(a6)+,d6
		move.l	d6,(a1)+

loc_4F23E:
		move.w	(a2)+,d6
		swap	d6
		move.w	(a5)+,d6
		neg.w	d6
		add.w	(a6)+,d6
		move.l	d6,(a1)+
		dbf	d0,loc_4F232
		bra.s	loc_4F270
; ---------------------------------------------------------------------------

loc_4F250:
		move.w	(a5)+,d5
		neg.w	d5
		lsr.w	#1,d0
		bcc.s	loc_4F262

loc_4F258:
		move.w	(a2)+,d6
		swap	d6
		move.w	(a6)+,d6
		add.w	d5,d6
		move.l	d6,(a1)+

loc_4F262:
		move.w	(a2)+,d6
		swap	d6
		move.w	(a6)+,d6
		add.w	d5,d6
		move.l	d6,(a1)+
		dbf	d0,loc_4F258

loc_4F270:
		tst.w	d4
		bmi.s	loc_4F288
		move.w	(a4)+,d0
		smi	d7
		bpl.s	loc_4F27E
		andi.w	#$7FFF,d0

loc_4F27E:
		move.w	d4,d5
		sub.w	d0,d4
		bpl.s	loc_4F228
		move.w	d5,d0
		bra.s	loc_4F22A
; ---------------------------------------------------------------------------

loc_4F288:
		swap	d7
		rts

; =============== S U B R O U T I N E =======================================

Apply_FGVScroll:
		lea	(V_scroll_buffer).w,a1

Apply_FGVScroll2:
		move.w	(Camera_Y_pos_BG_copy).w,d1
		move.w	(Camera_X_pos_copy).w,d0
		move.w	d0,d2
		andi.w	#$F,d2
		beq.s	loc_4F2A4
		addi.w	#$10,d0

loc_4F2A4:
		lsr.w	#4,d0

loc_4F2A6:
		addq.w	#2,a5
		move.w	(a4)+,d2
		lsr.w	#4,d2
		sub.w	d2,d0
		bpl.s	loc_4F2A6
		neg.w	d0
		moveq	#$13,d2
		sub.w	d0,d2
		bcc.s	loc_4F2BA
		moveq	#$14,d0

loc_4F2BA:
		subq.w	#1,d0

loc_4F2BC:
		move.w	(a5)+,d3

loc_4F2BE:
		move.w	d3,(a1)+
		move.w	d1,(a1)+
		dbf	d0,loc_4F2BE
		tst.w	d2
		bmi.s	locret_4F2D8
		move.w	(a4)+,d0
		lsr.w	#4,d0
		move.w	d2,d3
		sub.w	d0,d2
		bpl.s	loc_4F2BA
		move.w	d3,d0
		bra.s	loc_4F2BC
; ---------------------------------------------------------------------------

locret_4F2D8:
		rts

; ---------------------------------------------------------------
; Vladikcomper's Parallax Engine
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
		lea	(H_scroll_table).w,a5
		move.w	(Camera_X_pos_copy).w,d0			; d0 = BG Position
		swap	d0
		clr.w	d0
		moveq	#0,d4

ExecuteParallaxScript_ProcessBlock:
		move.b	(a1)+,d4								; load scrolling mode for the current block in script
		bmi.s	locret_4F2D8							; if end of list reached, branch
		move.w	ExecuteParallaxScript_Index(pc,d4.w),d5
		move.b	(a1)+,d4								; load scrolling mode parameter
		jmp	ExecuteParallaxScript_Index(pc,d5.w)
; ---------------------------------------------------------------

ExecuteParallaxScript_Index: offsetTable
		offsetTableEntry.w ExecuteParallaxScript_Parallax_Normal		; 0
		offsetTableEntry.w ExecuteParallaxScript_Parallax_Moving		; 2
		offsetTableEntry.w ExecuteParallaxScript_Parallax_Linear		; 4
; ---------------------------------------------------------------
; Scrolling routine: Static solid block
; ---------------------------------------------------------------
; Input:
; d4.w	$00PP, where PP is parameter
;
; Notice:
; Don't pollute the high byte of d4!
; ---------------------------------------------------------------

ExecuteParallaxScript_Parallax_Normal:
		; Calculate positions
		move.l	d0,d1
		swap	d1
		add.w	(HScroll_Shift+2).w,d1
		mulu.w	(a1)+,d1
		lsl.l	#8,d1
		swap	d1
		move.w	d1,(a5)+

		bra.s	ExecuteParallaxScript_ProcessBlock		
; ---------------------------------------------------------------
; Scrolling routine: Moving solid block
; ---------------------------------------------------------------
; Input:
; d4.w	$00PP, where PP is parameter
;
; Notice:
; Don't pollute the high byte of d4!
; ---------------------------------------------------------------

ExecuteParallaxScript_Parallax_Moving:
		; Calculate positions
		move.l	d0,d1
		swap	d1
		add.w	(HScroll_Shift+2).w,d1
		mulu.w	(a1)+,d1
		lsl.l	#8,d1
		swap	d1

		; Add frame factor
		move.w	(Level_frame_counter).w,d3
		lsr.w	d4,d3
		add.w	d3,d1
		move.w	d1,(a5)+

		bra.s	ExecuteParallaxScript_ProcessBlock		
; ---------------------------------------------------------------
; Scrolling routine: Linear Parallax / Psedo-surface
; ---------------------------------------------------------------
; Input:
; d4.w	$00PP, where PP is parameter
;
; Notice:
; Don't pollute the high byte of d4!
; ---------------------------------------------------------------

ExecuteParallaxScript_Parallax_Linear:
		; Calculate positions
		move.l	d0,d1
		swap	d1
		add.w	(HScroll_Shift+2).w,d1
		muls.w	(a1)+,d1
		lsl.l	#8,d1
		move.l	d1,d2
		asr.l	d4,d2

		; Execute code according to number of lines set
		move.w	(a1)+,d6						; d5 = N, where N is Number of lines
		subq.w	#1,d6
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
		jmp	.loop(pc,d6.w)
; ---------------------------------------------------------------

		; Main functional block (10 bytes per loop)

.loop
	rept	16
		swap	d1
		move.w	d1,d3
		move.w	d3,(a5)+
		swap	d1
		add.l	d2,d1
	endr
		dbf	d5,.loop

		bra.w	ExecuteParallaxScript_ProcessBlock
