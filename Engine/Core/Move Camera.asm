; ---------------------------------------------------------------------------
; Background layer deformation subroutines
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

DeformBgLayer:
		tst.b	(Deform_lock).w
		bne.w	locret_1C0E6
		clr.l	(H_scroll_amount).w						; clear horizontal and vertical scroll amount
		tst.b	(Scroll_lock).w
		bne.s	.events
		lea	(Player_1).w,a0							; a0=character
		tst.b	(Scroll_force_positions).w
		beq.s	.notsforce
		clr.b	(Scroll_force_positions).w
		clr.w	(H_scroll_frame_offset).w
		lea	(Scroll_forced_X_pos-x_pos).w,a0				; is now a player address

.notsforce
		lea	(Camera_X_pos).w,a1
		lea	(Camera_min_X_pos).w,a2
		lea	(H_scroll_amount).w,a4
		lea	(H_scroll_frame_offset).w,a5
		lea	(Pos_table).w,a6
		bsr.s	MoveCameraX
		lea	(Camera_Y_pos).w,a1
		lea	(Camera_min_Y_pos).w,a2
		lea	(V_scroll_amount).w,a4
		move.w	(Distance_from_top).w,d3

	if ExtendedCamera
		bsr.w	MoveCameraY
	else
		bsr.s	MoveCameraY
	endif

.events
		bra.w	Do_ResizeEvents

; ---------------------------------------------------------------------------
; Subroutine to scroll the level horizontally as Sonic moves
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

MoveCameraX:

	if ExtendedCamera
		bsr.s	Camera_Extended
	endif

		move.w	(a1),d4								; get camera X pos
		move.w	(a5),d1								; should scrolling be delayed?
		beq.s	loc_1C0D2							; if not, branch
		subi.w	#$100,d1							; reduce delay value
		move.w	d1,(a5)
		moveq	#0,d1
		move.b	(a5),d1								; get delay value
		add.b	d1,d1								; multiply by 4, the size of a position buffer entry
		add.b	d1,d1
		addq.b	#4,d1
		move.w	Pos_table_index-H_scroll_frame_offset(a5),d0			; get current position buffer index
		sub.b	d1,d0
		move.w	(a6,d0.w),d0							; get Sonic's position a certain number of frames ago
		andi.w	#$7FFF,d0
		bra.s	loc_1C0D6							; use that value for scrolling
; ---------------------------------------------------------------------------

loc_1C0D2:
		move.w	x_pos(a0),d0

loc_1C0D6:
		sub.w	(a1),d0

	if ExtendedCamera
		sub.w	(Camera_X_center).w,d0
		blt.s	loc_1C0E8
		bge.s	loc_1C0FC
	else
		subi.w	#(320/2)-16,d0							; is the player less than 144 pixels from the screen edge?
		blt.s	loc_1C0E8							; if he is, scroll left
		subi.w	#16,d0								; is the player more than 159 pixels from the screen edge?
		bge.s	loc_1C0FC							; if he is, scroll right
	endif

		clr.w	(a4)								; otherwise, don't scroll

locret_1C0E6:
		rts
; ---------------------------------------------------------------------------

loc_1C0E8:
		cmpi.w	#-24,d0
		bgt.s	.skip
		moveq	#-24,d0								; limit scrolling to 24 pixels per frame

.skip
		add.w	(a1),d0								; get new camera position
		cmp.w	(a2),d0								; is it greater than the minimum position?
		bgt.s	loc_1C112							; if it is, branch
		move.w	(a2),d0								; prevent camera from going any further back
		bra.s	loc_1C112
; ---------------------------------------------------------------------------

loc_1C0FC:
		cmpi.w	#24,d0
		blo.s	.skip2
		moveq	#24,d0

.skip2
		add.w	(a1),d0								; get new camera position
		cmp.w	Camera_max_X_pos-Camera_min_X_pos(a2),d0			; is it less than the max position?
		blt.s	loc_1C112							; if it is, branch
		move.w	Camera_max_X_pos-Camera_min_X_pos(a2),d0			; prevent camera from going any further forward

loc_1C112:
		move.w	d0,d1
		sub.w	(a1),d1								; subtract old camera position
		asl.w	#8,d1								; shift up by a byte
		move.w	d0,(a1)								; set new camera position
		move.w	d1,(a4)								; set difference between old and new positions
		rts

	if ExtendedCamera

; ---------------------------------------------------------------------------
; Subroutine of the Extended camera
; From Sonic CD R11A Disassembly
; Check out the github:
; https://github.com/DevsArchive/sonic-cd-r11a-disassembly
; ---------------------------------------------------------------------------

Camera_Extended:
		move.w	Camera_X_center-Camera_X_pos(a1),d1				; get camera X center position
		move.w	ground_vel(a0),d0						; get how fast we are moving
		bpl.s	.PosInertia
		neg.w	d0

.PosInertia:
		cmpi.w	#$600,d0							; are we going at max regular speed?
		blo.s	.ResetPan							; if not, branch
		tst.w	ground_vel(a0)							; are we moving right?
		bpl.s	.MovingRight							; if so, branch

.MovingLeft:
		addq.w	#2,d1								; pan the camera to the right
		cmpi.w	#(320/2)+64,d1							; has it panned far enough?
		blo.s	.SetPanVal							; if not, branch
		move.w	#(320/2)+64,d1							; cap the camera's position
		bra.s	.SetPanVal

.MovingRight:
		subq.w	#2,d1								; pan the camera to the left
		cmpi.w	#(320/2)-64,d1							; has it panned far enough
		bhs.s	.SetPanVal							; if not, branch
		move.w	#(320/2)-64,d1							; cap the camera's position
		bra.s	.SetPanVal

.ResetPan:
		cmpi.w	#320/2,d1							; has the camera panned back to the middle?
		beq.s	.SetPanVal							; if so, branch
		bhs.s	.ResetLeft							; if it's panning back left
		addq.w	#2,d1								; pan back to the right
		bra.s	.SetPanVal

.ResetLeft:
		subq.w	#2,d1								; pan back to the left

.SetPanVal:
		move.w	d1,Camera_X_center-Camera_X_pos(a1)				; update camera X center position
		rts

	endif

; ---------------------------------------------------------------------------
; Subroutine to scroll the level vertically as Sonic moves
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

MoveCameraY:
		move.w	y_pos(a0),d0
		sub.w	(a1),d0								; subtract camera Y pos
		cmpi.w	#-$100,(Camera_min_Y_pos).w					; does the level wrap vertically?
		bne.s	.notwrap							; if not, branch
		and.w	(Screen_Y_wrap_value).w,d0

.notwrap
		btst	#status.player.rolling,status(a0)				; is the player rolling?
		beq.s	.notroll							; if not, branch

		; fix player ypos
		move.b	y_radius(a0),d1
		sub.b	default_y_radius(a0),d1
		ext.w	d1
		tst.b	(Reverse_gravity_flag).w
		beq.s	.notgrav
		neg.w	d1

.notgrav
		add.w	d1,d0

.notroll
		btst	#status.player.in_air,status(a0)				; is the player in the air?
		beq.s	loc_1C164							; if not, branch

		; if Sonic's in the air, he has $20 pixels above and below him to move
		; without disturbing the camera the camera movement is also only capped at $18 pixels
		addi.w	#32,d0
		sub.w	d3,d0
		blo.s	loc_1C1B0							; if Sonic is above the boundary, scroll to catch up to him
		subi.w	#64,d0
		bhs.s	loc_1C1B0							; if Sonic is below the boundary, scroll to catch up to him
		tst.b	(Camera_max_Y_pos_changing).w					; is the max Y pos changing?
		bne.s	loc_1C1C2							; if it is, branch
		bra.s	loc_1C16E
; ---------------------------------------------------------------------------

loc_1C164:

		; on the ground, the camera follows Sonic very strictly
		sub.w	d3,d0								; subtract camera bias
		bne.s	loc_1C172							; if Sonic has moved, scroll to catch up to him
		tst.b	(Camera_max_Y_pos_changing).w					; is the max Y pos changing?
		bne.s	loc_1C1C2							; if it is, branch

loc_1C16E:
		clr.w	(a4)								; clear Y position difference (V_scroll_amount)
		rts
; ---------------------------------------------------------------------------

loc_1C172:
		cmpi.w	#(224/2)-16,d3							; is the camera bias normal?
		bne.s	loc_1C19E							; if not, branch
		tst.b	(Fast_V_scroll_flag).w
		bne.s	loc_1C1B0
		mvabs.w	ground_vel(a0),d1						; get player ground velocity, force it to be positive
		cmpi.w	#$800,d1							; is the player travelling very fast?
		bhs.s	loc_1C1B0							; if he is, branch
		move.w	#bytes_to_word(6,0),d1						; if player is going too fast, cap camera movement to 6 pixels per frame
		cmpi.w	#6,d0								; is player going down too fast?
		bgt.s	loc_1C1FA							; if so, move camera at capped speed
		cmpi.w	#-6,d0								; is player going up too fast?
		blt.s	loc_1C1D8							; if so, move camera at capped speed
		bra.s	loc_1C1C8							; otherwise, move camera at player's speed
; ---------------------------------------------------------------------------

loc_1C19E:
		move.w	#bytes_to_word(2,0),d1						; if player is going too fast, cap camera movement to 2 pixels per frame
		cmpi.w	#2,d0								; is player going down too fast?
		bgt.s	loc_1C1FA							; if so, move camera at capped speed
		cmpi.w	#-2,d0								; is player going up too fast?
		blt.s	loc_1C1D8							; if so, move camera at capped speed
		bra.s	loc_1C1C8							; otherwise, move camera at player's speed
; ---------------------------------------------------------------------------

loc_1C1B0:
		move.w	#bytes_to_word(24,0),d1						; if player is going too fast, cap camera movement to $18 pixels per frame
		cmpi.w	#24,d0								; is player going down too fast?
		bgt.s	loc_1C1FA							; if so, move camera at capped speed
		cmpi.w	#-24,d0								; is player going up too fast?
		blt.s	loc_1C1D8							; if so, move camera at capped speed
		bra.s	loc_1C1C8							; otherwise, move camera at player's speed
; ---------------------------------------------------------------------------

loc_1C1C2:
		moveq	#0,d0								; distance for camera to move = 0
		move.b	d0,(Camera_max_Y_pos_changing).w				; clear camera max Y pos changing flag

loc_1C1C8:
		moveq	#0,d1
		move.w	d0,d1								; get position difference
		add.w	(a1),d1								; add old camera Y position
		tst.w	d0								; is the camera to scroll down?
		bpl.s	loc_1C202							; if it is, branch
		bra.s	loc_1C1E2
; ---------------------------------------------------------------------------

loc_1C1D8:
		neg.w	d1								; make the value negative (since we're going backwards)
		ext.l	d1
		asl.l	#8,d1								; move this into the upper word, so it lines up with the actual y_pos value in Camera_Y_pos
		add.l	(a1),d1								; add the two, getting the new Camera_Y_pos value
		swap	d1								; actual Y-coordinate is now the low word

loc_1C1E2:
		cmp.w	(a2),d1								; is the new position less than the minimum Y pos?
		bgt.s	loc_1C21A							; if not, branch
		cmpi.w	#-$100,d1
		bgt.s	loc_1C1F4
		and.w	(Screen_Y_wrap_value).w,d1
		bra.s	loc_1C21A
; ---------------------------------------------------------------------------

loc_1C1F4:
		move.w	(a2),d1								; prevent camera from going any further up
		bra.s	loc_1C21A
; ---------------------------------------------------------------------------

loc_1C1FA:
		ext.l	d1
		asl.l	#8,d1								; move this into the upper word, so it lines up with the actual y_pos value in Camera_Y_pos
		add.l	(a1),d1								; add the two, getting the new Camera_Y_pos value
		swap	d1								; actual Y-coordinate is now the low word

loc_1C202:
		cmp.w	Camera_max_Y_pos-Camera_min_Y_pos(a2),d1			; is the new position greater than the maximum Y pos?
		blt.s	loc_1C21A							; if not, branch
		move.w	(Screen_Y_wrap_value).w,d3
		addq.w	#1,d3
		sub.w	d3,d1
		blo.s	loc_1C216
		sub.w	d3,(a1)
		bra.s	loc_1C21A
; ---------------------------------------------------------------------------

loc_1C216:
		move.w	Camera_max_Y_pos-Camera_min_Y_pos(a2),d1			; prevent camera from going any further down

loc_1C21A:
		move.w	(a1),d4								; get camera Y pos
		swap	d1								; actual Y-coordinate is now the high word, as Camera_Y_pos expects it
		move.l	d1,d3
		sub.l	(a1),d3
		ror.l	#8,d3
		move.w	d3,(a4)								; set difference between old and new positions
		move.l	d1,(a1)								; set new camera Y pos
		rts
