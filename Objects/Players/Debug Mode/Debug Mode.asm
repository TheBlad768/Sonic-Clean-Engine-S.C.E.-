; ---------------------------------------------------------------------------
; When debug mode is currently in use
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Debug_Mode:
		tst.b	(Debug_placement_routine).w
		bne.w	.action
		addq.b	#2,(Debug_placement_routine).w
		move.l	mappings(a0),(Debug_saved_mappings).w				; save mappings
		cmpi.b	#PlayerID_Death,routine(a0)					; is player dead?
		bhs.s	.death								; if yes, branch
		move.l	priority(a0),(Debug_saved_priority).w				; save priority and art_tile

.death
		move.w	(Screen_Y_wrap_value).w,d0
		and.w	d0,y_pos(a0)
		and.w	d0,(Camera_Y_pos).w
		bclr	#status.player.in_air,status(a0)
		bclr	#status.player.pushing,status(a0)
		bclr	#status.player.underwater,status(a0)
		beq.s	.select
		movea.w	a0,a1								; a1=character
		jsr	Player_ResetAirTimer(pc)

		; set player speed (a4 warning!)
		move.w	#$600,Max_speed-Max_speed(a4)					; set max speed
		move.w	#$C,Acceleration-Max_speed(a4)					; set acceleration
		move.w	#$80,Deceleration-Max_speed(a4)					; set deceleration

.select
		moveq	#0,d0
		move.w	d0,priority(a0)
		move.b	d0,anim(a0)
		move.b	d0,mapping_frame(a0)
		move.b	d0,spin_dash_flag(a0)
		move.b	d0,(Scroll_lock).w
		move.b	d0,(Deform_lock).w
		move.b	d0,(WindTunnel_flag).w
		move.w	d0,(Breathing_bubbles+objoff_30).w				; clear drowning timer
		movea.l	(Level_data_addr_RAM.Debug).w,a2
		move.w	(a2)+,d6
		cmp.b	(Debug_object).w,d6						; have you gone past the last item?
		bhi.s	.notreset							; if not, branch
		clr.b	(Debug_object).w						; back to start of list

.notreset
		bsr.w	.display
		move.b	#12,(Debug_camera_delay).w
		move.b	#1,(Debug_camera_speed).w

.action
		movea.l	(Level_data_addr_RAM.Debug).w,a2
		move.w	(a2)+,d6
		pea	(Draw_Sprite).w

		; control
		moveq	#btnDir,d4
		and.b	(Ctrl_1_pressed).w,d4						; is up/down/left/right	pressed?
		bne.s	.dirpressed							; if yes, branch
		moveq	#btnDir,d0
		and.b	(Ctrl_1_held).w,d0						; is up/down/left/right	held?
		bne.s	.dirheld							; if yes, branch
		move.b	#12,(Debug_camera_delay).w
		move.b	#15,(Debug_camera_speed).w
		bra.s	.chgitem
; ---------------------------------------------------------------------------

.dirheld
		subq.b	#1,(Debug_camera_delay).w
		bne.s	.movement
		addq.b	#1,(Debug_camera_delay).w
		addq.b	#1,(Debug_camera_speed).w
		bne.s	.dirpressed
		st	(Debug_camera_speed).w

.dirpressed
		move.b	(Ctrl_1_held).w,d4

.movement
		moveq	#0,d1
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

.chgitem
		btst	#button_A,(Ctrl_1_held).w					; is button A held?
		beq.s	.createitem							; if not, branch
		btst	#button_C,(Ctrl_1_pressed).w					; is button C pressed?
		beq.s	.nextitem							; if not, branch
		subq.b	#1,(Debug_object).w						; go back 1 item
		bhs.s	.display
		add.b	d6,(Debug_object).w
		bra.s	.display
; ---------------------------------------------------------------------------

.nextitem
		btst	#button_A,(Ctrl_1_pressed).w					; is button A pressed?
		beq.s	.createitem							; if not, branch
		addq.b	#1,(Debug_object).w						; go forwards 1 item
		cmp.b	(Debug_object).w,d6
		bhi.s	.display
		clr.b	(Debug_object).w						; loop back to first item

.display
		moveq	#0,d0
		move.b	(Debug_object).w,d0
		add.w	d0,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d0,d0
		add.w	d1,d0
		move.l	4(a2,d0.w),mappings(a0)						; load mappings for item
		move.w	8(a2,d0.w),art_tile(a0)						; load VRAM setting for item
		move.b	(a2,d0.w),mapping_frame(a0)					; load frame number for item
		rts
; ---------------------------------------------------------------------------

.createitem
		btst	#button_C,(Ctrl_1_pressed).w					; is button C pressed?
		beq.s	.backtonormal							; if not, branch
		jsr	(Create_New_Sprite).w
		bne.s	.backtonormal
		move.w	x_pos(a0),x_pos(a1)
		move.w	y_pos(a0),y_pos(a1)

		moveq	#signextendB( \
			~setBit(render_flags.on_screen)&$FF \
		),d0

		and.b	render_flags(a0),d0
		move.b	d0,render_flags(a1)
		move.b	d0,status(a1)
		moveq	#0,d0
		move.b	(Debug_object).w,d0
		add.w	d0,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d0,d0
		add.w	d1,d0
		move.b	4(a2,d0.w),subtype(a1)
		move.l	(a2,d0.w),address(a1)
		clr.b	address(a1)

.stayindebug
		rts
; ---------------------------------------------------------------------------

.backtonormal
		btst	#button_B,(Ctrl_1_pressed).w					; is button B pressed?
		beq.s	.stayindebug							; if not, branch
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
		move.l	d0,x_vel(a0)							; clear x_vel and y_vel
		move.w	d0,ground_vel(a0)
		move.b	d0,double_jump_flag(a0)
		move.b	d0,jumping(a0)
		andi.b	#setBit(status.player.underwater),status(a0)
		ori.b	#setBit(status.player.in_air),status(a0)
		move.b	#PlayerID_Control,routine(a0)
		move.w	default_y_radius(a0),y_radius(a0)				; set y_radius and x_radius
		rts
