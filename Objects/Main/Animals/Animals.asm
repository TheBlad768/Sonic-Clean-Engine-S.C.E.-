; ---------------------------------------------------------------------------
; Animal (Object)
; ---------------------------------------------------------------------------

; Dynamic object variables
animal_ground_x_vel				= objoff_30	; .w
animal_ground_y_vel				= objoff_32	; .w
animal_ground_pointer				= objoff_34	; .l

;						= objoff_3E	; .w

; =============== S U B R O U T I N E =======================================

		; this table declares what animals will appear in the zone
		; when an enemy is destroyed, a random animal is chosen from the 2 selected animals
		; note: you must also load the corresponding art in the PLCs

Obj_Animal_ZoneAnimals:
		zoneAnimals.b Flicky, Chicken	; DEZ

		zonewarning Obj_Animal_ZoneAnimals,(1*2)

; ---------------------------------------------------------------------------

		; this table declares the speed and mappings of each animal

Obj_Animal_Properties:
Rabbit:		objanimaldecl Map_Animals5, Obj_Animal_Walk, -$200, -$400	; 0
Chicken:	objanimaldecl Map_Animals1, Obj_Animal_Fly, -$200, -$300	; 1
Penguin:	objanimaldecl Map_Animals5, Obj_Animal_Walk, -$180, -$300	; 2
Seal:		objanimaldecl Map_Animals4, Obj_Animal_Walk, -$140, -$180	; 3
Pig:		objanimaldecl Map_Animals3, Obj_Animal_Walk, -$1C0, -$300	; 4
Flicky:		objanimaldecl Map_Animals1, Obj_Animal_Fly, -$300, -$400	; 5
Squirrel:	objanimaldecl Map_Animals2, Obj_Animal_Walk, -$280, -$380	; 6

; =============== S U B R O U T I N E =======================================

Obj_Animal:

		; init
		jsr	(Random_Number).w
		move.w	#make_art_tile($580,0,0),d1					; animal 1 (VRAM)
		andi.w	#1,d0
		beq.s	.rskip
		move.w	#make_art_tile($592,0,0),d1					; animal 2 (VRAM)

.rskip
		move.w	d1,art_tile(a0)
		moveq	#0,d1
		move.b	(Current_zone).w,d1
		add.w	d1,d1
		add.w	d0,d1
		lea	Obj_Animal_ZoneAnimals(pc),a1
		move.b	(a1,d1.w),d0
		lea	Obj_Animal_Properties(pc),a1					; $C size data
		adda.w	d0,a1
		move.l	(a1)+,mappings(a0)
		move.l	(a1)+,animal_ground_pointer(a0)
		move.l	(a1),animal_ground_x_vel(a0)

		move.b	#( \
			setBit(render_flags.level) | \
			setBit(status.npc.x_flip) \
		),render_flags(a0)

		move.l	#bytes_word_to_long(24/2,16/2,priority_6),height_pixels(a0)	; set height, width and priority
		move.b	#24/2,y_radius(a0)						; set y_radius
		move.b	#2,mapping_frame(a0)
		move.b	#7,anim_frame_timer(a0)
		move.w	#-$400,y_vel(a0)
		move.l	#.main,address(a0)						; Go to "Obj_Animal_Main"

		; draw score
		lea	Child6_EndSignScore(pc),a2
		jsr	(CreateChild6_Simple).w
		bne.s	.draw
		move.w	objoff_3E(a0),d0
		lsr.w	d0								; division by 2
		move.b	d0,mapping_frame(a1)
		bra.s	.draw
; ---------------------------------------------------------------------------

.main
		tst.b	render_flags(a0)						; object visible on the screen?
		bpl.s	.delete								; if not, branch
		MoveSprite a0
		tst.w	y_vel(a0)
		bmi.s	.draw
		jsr	(ObjCheckFloorDist).w
		tst.w	d1
		bpl.s	.draw
		add.w	d1,y_pos(a0)
		move.l	animal_ground_x_vel(a0),x_vel(a0)
		move.l	animal_ground_pointer(a0),address(a0)
		move.b	#1,mapping_frame(a0)

.draw
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.delete
		jmp	(Delete_Current_Sprite).w

; =============== S U B R O U T I N E =======================================

Obj_Animal_Walk:
		MoveSprite a0
		move.b	#1,mapping_frame(a0)
		tst.w	y_vel(a0)
		bmi.s	.notfloor
		clr.b	mapping_frame(a0)
		jsr	(ObjCheckFloorDist).w
		tst.w	d1
		bpl.s	.notfloor
		add.w	d1,y_pos(a0)
		move.w	animal_ground_y_vel(a0),y_vel(a0)

.notfloor
		tst.b	render_flags(a0)						; object visible on the screen?
		bpl.s	Obj_Animal.delete						; if not, branch
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

Obj_Animal_Fly:
		MoveSprite a0, $18
		tst.w	y_vel(a0)
		bmi.s	.anim
		jsr	(ObjCheckFloorDist).w
		tst.w	d1
		bpl.s	.anim
		add.w	d1,y_pos(a0)
		move.w	animal_ground_y_vel(a0),y_vel(a0)

.anim
		subq.b	#1,anim_frame_timer(a0)						; decrement timer
		bpl.s	.skipanim							; if time remains, branch
		addq.b	#1+1,anim_frame_timer(a0)					; reset timer to 1 frames
		bchg	#0,mapping_frame(a0)						; change frame

.skipanim
		tst.b	render_flags(a0)						; object visible on the screen?
		bpl.w	Obj_Animal.delete						; if not, branch
		jmp	(Draw_Sprite).w

; ---------------------------------------------------------------------------
; Animal Ending (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_Animal_Ending:

		; these are the S1 ending actions
		moveq	#0,d0
		move.b	subtype(a0),d0
		lsl.w	#4,d0								; multiply by $10
		lea	Animal_Ending_Index(pc,d0.w),a1					; $E size data
		move.l	(a1)+,address(a0)						; Go to "NEXT"
		move.l	(a1)+,mappings(a0)
		move.w	(a1)+,art_tile(a0)
		move.l	(a1),x_vel(a0)							; load horizontal and vertical speed
		move.l	(a1),animal_ground_x_vel(a0)					; copy horizontal and vertical speed

		move.b	#( \
			setBit(render_flags.level) | \
			setBit(status.npc.x_flip) \
		),render_flags(a0)

		move.l	#bytes_word_to_long(24/2,16/2,priority_6),height_pixels(a0)	; set height, width and priority
		move.b	#24/2,y_radius(a0)						; set y_radius
		move.b	#7,anim_frame_timer(a0)
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

		; these are the S1 ending actions

Animal_Ending_Index:

		; the following tables tell the properties of animals based on their subtype
		objanimalending Obj_Animal_FlickyWait, Map_Animals1, make_art_tile($5A5,0,0), -$440, -$400	; 0 ($F) (Blue Flicky)
		objanimalending Obj_Animal_FlickyWait, Map_Animals1, make_art_tile($5A5,0,0), -$440, -$400	; 1 ($10) (Blue Flicky)
		objanimalending Obj_Animal_FlickyJump, Map_Animals1, make_art_tile($5A5,0,0), -$440, -$400	; 2 ($11) (Blue Flicky)
		objanimalending Obj_Animal_RabbitWait, Map_Animals5, make_art_tile($553,0,0), -$300, -$400	; 3 ($12) (Rabbit)
		objanimalending Obj_Animal_LandJump, Map_Animals5, make_art_tile($553,0,0), -$300, -$400	; 4 ($13) (Rabbit)
		objanimalending Obj_Animal_SingleBounce, Map_Animals5, make_art_tile($573,0,0), -$180, -$300	; 5 ($14) (Penguin)
		objanimalending Obj_Animal_LandJump, Map_Animals5, make_art_tile($573,0,0), -$180, -$300	; 6 ($15) (Penguin)
		objanimalending Obj_Animal_SingleBounce, Map_Animals4, make_art_tile($585,0,0), -$140, -$180	; 7 ($16) (Seal)
		objanimalending Obj_Animal_LandJump, Map_Animals3, make_art_tile($593,0,0), -$1C0, -$300	; 8 ($17) (Pig)
		objanimalending Obj_Animal_FlyBounce, Map_Animals1, make_art_tile($565,0,0), -$200, -$300	; 9 ($18) (Chicken)
		objanimalending Obj_Animal_DoubleBounce, Map_Animals2, make_art_tile($5B3,0,0), -$280, -$380	; A ($19) (Squirrel)

; =============== S U B R O U T I N E =======================================

Obj_Animal_FlickyWait:
		jsr	(Find_SonicObject).w
		cmpi.w	#(320/2)+24,d2							; is Sonic within $B8 pixels (x-axis)?
		bhs.s	.chkdel								; if not, branch
		move.l	animal_ground_x_vel(a0),x_vel(a0)
		move.l	#.fly,address(a0)

.fly
		MoveSprite a0, $18
		tst.w	y_vel(a0)
		bmi.s	.anim
		jsr	(ObjCheckFloorDist).w
		tst.w	d1
		bpl.s	.anim
		add.w	d1,y_pos(a0)
		move.w	animal_ground_y_vel(a0),y_vel(a0)
		tst.b	subtype(a0)
		beq.s	.anim
		neg.w	x_vel(a0)
		bchg	#render_flags.x_flip,render_flags(a0)

.anim
		subq.b	#1,anim_frame_timer(a0)						; decrement timer
		bpl.s	.chkdel								; if time remains, branch
		addq.b	#1+1,anim_frame_timer(a0)					; reset timer to 1 frames
		bchg	#0,mapping_frame(a0)						; change frame

.chkdel
		bra.w	Obj_Animal_ChkDel

; =============== S U B R O U T I N E =======================================

Obj_Animal_FlickyJump:
		jsr	(Find_SonicObject).w
		cmpi.w	#(320/2)+24,d2							; is Sonic within $B8 pixels (x-axis)?
		bhs.s	.chkdel								; if not, branch
		clr.w	x_vel(a0)
		clr.w	animal_ground_x_vel(a0)
		move.l	#.jump,address(a0)

.jump
		MoveSprite a0, $18
		bsr.w	Obj_Animal_Jump
		jsr	(Find_SonicObject).w
		jsr	(Change_FlipX2).w

		; anim
		subq.b	#1,anim_frame_timer(a0)						; decrement timer
		bpl.s	.chkdel								; if time remains, branch
		addq.b	#1+1,anim_frame_timer(a0)					; reset timer to 1 frames
		bchg	#0,mapping_frame(a0)						; change frame

.chkdel
		bra.w	Obj_Animal_ChkDel

; =============== S U B R O U T I N E =======================================

Obj_Animal_RabbitWait:
		jsr	(Find_SonicObject).w
		cmpi.w	#(320/2)+24,d2							; is Sonic within $B8 pixels (x-axis)?
		bhs.s	.chkdel								; if not, branch
		move.l	animal_ground_x_vel(a0),x_vel(a0)
		move.l	#.walk,address(a0)

.walk
		MoveSprite a0
		move.b	#1,mapping_frame(a0)
		tst.w	y_vel(a0)
		bmi.s	.chkdel
		clr.b	mapping_frame(a0)
		jsr	(ObjCheckFloorDist).w
		tst.w	d1
		bpl.s	.chkdel
		add.w	d1,y_pos(a0)
		move.w	animal_ground_y_vel(a0),y_vel(a0)

.chkdel
		bra.w	Obj_Animal_ChkDel

; =============== S U B R O U T I N E =======================================

Obj_Animal_DoubleBounce:
		MoveSprite a0
		move.b	#1,mapping_frame(a0)
		tst.w	y_vel(a0)
		bmi.s	.chkdel
		clr.b	mapping_frame(a0)
		jsr	(ObjCheckFloorDist).w
		tst.w	d1
		bpl.s	.chkdel
		not.b	subtype+1(a0)
		bne.s	.chg
		neg.w	x_vel(a0)
		bchg	#render_flags.x_flip,render_flags(a0)

.chg
		add.w	d1,y_pos(a0)
		move.w	animal_ground_y_vel(a0),y_vel(a0)

.chkdel
		bra.w	Obj_Animal_ChkDel

; =============== S U B R O U T I N E =======================================

Obj_Animal_LandJump:
		jsr	(Find_SonicObject).w
		cmpi.w	#(320/2)+24,d2							; is Sonic within $B8 pixels (x-axis)?
		bhs.s	.chkdel								; if not, branch
		clr.w	x_vel(a0)
		clr.w	animal_ground_x_vel(a0)
		move.l	#.jump,address(a0)

.jump
		MoveSprite a0
		bsr.w	Obj_Animal_Jump
		jsr	(Find_SonicObject).w
		jsr	(Change_FlipX2).w

.chkdel
		bra.w	Obj_Animal_ChkDel

; =============== S U B R O U T I N E =======================================

Obj_Animal_SingleBounce:
		jsr	(Find_SonicObject).w
		cmpi.w	#(320/2)+24,d2							; is Sonic within $B8 pixels (x-axis)?
		bhs.s	.chkdel								; if not, branch
		move.l	#.bounce,address(a0)

.bounce
		MoveSprite a0
		move.b	#1,mapping_frame(a0)
		tst.w	y_vel(a0)
		bmi.s	.chkdel
		clr.b	mapping_frame(a0)
		jsr	(ObjCheckFloorDist).w
		tst.w	d1
		bpl.s	.chkdel
		neg.w	x_vel(a0)
		bchg	#render_flags.x_flip,render_flags(a0)
		add.w	d1,y_pos(a0)
		move.w	animal_ground_y_vel(a0),y_vel(a0)

.chkdel
		bra.s	Obj_Animal_ChkDel

; =============== S U B R O U T I N E =======================================

Obj_Animal_FlyBounce:
		jsr	(Find_SonicObject).w
		cmpi.w	#(320/2)+24,d2							; is Sonic within $B8 pixels (x-axis)?
		bhs.s	Obj_Animal_ChkDel						; if not, branch
		move.l	#.bounce,address(a0)

.bounce
		MoveSprite a0, $18
		tst.w	y_vel(a0)
		bmi.s	.anim
		jsr	(ObjCheckFloorDist).w
		tst.w	d1
		bpl.s	.anim
		not.b	subtype+1(a0)
		bne.s	.chg
		neg.w	x_vel(a0)
		bchg	#render_flags.x_flip,render_flags(a0)

.chg
		add.w	d1,y_pos(a0)
		move.w	animal_ground_y_vel(a0),y_vel(a0)

.anim
		subq.b	#1,anim_frame_timer(a0)						; decrement timer
		bpl.s	Obj_Animal_ChkDel						; if time remains, branch
		addq.b	#1+1,anim_frame_timer(a0)					; reset timer to 1 frames
		bchg	#0,mapping_frame(a0)						; change frame

; =============== S U B R O U T I N E =======================================

Obj_Animal_ChkDel:
		move.w	x_pos(a0),d0
		sub.w	(Player_1+x_pos).w,d0
		blo.s	.draw
		subi.w	#(512/2)+128,d0
		bpl.s	.draw
		tst.b	render_flags(a0)						; object visible on the screen?
		bpl.s	.offscreen							; if not, branch

.draw
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.offscreen
		move.w	respawn_addr(a0),d0						; get address in respawn table
		beq.s	.delete								; if it's zero, it isn't remembered
		movea.w	d0,a2								; load address into a2
		bclr	#7,(a2)

.delete
		jmp	(Delete_Current_Sprite).w

; =============== S U B R O U T I N E =======================================

Obj_Animal_Jump:
		move.b	#1,mapping_frame(a0)
		tst.w	y_vel(a0)
		bmi.s	.return
		clr.b	mapping_frame(a0)
		jsr	(ObjCheckFloorDist).w
		tst.w	d1
		bpl.s	.return
		add.w	d1,y_pos(a0)
		move.w	animal_ground_y_vel(a0),y_vel(a0)

.return
		rts
; ---------------------------------------------------------------------------

		include "Objects/Main/Animals/Object Data/Map - Animals 1.asm"
		include "Objects/Main/Animals/Object Data/Map - Animals 2.asm"
		include "Objects/Main/Animals/Object Data/Map - Animals 3.asm"
		include "Objects/Main/Animals/Object Data/Map - Animals 4.asm"
		include "Objects/Main/Animals/Object Data/Map - Animals 5.asm"
