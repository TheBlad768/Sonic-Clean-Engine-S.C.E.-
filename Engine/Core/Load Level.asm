; ---------------------------------------------------------------------------
; Load level data
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

LoadLevelLoadBlock:

		; load primary level art
		movea.l	(Level_data_addr_RAM.8x8Data1).w,a1				; get primary level art to a1
		move.w	(a1),d4								; save art size
		moveq	#tiles_to_bytes(0),d2						; VRAM
		bsr.w	Queue_KosPlus_Module						; decompress and send data to VRAM

		; load secondary level art
		move.l	(Level_data_addr_RAM.8x8Data2).w,d0				; get secondary level art to d0
		beq.s	.waitplc							; if zero, branch
		movea.l	d0,a1								; load secondary level art to a1
		move.w	d4,d2								; load art size for the starting position
		bsr.w	Queue_KosPlus_Module						; decompress and send data to VRAM

		; set
		move.l	#VInt_Fade,(V_int_ptr).w					; set VInt pointer

.waitplc
		st	(V_int_flag).w							; set VInt flag
		bsr.w	Process_KosPlus_Queue
		bsr.w	Wait_VSync.skip
		bsr.w	Process_KosPlus_Module_Queue
		tst.w	(KosPlus_modules_left).w
		bne.s	.waitplc							; wait for KosPlusM queue to clear
		rts

; ---------------------------------------------------------------------------
; Clear level switches RAM
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Clear_Switches:
		clearRAM2 Level_trigger_array, Level_trigger_array_end
		rts

; ---------------------------------------------------------------------------
; Reset level data
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Reset_LevelData:
		move.l	#Load_Objects_Init,(Object_load_addr_RAM).w
		move.l	#Load_Rings_Init,(Rings_manager_addr_RAM).w
		bsr.s	Clear_Switches

		; clear
		move.b	d0,(Screen_event_routine).w
		move.b	d0,(Background_event_routine).w
		move.b	d0,(Boss_flag).w
		move.b	d0,(Respawn_table_keep).w

		; load
		bsr.s	LoadLevelPointer
		bsr.s	Load_Level
		bsr.w	CheckLevelForWater

; ---------------------------------------------------------------------------
; Collision index pointer loading subroutine
; Uses Sonic & Knuckles format mapping
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Load_Solids:
		movea.l	(Level_data_addr_RAM.SolidRAM).w,a1				; get solid pointer to a1

Load_Solids2:
		move.l	a1,(Primary_collision_addr).w
		move.l	a1,(Collision_addr).w
		addq.w	#1,a1
		move.l	a1,(Secondary_collision_addr).w
		rts

; ---------------------------------------------------------------------------
; Load level data 2
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

LoadLevelLoadBlock2:

		; load art
		movea.l	(Level_data_addr_RAM.PLC1).w,a5					; get plc1 pointer to a5
		bsr.w	LoadPLC_Raw_KosPlusM

.skipPLC
		lea	(Level_data_addr_RAM.16x16Data1).w,a2

		; load blocks, chunks, layout, solid, objects, rings
		moveq	#6-1,d1

.finddata

		; load primary data
		move.l	(a2)+,d0							; get primary data to d0
		beq.s	.nextdata							; if zero, branch
		movea.l	d0,a0								; load primary data to a0
		movea.l	-8(a2),a1							; load destination (in RAM) address to a1
		bsr.w	KosPlus_Decomp							; decompress and send data to destination (in RAM)

		; load secondary data
		move.l	(a2),d0								; get secondary data to d0
		beq.s	.nextdata							; if zero, branch
		movea.l	d0,a0								; load secondary data to a0
		bsr.w	KosPlus_Decomp							; decompress and send data to destination (in RAM)

.nextdata
		addq.w	#4*2,a2								; next
		dbf	d1,.finddata

		; load level palette
		lea	(Level_data_addr_RAM.Palette).w,a2				; level palette
		moveq	#0,d0
		move.b	(a2),d0								; get level palette id
		bsr.w	LoadPalette							; load palette

; ---------------------------------------------------------------------------
; Load level layout
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Load_Level:
		movea.l	(Level_data_addr_RAM.LayoutRAM).w,a1				; get layout pointer to a1

Load_Level2:
		move.l	a1,(Level_layout_addr_ROM).w					; save to addr
		addq.w	#8,a1								; skip layout header
		move.l	a1,(Level_layout_addr2_ROM).w					; save to addr2
		rts

; ---------------------------------------------------------------------------
; Load level pointer (resize, events, etc.)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

LoadLevelPointer:

		; calc level
		move.w	(Current_zone_and_act).w,d0
		ror.b	#2,d0

.mul =	0

	if .mul
		lsr.w	#6,d0
		mulu.w	#(Level_data_addr_RAM_end-Level_data_addr_RAM),d0
	else

		if (Level_data_addr_RAM_end-Level_data_addr_RAM)<>$AE
			fatal "Warning! The buffer size is different! Your buffer is $\{Level_data_addr_RAM_end-Level_data_addr_RAM}, but it's not $AE"
		endif

		; if you make a different buffer size, you need to change this code
		move.w	d0,d1								; multiply by $AE
		add.w	d0,d1
		add.w	d0,d1
		lsr.w	#2,d0
		sub.w	d0,d1
		lsr.w	#3,d0
		sub.w	d0,d1
		move.w	d1,d0
	endif

.skip
		lea	(LevelLoadPointer).l,a2
		adda.w	d0,a2

.load
		lea	(Level_data_addr_RAM).w,a3

		set	.a,0

	rept (Level_data_addr_RAM_end-Level_data_addr_RAM)/$20				; copy $AE bytes
		movem.l	(a2)+,d0-d7
		movem.l	d0-d7,.a(a3)							; copy $20 bytes
		set	.a,.a + $20
	endr

	if (Level_data_addr_RAM_end-Level_data_addr_RAM)&$10
		movem.l	(a2)+,d0-d3
		movem.l	d0-d3,.a(a3)							; copy $10 bytes
		set	.a,.a + $10
	endif

	if (Level_data_addr_RAM_end-Level_data_addr_RAM)&8
		move.l	(a2)+,.a(a3)							; copy 8 bytes
		set	.a,.a + 4
		move.l	(a2)+,.a(a3)
		set	.a,.a + 4
	endif

	if (Level_data_addr_RAM_end-Level_data_addr_RAM)&4
		move.l	(a2)+,.a(a3)							; copy 4 bytes
		set	.a,.a + 4
	endif

	if (Level_data_addr_RAM_end-Level_data_addr_RAM)&2
		move.w	(a2)+,.a(a3)							; copy 2 bytes
		set	.a,.a + 2
	endif

	if (Level_data_addr_RAM_end-Level_data_addr_RAM)&1
		move.b	(a2)+,.a(a3)							; copy 1 byte
		set	.a,.a + 1
	endif

		rts
