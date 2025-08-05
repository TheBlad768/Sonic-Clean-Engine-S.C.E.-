; ---------------------------------------------------------------------------
; Ring (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_Ring:

		; init
		movem.l	ObjDat_Ring(pc),d0-d3						; copy data to d0-d3
		movem.l	d0-d3,address(a0)						; set data from d0-d3 to current object
		move.b	#7|collision_flags.npc.item,collision_flags(a0)			; set ring collision

		; draw
		jmp	(Sprite_OnScreen_Test_Collision).w

; =============== S U B R O U T I N E =======================================

Obj_Ring_Collect:

		; init
		move.l	#Map_Ring,mappings(a0)
		move.b	#setBit(render_flags.level),render_flags(a0)			; use screen coordinates
		move.l	#.sparkle,address(a0)
		move.w	#priority_1,priority(a0)
		jsr	(GiveRing).w

.sparkle

		; wait
		subq.b	#1,anim_frame_timer(a0)						; decrement timer
		bpl.s	.draw								; if time remains, branch
		addq.b	#5+1,anim_frame_timer(a0)					; reset timer to 5 frames

		; next frame
		addq.b	#1,mapping_frame(a0)
		cmpi.b	#5,mapping_frame(a0)
		beq.s	.delete

.draw
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.delete
		jmp	(Delete_Current_Sprite).w

; ---------------------------------------------------------------------------
; Bouncing ring (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_Bouncing_Ring:
		move.l	#Obj_Bouncing_Ring_Normal,d6
		tst.b	(Reverse_gravity_flag).w
		beq.s	.notgrav
		move.l	#Obj_Bouncing_Ring_TestGravity,d6

.notgrav
		move.w	(Ring_count).w,d5
		moveq	#32,d0								; max rings
		cmp.w	d0,d5
		blo.s	.notmax
		move.w	d0,d5								; set max rings

.notmax
		subq.w	#1,d5								; fix dbf

		; get RAM slot
		getobjectRAMslot a2

		; load ring data
		movea.w	a0,a1								; load current object to a1
		lea	ObjDat3_BouncingRing(pc),a3					; load ring data
		lea	Rings_Velocity(pc),a2
		tst.b	(Water_flag).w							; does level have water?
		beq.s	.load								; if not, branch
		move.w	(Water_level).w,d1
		cmp.w	y_pos(a0),d1							; is ring above the water?
		bge.s	.load								; if yes, branch
		lea	Rings_WaterVelocity(pc),a2
		bra.s	.load
; ---------------------------------------------------------------------------

.create

		; create bouncing ring object

.find
		lea	next_object(a1),a1						; goto next object RAM slot
		tst.l	address(a1)							; is object RAM slot empty?
		dbeq	d0,.find							; if not, branch
		bne.s	.notfree							; branch, if object RAM slot is not empty
		subq.w	#1,d0								; dbeq didn't subtract sprite table so we'll do it ourselves

		; load object
		move.w	x_pos(a0),x_pos(a1)
		move.w	y_pos(a0),y_pos(a1)

.load
		move.l	d6,address(a1)							; set object address
		movem.l	(a3),d2-d4							; load ring data
		movem.l	d2-d4,render_flags(a1)						; set ring data
		move.b	#7|collision_flags.npc.item,collision_flags(a1)
		move.w	height_pixels(a1),y_radius(a1)					; set y_radius and x_radius
		move.l	(a2)+,x_vel(a1)
		tst.w	d0								; object RAM slots ended?
		dbmi	d5,.create							; if not, loop

.notfree
		sfx	sfx_RingLoss							; play ring loss sound
		st	(Ring_spill_anim_counter).w					; set time
		clr.w	(Ring_count).w
		move.b	#$80,(Update_HUD_ring_count).w

		; check gravity
		tst.b	(Reverse_gravity_flag).w
		bne.w	Obj_Bouncing_Ring_TestGravity

; =============== S U B R O U T I N E =======================================

Obj_Bouncing_Ring_Normal:
		MoveSprite2 a0

		; check speed
		moveq	#$18,d1								; normal speed
		tst.b	(Water_flag).w							; does level have water?
		beq.s	.check								; if not, branch
		move.w	(Water_level).w,d0
		cmp.w	y_pos(a0),d0							; is ring above the water?
		bge.s	.check								; if yes, branch
		moveq	#$A,d1								; water speed

.check
		add.w	d1,y_vel(a0)
		bmi.s	.main
		move.b	(V_int_run_count+3).w,d0
		add.b	d7,d0								; d7 - object count (Process_Sprites)
		andi.b	#7,d0
		bne.s	.main
		tst.b	render_flags(a0)						; object visible on the screen?
		bpl.s	.chkdel								; if not, branch

		; check shield
		btst	#status_secondary.lightning_shield,(Player_1+status_secondary).w	; does Sonic have a Lightning Shield?
		beq.s	.notshield							; if not, branch
		move.l	#Obj_Attracted_Ring.main,address(a0)

.notshield

		; check floor
		move.w	x_pos(a0),d3
		move.w	y_pos(a0),d2
		move.b	y_radius(a0),d0
		ext.w	d0
		add.w	d0,d2
		lea	(Primary_Angle).w,a4
		clr.b	(a4)
		lea	($10).w,a3
		moveq	#0,d6
		moveq	#$C,d5
		jsr	(Ring_FindFloor).w
		tst.w	d1
		bpl.s	.chkdel
		add.w	d1,y_pos(a0)
		move.w	y_vel(a0),d0
		asr.w	#2,d0
		sub.w	d0,y_vel(a0)
		neg.w	y_vel(a0)

.chkdel
		tst.b	(Ring_spill_anim_counter).w
		beq.s	.delete
		move.w	(Camera_max_Y_pos).w,d0
		addi.w	#224,d0
		cmp.w	y_pos(a0),d0
		blo.s	.delete

.main
		move.w	(Level_repeat_offset).w,d0
		sub.w	d0,x_pos(a0)
		Add_SpriteToCollisionResponseList a1
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.delete
		jmp	(Delete_Current_Sprite).w

; =============== S U B R O U T I N E =======================================

Obj_Bouncing_Ring_TestGravity:

		; move sprite
		movem.w	x_vel(a0),d0/d2							; load xy speed
		tst.b	(Reverse_gravity_flag).w
		beq.s	.notgrav
		neg.l	d2								; reverse y speed

.notgrav
		asl.l	#8,d0								; shift velocity to line up with the middle 16 bits of the 32-bit position
		asl.l	#8,d2								; shift velocity to line up with the middle 16 bits of the 32-bit position
		add.l	d0,x_pos(a0)							; add to x-axis position ; note this affects the subpixel position x_sub(a0) = 2+x_pos(a0)
		add.l	d2,y_pos(a0)							; add to y-axis position ; note this affects the subpixel position y_sub(a0) = 2+y_pos(a0)

		; check speed
		moveq	#$18,d1								; normal speed
		tst.b	(Water_flag).w							; does level have water?
		beq.s	.check								; if not, branch
		move.w	(Water_level).w,d0
		cmp.w	y_pos(a0),d0							; is ring above the water?
		bge.s	.check								; if yes, branch
		moveq	#$A,d1								; water speed

.check
		add.w	d1,y_vel(a0)
		bmi.s	.main
		move.b	(V_int_run_count+3).w,d0
		add.b	d7,d0								; d7 - object count (Process_Sprites)
		andi.b	#7,d0
		bne.s	.main
		tst.b	render_flags(a0)						; object visible on the screen?
		bpl.s	.chkdel								; if not, branch

		; check shield
		btst	#status_secondary.lightning_shield,(Player_1+status_secondary).w	; does Sonic have a Lightning Shield?
		beq.s	.notshield							; if not, branch
		move.l	#Obj_Attracted_Ring.main,address(a0)

.notshield

		; check floor
		move.w	x_pos(a0),d3
		move.w	y_pos(a0),d2
		move.b	y_radius(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		lea	(Primary_Angle).w,a4
		clr.b	(a4)
		lea	(-$10).w,a3
		move.w	#$800,d6
		moveq	#$C,d5
		jsr	(Ring_FindFloor).w
		tst.w	d1
		bpl.s	.chkdel
		sub.w	d1,y_pos(a0)
		move.w	y_vel(a0),d0
		asr.w	#2,d0
		sub.w	d0,y_vel(a0)
		neg.w	y_vel(a0)

.chkdel
		tst.b	(Ring_spill_anim_counter).w
		beq.s	.delete
		move.w	(Camera_max_Y_pos).w,d0
		addi.w	#224,d0
		cmp.w	y_pos(a0),d0
		blo.s	.delete

.main
		move.w	(Level_repeat_offset).w,d0
		sub.w	d0,x_pos(a0)
		Add_SpriteToCollisionResponseList a1
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.delete
		jmp	(Delete_Current_Sprite).w

; ---------------------------------------------------------------------------
; Attracted ring (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_Attracted_Ring:

		; init
		movem.l	ObjDat_Ring2(pc),d0-d3						; copy data to d0-d3
		movem.l	d0-d3,address(a0)						; set data from d0-d3 to current object
		move.b	#7|collision_flags.npc.item,collision_flags(a0)			; set ring collision
		move.w	height_pixels(a0),y_radius(a0)					; set y_radius and x_radius

.main

		; move on x axis
		moveq	#48,d1
		move.w	(Player_1+x_pos).w,d0
		cmp.w	x_pos(a0),d0
		bge.s	.moveright							; if ring is to the left of the player, branch

		; move left
		neg.w	d1
		tst.w	x_vel(a0)
		bmi.s	.applymovementx
		add.w	d1,d1
		add.w	d1,d1
		bra.s	.applymovementx
; ---------------------------------------------------------------------------

.moveright
		tst.w	x_vel(a0)
		bpl.s	.applymovementx
		add.w	d1,d1
		add.w	d1,d1

.applymovementx
		add.w	d1,x_vel(a0)

		; move on y axis
		moveq	#48,d1
		move.w	(Player_1+y_pos).w,d0
		cmp.w	y_pos(a0),d0
		bge.s	.moveup								; if ring is below the player, branch

		; move down
		neg.w	d1
		tst.w	y_vel(a0)
		bmi.s	.applymovementy
		add.w	d1,d1
		add.w	d1,d1
		bra.s	.applymovementy
; ---------------------------------------------------------------------------

.moveup
		tst.w	y_vel(a0)
		bpl.s	.applymovementy
		add.w	d1,d1
		add.w	d1,d1

.applymovementy
		add.w	d1,y_vel(a0)
		MoveSprite2 a0

		; check shield
		btst	#status_secondary.lightning_shield,(Player_1+status_secondary).w	; does player still have a lightning shield?
		bne.s	.chkdel								; if yes, branch

		; set bouncing
		st	(Ring_spill_anim_counter).w					; set time
		move.l	#Obj_Bouncing_Ring_Normal,address(a0)
		tst.b	(Reverse_gravity_flag).w
		beq.s	.chkdel
		move.l	#Obj_Bouncing_Ring_TestGravity,address(a0)

.chkdel
		out_of_xrange.s	.offscreen
		Add_SpriteToCollisionResponseList a1
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.offscreen
		move.w	respawn_addr(a0),d0						; get address in respawn table
		beq.s	.offscreen2							; if it's zero, it isn't remembered
		movea.w	d0,a2								; load address into a2
		bclr	#7,(a2)

.offscreen2
		move.w	objoff_30(a0),d0						; load ring RAM address
		beq.s	.delete
		movea.w	d0,a2
		clr.w	(a2)

.delete
		jmp	(Delete_Current_Sprite).w

; =============== S U B R O U T I N E =======================================

; mapping
ObjDat_Ring:			subObjMainData \
				Sprite_OnScreen_Test_Collision, \
					setBit(render_flags.level) | \
					setBit(render_flags.static_mappings), \
				0, 16, 16, 2, ArtTile_Ring, 1, 1, Map_Ring_10+2

ObjDat_Ring2:			subObjMainData \
				Obj_Attracted_Ring.main, \
					setBit(render_flags.level) | \
					setBit(render_flags.static_mappings), \
				0, 16, 16, 2, ArtTile_Ring, 1, 1, Map_Ring_10+2

ObjDat3_BouncingRing:		subObjMainData \
				FALSE, \
					setBit(render_flags.level) | \
					setBit(render_flags.static_mappings) | \
					setBit(render_flags.on_screen), \
				0, 16, 16, 3, ArtTile_Ring, 1, 1, Map_Ring_10+2
; ---------------------------------------------------------------------------

Rings_Velocity:

		; xvel, yvel (normal)
		dc.w -$C4, -$3EC	; 1
		dc.w $C4, -$3EC		; 2
		dc.w -$238, -$350	; 3
		dc.w $238, -$350	; 4
		dc.w -$350, -$238	; 5
		dc.w $350, -$238	; 6
		dc.w -$3EC, -$C4	; 7
		dc.w $3EC, -$C4		; 8
		dc.w -$3EC, $C4		; 9
		dc.w $3EC, $C4		; 10
		dc.w -$350, $238	; 11
		dc.w $350, $238		; 12
		dc.w -$238, $350	; 13
		dc.w $238, $350		; 14
		dc.w -$C4, $3EC		; 15
		dc.w $C4, $3EC		; 16
		dc.w -$62, -$1F6	; 17
		dc.w $62, -$1F6		; 18
		dc.w -$11C, -$1A8	; 19
		dc.w $11C, -$1A8	; 20
		dc.w -$1A8, -$11C	; 21
		dc.w $1A8, -$11C	; 22
		dc.w -$1F6, -$62	; 23
		dc.w $1F6, -$62		; 24
		dc.w -$1F6, $62		; 25
		dc.w $1F6, $62		; 26
		dc.w -$1A8, $11C	; 27
		dc.w $1A8, $11C		; 28
		dc.w -$11C, $1A8	; 29
		dc.w $11C, $1A8		; 30
		dc.w -$62, $1F6		; 31
		dc.w $62, $1F6		; 32

Rings_WaterVelocity:

		; xvel, yvel (water)
		dc.w -$64, -$1F8	; 1
		dc.w $64, -$1F8		; 2
		dc.w -$11C, -$1A8	; 3
		dc.w $11C, -$1A8	; 4
		dc.w -$1A8, -$11C	; 5
		dc.w $1A8, -$11C	; 6
		dc.w -$1F8, -$64	; 7
		dc.w $1F8, -$64		; 8
		dc.w -$1F8, $60		; 9
		dc.w $1F8, $60		; 10
		dc.w -$1A8, $11C	; 11
		dc.w $1A8, $11C		; 12
		dc.w -$11C, $1A8	; 13
		dc.w $11C, $1A8		; 14
		dc.w -$64, $1F4		; 15
		dc.w $64, $1F4		; 16
		dc.w -$32, -$FC		; 17
		dc.w $32, -$FC		; 18
		dc.w -$8E, -$D4		; 19
		dc.w $8E, -$D4		; 20
		dc.w -$D4, -$8E		; 21
		dc.w $D4, -$8E		; 22
		dc.w -$FC, -$32		; 23
		dc.w $FC, -$32		; 24
		dc.w -$FC, $30		; 25
		dc.w $FC, $30		; 26
		dc.w -$D4, $8E		; 27
		dc.w $D4, $8E		; 28
		dc.w -$8E, $D4		; 29
		dc.w $8E, $D4		; 30
		dc.w -$32, $FA		; 31
		dc.w $32, $FA		; 32
; ---------------------------------------------------------------------------

		include "Objects/Main/Rings/Object Data/Map - Rings.asm"
