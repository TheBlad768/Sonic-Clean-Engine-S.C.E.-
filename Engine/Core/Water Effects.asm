; ---------------------------------------------------------------------------
; Water handle
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Handle_Onscreen_Water_Height:
		tst.b	(Water_flag).w								; does level have water?
		beq.s	.return									; if not, branch
		tst.b	(Deform_lock).w
		bne.s	.skip
		cmpi.b	#PlayerID_Death,(Player_1+routine).w					; is player dead?
		bhs.s	.skip									; if yes, branch
		bsr.s	DynamicWaterHeight

.skip
		moveq	#0,d0
		move.b	d0,(Water_full_screen_flag).w
		move.b	(Oscillating_Data).w,d0
		lsr.w	d0
		add.w	(Mean_water_level).w,d0
		move.w	d0,(Water_level).w

		; calculate distance between water surface and top of screen
		move.w	(Water_level).w,d0
		sub.w	(Camera_Y_pos).w,d0
		beq.s	.set
		bhs.s	.check
		bpl.s	.check

.set
		st	(Water_full_screen_flag).w
		st	(H_int_counter).w							; set 256-1
		rts
; ---------------------------------------------------------------------------

.check
		cmpi.w	#224-1,d0
		blo.s	.counter
		moveq	#-1,d0									; set 256-1

.counter
		move.b	d0,(H_int_counter).w

.return
		rts

; =============== S U B R O U T I N E =======================================

DynamicWaterHeight:

		; check
		move.l	(Level_data_addr_RAM.WaterResize).w,d0
		beq.s	.wrskip
		movea.l	d0,a0
		jsr	(a0)

.wrskip
		moveq	#0,d1
		move.b	(Water_speed).w,d1
		move.w	(Target_water_level).w,d0
		sub.w	(Mean_water_level).w,d0
		beq.s	.return
		bhs.s	.skip
		neg.w	d1

.skip
		add.w	d1,(Mean_water_level).w

.return
		rts

; =============== S U B R O U T I N E =======================================

CheckLevelForWater:

		; reset water
		move.w	#$1000,d0
		move.w	d0,(Water_level).w
		move.w	d0,(Mean_water_level).w
		move.w	d0,(Target_water_level).w
		clr.b	(Water_flag).w								; disable water
		rts
; ---------------------------------------------------------------------------

.getwater

		; set water
		move.w	(Level_data_addr_RAM.WaterHeight).w,d0					; load water height
		move.w	d0,(Water_level).w
		move.w	d0,(Mean_water_level).w
		move.w	d0,(Target_water_level).w
		st	(Water_flag).w								; enable water
		clr.b	(Water_entered_counter).w
		clr.b	(Water_full_screen_flag).w
		move.b	#1,(Water_speed).w

		; load player water palette
		lea	(Level_data_addr_RAM.WaterSpal).w,a1					; load Sonic palette
		moveq	#0,d0
		move.b	(a1),d0									; player water palette
		move.w	d0,d1
		jsr	(LoadPalette2).w
		move.w	d1,d0
		jsr	(LoadPalette2_Immediate).w

LoadWaterPalette:
		tst.b	(Water_flag).w
		beq.s	.return

		; load level water palette
		lea	(Level_data_addr_RAM.WaterPalette).w,a1					; water palette
		moveq	#0,d0
		move.b	(a1),d0
		move.w	d0,d1
		jsr	(LoadPalette2).w							; load water palette
		move.w	d1,d0
		jsr	(LoadPalette2_Immediate).w

		; restore water full flag
		tst.b	(Last_star_post_hit).w
		beq.s	.return
		move.b	(Saved_water_full_screen_flag).w,(Water_full_screen_flag).w

.return
		rts
