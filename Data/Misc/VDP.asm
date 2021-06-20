VDP_register_values:
		dc.w $8004						; H-int disabled
		dc.w $8134						; V-int enabled, display blanked, DMA enabled, 224 line display
		dc.w $8200+(vram_fg>>10)		; Scroll A PNT base $C000
		dc.w $8300+(vram_window>>10)	; Window PNT base $C000
		dc.w $8400+(vram_bg>>13)		; Scroll B PNT base $E000
		dc.w $8500+(vram_sprites>>9)		; Sprite attribute table base $D400
		dc.w $8600						; unused
		dc.w $8700+(0<<4)				; Backdrop color is color 0 of the first palette line
		dc.w $8800						; unused
		dc.w $8900						; unused
		dc.w $8A00						; default H.interrupt register
		dc.w $8B00						; Full-screen horizontal and vertical scrolling
		dc.w $8C81						; 40 cell wide display, no interlace
		dc.w $8D00+(vram_hscroll>>10)	; Horizontal scroll table base $F000
		dc.w $8E00						; unused
		dc.w $8F02						; Auto-ncrement is 2
		dc.w $9001						; Scroll planes are 64x32 cells
		dc.w $9100						; Window horizontal position
		dc.w $9200						; Window vertical position

; =============== S U B R O U T I N E =======================================

Init_VDP:
		lea	(VDP_control_port).l,a0
		lea	(VDP_data_port).l,a1
		lea	VDP_register_values(pc),a2
		moveq	#18,d7

.setreg:
		move.w	(a2)+,VDP_control_port-VDP_control_port(a0)
		dbf	d7,.setreg	; set the VDP registers
		move.w	VDP_register_values+2(pc),d0
		move.w	d0,(VDP_reg_1_command).w
		move.w	#$8A00+223,(H_int_counter_command).w
		moveq	#0,d0

; Clear Vertical Scrolling
		move.l	#vdpComm($0000,VSRAM,WRITE),VDP_control_port-VDP_control_port(a0)
		move.w	d0,VDP_data_port-VDP_data_port(a1)	; FG
		move.w	d0,VDP_data_port-VDP_data_port(a1)	; BG

; Clear Palette
		move.l	#vdpComm($0000,CRAM,WRITE),VDP_control_port-VDP_control_port(a0)
		moveq	#64-1,d7

.clrCRAM:
		move.w	d0,VDP_data_port-VDP_data_port(a1)
		dbf	d7,.clrCRAM	; clear the CRAM
		clr.l	(V_scroll_value).w
		clr.l	(H_scroll_value).w

; Clear VRAM
		dmaFillVRAM 0,$0000,($1000<<4)	; clear entire VRAM
		rts
; End of function Init_VDP
