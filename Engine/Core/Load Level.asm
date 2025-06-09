; ---------------------------------------------------------------------------
; Load level data
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

LoadLevelLoadBlock:

		; load primary level art
		movea.l	(Level_data_addr_RAM.8x8data1).w,a1
		move.w	(a1),d4								; save art size
		moveq	#tiles_to_bytes(0),d2						; VRAM
		bsr.w	Queue_KosPlus_Module

		; load secondary level art
		move.l	(Level_data_addr_RAM.8x8data2).w,d0
		beq.s	.waitplc
		movea.l	d0,a1
		move.w	d4,d2								; return art size for the starting position
		bsr.w	Queue_KosPlus_Module

.waitplc
		move.b	#VintID_Fade,(V_int_routine).w
		bsr.w	Process_KosPlus_Queue
		bsr.w	Wait_VSync
		bsr.w	Process_KosPlus_Module_Queue
		tst.w	(KosPlus_modules_left).w
		bne.s	.waitplc							; wait for KosPlusM queue to clear
		rts

; ---------------------------------------------------------------------------
; Clear switches RAM
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
		movea.l	(Level_data_addr_RAM.Solid).w,a1

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
		movea.l	(Level_data_addr_RAM.PLC1).w,a5
		bsr.w	LoadPLC_Raw_KosPlusM

.skipPLC
		lea	(Level_data_addr_RAM.16x16ram).w,a2

		; save blocks address
		move.l	(a2)+,(Block_table_addr_ROM).w

		; load primary level blocks
		move.l	(a2)+,d0
		beq.s	.notbsec
		movea.l	d0,a0
		movea.l	-8(a2),a1							; load blocks address
		bsr.w	KosPlus_Decomp

		; load secondary level blocks
		move.l	(a2),d0
		beq.s	.notbsec
		movea.l	d0,a0
		bsr.w	KosPlus_Decomp

.notbsec
		addq.w	#4,a2								; next

		; save chunks address
		move.l	(a2)+,(Level_chunk_addr_ROM).w

		; load primary level chunks
		move.l	(a2)+,d0
		beq.s	.notcsec
		movea.l	d0,a0
		movea.l	-8(a2),a1							; load chunks address
		bsr.w	KosPlus_Decomp

		; load secondary level chunks
		move.l	(a2),d0
		beq.s	.notcsec
		movea.l	d0,a0
		bsr.w	KosPlus_Decomp

.notcsec

		; load level palette
		lea	(Level_data_addr_RAM.Palette).w,a2				; level palette
		moveq	#0,d0
		move.b	(a2),d0
		bsr.w	LoadPalette							; load palette

; ---------------------------------------------------------------------------
; Load level layout
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Load_Level:
		movea.l	(Level_data_addr_RAM.Layout).w,a1

Load_Level2:
		move.l	a1,(Level_layout_addr_ROM).w					; save to addr
		addq.w	#8,a1								; skip layout header
		move.l	a1,(Level_layout_addr2_ROM).w					; save to addr2
		rts

; ---------------------------------------------------------------------------
; Load level pointer (resize, events, etc...)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

LoadLevelPointer:
		move.w	(Current_zone_and_act).w,d0
		ror.b	#2,d0

.mul		= 0

	if .mul
		lsr.w	#6,d0
		mulu.w	#(Level_data_addr_RAM_end-Level_data_addr_RAM),d0
	else
		move.w	d0,d1								; multiply by $82
		lsr.w	#5,d1
		add.w	d0,d0
		add.w	d1,d0
	endif

.skip
		lea	(LevelLoadPointer).l,a2
		adda.w	d0,a2

.load
		lea	(Level_data_addr_RAM).w,a3

		; if you make a different buffer size, you need to change this code

	if (Level_data_addr_RAM_end-Level_data_addr_RAM)<>$82
		fatal "Warning! The buffer size is different!"
	endif

		set	.a,0

	rept (Level_data_addr_RAM_end-Level_data_addr_RAM)/$20				; copy $82 bytes
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
