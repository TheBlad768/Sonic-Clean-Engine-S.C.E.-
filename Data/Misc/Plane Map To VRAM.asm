; ---------------------------------------------------------------------------
; Subroutine to clear the screen
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

ClearScreen:
Clear_DisplayData:
		stopZ80
		dmaFillVRAM 0,$0000,($1000<<4)		; clear VRAM
		clr.l	(V_scroll_value).w
		clr.l	(H_scroll_value).w
		clearRAM Sprite_table_buffer, Sprite_table_buffer_End
		clearRAM H_scroll_buffer, H_scroll_buffer_End
		startZ80
		bra.w	Init_SpriteTable
; End of function Clear_DisplayData
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
		lea	(VDP_data_port).l,a6
		move.l	#vdpCommDelta(planeLocH32(0,1)),d4	; row increment value
		bra.s	Plane_Map_To_VRAM.loop
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
		lea	(VDP_data_port).l,a6
		move.l	#vdpCommDelta(planeLocH80(0,1)),d4	; row increment value
		bra.s	Plane_Map_To_VRAM.loop
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
		lea	(VDP_data_port).l,a6
		move.l	#vdpCommDelta(planeLocH40(0,1)),d4	; row increment value

.loop	move.w	d1,d3
		bsr.s	RAM_Map_Data_Copy
		add.l	d4,d0			; move onto next row
		dbf	d2,.loop				; and copy it
		rts
; End of function Plane_Map_To_VRAM
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
		lea	(VDP_data_port).l,a6
		move.l	#vdpCommDelta(planeLocH40(0,1)),d4

-		move.l	d0,VDP_control_port-VDP_data_port(a6)
		move.w	d1,d5

-		move.w	(a1)+,d6
		add.w	d3,d6	; add VRAM shift
		move.w	d6,VDP_data_port-VDP_data_port(a6)
		dbf	d5,-			; copy one row
		add.l	d4,d0	; move onto next row
		dbf	d2,--		; and copy it
		rts
; End of function Plane_Map_To_Add_VRAM

; =============== S U B R O U T I N E =======================================

Copy_Map_Line_To_VRAM:
		subi.w	#16,d1
		bcs.s	+
		move.w	d1,d3
		andi.w	#7,d3
		bne.s	+
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
		bsr.s	RAM_Map_Data_Copy
		enableInts
+		rts
; End of function Copy_Map_Line_To_VRAM
; =============== S U B R O U T I N E =======================================

RAM_Map_Data_Copy:
		move.l	d0,VDP_control_port-VDP_data_port(a6)

-		move.w	(a1)+,VDP_data_port-VDP_data_port(a6)
		dbf	d3,-				; copy one row
		rts
; End of function RAM_Map_Data_Copy

; =============== S U B R O U T I N E =======================================

RAM_Map_Data_To_VDP:
		lea	(VDP_data_port).l,a6
		moveq	#320/8-1,d1
		moveq	#256/8-1,d2

-		movea.l	a1,a2
		move.w	d1,d3
		bsr.s	RAM_Map_Data_Copy
		movea.l	a2,a1
		addi.l	#vdpCommDelta(planeLocH40(0,1)),d0
		dbf	d2,-
		rts
; End of function RAM_Map_Data_To_VDP

; =============== S U B R O U T I N E =======================================

ClearVRAMArea:
		lea	(VDP_data_port).l,a6
		move.l	d0,VDP_control_port-VDP_data_port(a6)
		moveq	#0,d0
-		move.l	d0,VDP_data_port-VDP_data_port(a6)
		dbf	d3,-
		rts
; End of function ClearVRAMArea

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
; End of function CalcVRAM
