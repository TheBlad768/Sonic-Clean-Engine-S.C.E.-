; ---------------------------------------------------------------------------
; Level Select
; ---------------------------------------------------------------------------

; Constants
LevelSelect.VRAM =					0

LevelSelect.ZoneCount =					ZoneCount
LevelSelect.ActDEZCount =				4				; DEZ

LevelSelect.MusicTestCount =				8
LevelSelect.SoundTestCount =				LevelSelect.MusicTestCount+1
LevelSelect.SampleTestCount =				LevelSelect.SoundTestCount+1
LevelSelect.MaxCount =					11
LevelSelect.MaxMusicNumber =				(mus__End-mus__First)-1
LevelSelect.MaxSoundNumber =				(sfx__End-sfx__First)-1
LevelSelect.MaxSampleNumber =				$10

; RAM

	dsset ramaddr(RAM_start)							; pretend we're in the RAM

LevelSelect.buffer					ds.b $1000			; foreground buffer (copy)
LevelSelect.buffer2					ds.b $1000			; foreground buffer (main)

	dsreset										; stop pretending and reset the program counter

	dsset ramaddr(Object_load_addr_front)						; pretend we're in the RAM

LevelSelect.music_count					ds.w 1
LevelSelect.sound_count					ds.w 1
LevelSelect.sample_count				ds.w 1
LevelSelect.control_timer				ds.w 1
LevelSelect.saved_act					ds.w 1
LevelSelect.vertical_count				ds.w 1
LevelSelect.horizontal_count				ds.w $10

	dsreset										; stop pretending and reset the program counter

; =============== S U B R O U T I N E =======================================

LevelSelectScreen:
		music	mus_Stop							; stop music
		jsr	(Clear_KosPlus_Module_Queue).w					; clear KosPlusM PLCs
		ResetDMAQueue								; clear DMA queue
		jsr	(Pal_FadeToBlack).w
		disableInts
		move.l	#VInt,(V_int_addr).w
		move.l	#HInt,(H_int_addr).w
		disableScreen
		jsr	(Clear_DisplayData).w
		lea	Level_VDP(pc),a1
		jsr	(Load_VDP).w
		jsr	(Clear_Palette).w
		clearRAM RAM_start, (RAM_start+$2000)					; clear foreground buffers
		clearRAM Object_RAM, Object_RAM_end					; clear the object RAM
		clearRAM Lag_frame_count, Lag_frame_count_end				; clear variables
		clearRAM Camera_RAM, Camera_RAM_end					; clear the camera RAM
		clearRAM Oscillating_variables, Oscillating_variables_end		; clear variables

		; clear
		move.b	d0,(Water_full_screen_flag).w
		move.b	d0,(Water_flag).w
		move.b	d0,(HUD_RAM.status).w
		move.b	d0,(Update_HUD_timer).w						; clear time counter update flag
		move.w	d0,(Current_zone_and_act).w
		move.w	d0,(Apparent_zone_and_act).w
		move.b	d0,(Last_star_post_hit).w
		move.b	d0,(Debug_mode_flag).w

		; load main art
		QueueKosPlusModule	ArtKosPM_LevelSelectText, 1

		; load text
		bsr.w	LevelSelect_LoadText
		move.w	#make_art_tile(LevelSelect.VRAM,1,FALSE),d3
		bsr.w	LevelSelect_LoadHeaderText
		mvq	make_art_tile(LevelSelect.VRAM,0,FALSE),d3
		bsr.w	LevelSelect_MarkFields.drawmusic
		mvq	make_art_tile(LevelSelect.VRAM,0,FALSE),d3
		bsr.w	LevelSelect_MarkFields.drawsound
		mvq	make_art_tile(LevelSelect.VRAM,0,FALSE),d3
		bsr.w	LevelSelect_MarkFields.drawsample
		move.w	#make_art_tile(0,1,FALSE),d3
		bsr.w	LevelSelect_MarkFields

		; load main palette
		lea	(Pal_LevelSelect).l,a1
		lea	(Target_palette).w,a2
		jsr	(PalLoad_Line32).w

		; set
		move.l	#VInt_Fade,(V_int_ptr).w					; set VInt pointer

.waitplc
		st	(V_int_flag).w							; set VInt flag
		jsr	(Process_KosPlus_Queue).w
		jsr	(Wait_VSync.skip).w
		jsr	(Process_KosPlus_Module_Queue).w
		tst.w	(KosPlus_modules_left).w
		bne.s	.waitplc							; wait for KosPlusM queue to clear

		; next
		move.l	#VInt_LevelSelect,(V_int_ptr).w					; set VInt pointer
		jsr	(Wait_VSync).w
		enableScreen
		jsr	(Pal_FadeFromBlack).w

.loop
		jsr	(Wait_VSync).w
		lea	LSScroll_Data(pc),a2
		jsr	(HScroll_Deform).w

		; update text
		moveq	#make_art_tile(0,0,FALSE),d3
		bsr.w	LevelSelect_MarkFields
		bsr.s	LevelSelect_Controls
		move.w	#make_art_tile(0,1,FALSE),d3
		bsr.w	LevelSelect_MarkFields

		; check exit
		cmpi.w	#LevelSelect.ZoneCount,(LevelSelect.vertical_count).w
		bhs.s	.loop
		tst.b	(Ctrl_1_pressed).w
		bpl.s	.loop

		; load zone and act
		move.b	#GameModeID_LevelScreen,(Game_mode).w				; set screen mode to level
		move.w	(LevelSelect.vertical_count).w,d2
		move.b	d2,-(sp)							; multiply by $100
		move.w	(sp)+,d2
		clr.b	d2								; clear garbage data
		add.w	(LevelSelect.saved_act).w,d2
		move.w	d2,(Current_zone_and_act).w
		move.w	d2,(Apparent_zone_and_act).w
		rts

; ---------------------------------------------------------------------------
; Check vertical line
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

LevelSelect_Controls:

		; set vertical line
		moveq	#LevelSelect.MaxCount-1,d2					; set max count
		move.w	(LevelSelect.vertical_count).w,d3
		lea	(LevelSelect.control_timer).w,a3
		bsr.w	LevelSelect_FindUpDownControls
		move.w	d3,(LevelSelect.vertical_count).w

		; check vertical line
		cmpi.w	#LevelSelect.ZoneCount,d3
		blo.s	.getact
		subq.w	#LevelSelect.MusicTestCount,d3
		blo.s	.return
		add.w	d3,d3								; multiply by 2
		jmp	.index(pc,d3.w)
; ---------------------------------------------------------------------------

.index
		bra.s	.getmusic							; 0
		bra.s	.getsound							; 2

; ---------------------------------------------------------------------------
; Play sample
; ---------------------------------------------------------------------------

		; get sample								; 4
		moveq	#LevelSelect.MaxSampleNumber,d2					; set max count
		move.w	(LevelSelect.sample_count).w,d3
		lea	(LevelSelect.control_timer).w,a3
		bsr.w	LevelSelect_FindLeftRightControls
		move.w	d3,(LevelSelect.sample_count).w

		; check ctrl
		moveq	#btnABC,d1
		and.b	(Ctrl_1_pressed).w,d1
		beq.w	LevelSelect_FindUpDownControls.returnup

		; play sample
		move.w	d3,d0
		addq.w	#1,d0										; $00 is reserved for pause
		jmp	(Play_Sample).w									; play sample

; ---------------------------------------------------------------------------
; Get act
; ---------------------------------------------------------------------------

.getact
		lea	(LevelSelect.horizontal_count).w,a0
		move.w	(LevelSelect.vertical_count).w,d4
		add.w	d4,d4								; multiply by 2
		move.w	(a0,d4.w),d3
		move.w	.maxacts(pc,d4.w),d2						; set max count
		lea	(LevelSelect.control_timer).w,a3
		bsr.w	LevelSelect_FindLeftRightControls
		move.w	d3,(a0,d4.w)
		move.w	d3,(LevelSelect.saved_act).w

.return
		rts
; ---------------------------------------------------------------------------

.maxacts
		dc.w LevelSelect.ActDEZCount-1	; DEZ

		zonewarning .maxacts,(2*1)

; ---------------------------------------------------------------------------
; Play music
; ---------------------------------------------------------------------------

.getmusic
		moveq	#LevelSelect.MaxMusicNumber,d2					; set max count
		move.w	(LevelSelect.music_count).w,d3
		lea	(LevelSelect.control_timer).w,a3
		bsr.s	LevelSelect_FindLeftRightControls
		move.w	d3,(LevelSelect.music_count).w

		; check ctrl
		moveq	#btnABC,d1
		and.b	(Ctrl_1_pressed).w,d1
		beq.s	LevelSelect_FindUpDownControls.returnup

		; check stop music
		btst	#button_B,d1
		bne.s	.stop								; branch if B is pressed

		; play music
		move.w	d3,d0
		addq.w	#mus__First,d0							; $00 is reserved for silence
		jmp	(Play_Music).w							; play music
; --------------------------------------------------------------------------

.stop
		music	mus_Stop,1

; ---------------------------------------------------------------------------
; Play sound
; ---------------------------------------------------------------------------

.getsound
		moveq	#LevelSelect.MaxSoundNumber,d2					; set max count
		move.w	(LevelSelect.sound_count).w,d3
		lea	(LevelSelect.control_timer).w,a3
		bsr.s	LevelSelect_FindLeftRightControls
		move.w	d3,(LevelSelect.sound_count).w

		; check ctrl
		moveq	#btnABC,d1
		and.b	(Ctrl_1_pressed).w,d1
		beq.s	LevelSelect_FindUpDownControls.returnup

		; play sfx
		move.w	d3,d0
		addq.w	#sfx__First,d0							; skip music
		jmp	(Play_SFX).w							; play sfx

; ---------------------------------------------------------------------------
; Control (up/down)
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
		bls.s	.returndown
		moveq	#0,d3

.returndown
		rts

; ---------------------------------------------------------------------------
; Control (left/right)
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
		bls.s	.returnright
		moveq	#0,d3

.returnright
		rts

; ---------------------------------------------------------------------------
; Draw line and numbers
; ---------------------------------------------------------------------------

LevelSelect_MappingOffsets:
		dc.w planeLoc(64,0,5)
		dc.w planeLoc(64,0,7)
		dc.w planeLoc(64,0,9)
		dc.w planeLoc(64,0,11)
		dc.w planeLoc(64,0,13)
		dc.w planeLoc(64,0,15)
		dc.w planeLoc(64,0,17)
		dc.w planeLoc(64,0,19)
		dc.w planeLoc(64,0,22)
		dc.w planeLoc(64,0,24)
		dc.w planeLoc(64,0,26)

; =============== S U B R O U T I N E =======================================

LevelSelect_MarkFields:
		lea	(LevelSelect.buffer).l,a1
		lea	LevelSelect.buffer2-LevelSelect.buffer(a1),a2

		; get text pos
		move.w	(LevelSelect.vertical_count).w,d0
		add.w	d0,d0								; multiply by 2
		move.w	LevelSelect_MappingOffsets(pc,d0.w),d0

		; RAM shift
		adda.w	d0,a1
		adda.w	d0,a2

		; load line
		moveq	#bytesToXcnt(64,8),d2

.copy

	rept 8
		move.w	(a1)+,d0
		add.w	d3,d0								; VRAM shift
		move.w	d0,(a2)+
	endr

		dbf	d2,.copy

	if ((make_art_tile(LevelSelect.VRAM,0,FALSE))<>0)
		ori.w	#make_art_tile(LevelSelect.VRAM,0,FALSE),d3
	endif

		; check vertical line
		move.w	(LevelSelect.vertical_count).w,d0
		cmpi.w	#LevelSelect.ZoneCount,d0
		blo.s	LevelSelect_LoadAct
		subq.w	#LevelSelect.MusicTestCount,d0
		blo.s	.return
		add.w	d0,d0								; multiply by 2
		jmp	.index(pc,d0.w)
; ---------------------------------------------------------------------------

.index
		bra.s	.drawmusic							; 0
		bra.s	.drawsound							; 2

; ---------------------------------------------------------------------------
; Draw sample
; ---------------------------------------------------------------------------

.drawsample										; 6
		lea	(LevelSelect.buffer2+planeLoc(64,24,26)).l,a5
		move.w	(LevelSelect.sample_count).w,d0
		bra.s	.drawnumbers

; ---------------------------------------------------------------------------
; Draw sound
; ---------------------------------------------------------------------------

.drawsound
		lea	(LevelSelect.buffer2+planeLoc(64,24,24)).l,a5
		move.w	(LevelSelect.sound_count).w,d0
		bra.s	.drawnumbers

; ---------------------------------------------------------------------------
; Draw music
; ---------------------------------------------------------------------------

.drawmusic
		lea	(LevelSelect.buffer2+planeLoc(64,24,22)).l,a5
		move.w	(LevelSelect.music_count).w,d0

.drawnumbers
		move.w	d0,d2
		move.w	d0,-(sp)							; division by $100
		move.b	(sp)+,d0
		bsr.s	.getnumber
		move.b	d2,d0
		lsr.b	#4,d0
		bsr.s	.getnumber
		move.b	d2,d0

.getnumber
		andi.w	#$F,d0
		cmpi.b	#10,d0								; is digit $A-$F?
		blo.s	.skipsymbols							; if not, branch
		addq.b	#6,d0								; use alpha characters

.skipsymbols
		addq.b	#1,d0
		add.w	d3,d0
		move.w	d0,(a5)+

.return
		rts

; ---------------------------------------------------------------------------
; Draw act
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

LevelSelect_LoadAct:
		lea	(LevelSelect.buffer2+planeLoc(64,24,5)).l,a5
		lea	(LevelSelect.horizontal_count).w,a0
		move.w	(LevelSelect.vertical_count).w,d0
		move.w	d0,d1
		move.b	d0,-(sp)							; multiply by $100
		move.w	(sp)+,d0
		clr.b	d0								; clear garbage data
		adda.w	d0,a5
		add.w	d1,d1								; multiply by 2
		move.w	(a0,d1.w),d0
		add.w	d1,d1								; multiply by 4
		add.w	d1,d1
		add.w	d0,d0								; multiply by 2
		add.w	d1,d0
		lea	LevelSelect_ActTextIndex(pc),a0
		adda.w	(a0,d0.w),a0

.loadtext
		moveq	#0,d6
		move.b	(a0)+,d6							; get text size

.copy
		moveq	#0,d0
		move.b	(a0)+,d0
		add.w	d3,d0
		move.w	d0,(a5)+
		dbf	d6,.copy
		rts

; =============== S U B R O U T I N E =======================================

LevelSelect_LoadHeaderText:
		lea	(LevelSelect.buffer2+planeLoc(64,0,1)).l,a5
		lea	LevelSelect_HeaderText(pc),a0
		bra.s	LevelSelect_LoadAct.loadtext

; ---------------------------------------------------------------------------
; Load text
; ---------------------------------------------------------------------------

		save
		codepage	LEVELSCREEN

; =============== S U B R O U T I N E =======================================

LevelSelect_LoadText:
		lea	LevelSelect_MappingOffsets(pc),a0
		lea	(LevelSelect.buffer).l,a1
		lea	LevelSelect_MainText(pc),a2

		; set
		mvq	make_art_tile(LevelSelect.VRAM,0,FALSE),d3
		moveq	#LevelSelect.MaxCount-1,d1

.load
		moveq	#0,d2
		move.b	(a2)+,d2							; text size
		move.w	d2,d4								; save text size
		move.w	(a0)+,d0							; offset
		lea	(a1,d0.w),a3							; RAM shift

.copy
		moveq	#0,d0
		move.b	(a2)+,d0							; load letter
		add.w	d3,d0
		move.w	d0,(a3)+
		dbf	d2,.copy

		; fill with spaces
		moveq	#64-2,d2							; maximum length of line (dbf + dbf)
		sub.w	d4,d2
		blo.s	.next

.sloop
		moveq	#' ',d0								; space
		add.w	d3,d0
		move.w	d0,(a3)+
		dbf	d2,.sloop

.next
		dbf	d1,.load

		; copy buffer
		lea	(LevelSelect.buffer).l,a1
		lea	LevelSelect.buffer2-LevelSelect.buffer(a1),a2
		moveq	#bytesToXcnt(($1000),8*4),d1

.bcopy

	rept 8
		move.l	(a1)+,(a2)+
	endr

		dbf	d1,.bcopy
		rts

		restore
; ---------------------------------------------------------------------------

LevelSelect_ActTextIndex: offsetTable
		offsetTableEntry.w LevelSelect_LoadAct1		; DEZ1
		offsetTableEntry.w LevelSelect_LoadAct2		; DEZ2
		offsetTableEntry.w LevelSelect_LoadAct3		; DEZ3
		offsetTableEntry.w LevelSelect_LoadAct4		; DEZ4

		zonewarning LevelSelect_ActTextIndex,(2*4)
; --------------------------------------------------------------------------

; level act
LevelSelect_LoadAct1:		levselstr "ACT 1"
LevelSelect_LoadAct2:		levselstr "ACT 2"
LevelSelect_LoadAct3:		levselstr "ACT 3"
LevelSelect_LoadAct4:		levselstr "ACT 4"
LevelSelect_HeaderText:		levselstr "SONIC TEST GAME - *** DEBUG MODE ***                            "

; main text
LevelSelect_MainText:
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
; ---------------------------------------------------------------------------

		; scroll data

LSScroll_Data: HScroll_Header
		HScroll_Data 8, 8, -$100, FG	; start pos, size, velocity, plane
		HScroll_End
