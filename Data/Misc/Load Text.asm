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
		move.l	#vdpCommDelta(planeLocH40(0,1)),d2

Load_PlaneText_SetPos:
		move.l	d1,VDP_control_port-VDP_control_port(a5)

Load_PlaneText_Loop:
		moveq	#0,d0
		move.b	(a1)+,d0
		bmi.s	Load_PlaneText_Options
		add.w	d3,d0						; VRAM shift
		move.w	d0,VDP_data_port-VDP_data_port(a6)
		bra.s	Load_PlaneText_Loop
; ---------------------------------------------------------------------------

Load_PlaneText_Options:
		cmpi.b	#-1,d0						; If $FF flag, stop loading letters
		beq.s	Load_PlaneText_Return

Load_PlaneText_NextLine:
		andi.w	#$1F,d0						; If $80-$9F flag, load letters to the next line

-		add.l	d2,d1
		dbf	d0,-
		bra.s	Load_PlaneText_SetPos
; ---------------------------------------------------------------------------

Load_PlaneText_Return:
		enableIntsSave
		rts
