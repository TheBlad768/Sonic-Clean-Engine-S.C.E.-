; ---------------------------------------------------------------------------
; Subroutine to clear the screen
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

ClearScreen:
Clear_DisplayData:
		stopZ80
		lea	(VDP_control_port).l,a5
		dmaFillVRAM 0,$0000,($1000<<4)		; clear VRAM
		startZ80
		clr.l	(V_scroll_value).w
		clr.l	(H_scroll_value).w
		clearRAM Sprite_table_buffer, Sprite_table_buffer_end
		clearRAM H_scroll_buffer, H_scroll_buffer_end
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
		move.l	#vdpCommDelta(planeLocH32(0,1)),d4	; row increment value
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
		move.l	#vdpCommDelta(planeLocH80(0,1)),d4	; row increment value
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

TilemapToVRAM:
ShowVDPGraphics:
PlaneMapToVRAM:
Plane_Map_To_VRAM:
		move.l	#vdpCommDelta(planeLocH40(0,1)),d4	; row increment value

.main
		lea	(VDP_data_port).l,a6
		lea	VDP_control_port-VDP_data_port(a6),a5

.loop2
		move.w	d1,d3
		move.l	d0,VDP_control_port-VDP_control_port(a5)

.loop
		move.w	(a1)+,VDP_data_port-VDP_data_port(a6)
		dbf	d3,.loop		; copy one row
		add.l	d4,d0	; move onto next row
		dbf	d2,.loop2		; and copy it
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
		move.l	#vdpCommDelta(planeLocH40(0,1)),d4

.main
		lea	(VDP_data_port).l,a6
		lea	VDP_control_port-VDP_data_port(a6),a5

.loop2
		move.l	d0,VDP_control_port-VDP_control_port(a5)
		move.w	d1,d5

.loop
		move.w	(a1)+,d6
		add.w	d3,d6	; add VRAM shift
		move.w	d6,VDP_data_port-VDP_data_port(a6)
		dbf	d5,.loop		; copy one row
		add.l	d4,d0	; move onto next row
		dbf	d2,.loop2		; and copy it
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
		move.l	#vdpCommDelta(planeLocH40(0,1)),d4	; row increment value

.main
		lea	(VDP_data_port).l,a6
		lea	VDP_control_port-VDP_data_port(a6),a5

.loop
		move.w	d1,d3
		move.l	d0,VDP_control_port-VDP_control_port(a5)

.clear
		move.w	#0,VDP_data_port-VDP_data_port(a6)
		dbf	d3,.clear		; copy one row
		add.l	d4,d0	; move onto next row
		dbf	d2,.loop		; and copy it
		rts

; =============== S U B R O U T I N E =======================================

Copy_Map_Line_To_VRAM:
		subi.w	#16,d1
		bcs.s	.return
		move.w	d1,d3
		andi.w	#7,d3
		bne.s	.return
		andi.w	#$F8,d1
		move.w	d1,d2
		add.w	d1,d1
		move.w	d1,d3
		lsl.w	#2,d1
		add.w	d3,d1
		lea	(a1,d1.w),a1
		lsl.w	#4,d2
		swap	d0
		add.w	d2,d0
		swap	d0
		moveq	#320/8-1,d3
		disableInts
		lea	(VDP_data_port).l,a6
		lea	VDP_control_port-VDP_data_port(a6),a5
		bsr.s	RAM_Map_Data_Copy
		enableInts

.return
		rts

; =============== S U B R O U T I N E =======================================

RAM_Map_Data_Copy:
		move.l	d0,VDP_control_port-VDP_control_port(a5)

.loop
		move.w	(a1)+,VDP_data_port-VDP_data_port(a6)
		dbf	d3,.loop	; copy one row
		rts

; =============== S U B R O U T I N E =======================================

RAM_Map_Data_To_VDP:
		lea	(VDP_data_port).l,a6
		lea	VDP_control_port-VDP_data_port(a6),a5

.main
		moveq	#320/8-1,d1
		moveq	#256/8-1,d2

.loop
		movea.l	a1,a2
		move.w	d1,d3
		bsr.s	RAM_Map_Data_Copy
		movea.l	a2,a1
		addi.l	#vdpCommDelta(planeLocH40(0,1)),d0
		dbf	d2,.loop
		rts

; =============== S U B R O U T I N E =======================================

ClearVRAMArea:
		lea	(VDP_data_port).l,a6
		lea	VDP_control_port-VDP_data_port(a6),a5

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
		ori.w	#$4000,d0
		swap	d0
		rts
