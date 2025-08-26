; ---------------------------------------------------------------------------
; Level
; ---------------------------------------------------------------------------

Level_VDP:
		dc.w $8004										; disable HInt, HV counter, 8-colour mode
		dc.w $8200+(VRAM_Plane_A_Name_Table>>10)						; set foreground nametable address
		dc.w $8300+(VRAM_Plane_B_Name_Table>>10)						; set window nametable address
		dc.w $8400+(VRAM_Plane_B_Name_Table>>13)						; set background nametable address
		dc.w $8700+(2<<4)									; set background colour (line 3; colour 0)
		dc.w $8B03										; line scroll mode
		dc.w $8C81										; set 40cell screen size, no interlacing, no s/h
		dc.w $9001										; 64x32 cell nametable area
		dc.w $9100										; set window H position at default
		dc.w $9200										; set window V position at default
		dc.w 0											; end marker

; =============== S U B R O U T I N E =======================================

LevelScreen:
		bset	#GameModeFlag_TitleCard,(Game_mode).w						; set bit 7 is indicate that we're loading the level
		music	mus_FadeOut									; fade out music
		jsr	(Clear_KosPlus_Module_Queue).w							; clear KosPlusM PLCs
		ResetDMAQueue										; clear DMA queue
		jsr	(Pal_FadeToBlack).w
		disableInts
		move.l	#VInt,(V_int_addr).w
		move.l	#HInt,(H_int_addr).w
		jsr	(Clear_DisplayData).w
		jsr	(TitleCard_LoadLetter).l
		enableInts
		tst.b	(Last_star_post_hit).w
		beq.s	.notstarpost									; if no starpost was set, branch
		move.w	(Saved_zone_and_act).w,(Current_zone_and_act).w
		move.w	(Saved_apparent_zone_and_act).w,(Apparent_zone_and_act).w

.notstarpost
		clearRAM Object_RAM, Object_RAM_end							; clear the object RAM
		clearRAM Lag_frame_count, Lag_frame_count_end						; clear variables
		clearRAM Camera_RAM, Camera_RAM_end							; clear the camera RAM
		clearRAM Oscillating_variables, Oscillating_variables_end				; clear variables
		lea	Level_VDP(pc),a1
		jsr	(Load_VDP).w									; a6 now has a VDP control address do not overwrite this register
		jsr	(LoadLevelPointer).w								; load level data

	if GameDebug
		btst	#button_C,(Ctrl_1_held).w							; is C button held?
		beq.s	.cnotheld									; if not, branch
		move.w	#$8C89,VDP_control_port-VDP_control_port(a6)					; set shadow/highlight mode ; warning: don't overwrite a6

.cnotheld
		btst	#button_A,(Ctrl_1_held).w							; is A button held?
		beq.s	.anotheld									; if not, branch
		st	(Debug_mode_flag).w								; enable debug mode

.anotheld
	endif

		move.w	#$8A00+255,(H_int_counter_command).w						; set palette change position (for water)
		move.w	(H_int_counter_command).w,VDP_control_port-VDP_control_port(a6)			; warning: don't overwrite a6

		; load player palette
		lea	(Level_data_addr_RAM.Spal).w,a1							; load Sonic palette
		moveq	#0,d0
		move.b	(a1),d0										; player palette
		move.w	d0,d1
		jsr	(LoadPalette).w									; load player's palette
		move.w	d1,d0
		jsr	(LoadPalette_Immediate).w

		; load HUD art
		lea	(PLC1_Sonic).l,a5
		jsr	(LoadPLC_Raw_KosPlusM).w							; load hud and ring art
		jsr	(CheckLevelForWater).w
		clearRAM Water_palette_line_2, Normal_palette
		tst.b	(Water_flag).w
		beq.s	.notwater
		move.w	#$8014,VDP_control_port-VDP_control_port(a6)					; H-int enabled ; last use a6 here

.notwater

		; get level music id
		lea	(Level_data_addr_RAM.Music).w,a1						; load music
		moveq	#0,d0
		move.b	(a1),d0
		move.w	d0,(Current_music).w
		jsr	(Play_Music).w									; play music
		move.l	#Obj_TitleCard,(Dynamic_object_RAM+(object_size*5)+address).w			; load title card object

.wait
		move.b	#VintID_Fade,(V_int_routine).w
		jsr	(Process_KosPlus_Queue).w
		jsr	(Wait_VSync).w
		jsr	(Process_Sprites).w
		jsr	(Render_Sprites).w
		jsr	(Process_KosPlus_Module_Queue).w
		tst.w	(Dynamic_object_RAM+(object_size*5)+objoff_48).w				; has title card sequence finished?
		bne.s	.wait										; if not, branch
		tst.w	(KosPlus_modules_left).w							; are there any items in the pattern load cue?
		bne.s	.wait										; if yes, branch
		disableInts
		jsr	(HUD_DrawInitial).w								; init HUD
		enableInts
		jsr	(Get_LevelSizeStart).w
		jsr	(DeformBgLayer).w
		jsr	(LoadLevelLoadBlock).w
		jsr	(LoadLevelLoadBlock2).w
		disableInts
		jsr	(Level_Setup).w									; draw level
		enableInts

		; check
		move.l	(Level_data_addr_RAM.AnimateTilesInit).w,d0
		beq.s	.askip
		movea.l	d0,a0
		jsr	(a0)										; animate art init

.askip
		jsr	(Load_Solids).w
		jsr	(Handle_Onscreen_Water_Height).w
		moveq	#0,d0
		move.w	d0,(Ctrl_1_logical).w
		move.w	d0,(Ctrl_1).w
		move.b	d0,(HUD_RAM.status).w								; clear HUD flag
		move.b	d0,(Update_HUD_timer).w								; clear time counter update flag
		tst.b	(Last_star_post_hit).w								; are you starting from a starpost?
		bne.s	.starpost									; if yes, branch
		move.w	d0,(Ring_count).w								; clear rings
		move.l	d0,(Timer).w									; clear time
		move.b	d0,(Saved_status_secondary).w
		move.b	d0,(Respawn_table_keep).w

.starpost
		move.b	d0,(Time_over_flag).w
		jsr	(OscillateNumInit).w
		moveq	#1,d0
		move.b	d0,(Ctrl_1_locked).w
		move.b	d0,(Update_HUD_score).w								; update score counter
		move.b	d0,(Update_HUD_ring_count).w							; update rings counter
		move.b	d0,(Level_started_flag).w
		lea	LevelExtraRender_Data(pc),a1
		jsr	(Load_ExtraRender).w
		move.l	#Load_Objects_Init,(Object_load_addr_RAM).w
		move.l	#Load_Rings_Init,(Rings_manager_addr_RAM).w
		tst.b	(Water_flag).w
		beq.s	.notwater2
		move.l	#Obj_WaveSplash,(Wave_Splash+address).w

.notwater2
		bsr.w	SpawnLevelMainSprites
		jsr	(Load_Objects).w
		jsr	(Load_Rings).w
		jsr	(Process_Sprites).w
		jsr	(Render_Sprites).w
		jsr	(Animate_Tiles).w
		move.w	#bytes_to_word(16*2,48-1),(Palette_fade_info).w					; set fade info and fade count
		jsr	(Pal_FillBlack).w
		moveq	#22,d0
		move.w	d0,(Palette_fade_timer).w							; time for Pal_FromBlack
		move.w	d0,(Dynamic_object_RAM+(object_size*5)+objoff_2E).w				; time for Title Card
		move.w	#$7F00,(Ctrl_1).w
		andi.b	#$7F,(Last_star_post_hit).w
		bclr	#GameModeFlag_TitleCard,(Game_mode).w						; subtract $80 from mode to end pre-level stuff

.loop
		jsr	(Pause_Game).w
		move.b	#VintID_Level,(V_int_routine).w
		jsr	(Process_KosPlus_Queue).w
		jsr	(Wait_VSync).w
		addq.w	#1,(Level_frame_counter).w
		jsr	(Special_Events).w
		jsr	(Load_Objects).w
		jsr	(Process_Sprites).w
		tst.b	(Restart_level_flag).w
		bne.w	LevelScreen
		jsr	(DeformBgLayer).w
		jsr	(Screen_Events).w
		jsr	(Handle_Onscreen_Water_Height).w
		jsr	(Load_Rings).w
		jsr	(Animate_Palette).w
		jsr	(Animate_Tiles).w
		jsr	(Process_KosPlus_Module_Queue).w
		jsr	(OscillateNumDo).w
		jsr	(ChangeRingFrame).w
		jsr	(Render_Sprites).w
		bra.s	.loop
; ---------------------------------------------------------------------------

LevelExtraRender_Data:
		dc.w 2-1
		dc.l Render_HUD		; 0
		dc.l Render_Rings	; 1

; =============== S U B R O U T I N E =======================================

SpawnLevelMainSprites:
		move.l	#Obj_ResetCollisionResponseList,(Reserved_object_3+address).w
		move.l	#Obj_Sonic,(Player_1+address).w
		move.l	#Obj_DashDust,(Dust+address).w
		move.l	#Obj_InstaShield,(Shield+address).w
		rts

; =============== S U B R O U T I N E =======================================

Obj_ResetCollisionResponseList:
		clr.w	(Collision_response_list).w
		rts
