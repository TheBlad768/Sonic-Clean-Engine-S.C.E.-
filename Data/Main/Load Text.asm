; ---------------------------------------------------------------------------
; Display 8x8 text on the plan
; Inputs:
; d1 = plane address
; d3 = VRAM shift
; a1 = source address
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Load_PlaneText:
		disableIntsSave
		lea	(VDP_data_port).l,a6
		lea	VDP_control_port-VDP_data_port(a6),a5

.skipvdp
		move.l	#vdpCommDelta(planeLoc(64,0,1)),d2

.setpos
		move.l	d1,VDP_control_port-VDP_control_port(a5)

.loop
		moveq	#0,d0
		move.b	(a1)+,d0
		bmi.s	.options
		add.w	d3,d0									; VRAM shift
		move.w	d0,VDP_data_port-VDP_data_port(a6)
		bra.s	.loop
; ---------------------------------------------------------------------------

.options
		cmpi.b	#$A0,d0									; if $80-$9F flag, load letters to the next line
		blo.s		.nextline
		cmpi.b	#-1,d0									; if $FF(-1) flag, stop loading letters
		beq.s	.exit
		cmpi.b	#-2,d0									; if $FE(-2) flag, calc pos loading letters
		beq.s	.calcxpos

		; check palette line
		cmpi.b	#$F2,d0									; if $F2-$F5 flag, change palette line
		blo.s		.loop
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

.donextline
		add.l	d2,d1
		dbf	d0,.donextline
		bra.s	.setpos
; ---------------------------------------------------------------------------

.calcxpos

		; get pos
		move.l	d1,d5
		move.l	d5,VDP_control_port-VDP_control_port(a5)

		; clear line
		moveq	#0,d0
		moveq	#40-1,d4									; max 40 characters

.clearxpos
		move.w	d0,VDP_data_port-VDP_data_port(a6)
		dbf	d4,.clearxpos
		move.l	d5,VDP_control_port-VDP_control_port(a5)

		moveq	#40-1,d4									; max 40 characters

		; calc center position
		moveq	#0,d0
		move.b	(a1)+,d0									; get name size
		move.w	d0,d6
		addq.w	#1,d4									; fix dbf count(-1)
		sub.w	d0,d4
		lsr.w	d4										; even value
		add.w	d4,d4
		swap	d4
		clr.w	d4
		add.l	d4,d5
		move.l	d5,VDP_control_port-VDP_control_port(a5)
		bra.s	.loop
; ---------------------------------------------------------------------------

.exit
		enableIntsSave
		rts
