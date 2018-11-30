
; =============== S U B R O U T I N E =======================================

Obj_StarPost:
		moveq	#0,d0
		move.b	5(a0),d0
		move.w	off_2CFB6(pc,d0.w),d1
		jmp	off_2CFB6(pc,d1.w)
; ---------------------------------------------------------------------------

off_2CFB6: offsetTable
		offsetTableEntry.w loc_2CFC0		; 0
		offsetTableEntry.w loc_2D012		; 2
		offsetTableEntry.w loc_2D0F8		; 4
		offsetTableEntry.w loc_2D10A		; 6
		offsetTableEntry.w loc_2D47E		; 8
; ---------------------------------------------------------------------------

loc_2CFC0:
		addq.b	#2,5(a0)
		move.l	#Map_StarPost,$C(a0)
		move.w	#$5EC,$A(a0)
		move.b	#4,4(a0)
		move.b	#8,7(a0)
		move.b	#$28,6(a0)
		move.w	#$280,8(a0)
		movea.w	respawn_addr(a0),a2
		btst	#0,(a2)
		bne.s	loc_2D008
		move.b	(Last_star_post_hit).w,d1
		andi.b	#$7F,d1
		move.b	$2C(a0),d2
		andi.b	#$7F,d2
		cmp.b	d2,d1
		blo.s		loc_2D012

loc_2D008:
		bset	#0,(a2)
		move.b	#2,$20(a0)

loc_2D012:
		tst.w	(Debug_placement_mode).w
		bne.w	loc_2D0F8
		lea	(Player_1).w,a3
		move.b	(Last_star_post_hit).w,d1
		bsr.s	sub_2D028
		bra.w	loc_2D0F8

; =============== S U B R O U T I N E =======================================

sub_2D028:
		andi.b	#$7F,d1
		move.b	$2C(a0),d2
		andi.b	#$7F,d2
		cmp.b	d2,d1
		bhs.w	loc_2D0EA
		move.w	$10(a3),d0
		sub.w	$10(a0),d0
		addi.w	#8,d0
		cmpi.w	#$10,d0
		bhs.w	locret_2D0E8
		move.w	$14(a3),d0
		sub.w	$14(a0),d0
		addi.w	#$40,d0
		cmpi.w	#$68,d0
		bhs.w	locret_2D0E8
		sfx	sfx_Lamppost,0,0,0
		jsr	(Create_New_Sprite).l
		bne.s	loc_2D0D0
		move.l	#Obj_StarPost,(a1)
		move.b	#6,5(a1)
		move.w	$10(a0),$30(a1)
		move.w	$14(a0),$32(a1)
		subi.w	#$14,$32(a1)
		move.l	$C(a0),$C(a1)
		move.w	$A(a0),$A(a1)
		move.b	#4,4(a1)
		move.b	#8,7(a1)
		move.b	#8,6(a1)
		move.w	#$200,8(a1)
		move.b	#2,$22(a1)
		move.w	#$20,$36(a1)
		move.w	a0,$3E(a1)
		cmpi.w	#20,(Ring_count).w
		blo.s		loc_2D0D0
		bsr.w	sub_2D3C8

loc_2D0D0:
		move.b	#1,$20(a0)
		bsr.w	Lamp_StoreInfo
		move.b	#4,5(a0)
		movea.w	respawn_addr(a0),a2
		bset	#0,(a2)

locret_2D0E8:
		rts
; ---------------------------------------------------------------------------

loc_2D0EA:
		tst.b	$20(a0)
		bne.s	locret_2D0F6
		move.b	#2,$20(a0)

locret_2D0F6:
		rts
; End of function sub_2D028
; ---------------------------------------------------------------------------

loc_2D0F8:
		lea	(Ani_Starpost).l,a1
		jsr	(Animate_Sprite).l
		jmp	(Sprite_OnScreen_Test).l
; ---------------------------------------------------------------------------

loc_2D10A:
		subq.w	#1,$36(a0)
		bpl.s	loc_2D12E
		movea.w	$3E(a0),a1
		cmpi.l	#Obj_StarPost,(a1)
		bne.s	loc_2D128
		move.b	#2,$20(a1)
		move.b	#0,$22(a1)

loc_2D128:
		jmp	(Delete_Current_Sprite).l
; ---------------------------------------------------------------------------

loc_2D12E:
		move.b	$26(a0),d0
		subi.b	#$10,$26(a0)
		subi.b	#$40,d0
		jsr	(GetSineCosine).l
		muls.w	#$C00,d1
		swap	d1
		add.w	$30(a0),d1
		move.w	d1,$10(a0)
		muls.w	#$C00,d0
		swap	d0
		add.w	$32(a0),d0
		move.w	d0,$14(a0)
		jmp	(Sprite_OnScreen_Test).l

; =============== S U B R O U T I N E =======================================

Lamp_StoreInfo:
		move.b	$2C(a0),(Last_star_post_hit).w
		move.w	$10(a0),(Saved_X_pos).w
		move.w	$14(a0),(Saved_Y_pos).w

Save_Level_Data:
		move.b	(Last_star_post_hit).w,(Saved_last_star_post_hit).w
		move.w	(Current_zone_and_act).w,(Saved_zone_and_act).w
		move.w	(Player_1+art_tile).w,(Saved_art_tile).w
		move.w	(Player_1+top_solid_bit).w,(Saved_solid_bits).w
		move.w	(Ring_count).w,(Saved_ring_count).w
		move.l	(Timer).w,(Saved_timer).w
		move.b	(Dynamic_resize_routine).w,(Saved_dynamic_resize_routine).w
		move.w	(Camera_max_Y_pos).w,(Saved_camera_max_Y_pos).w
		move.w	(Camera_X_pos).w,(Saved_camera_X_pos).w
		move.w	(Camera_Y_pos).w,(Saved_camera_Y_pos).w
		move.w	(Mean_water_level).w,(Saved_mean_water_level).w
		move.b	(Water_full_screen_flag).w,(Saved_water_full_screen_flag).w
		rts
; End of function Save_Level_Data

; =============== S U B R O U T I N E =======================================

Lamp_LoadInfo:
Load_Starpost_Settings:
		move.b	(Saved_last_star_post_hit).w,(Last_star_post_hit).w
		move.w	(Saved_zone_and_act).w,(Current_zone_and_act).w
		move.w	(Saved_X_pos).w,(Player_1+x_pos).w
		move.w	(Saved_Y_pos).w,(Player_1+y_pos).w
		move.w	(Saved_ring_count).w,(Ring_count).w
		clr.w	(Ring_count).w
		move.l	(Saved_timer).w,(Timer).w
		move.b	#59,(Timer_frame).w
		subq.b	#1,(Timer_second).w
		move.w	(Saved_art_tile).w,(Player_1+art_tile).w
		move.w	(Saved_solid_bits).w,(Player_1+top_solid_bit).w
		move.b	(Saved_dynamic_resize_routine).w,(Dynamic_resize_routine).w
		move.w	(Saved_camera_max_Y_pos).w,(Camera_max_Y_pos).w
		move.w	(Saved_camera_max_Y_pos).w,(Camera_target_max_Y_pos).w
		move.w	(Saved_camera_X_pos).w,(Camera_X_pos).w
		move.w	(Saved_camera_Y_pos).w,(Camera_Y_pos).w
		tst.b	(Water_flag).w
		beq.s	+
		move.w	(Saved_mean_water_level).w,(Mean_water_level).w
		move.b	(Saved_water_full_screen_flag).w,(Water_full_screen_flag).w
+		rts
; End of function Load_Starpost_Settings

; =============== S U B R O U T I N E =======================================

sub_2D3C8:
		moveq	#3,d1
		moveq	#0,d2

-		jsr	(Create_New_Sprite).l
		bne.s	+
		move.l	(a0),(a1)
		move.l	#Map_StarpostStars,$C(a1)
		move.w	#$5EC,$A(a1)
		move.b	#4,4(a1)
		move.b	#8,5(a1)
		move.w	$10(a0),d0
		move.w	d0,$10(a1)
		move.w	d0,$30(a1)
		move.w	$14(a0),d0
		subi.w	#$30,d0
		move.w	d0,$14(a1)
		move.w	d0,$32(a1)
		move.w	8(a0),8(a1)
		move.b	#8,7(a1)
		move.b	#1,$22(a1)
		move.w	#-$400,$18(a1)
		move.w	#0,$1A(a1)
		move.w	d2,$34(a1)
		addi.w	#$40,d2
		dbf	d1,-
+		lea	(ArtKosM_StarPostStars3).l,a1
		move.w	(Ring_count).w,d0
		subi.w	#20,d0
		divu.w	#15,d0
		ext.l	d0
		moveq	#3,d2
		divu.w	d2,d0
		swap	d0
		tst.w	d0
		beq.s	+
		lea	(ArtKosM_StarPostStars1).l,a1
		cmpi.w	#1,d0
		beq.s	+
		lea	(ArtKosM_StarPostStars2).l,a1
+		move.w	#tiles_to_bytes($5EC),d2
		jmp	(Queue_Kos_Module).l
; End of function sub_2D3C8
; ---------------------------------------------------------------------------

loc_2D47E:	; 8
		move.b	$29(a0),d0
		beq.w	loc_2D50A
		andi.b	#1,d0
		beq.s	loc_2D506
		move.w	#$100,(Current_zone_and_act).w
		move.w	(Ring_count).w,(Saved_ring_count).w
		clr.b	(Last_star_post_hit).w
		st	(Restart_level_flag).w
		move.b	(Player_1+status_secondary).w,d0
		andi.b	#$71,d0
		move.b	d0,(Saved_status_secondary).w
		jsr	(Clear_SpriteRingMem).l

loc_2D506:
		clr.b	$29(a0)

loc_2D50A:
		addi.w	#$A,$34(a0)
		move.w	$34(a0),d0
		andi.w	#$FF,d0
		jsr	(GetSineCosine).l
		asr.w	#5,d0
		asr.w	#3,d1
		move.w	d1,d3
		move.w	$34(a0),d2
		andi.w	#$3E0,d2
		lsr.w	#5,d2
		moveq	#2,d5
		moveq	#0,d4
		cmpi.w	#$10,d2
		ble.s		loc_2D53A
		neg.w	d1

loc_2D53A:
		andi.w	#$F,d2
		cmpi.w	#8,d2
		ble.s		loc_2D54A
		neg.w	d2
		andi.w	#7,d2

loc_2D54A:
		lsr.w	#1,d2
		beq.s	loc_2D550
		add.w	d1,d4

loc_2D550:
		asl.w	#1,d1
		dbf	d5,loc_2D54A
		asr.w	#4,d4
		add.w	d4,d0
		addq.w	#1,$36(a0)
		move.w	$36(a0),d1
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
		move.b	#-$28,$28(a0)

loc_2D57A:
		cmpi.w	#$180,d1
		ble.s		loc_2D58C
		neg.w	d1
		addi.w	#$200,d1
		bmi.w	loc_2D5C0
		bra.s	loc_2D56A
; ---------------------------------------------------------------------------

loc_2D58C:
		move.w	$30(a0),d2
		add.w	d3,d2
		move.w	d2,$10(a0)
		move.w	$32(a0),d2
		add.w	d0,d2
		move.w	d2,$14(a0)
		addq.b	#1,$23(a0)
		move.b	$23(a0),d0
		andi.w	#6,d0
		lsr.w	#1,d0
		cmpi.b	#3,d0
		bne.s	loc_2D5B6
		moveq	#1,d0

loc_2D5B6:
		move.b	d0,$22(a0)
		jmp	(RememberState_Collision).l
; ---------------------------------------------------------------------------

loc_2D5C0:
		jmp	(Delete_Current_Sprite).l
; ---------------------------------------------------------------------------

		include "Objects/StarPost/Object Data/Anim - Starpost.asm"
		include "Objects/StarPost/Object Data/Map - Starpost.asm"
		include "Objects/StarPost/Object Data/Map - Starpost Stars.asm"
		include "Objects/StarPost/Object Data/Map - Enemy Points.asm"