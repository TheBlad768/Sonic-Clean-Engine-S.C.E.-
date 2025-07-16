; ---------------------------------------------------------------------------
; Dynamic level events
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Do_ResizeEvents:

		; check
		move.l	(Level_data_addr_RAM.Resize).w,d0
		beq.s	.rskip								; if zero, branch
		movea.l	d0,a0
		jsr	(a0)

.rskip
		moveq	#2,d1								; set camera lowering speed
		move.w	(Camera_target_max_Y_pos).w,d0
		sub.w	(Camera_max_Y_pos).w,d0
		beq.s	.return								; if it's same position, branch
		bhs.s	.check
		neg.w	d1								; change to camera raising speed
		move.w	(Camera_Y_pos).w,d0
		cmp.w	(Camera_target_max_Y_pos).w,d0
		bls.s	.set
		move.w	d0,(Camera_max_Y_pos).w
		andi.w	#$FFFE,(Camera_max_Y_pos).w					; align (2 pixels)

.set
		add.w	d1,(Camera_max_Y_pos).w
		st	(Camera_max_Y_pos_changing).w

.return
		rts
; ---------------------------------------------------------------------------

.check
		move.w	(Camera_Y_pos).w,d0
		addq.w	#8,d0
		cmp.w	(Camera_max_Y_pos).w,d0
		blo.s	.set2
		btst	#status.player.in_air,(Player_1+status).w			; is the player in the air?
		beq.s	.set2								; if not, branch
		add.w	d1,d1								; multiply by 4
		add.w	d1,d1

.set2
		add.w	d1,(Camera_max_Y_pos).w
		st	(Camera_max_Y_pos_changing).w
		rts
