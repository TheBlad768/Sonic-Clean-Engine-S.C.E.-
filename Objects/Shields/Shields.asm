; Elemental Shield DPLC variables
LastLoadedDPLC				= $34
Art_Address					= $38
DPLC_Address		 		= $3C

; =============== S U B R O U T I N E =======================================

Obj_Fire_Shield:
		; Init
		move.l	#Map_FireShield,mappings(a0)
		move.l	#DPLC_FireShield,DPLC_Address(a0)			; Used by PLCLoad_Shields
		move.l	#ArtUnc_FireShield>>1,Art_Address(a0)			; Used by PLCLoad_Shields
		move.b	#4,render_flags(a0)
		move.w	#$80,priority(a0)
		move.b	#$18,width_pixels(a0)
		move.b	#$18,height_pixels(a0)
		move.w	#make_art_tile(ArtTile_Shield,0,0),art_tile(a0)
		move.w	#tiles_to_bytes(ArtTile_Shield),vram_art(a0)	; Used by PLCLoad_Shields
		btst	#7,(Player_1+art_tile).w
		beq.s	loc_195F0
		bset	#7,art_tile(a0)
loc_195F0:	; +
		move.w	#1,anim(a0)				; Clear anim and set prev_anim to 1
		st	LastLoadedDPLC(a0)			; Reset LastLoadedDPLC (used by PLCLoad_Shields)
		move.l	#Obj_Fire_Shield_Main,address(a0)
; loc_19602:
Obj_Fire_Shield_Main:
		lea	(Player_1).w,a2
		btst	#Status_Invincible,status_secondary(a2) ; Is player invincible?
		bne.w	locret_19690				; If so, do not display and do not update variables
		cmpi.b	#$1C,anim(a2)				; Is player in their 'blank' animation?
		beq.w	locret_19690				; If so, do not display and do not update variables
		btst	#Status_Shield,status_secondary(a2) 	; Should the player still have a shield?
		beq.w	Obj_Fire_Shield_Destroy			; If not, change to Insta-Shield
		btst	#Status_Underwater,status(a2)		; Is player underwater?
		bne.s	Obj_Fire_Shield_DestroyUnderwater	; If so, branch
		move.w	x_pos(a2),x_pos(a0)
		move.w	y_pos(a2),y_pos(a0)
		tst.b	anim(a0)				; Is shield in its 'dashing' state?
		bne.s	Obj_Fire_Shield_Display			; If so, do not update orientation or allow changing of the priority art_tile bit
		move.b	status(a2),status(a0)			; Inherit status
		andi.b	#1,status(a0)				; Limit inheritance to 'orientation' bit
		tst.b	(Reverse_gravity_flag).w
		beq.s	.normalgravity
		ori.b	#2,status(a0)				; If in reverse gravity, reverse the vertical mirror render_flag bit (On if Off beforehand and vice versa)
; loc_19654:
.normalgravity:
		andi.w	#drawing_mask,art_tile(a0)
		tst.w	art_tile(a2)
		bpl.s	.nothighpriority
		ori.w	#high_priority,art_tile(a0)
; loc_19666:
.nothighpriority:
Obj_Fire_Shield_Display:
		lea	Ani_FireShield(pc),a1
		bsr.w	Animate_Sprite
		move.w	#$80,priority(a0)		; Layer shield over player sprite
		cmpi.b	#$F,mapping_frame(a0)		; Are these the frames that display in front of the player?
		blo.s	.overplayer			; If so, branch
		move.w	#$200,priority(a0)		; If not, layer shield behind player sprite
; loc_19686:
.overplayer:
		bsr.w	PLCLoad_Shields
		bra.w	Draw_Sprite
; ---------------------------------------------------------------------------
; loc_19692:
Obj_Fire_Shield_DestroyUnderwater:
		andi.b	#$8E,status_secondary(a2)	; Sets Status_Shield, Status_FireShield, Status_LtngShield, and Status_BublShield to 0
		bsr.w	Create_New_Sprite		; Set up for a new object
		bne.s	Obj_Fire_Shield_Destroy		; If that can't happen, branch
		move.l	#Obj_FireShield_Dissipate,address(a1)	; Create dissipate object
		move.w	x_pos(a0),x_pos(a1)		; Put it at shields' x_pos
		move.w	y_pos(a0),y_pos(a1)		; Put it at shields' y_pos

Obj_Fire_Shield_Destroy:
		andi.b	#$8E,status_secondary(a2)	; Sets Status_Shield, Status_FireShield, Status_LtngShield, and Status_BublShield to 0
		move.l	#Obj_Insta_Shield,address(a0)		; Replace the Fire Shield with the Insta-Shield

locret_19690:
		rts
; ---------------------------------------------------------------------------

Obj_Lightning_Shield:
		; init
		; Load Spark art
		QueueStaticDMA ArtUnc_Obj_Lightning_Shield_Sparks,tiles_to_bytes(5),tiles_to_bytes(ArtTile_Shield_Sparks)
		move.l	#Map_LightningShield,mappings(a0)
		move.l	#DPLC_LightningShield,DPLC_Address(a0)			; Used by PLCLoad_Shields
		move.l	#ArtUnc_LightningShield>>1,Art_Address(a0)			; Used by PLCLoad_Shields
		move.b	#4,render_flags(a0)
		move.w	#$80,priority(a0)
		move.b	#$18,width_pixels(a0)
		move.b	#$18,height_pixels(a0)
		move.w	#make_art_tile(ArtTile_Shield,0,0),art_tile(a0)
		move.w	#tiles_to_bytes(ArtTile_Shield),vram_art(a0)	; Used by PLCLoad_Shields
		btst	#7,(Player_1+art_tile).w
		beq.s	.nothighpriority
		bset	#7,art_tile(a0)

.nothighpriority:
		move.w	#1,anim(a0)				; Clear anim and set prev_anim to 1
		st	LastLoadedDPLC(a0)			; Reset LastLoadedDPLC (used by PLCLoad_Shields)
		move.l	#Obj_Lightning_Shield_Main,address(a0)

Obj_Lightning_Shield_Main:
		lea	(Player_1).w,a2
		btst	#Status_Invincible,status_secondary(a2)	; Is player invincible?
		bne.w	locret_197C4				; If so, do not display and do not update variables
		cmpi.b	#$1C,anim(a2)				; Is player in their 'blank' animation?
		beq.w	locret_197C4				; If so, do not display and do not update variables
		btst	#Status_Shield,status_secondary(a2)	; Should the player still have a shield?
		beq.s	Obj_Lightning_Shield_Destroy		; If not, change to Insta-Shield
		btst	#Status_Underwater,status(a2)		; Is player underwater?
		bne.s	Obj_Lightning_Shield_DestroyUnderwater	; If so, branch
		move.w	x_pos(a2),x_pos(a0)
		move.w	y_pos(a2),y_pos(a0)
		move.b	status(a2),status(a0)			; Inherit status
		andi.b	#1,status(a0)				; Limit inheritance to 'orientation' bit
		tst.b	(Reverse_gravity_flag).w
		beq.s	.normalgravity
		ori.b	#2,status(a0)				; If in reverse gravity, reverse the vertical mirror render_flag bit (On if Off beforehand and vice versa)

.normalgravity:
		andi.w	#drawing_mask,art_tile(a0)
		tst.w	art_tile(a2)
		bpl.s	.nothighpriority
		ori.w	#high_priority,art_tile(a0)

.nothighpriority:
		tst.b	anim(a0)				; Is shield in its 'double jump' state?
		beq.s	Obj_Lightning_Shield_Display		; Is not, branch and display
		bsr.s	Obj_Lightning_Shield_Create_Spark	; Create sparks
		clr.b	anim(a0)				; Once done, return to non-'double jump' state

Obj_Lightning_Shield_Display:
		lea	Ani_LightningShield(pc),a1
		bsr.w	Animate_Sprite
		move.w	#$80,priority(a0)			; Layer shield over player sprite
		cmpi.b	#$E,mapping_frame(a0)			; Are these the frames that display in front of the player?
		blo.s	.overplayer				; If so, branch
		move.w	#$200,priority(a0)			; If not, layer shield behind player sprite

.overplayer:
		bsr.w	PLCLoad_Shields
		bra.w	Draw_Sprite
; ---------------------------------------------------------------------------

Obj_Lightning_Shield_DestroyUnderwater:
		tst.w	(Palette_fade_timer).w
		beq.s	Obj_Lightning_Shield_FlashWater

Obj_Lightning_Shield_Destroy:
		andi.b	#$8E,status_secondary(a2)	; Sets Status_Shield, Status_FireShield, Status_LtngShield, and Status_BublShield to 0
		move.l	#Obj_Insta_Shield,address(a0)		; Replace the Lightning Shield with the Insta-Shield

locret_197C4:
		rts
; ---------------------------------------------------------------------------
; LightningShield_FlashWater:
Obj_Lightning_Shield_FlashWater:
		move.l	#Obj_Lightning_Shield_DestroyUnderwater2,address(a0)
		andi.b	#$8E,status_secondary(a2)	; Sets Status_Shield, Status_FireShield, Status_LtngShield, and Status_BublShield to 0

		; Flashes the underwater palette white
		lea	(Water_palette).w,a1
		lea	(Target_water_palette).w,a2
		moveq	#($80/4)-1,d0			; Size of Water_palette/4-1

-		move.l	(a1),(a2)+				; Backup palette entries
		move.l	#$0EEE0EEE,(a1)+		; Overwrite palette entries with white
		dbf	d0,-							; Loop until entire thing is overwritten

		move.b	#3,anim_frame_timer(a0)
		rts

; =============== S U B R O U T I N E =======================================

; LightningShield_Create_Spark:
Obj_Lightning_Shield_Create_Spark:
		moveq	#1,d2
; HyperSonic_Create_Spark:
Obj_Lightning_Shield_Create_Spark_Part2:
		lea	SparkVelocities(pc),a2
		moveq	#4-1,d1

-		bsr.w	Create_New_Sprite		; Find free object slot
		bne.s	locret_19862			; If one can't be found, return
		move.l	#Obj_Lightning_Shield_Spark,address(a1)	; Make new object a Spark
		move.w	x_pos(a0),x_pos(a1)		; (Spark) Inherit x_pos from source object (Lightning Shield, Hyper Sonic Stars)
		move.w	y_pos(a0),y_pos(a1)		; (Spark) Inherit y_pos from source object (Lightning Shield, Hyper Sonic Stars)
		move.l	mappings(a0),mappings(a1)	; (Spark) Inherit mappings from source object (Lightning Shield, Hyper Sonic Stars)
		move.w	art_tile(a0),art_tile(a1)	; (Spark) Inherit art_tile from source object (Lightning Shield, Hyper Sonic Stars)
		move.b	#4,render_flags(a1)
		move.w	#$80,priority(a1)
		move.b	#8,width_pixels(a1)
		move.b	#8,height_pixels(a1)
		move.b	d2,anim(a1)
		move.l	(a2)+,x_vel(a1)			; (Spark) Give x_vel (unique to each of the four Sparks)
		dbf	d1,-

locret_19862:
		rts
; End of function Obj_Lightning_Shield_Create_Spark
; ---------------------------------------------------------------------------

SparkVelocities:
		dc.w  -$200, -$200
		dc.w   $200, -$200
		dc.w  -$200,  $200
		dc.w   $200,  $200
; ---------------------------------------------------------------------------
; Obj_LightningShield_Spark:
Obj_Lightning_Shield_Spark:
		bsr.w	MoveSprite2
		addi.w	#$18,y_vel(a0)
		lea	Ani_LightningShield(pc),a1
		bsr.w	Animate_Sprite
		tst.b	routine(a0)			; Changed by Animate_Sprite
		bne.s	Obj_Lightning_Shield_Spark_Delete
		bra.w	Draw_Sprite
; ---------------------------------------------------------------------------

Obj_Lightning_Shield_Spark_Delete:
		bra.w	Delete_Current_Sprite
; ---------------------------------------------------------------------------
; LightningShield_Destroy:
Obj_Lightning_Shield_DestroyUnderwater2:
		subq.b	#1,anim_frame_timer(a0)		; Is it time to end the white flash?
		bpl.s	locret_198BC			; If not, return
		move.l	#Obj_Insta_Shield,address(a0)		; Replace Lightning Shield with Insta-Shield
		lea	(Target_water_palette).w,a1
		lea	(Water_palette).w,a2
		moveq	#($80/4)-1,d0			; Size of Water_palette/4-1

-		move.l	(a1)+,(a2)+			; Restore backed-up underwater palette
		dbf	d0,-				; Loop until entire thing is restored

locret_198BC:
		rts
; ---------------------------------------------------------------------------

Obj_Bubble_Shield:
		; Init
		move.l	#Map_BubbleShield,mappings(a0)
		move.l	#DPLC_BubbleShield,DPLC_Address(a0)			; Used by PLCLoad_Shields
		move.l	#ArtUnc_BubbleShield>>1,Art_Address(a0)			; Used by PLCLoad_Shields
		move.b	#4,render_flags(a0)
		move.w	#$80,priority(a0)
		move.b	#$18,width_pixels(a0)
		move.b	#$18,height_pixels(a0)
		move.w	#make_art_tile(ArtTile_Shield,0,0),art_tile(a0)
		move.w	#tiles_to_bytes(ArtTile_Shield),vram_art(a0)	; Used by PLCLoad_Shields
		btst	#7,(Player_1+art_tile).w
		beq.s	.nothighpriority
		bset	#7,art_tile(a0)

.nothighpriority:
		move.w	#1,anim(a0)				; Clear anim and set prev_anim to 1
		st	LastLoadedDPLC(a0)			; Reset LastLoadedDPLC (used by PLCLoad_Shields)
		lea	(Player_1).w,a1
		bsr.w	Player_ResetAirTimer
		move.l	#Obj_Bubble_Shield_Main,address(a0)

Obj_Bubble_Shield_Main:
		lea	(Player_1).w,a2
		btst	#Status_Invincible,status_secondary(a2)	; Is player invincible?
		bne.s	locret_1998A				; If so, do not display and do not update variables
		cmpi.b	#$1C,anim(a2)				; Is player in their 'blank' animation?
		beq.s	locret_1998A				; If so, do not display and do not update variables
		btst	#Status_Shield,status_secondary(a2)	; Should the player still have a shield?
		beq.s	Obj_Bubble_Shield_Destroy		; If not, change to Insta-Shield
		move.w	x_pos(a2),x_pos(a0)
		move.w	y_pos(a2),y_pos(a0)
		move.b	status(a2),status(a0)			; Inherit status
		andi.b	#1,status(a0)				; Limit inheritance to 'orientation' bit
		tst.b	(Reverse_gravity_flag).w
		beq.s	.normalgravity
		ori.b	#2,status(a0)				; Reverse the vertical mirror render_flag bit (On if Off beforehand and vice versa)

.normalgravity:
		andi.w	#drawing_mask,art_tile(a0)
		tst.w	art_tile(a2)
		bpl.s	.nothighpriority
		ori.w	#high_priority,art_tile(a0)

.nothighpriority:
;Obj_Bubble_Shield_Display:
		lea	Ani_BubbleShield(pc),a1
		bsr.w	Animate_Sprite
		bsr.w	PLCLoad_Shields
		bra.w	Draw_Sprite
; ---------------------------------------------------------------------------

Obj_Bubble_Shield_Destroy:
		andi.b	#$8E,status_secondary(a2)			; Sets Status_Shield, Status_FireShield, Status_LtngShield, and Status_BublShield to 0
		move.l	#Obj_Insta_Shield,address(a0)		; Replace the Bubble Shield with the Insta-Shield

locret_1998A:
		rts

; =============== S U B R O U T I N E =======================================

Obj_Insta_Shield:
		; Init
		move.l	#Map_InstaShield,mappings(a0)
		move.l	#DPLC_InstaShield,DPLC_Address(a0)			; Used by PLCLoad_Shields
		move.l	#ArtUnc_InstaShield>>1,Art_Address(a0)			; Used by PLCLoad_Shields
		move.b	#4,render_flags(a0)
		move.w	#$80,priority(a0)
		move.b	#$18,width_pixels(a0)
		move.b	#$18,height_pixels(a0)
		move.w	#make_art_tile(ArtTile_Shield,0,0),art_tile(a0)
		move.w	#tiles_to_bytes(ArtTile_Shield),vram_art(a0)	; Used by PLCLoad_Shields
		btst	#7,(Player_1+art_tile).w
		beq.s	.nothighpriority
		bset	#7,art_tile(a0)

.nothighpriority:
		move.w	#1,anim(a0)					; Clear anim and set prev_anim to 1
		st	LastLoadedDPLC(a0)				; Reset LastLoadedDPLC (used by PLCLoad_Shields)
		move.l	#Obj_Insta_Shield_Main,address(a0)

Obj_Insta_Shield_Main:
		lea	(Player_1).w,a2
		btst	#Status_Invincible,status_secondary(a2) ; Is the player invincible?
		bne.s	locret_1998A					; If so, return
		move.w	x_pos(a2),x_pos(a0)			; Inherit player's x_pos
		move.w	y_pos(a2),y_pos(a0)			; Inherit player's y_pos
		move.b	status(a2),status(a0)			; Inherit status
		andi.b	#1,status(a0)					; Limit inheritance to 'orientation' bit
		tst.b	(Reverse_gravity_flag).w
		beq.s	.normalgravity
		ori.b	#2,status(a0)					; Reverse the vertical mirror render_flag bit (On if Off beforehand and vice versa)

.normalgravity:
		andi.w	#drawing_mask,art_tile(a0)
		tst.w	art_tile(a2)
		bpl.s	.nothighpriority
		ori.w	#high_priority,art_tile(a0)

.nothighpriority:
;Obj_Insta_Shield_Display:
		lea	Ani_InstaShield(pc),a1
		bsr.w	Animate_Sprite
		cmpi.b	#7,mapping_frame(a0)		; Has it reached then end of its animation?
		bne.s	.notover						; If not, branch
		tst.b	double_jump_flag(a2)				; Is it in its attacking state?
		beq.s	.notover						; If not, branch
		move.b	#2,double_jump_flag(a2)		; Mark attack as over

.notover:
		tst.b	mapping_frame(a0)				; Is this the first frame?
		beq.s	.loadnewDPLC				; If so, branch and load the DPLC for this and the next few frames
		cmpi.b	#3,mapping_frame(a0)		; Is this the third frame?
		bne.s	.skipDPLC					; If not, branch as we don't need to load another DPLC yet

.loadnewDPLC:
		bsr.s	PLCLoad_Shields

.skipDPLC:
		bra.w	Draw_Sprite

; =============== S U B R O U T I N E =======================================

PLCLoad_Shields:
		moveq	#0,d0
		move.b	mapping_frame(a0),d0
		cmp.b	LastLoadedDPLC(a0),d0
		beq.s	PLCLoad_Shields_Return
		move.b	d0,LastLoadedDPLC(a0)
		movea.l	DPLC_Address(a0),a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		move.w	(a2)+,d5
		subq.w	#1,d5
		bmi.s	PLCLoad_Shields_Return
		move.w	vram_art(a0),d4

PLCLoad_Shields_ReadEntry:
		moveq	#0,d1
		move.w	(a2)+,d1
		move.w	d1,d3
		lsr.w	#8,d3
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1
		lsl.l	#4,d1
		add.l	Art_Address(a0),d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr	(Add_To_DMA_Queue).w
		dbf	d5,PLCLoad_Shields_ReadEntry

PLCLoad_Shields_Return:
		rts

; =============== S U B R O U T I N E =======================================

Obj_Invincibility:
		QueueStaticDMA ArtUnc_Invincibility,tiles_to_bytes($20),tiles_to_bytes(ArtTile_Shield)
		moveq	#0,d2
		lea	off_187DE-6(pc),a2
		lea	address(a0),a1
		moveq	#4-1,d1

loc_1880E:
		move.l	#Obj_188E8,address(a1)
		move.l	#Map_Invincibility,mappings(a1)
		move.w	#make_art_tile(ArtTile_Shield,0,0),art_tile(a1)
		move.w	#$80,priority(a1)
		move.b	#4,render_flags(a1)
		bset	#6,render_flags(a1)
		move.b	#32/2,width_pixels(a1)
		move.w	#2,mainspr_childsprites(a1)
		move.b	d2,$36(a1)
		addq.w	#1,d2
		move.l	(a2)+,$30(a1)
		move.w	(a2)+,$34(a1)
		lea	next_object(a1),a1
		dbf	d1,loc_1880E
		move.l	#loc_18868,address(a0)
		move.b	#4,$34(a0)

loc_18868:
		lea	(Player_1).w,a1
		btst	#1,status_secondary(a1)
		beq.w	Delete_Current_Sprite
		move.w	x_pos(a1),d0
		move.w	d0,x_pos(a0)
		move.w	y_pos(a1),d1
		move.w	d1,y_pos(a0)
		lea	sub2_x_pos(a0),a2
		lea	byte_189E0(pc),a3
		moveq	#0,d5

loc_188A0:
		move.w	$38(a0),d2
		move.b	(a3,d2.w),d5
		bpl.s	loc_188B0
		clr.w	$38(a0)
		bra.s	loc_188A0
; ---------------------------------------------------------------------------

loc_188B0:
		addq.w	#1,$38(a0)
		lea	word_189A0(pc),a6
		move.b	$34(a0),d6
		bsr.w	sub_1898A
		move.w	d2,(a2)+
		move.w	d3,(a2)+
		move.w	d5,(a2)+
		addi.w	#$20,d6
		bsr.w	sub_1898A
		move.w	d2,(a2)+
		move.w	d3,(a2)+
		move.w	d5,(a2)+
		moveq	#$12,d0
		btst	#0,status(a1)
		beq.s	loc_188E0
		neg.w	d0

loc_188E0:
		add.b	d0,$34(a0)
		bra.w	Draw_Sprite

; =============== S U B R O U T I N E =======================================

Obj_188E8:
		lea	(Player_1).w,a1
		btst	#1,status_secondary(a1)
		beq.w	Delete_Current_Sprite
		lea	(Pos_table_index).w,a5
		lea	(Pos_table).w,a6
		move.b	$36(a0),d1
		lsl.b	#2,d1
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
		movea.l	$30(a0),a3

loc_18936:
		move.w	$38(a0),d2
		move.b	(a3,d2.w),d5
		bpl.s	loc_18946
		clr.w	$38(a0)
		bra.s	loc_18936
; ---------------------------------------------------------------------------

loc_18946:
		swap	d5
		add.b	$35(a0),d2
		move.b	(a3,d2.w),d5
		addq.w	#1,$38(a0)
		lea	word_189A0(pc),a6
		move.b	$34(a0),d6
		bsr.s	sub_1898A
		move.w	d2,(a2)+
		move.w	d3,(a2)+
		move.w	d5,(a2)+
		addi.w	#$20,d6
		swap	d5
		bsr.s	sub_1898A
		move.w	d2,(a2)+
		move.w	d3,(a2)+
		move.w	d5,(a2)+
		moveq	#2,d0
		btst	#0,status(a1)
		beq.s	loc_18982
		neg.w	d0

loc_18982:
		add.b	d0,$34(a0)
		bra.w	Draw_Sprite

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
; End of function sub_1898A
; ---------------------------------------------------------------------------

off_187DE:
		dc.l byte_189ED
		dc.w $B
		dc.l byte_18A02
		dc.w $160D
		dc.l byte_18A1B
		dc.w $2C0D
word_189A0:
		dc.w   $F00,  $F03,  $E06,  $D08,  $B0B,  $80D,	 $60E,	$30F,	$10, $FC0F, $F90E, $F70D, $F40B, $F208,	$F106, $F003
		dc.w  $F000, $F0FC, $F1F9, $F2F7, $F4F4, $F7F2,	$F9F1, $FCF0, $FFF0,  $3F0,  $6F1,  $8F2,  $BF4,  $DF7,	 $EF9,	$FFC
byte_189E0:
		dc.b	8,   5,	  7,   6,   6,	 7,   5,   8,	6,   7,	  7,   6, $FF
byte_189ED:
		dc.b    8,   7,   6,   5,   4,   3,   4,   5,   6,   7, $FF,   3,   4,   5,   6,   7,   8,   7,   6,   5
		dc.b    4
byte_18A02:
		dc.b    8,   7,   6,   5,   4,   3,   2,   3,   4,   5,   6,   7, $FF,   2,   3,   4,   5,   6,   7,   8
		dc.b    7,   6,   5,   4,   3
byte_18A1B:
		dc.b    7,   6,   5,   4,   3,   2,   1,   2,   3,   4,   5,   6, $FF,   1,   2,   3,   4,   5,   6,   7
		dc.b    6,   5,   4,   3,   2
; ---------------------------------------------------------------------------

		include "Objects/Shields/Object Data/Map - Invincibility.asm"
		include "Objects/Shields/Object Data/Anim - Fire Shield.asm"
		include "Objects/Shields/Object Data/Map - Fire Shield.asm"
		include "Objects/Shields/Object Data/DPLC - Fire Shield.asm"
		include "Objects/Shields/Object Data/Anim - Lightning Shield.asm"
		include "Objects/Shields/Object Data/Map - Lightning Shield.asm"
		include "Objects/Shields/Object Data/DPLC - Lightning Shield.asm"
		include "Objects/Shields/Object Data/Anim - Bubble Shield.asm"
		include "Objects/Shields/Object Data/Map - Bubble Shield.asm"
		include "Objects/Shields/Object Data/DPLC - Bubble Shield.asm"
		include "Objects/Shields/Object Data/Anim - Insta-Shield.asm"
		include "Objects/Shields/Object Data/Map - Insta-Shield.asm"
		include "Objects/Shields/Object Data/DPLC - Insta-Shield.asm"