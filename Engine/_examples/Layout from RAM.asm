; This is just an example. You can try to place the code in another place at your discretion.

; =============== S U B R O U T I N E =======================================

DEZ1_ScreenInit:

		; copy layout to RAM
		lea	(RAM_start+$7000).l,a1					; your free layout buffer address
		lea	(DEZ1_Layout).l,a4					; layout address
		move.w	#((DEZ1_Layout_end-DEZ1_Layout)/4)-1,d0			; layout size

.copy
		move.l	(a4)+,(a1)+
		dbf	d0,.copy


.layout		:= DEZ1_Layout
.layout_end	:= DEZ1_Layout_end

	if MOMPASS>1
		if (.layout_end-.layout)&2
			move.w	(a4)+,(a1)+
		endif
	endif


		; load layout from RAM
		lea	(RAM_start+$7000).l,a1					; your layout buffer address
		move.l	a1,(Level_layout_addr_ROM).w				; save to addr
		addq.w	#8,a1							; skip layout header
		move.l	a1,(Level_layout_addr2_ROM).w				; save to addr2

		; test
		move.l	#$0D0D0D0D,(RAM_start+$7120).l				; replace 4 chunks

		; update FG
		jsr	(Reset_TileOffsetPositionActual).w
		jmp	(Refresh_PlaneFull).w