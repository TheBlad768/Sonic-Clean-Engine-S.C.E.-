; ---------------------------------------------------------------------------
; Display 8x8 text on the plane
;
; Inputs:
; d1 = plane address
; d3 = VRAM shift
; a1 = source address
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Load_PlaneText:
		disableIntsSave
		lea	(VDP_data_port).l,a6						; load VDP data address to a6
		lea	VDP_control_port-VDP_data_port(a6),a5				; load VDP control address to a5

.skipvdp
		move.l	#vdpCommDelta(planeLoc(64,0,1)),d2

.setpos
		move.l	d1,VDP_control_port-VDP_control_port(a5)

.loop
		moveq	#0,d0
		move.b	(a1)+,d0							; get character to d0
		bmi.s	.options							; if minus, branch
		add.w	d3,d0								; VRAM shift
		move.w	d0,VDP_data_port-VDP_data_port(a6)
		bra.s	.loop
; ---------------------------------------------------------------------------

.exit
		enableIntsSave
		rts
; ---------------------------------------------------------------------------

.options
		cmpi.b	#-1,d0								; if $FF(-1) flag, stop loading characters
		beq.s	.exit
		cmpi.b	#-2,d0								; if $FE(-2) flag, calc pos loading characters
		beq.s	.calcxpos
		cmpi.b	#$A0,d0								; if $80-$9F flag, load characters to the next line
		blo.s	.nextline

		; check palette line
		cmpi.b	#$F2,d0								; if $F2-$F5 flag, change palette line
		blo.s	.loop
		cmpi.b	#$F5,d0
		bhs.s	.loop

		; set palette line
		subi.b	#$F2,d0
		andi.w	#3,d0
		ror.w	#3,d0
		andi.w	#$9FFF,d3
		or.w	d0,d3
		bra.s	.loop
; ---------------------------------------------------------------------------

.nextline
		andi.w	#$1F,d0
		addq.w	#1,d0
		swap	d2
		mulu.w	d2,d0
		swap	d2
		swap	d0
		clr.w	d0
		add.l	d0,d1
		bra.s	.setpos
; ---------------------------------------------------------------------------

.calcxpos

		; get pos
		move.l	d1,d5

		; calc center position
		moveq	#0,d0
		move.b	(a1)+,d0							; get text size (second byte parameter)
		moveq	#screen_width/8,d4						; max 40 characters
		sub.w	d0,d4
		lsr.w	d4								; even value
		add.w	d4,d4
		swap	d4
		clr.w	d4
		add.l	d4,d5
		move.l	d5,VDP_control_port-VDP_control_port(a5)
		bra.s	.loop

; ---------------------------------------------------------------------------
; Display text on the plane
;
; Inputs:
; d1 = plane address
; d2 = horizontal and vertical character size (size/8-1)
; d3 = VRAM shift
; a1 = source address
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Load_PlaneText_2:
		disableIntsSave
		lea	(VDP_data_port).l,a6						; load VDP data address to a6
		lea	VDP_control_port-VDP_data_port(a6),a5				; load VDP control address to a5
		move.w	#$8F80,VDP_control_port-VDP_control_port(a5)			; VRAM increment at $80 bytes (vertical write)

		; get character size
		move.w	d2,d6								; copy vertical character size to d6
		addq.w	#1,d6								; dbf fix
		swap	d2								; get horizontal character size
		move.w	d2,d5								; copy horizontal character size to d5
		addq.w	#1,d5								; dbf fix
		mulu.w	d5,d6								; multiply the total number of tiles

.loop
		moveq	#0,d0
		move.b	(a1)+,d0							; get character to d0
		bmi.s	.exit								; if $FF(-1) flag, stop loading characters

		; get character tile
		mulu.w	d6,d0								; multiply the total number of tiles
		add.w	d3,d0								; VRAM shift

		; get character size
		move.w	d2,d4								; copy horizontal character size to d4
		swap	d2								; get vertical character size

.row
		move.w	d2,d5								; copy vertical character size to d5
		move.l	d1,VDP_control_port-VDP_control_port(a5)

.column
		move.w	d0,VDP_data_port-VDP_data_port(a6)
		addq.w	#1,d0								; next character tile
		dbf	d5,.column							; check vertical character size end
		addi.l	#vdpCommDelta(planeLoc(64,1,0)),d1				; next row
		dbf	d4,.row								; check horizontal character size end
		swap	d2								; get horizontal character size
		bra.s	.loop								; next character
; ---------------------------------------------------------------------------

.exit

		; exit
		move.w	#$8F02,VDP_control_port-VDP_control_port(a5)			; VRAM increment at 2 bytes (draw tiles horizontally)
		enableIntsSave
		rts
