; ---------------------------------------------------------------------------
; StarPost (Object)
; ---------------------------------------------------------------------------

; Dynamic object variables

; =============== S U B R O U T I N E =======================================

Obj_StarPost:

		; init
		movem.l	ObjDat_StarPost(pc),d0-d3					; copy data to d0-d3
		movem.l	d0-d3,address(a0)						; set data from d0-d3 to current object
		move.w	#2,mainspr_childsprites(a0)

		; create circle
		lea	sub2_x_pos(a0),a1						; $16-$23 bytes reserved
		move.w	x_pos(a0),(a1)+							; xpos
		moveq	#-32,d0
		add.w	y_pos(a0),d0
		move.w	d0,(a1)+							; ypos
		move.w	#1,(a1)+							; frame (circle)
		move.w	x_pos(a0),(a1)+							; xpos
		move.w	y_pos(a0),(a1)+							; ypos
;		move.w	#0,(a1)+							; frame (pillar)

		; check
		move.w	respawn_addr(a0),d0						; get address in respawn table
		beq.s	.main								; if it's zero, it isn't remembered
		movea.w	d0,a2								; load address into a2
		btst	#0,(a2)
		bne.s	.main
		moveq	#$7F,d1
		and.b	(Last_star_post_hit).w,d1
		moveq	#$7F,d2
		and.b	subtype(a0),d2
		cmp.b	d2,d1
		blo.s	.main
		bset	#0,(a2)
		move.l	#.canim,address(a0)						; set as "taken"
		bra.s	.draw
; ---------------------------------------------------------------------------

.main

		; check player
		bsr.s	.check

.draw
		jmp	(Sprite_CheckDelete).w

; =============== S U B R O U T I N E =======================================

.check
		moveq	#$7F,d1
		and.b	(Last_star_post_hit).w,d1
		moveq	#$7F,d2
		and.b	subtype(a0),d2
		cmp.b	d2,d1
		bhs.s	.taken
		tst.w	(Debug_placement_mode).w					; is debug mode on?
		bne.s	.return								; if yes, branch

		; check xpos
		move.w	(Player_1+x_pos).w,d0
		sub.w	x_pos(a0),d0
		addi.w	#8,d0
		cmpi.w	#16,d0
		bhs.s	.return

		; check ypos
		move.w	(Player_1+y_pos).w,d0
		sub.w	y_pos(a0),d0
		addi.w	#64,d0
		cmpi.w	#104,d0
		bhs.s	.return

		; play sfx
		sfx	sfx_StarPost

		; move circle
		move.w	#34,objoff_36(a0)						; rotation time

		; check bonus
		cmpi.w	#50,(Ring_count).w						; does Sonic have at least 50 rings?
		blo.s	.notbonus							; if not, branch
		bsr.w	Load_StarPost_Stars						; load stars

.notbonus
		bsr.s	Save_StarPost_Settings
		move.l	#.circular,address(a0)

		; check
		move.w	respawn_addr(a0),d0						; get address in respawn table
		beq.s	.return								; if it's zero, it isn't remembered
		movea.w	d0,a2								; load address into a2
		bset	#0,(a2)

.return
		rts
; ---------------------------------------------------------------------------

.taken
		move.l	#.canim,address(a0)						; set as "taken"
		rts

; =============== S U B R O U T I N E =======================================

.circular
		subq.w	#1,objoff_36(a0)
		bne.s	.cmove
		move.l	#.canim,address(a0)

.canim
		moveq	#1,d0
		btst	#2,(Level_frame_counter+1).w
		beq.s	.cdraw
		addq.b	#1,d0

.cdraw
		move.b	d0,sub2_mapframe(a0)
		jmp	(Sprite_CheckDelete).w
; ---------------------------------------------------------------------------

.cmove
		moveq	#-$40,d0
		add.b	angle(a0),d0
		subi.b	#$10,angle(a0)
		jsr	(GetSineCosine).w
		move.w	#$C00,d2
		muls.w	d2,d1
		swap	d1
		add.w	x_pos(a0),d1
		move.w	d1,sub2_x_pos(a0)
		muls.w	d2,d0
		swap	d0
		add.w	y_pos(a0),d0
		subi.w	#20,d0
		move.w	d0,sub2_y_pos(a0)
		jmp	(Sprite_CheckDelete).w

; ---------------------------------------------------------------------------
; Save StarPost (Normal)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Save_StarPost_Settings:
		move.b	subtype(a0),(Last_star_post_hit).w
		move.w	x_pos(a0),(Saved_X_pos).w
		move.w	y_pos(a0),(Saved_Y_pos).w

Save_Level_Data:
		move.b	(Last_star_post_hit).w,(Saved_last_star_post_hit).w
		move.w	(Current_zone_and_act).w,(Saved_zone_and_act).w
		move.w	(Apparent_zone_and_act).w,(Saved_apparent_zone_and_act).w
		move.w	(Player_1+art_tile).w,(Saved_art_tile).w
		move.w	(Player_1+top_solid_bit).w,(Saved_solid_bits).w
		move.w	(Ring_count).w,(Saved_ring_count).w
		move.l	(Timer).w,(Saved_timer).w
		move.l	(Level_data_addr_RAM.Resize).w,(Saved_dynamic_resize).w
		move.l	(Level_data_addr_RAM.WaterResize).w,(Saved_waterdynamic_resize).w
		move.w	(Camera_max_Y_pos).w,(Saved_camera_max_Y_pos).w
		move.w	(Camera_X_pos).w,(Saved_camera_X_pos).w
		move.w	(Camera_Y_pos).w,(Saved_camera_Y_pos).w
		move.w	(Mean_water_level).w,(Saved_mean_water_level).w
		move.b	(Water_full_screen_flag).w,(Saved_water_full_screen_flag).w
		rts

; ---------------------------------------------------------------------------
; Load StarPost (Normal)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Load_StarPost_Settings:
		move.b	(Saved_last_star_post_hit).w,(Last_star_post_hit).w
		move.w	(Saved_zone_and_act).w,(Current_zone_and_act).w
		move.w	(Saved_apparent_zone_and_act).w,(Apparent_zone_and_act).w
		move.w	(Saved_X_pos).w,(Player_1+x_pos).w
		move.w	(Saved_Y_pos).w,(Player_1+y_pos).w
		move.w	(Saved_ring_count).w,(Ring_count).w
		tst.b	(Respawn_table_keep).w
		bne.s	.skip
		clr.w	(Ring_count).w

.skip
		move.l	(Saved_timer).w,(Timer).w
		move.b	#59,(Timer_frame).w
		subq.b	#1,(Timer_second).w
		move.w	(Saved_art_tile).w,(Player_1+art_tile).w
		move.w	(Saved_solid_bits).w,(Player_1+top_solid_bit).w
		move.l	(Saved_dynamic_resize).w,(Level_data_addr_RAM.Resize).w
		move.l	(Saved_waterdynamic_resize).w,(Level_data_addr_RAM.WaterResize).w
		move.w	(Saved_camera_max_Y_pos).w,(Camera_max_Y_pos).w
		move.w	(Saved_camera_max_Y_pos).w,(Camera_target_max_Y_pos).w
		move.w	(Saved_camera_X_pos).w,(Camera_X_pos).w
		move.w	(Saved_camera_Y_pos).w,(Camera_Y_pos).w
		tst.b	(Water_flag).w
		beq.s	.return
		move.w	(Saved_mean_water_level).w,(Mean_water_level).w
		move.b	(Saved_water_full_screen_flag).w,(Water_full_screen_flag).w

.return
		rts

; ---------------------------------------------------------------------------
; Load StarPost stars
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Load_StarPost_Stars:
		moveq	#4-1,d1
		moveq	#0,d2
		jsr	(Create_New_Sprite3).w
		bne.s	.return

.create
		move.l	#Obj_StarPost_Stars,address(a1)
		move.l	#Map_StarPostStars,mappings(a1)
		move.w	#make_art_tile(ArtTile_StarPost+8,0,0),art_tile(a1)
		move.b	#setBit(render_flags.level),render_flags(a1)			; use screen coordinates
		move.w	priority(a0),priority(a1)
		move.w	#bytes_to_word(16/2,16/2),height_pixels(a1)			; set height and width
		move.b	#1,mapping_frame(a1)
		move.w	a0,parent3(a1)							; save parent (StarPost)
		move.w	x_pos(a0),d3
		move.w	d3,x_pos(a1)
		move.w	d3,objoff_30(a1)
		moveq	#-48,d3
		add.w	y_pos(a0),d3
		move.w	d3,y_pos(a1)
		move.w	d3,objoff_32(a1)
		move.l	#words_to_long(-$400,0),x_vel(a1)
		move.w	d2,objoff_34(a1)
		addi.w	#256/4,d2
		jsr	(Create_New_Sprite4).w						; find next free object slot
		dbne	d1,.create

.return
		rts

; ---------------------------------------------------------------------------
; StarPost stars (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_StarPost_Stars:
		move.b	collision_property(a0),d0
		beq.s	loc_2D50A
		andi.b	#1,d0
		beq.s	loc_2D506

		; load special stage
		addq.w	#4*2,sp								; exit from object and current screen
		move.b	#GameModeID_LevelSelectScreen,(Game_mode).w			; set screen mode to special stage
		moveq	#$71,d0
		and.b	(Player_1+status_secondary).w,d0
		move.b	d0,(Saved_status_secondary).w
		st	(Respawn_table_keep).w
		jsr	(Clear_SpriteRingMem).w

loc_2D506:
		clr.b	collision_property(a0)

loc_2D50A:
		move.w	objoff_34(a0),d0
		addi.w	#10,objoff_34(a0)
		jsr	(GetSineCosine).w
		asr.w	#5,d0
		asr.w	#3,d1
		move.w	d1,d3
		move.w	objoff_34(a0),d2
		andi.w	#$3E0,d2
		lsr.w	#5,d2
		moveq	#2,d5
		moveq	#0,d4
		cmpi.w	#16,d2
		ble.s	loc_2D53A
		neg.w	d1

loc_2D53A:
		andi.w	#$F,d2
		cmpi.w	#8,d2
		ble.s	loc_2D54A
		neg.w	d2
		andi.w	#7,d2

loc_2D54A:
		lsr.w	d2
		beq.s	loc_2D550
		add.w	d1,d4

loc_2D550:
		asl.w	d1
		dbf	d5,loc_2D54A
		asr.w	#4,d4
		add.w	d4,d0
		addq.w	#1,objoff_36(a0)
		move.w	objoff_36(a0),d1
		cmpi.w	#$80,d1
		beq.s	loc_2D574
		bgt.s	loc_2D57A

loc_2D56A:
		muls.w	d1,d0
		muls.w	d1,d3
		asr.w	#7,d0
		asr.w	#7,d3
		bra.s	loc_2D58C
; ---------------------------------------------------------------------------

loc_2D574:
		move.b	#$18|collision_flags.npc.special,collision_flags(a0)		; set collision size 8x8

loc_2D57A:
		cmpi.w	#$180,d1
		ble.s	loc_2D58C
		neg.w	d1
		addi.w	#$200,d1
		bmi.s	loc_2D5C0
		bra.s	loc_2D56A
; ---------------------------------------------------------------------------

loc_2D58C:
		move.w	objoff_30(a0),d2
		add.w	d3,d2
		move.w	d2,x_pos(a0)
		move.w	objoff_32(a0),d2
		add.w	d0,d2
		move.w	d2,y_pos(a0)
		addq.b	#1,objoff_23(a0)
		moveq	#6,d0
		and.b	objoff_23(a0),d0
		lsr.w	d0
		cmpi.b	#3,d0
		bne.s	loc_2D5B6
		moveq	#1,d0

loc_2D5B6:
		move.b	d0,mapping_frame(a0)
		jmp	(Child_DrawTouch_Sprite).w
; ---------------------------------------------------------------------------

loc_2D5C0:
		jmp	(Delete_Current_Sprite).w

; =============== S U B R O U T I N E =======================================

; mapping
ObjDat_StarPost:	subObjMainData \
				Obj_StarPost.main, \
					setBit(render_flags.level) | \
					setBit(render_flags.multi_sprite), \
				0, 80, 16, 5, ArtTile_StarPost+8, 0, 0, Map_StarPost
; ---------------------------------------------------------------------------

		include "Objects/Main/StarPost/Object Data/Map - StarPost.asm"
		include "Objects/Main/StarPost/Object Data/Map - StarPost Stars.asm"
		include "Objects/Main/StarPost/Object Data/Map - Enemy Points.asm"
