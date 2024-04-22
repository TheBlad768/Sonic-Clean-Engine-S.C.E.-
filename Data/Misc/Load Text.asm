; ---------------------------------------------------------------------------
; Display 8x8 text on the plan
; Inputs:
; d1 = plane address
; d3 = vram shift
; a1 = source address
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Load_PlaneText:
		disableIntsSave
		lea	(VDP_data_port).l,a6
		lea	VDP_control_port-VDP_data_port(a6),a5

.skipvdp
		move.l	#vdpCommDelta(planeLocH40(0,1)),d2

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
		cmpi.b	#-1,d0									; if $FF flag, stop loading letters
		beq.s	.exit

.nextline
		andi.w	#$1F,d0									; if $80-$9F flag, load letters to the next line

.donextline
		add.l	d2,d1
		dbf	d0,.donextline
		bra.s	.setpos
; ---------------------------------------------------------------------------

.exit
		enableIntsSave
		rts
