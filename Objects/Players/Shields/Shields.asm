; ---------------------------------------------------------------------------
; Shields (Object)
; ---------------------------------------------------------------------------

; Elemental Shield DPLC variables
shield_prev_frame			= objoff_34	; .b
shield_art_address			= objoff_38	; .l
shield_dplc_address			= objoff_3C	; .w
shield_vram_art				= objoff_40	; .w ; address of art in VRAM (same as art_tile * $20)
shield_parent				= objoff_42	; .w

; ---------------------------------------------------------------------------
; Fire Shield
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_FireShield:

		; init
		movem.l	ObjDat_FireShield(pc),d0-d3					; copy data to d0-d3
		movem.l	d0-d3,address(a0)						; set data from d0-d3 to current object
		move.l	#DPLC_FireShield,shield_dplc_address(a0)			; used by PLCLoad_Shields
		move.l	#dmaSource(ArtUnc_FireShield),shield_art_address(a0)		; used by PLCLoad_Shields
		move.w	#tiles_to_bytes(ArtTile_Shield),shield_vram_art(a0)		; used by PLCLoad_Shields

		; check priority
		btst	#high_priority_bit,(Player_1+art_tile).w			; is Sonic has high priority?
		beq.s	.nothighpriority						; if not, branch
		bset	#high_priority_bit,art_tile(a0)					; high priority

.nothighpriority
		move.w	#1,anim(a0)							; clear anim and set prev_anim to 1
		st	shield_prev_frame(a0)						; reset shield_prev_frame (used by PLCLoad_Shields)

.main
		lea	(Player_1).w,a2							; a2=character
		btst	#status_secondary.invincible,status_secondary(a2)		; is player invincible?
		bne.w	.return								; if so, do not display and do not update variables
		cmpi.b	#AniIDSonAni_Blank,anim(a2)					; is player in their 'blank' animation?
		beq.w	.return								; if so, do not display and do not update variables
		btst	#status_secondary.shield,status_secondary(a2)			; should the player still have a shield?
		beq.w	.destroy							; if not, change to Insta-Shield
		btst	#status.player.underwater,status(a2)				; is player underwater?
		bne.s	.destroyunderwater						; if so, branch
		move.w	x_pos(a2),x_pos(a0)
		move.w	y_pos(a2),y_pos(a0)
		tst.b	anim(a0)							; is shield in its 'dashing' state?
		bne.s	.nothighpriority2						; if so, do not update orientation or allow changing of the priority art_tile bit
		move.b	status(a2),status(a0)						; inherit status
		andi.b	#setBit(status.npc.x_flip),status(a0)				; limit inheritance to 'orientation' bit
		tst.b	(Reverse_gravity_flag).w
		beq.s	.normalgravity
		ori.b	#setBit(status.npc.y_flip),status(a0)				; if in reverse gravity, reverse the vertical mirror render_flag bit (On if Off beforehand and vice versa)

.normalgravity
		andi.w	#drawing_mask,art_tile(a0)
		tst.w	art_tile(a2)
		bpl.s	.nothighpriority2
		ori.w	#high_priority,art_tile(a0)

.nothighpriority2
		lea	Ani_FireShield(pc),a1
		jsr	(Animate_Sprite).w
		move.w	#priority_1,d0							; layer shield over player sprite
		cmpi.b	#$F,mapping_frame(a0)						; are these the frames that display in front of the player?
		blo.s	.overplayer							; if so, branch
		move.w	#priority_4,d0							; if not, layer shield behind player sprite

.overplayer
		move.w	d0,priority(a0)
		bsr.w	PLCLoad_Shields
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.destroyunderwater
		jsr	(Create_New_Sprite).w						; set up for a new object
		bne.s	.destroy							; if that can't happen, branch
		move.l	#Obj_FireShield_Dissipate,address(a1)				; create dissipate object
		move.w	x_pos(a0),x_pos(a1)						; put it at shields' x_pos
		move.w	y_pos(a0),y_pos(a1)						; put it at shields' y_pos

.destroy

		; sets Status_Shield, Status_FireShield, Status_LtngShield, and Status_BublShield to 0
		andi.b	#~( \
			setBit(status_secondary.shield) | \
			setBit(status_secondary.fire_shield) | \
			setBit(status_secondary.lightning_shield) | \
			setBit(status_secondary.bubble_shield) \
		),status_secondary(a2)

		move.l	#Obj_InstaShield,address(a0)					; replace the Fire Shield with the Insta-Shield

.return
		rts

; ---------------------------------------------------------------------------
; Lightning Shield
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_LightningShield:

.artsize	:= (ArtUnc_LightningShield_Sparks_end-ArtUnc_LightningShield_Sparks)&$FFFF

		; load spark art
		QueueStaticDMA ArtUnc_LightningShield_Sparks,.artsize,tiles_to_bytes(ArtTile_Shield_Sparks)

		; init
		movem.l	ObjDat_LightningShield(pc),d0-d3				; copy data to d0-d3
		movem.l	d0-d3,address(a0)						; set data from d0-d3 to current object
		move.l	#DPLC_LightningShield,shield_dplc_address(a0)			; used by PLCLoad_Shields
		move.l	#dmaSource(ArtUnc_LightningShield),shield_art_address(a0)	; used by PLCLoad_Shields
		move.w	#tiles_to_bytes(ArtTile_Shield),shield_vram_art(a0)		; used by PLCLoad_Shields

		; check priority
		btst	#high_priority_bit,(Player_1+art_tile).w			; is Sonic has high priority?
		beq.s	.nothighpriority						; if not, branch
		bset	#high_priority_bit,art_tile(a0)					; high priority

.nothighpriority
		move.w	#1,anim(a0)							; clear anim and set prev_anim to 1
		st	shield_prev_frame(a0)						; reset shield_prev_frame (used by PLCLoad_Shields)

.main
		lea	(Player_1).w,a2							; a2=character
		btst	#status_secondary.invincible,status_secondary(a2)		; is player invincible?
		bne.s	Obj_FireShield.return						; if so, do not display and do not update variables
		cmpi.b	#AniIDSonAni_Blank,anim(a2)					; is player in their 'blank' animation?
		beq.s	Obj_FireShield.return						; if so, do not display and do not update variables
		btst	#status_secondary.shield,status_secondary(a2)			; should the player still have a shield?
		beq.s	.destroy							; if not, change to Insta-Shield
		btst	#status.player.underwater,status(a2)				; is player underwater?
		bne.s	.destroyunderwater						; if so, branch
		move.w	x_pos(a2),x_pos(a0)
		move.w	y_pos(a2),y_pos(a0)
		move.b	status(a2),status(a0)						; inherit status
		andi.b	#setBit(status.npc.x_flip),status(a0)				; limit inheritance to 'orientation' bit
		tst.b	(Reverse_gravity_flag).w
		beq.s	.normalgravity
		ori.b	#setBit(status.npc.y_flip),status(a0)				; if in reverse gravity, reverse the vertical mirror render_flag bit (On if Off beforehand and vice versa)

.normalgravity
		andi.w	#drawing_mask,art_tile(a0)
		tst.w	art_tile(a2)
		bpl.s	.nothighpriority2
		ori.w	#high_priority,art_tile(a0)

.nothighpriority2
		tst.b	anim(a0)							; is shield in its 'double jump' state?
		beq.s	.display							; is not, branch and display
		bsr.s	Obj_LightningShield_Create_Spark				; create sparks
		clr.b	anim(a0)							; once done, return to non-'double jump' state

.display
		lea	Ani_LightningShield(pc),a1
		jsr	(Animate_Sprite).w
		move.w	#priority_1,d0							; layer shield over player sprite
		cmpi.b	#$E,mapping_frame(a0)						; are these the frames that display in front of the player?
		blo.s	.overplayer							; if so, branch
		move.w	#priority_4,d0							; if not, layer shield behind player sprite

.overplayer
		move.w	d0,priority(a0)
		bsr.w	PLCLoad_Shields
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.destroyunderwater
		tst.w	(Palette_fade_timer).w
		beq.s	.flashwater

.destroy

		; sets Status_Shield, Status_FireShield, Status_LtngShield, and Status_BublShield to 0
		andi.b	#~( \
			setBit(status_secondary.shield) | \
			setBit(status_secondary.fire_shield) | \
			setBit(status_secondary.lightning_shield) | \
			setBit(status_secondary.bubble_shield) \
		),status_secondary(a2)

		move.l	#Obj_InstaShield,address(a0)					; replace the Lightning Shield with the Insta-Shield

.return
		rts
; ---------------------------------------------------------------------------

.flashwater
		move.l	#Obj_LightningShield_DestroyUnderwater2,address(a0)

		; sets Status_Shield, Status_FireShield, Status_LtngShield, and Status_BublShield to 0
		andi.b	#~( \
			setBit(status_secondary.shield) | \
			setBit(status_secondary.fire_shield) | \
			setBit(status_secondary.lightning_shield) | \
			setBit(status_secondary.bubble_shield) \
		),status_secondary(a2)

		; flashes the underwater palette white
		lea	(Water_palette).w,a1
		lea	(Target_water_palette).w,a2
		moveq	#bytesToLcnt(Water_palette-Target_water_palette),d0		; size of Water_palette/4-1

.loop
		move.l	(a1),(a2)+							; backup palette entries
		move.l	#words_to_long(cWhite,cWhite),(a1)+				; overwrite palette entries with white
		dbf	d0,.loop							; loop until entire thing is overwritten
		move.b	#3,anim_frame_timer(a0)
		rts

; ---------------------------------------------------------------------------
; Create Lightning Shield (Spark)
; ---------------------------------------------------------------------------

SparkVelocities:	; x_vel, y_vel
		dc.w -$200, -$200
		dc.w $200, -$200
		dc.w -$200, $200
		dc.w $200, $200

; =============== S U B R O U T I N E =======================================

Obj_LightningShield_Create_Spark:
		moveq	#1,d2								; set anim

.part2											; skip anim
		lea	SparkVelocities(pc),a2
		moveq	#4-1,d1
		jsr	(Create_New_Sprite).w						; find free object slot
		bne.s	.return								; if one can't be found, return

.loop
		move.l	#Obj_LightningShield_Spark,address(a1)				; make new object a Spark
		move.w	x_pos(a0),x_pos(a1)						; (Spark) inherit x_pos from source object (Lightning Shield, Hyper Sonic Stars)
		move.w	y_pos(a0),y_pos(a1)						; (Spark) inherit y_pos from source object (Lightning Shield, Hyper Sonic Stars)
		move.l	mappings(a0),mappings(a1)					; (Spark) inherit mappings from source object (Lightning Shield, Hyper Sonic Stars)
		move.w	art_tile(a0),art_tile(a1)					; (Spark) inherit art_tile from source object (Lightning Shield, Hyper Sonic Stars)
		move.b	#setBit(render_flags.level),render_flags(a1)			; use screen coordinates
		move.l	#bytes_word_to_long(16/2,16/2,priority_1),height_pixels(a1)	; set height, width and priority
		move.b	d2,anim(a1)
		move.l	(a2)+,x_vel(a1)							; (Spark) give x_vel and y_vel (unique to each of the four Sparks)
		jsr	(Create_New_Sprite4).w						; find next free object slot
		dbne	d1,.loop

.return
		rts

; ---------------------------------------------------------------------------
; Lightning Shield (Spark)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_LightningShield_Spark:
		MoveSprite a0, $18
		lea	Ani_LightningShield(pc),a1
		jsr	(Animate_Sprite).w
		tst.b	routine(a0)							; changed by Animate_Sprite
		bne.s	.delete
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.delete
		jmp	(Delete_Current_Sprite).w

; =============== S U B R O U T I N E =======================================

Obj_LightningShield_DestroyUnderwater2:
		subq.b	#1,anim_frame_timer(a0)						; is it time to end the white flash?
		bpl.s	Obj_LightningShield_Create_Spark.return				; if not, return
		move.l	#Obj_InstaShield,address(a0)					; replace Lightning Shield with Insta-Shield

		; restore backed-up underwater palette
		lea	(Target_water_palette).w,a1
		lea	(Water_palette).w,a2
		jmp	(PalLoad_Line64).w

; ---------------------------------------------------------------------------
; Bubble Shield
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_BubbleShield:

		; init
		movem.l	ObjDat_BubbleShield(pc),d0-d3					; copy data to d0-d3
		movem.l	d0-d3,address(a0)						; set data from d0-d3 to current object
		move.l	#DPLC_BubbleShield,shield_dplc_address(a0)			; used by PLCLoad_Shields
		move.l	#dmaSource(ArtUnc_BubbleShield),shield_art_address(a0)		; used by PLCLoad_Shields
		move.w	#tiles_to_bytes(ArtTile_Shield),shield_vram_art(a0)		; used by PLCLoad_Shields

		; check priority
		btst	#high_priority_bit,(Player_1+art_tile).w			; is Sonic has high priority?
		beq.s	.nothighpriority						; if not, branch
		bset	#high_priority_bit,art_tile(a0)					; high priority

.nothighpriority
		move.w	#1,anim(a0)							; clear anim and set prev_anim to 1
		st	shield_prev_frame(a0)						; reset shield_prev_frame (used by PLCLoad_Shields)
		lea	(Player_1).w,a1							; a1=character
		jsr	(Player_ResetAirTimer).l

.main
		lea	(Player_1).w,a2							; a2=character
		btst	#status_secondary.invincible,status_secondary(a2)		; is player invincible?
		bne.s	.return								; if so, do not display and do not update variables
		cmpi.b	#AniIDSonAni_Blank,anim(a2)					; is player in their 'blank' animation?
		beq.s	.return								; if so, do not display and do not update variables
		btst	#status_secondary.shield,status_secondary(a2)			; should the player still have a shield?
		beq.s	.destroy							; if not, change to Insta-Shield
		move.w	x_pos(a2),x_pos(a0)
		move.w	y_pos(a2),y_pos(a0)
		move.b	status(a2),status(a0)						; inherit status
		andi.b	#setBit(status.npc.x_flip),status(a0)				; limit inheritance to 'orientation' bit
		tst.b	(Reverse_gravity_flag).w
		beq.s	.normalgravity
		ori.b	#setBit(status.npc.y_flip),status(a0)				; reverse the vertical mirror render_flag bit (On if Off beforehand and vice versa)

.normalgravity
		andi.w	#drawing_mask,art_tile(a0)
		tst.w	art_tile(a2)
		bpl.s	.nothighpriority2
		ori.w	#high_priority,art_tile(a0)

.nothighpriority2
		lea	Ani_BubbleShield(pc),a1
		jsr	(Animate_Sprite).w
		bsr.w	PLCLoad_Shields
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.destroy

		; sets Status_Shield, Status_FireShield, Status_LtngShield, and Status_BublShield to 0
		andi.b	#~( \
			setBit(status_secondary.shield) | \
			setBit(status_secondary.fire_shield) | \
			setBit(status_secondary.lightning_shield) | \
			setBit(status_secondary.bubble_shield) \
		),status_secondary(a2)

		move.l	#Obj_InstaShield,address(a0)					; replace the Bubble Shield with the Insta-Shield

.return
		rts

; ---------------------------------------------------------------------------
; Insta Shield
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_InstaShield:

		; init
		movem.l	ObjDat_InstaShield(pc),d0-d3					; copy data to d0-d3
		movem.l	d0-d3,address(a0)						; set data from d0-d3 to current object
		move.l	#DPLC_InstaShield,shield_dplc_address(a0)			; used by PLCLoad_Shields
		move.l	#dmaSource(ArtUnc_InstaShield),shield_art_address(a0)		; used by PLCLoad_Shields
		move.w	#tiles_to_bytes(ArtTile_Shield),shield_vram_art(a0)		; used by PLCLoad_Shields

		; check priority
		btst	#high_priority_bit,(Player_1+art_tile).w			; is Sonic has high priority?
		beq.s	.nothighpriority						; if not, branch
		bset	#high_priority_bit,art_tile(a0)					; high priority

.nothighpriority
		move.w	#1,anim(a0)							; clear anim and set prev_anim to 1
		st	shield_prev_frame(a0)						; reset shield_prev_frame (used by PLCLoad_Shields)

.main
		lea	(Player_1).w,a2							; a2=character
		btst	#status_secondary.invincible,status_secondary(a2)				; is the player invincible?
		bne.s	Obj_BubbleShield.return						; if so, return
		move.w	x_pos(a2),x_pos(a0)						; inherit player's x_pos
		move.w	y_pos(a2),y_pos(a0)						; inherit player's y_pos
		move.b	status(a2),status(a0)						; inherit status
		andi.b	#setBit(status.npc.x_flip),status(a0)				; limit inheritance to 'orientation' bit
		tst.b	(Reverse_gravity_flag).w
		beq.s	.normalgravity
		ori.b	#setBit(status.npc.y_flip),status(a0)				; reverse the vertical mirror render_flag bit (On if Off beforehand and vice versa)

.normalgravity
		andi.w	#drawing_mask,art_tile(a0)
		tst.w	art_tile(a2)
		bpl.s	.nothighpriority2
		ori.w	#high_priority,art_tile(a0)

.nothighpriority2
		lea	Ani_InstaShield(pc),a1
		jsr	(Animate_Sprite).w
		cmpi.b	#7,mapping_frame(a0)						; has it reached then end of its animation?
		bne.s	.notover							; if not, branch
		tst.b	double_jump_flag(a2)						; is it in its attacking state?
		beq.s	.notover							; if not, branch
		move.b	#2,double_jump_flag(a2)						; mark attack as over

.notover
		tst.b	mapping_frame(a0)						; is this the first frame?
		beq.s	.loadnewdplc							; if so, branch and load the DPLC for this and the next few frames
		cmpi.b	#3,mapping_frame(a0)						; is this the third frame?
		bne.s	.skipdplc							; if not, branch as we don't need to load another DPLC yet

.loadnewdplc
		bsr.s	PLCLoad_Shields

.skipdplc
		jmp	(Draw_Sprite).w

; ---------------------------------------------------------------------------
; Shields (DPLC)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

PLCLoad_Shields:
		moveq	#0,d0
		move.b	mapping_frame(a0),d0
		cmp.b	shield_prev_frame(a0),d0
		beq.s	.return
		move.b	d0,shield_prev_frame(a0)

		; load
		add.w	d0,d0
		movea.l	shield_dplc_address(a0),a2
		adda.w	(a2,d0.w),a2
		move.w	(a2)+,d5
		subq.w	#1,d5
		bmi.s	.return
		move.w	shield_vram_art(a0),d4
		move.l	shield_art_address(a0),d6

.readentry
		moveq	#0,d1
		move.w	(a2)+,d1
		move.w	d1,d3
		move.w	d3,-(sp)
		move.b	(sp)+,d3
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1
		lsl.l	#4,d1
		add.l	d6,d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr	(Add_To_DMA_Queue).w
		dbf	d5,.readentry

.return
		rts

; ---------------------------------------------------------------------------
; Invincibility
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_Invincibility:

.artsize	:= (ArtUnc_Invincibility_end-ArtUnc_Invincibility)&$FFFF

		; load invincibility art
		QueueStaticDMA ArtUnc_Invincibility,.artsize,tiles_to_bytes(ArtTile_Shield)

		; init
		moveq	#0,d2
		lea	off_187DE-6(pc),a2
		lea	(a0),a1
		moveq	#4-1,d1

.loop
		movem.l	ObjDat_Invincibility(pc),d0/d3-d5				; copy data to d0/d3-d5
		movem.l	d0/d3-d5,address(a1)						; set data from d0/d3-d5 to current object
		move.w	#2,mainspr_childsprites(a1)
		move.w	parent(a0),parent(a1)
		move.b	d2,objoff_36(a1)
		addq.w	#1,d2
		move.l	(a2)+,objoff_30(a1)
		move.w	(a2)+,objoff_34(a1)
		lea	next_object(a1),a1
		dbf	d1,.loop
		move.l	#.main,address(a0)
		move.b	#4,objoff_34(a0)

.main
		lea	(Player_1).w,a1							; a1=character
		btst	#status_secondary.invincible,status_secondary(a1)		; should the player still have a invincible?
		beq.s	.delete								; if not, delete
		move.w	x_pos(a1),d0
		move.w	d0,x_pos(a0)
		move.w	y_pos(a1),d1
		move.w	d1,y_pos(a0)
		lea	sub2_x_pos(a0),a2
		lea	byte_189E0(pc),a3
		moveq	#0,d5

.find
		move.w	objoff_38(a0),d2
		move.b	(a3,d2.w),d5
		bpl.s	.found
		clr.w	objoff_38(a0)
		bra.s	.find
; ---------------------------------------------------------------------------

.found
		addq.w	#1,objoff_38(a0)
		lea	byte_189A0(pc),a6
		move.b	objoff_34(a0),d6
		bsr.w	sub_1898A
		move.w	d2,(a2)+							; sub2_x_pos
		move.w	d3,(a2)+							; sub2_y_pos
		move.w	d5,(a2)+							; sub2_mapframe
		addi.w	#$20,d6
		bsr.w	sub_1898A
		move.w	d2,(a2)+							; sub3_x_pos
		move.w	d3,(a2)+							; sub3_y_pos
		move.w	d5,(a2)+							; sub3_mapframe
		moveq	#$12,d0
		btst	#status.player.x_flip,status(a1)
		beq.s	.notflip
		neg.w	d0

.notflip
		add.b	d0,objoff_34(a0)
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.delete
		jmp	(Delete_Current_Sprite).w

; =============== S U B R O U T I N E =======================================

Obj_188E8:
		lea	(Player_1).w,a1							; a1=character
		btst	#status_secondary.invincible,status_secondary(a1)		; should the player still have a invincible?
		beq.s	Obj_Invincibility.delete					; if not, delete
		lea	(Pos_table_index).w,a5
		lea	(Pos_table).w,a6
		moveq	#0,d1
		move.b	objoff_36(a0),d1
		add.b	d1,d1
		add.b	d1,d1
		move.w	d1,d2
		add.w	d1,d1
		add.w	d2,d1
		move.w	(a5),d0
		sub.b	d1,d0
		lea	(a6,d0.w),a2
		move.w	(a2)+,d0
		move.w	(a2)+,d1
		move.w	d0,x_pos(a0)
		move.w	d1,y_pos(a0)
		lea	sub2_x_pos(a0),a2
		movea.l	objoff_30(a0),a3

.find
		move.w	objoff_38(a0),d2
		move.b	(a3,d2.w),d5
		bpl.s	.found
		clr.w	objoff_38(a0)
		bra.s	.find
; ---------------------------------------------------------------------------

.found
		swap	d5
		add.b	objoff_35(a0),d2
		move.b	(a3,d2.w),d5
		addq.w	#1,objoff_38(a0)
		lea	byte_189A0(pc),a6
		move.b	objoff_34(a0),d6
		bsr.s	sub_1898A
		move.w	d2,(a2)+							; sub2_x_pos
		move.w	d3,(a2)+							; sub2_y_pos
		move.w	d5,(a2)+							; sub2_mapframe
		addi.w	#$20,d6
		swap	d5
		bsr.s	sub_1898A
		move.w	d2,(a2)+							; sub3_x_pos
		move.w	d3,(a2)+							; sub3_y_pos
		move.w	d5,(a2)+							; sub3_mapframe
		moveq	#2,d0
		btst	#status.player.x_flip,status(a1)
		beq.s	.notflip
		neg.w	d0

.notflip
		add.b	d0,objoff_34(a0)
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

sub_1898A:
		andi.w	#$3E,d6
		move.b	(a6,d6.w),d2
		move.b	1(a6,d6.w),d3
		ext.w	d2
		ext.w	d3
		add.w	d0,d2
		add.w	d1,d3
		rts
; ---------------------------------------------------------------------------

off_187DE:
		dc.l byte_189ED		; 1
		dc.b 0, $B
		dc.l byte_18A02		; 2
		dc.b $16, $D
		dc.l byte_18A1B		; 3
		dc.b $2C, $D

byte_189A0:
		dc.b $F, 0
		dc.b $F, 3
		dc.b $E, 6
		dc.b $D, 8
		dc.b $B, $B
		dc.b 8, $D
		dc.b 6, $E
		dc.b 3, $F
		dc.b 0, $10
		dc.b -4, $F
		dc.b -7, $E
		dc.b -9, $D
		dc.b -$C, $B
		dc.b -$E, 8
		dc.b -$F, 6
		dc.b -$10, 3
		dc.b -$10, 0
		dc.b -$10, -4
		dc.b -$F, -7
		dc.b -$E, -9
		dc.b -$C, -$C
		dc.b -9, -$E
		dc.b -7, -$F
		dc.b -4,-$10
		dc.b -1,-$10
		dc.b 3,-$10
		dc.b 6, -$F
		dc.b 8, -$E
		dc.b $B, -$C
		dc.b $D, -9
		dc.b $E, -7
		dc.b $F, -4
byte_189E0:
		dc.b 8, 5, 7, 6, 6, 7, 5, 8, 6, 7, 7, 6, $FF
byte_189ED:
		dc.b 8, 7, 6, 5, 4, 3, 4, 5, 6, 7, $FF, 3, 4, 5, 6, 7, 8, 7, 6, 5
		dc.b 4
byte_18A02:
		dc.b 8, 7, 6, 5, 4, 3, 2, 3, 4, 5, 6, 7, $FF, 2, 3, 4, 5, 6, 7, 8
		dc.b 7, 6, 5, 4, 3
byte_18A1B:
		dc.b 7, 6, 5, 4, 3, 2, 1, 2, 3, 4, 5, 6, $FF, 1, 2, 3, 4, 5, 6, 7
		dc.b 6, 5, 4, 3, 2
	even

; =============== S U B R O U T I N E =======================================

; mapping
ObjDat_FireShield:		subObjMainData \
				Obj_FireShield.main, \
					setBit(render_flags.level), \
				0, 48, 48, 1, ArtTile_Shield, 0, 0, Map_FireShield

ObjDat_LightningShield:		subObjMainData \
				Obj_LightningShield.main, \
					setBit(render_flags.level), \
				0, 48, 48, 1, ArtTile_Shield, 0, 0, Map_LightningShield

ObjDat_BubbleShield:		subObjMainData \
				Obj_BubbleShield.main, \
					setBit(render_flags.level), \
				0, 48, 48, 1, ArtTile_Shield, 0, 0, Map_BubbleShield

ObjDat_InstaShield:		subObjMainData \
				Obj_InstaShield.main, \
					setBit(render_flags.level), \
				0, 48, 48, 1, ArtTile_Shield, 0, 0, Map_InstaShield

ObjDat_Invincibility:		subObjMainData \
				Obj_188E8, \
					setBit(render_flags.level) | \
					setBit(render_flags.multi_sprite), \
				0, 32, 32, 1, ArtTile_Shield, 0, 0, Map_Invincibility
; ---------------------------------------------------------------------------

		include "Objects/Players/Shields/Object Data/Anim - Fire Shield.asm"
		include "Objects/Players/Shields/Object Data/Anim - Lightning Shield.asm"
		include "Objects/Players/Shields/Object Data/Anim - Bubble Shield.asm"
		include "Objects/Players/Shields/Object Data/Anim - Insta-Shield.asm"
		include "Objects/Players/Shields/Object Data/Map - Invincibility.asm"
		include "Objects/Players/Shields/Object Data/Map - Fire Shield.asm"
		include "Objects/Players/Shields/Object Data/DPLC - Fire Shield.asm"
		include "Objects/Players/Shields/Object Data/Map - Lightning Shield.asm"
		include "Objects/Players/Shields/Object Data/DPLC - Lightning Shield.asm"
		include "Objects/Players/Shields/Object Data/Map - Bubble Shield.asm"
		include "Objects/Players/Shields/Object Data/DPLC - Bubble Shield.asm"
		include "Objects/Players/Shields/Object Data/Map - Insta-Shield.asm"
		include "Objects/Players/Shields/Object Data/DPLC - Insta-Shield.asm"
