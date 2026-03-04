; ---------------------------------------------------------------------------
; Check camera boundary subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Check_CameraBoundary:
		move.w	(Camera_X_pos).w,(Camera_min_X_pos).w				; lock min x to current camera position

		; check y boundary
		move.w	(Camera_target_max_Y_pos).w,d0
		cmp.w	(Camera_max_Y_pos).w,d0						; has the camera reached this y limit?
		blo.s	Check_CameraInRange.return					; if not, branch
		move.w	d0,(Camera_min_Y_pos).w						; set top boundary

		; check x boundary
		move.w	boss_x_boundary(a0),d0						; load the x-axis boundary
		cmp.w	(Camera_X_pos).w,d0						; has the camera crossed x boundary position?
		bhi.s	Check_CameraInRange.return					; if not, branch

		; jump to custom code
		movea.l	jump_ptr(a0),a1
		jmp	(a1)

; ---------------------------------------------------------------------------
; Check camera range subroutine
; ---------------------------------------------------------------------------
;
; Input:
; a1 = pointer to boundary table
;
; Boundary Table:
; +0: min y boundary
; +2: max y boundary
; +4: min x boundary
; +6: max x boundary
; +8:  y boundary (used to set boss_side_y_bit)
; +10: y boundary (unused/padding)
; +12: x boundary (used to set boss_side_x_bit)
; +14: x boundary (unused/padding)

; =============== S U B R O U T I N E =======================================

Check_CameraInRange:

		; check xy camera position
		move.w	(Camera_Y_pos).w,d0
		cmp.w	(a1)+,d0
		blo.s	.fail
		cmp.w	(a1)+,d0
		bhi.s	.fail
		move.w	(Camera_X_pos).w,d1
		cmp.w	(a1)+,d1
		blo.s	.fail
		cmp.w	(a1)+,d1
		bhi.s	.fail

		; set xy side bits
		bclr	#boss_side_y_bit,boss_state_flags(a0)
		cmp.w	(a1),d0
		bls.s	.check
		bset	#boss_side_y_bit,boss_state_flags(a0)

.check
		bclr	#boss_side_x_bit,boss_state_flags(a0)
		cmp.w	4(a1),d1
		bls.s	.done
		bset	#boss_side_x_bit,boss_state_flags(a0)

.done
		move.l	(sp),address(a0)

.return
		rts
; ---------------------------------------------------------------------------

.fail
		addq.w	#4,sp								; exit from current object
		bra.w	Delete_Sprite_If_Not_In_Range

; ---------------------------------------------------------------------------
; Init camera boundary subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Init_CameraBoundary:
		st	(Boss_flag).w							; set boss flag

Init_CameraBoundary_2:
		music	mus_FadeOut							; fade out music
		move.w	#2*60,wait_timer(a0)						; set timer

Init_CameraBoundary_3:

		; set xy-axis boundaries
		move.w	(Camera_min_Y_pos).w,(Camera_stored_min_Y_pos).w
		move.w	(Camera_target_max_Y_pos).w,(Camera_stored_max_Y_pos).w
		move.w	(Camera_min_X_pos).w,(Camera_stored_min_X_pos).w
		move.w	(Camera_max_X_pos).w,(Camera_stored_max_X_pos).w
		move.l	(a1)+,(Camera_saved_min_Y_pos).w
		move.l	(a1)+,(Camera_saved_min_X_pos).w
		rts

; ---------------------------------------------------------------------------
; Check camera boundary subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Check_CameraInBoundary:

		; check music state
		btst	#boss_music_bit,boss_state_flags(a0)				; has boss music started?
		bne.s	.checky								; if yes, skip

		; wait
		subq.w	#1,wait_timer(a0)						; subtract 1
		bpl.s	.checky								; if timer has run out, branch

		; play music
		move.b	boss_saved_mus(a0),d0
		move.b	d0,(Current_music+1).w
		bsr.w	Play_Music
		bset	#boss_music_bit,boss_state_flags(a0)				; set music flag

.checky

		; check y camera state
		btst	#boss_lock_y_bit,boss_state_flags(a0)				; is y-axis already locked?
		bne.s	.checkx								; if yes, branch
		move.w	(Camera_Y_pos).w,d0						; get camera y pos

		; check y side bit
		tst.b	boss_state_flags(a0)						; was 7 bit set?
		bmi.s	.checkbottom							; if yes, branch

		; check top
		cmp.w	(Camera_saved_min_Y_pos).w,d0					; has camera reached top boundary?
		bhs.s	.locky								; if yes, branch
		move.w	d0,(Camera_min_Y_pos).w						; set top boundary
		bra.s	.checkx
; ---------------------------------------------------------------------------

.checkbottom
		moveq	#224-128,d1							; set bottom offset
		add.w	(Camera_saved_max_Y_pos).w,d1
		cmp.w	d1,d0								; has camera reached bottom boundary?
		bhi.s	.checkx								; if not, branch

.locky

		; set y-axis boundaries
		bset	#boss_lock_y_bit,boss_state_flags(a0)
		move.w	(Camera_saved_min_Y_pos).w,(Camera_min_Y_pos).w
		move.w	(Camera_saved_max_Y_pos).w,d0
		move.w	d0,(Camera_target_max_Y_pos).w

.checkx

		; check x camera state
		btst	#boss_lock_x_bit,boss_state_flags(a0)				; is x-axis already locked?
		bne.s	.checkdone							; if yes, branch
		move.w	(Camera_X_pos).w,d0						; get camera x pos

		; check x side bit
		btst	#boss_side_x_bit,boss_state_flags(a0)
		bne.s	.checkright

		; check left
		cmp.w	(Camera_saved_min_X_pos).w,d0					; has camera reached left boundary?
		bhs.s	.lockx								; if yes, branch
		move.w	d0,(Camera_min_X_pos).w						; set left boundary
		bra.s	.checkdone
; ---------------------------------------------------------------------------

.checkright
		cmp.w	(Camera_saved_max_X_pos).w,d0					; has camera reached right boundary?
		bls.s	.lockx								; if yes, branch
		move.w	d0,(Camera_max_X_pos).w						; set right boundary
		bra.s	.checkdone
; ---------------------------------------------------------------------------

.lockx

		; set x-axis boundaries
		bset	#boss_lock_x_bit,boss_state_flags(a0)				; set x-lock flag
		move.w	(Camera_saved_min_X_pos).w,(Camera_min_X_pos).w
		move.w	(Camera_saved_max_X_pos).w,(Camera_max_X_pos).w

.checkdone

		; check bits
		moveq	#signextendB( \
			setBit(boss_music_bit) | \
			setBit(boss_lock_y_bit) | \
			setBit(boss_lock_x_bit) \
		),d0

		and.b	boss_state_flags(a0),d0

		cmpi.b	#signextendB( \
			setBit(boss_music_bit) | \
			setBit(boss_lock_y_bit) | \
			setBit(boss_lock_x_bit) \
		),d0

		bne.s	Check_InTheirRange.return					; if bits are not set, branch

		; clear
		clr.w	boss_saved_mus(a0)						; clear boss_saved_mus and boss_state_flags

		; jump to custom code
		movea.l	jump_ptr(a0),a1
		jmp	(a1)

; ---------------------------------------------------------------------------
; Check in their range subroutine
; ---------------------------------------------------------------------------
;
; Input:
; a1 = parent object address
; a2 = pointer to range table
;
; Range Table:
; +0: min x range
; +2: max x range
; +4: min y range
; +6: max y range

; =============== S U B R O U T I N E =======================================

Check_InTheirRange:
		move.w	x_pos(a0),d0
		move.w	x_pos(a1),d1
		add.w	(a2)+,d1
		cmp.w	d1,d0
		blt.s	.fail
		add.w	(a2)+,d1
		cmp.w	d1,d0
		bge.s	.fail
		move.w	y_pos(a0),d0
		move.w	y_pos(a1),d1
		add.w	(a2)+,d1
		cmp.w	d1,d0
		blt.s	.fail
		add.w	(a2)+,d1
		cmp.w	d1,d0
		bge.s	.fail

		; success
		moveq	#1,d0

.return
		rts
; ---------------------------------------------------------------------------

.fail
		moveq	#0,d0
		rts

; ---------------------------------------------------------------------------
; Check in my range subroutine
; ---------------------------------------------------------------------------
;
; Input:
; a1 = player object address
; a2 = pointer to range table
;
; Range Table:
; +0: min x range
; +2: max x range
; +4: min y range
; +6: max y range

; =============== S U B R O U T I N E =======================================

Check_InMyRange:
		move.w	x_pos(a0),d0
		move.w	x_pos(a1),d1
		add.w	(a2)+,d0
		cmp.w	d0,d1
		blt.s	.fail
		add.w	(a2)+,d0
		cmp.w	d0,d1
		bge.s	.fail
		move.w	y_pos(a0),d0
		move.w	y_pos(a1),d1
		add.w	(a2)+,d0
		cmp.w	d0,d1
		blt.s	.fail
		add.w	(a2)+,d0
		cmp.w	d0,d1
		bge.s	.fail

		; success
		moveq	#1,d0
		rts
; ---------------------------------------------------------------------------

.fail
		moveq	#0,d0
		rts

; ---------------------------------------------------------------------------
; Check player in range subroutine
; ---------------------------------------------------------------------------
;
; Input:
; a1 = pointer to range table
;
; Output:
; d0.l = Player_2 and Player_1
;
; Range Table:
; +0: min x range
; +2: max x range
; +4: min y range
; +6: max y range

; =============== S U B R O U T I N E =======================================

Check_PlayerInRange:
		move.w	x_pos(a0),d3

.skipx
		move.w	y_pos(a0),d4

.main
		moveq	#0,d0
		lea	(Player_1).w,a2							; a2=character
		move.w	x_pos(a2),d1
		move.w	y_pos(a2),d2
		add.w	(a1)+,d3
		move.w	d3,d5
		add.w	(a1)+,d5
		add.w	(a1)+,d4
		move.w	d4,d6
		add.w	(a1)+,d6

		; check
		cmp.w	d3,d1
		blo.s	.return
		cmp.w	d5,d1
		bhs.s	.return
		cmp.w	d4,d2
		blo.s	.return
		cmp.w	d6,d2
		bhs.s	.return
		move.w	a2,d0

.return
		rts

; ---------------------------------------------------------------------------
; Check player in range 2 subroutine
; ---------------------------------------------------------------------------
;
; Input:
; a1 = pointer to range table
;
; Boundary Table:
; +0: min y boundary
; +2: max y boundary
; +4: min x boundary
; +6: max x boundary

; =============== S U B R O U T I N E =======================================

Check_PlayerInRange2:

		; check xy player position
		move.w	(Player_1+y_pos).w,d0
		cmp.w	(a1)+,d0
		blo.s	.fail
		cmp.w	(a1)+,d0
		bhi.s	.fail
		move.w	(Player_1+x_pos).w,d1
		cmp.w	(a1)+,d1
		blo.s	.fail
		cmp.w	(a1),d1
		bhi.s	.fail

		; success
		moveq	#1,d0
		rts
; ---------------------------------------------------------------------------

.fail
		moveq	#0,d0
		rts

; ---------------------------------------------------------------------------
; Check object off screen subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Chk_OffScreen:
		move.w	x_pos(a0),d0							; get object x-position
		sub.w	(Camera_X_pos).w,d0						; subtract screen x-position
		bmi.s	.offscreen
		cmpi.w	#screen_width,d0						; is object on the screen?
		bge.s	.offscreen							; if not, branch
		move.w	y_pos(a0),d0							; get object y-position
		sub.w	(Camera_Y_pos).w,d0						; subtract screen y-position
		bmi.s	.offscreen
		cmpi.w	#screen_height,d0						; is object on the screen?
		bge.s	.offscreen							; if not, branch

		; onscreen
		moveq	#0,d0								; set flag to 0
		rts
; ---------------------------------------------------------------------------

.offscreen
		moveq	#1,d0								; set flag to 1
		rts

; ---------------------------------------------------------------------------
; Check object off screen with width subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Chk_WidthOffScreen:
		moveq	#0,d1
		move.b	width_pixels(a0),d1
		move.w	x_pos(a0),d0							; get object x-position
		sub.w	(Camera_X_pos).w,d0						; subtract screen x-position
		add.w	d1,d0								; add object width
		bmi.s	.offscreen
		add.w	d1,d1
		sub.w	d1,d0
		cmpi.w	#screen_width,d0						; is object on the screen?
		bge.s	.offscreen							; if not, branch
		move.w	y_pos(a0),d0							; get object y-position
		sub.w	(Camera_Y_pos).w,d0						; subtract screen y-position
		bmi.s	.offscreen
		cmpi.w	#screen_height,d0						; is object on the screen?
		bge.s	.offscreen							; if not, branch

		; onscreen
		moveq	#0,d0								; set flag to 0
		rts
; ---------------------------------------------------------------------------

.offscreen
		moveq	#1,d0								; set flag to 1
		rts

; ---------------------------------------------------------------------------
; Check camera x boundary subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Check_CameraXBoundary:
		move.w	(Camera_X_pos).w,d0

.skipcam
		tst.w	x_vel(a0)
		beq.s	.return
		bmi.s	.left
		addi.w	#screen_width-block_width,d0
		cmp.w	x_pos(a0),d0
		bhi.s	.return
		clr.w	x_vel(a0)

.return
		rts
; ---------------------------------------------------------------------------

.left
		addi.w	#block_width,d0
		cmp.w	x_pos(a0),d0
		blo.s	.return2
		clr.w	x_vel(a0)

.return2
		rts

; ---------------------------------------------------------------------------
; Check camera x boundary 2 subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Check_CameraXBoundary2:
		move.w	(Camera_X_pos).w,d0

.skipcam
		tst.w	x_vel(a0)
		bmi.s	.left
		add.w	d2,d0
		cmp.w	x_pos(a0),d0
		bls.s	.setflipx
		rts
; ---------------------------------------------------------------------------

.left
		add.w	d1,d0
		cmp.w	x_pos(a0),d0
		blo.s	.return

.setflipx
		bchg	#render_flags.x_flip,render_flags(a0)
		neg.w	x_vel(a0)

.return
		rts

; ---------------------------------------------------------------------------
; Camera resize max y from x position subroutine
; ---------------------------------------------------------------------------
;
; Input:
; a1 = pointer to camera resize table
;
; Resize Table:
; +0: max y boundary
; +2: camera x position or -1 for end marker
; +4: max y boundary
; +6: camera x position or -1 for end marker
; etc...

; =============== S U B R O U T I N E =======================================

Resize_MaxYFromX:
		move.w	(Camera_X_pos).w,d0

.find
		move.l	(a1)+,d1
		cmp.w	d1,d0
		bhi.s	.find
		swap	d1
		tst.w	d1
		bpl.s	.skip
		andi.w	#$7FFF,d1
		move.w	d1,(Camera_max_Y_pos).w

.skip
		move.w	d1,(Camera_target_max_Y_pos).w
		rts

; ---------------------------------------------------------------------------
; Water resize max y from x position subroutine
; ---------------------------------------------------------------------------
;
; Input:
; a1 = pointer to water resize table
;
; Resize Table:
; +0: max y boundary
; +2: camera x position or -1 for end marker
; +4: max y boundary
; +6: camera x position or -1 for end marker
; etc...

; =============== S U B R O U T I N E =======================================

WaterResize_MaxYFromX:
		move.w	(Camera_X_pos).w,d0

.find
		move.l	(a1)+,d1
		cmp.w	d1,d0
		bhi.s	.find
		swap	d1
		tst.w	d1
		bpl.s	.skip
		andi.w	#$7FFF,d1
		move.w	d1,(Mean_water_level).w

.skip
		move.w	d1,(Target_water_level).w
		rts

; ---------------------------------------------------------------------------
; Change act camera sizes subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Change_ActSizes:

		; get level size
		movem.l	(Level_data_addr_RAM.xstart).w,d0-d1
		movem.l	d0-d1,(Camera_target_min_X_pos).w
		movem.l	d0-d1,(Camera_min_X_pos).w
		rts

; ---------------------------------------------------------------------------
; Change act camera sizes 2 subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Change_ActSizes2:

		; get level size
		lea	(Level_data_addr_RAM.xstart).w,a1
		move.w	(a1)+,(Camera_stored_min_X_pos).w
		move.w	(a1)+,(Camera_stored_max_X_pos).w
		move.w	(a1)+,(Camera_stored_min_Y_pos).w
		move.w	(a1)+,d1
		move.w	d1,(Camera_stored_max_Y_pos).w
		move.w	d1,(Camera_target_max_Y_pos).w

		; create change level size object
		lea	(Child7_ChangeLevSize).l,a2
		bra.w	CreateChild7_Normal2
