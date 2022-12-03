; ---------------------------------------------------------------------------
; When debug mode is currently in use
; Sonic Crackers style
; ---------------------------------------------------------------------------

DebugMode_Speed:		= $80

; =============== S U B R O U T I N E =======================================

DebugMode:
		tst.b	(Debug_placement_routine).w
		bne.s	.control
		addq.b	#2,(Debug_placement_routine).w
		move.l	mappings(a0),(Saved_mappings).w
		cmpi.b	#id_SonicDeath,routine(a0)
		bhs.s	.death
		move.w	art_tile(a0),(Saved_art_tile).w

.death
		bset	#7,art_tile(a0)
		move.b	#DebugMode_Speed,(Debug_camera_speed).w
		move.w	(Screen_Y_wrap_value).w,d0
		and.w	d0,(Player_1+y_pos).w
		and.w	d0,(Camera_Y_pos).w
		clr.b	(Scroll_lock).w
		clr.b	(WindTunnel_flag).w
		bclr	#Status_Underwater,status(a0)
		beq.s	.control
		movea.w	a0,a1
		jsr	Player_ResetAirTimer(pc)
		move.w	#$600,(Sonic_Knux_top_speed).w
		move.w	#$C,(Sonic_Knux_acceleration).w
		move.w	#$80,(Sonic_Knux_deceleration).w

.control
		pea	(Draw_Sprite).w
		btst	#button_B,(Ctrl_1_pressed).w			; is button B pressed?
		beq.s	.movement						; if not, branch
		clr.w	(Debug_placement_mode).w		; deactivate debug mode
		disableInts
		jsr	(HUD_DrawInitial).w
		move.b	#1,(Update_HUD_score).w
		move.b	#$80,(Update_HUD_ring_count).w
		enableInts
		lea	(Player_1).w,a1
		move.l	(Saved_mappings).w,mappings(a1)
		move.w	(Saved_art_tile).w,art_tile(a1)
		moveq	#0,d0
		move.b	d0,anim(a1)
		move.w	d0,x_sub(a1)
		move.w	d0,y_sub(a1)
		move.b	d0,object_control(a1)
		move.b	d0,spin_dash_flag(a1)
		move.l	d0,x_vel(a1)
		move.w	d0,ground_vel(a1)
		andi.b	#1,status(a1)
		ori.b	#2,status(a1)
		move.b	#id_SonicControl,routine(a1)
		move.w	#bytes_to_word(38/2,18/2),y_radius(a1)	; set y_radius and x_radius
		rts
; ---------------------------------------------------------------------------

.movement
		moveq	#0,d1
		move.b	(Ctrl_1_held).w,d4
		move.b	(Debug_camera_speed).w,d1
		addq.w	#1,d1
		swap	d1
		asr.l	#4,d1
		move.l	y_pos(a0),d2
		move.l	x_pos(a0),d3
		btst	#button_up,d4				; is up being held?
		beq.s	loc_1D03C				; if not, branch
		sub.l	d1,d2
		moveq	#0,d0
		move.w	(Camera_min_Y_pos).w,d0
		swap	d0
		cmp.l	d0,d2
		bge.s	loc_1D03C
		move.l	d0,d2

loc_1D03C:
		btst	#button_down,d4				; is down being held?
		beq.s	loc_1D052				; if not, branch
		add.l	d1,d2
		moveq	#0,d0
		move.w	(Camera_target_max_Y_pos).w,d0
		addi.w	#223,d0
		swap	d0
		cmp.l	d0,d2
		blt.s		loc_1D052
		move.l	d0,d2

loc_1D052:
		btst	#button_left,d4				; is left being held?
		beq.s	loc_1D05E				; if not, branch
		sub.l	d1,d3
		bcc.s	loc_1D05E
		moveq	#0,d3

loc_1D05E:
		btst	#button_right,d4				; is right being held?
		beq.s	loc_1D066				; if not, branch
		add.l	d1,d3

loc_1D066:
		move.l	d2,y_pos(a0)
		move.l	d3,x_pos(a0)
		rts
