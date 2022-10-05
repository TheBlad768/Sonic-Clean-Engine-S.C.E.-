; ---------------------------------------------------------------------------
; VDP init
; ---------------------------------------------------------------------------

VDP_register_values:
		dc.w $8004						; H-int disabled
		dc.w $8134						; V-int enabled, display blanked, DMA enabled, 224 line display
		dc.w $8200+(vram_fg>>10)		; Scroll A PNT base $C000
		dc.w $8300+(vram_window>>10)	; Window PNT base $C000
		dc.w $8400+(vram_bg>>13)		; Scroll B PNT base $E000
		dc.w $8500+(vram_sprites>>9)		; Sprite attribute table base $D400
		dc.w $8600						; Sprite Pattern Generator Base Address: low 64KB VRAM
		dc.w $8700+(0<<4)				; Backdrop color is color 0 of the first palette line
		dc.w $8800						; unused
		dc.w $8900						; unused
		dc.w $8A00						; default H.interrupt register
		dc.w $8B00						; Full-screen horizontal and vertical scrolling
		dc.w $8C81						; 40 cell wide display, no interlace
		dc.w $8D00+(vram_hscroll>>10)	; Horizontal scroll table base $F000
		dc.w $8E00						; Nametable Pattern Generator Base Address: low 64KB VRAM
		dc.w $8F02						; VDP auto increment is 2
		dc.w $9001						; Scroll planes are 64x32 cells (512x256)
		dc.w $9100						; Window horizontal position
		dc.w $9200						; Window vertical position

; =============== S U B R O U T I N E =======================================

Init_VDP:
		lea	(VDP_data_port).l,a6
		lea	VDP_control_port-VDP_data_port(a6),a5
		lea	VDP_register_values(pc),a1
		moveq	#19-1,d1

.setreg
		move.w	(a1)+,VDP_control_port-VDP_control_port(a5)
		dbf	d1,.setreg	; set the VDP registers
		move.w	VDP_register_values+2(pc),d0
		move.w	d0,(VDP_reg_1_command).w
		move.w	#$8A00+223,(H_int_counter_command).w
		moveq	#0,d0

; Clear Vertical Scrolling
		move.l	#vdpComm($0000,VSRAM,WRITE),VDP_control_port-VDP_control_port(a5)
		move.l	d0,VDP_data_port-VDP_data_port(a6)	; FG/BG

; Clear Palette
		move.l	#vdpComm($0000,CRAM,WRITE),VDP_control_port-VDP_control_port(a5)
		moveq	#64/2-1,d1

.clrCRAM
		move.l	d0,VDP_data_port-VDP_data_port(a6)
		dbf	d1,.clrCRAM	; clear the CRAM
		clr.l	(V_scroll_value).w
		clr.l	(H_scroll_value).w

; Clear VRAM
		dmaFillVRAM 0,$0000,($1000<<4)	; clear entire VRAM
		rts

; ---------------------------------------------------------------------------
; VDP load
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Load_VDP:
		lea	(VDP_control_port).l,a6

.main
		move.w	(a1)+,d0

.loop
		move.w	d0,VDP_control_port-VDP_control_port(a6)
		move.w	(a1)+,d0
		bmi.s	.loop
		rts
