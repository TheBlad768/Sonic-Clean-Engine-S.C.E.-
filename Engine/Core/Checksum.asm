; ---------------------------------------------------------------------------
; Checksum check
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Test_Checksum:
		movea.w	#EndOfHeader,a0							; start checking bytes after the header ($200)
		move.l	(ROMEndLoc).w,d1						; stop at end of ROM
		sub.l	a0,d1									; subtract start address to get size
		lsr.l	#6,d1										; divide by 64 (32 words)
		moveq	#0,d0									; initialize checksum

.loop

	rept 32
		add.w	(a0)+,d0
	endr

		dbf	d1,.loop

		; check
		cmp.w	(Checksum).w,d0							; compare correct checksum to the one in ROM
		beq.s	.exit								; if they match, branch

		; failed
		move.l	#vdpComm($0000,CRAM,WRITE),(VDP_control_port).l			; set VDP to CRAM write
		moveq	#bytesToXcnt(64,2),d7

.fill
		move.l	#words_to_long($E,$E),(VDP_data_port).l				; fill palette with red
		dbf	d7,.fill							; repeat 32 more times

		; freeze
		bra.s	*
; ---------------------------------------------------------------------------

.exit
		rts