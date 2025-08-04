; ---------------------------------------------------------------------------
; Subroutine to clear the screen
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Clear_DisplayData:
		stopZ80
		lea	(VDP_control_port).l,a5						; load VDP control address to a5
		dmaFillVRAM 0,0,$10000							; clear VRAM
		startZ80
		clearRAM Sprite_table_buffer, Sprite_table_buffer_end			; clear sprite table buffer
		clearRAM H_scroll_buffer, V_scroll_buffer_end				; clear hvscroll buffer
		move.l	d0,(V_scroll_value).w						; clear vscroll value
		move.l	d0,(H_scroll_value).w						; clear hscroll value
		bra.w	Init_SpriteTable

; ---------------------------------------------------------------------------
; Copies a plane map to a plane PNT, used for a 28-cell wide plane
; Inputs:
; a1 = map address
; d0 = VDP command to write to the PNT
; d1 = number of cells in a row - 1
; d2 = number of cell rows - 1
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Plane_Map_To_VRAM_3:
		move.l	#vdpCommDelta(planeLoc(32,0,1)),d4				; row increment value
		bra.s	Plane_Map_To_VRAM.main

; ---------------------------------------------------------------------------
; Copies a plane map to a plane PNT, used for a 128-cell wide plane
; Inputs:
; a1 = map address
; d0 = VDP command to write to the PNT
; d1 = number of cells in a row - 1
; d2 = number of cell rows - 1
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Plane_Map_To_VRAM_2:
		move.l	#vdpCommDelta(planeLoc(128,0,1)),d4				; row increment value
		bra.s	Plane_Map_To_VRAM.main

; ---------------------------------------------------------------------------
; Copies a plane map to a plane PNT
; Inputs:
; a1 = map address
; d0 = VDP command to write to the PNT
; d1 = number of cells in a row - 1
; d2 = number of cell rows - 1
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Plane_Map_To_VRAM:
		move.l	#vdpCommDelta(planeLoc(64,0,1)),d4				; row increment value

.main
		lea	(VDP_data_port).l,a6						; load VDP data address to a6
		lea	VDP_control_port-VDP_data_port(a6),a5				; load VDP control address to a5

.loop2
		move.w	d1,d3
		move.l	d0,VDP_control_port-VDP_control_port(a5)

.loop
		move.w	(a1)+,VDP_data_port-VDP_data_port(a6)
		dbf	d3,.loop							; copy one row
		add.l	d4,d0								; move onto next row
		dbf	d2,.loop2							; and copy it
		rts

; ---------------------------------------------------------------------------
; Subroutine to load mappings to VRAM
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Copy_Listed_Data_To_VRAM:
		move.w	(a0)+,d6							; count

.load
		movea.l	(a0)+,a1							; source
		move.l	(a0)+,d0							; destination
		move.w	(a0)+,d1							; width
		move.w	(a0)+,d2							; height
		bsr.s	Plane_Map_To_VRAM
		dbf	d6,.load
		rts

; ---------------------------------------------------------------------------
; Copies a plane map to a plane PNT
; Inputs:
; a1 = map address
; d0 = VDP command to write to the PNT
; d1 = number of cells in a row - 1
; d2 = number of cell rows - 1
; d3 = VRAM shift
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Plane_Map_To_Add_VRAM:
		move.l	#vdpCommDelta(planeLoc(64,0,1)),d4

.main
		lea	(VDP_data_port).l,a6						; load VDP data address to a6
		lea	VDP_control_port-VDP_data_port(a6),a5				; load VDP control address to a5

.loop2
		move.l	d0,VDP_control_port-VDP_control_port(a5)
		move.w	d1,d5

.loop
		move.w	(a1)+,d6
		add.w	d3,d6								; add VRAM shift
		move.w	d6,VDP_data_port-VDP_data_port(a6)
		dbf	d5,.loop							; copy one row
		add.l	d4,d0								; move onto next row
		dbf	d2,.loop2							; and copy it
		rts

; ---------------------------------------------------------------------------
; Clear plane PNT
; Inputs:
; d0 = VDP command to write to the PNT
; d1 = number of cells in a row - 1
; d2 = number of cell rows - 1
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Clear_Plane_Map:
		move.l	#vdpCommDelta(planeLoc(64,0,1)),d4				; row increment value

.main
		lea	(VDP_data_port).l,a6						; load VDP data address to a6
		lea	VDP_control_port-VDP_data_port(a6),a5				; load VDP control address to a5

.loop
		move.w	d1,d3
		move.l	d0,VDP_control_port-VDP_control_port(a5)

.clear
		move.w	#0,VDP_data_port-VDP_data_port(a6)
		dbf	d3,.clear							; copy one row
		add.l	d4,d0								; move onto next row
		dbf	d2,.loop							; and copy it
		rts

; ---------------------------------------------------------------------------
; Copies a plane map to RAM
; Inputs:
; a1 = map address
; a2 = output buffer
; d1 = number of cells in a row - 1
; d2 = number of cell rows - 1
; d3 = next row
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Plane_Map_To_RAM:

.loop2
		move.w	d1,d5
		lea	(a2),a3

.loop
		move.w	(a1)+,(a3)+
		dbf	d5,.loop							; copy one row
		adda.w	d3,a2								; move onto next row
		dbf	d2,.loop2							; and copy it
		rts

; =============== S U B R O U T I N E =======================================

Copy_Map_Line_To_VRAM:
		subi.w	#16,d1
		blo.s	.return
		move.w	d1,d3
		andi.w	#7,d3
		bne.s	.return
		andi.w	#$F8,d1
		move.w	d1,d2
		add.w	d1,d1
		move.w	d1,d3
		add.w	d1,d1
		add.w	d1,d1
		add.w	d3,d1
		adda.w	d1,a1
		lsl.w	#4,d2
		swap	d0
		add.w	d2,d0
		swap	d0
		moveq	#bytesToXcnt(320,8),d3
		lea	(VDP_data_port).l,a6						; load VDP data address to a6
		lea	VDP_control_port-VDP_data_port(a6),a5				; load VDP control address to a5
		disableInts
		bsr.s	RAM_Map_Data_Copy
		enableInts

.return
		rts

; =============== S U B R O U T I N E =======================================

RAM_Map_Data_Copy:
		move.l	d0,VDP_control_port-VDP_control_port(a5)

.loop
		move.w	(a1)+,VDP_data_port-VDP_data_port(a6)
		dbf	d3,.loop							; copy one row
		rts

; =============== S U B R O U T I N E =======================================

RAM_Map_Data_To_VDP:
		lea	(VDP_data_port).l,a6						; load VDP data address to a6
		lea	VDP_control_port-VDP_data_port(a6),a5				; load VDP control address to a5

.main
		moveq	#bytesToXcnt(320,8),d1
		moveq	#bytesToXcnt(256,8),d2

.loop
		lea	(a1),a2
		move.w	d1,d3
		bsr.s	RAM_Map_Data_Copy
		lea	(a2),a1
		addi.l	#vdpCommDelta(planeLoc(64,0,1)),d0
		dbf	d2,.loop
		rts

; =============== S U B R O U T I N E =======================================

ClearVRAMArea:
		lea	(VDP_data_port).l,a6						; load VDP data address to a6
		lea	VDP_control_port-VDP_data_port(a6),a5				; load VDP control address to a5

.main
		move.l	d0,VDP_control_port-VDP_control_port(a5)
		moveq	#0,d0

.clear
		move.l	d0,VDP_data_port-VDP_data_port(a6)
		dbf	d3,.clear
		rts

; =============== S U B R O U T I N E =======================================

CalcVRAM:
		swap	d0
		clr.w	d0
		swap	d0

CalcVRAM2:
		lsl.l	#2,d0
		lsr.w	#2,d0
		ori.w	#vdpComm(0,VRAM,WRITE)>>16,d0
		swap	d0
		rts
