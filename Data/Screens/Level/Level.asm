; ---------------------------------------------------------------------------
; Level
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

GM_Level:
		bset	#GameModeFlag_TitleCard,(Game_mode).w		; Set bit 7 is indicate that we're loading the level
		sfx	bgm_Fade,0,1,1								; fade out music
		bsr.w	Clear_Kos_Module_Queue					; Clear KosM PLCs
		bsr.w	Clear_Nem_Queue						; Clear Nem PLCs
		bsr.w	Pal_FadeToBlack
		disableInts
		bsr.w	Clear_DisplayData
		enableInts
		tst.b	(Last_star_post_hit).w
		beq.s	+										; If no lampost was set, branch
		move.w	(Saved_zone_and_act).w,(Current_zone_and_act).w
+		clearRAM Sprite_table_input, Sprite_table_input_End
		clearRAM Object_RAM, Object_RAM_End
		clearRAM Lag_frame_count, Lag_frame_count_End
		clearRAM Camera_RAM, Camera_RAM_End
		clearRAM Oscillating_variables, Oscillating_variables_End
		bsr.w	Init_SpriteTable
		lea	(VDP_control_port).l,a6
		move.w	#$8004,(a6)								; 8-colour mode
		move.w	#$8200+(vram_fg>>10),(a6)				; set foreground nametable address
		move.w	#$8300+(vram_bg>>10),(a6)				; set window nametable address
		move.w	#$8400+(vram_bg>>13),(a6)				; set background nametable address
		move.w	#$8700+(2<<4),(a6)						; set background colour (line 3; colour 0)
		move.w	#$8B03,(a6)								; line scroll mode
		move.w	#$8C81,(a6)								; set 40cell screen size, no interlacing, no s/h
		move.w	#$9001,(a6)								; 64-cell hscroll size
		move.w	#$9200,(a6)								; set window V position at default
	if GameDebug=1
		btst	#bitA,(Ctrl_1).w								; is A button held?
		beq.s	+										; if not, branch
		move.b	#1,(Debug_mode_flag).w 					; enable debug mode
+
	endif
		move.w	#$8A00+255,(H_int_counter_command).w	; set palette change position (for water)
		move.w	(H_int_counter_command).w,(a6)
		ResetDMAQueue
		moveq	#palid_Sonic,d0
		move.w	d0,d1
		bsr.w	LoadPalette								; load Sonic's palette
		move.w	d1,d0
		bsr.w	LoadPalette_Immediate
		lea	(PLC_Main).l,a1
		bsr.w	LoadPLC_Raw_Nem						; load hud and ring art
		bsr.w	CheckLevelForWater
		clearRAM Water_palette_line_2, Normal_palette
		tst.b	(Water_flag).w
		beq.s	+
		move.w	#$8014,(a6)								; H-int enabled
		moveq	#palid_WaterSonic,d0
		move.w	d0,d1
		bsr.w	LoadPalette2								; load Sonic's water palette
		move.w	d1,d0
		bsr.w	LoadPalette2_Immediate
+		move.w	(Current_zone_and_act).w,d0
		lsl.b	#6,d0
		lsr.w	#6,d0
		lea	LevelMusic_Playlist(pc),a1						; load music playlist
		move.b	(a1,d0.w),d0
		move.w	d0,(Level_music).w
		bsr.w	PlaySound								; play music
		move.l	#Obj_TitleCard,(Object_RAM+$250).w		; load title card object

-		move.b	#VintID_TitleCard,(V_int_routine).w
		bsr.w	Process_Kos_Queue
		bsr.w	Wait_VSync
		bsr.w	Process_Sprites
		bsr.w	Render_Sprites
		bsr.w	Process_Nem_Queue_Init
		bsr.w	Process_Kos_Module_Queue
		tst.w	(Object_RAM+$298).w					; has title card sequence finished?
		bne.s	-										; if not, branch
		tst.l	(Nem_decomp_queue).w						; are there any items in the pattern load cue?
		bne.s	-										; if yes, branch
		disableInts
		bsr.w	HUD_DrawInitial
		enableInts
		bsr.w	Get_LevelSizeStart
		bsr.w	DeformBgLayer
		bsr.w	LoadLevelLoadBlock
		bsr.w	LoadLevelLoadBlock2
		disableInts
		bsr.w	LevelSetup
		enableInts
		bsr.w	Load_Solids
		bsr.w	Handle_Onscreen_Water_Height
		moveq	#0,d0
		move.w	d0,(Ctrl_1_logical).w
		move.w	d0,(Ctrl_1).w
		tst.b	(Last_star_post_hit).w							; are you starting from a lamppost?
		bne.s	+										; if yes, branch
		move.w	d0,(Ring_count).w						; set rings
		move.l	d0,(Timer).w								; clear time
		move.b	d0,(Saved_status_secondary).w
+		move.b	d0,(Time_over_flag).w
		bsr.w	OscillateNumInit
		move.b	#1,(Ctrl_1_locked).w
		move.b	#1,(Update_HUD_score).w					; update score counter
		move.b	#1,(Update_HUD_ring_count).w			; update rings counter
		move.b	#1,(Update_HUD_timer).w					; update time counter
		move.b	#1,(Level_started_flag).w
		tst.b	(Water_flag).w
		beq.s	+
		move.l	#Obj_WaterWave,(v_WaterWave).w
+		bsr.w	SpawnLevelMainSprites
		bsr.w	Load_Sprites
		bsr.w	Load_Rings
		bsr.w	Process_Sprites
		bsr.w	Render_Sprites
		bsr.w	Animate_Tiles
		move.w	#$708,(Demo_timer).w
		bsr.w	LoadWaterPalette
		clearRAM Water_palette_line_2, Normal_palette
		move.w	#$202F,(Palette_fade_info).w
		bsr.w	Pal_FillBlack
		move.w	#$16,(Palette_fade_timer).w
		move.w	#$7F00,(Ctrl_1).w
		andi.b	#$7F,(Last_star_post_hit).w
		bclr	#GameModeFlag_TitleCard,(Game_mode).w		; subtract $80 from mode to end pre-level stuff

-		bsr.w	Pause_Game
		move.b	#VintID_Level,(V_int_routine).w
		bsr.w	Process_Kos_Queue
		bsr.w	Wait_VSync
		addq.w	#1,(Level_frame_counter).w
		bsr.w	Animate_Palette
		bsr.w	Load_Sprites
		bsr.w	Process_Sprites
		tst.b	(Restart_level_flag).w
		bne.w	GM_Level
		bsr.w	DeformBgLayer
		bsr.w	ScreenEvents
		bsr.w	Handle_Onscreen_Water_Height
		bsr.w	Load_Rings
		bsr.w	Animate_Tiles
		bsr.w	Process_Nem_Queue_Init
		bsr.w	Process_Kos_Module_Queue
		bsr.w	OscillateNumDo
		bsr.w	SynchroAnimate
		bsr.w	Render_Sprites
		cmpi.b	#id_Level,(Game_mode).w
		beq.s	-
		rts

; =============== S U B R O U T I N E =======================================

SpawnLevelMainSprites:
		move.l	#Obj_Collision_Response_List,(Reserved_object_3).w
		move.l	#Obj_Sonic,(Player_1).w
		move.l	#Obj_DashDust,(v_Dust).w
		move.l	#Obj_Insta_Shield,(v_Shield).w
		move.w	#Player_1,(v_Shield+parent).w
		rts
; End of function SpawnLevelMainSprites

; =============== S U B R O U T I N E =======================================

Obj_Collision_Response_List:
		move.w	#0,(Collision_response_list).w
		rts
; End of function Obj_Collision_Response_List
