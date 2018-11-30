
; =============== S U B R O U T I N E =======================================

Obj_Ring:
		moveq	#0,d0
		move.b	routine(a0),d0
		move.w	Ring_Index(pc,d0.w),d1
		jmp	Ring_Index(pc,d1.w)
; ---------------------------------------------------------------------------

Ring_Index: offsetTable
		offsetTableEntry.w Obj_RingInit			; 0
		offsetTableEntry.w Obj_RingAnimate	; 2
		offsetTableEntry.w Obj_RingCollect		; 4
		offsetTableEntry.w Obj_RingSparkle		; 6
		offsetTableEntry.w Obj_RingDelete		; 8
; ---------------------------------------------------------------------------

Obj_RingInit:
		addq.b	#2,routine(a0)
		move.l	#Map_Ring,mappings(a0)
		move.w	#make_art_tile(ArtTile_ArtNem_Ring,1,1),art_tile(a0)
		move.b	#4,render_flags(a0)
		move.w	#$100,priority(a0)
		move.b	#$47,collision_flags(a0)
		move.b	#8,width_pixels(a0)

Obj_RingAnimate:
		move.b	(Rings_frame).w,mapping_frame(a0)
		bra.w	RememberState_Collision
; ---------------------------------------------------------------------------

Obj_RingCollect:
		addq.b	#2,routine(a0)
		move.b	#0,collision_flags(a0)
		move.w	#$80,priority(a0)
		bsr.s	GiveRing

Obj_RingSparkle:
		lea	Ani_RingSparkle(pc),a1
		bsr.w	Animate_Sprite
		bra.w	Draw_Sprite
; ---------------------------------------------------------------------------

Obj_RingDelete:
		bra.w	Delete_Current_Sprite

; =============== S U B R O U T I N E =======================================

GiveRing:
CollectRing:
		addq.w	#1,(v_rings).w		; add 1 to rings
		ori.b	#1,(f_ringcount).w		; update the rings counter
		move.w	#sfx_Ring,d0			; play ring sound
		jmp	(PlaySound_Special).l
; End of function GiveRing

; =============== S U B R O U T I N E =======================================

Obj_Bouncing_Ring:
		moveq	#0,d0
		move.b	5(a0),d0
		move.w	off_1A658(pc,d0.w),d1
		jmp	off_1A658(pc,d1.w)
; ---------------------------------------------------------------------------

off_1A658: offsetTable
		offsetTableEntry.w loc_1A67A
		offsetTableEntry.w loc_1A75C
		offsetTableEntry.w loc_1A7C2
		offsetTableEntry.w loc_1A7D6
		offsetTableEntry.w loc_1A7E4
; ---------------------------------------------------------------------------

Obj_Bouncing_Ring_Reverse_Gravity:
		moveq	#0,d0
		move.b	5(a0),d0
		move.w	off_1A670(pc,d0.w),d1
		jmp	off_1A670(pc,d1.w)
; ---------------------------------------------------------------------------

off_1A670: offsetTable
		offsetTableEntry.w loc_1A67A
		offsetTableEntry.w loc_1A7E8
		offsetTableEntry.w loc_1A7C2
		offsetTableEntry.w loc_1A7D6
		offsetTableEntry.w loc_1A7E4
; ---------------------------------------------------------------------------

loc_1A67A:
		move.l	#Obj_Bouncing_Ring,d6
		tst.b	(Reverse_gravity_flag).w
		beq.s	loc_1A68C
		move.l	#Obj_Bouncing_Ring_Reverse_Gravity,d6

loc_1A68C:
		movea.l	a0,a1
		moveq	#0,d5
		move.w	(Ring_count).w,d5
		moveq	#$20,d0
		cmp.w	d0,d5
		blo.s		loc_1A6A6
		move.w	d0,d5

loc_1A6A6:
		subq.w	#1,d5
		move.w	#$288,d4
		bra.s	loc_1A6B6
; ---------------------------------------------------------------------------

loc_1A6AE:
		bsr.w	Create_New_Sprite3
		bne.w	loc_1A738

loc_1A6B6:
		move.l	d6,(a1)
		addq.b	#2,5(a1)
		move.b	#8,$1E(a1)
		move.b	#8,$1F(a1)
		move.w	$10(a0),$10(a1)
		move.w	$14(a0),$14(a1)
		move.l	#Map_Ring,$C(a1)
		move.w	#make_art_tile(ArtTile_ArtNem_Ring,1,1),art_tile(a1)
		move.b	#$84,4(a1)
		move.w	#$180,8(a1)
		move.b	#$47,$28(a1)
		move.b	#8,7(a1)
		move.b	#-1,(Ring_spill_anim_counter).w
		tst.w	d4
		bmi.s	loc_1A728
		move.w	d4,d0
		jsr	(GetSineCosine).l
		move.w	d4,d2
		lsr.w	#8,d2
		asl.w	d2,d0
		asl.w	d2,d1
		move.w	d0,d2
		move.w	d1,d3
		addi.b	#$10,d4
		bcc.s	loc_1A728
		subi.w	#$80,d4
		bcc.s	loc_1A728
		move.w	#$288,d4

loc_1A728:
		move.w	d2,$18(a1)
		move.w	d3,$1A(a1)
		neg.w	d2
		neg.w	d4
		dbf	d5,loc_1A6AE

loc_1A738:
		sfx	sfx_RingLoss,0,0,0	; play ring loss sound
		move.w	#0,(Ring_count).w
		move.b	#$80,(Update_HUD_ring_count).w
		tst.b	(Reverse_gravity_flag).w
		bne.w	loc_1A7E8

loc_1A75C:
		move.b	(Ring_spill_anim_frame).w,$22(a0)
		bsr.w	MoveSprite2
		addi.w	#$18,$1A(a0)
		bmi.s	loc_1A7B0
		move.b	(V_int_run_count+3).w,d0
		add.b	d7,d0
		andi.b	#7,d0
		bne.s	loc_1A7B0
		tst.b	4(a0)
		bpl.s	loc_1A79C
		jsr	(RingCheckFloorDist).l
		tst.w	d1
		bpl.s	loc_1A79C
		add.w	d1,$14(a0)
		move.w	$1A(a0),d0
		asr.w	#2,d0
		sub.w	d0,$1A(a0)
		neg.w	$1A(a0)

loc_1A79C:
		tst.b	(Ring_spill_anim_counter).w
		beq.s	loc_1A7E4
		move.w	(Camera_max_Y_pos).w,d0
		addi.w	#$E0,d0
		cmp.w	$14(a0),d0
		blo.s	loc_1A7E4

loc_1A7B0:
		jsr	(Add_SpriteToCollisionResponseList).l
		bra.w	Draw_Sprite
; ---------------------------------------------------------------------------

loc_1A7C2:
		addq.b	#2,5(a0)
		move.b	#0,$28(a0)
		move.w	#$80,8(a0)
		bsr.w	GiveRing

loc_1A7D6:
		lea	Ani_RingSparkle(pc),a1
		bsr.w	Animate_Sprite
		bra.w	Draw_Sprite
; ---------------------------------------------------------------------------

loc_1A7E4:
		bra.w	Delete_Current_Sprite
; ---------------------------------------------------------------------------

loc_1A7E8:
		move.b	(Ring_spill_anim_frame).w,$22(a0)
		bsr.w	MoveSprite_TestGravity2
		addi.w	#$18,$1A(a0)
		bmi.s	loc_1A83C
		move.b	(V_int_run_count+3).w,d0
		add.b	d7,d0
		andi.b	#7,d0
		bne.s	loc_1A83C
		tst.b	4(a0)
		bpl.s	loc_1A828
		jsr	(sub_FCA0).l
		tst.w	d1
		bpl.s	loc_1A828
		sub.w	d1,$14(a0)
		move.w	$1A(a0),d0
		asr.w	#2,d0
		sub.w	d0,$1A(a0)
		neg.w	$1A(a0)

loc_1A828:
		tst.b	(Ring_spill_anim_counter).w
		beq.s	loc_1A7E4
		move.w	(Camera_max_Y_pos).w,d0
		addi.w	#$E0,d0
		cmp.w	$14(a0),d0
		blo.s		loc_1A7E4

loc_1A83C:
		jsr	(Add_SpriteToCollisionResponseList).l
		bra.w	Draw_Sprite
; ---------------------------------------------------------------------------

Obj_Attracted_Ring:
		; init
		move.l	#Map_Ring,mappings(a0)
		move.w	#make_art_tile(ArtTile_ArtNem_Ring,1,1),art_tile(a0)
		move.b	#4,render_flags(a0)
		move.w	#$100,priority(a0)
		move.b	#$47,collision_flags(a0)
		move.b	#8,width_pixels(a0)
		move.b	#8,height_pixels(a0)
		move.b	#8,y_radius(a0)
		move.b	#8,x_radius(a0)
		move.l	#loc_1A88C,(a0)

loc_1A88C:
		tst.b	5(a0)
		bne.s	AttractedRing_GiveRing
		bsr.w	AttractedRing_Move
		btst	#Status_LtngShield,(Player_1+status_secondary).w	; Does player still have a lightning shield?
		bne.s	Obj_Attracted_RingAnimate
		move.l	#Obj_Bouncing_Ring,(a0)						; If not, change object
		move.b	#2,5(a0)
		move.b	#-1,(Ring_spill_anim_counter).w

Obj_Attracted_RingAnimate:
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	loc_1A8C6
		move.b	#3,anim_frame_timer(a0)
		addq.b	#1,mapping_frame(a0)
		andi.b	#3,mapping_frame(a0)

loc_1A8C6:
		move.w	x_pos(a0),d0
		andi.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse_back).w,d0
		cmpi.w	#$280,d0
		bhi.w	loc_1A8E4
		jsr	(Add_SpriteToCollisionResponseList).l
		bra.w	Draw_Sprite
; ---------------------------------------------------------------------------

loc_1A8E4:
		move.w	respawn_addr(a0),d0
		beq.s	loc_1A8F0
		movea.w	d0,a2
		bclr	#7,(a2)

loc_1A8F0:
		move.w	($30).w,d0
		beq.s	loc_1A8FC
		movea.w	d0,a2
		move.w	#0,(a2)

loc_1A8FC:
		bra.w	Delete_Current_Sprite
; ---------------------------------------------------------------------------

AttractedRing_GiveRing:
		move.b	#0,collision_flags(a0)
		move.w	#$80,priority(a0)
		bsr.w	GiveRing
		move.l	#loc_1A920,(a0)
		move.b	#0,5(a0)

loc_1A920:
		tst.b	5(a0)
		bne.s	loc_1A934
		lea	Ani_RingSparkle(pc),a1
		bsr.w	Animate_Sprite
		bra.w	Draw_Sprite
; ---------------------------------------------------------------------------

loc_1A934:
		bra.w	Delete_Current_Sprite

; =============== S U B R O U T I N E =======================================

AttractedRing_Move:
		; Move on X axis
		move.w	#$30,d1
		move.w	(Player_1+x_pos).w,d0
		cmp.w	x_pos(a0),d0
		bhs.s	AttractedRing_MoveRight	; If ring is to the left of the player, branch

;AttractedRing_MoveLeft:
		neg.w	d1
		tst.w	x_vel(a0)
		bmi.s	AttractedRing_ApplyMovementX
		add.w	d1,d1
		add.w	d1,d1
		bra.s	AttractedRing_ApplyMovementX
; ---------------------------------------------------------------------------

AttractedRing_MoveRight:
		tst.w	x_vel(a0)
		bpl.s	AttractedRing_ApplyMovementX
		add.w	d1,d1
		add.w	d1,d1

AttractedRing_ApplyMovementX:
		add.w	d1,x_vel(a0)
		; Move on Y axis
		move.w	#$30,d1
		move.w	(Player_1+y_pos).w,d0
		cmp.w	y_pos(a0),d0
		bhs.s	AttractedRing_MoveUp	; If ring is below the player, branch

;AttractedRing_MoveDown:
		neg.w	d1
		tst.w	y_vel(a0)
		bmi.s	AttractedRing_ApplyMovementY
		add.w	d1,d1
		add.w	d1,d1
		bra.s	AttractedRing_ApplyMovementY
; ---------------------------------------------------------------------------

AttractedRing_MoveUp:
		tst.w	y_vel(a0)
		bpl.s	AttractedRing_ApplyMovementY
		add.w	d1,d1
		add.w	d1,d1

AttractedRing_ApplyMovementY:
		add.w	d1,y_vel(a0)
		jmp	(MoveSprite2).l
; End of function AttractedRing_Move
; ---------------------------------------------------------------------------

		include	"Objects/Rings/Object Data/Anim - Rings.asm"
		include	"Objects/Rings/Object Data/Map - Rings.asm"