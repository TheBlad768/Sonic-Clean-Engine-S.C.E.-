; ---------------------------------------------------------------------------
; Display 8x8 text on the plane
;
; Inputs:
; d1 = plane address
; d3 = VRAM shift
; a1 = source address
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Draw_PlaneText:
		disableIntsSave
		movem.l	d4-d6,-(sp)							; save the registers to the stack
		lea	(VDP_data_port).l,a6						; load VDP data address to a6
		lea	VDP_control_port-VDP_data_port(a6),a5				; load VDP control address to a5

.skipvdp
		move.l	#vdpCommDelta(planeLoc(64,0,1)),d2				; row increment value

.setpos
		move.l	d1,VDP_control_port-VDP_control_port(a5)			; set plane address

.loop
		moveq	#0,d0
		move.b	(a1)+,d0							; get character to d0
		bmi.s	.options							; if minus, branch
		add.w	d3,d0								; VRAM shift
		move.w	d0,VDP_data_port-VDP_data_port(a6)
		bra.s	.loop								; next character
; ---------------------------------------------------------------------------

.exit
		movem.l	(sp)+,d4-d6							; return saved registers from the stack
		enableIntsSave
		rts
; ---------------------------------------------------------------------------

.options
		cmpi.b	#-1,d0								; if $FF(-1) flag, stop loading characters
		beq.s	.exit
		cmpi.b	#-2,d0								; if $FE(-2) flag, calc position loading characters
		beq.s	.calcxpos
		cmpi.b	#$A0,d0								; if $80-$9F flag, load characters to the next line
		blo.s	.nextline

		; check palette line
		cmpi.b	#$F2,d0								; if $F2-$F5 flag, change palette line
		blo.s	.loop								; next character
		cmpi.b	#$F5,d0
		bhs.s	.loop								; next character

		; set palette line
		subi.b	#$F2,d0
		andi.w	#3,d0								; only 4 lines of the palette
		ror.w	#3,d0								; get palette line
		andi.w	#~(palette_mask),d3						; remove palette line from VRAM shift
		or.w	d0,d3								; set new VRAM shift
		bra.s	.loop								; next character
; ---------------------------------------------------------------------------

.nextline
		andi.w	#$1F,d0								; get next line size
		addq.w	#1,d0								; fix zero value
		swap	d2								; get word from long
		mulu.w	d2,d0								; multiply by the next line
		swap	d2								; get long from word
		swap	d0								; "
		clr.w	d0								; "
		add.l	d0,d1								; add calculated position
		bra.s	.setpos								; next character
; ---------------------------------------------------------------------------

.calcxpos

		; get position
		move.l	d1,d5								; copy plane address to d5

		; calc center position
		moveq	#0,d0
		move.b	(a1)+,d0							; get text size (second byte parameter)
		moveq	#screen_width/8,d4						; max 40 characters
		sub.w	d0,d4								; subtract the number of characters from the screen width
		lsr.w	d4								; get even values only
		add.w	d4,d4								; multiply by 2
		swap	d4								; get long from word
		clr.w	d4								; "
		add.l	d4,d5								; add calculated position
		move.l	d5,VDP_control_port-VDP_control_port(a5)			; set plane address
		bra.s	.loop								; next character

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

Draw_PlaneText_Advanced:
		disableIntsSave
		movem.l	d1/d4-d6,-(sp)							; save the registers to the stack
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
		bmi.s	.options							; if minus, branch

		; get character tile
		mulu.w	d6,d0								; multiply the total number of tiles
		add.w	d3,d0								; VRAM shift

		; get character size
		move.w	d2,d4								; copy horizontal character size to d4
		swap	d2								; get vertical character size

.row
		move.w	d2,d5								; copy vertical character size to d5
		move.l	d1,VDP_control_port-VDP_control_port(a5)			; set plane address

.column
		move.w	d0,VDP_data_port-VDP_data_port(a6)
		addq.w	#1,d0								; next character tile
		dbf	d5,.column							; check vertical character size end
		addi.l	#vdpCommDelta(planeLoc(64,1,0)),d1				; next row
		dbf	d4,.row								; check horizontal character size end
		swap	d2								; get horizontal character size
		bra.s	.loop								; next character
; ---------------------------------------------------------------------------

.options
		cmpi.b	#-1,d0								; if $FF(-1) flag, stop loading characters
		beq.s	.exit

		; next line
		andi.w	#$1F,d0								; get next line size
		addq.w	#1,d0								; fix zero value
		swap	d2								; get vertical character size
		move.w	d2,d5								; copy horizontal character size to d5
		addq.w	#1,d5								; dbf fix
		mulu.w	d5,d0								; multiply by the vertical character size
		mulu.w	#$80,d0								; multiply by the next line
		swap	d0								; get long from word
		clr.w	d0								; "
		add.l	d0,(sp)								; add calculated position to stack
		move.l	(sp),d1								; get new plane address from stack
		swap	d2								; get horizontal character size
		bra.s	.loop								; next character
; ---------------------------------------------------------------------------

.exit

		; exit
		move.w	#$8F02,VDP_control_port-VDP_control_port(a5)			; VRAM increment at 2 bytes (draw tiles horizontally)
		movem.l	(sp)+,d1/d4-d6							; return saved registers from the stack
		enableIntsSave
		rts
