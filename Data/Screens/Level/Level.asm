; ---------------------------------------------------------------------------
; Level
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

GM_Level:
		bset	#GameModeFlag_TitleCard,(Game_mode).w		; Set bit 7 is indicate that we're loading the level
		sfx	bgm_Fade,0,1,1								; fade out music
		jsr	(Clear_Kos_Module_Queue).w					; Clear KosM PLCs
		jsr	(Pal_FadeToBlack).w
		disableInts
		jsr	(Clear_DisplayData).w
		enableInts
		tst.b	(Last_star_post_hit).w
		beq.s	+										; If no lampost was set, branch
		move.w	(Saved_zone_and_act).w,(Current_zone_and_act).w
+		clearRAM Object_RAM, Object_RAM_End
		clearRAM Lag_frame_count, Lag_frame_count_End
		clearRAM Camera_RAM, Camera_RAM_End
		clearRAM Oscillating_variables, Oscillating_variables_End
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
		btst	#bitA,(Ctrl_1_held).w							; is A button held?
		beq.s	+										; if not, branch
		move.b	#1,(Debug_mode_flag).w 					; enable debug mode
+
	endif
		move.w	#$8A00+255,(H_int_counter_command).w	; set palette change position (for water)
		move.w	(H_int_counter_command).w,(a6)
		ResetDMAQueue
		moveq	#palid_Sonic,d0
		move.w	d0,d1
		jsr	(LoadPalette).w								; load Sonic's palette
		move.w	d1,d0
		jsr	(LoadPalette_Immediate).w
		lea	(PLC_Main).l,a5
		jsr	(LoadPLC_Raw_KosM).w						; load hud and ring art
		jsr	(CheckLevelForWater).w
		clearRAM Water_palette_line_2, Normal_palette
		tst.b	(Water_flag).w
		beq.s	+
		move.w	#$8014,VDP_control_port-VDP_control_port(a6)	; H-int enabled
		moveq	#palid_WaterSonic,d0
		move.w	d0,d1
		jsr	(LoadPalette2).w								; load Sonic's water palette
		move.w	d1,d0
		jsr	(LoadPalette2_Immediate).w
+		move.w	(Current_zone_and_act).w,d0
		ror.b	#2,d0
		lsr.w	#6,d0
		lea	(LevelMusic_Playlist).l,a1						; load music playlist
		move.b	(a1,d0.w),d0
		move.w	d0,(Level_music).w
		move.b	d0,(Clone_Driver_RAM+SMPS_RAM.variables.queue.v_playsnd1).w	; play music
		move.l	#Obj_TitleCard,(Dynamic_object_RAM+(object_size*5)).w			; load title card object

-		move.b	#VintID_TitleCard,(V_int_routine).w
		jsr	(Process_Kos_Queue).w
		jsr	(Wait_VSync).w
		jsr	(Process_Sprites).w
		jsr	(Render_Sprites).w
		jsr	(Process_Kos_Module_Queue).w
		tst.w	(Dynamic_object_RAM+(object_size*5)+objoff_48).w		; has title card sequence finished?
		bne.s	-													; if not, branch
		tst.w	(Kos_modules_left).w									; are there any items in the pattern load cue?
		bne.s	-													; if yes, branch
		disableInts
		jsr	(HUD_DrawInitial).w
		enableInts
		jsr	(LoadLevelPointer).w
		jsr	(Get_LevelSizeStart).w
		jsr	(DeformBgLayer).w
		jsr	(LoadLevelLoadBlock).w
		jsr	(LoadLevelLoadBlock2).w
		disableInts
		jsr	(LevelSetup).w
		enableInts
		jsr	(Load_Solids).w
		jsr	(Handle_Onscreen_Water_Height).w
		moveq	#0,d0
		move.w	d0,(Ctrl_1_logical).w
		move.w	d0,(Ctrl_1).w
		move.b	d0,(HUD_RAM.status).w
		tst.b	(Last_star_post_hit).w							; are you starting from a lamppost?
		bne.s	+										; if yes, branch
		move.w	d0,(Ring_count).w						; clear rings
		move.l	d0,(Timer).w								; clear time	
		move.b	d0,(Saved_status_secondary).w
+		move.b	d0,(Time_over_flag).w
		jsr	(OscillateNumInit).w
		moveq	#1,d0
		move.b	d0,(Ctrl_1_locked).w
		move.b	d0,(Update_HUD_score).w					; update score counter
		move.b	d0,(Update_HUD_ring_count).w			; update rings counter
		move.b	d0,(Update_HUD_timer).w					; update time counter
		move.b	d0,(Level_started_flag).w
		tst.b	(Water_flag).w
		beq.s	+
		move.l	#Obj_WaterWave,(v_WaterWave).w
+		bsr.w	SpawnLevelMainSprites
		jsr	(Load_Sprites).w
		jsr	(Load_Rings).w
		jsr	(Process_Sprites).w
		jsr	(Render_Sprites).w
		jsr	(Animate_Tiles).w
		jsr	(LoadWaterPalette).w
		clearRAM Water_palette_line_2, Normal_palette
		move.w	#$202F,(Palette_fade_info).w
		jsr	(Pal_FillBlack).w
		move.w	#$16,(Palette_fade_timer).w
		move.w	#$7F00,(Ctrl_1).w
		andi.b	#$7F,(Last_star_post_hit).w
		bclr	#GameModeFlag_TitleCard,(Game_mode).w		; subtract $80 from mode to end pre-level stuff

Level_Loop:
		jsr	(Pause_Game).w
		move.b	#VintID_Level,(V_int_routine).w
		jsr	(Process_Kos_Queue).w
		jsr	(Wait_VSync).w
		addq.w	#1,(Level_frame_counter).w
		jsr	(Animate_Palette).w
		jsr	(Load_Sprites).w
		jsr	(Process_Sprites).w
		tst.b	(Restart_level_flag).w
		bne.w	GM_Level
		jsr	(DeformBgLayer).w
		jsr	(ScreenEvents).w
		jsr	(Handle_Onscreen_Water_Height).w
		jsr	(Load_Rings).w
		jsr	(Animate_Tiles).w
		jsr	(Process_Kos_Module_Queue).w
		jsr	(OscillateNumDo).w
		jsr	(SynchroAnimate).w
		jsr	(Render_Sprites).w
		cmpi.b	#id_LevelScreen,(Game_mode).w
		beq.s	Level_Loop
		rts

; =============== S U B R O U T I N E =======================================

SpawnLevelMainSprites:
		move.l	#Obj_Collision_Response_List,(Reserved_object_3).w
		move.l	#Obj_Sonic,(Player_1).w
		move.l	#Obj_DashDust,(v_Dust).w
		move.l	#Obj_Insta_Shield,(v_Shield).w
		rts
; End of function SpawnLevelMainSprites

; =============== S U B R O U T I N E =======================================

Obj_Collision_Response_List:
		clr.w	(Collision_response_list).w
		rts
; End of function Obj_Collision_Response_List
