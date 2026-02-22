; ---------------------------------------------------------------------------
; Shields (Object)
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
; Fire Shield
; ---------------------------------------------------------------------------

; dynamic object variables

; =============== S U B R O U T I N E =======================================

Obj_FireShield:

		; init
		movem.l	ObjDat_FireShield(pc),d0-d3					; copy data to d0-d3
		movem.l	d0-d3,address(a0)						; set data from d0-d3 to current object

		; check priority
		btst	#high_priority_bit,(Player_1+art_tile).w			; is Sonic has high priority?
		beq.s	.nothighpriority						; if not, branch
		bset	#high_priority_bit,art_tile(a0)					; high priority

.nothighpriority
		move.w	#1,anim(a0)							; clear anim and set prev anim to 1
		st	ros_prev_frame(a0)						; reset DPLC prev frame (used by Perform_DPLC)

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

		; draw
		lea	PLCPtr_FireShield(pc),a2
		jsr	(Perform_DPLC).w
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.destroyunderwater
		jsr	(Create_New_Object).w						; set up for a new object
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

; dynamic object variables

; =============== S U B R O U T I N E =======================================

Obj_LightningShield:

.artsize	:= (ArtUnc_LightningShield_Sparks_end-ArtUnc_LightningShield_Sparks)&$FFFF

		; load spark art
		QueueStaticDMA ArtUnc_LightningShield_Sparks,.artsize,tiles_to_bytes(ArtTile_Shield_Sparks)

		; init
		movem.l	ObjDat_LightningShield(pc),d0-d3				; copy data to d0-d3
		movem.l	d0-d3,address(a0)						; set data from d0-d3 to current object

		; check priority
		btst	#high_priority_bit,(Player_1+art_tile).w			; is Sonic has high priority?
		beq.s	.nothighpriority						; if not, branch
		bset	#high_priority_bit,art_tile(a0)					; high priority

.nothighpriority
		move.w	#1,anim(a0)							; clear anim and set prev anim to 1
		st	ros_prev_frame(a0)						; reset DPLC prev frame (used by Perform_DPLC)

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

		; draw
		lea	PLCPtr_LightningShield(pc),a2
		jsr	(Perform_DPLC).w
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
		jsr	(Create_New_Object).w						; find free object slot
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
		jsr	(Create_New_Object_4).w						; find next free object slot
		dbne	d1,.loop

.return
		rts

; ---------------------------------------------------------------------------
; Lightning Shield (Spark)
; ---------------------------------------------------------------------------

; dynamic object variables

; =============== S U B R O U T I N E =======================================

Obj_LightningShield_Spark:
		MoveSprite , $18
		lea	Ani_LightningShield(pc),a1
		jsr	(Animate_Sprite).w
		tst.b	routine(a0)							; changed by Animate_Sprite
		bne.s	.delete
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.delete
		jmp	(Delete_Current_Object).w

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

; dynamic object variables

; =============== S U B R O U T I N E =======================================

Obj_BubbleShield:

		; init
		movem.l	ObjDat_BubbleShield(pc),d0-d3					; copy data to d0-d3
		movem.l	d0-d3,address(a0)						; set data from d0-d3 to current object

		; check priority
		btst	#high_priority_bit,(Player_1+art_tile).w			; is Sonic has high priority?
		beq.s	.nothighpriority						; if not, branch
		bset	#high_priority_bit,art_tile(a0)					; high priority

.nothighpriority
		move.w	#1,anim(a0)							; clear anim and set prev_anim to 1
		st	ros_prev_frame(a0)						; reset DPLC prev frame (used by Perform_DPLC)
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

		; draw
		lea	PLCPtr_BubbleShield(pc),a2
		jsr	(Perform_DPLC).w
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

; dynamic object variables

; =============== S U B R O U T I N E =======================================

Obj_InstaShield:

		; init
		movem.l	ObjDat_InstaShield(pc),d0-d3					; copy data to d0-d3
		movem.l	d0-d3,address(a0)						; set data from d0-d3 to current object

		; check priority
		btst	#high_priority_bit,(Player_1+art_tile).w			; is Sonic has high priority?
		beq.s	.nothighpriority						; if not, branch
		bset	#high_priority_bit,art_tile(a0)					; high priority

.nothighpriority
		move.w	#1,anim(a0)							; clear anim and set prev anim to 1
		st	ros_prev_frame(a0)						; reset DPLC prev frame (used by Perform_DPLC)

.main
		lea	(Player_1).w,a2							; a2=character
		btst	#status_secondary.invincible,status_secondary(a2)		; is the player invincible?
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
		bne.s	.draw								; if not, branch as we don't need to load another DPLC yet

.loadnewdplc

		; dplc
		lea	PLCPtr_InstaShield(pc),a2
		jsr	(Perform_DPLC).w

.draw
		jmp	(Draw_Sprite).w

; ---------------------------------------------------------------------------
; Invincibility
; ---------------------------------------------------------------------------

; dynamic object variables

	dsset aniraw_ptr								; pretend we're in the RAM

invincibility			= *

.anim_ptr			ds.l 1							; (4 bytes)
.offset				ds.b 1							; (1 byte)
.offset2			ds.b 1							; (1 byte)
.index				ds.b 1							; (1 byte)
				ds.b 1							; (1 byte)
.frame				ds.w 1							; (2 bytes)

	dsreset										; stop pretending and reset the program counter

; =============== S U B R O U T I N E =======================================

Obj_Invincibility:

.artsize	:= (ArtUnc_Invincibility_end-ArtUnc_Invincibility)&$FFFF

		; load invincibility art
		QueueStaticDMA ArtUnc_Invincibility,.artsize,tiles_to_bytes(ArtTile_Shield)

		; init
		moveq	#0,d2
		lea	Child_Invincibility_Index-6(pc),a2
		lea	(a0),a1
		moveq	#4-1,d1

.loop
		movem.l	ObjDat_Invincibility(pc),d0/d3-d5				; copy data to d0/d3-d5
		movem.l	d0/d3-d5,address(a1)						; set data from d0/d3-d5 to current object
		move.w	#2,mainspr_childsprites(a1)					; set number of child sprites
		move.b	d2,invincibility.index(a1)
		move.l	(a2)+,invincibility.anim_ptr(a1)
		move.w	(a2)+,invincibility.offset(a1)					; set offset 1 and offset 2
		lea	next_object(a1),a1
		addq.w	#1,d2
		dbf	d1,.loop
		move.l	#.main,address(a0)
		move.b	#4,invincibility.offset(a0)

.main

		; check
		lea	(Player_1).w,a1							; a1=character
		btst	#status_secondary.invincible,status_secondary(a1)		; should the player still have a invincible?
		beq.s	.delete								; if not, delete

		; set
		move.w	x_pos(a1),d0
		move.w	d0,x_pos(a0)
		move.w	y_pos(a1),d1
		move.w	d1,y_pos(a0)
		lea	sub2_x_pos(a0),a2
		lea	Invincibility_AnimData00(pc),a3					; load mapping frames
		moveq	#0,d5

.run
		move.w	invincibility.frame(a0),d2					; load current frame number
		move.b	(a3,d2.w),d5							; read mapping frame from script
		bpl.s	.next								; if animation is not complete, branch

		; repeat animation from beginning
		clr.w	invincibility.frame(a0)						; restart the animation
		bra.s	.run
; ---------------------------------------------------------------------------

.next
		addq.w	#1,invincibility.frame(a0)					; next frame number
		lea	Invincibility_XYOffsetData(pc),a6				; load x offset, y offset
		move.b	invincibility.offset(a0),d6
		bsr.w	Invincibility_GetXYOffset
		move.w	d2,(a2)+							; sub2_x_pos
		move.w	d3,(a2)+							; sub2_y_pos
		move.w	d5,(a2)+							; sub2_mapframe
		addi.w	#2*$10,d6							; next
		bsr.w	Invincibility_GetXYOffset
		move.w	d2,(a2)+							; sub3_x_pos
		move.w	d3,(a2)+							; sub3_y_pos
		move.w	d5,(a2)+							; sub3_mapframe

		; check xflip
		moveq	#2*9,d0
		btst	#status.player.x_flip,status(a1)
		beq.s	.notxflip
		neg.w	d0

.notxflip
		add.b	d0,invincibility.offset(a0)
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.delete
		jmp	(Delete_Current_Object).w

; ---------------------------------------------------------------------------
; Invincibility (Child)
; ---------------------------------------------------------------------------

; dynamic object variables

; =============== S U B R O U T I N E =======================================

Obj_Invincibility_Child:

		; check
		lea	(Player_1).w,a1							; a1=character
		btst	#status_secondary.invincible,status_secondary(a1)		; should the player still have a invincible?
		beq.s	Obj_Invincibility.delete					; if not, delete

		; calc
		lea	(Pos_table_index).w,a5
		lea	(Pos_table).w,a6
		moveq	#0,d1
		move.b	invincibility.index(a0),d1
		add.b	d1,d1								; multiply by 12
		add.b	d1,d1
		move.w	d1,d2
		add.w	d1,d1
		add.w	d2,d1
		move.w	(a5),d0
		sub.b	d1,d0
		lea	(a6,d0.w),a2

		; set
		move.w	(a2)+,d0
		move.w	(a2)+,d1
		move.w	d0,x_pos(a0)
		move.w	d1,y_pos(a0)
		lea	sub2_x_pos(a0),a2
		movea.l	invincibility.anim_ptr(a0),a3					; load mapping frames
		moveq	#0,d5

.run
		move.w	invincibility.frame(a0),d2					; load current frame number
		move.b	(a3,d2.w),d5							; read mapping frame from script
		bpl.s	.next								; if animation is not complete, branch

		; repeat animation from beginning
		clr.w	invincibility.frame(a0)						; restart the animation
		bra.s	.run
; ---------------------------------------------------------------------------

.next
		swap	d5
		add.b	invincibility.offset2(a0),d2
		move.b	(a3,d2.w),d5
		addq.w	#1,invincibility.frame(a0)					; next frame number
		lea	Invincibility_XYOffsetData(pc),a6				; load x offset, y offset
		move.b	invincibility.offset(a0),d6
		bsr.s	Invincibility_GetXYOffset
		move.w	d2,(a2)+							; sub2_x_pos
		move.w	d3,(a2)+							; sub2_y_pos
		move.w	d5,(a2)+							; sub2_mapframe
		addi.w	#2*$10,d6							; next
		swap	d5
		bsr.s	Invincibility_GetXYOffset
		move.w	d2,(a2)+							; sub3_x_pos
		move.w	d3,(a2)+							; sub3_y_pos
		move.w	d5,(a2)+							; sub3_mapframe

		; check xflip
		moveq	#2*1,d0
		btst	#status.player.x_flip,status(a1)
		beq.s	.notxflip
		neg.w	d0

.notxflip
		add.b	d0,invincibility.offset(a0)
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

Invincibility_GetXYOffset:
		andi.w	#$3E,d6
		move.b	(a6,d6.w),d2							; get x offset
		move.b	1(a6,d6.w),d3							; get y offset
		ext.w	d2								; sign extension
		ext.w	d3								; sign extension
		add.w	d0,d2								; add to xpos
		add.w	d1,d3								; add to ypos
		rts
; ---------------------------------------------------------------------------

Child_Invincibility_Index:
		dc.l Invincibility_AnimData01						; 1 (animation script)
		dc.b 0, 11								; offset 1, offset 2
		dc.l Invincibility_AnimData02						; 2 (animation script)
		dc.b 11*2, 13								; offset 1, offset 2
		dc.l Invincibility_AnimData03						; 3 (animation script)
		dc.b 22*2, 13								; offset 1, offset 2

Invincibility_XYOffsetData:
		dc.b 15, 0	; x offset, y offset
		dc.b 15, 3
		dc.b 14, 6
		dc.b 13, 8
		dc.b 11, 11
		dc.b 8, 13
		dc.b 6, 14
		dc.b 3, 15
		dc.b 0, 16
		dc.b -4, 15
		dc.b -7, 14
		dc.b -9, 13
		dc.b -12, 11
		dc.b -14, 8
		dc.b -15, 6
		dc.b -16, 3
		dc.b -16, 0
		dc.b -16, -4
		dc.b -15, -7
		dc.b -14, -9
		dc.b -12, -12
		dc.b -9, -14
		dc.b -7, -15
		dc.b -4, -16
		dc.b -1, -16
		dc.b 3, -16
		dc.b 6, -15
		dc.b 8, -14
		dc.b 11, -12
		dc.b 13, -9
		dc.b 14, -7
		dc.b 15, -4
Invincibility_AnimData00:
		dc.b 8, 5, 7, 6, 6, 7, 5, 8, 6, 7, 7, 6, $FF
Invincibility_AnimData01:
		dc.b 8, 7, 6, 5, 4, 3, 4, 5, 6, 7, $FF
		dc.b 3, 4, 5, 6, 7, 8, 7, 6, 5, 4
Invincibility_AnimData02:
		dc.b 8, 7, 6, 5, 4, 3, 2, 3, 4, 5, 6, 7, $FF
		dc.b 2, 3, 4, 5, 6, 7, 8, 7, 6, 5, 4, 3
Invincibility_AnimData03:
		dc.b 7, 6, 5, 4, 3, 2, 1, 2, 3, 4, 5, 6, $FF
		dc.b 1, 2, 3, 4, 5, 6, 7, 6, 5, 4, 3, 2
	even

; =============== S U B R O U T I N E =======================================

; init
ObjDat_FireShield:		subObjMainData \
				Obj_FireShield.main, \
					setBit(render_flags.level), \
				0, 48, 48, 1, ArtTile_Shield, 0, FALSE, Map_FireShield

ObjDat_LightningShield:		subObjMainData \
				Obj_LightningShield.main, \
					setBit(render_flags.level), \
				0, 48, 48, 1, ArtTile_Shield, 0, FALSE, Map_LightningShield

ObjDat_BubbleShield:		subObjMainData \
				Obj_BubbleShield.main, \
					setBit(render_flags.level), \
				0, 48, 48, 1, ArtTile_Shield, 0, FALSE, Map_BubbleShield

ObjDat_InstaShield:		subObjMainData \
				Obj_InstaShield.main, \
					setBit(render_flags.level), \
				0, 48, 48, 1, ArtTile_Shield, 0, FALSE, Map_InstaShield

ObjDat_Invincibility:		subObjMainData \
				Obj_Invincibility_Child, \
					setBit(render_flags.level) | \
					setBit(render_flags.multi_sprite), \
				0, 32, 32, 1, ArtTile_Shield, 0, FALSE, Map_Invincibility

; dplc
PLCPtr_FireShield:		DPLCEntry ArtUnc_FireShield, DPLC_FireShield
PLCPtr_LightningShield:		DPLCEntry ArtUnc_LightningShield, DPLC_LightningShield
PLCPtr_BubbleShield:		DPLCEntry ArtUnc_BubbleShield, DPLC_BubbleShield
PLCPtr_InstaShield:		DPLCEntry ArtUnc_InstaShield, DPLC_InstaShield
; ---------------------------------------------------------------------------

		; mappings
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
