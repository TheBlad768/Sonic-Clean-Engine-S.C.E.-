; ---------------------------------------------------------------------------
; When debug mode is currently in use
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

DebugMode:
		tst.b	(Debug_placement_routine).w
		bne.w	.action
		addq.b	#2,(Debug_placement_routine).w
		move.l	mappings(a0),(Saved_mappings).w
		cmpi.b	#id_SonicDeath,routine(a0)
		bhs.s	.death
		move.w	art_tile(a0),(Saved_art_tile).w

.death
		move.w	(Screen_Y_wrap_value).w,d0
		and.w	d0,(Player_1+y_pos).w
		and.w	d0,(Camera_Y_pos).w
		clr.b	(Scroll_lock).w
		clr.b	(WindTunnel_flag).w
		bclr	#Status_Underwater,status(a0)
		beq.s	.select
		movea.w	a0,a1
		jsr	Player_ResetAirTimer(pc)
		move.w	#$600,(Sonic_Knux_top_speed).w
		move.w	#$C,(Sonic_Knux_acceleration).w
		move.w	#$80,(Sonic_Knux_deceleration).w

.select
		moveq	#0,d0
		move.b	d0,mapping_frame(a0)
		move.b	d0,anim(a0)
		move.w	(Current_zone_and_act).w,d0
		ror.b	#2,d0
		lsr.w	#5,d0
		lea	DebugList(pc),a2
		adda.w	(a2,d0.w),a2
		move.w	(a2)+,d6
		cmp.b	(Debug_object).w,d6		; have you gone past the last item?
		bhi.s	.notreset					; if not, branch
		clr.b	(Debug_object).w				; back to start of list

.notreset
		bsr.w	.showitem
		move.b	#12,(Debug_camera_delay).w
		move.b	#1,(Debug_camera_speed).w

.action
		moveq	#0,d0
		move.w	(Current_zone_and_act).w,d0
		ror.b	#2,d0
		lsr.w	#5,d0
		lea	DebugList(pc),a2
		adda.w	(a2,d0.w),a2
		move.w	(a2)+,d6
		bsr.s	.control
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.control
		move.b	(Ctrl_1_pressed).w,d4
		andi.w	#btnDir,d4				; is up/down/left/right	pressed?
		bne.s	.dirpressed				; if yes, branch
		move.b	(Ctrl_1_held).w,d0
		andi.w	#btnDir,d0				; is up/down/left/right	held?
		bne.s	.dirheld					; if yes, branch
		move.b	#12,(Debug_camera_delay).w
		move.b	#15,(Debug_camera_speed).w
		bra.w	.chgitem
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
		btst	#button_up,d4				; is up being held?
		beq.s	.notup					; if not, branch
		sub.l	d1,d2
		moveq	#0,d0
		move.w	(Camera_min_Y_pos).w,d0
		swap	d0
		cmp.l	d0,d2
		bge.s	.notup
		move.l	d0,d2

.notup
		btst	#button_down,d4				; is down being held?
		beq.s	.notdown					; if not, branch
		add.l	d1,d2
		moveq	#0,d0
		move.w	(Camera_target_max_Y_pos).w,d0
		addi.w	#223,d0
		swap	d0
		cmp.l	d0,d2
		blt.s		.notdown	
		move.l	d0,d2

.notdown	
		btst	#button_left,d4				; is left being held?
		beq.s	.notleft					; if not, branch
		sub.l	d1,d3
		bcc.s	.notleft
		moveq	#0,d3

.notleft
		btst	#button_right,d4				; is right being held?
		beq.s	.notright					; if not, branch
		add.l	d1,d3

.notright
		move.l	d2,y_pos(a0)
		move.l	d3,x_pos(a0)

.chgitem
		btst	#button_A,(Ctrl_1_held).w 		; is button A held?
		beq.s	.createitem				; if not, branch
		btst	#button_C,(Ctrl_1_pressed).w	; is button C pressed?
		beq.s	.nextitem				; if not, branch
		subq.b	#1,(Debug_object).w		; go back 1 item
		bcc.s	.display
		add.b	d6,(Debug_object).w
		bra.s	.display
; ---------------------------------------------------------------------------

.nextitem
		btst	#button_A,(Ctrl_1_pressed).w	; is button A pressed?
		beq.s	.createitem				; if not, branch
		addq.b	#1,(Debug_object).w		; go forwards 1 item
		cmp.b	(Debug_object).w,d6
		bhi.s	.display
		clr.b	(Debug_object).w				; loop back to first item

.display
		bra.w	.showitem
; ---------------------------------------------------------------------------

.createitem
		btst	#button_C,(Ctrl_1_pressed).w	; is button C pressed?
		beq.s	.backtonormal			; if not, branch
		jsr	(Create_New_Sprite).w
		bne.s	.backtonormal
		move.w	x_pos(a0),x_pos(a1)
		move.w	y_pos(a0),y_pos(a1)
		move.b	render_flags(a0),d0
		andi.b	#$7F,d0
		move.b	d0,render_flags(a1)
		move.b	d0,status(a1)
		moveq	#0,d0
		move.b	(Debug_object).w,d0
		add.w	d0,d0
		move.w	d0,d1
		lsl.w	#2,d0
		add.w	d1,d0
		move.b	4(a2,d0.w),subtype(a1)
		move.l	(a2,d0.w),address(a1)
		clr.b	address(a1)

.stayindebug
		rts
; ---------------------------------------------------------------------------

.backtonormal
		btst	#button_B,(Ctrl_1_pressed).w			; is button B pressed?
		beq.s	.stayindebug						; if not, branch
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

.showitem
		moveq	#0,d0
		move.b	(Debug_object).w,d0
		add.w	d0,d0
		move.w	d0,d1
		lsl.w	#2,d0
		add.w	d1,d0
		move.l	4(a2,d0.w),mappings(a0)		; load mappings for item
		move.w	8(a2,d0.w),art_tile(a0)			; load VRAM setting for item
		move.b	(a2,d0.w),mapping_frame(a0)	; load frame number for item
		rts
; ---------------------------------------------------------------------------

		include "Misc Data/DebugList.asm"
