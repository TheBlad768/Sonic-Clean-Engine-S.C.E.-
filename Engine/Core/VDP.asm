; ---------------------------------------------------------------------------
; VDP init
; ---------------------------------------------------------------------------

VDP_register_values:
		dc.w $8004								; H-int disabled
		dc.w $8134								; V-int enabled, display blanked, DMA enabled, 224 line display
		dc.w $8200+(VRAM_Plane_A_Name_Table>>10)				; scroll A PNT base $C000
		dc.w $8300+(VRAM_Plane_W_Name_Table>>10)				; window PNT base $C000
		dc.w $8400+(VRAM_Plane_B_Name_Table>>13)				; scroll B PNT base $E000
		dc.w $8500+(VRAM_Sprite_Attribute_Table>>9)				; sprite attribute table base $D400
		dc.w $8600								; sprite Pattern Generator Base Address: low 64KB VRAM
		dc.w $8700+(0<<4)							; backdrop color is color 0 of the first palette line
		dc.w $8800								; unused
		dc.w $8900								; unused
		dc.w $8A00								; default H-int register
		dc.w $8B00								; full-screen horizontal and vertical scrolling
		dc.w $8C81								; 40 cell wide display, no interlace
		dc.w $8D00+(VRAM_Horiz_Scroll_Table>>10)				; horizontal scroll table base $F000
		dc.w $8E00								; nametable Pattern Generator Base Address: low 64KB VRAM
		dc.w $8F02								; VDP auto increment is 2
		dc.w $9001								; scroll planes are 64x32 cells (512x256)
		dc.w $9100								; window horizontal position
		dc.w $9200								; window vertical position
		dc.w 0									; end marker

; =============== S U B R O U T I N E =======================================

Init_VDP:

		; set VDP registers
		lea	VDP_register_values(pc),a1
		bsr.s	Load_VDP							; a6 now has a VDP control address do not overwrite this register
		move.w	VDP_register_values+2(pc),(VDP_reg_1_command).w
		move.w	#$8A00+223,(H_int_counter_command).w

		; clear data
		lea	VDP_data_port-VDP_data_port(a6),a5				; load VDP control address to a5
		lea	VDP_data_port-VDP_control_port(a5),a6				; load VDP data address to a6
		moveq	#0,d0

		; clear vertical scrolling
		move.l	#vdpComm(0,VSRAM,WRITE),VDP_control_port-VDP_control_port(a5)
		move.l	d0,VDP_data_port-VDP_data_port(a6)				; FG and BG
		move.l	d0,(V_scroll_value).w
		move.l	d0,(H_scroll_value).w

		; clear palette
		move.l	#vdpComm(0,CRAM,WRITE),VDP_control_port-VDP_control_port(a5)
		moveq	#bytesToXcnt(64,2),d1

.clrCRAM
		move.l	d0,VDP_data_port-VDP_data_port(a6)
		dbf	d1,.clrCRAM							; clear the CRAM

		; clear VRAM
		dmaFillVRAM 0,0,$10000							; clear entire VRAM
		rts

; ---------------------------------------------------------------------------
; VDP load
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Load_VDP:
		lea	(VDP_control_port).l,a6

.main
		move.w	(a1)+,d0							; get first VDP registers

.loop
		move.w	d0,VDP_control_port-VDP_control_port(a6)
		move.w	(a1)+,d0							; next VDP registers
		bmi.s	.loop
		rts
