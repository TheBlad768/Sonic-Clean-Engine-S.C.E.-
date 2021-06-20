; ---------------------------------------------------------------------------
; Level Select Screen
; ---------------------------------------------------------------------------

; RAM
Music_test_count:			= Object_load_addr_front		; word
Sound_test_count:			= Object_load_addr_front+2	; word
v_LeveSelect_VCount:			= Object_load_addr_front+4	; word
v_LeveSelect_HCount:			= Object_load_addr_front+6	; word($10 bytes)

; VRAM
LSText_VRAM:				= $7B8

; Variables
LeveSelect_ZoneCount:			= ZoneCount
LeveSelect_ActDEZCount:		= 4	; DEZ
LeveSelect_MusicTestCount:	= 9
LeveSelect_SoundTestCount:	= LeveSelect_MusicTestCount+1
LeveSelect_MaxCount:			= 11
LeveSelect_MaxMusicNumber:	= 6
LeveSelect_MaxSoundNumber:	= $1D

; =============== S U B R O U T I N E =======================================

LevelSelect_Screen:
		sfx	bgm_Stop,0,1,1
		jsr	(Clear_Kos_Module_Queue).w
		jsr	(Pal_FadeToBlack).w
		disableInts
		disableScreen
		jsr	(Clear_DisplayData).w
		lea	(VDP_control_port).l,a6
		move.w	#$8004,(a6)					; Command $8004 - Disable HInt, HV Counter
		move.w	#$8200+(vram_fg>>10),(a6)	; Command $8230 - Nametable A at $C000
		move.w	#$8400+(vram_bg>>13),(a6)	; Command $8407 - Nametable B at $E000
		move.w	#$8700+(0<<4),(a6)			; Command $8700 - BG color is Pal 0 Color 0
		move.w	#$8B03,(a6)					; Command $8B03 - Vscroll full, HScroll line-based
		move.w	#$8C81,(a6)					; Command $8C81 - 40cell screen size, no interlacing, no s/h
		move.w	#$9001,(a6)					; Command $9001 - 64x32 cell nametable area
		move.w	#$9200,(a6)					; Command $9200 - Window V position at default
		clr.b	(Water_full_screen_flag).w
		clr.b	(Water_flag).w
		lea	(RAM_start).l,a3
		move.w	#bytesToWcnt(2240),d1

-		clr.w	(a3)+
		dbf	d1,-
		clearRAM Object_RAM, Object_RAM_End
		clearRAM Lag_frame_count, Lag_frame_count_End
		clearRAM Camera_RAM, Camera_RAM_End
		clearRAM Oscillating_variables, Oscillating_variables_End
		moveq	#0,d0
		move.w	d0,(Current_zone_and_act).w
		move.b	d0,(Last_star_post_hit).w
		move.b	d0,(Level_started_flag).w
		ResetDMAQueue
		lea	(ArtKosM_LevelSelectText).l,a1
		move.w	#tiles_to_bytes($7C0),d2
		jsr	(Queue_Kos_Module).w
		lea	(Pal_LevelSelect).l,a1
		lea	(Target_palette).w,a2
		jsr	(PalLoad_Line64).w
		bsr.w	Load_LevelSelect_Text
		move.w	#palette_line_1,d3
		bsr.w	Load_LevelSelect_Text2
		move.w	#palette_line_1,d3
		bsr.w	LevelSelect_MarkFields

-		move.b	#VintID_TitleCard,(V_int_routine).w
		jsr	(Process_Kos_Queue).w
		jsr	(Wait_VSync).w
		jsr	(Process_Kos_Module_Queue).w
		tst.w	(Kos_modules_left).w
		bne.s	-
		move.b	#VintID_Menu,(V_int_routine).w
		jsr	(Process_Kos_Queue).w
		jsr	(Wait_VSync).w
		jsr	(Process_Kos_Module_Queue).w
		enableScreen
		jsr	(Pal_FadeFromBlack).w

-		move.b	#VintID_Menu,(V_int_routine).w
		jsr	(Process_Kos_Queue).w
		jsr	(Wait_VSync).w
		bsr.w	LevelSelect_Deform
		disableInts
		moveq	#palette_line_0,d3
		bsr.w	LevelSelect_MarkFields
		bsr.s	LevelSelect_Controls
		move.w	#palette_line_1,d3
		bsr.w	LevelSelect_MarkFields
		enableInts
		jsr	(Process_Kos_Module_Queue).w
		tst.b	(Ctrl_1_pressed).w
		bpl.s	-
		cmpi.w	#LeveSelect_ZoneCount,(v_LeveSelect_VCount).w
		bhs.s	-
		move.b	#id_LevelScreen,(Game_mode).w		; set screen mode to level
		rts

; =============== S U B R O U T I N E =======================================

LevelSelect_Controls:
		moveq	#0,d0
		move.w	#LeveSelect_MaxCount-1,d2
		move.w	(v_LeveSelect_VCount).w,d0
		bsr.w	LevelSelect_FindUpDownControls
		move.w	d0,(v_LeveSelect_VCount).w
		cmpi.w	#LeveSelect_SoundTestCount,d0
		beq.s	LevelSelect_LoadSoundNumber
		cmpi.w	#LeveSelect_MusicTestCount,d0
		beq.s	LevelSelect_LoadMusicNumber
		cmpi.w	#LeveSelect_ZoneCount,d0
		bhs.s	LevelSelect_LoadLevel_Return

LevelSelect_LoadNewLevel:
		moveq	#0,d0
		lea	(v_LeveSelect_HCount).w,a0
		move.w	(v_LeveSelect_VCount).w,d3
		add.w	d3,d3
		move.w	(a0,d3.w),d0
		move.w	LevelSelect_LoadMaxActs(pc,d3.w),d2
		bsr.s	LevelSelect_FindLeftRightControls
		move.w	d0,(a0,d3.w)
		move.w	(v_LeveSelect_VCount).w,d2
		lsl.w	#8,d2
		add.w	d2,d0
		move.w	d0,(Current_zone_and_act).w

LevelSelect_LoadLevel_Return:
		rts
; ---------------------------------------------------------------------------

LevelSelect_LoadMaxActs:
		dc.w LeveSelect_ActDEZCount-1	; DEZ

		zonewarning LevelSelect_LoadMaxActs,2
; ---------------------------------------------------------------------------

LevelSelect_LoadMusicNumber:
		moveq	#0,d0
		move.w	#LeveSelect_MaxMusicNumber,d2
		move.w	(Music_test_count).w,d0
		bsr.s	LevelSelect_FindLeftRightControls
		move.w	d0,(Music_test_count).w
		move.b	(Ctrl_1_pressed).w,d1
		andi.b	#$70,d1
		beq.s	LevelSelect_LoadMusicNumber_Return
		move.b	d0,(Clone_Driver_RAM+SMPS_RAM.variables.queue.v_playsnd1).w	; play music

LevelSelect_LoadMusicNumber_Return:
		rts
; ---------------------------------------------------------------------------

LevelSelect_LoadSoundNumber:
		moveq	#0,d0
		move.w	#LeveSelect_MaxSoundNumber,d2
		move.w	(Sound_test_count).w,d0
		bsr.s	LevelSelect_FindLeftRightControls
		move.w	d0,(Sound_test_count).w
		addi.w	#$40,d0
		move.b	(Ctrl_1_pressed).w,d1
		andi.b	#$70,d1
		beq.s	LevelSelect_LoadSoundMusic_Return
		move.b	d0,(Clone_Driver_RAM+SMPS_RAM.variables.queue.v_playsnd2).w	; play sfx

LevelSelect_LoadSoundMusic_Return:
		rts

; =============== S U B R O U T I N E =======================================

LevelSelect_FindUpDownControls:
		move.b	(Ctrl_1_pressed).w,d1
		btst	#button_up,d1
		beq.s	+
		subq.w	#1,d0
		bpl.s	+
		move.w	d2,d0
+		btst	#button_down,d1
		beq.s	+
		addq.w	#1,d0
		cmp.w	d2,d0
		ble.s		+
		moveq	#0,d0
+		rts

; =============== S U B R O U T I N E =======================================

LevelSelect_FindLeftRightControls:
		move.b	(Ctrl_1_pressed).w,d1
		btst	#button_left,d1
		beq.s	+
		subq.w	#1,d0
		bpl.s	+
		move.w	d2,d0
+		btst	#button_right,d1
		beq.s	+
		addq.w	#1,d0
		cmp.w	d2,d0
		ble.s		+
		moveq	#0,d0
+		rts

; =============== S U B R O U T I N E =======================================

Load_LevelSelect_LoadAct:
		moveq	#0,d0
		locVRAM	$C2B0,d2
		lea	(v_LeveSelect_HCount).w,a0
		move.w	(v_LeveSelect_VCount).w,d0
		move.w	d0,d1
		beq.s	+
		subq.w	#1,d0
-		addi.l	#$1000000,d2
		dbf	d0,-
+		move.l	d2,VDP_control_port-VDP_data_port(a6)
		add.w	d1,d1
		move.w	(a0,d1.w),d0
		add.w	d1,d1
		add.w	d1,d1
		add.w	d0,d0
		add.w	d1,d0
		move.w	LevelSelect_LoadActText(pc,d0.w),d0
		lea	LevelSelect_LoadActText(pc,d0.w),a0
		bra.s	Load_LevelSelect_LoadText
; --------------------------------------------------------------------------

Load_LevelSelect_Text2:
		locVRAM	$C080,VDP_control_port-VDP_data_port(a6)
		lea	LevelSelect_Text(pc),a0

Load_LevelSelect_LoadText:
		moveq	#0,d6
		move.b	(a0)+,d6
-		moveq	#0,d0
		move.b	(a0)+,d0
		addi.w	#LSText_VRAM,d0
		add.w	d3,d0
		move.w	d0,VDP_data_port-VDP_data_port(a6)
		dbf	d6,-
		rts
; --------------------------------------------------------------------------

LevelSelect_LoadActText: offsetTable
		offsetTableEntry.w LevelSelect_LoadAct1			; DEZ1
		offsetTableEntry.w LevelSelect_LoadAct2			; DEZ2
		offsetTableEntry.w LevelSelect_LoadAct3			; DEZ3
		offsetTableEntry.w LevelSelect_LoadAct4			; DEZ4

		zonewarning LevelSelect_LoadActText,(2*4)
; --------------------------------------------------------------------------

LevelSelect_LoadAct1:
		levselstr "ACT 1"
LevelSelect_LoadAct2:
		levselstr "ACT 2"
LevelSelect_LoadAct3:
		levselstr "ACT 3"
LevelSelect_LoadAct4:
		levselstr "ACT 4"
LevelSelect_Text:
		levselstr "SONIC TEST HACK - *** DEBUG MODE ***                            "
	even

; =============== S U B R O U T I N E =======================================

LevelSelect_MarkFields:
		lea	(RAM_start).l,a4
		lea	LevelSelect_MarkTable(pc),a5
		lea	(VDP_data_port).l,a6
		moveq	#0,d0
		move.w	(v_LeveSelect_VCount).w,d0
		lsl.w	#2,d0
		lea	(a5,d0.w),a3
		moveq	#0,d0
		move.b	(a3),d0
		mulu.w	#$50,d0
		moveq	#0,d1
		move.b	1(a3),d1
		add.w	d1,d0
		lea	(a4,d0.w),a1
		moveq	#0,d1
		move.b	(a3),d1
		lsl.w	#7,d1
		add.b	1(a3),d1
		addi.w	#VRAM_Plane_A_Name_Table,d1
		lsl.l	#2,d1
		lsr.w	#2,d1
		ori.w	#vdpComm($0000,VRAM,WRITE)>>16,d1
		swap	d1
		move.l	d1,VDP_control_port-VDP_data_port(a6)
		moveq	#$40,d2
-		move.w	(a1)+,d0
		add.w	d3,d0
		move.w	d0,VDP_data_port-VDP_data_port(a6)
		dbf	d2,-
		addq.w	#2,a3
		moveq	#0,d0
		move.b	(a3),d0
		beq.s	+
		mulu.w	#$50,d0
		moveq	#0,d1
		move.b	1(a3),d1
		add.w	d1,d0
		lea	(a4,d0.w),a1
		moveq	#0,d1
		move.b	(a3),d1
		lsl.w	#7,d1
		add.b	1(a3),d1
		addi.w	#VRAM_Plane_A_Name_Table,d1
		lsl.l	#2,d1
		lsr.w	#2,d1
		ori.w	#vdpComm($0000,VRAM,WRITE)>>16,d1
		swap	d1
		move.l	d1,VDP_control_port-VDP_data_port(a6)
		move.w	(a1)+,d0
		add.w	d3,d0
		move.w	d0,VDP_data_port-VDP_data_port(a6)
+		cmpi.w	#LeveSelect_ZoneCount,(v_LeveSelect_VCount).w
		bhs.s	+
		bsr.w	Load_LevelSelect_LoadAct
+		cmpi.w	#LeveSelect_MusicTestCount,(v_LeveSelect_VCount).w
		bne.s	+
		bra.s	LevelSelect_DrawMusicNumber
+		cmpi.w	#LeveSelect_SoundTestCount,(v_LeveSelect_VCount).w
		bne.s	LevelSelect_MarkFields_Return
		bra.s	LevelSelect_DrawSoundNumber
; ---------------------------------------------------------------------------

LevelSelect_DrawMusicNumber:
		locVRAM	$CC30
		move.w	(Music_test_count).w,d0
		bra.s	LevelSelect_DrawNumbers
; ---------------------------------------------------------------------------

LevelSelect_DrawSoundNumber:
		locVRAM	$CD30
		move.w	(Sound_test_count).w,d0

LevelSelect_DrawNumbers:
		move.b	d0,d2
		lsr.b #8,d0
		bsr.s	+
		move.b	d2,d0
		lsr.b	#4,d0
		bsr.s	+
		move.b	d2,d0
+		andi.w	#$F,d0
		cmpi.b	#$A,d0
		blo.s		+
		addq.b	#7,d0
+		addi.w	#LSText_VRAM+8,d0
		add.w	d3,d0
		move.w	d0,VDP_data_port-VDP_data_port(a6)

LevelSelect_MarkFields_Return:
		rts

; =============== S U B R O U T I N E =======================================

LevelSelect_Deform:
		lea	(RAM_Start).l,a3
		lea	LevelSelectScroll_Data(pc),a2
		jmp	(HScroll_Deform).w
; ---------------------------------------------------------------------------

LevelSelectScroll_Data: dScroll_Header
		dScroll_Data 0, 8, -$100, 8
LevelSelectScroll_Data_End

; =============== S U B R O U T I N E =======================================

Load_LevelSelect_Text:
		lea	Info_Text(pc),a1
		lea	(RAM_start).l,a3
		lea	Map_TitleText(pc),a5
		moveq	#LeveSelect_MaxCount-1,d1

-		move.w	(a5)+,d3
		lea	(a3,d3.w),a2
		moveq	#0,d2
		move.b	(a1)+,d2
		move.w	d2,d3

-		moveq	#0,d0
		move.b	(a1)+,d0
		addi.w	#LSText_VRAM,d0
		move.w	d0,(a2)+
		dbf	d2,-
		dbf	d1,--
		lea	(RAM_start).l,a1
		locVRAM	$C000,d0
		moveq	#(320/8-1),d1
		moveq	#(224/8-1),d2
		jmp	(Plane_Map_To_VRAM).w
; ---------------------------------------------------------------------------

LevelSelect_MarkTable:
		dc.b 5, 0, 5, $24
		dc.b 7, 0, 7, $24
		dc.b 9, 0, 9, $24
		dc.b 11, 0, 11, $24
		dc.b 13, 0, 13, $24
		dc.b 15, 0, 15, $24
		dc.b 17, 0, 17, $24
		dc.b 19, 0, 19, $24
		dc.b 21, 0, 21, $24
		dc.b 24, 0, 24, $24
		dc.b 26, 0, 26, $24
Map_TitleText:
		dc.w planeLocH28(0,5)
		dc.w planeLocH28(0,7)
		dc.w planeLocH28(0,9)
		dc.w planeLocH28(0,11)
		dc.w planeLocH28(0,13)
		dc.w planeLocH28(0,15)
		dc.w planeLocH28(0,17)
		dc.w planeLocH28(0,19)
		dc.w planeLocH28(0,21)
		dc.w planeLocH28(0,24)
		dc.w planeLocH28(0,26)
Info_Text:
		levselstr "   DEATH EGG          - ACT 1                                   "
		levselstr "   UNKNOWN LEVEL      - UNKNOWN                                 "
		levselstr "   UNKNOWN LEVEL      - UNKNOWN                                 "
		levselstr "   UNKNOWN LEVEL      - UNKNOWN                                 "
		levselstr "   UNKNOWN LEVEL      - UNKNOWN                                 "
		levselstr "   UNKNOWN LEVEL      - UNKNOWN                                 "
		levselstr "   UNKNOWN LEVEL      - UNKNOWN                                 "
		levselstr "   UNKNOWN LEVEL      - UNKNOWN                                 "
		levselstr "   UNKNOWN LEVEL      - UNKNOWN                                 "
		levselstr "   MUSIC TEST:        - 000                                     "
		levselstr "   SOUND TEST:        - 000                                     "
	even