; ---------------------------------------------------------------------------
; Level Select
; ---------------------------------------------------------------------------

; Constants
LevelSelect_Offset:				= *
LevelSelect_VRAM:				= 0

; Variables
LevelSelect_ZoneCount:			= ZoneCount
LevelSelect_ActDEZCount:			= 4	; DEZ

LevelSelect_MusicTestCount:		= 8
LevelSelect_SoundTestCount:		= LevelSelect_MusicTestCount+1
LevelSelect_SampleTestCount:		= LevelSelect_SoundTestCount+1
LevelSelect_MaxCount:			= 11
LevelSelect_MaxMusicNumber:		= (mus__Last-mus__First)
LevelSelect_MaxSoundNumber:		= (sfx__Last-sfx__First)
LevelSelect_MaxSampleNumber:	= (dac__Last-dac__First)

; RAM
	phase ramaddr(Object_load_addr_front)

vLevelSelect_MusicCount:			ds.w 1
vLevelSelect_SoundCount:			ds.w 1
vLevelSelect_SampleCount:			ds.w 1
vLevelSelect_CtrlTimer:			ds.w 1
vLevelSelect_SaveAct:				ds.w 1
vLevelSelect_VCount:				ds.w 1
vLevelSelect_HCount:				ds.w $10

	dephase
	!org	LevelSelect_Offset

; =============== S U B R O U T I N E =======================================

LevelSelect_Screen:
		music	mus_Stop											; stop music
		jsr	(Clear_Kos_Module_Queue).w								; clear KosM PLCs
		ResetDMAQueue												; clear DMA queue
		jsr	(Pal_FadeToBlack).w
		disableInts
		move.l	#VInt,(V_int_addr).w
		move.l	#HInt,(H_int_addr).w
		disableScreen
		jsr	(Clear_DisplayData).w
		lea	Level_VDP(pc),a1
		jsr	(Load_VDP).w
		jsr	(Clear_Palette).w
		clearRAM RAM_start, (RAM_start+$1000)						; clear foreground buffer
		clearRAM Object_RAM, Object_RAM_end
		clearRAM Lag_frame_count, Lag_frame_count_end
		clearRAM Camera_RAM, Camera_RAM_end
		clearRAM Oscillating_variables, Oscillating_variables_end
		moveq	#0,d0
		move.b	d0,(Water_full_screen_flag).w
		move.b	d0,(Water_flag).w
		move.w	d0,(Current_zone_and_act).w
		move.w	d0,(Apparent_zone_and_act).w
		move.b	d0,(Last_star_post_hit).w
		move.b	d0,(Debug_mode_flag).w

		; load main art
		lea	(ArtKosM_LevelSelectText).l,a1
		move.w	#tiles_to_bytes(1),d2
		jsr	(Queue_Kos_Module).w

		; load main palette
		lea	(Pal_LevelSelect).l,a1
		lea	(Target_palette).w,a2
		jsr	(PalLoad_Line32).w

		; load text
		bsr.w	LevelSelect_LoadText
		move.w	#palette_line_1+LevelSelect_VRAM,d3
		bsr.w	LevelSelect_LoadMainText
		move.w	#palette_line_0+LevelSelect_VRAM,d3
		bsr.w	LevelSelect_MarkFields_Index.drawmusic
		move.w	#palette_line_0+LevelSelect_VRAM,d3
		bsr.w	LevelSelect_MarkFields_Index.drawsound
		move.w	#palette_line_0+LevelSelect_VRAM,d3
		bsr.w	LevelSelect_MarkFields_Index.drawsample
		move.w	#palette_line_1,d3
		bsr.w	LevelSelect_MarkFields

.waitplc
		move.b	#VintID_Fade,(V_int_routine).w
		jsr	(Process_Kos_Queue).w
		jsr	(Wait_VSync).w
		jsr	(Process_Kos_Module_Queue).w
		tst.w	(Kos_modules_left).w
		bne.s	.waitplc
		move.b	#VintID_Main,(V_int_routine).w
		jsr	(Wait_VSync).w
		enableScreen
		jsr	(Pal_FadeFromBlack).w

.loop
		move.b	#VintID_Main,(V_int_routine).w
		jsr	(Wait_VSync).w
		bsr.w	LevelSelect_Deform
		disableInts
		moveq	#palette_line_0,d3
		bsr.w	LevelSelect_MarkFields
		bsr.s	LevelSelect_Controls
		move.w	#palette_line_1,d3
		bsr.w	LevelSelect_MarkFields
		enableInts
		cmpi.w	#LevelSelect_ZoneCount,(vLevelSelect_VCount).w
		bhs.s	.loop
		tst.b	(Ctrl_1_pressed).w
		bpl.s	.loop

		; load zone and act
		move.b	#id_LevelScreen,(Game_mode).w	; set screen mode to level
		move.w	(vLevelSelect_VCount).w,d2
		move.b	d2,(sp)
		move.w	(sp),d2
		clr.b	d2
		add.w	(vLevelSelect_SaveAct).w,d2
		move.w	d2,(Current_zone_and_act).w
		move.w	d2,(Apparent_zone_and_act).w
		rts

; ---------------------------------------------------------------------------
; Check vertical line
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

LevelSelect_Controls:

		; set vertical line
		move.w	#LevelSelect_MaxCount-1,d2
		move.w	(vLevelSelect_VCount).w,d3
		lea	(vLevelSelect_CtrlTimer).w,a3
		bsr.w	LevelSelect_FindUpDownControls
		move.w	d3,(vLevelSelect_VCount).w

		; check vertical line
		cmpi.w	#LevelSelect_ZoneCount,d3
		blo.s		LevelSelect_Controls_ZoneAndAct
		subq.w	#LevelSelect_MusicTestCount,d3
		blo.s		LevelSelect_Controls_ZoneAndAct.return
		add.w	d3,d3
		move.w	LevelSelect_Index(pc,d3.w),d3
		jmp	LevelSelect_Index(pc,d3.w)
; ---------------------------------------------------------------------------

LevelSelect_Index: offsetTable
		offsetTableEntry.w LevelSelect_LoadMusicNumber			; 0
		offsetTableEntry.w LevelSelect_LoadSoundNumber			; 2
		offsetTableEntry.w LevelSelect_LoadSampleNumber		; 4
; ---------------------------------------------------------------------------

LevelSelect_Controls_ZoneAndAct:
		lea	(vLevelSelect_HCount).w,a0
		move.w	(vLevelSelect_VCount).w,d4
		add.w	d4,d4
		move.w	(a0,d4.w),d3
		move.w	LevelSelect_LoadMaxActs(pc,d4.w),d2
		lea	(vLevelSelect_CtrlTimer).w,a3
		bsr.w	LevelSelect_FindLeftRightControls
		move.w	d3,(a0,d4.w)
		move.w	d3,(vLevelSelect_SaveAct).w

.return
		rts
; ---------------------------------------------------------------------------

LevelSelect_LoadMaxActs:
		dc.w LevelSelect_ActDEZCount-1	; DEZ

		zonewarning LevelSelect_LoadMaxActs,2

; ---------------------------------------------------------------------------
; Load Music
; ---------------------------------------------------------------------------

LevelSelect_LoadMusicNumber:
		moveq	#LevelSelect_MaxMusicNumber,d2
		move.w	(vLevelSelect_MusicCount).w,d3
		lea	(vLevelSelect_CtrlTimer).w,a3
		bsr.w	LevelSelect_FindLeftRightControls
		move.w	d3,(vLevelSelect_MusicCount).w

		; check ctrl
		moveq	#btnABC,d1
		and.b	(Ctrl_1_pressed).w,d1
		beq.s	LevelSelect_Controls_ZoneAndAct.return

		; play music
		move.w	d3,d0
		addq.w	#mus__First,d0				; $00 is reserved for silence
		jmp	(SMPS_QueueSound1).w			; play music

; ---------------------------------------------------------------------------
; Load Sound
; ---------------------------------------------------------------------------

LevelSelect_LoadSoundNumber:
		moveq	#LevelSelect_MaxSoundNumber,d2
		move.w	(vLevelSelect_SoundCount).w,d3
		lea	(vLevelSelect_CtrlTimer).w,a3
		bsr.s	LevelSelect_FindLeftRightControls
		move.w	d3,(vLevelSelect_SoundCount).w

		; check ctrl
		moveq	#btnABC,d1
		and.b	(Ctrl_1_pressed).w,d1
		beq.s	LevelSelect_Controls_ZoneAndAct.return

		; play sfx
		move.w	d3,d0
		addi.w	#sfx__First,d0				; skip music
		jmp	(SMPS_QueueSound2).w			; play sfx

; ---------------------------------------------------------------------------
; Load Sample
; ---------------------------------------------------------------------------

LevelSelect_LoadSampleNumber:
		moveq	#LevelSelect_MaxSampleNumber,d2
		move.w	(vLevelSelect_SampleCount).w,d3
		lea	(vLevelSelect_CtrlTimer).w,a3
		bsr.s	LevelSelect_FindLeftRightControls
		move.w	d3,(vLevelSelect_SampleCount).w

		; check ctrl
		moveq	#btnABC,d1
		and.b	(Ctrl_1_pressed).w,d1
		beq.s	LevelSelect_Controls_ZoneAndAct.return

		; play sample
		move.w	d3,d0
		addi.w	#dac__First,d0				; $80 is reserved for pause
		jmp	(SMPS_PlayDACSample).w			; play sample

; ---------------------------------------------------------------------------
; Control (Up/Down)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

LevelSelect_FindUpDownControls:
		moveq	#btnUD,d1
		and.b	(Ctrl_1_pressed).w,d1
		beq.s	.notpressed
		move.w	#16,(a3)
		bra.s	.pressed
; --------------------------------------------------------------------------

.notpressed
		moveq	#btnUD,d1
		and.b	(Ctrl_1_held).w,d1
		beq.s	.returnup
		subq.w	#1,(a3)
		bpl.s	.returnup
		addq.w	#4,(a3)

.pressed
		btst	#button_up,d1
		beq.s	.notdown
		subq.w	#1,d3
		bpl.s	.returnup
		move.w	d2,d3

.returnup
		rts
; ---------------------------------------------------------------------------

.notdown
		addq.w	#1,d3
		cmp.w	d2,d3
		bls.s		.returndown
		moveq	#0,d3

.returndown
		rts

; ---------------------------------------------------------------------------
; Control (Left/Right)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

LevelSelect_FindLeftRightControls:
		moveq	#btnLR,d1
		and.b	(Ctrl_1_pressed).w,d1
		beq.s	.notpressed
		move.w	#16,(a3)
		bra.s	.pressed
; --------------------------------------------------------------------------

.notpressed
		moveq	#btnLR,d1
		and.b	(Ctrl_1_held).w,d1
		beq.s	.returnleft
		subq.w	#1,(a3)
		bpl.s	.returnleft
		addq.w	#4,(a3)

.pressed
		btst	#button_left,d1
		beq.s	.notright
		subq.w	#1,d3
		bpl.s	.returnleft
		move.w	d2,d3

.returnleft
		rts
; ---------------------------------------------------------------------------

.notright
		addq.w	#1,d3
		cmp.w	d2,d3
		bls.s		.returnright
		moveq	#0,d3

.returnright
		rts

; ---------------------------------------------------------------------------
; Draw act
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

LevelSelect_LoadAct:
		locVRAM	$C2B0,d2
		lea	(vLevelSelect_HCount).w,a0
		move.w	(vLevelSelect_VCount).w,d0
		move.w	d0,d1
		move.b	d0,(sp)
		move.w	(sp),d0
		clr.b	d0
		swap	d0
		clr.w	d0
		add.l	d0,d2
		move.l	d2,VDP_control_port-VDP_control_port(a5)
		add.w	d1,d1
		move.w	(a0,d1.w),d0
		add.w	d1,d1
		add.w	d1,d1
		add.w	d0,d0
		add.w	d1,d0
		move.w	LevelSelect_ActTextIndex(pc,d0.w),d0
		lea	LevelSelect_ActTextIndex(pc,d0.w),a0
		bra.s	LevelSelect_LoadMainText.loadtext

; =============== S U B R O U T I N E =======================================

LevelSelect_LoadMainText:
		lea	(VDP_data_port).l,a6
		lea	VDP_control_port-VDP_data_port(a6),a5
		locVRAM	$C080,VDP_control_port-VDP_control_port(a5)
		lea	LevelSelect_MainText(pc),a0

.loadtext
		moveq	#0,d6
		move.b	(a0)+,d6

.copy
		moveq	#0,d0
		move.b	(a0)+,d0
		add.w	d3,d0
		move.w	d0,VDP_data_port-VDP_data_port(a6)
		dbf	d6,.copy
		rts
; --------------------------------------------------------------------------

LevelSelect_ActTextIndex: offsetTable
		offsetTableEntry.w LevelSelect_LoadAct1		; DEZ1
		offsetTableEntry.w LevelSelect_LoadAct2		; DEZ2
		offsetTableEntry.w LevelSelect_LoadAct3		; DEZ3
		offsetTableEntry.w LevelSelect_LoadAct4		; DEZ4

		zonewarning LevelSelect_ActTextIndex,(2*4)
; --------------------------------------------------------------------------

LevelSelect_LoadAct1:
		levselstr "ACT 1"
LevelSelect_LoadAct2:
		levselstr "ACT 2"
LevelSelect_LoadAct3:
		levselstr "ACT 3"
LevelSelect_LoadAct4:
		levselstr "ACT 4"
LevelSelect_MainText:
		levselstr "SONIC TEST GAME - *** DEBUG MODE ***                            "
	even

; ---------------------------------------------------------------------------
; Draw line and numbers
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

LevelSelect_MarkFields:
		lea	(VDP_data_port).l,a6
		lea	VDP_control_port-VDP_data_port(a6),a5
		lea	(RAM_start).l,a4
		lea	LevelSelect_MarkTable(pc),a3
		move.w	(vLevelSelect_VCount).w,d0
		add.w	d0,d0
		lea	(a3,d0.w),a3
		moveq	#0,d0
		move.b	(a3),d0
		lsl.w	#4,d0
		move.w	d0,d1
		add.w	d1,d1
		add.w	d1,d1
		add.w	d1,d0
		moveq	#0,d1
		move.b	1(a3),d1
		add.w	d1,d0
		lea	(a4,d0.w),a1
		moveq	#0,d1
		move.b	(a3),d1
		lsl.w	#7,d1
		add.b	1(a3),d1

		; calc plane pos
		addi.w	#VRAM_Plane_A_Name_Table,d1
		lsl.l	#2,d1
		lsr.w	#2,d1
		ori.w	#vdpComm($0000,VRAM,WRITE)>>16,d1
		swap	d1
		move.l	d1,VDP_control_port-VDP_control_port(a5)

		; load line
		moveq	#40-1,d2	

.copy
		move.w	(a1)+,d0
		add.w	d3,d0	; VRAM shift
		move.w	d0,VDP_data_port-VDP_data_port(a6)
		dbf	d2,.copy

	if LevelSelect_VRAM<>0
		ori.w	#LevelSelect_VRAM,d3
	endif

		; check vertical line
		move.w	(vLevelSelect_VCount).w,d0
		cmpi.w	#LevelSelect_ZoneCount,d0
		blo.w	LevelSelect_LoadAct
		subq.w	#LevelSelect_MusicTestCount,d0
		blo.s		LevelSelect_MarkFields_Index.return
		add.w	d0,d0
		move.w	LevelSelect_MarkFields_Index(pc,d0.w),d0
		jmp	LevelSelect_MarkFields_Index(pc,d0.w)
; ---------------------------------------------------------------------------

LevelSelect_MarkFields_Index: offsetTable
		offsetTableEntry.w .drawmusic					; 0
		offsetTableEntry.w .drawsound					; 2
		offsetTableEntry.w .drawsample					; 4
; ---------------------------------------------------------------------------

.drawsample
		locVRAM	$CD30,VDP_control_port-VDP_control_port(a5)
		move.w	(vLevelSelect_SampleCount).w,d0
		bra.s	.drawnumbers
; ---------------------------------------------------------------------------

.drawsound
		locVRAM	$CC30,VDP_control_port-VDP_control_port(a5)
		move.w	(vLevelSelect_SoundCount).w,d0
		bra.s	.drawnumbers
; ---------------------------------------------------------------------------

.drawmusic
		locVRAM	$CB30,VDP_control_port-VDP_control_port(a5)
		move.w	(vLevelSelect_MusicCount).w,d0

.drawnumbers
		move.w	d0,d2
		move.w	d0,-(sp)
		clr.w	d0
		move.b	(sp)+,d0
		bsr.s	.getnumber
		move.b	d2,d0
		lsr.b	#4,d0
		bsr.s	.getnumber
		move.b	d2,d0

.getnumber
		andi.w	#$F,d0
		cmpi.b	#10,d0
		blo.s		.skipsymbols
		addq.b	#6,d0

.skipsymbols
		addq.b	#1,d0
		add.w	d3,d0
		move.w	d0,VDP_data_port-VDP_data_port(a6)

.return
		rts

; ---------------------------------------------------------------------------
; Deform
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

LevelSelect_Deform:
		lea	(H_scroll_table).w,a3
		lea	LevelSelectScroll_Data(pc),a2
		jmp	(HScroll_Deform).w
; ---------------------------------------------------------------------------

LevelSelectScroll_Data: dScroll_Header
		dScroll_Data 0, 8, -$100, 8
LevelSelectScroll_Data_end

; ---------------------------------------------------------------------------
; Load text
; ---------------------------------------------------------------------------

		save
		codepage	LEVELSCREEN

; =============== S U B R O U T I N E =======================================

LevelSelect_LoadText:
		lea	LevelSelect_MappingOffsets(pc),a0
		lea	(RAM_start).l,a1
		lea	LevelSelect_Text(pc),a2

	if ~~LevelSelect_VRAM
		moveq	#0,d3
	else
		move.w	#LevelSelect_VRAM,d3
	endif

		moveq	#LevelSelect_MaxCount-1,d1

.load
		moveq	#0,d2
		move.b	(a2)+,d2		; text size
		move.w	d2,d4		; save text size
		move.w	(a0)+,d0		; offset
		lea	(a1,d0.w),a3		; RAM shift

.copy
		moveq	#0,d0
		move.b	(a2)+,d0		; load letter
		add.w	d3,d0
		move.w	d0,(a3)+
		dbf	d2,.copy

		; fill with spaces
		moveq	#40-2,d2	; maximum length of line (dbf + dbf)
		sub.w	d4,d2
		blo.s		.next

.sloop
		moveq	#' ',d0		; space
		add.w	d3,d0
		move.w	d0,(a3)+
		dbf	d2,.sloop

.next
		dbf	d1,.load
		copyTilemap	vram_fg, 320, 224, 1
; ---------------------------------------------------------------------------

		restore

LevelSelect_MarkTable:

		; 2 bytes per level select entry (ypos, xpos)
		dc.b 5, 0
		dc.b 7, 0
		dc.b 9, 0
		dc.b 11, 0
		dc.b 13, 0
		dc.b 15, 0
		dc.b 17, 0
		dc.b 19, 0
		dc.b 22, 0
		dc.b 24, 0
		dc.b 26, 0
LevelSelect_MappingOffsets:
		dc.w planeLocH28(0,5)
		dc.w planeLocH28(0,7)
		dc.w planeLocH28(0,9)
		dc.w planeLocH28(0,11)
		dc.w planeLocH28(0,13)
		dc.w planeLocH28(0,15)
		dc.w planeLocH28(0,17)
		dc.w planeLocH28(0,19)
		dc.w planeLocH28(0,22)
		dc.w planeLocH28(0,24)
		dc.w planeLocH28(0,26)
LevelSelect_Text:
		levselstr "   DEATH EGG          - ACT 1"
		levselstr "   UNKNOWN LEVEL      - UNKNOWN"
		levselstr "   UNKNOWN LEVEL      - UNKNOWN"
		levselstr "   UNKNOWN LEVEL      - UNKNOWN"
		levselstr "   UNKNOWN LEVEL      - UNKNOWN"
		levselstr "   UNKNOWN LEVEL      - UNKNOWN"
		levselstr "   UNKNOWN LEVEL      - UNKNOWN"
		levselstr "   UNKNOWN LEVEL      - UNKNOWN"
		levselstr "   MUSIC TEST:        -"
		levselstr "   SOUND TEST:        -"
		levselstr "   SAMPLE TEST:       -"
	even
