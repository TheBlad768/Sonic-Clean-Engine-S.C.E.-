
; =============== S U B R O U T I N E =======================================

Handle_Onscreen_Water_Height:
		tst.b	(Water_flag).w
		beq.s	Handle_Onscreen_Water_Height_Return
		tst.b	(Deform_lock).w
		bne.s	+
		cmpi.b	#id_SonicDeath,(Player_1+routine).w
		bhs.s	+
		bsr.s	DynamicWaterHeight
+		clr.b	(Water_full_screen_flag).w
		moveq	#0,d0
		move.b	(Oscillating_Data).w,d0
		lsr.w	d0
		add.w	(Mean_water_level).w,d0
		move.w	d0,(Water_level).w
		move.w	(Water_level).w,d0
		sub.w	(Camera_Y_pos).w,d0
		beq.s	+
		bcc.s	++
		tst.w	d0
		bpl.s	++
+		move.b	#1,(Water_full_screen_flag).w
		move.b	#256-1,(H_int_counter).w
		rts
; ---------------------------------------------------------------------------
+		cmpi.w	#224-1,d0
		blo.s		+
		move.w	#256-1,d0
+		move.b	d0,(H_int_counter).w

Handle_Onscreen_Water_Height_Return:
		rts
; End of function Handle_Onscreen_Water_Height

; =============== S U B R O U T I N E =======================================

DynamicWaterHeight:
		movea.l	(Level_data_addr_RAM.WaterResize).w,a0
		jsr	(a0)
		moveq	#0,d1
		move.b	(Water_speed).w,d1
		move.w	(Target_water_level).w,d0
		sub.w	(Mean_water_level).w,d0
		beq.s	No_WaterResize
		bcc.s	+
		neg.w	d1
+		add.w	d1,(Mean_water_level).w

No_WaterResize:
		rts
; End of function DynamicWaterHeight

; =============== S U B R O U T I N E =======================================

CheckLevelForWater:
		move.w	#$1000,d0
		move.w	d0,(Water_level).w
		move.w	d0,(Mean_water_level).w
		move.w	d0,(Target_water_level).w
		clr.b	(Water_flag).w

CheckLevelForWater_Return:
		rts
; ---------------------------------------------------------------------------

StartLevelWater:
		move.b	#1,(Water_flag).w
		tst.b	(Water_flag).w
		beq.s	LoadWaterPalette
		moveq	#0,d0
		move.w	(Current_zone_and_act).w,d0
		ror.b	#2,d0
		lsr.w	#5,d0
		move.w	StartingWaterHeights(pc,d0.w),d0
		move.w	d0,(Water_level).w
		move.w	d0,(Mean_water_level).w
		move.w	d0,(Target_water_level).w
		clr.b	(Water_entered_counter).w
		clr.b	(Water_full_screen_flag).w
		move.b	#1,(Water_speed).w

LoadWaterPalette:
		tst.b	(Water_flag).w
		beq.s	CheckLevelForWater_Return
		moveq	#0,d0
		move.w	(Current_zone_and_act).w,d0
		ror.b	#2,d0
		lsr.w	#6,d0
		move.b	WaterPalette_Index(pc,d0.w),d0	; Water palette
		move.w	d0,d1
		bsr.w	LoadPalette2
		move.w	d1,d0
		bra.w	LoadPalette2_Immediate
; End of function CheckLevelForWater
; ---------------------------------------------------------------------------

StartingWaterHeights:
		dc.w $400	; DEZ 1
		dc.w $400	; DEZ 2
		dc.w $400	; DEZ 3
		dc.w $400	; DEZ 4

		zonewarning StartingWaterHeights,(2*4)
; ---------------------------------------------------------------------------

WaterPalette_Index:
		dc.b palid_WaterDEZ, palid_WaterDEZ, palid_WaterDEZ, palid_WaterDEZ		; DEZ 1,2,3,4

		zonewarning WaterPalette_Index,(1*4)
