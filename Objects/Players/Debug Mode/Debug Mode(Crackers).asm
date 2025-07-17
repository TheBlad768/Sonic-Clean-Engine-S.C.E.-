; ---------------------------------------------------------------------------
; When debug mode is currently in use (Sonic Crackers style)
; ---------------------------------------------------------------------------

DebugMode_Speed:		= $80

; =============== S U B R O U T I N E =======================================

Debug_Mode:
		tst.b	(Debug_placement_routine).w
		bne.s	.control
		addq.b	#2,(Debug_placement_routine).w
		move.l	mappings(a0),(Debug_saved_mappings).w				; save mappings
		cmpi.b	#PlayerID_Death,routine(a0)					; is player dead?
		bhs.s	.death								; if yes, branch
		move.l	priority(a0),(Debug_saved_priority).w				; save priority and art_tile

.death
		bset	#high_priority_bit,art_tile(a0)
		move.b	#DebugMode_Speed,(Debug_camera_speed).w
		move.w	(Screen_Y_wrap_value).w,d0
		and.w	d0,y_pos(a0)
		and.w	d0,(Camera_Y_pos).w
		moveq	#0,d0
		move.w	d0,priority(a0)
		move.b	d0,(Scroll_lock).w
		move.b	d0,(Deform_lock).w
		move.b	d0,(WindTunnel_flag).w
		move.w	d0,(Breathing_bubbles+objoff_30).w				; clear drowning timer
		bclr	#status.player.in_air,status(a0)
		bclr	#status.player.pushing,status(a0)
		bclr	#status.player.underwater,status(a0)
		beq.s	.control
		movea.w	a0,a1								; a1=character
		jsr	Player_ResetAirTimer(pc)

		; set player speed (a4 warning!)
		move.w	#$600,Max_speed-Max_speed(a4)					; set Max_speed
		move.w	#$C,Acceleration-Max_speed(a4)					; set Acceleration
		move.w	#$80,Deceleration-Max_speed(a4)					; set Deceleration

.control
		pea	(Draw_Sprite).w
		btst	#button_B,(Ctrl_1_pressed).w					; is button B pressed?
		beq.s	.movement							; if not, branch
		clr.w	(Debug_placement_mode).w					; deactivate debug mode
		disableInts
		jsr	(HUD_DrawInitial).w
		move.b	#1,(Update_HUD_score).w
		move.b	#$80,(Update_HUD_ring_count).w
		enableInts
		move.l	(Debug_saved_mappings).w,mappings(a0)				; restore mappings
		move.l	(Debug_saved_priority).w,priority(a0)				; restore priority and art_tile

		; reset
		moveq	#0,d0
		move.b	d0,anim(a0)
		move.w	d0,x_sub(a0)
		move.w	d0,y_sub(a0)
		move.w	d0,object_control(a0)						; clear object control and double jump flag
		move.b	d0,spin_dash_flag(a0)
		move.l	d0,x_vel(a0)
		move.w	d0,ground_vel(a0)
		move.b	d0,double_jump_flag(a0)
		move.b	d0,jumping(a0)
		andi.b	#setBit(status.player.underwater),status(a0)
		ori.b	#setBit(status.player.in_air),status(a0)
		move.b	#PlayerID_Control,routine(a0)
		move.w	default_y_radius(a0),y_radius(a0)				; set y_radius and x_radius
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
		btst	#button_up,d4							; is up being held?
		beq.s	.notup								; if not, branch
		sub.l	d1,d2
		moveq	#0,d0
		move.w	(Camera_min_Y_pos).w,d0
		swap	d0
		cmp.l	d0,d2
		bge.s	.notup
		move.l	d0,d2

.notup
		btst	#button_down,d4							; is down being held?
		beq.s	.notdown							; if not, branch
		add.l	d1,d2
		moveq	#0,d0
		move.w	(Camera_target_max_Y_pos).w,d0
		addi.w	#223,d0
		swap	d0
		cmp.l	d0,d2
		blt.s	.notdown
		move.l	d0,d2

.notdown
		btst	#button_left,d4							; is left being held?
		beq.s	.notleft							; if not, branch
		sub.l	d1,d3
		bhs.s	.notleft
		moveq	#0,d3

.notleft
		btst	#button_right,d4						; is right being held?
		beq.s	.notright							; if not, branch
		add.l	d1,d3

.notright
		move.l	d2,y_pos(a0)
		move.l	d3,x_pos(a0)
		rts
