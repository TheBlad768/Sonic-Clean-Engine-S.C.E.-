; ---------------------------------------------------------------------------
; Egg Capsule (Object)
; ---------------------------------------------------------------------------

; Dynamic object variables
ecap_timer				= objoff_2E	; .w

ecap_jump				= objoff_34	; .l
ecap_status				= objoff_38	; .b
ecap_speed				= objoff_3A	; .w ; flipped only

; Functions (objoff_38 status)
ecap_button				= 1		; bit
ecap_tailspos				= 7		; bit

; =============== S U B R O U T I N E =======================================

Obj_EggCapsule_Flying:
		bset	#render_flags.y_flip,render_flags(a0)				; set flipy flag

Obj_EggCapsule:

		; load art
		lea	PLC_EggCapsule(pc),a5
		jsr	(LoadPLC_Raw_KosPlusM).w

		; init
		lea	ObjDat_EggCapsule(pc),a1
		jsr	(SetUp_ObjAttributes).w
		move.l	#.main,address(a0)

		; check
		btst	#render_flags.y_flip,render_flags(a0)				; is egg capsule flipped?
		bne.s	.flipy								; if yes, branch
		move.l	#.normal,objoff_34(a0)

		; create object
		lea	Child1_EggCapsule_Button(pc),a2
		jsr	(CreateChild1_Normal).w

		; next
		bra.s	.main
; ---------------------------------------------------------------------------

.flipy

		; set xypos
		move.w	(Camera_X_pos).w,d0
		addi.w	#320/2,d0
		move.w	d0,x_pos(a0)
		moveq	#128/2,d0
		add.w	(Camera_Y_pos).w,d0
		move.w	d0,y_pos(a0)
		move.l	#.flipped,objoff_34(a0)
		move.w	#1,objoff_3A(a0)
		jsr	(Swing_Setup1).w

		; create button object
		lea	Child1_EggCapsule_FlippedButton(pc),a2
		jsr	(CreateChild1_Normal).w

		; create propellers objects
		lea	Child1_EggCapsule_Propeller(pc),a2
		jsr	(CreateChild1_Normal).w

.main
		movea.l	objoff_34(a0),a1
		move.w	x_pos(a0),-(sp)
		jsr	(a1)

		; solid
		moveq	#(64/2)+$B,d1							; width
		moveq	#48/2,d2							; height
		moveq	#(48/2)+1,d3							; height+1
		move.w	(sp)+,d4
		jsr	(SolidObjectFull).w

		; draw
		jmp	(Draw_Sprite).w

; ---------------------------------------------------------------------------
; Egg Capsule (Normal)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

.normal
		btst	#1,objoff_38(a0)						; is button pressed?
		beq.s	.return								; if not, branch
		move.l	#.sonicendpose,objoff_34(a0)

.open
		move.b	#1,mapping_frame(a0)						; set empty egg capsule frame
		move.w	#$40,objoff_2E(a0)						; wait

		; create pieces objects
		lea	Child1_EggCapsule_Pieces(pc),a2
		jsr	(CreateChild1_Normal).w

		; create animals objects
		lea	Child1_EggCapsule_Animals(pc),a2
		jsr	(CreateChild1_Normal).w

		; create explosion object
		lea	Child6_CreateBossExplosion(pc),a2
		jsr	(CreateChild6_Simple).w
		bne.s	.return
		move.b	#8,subtype(a1)

.return
		rts

; =============== S U B R O U T I N E =======================================

.sonicendpose
		tst.b	(Boss_flag).w							; boss is defeated?
		bne.s	.return								; if not, branch
		move.l	#.tailsendpose,d0
		bra.w	Check_SonicEndPose
; ---------------------------------------------------------------------------

.tailsendpose
		rts

; ---------------------------------------------------------------------------
; Egg Capsule (Flipped)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

.flipped

		; xpos
		move.w	(Camera_X_pos).w,d0
		move.w	objoff_3A(a0),d1						; get moving
		bmi.s	.left

		; check right side
		addi.w	#320-48,d0
		cmp.w	x_pos(a0),d0
		blo.s	.chgx
		bra.s	.setx
; ---------------------------------------------------------------------------

.left

		; check left side
		addi.w	#48,d0
		cmp.w	x_pos(a0),d0
		blo.s	.setx

.chgx
		neg.w	d1								; change moving

.setx
		move.w	d1,objoff_3A(a0)						; save moving
		add.w	d1,x_pos(a0)

		; ypos
		moveq	#64,d0
		add.w	(Camera_Y_pos).w,d0
		move.l	#$4000,d1
		cmp.w	y_pos(a0),d0
		bhi.s	.sety
		neg.l	d1

.sety
		add.l	d1,y_pos(a0)

		; check button
		btst	#1,objoff_38(a0)						; is button pressed?
		beq.s	.swing								; if not, branch

		; load sub routine
		moveq	#0,d0
		move.b	(Current_zone).w,d0
		add.w	d0,d0
		add.w	d0,d0
		move.l	.subindex(pc,d0.w),objoff_34(a0)
		bsr.w	.open

.swing
		jsr	(Swing_UpAndDown).w
		jmp	(MoveSprite2).w
; ---------------------------------------------------------------------------

.subindex										; $A, $E, $10 only (sub_866BA, sub_866DA, sub_866EC)
		dc.l sub_866BA								; DEZ

		zonewarning .subindex,(1*4)

; =============== S U B R O U T I N E =======================================

sub_866BA:										; Routine $A (Normal)
		tst.b	(Boss_flag).w							; boss is defeated?
		bne.s	.waitb								; if not, branch
		move.l	#sub_866CC,d0
		bsr.s	Check_SonicEndPose

.waitb
		jsr	(Swing_UpAndDown).w
		jmp	(MoveSprite2).w
; ---------------------------------------------------------------------------

sub_866CC:										; Routine $C
		jsr	(Swing_UpAndDown).w
		jmp	(MoveSprite2).w
; ---------------------------------------------------------------------------

sub_866DA:										; Routine $E (MGZ)
		tst.b	(Boss_flag).w							; boss is defeated?
		bne.s	.waitb								; if not, branch
		move.l	#sub_866CC,d0
		bsr.w	Check_SonicEndPose_MGZ

.waitb
		jsr	(Swing_UpAndDown).w
		jmp	(MoveSprite2).w

; =============== S U B R O U T I N E =======================================

sub_86716:										; Routine $12 (LBZ)
		bra.s	sub_866EC.swing
; ---------------------------------------------------------------------------

sub_866EC:										; Routine $10 (LBZ)
		tst.b	(Boss_flag).w							; boss is defeated?
		bne.s	.swing								; if not, branch
		move.l	#sub_86716,d0
		bsr.s	Check_SonicEndPose

.swing
		jsr	(Swing_UpAndDown).w
		moveq	#-96,d0
		add.w	(Camera_X_pos).w,d0
		cmp.w	x_pos(a0),d0
		blo.s	.loc_8670C
		rts
; ---------------------------------------------------------------------------

.loc_8670C
		subq.w	#2,x_pos(a0)
		jmp	(MoveSprite2).w

; =============== S U B R O U T I N E =======================================

Check_SonicEndPose:

		; wait
		subq.w	#1,objoff_2E(a0)
		bpl.s	.return

		lea	(Player_1).w,a1							; a1=character
		btst	#7,status(a1)
		bne.s	.return
		btst	#status.player.in_air,status(a1)				; is the player in the air?
		bne.s	.return								; if yes, branch
		cmpi.b	#PlayerID_Death,routine(a1)					; has player just died?
		bhs.s	.return								; if yes, branch
		move.l	d0,objoff_34(a0)						; set routine
		jsr	(Set_PlayerEndingPose).w
		jsr	(Create_New_Sprite).w
		bne.s	.return
		move.l	#Obj_LevelResults,address(a1)

.return
		rts

; =============== S U B R O U T I N E =======================================

Check_SonicEndPose_MGZ:

		; wait
		subq.w	#1,objoff_2E(a0)
		bpl.s	.return

		lea	(Player_1).w,a1							; a1=character
		cmpi.b	#PlayerID_Death,routine(a1)					; has player just died?
		bhs.s	.return								; if yes, branch
		tst.b	render_flags(a1)						; player visible on the screen?
		bpl.s	.return								; if not, branch
		move.w	#-$100,x_vel(a0)						; left move
		move.l	d0,objoff_34(a0)						; set routine
		jsr	(Create_New_Sprite).w
		bne.s	.return
		move.l	#Obj_LevelResults,address(a1)

.return
		rts

; ---------------------------------------------------------------------------
; Egg Capsule button (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_EggCapsule_Button:

		; init
		lea	ObjDat_EggCapsule_Button(pc),a1
		jsr	(SetUp_ObjAttributes3).w
		move.l	#.main,address(a0)

.main

		; solid
		moveq	#(32/2)+$B,d1							; width
		moveq	#10/2,d2							; height (when jumping)
		moveq	#(10/2)+1,d3							; height+1 (when walking)
		move.w	x_pos(a0),d4
		jsr	(SolidObjectFull).w

		; check standing on the object
		moveq	#standing_mask,d0
		and.b	status(a0),d0							; is Sonic or Tails standing on the object?
		beq.s	.draw								; if not, branch
		move.l	#.solid,address(a0)
		movea.w	parent3(a0),a1							; load egg capsule address
		bset	#1,objoff_38(a1)						; set flag as "pressed"
		move.b	#$C,mapping_frame(a0)						; "pressed" frame

.draw
		jmp	(Child_Draw_Sprite).w
; ---------------------------------------------------------------------------

.solid
		moveq	#(32/2)+$B,d1							; width
		moveq	#10/2,d2							; height (when jumping)
		moveq	#(10/2)+1,d3							; height+1 (when walking)
		move.w	x_pos(a0),d4
		jsr	(SolidObjectFull).w

		; draw
		jmp	(Child_Draw_Sprite).w

; ---------------------------------------------------------------------------
; Egg Capsule flipped button (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_EggCapsule_FlippedButton:

		; init
		lea	ObjDat_EggCapsule_Button(pc),a1
		jsr	(SetUp_ObjAttributes3).w
		bset	#render_flags.y_flip,render_flags(a0)				; set flipy flag
		move.l	#.main,address(a0)

.main
		lea	.range(pc),a1
		jsr	(Check_PlayerInRange).w
		tst.l	d0								; check Tails and Sonic address
		beq.s	.refresh
		tst.w	d0								; Sonic address
		beq.s	.notp1
		movea.w	d0,a1								; get Sonic address
		tst.w	y_vel(a1)
		bpl.s	.notp1
		cmpi.b	#AniIDSonAni_Roll,anim(a1)					; is player in his rolling animation?
		beq.s	.press								; if so, branch
		cmpi.b	#PlayerID_Tails,character_id(a1)				; is Tails?
		beq.s	.press								; if yes, branch

.notp1
		swap	d0
		movea.w	d0,a1								; get Tails address
		tst.w	y_vel(a1)
		bpl.s	.refresh

.press
		move.l	#.refresh,address(a0)
		subq.b	#8,child_dy(a0)							; move object to "pressed"
		movea.w	parent3(a0),a1							; load egg capsule address
		bset	#1,objoff_38(a1)						; set flag as "pressed"

.refresh
		jsr	(Refresh_ChildPosition).w

		; solid
		moveq	#(32/2)+$B,d1							; width
		moveq	#24/2,d2							; height (when jumping)
		moveq	#(24/2)+1,d3							; height+1 (when walking)
		move.w	x_pos(a0),d4
		jsr	(SolidObjectFull).w

		; draw
		jmp	(Child_Draw_Sprite).w
; ---------------------------------------------------------------------------

.range
		dc.w -26, 52	; xpos, xpos (26 pixels width)
		dc.w -28, 56	; ypos, ypos (28 pixels height)

; ---------------------------------------------------------------------------
; Egg Capsule flicker pieces (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_EggCapsule_Pieces:

		; init
		lea	ObjDat_EggCapsule_Pieces(pc),a1
		jsr	(SetUp_ObjAttributes).w
		move.l	#Obj_FlickerMove,address(a0)
		bsr.s	.getframe
		moveq	#1<<2,d0							; set index velocity
		jsr	(Set_IndexedVelocity).w
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

.getframe
		moveq	#0,d0
		move.b	subtype(a0),d0
		lsr.w	d0								; division by 2
		move.b	.frame(pc,d0.w),mapping_frame(a0)
		rts
; ---------------------------------------------------------------------------

.frame	dc.b 2, 3, $A, 4, $B
	even

; ---------------------------------------------------------------------------
; Egg Capsule propeller (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_EggCapsule_Propeller:

		; init
		lea	ObjDat3_EggCapsule_Propeller(pc),a1
		jsr	(SetUp_ObjAttributes3).w
		move.l	#.main,address(a0)

.main
		jsr	(Refresh_ChildPosition).w
		lea	AniRaw_Propeller(pc),a1
		jsr	(Animate_RawNoSST).w
		jmp	(Child_Draw_Sprite).w
; ---------------------------------------------------------------------------

AniRaw_Propeller:	dc.b 0, 6, 7, 8, 9, arfEnd
	even

; ---------------------------------------------------------------------------
; Egg Capsule animals (Object)
; ---------------------------------------------------------------------------

; Dynamic object variables
ecapa_timer				= objoff_2E	; .w

ecapa_yvel				= objoff_3E	; .w

; =============== S U B R O U T I N E =======================================

Obj_EggCapsule_Animals:

		; init
		lea	ObjDat_EggCapsule_Animals(pc),a1
		jsr	(SetUp_ObjAttributes3).w
		move.l	#.normal,address(a0)
		move.b	#16/2,y_radius(a0)						; 24/2?
		bsr.w	EggCapsule_Animals_Load
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.normal

		; wait
		subq.w	#1,objoff_2E(a0)
		bpl.s	.draw
		move.l	#.jump,address(a0)
		move.w	#priority_1,priority(a0)

.draw
		jmp	(Sprite_CheckDelete).w
; ---------------------------------------------------------------------------

.jump

		; Obj_Animal_Fly
		MoveSprite a0, $20
		tst.w	y_vel(a0)
		bmi.s	.anim
		jsr	(ObjCheckFloorDist).w
		tst.w	d1
		bpl.s	.anim
		add.w	d1,y_pos(a0)
		move.w	objoff_3E(a0),y_vel(a0)

		; check Sonic
		jsr	(Find_SonicTails).w
		move.w	#-$200,d1							; left
		tst.b	(Level_results_flag).w
		beq.s	.setxvel
		tst.w	d0
		beq.s	.setxvel
		neg.w	d1								; right

.setxvel
		move.w	d1,x_vel(a0)

		; check
		bclr	#render_flags.x_flip,render_flags(a0)
		tst.w	d1
		bpl.s	.anim
		bset	#render_flags.x_flip,render_flags(a0)

.anim
		moveq	#0,d0
		btst	#3,(V_int_run_count+3).w					; 0 or 8
		bne.s	.setframe
		addq.b	#1,d0

.setframe
		move.b	d0,mapping_frame(a0)
		jmp	(Sprite_CheckDelete).w

; ---------------------------------------------------------------------------
; Egg Capsule animals flipped (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_EggCapsule_Animals_Flipped:

		; refresh position
		jsr	(Refresh_ChildPosition).w

		; wait
		subq.w	#1,objoff_2E(a0)
		bpl.s	.draw
		move.l	#.move,address(a0)
		move.w	#priority_1,priority(a0)

.draw
		jmp	(Sprite_CheckDelete).w
; ---------------------------------------------------------------------------

.move
		lea	(Player_1).w,a1							; a1=character
		move.w	#$300,d0							; max xvel
		move.w	#$100,d1							; max yvel
		moveq	#$10,d2								; add xyvel
		moveq	#-48,d4								; add ypos
		sub.b	subtype(a0),d4

		; xvel
		move.w	d2,d5
		move.w	x_pos(a1),d6							; player xpos
		cmp.w	x_pos(a0),d6
		bhs.s	.skipx
		neg.w	d2

.skipx
		move.w	x_vel(a0),d6
		add.w	d2,d6
		cmp.w	d0,d6
		bgt.s	.yvel
		neg.w	d0
		cmp.w	d0,d6
		blt.s	.yvel
		move.w	d6,x_vel(a0)

.yvel
		move.w	y_pos(a1),d6							; player ypos
		add.w	d4,d6
		cmp.w	y_pos(a0),d6
		bhs.s	.skipy
		neg.w	d5

.skipy
		move.w	y_vel(a0),d6
		add.w	d5,d6
		cmp.w	d1,d6
		bgt.s	.xyvel
		neg.w	d1
		cmp.w	d1,d6
		blt.s	.xyvel
		move.w	d6,y_vel(a0)

.xyvel
		MoveSprite2 a0

		; check xvel
		bclr	#render_flags.x_flip,render_flags(a0)
		tst.w	x_vel(a0)
		bpl.s	.check
		bset	#render_flags.x_flip,render_flags(a0)

.check
		tst.b	(Level_results_flag).w
		bne.s	.anim
		move.l	#.back,address(a0)
		bset	#render_flags.x_flip,render_flags(a0)				; left side
		bra.s	.anim
; ---------------------------------------------------------------------------

.back
		subq.w	#2,x_pos(a0)							; left move

.anim
		moveq	#0,d0
		btst	#3,(V_int_run_count+3).w					; 0 or 8
		bne.s	.setframe
		addq.b	#1,d0

.setframe
		move.b	d0,mapping_frame(a0)
		jmp	(Sprite_CheckDelete).w
; ---------------------------------------------------------------------------

EggCapsule_Animals_Yvel:
		dc.w -$380
		dc.w -$300
		dc.w -$280
		dc.w -$200
EggCapsule_Animals_VRAM:
		dc.w make_art_tile($580,0,1)
		dc.w make_art_tile($592,0,1)
		dc.w make_art_tile($42E,0,1)
		dc.w make_art_tile($440,0,1)

; ---------------------------------------------------------------------------
; Egg Capsule load animals
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

EggCapsule_Animals_Load:
		moveq	#0,d0
		move.b	subtype(a0),d0
		move.w	d0,d1
		andi.w	#6,d0
		move.w	EggCapsule_Animals_Yvel(pc,d0.w),d2
		move.w	d2,y_vel(a0)
		move.w	d2,objoff_3E(a0)

		; check
		movea.w	parent3(a0),a1							; load egg capsule address
		btst	#render_flags.y_flip,render_flags(a1)				; is egg capsule flipped?
		beq.s	.skipf								; if not, branch

		; egg capsule flipped
		move.l	#Obj_EggCapsule_Animals_Flipped,address(a0)
		addq.b	#8,child_dy(a0)
		clr.w	y_vel(a0)

.skipf
		andi.w	#2,d0
		move.w	d0,d2
		move.w	EggCapsule_Animals_VRAM(pc,d2.w),art_tile(a0)
		moveq	#0,d2
		move.b	(Current_zone).w,d2
		add.w	d2,d2
		lea	Obj_Animal_ZoneAnimals(pc),a1
		adda.w	d2,a1
		lsr.w	d0								; division by 2
		move.b	(a1,d0.w),d0
		lea	Obj_Animal_Properties(pc),a2
		move.l	(a2,d0.w),mappings(a0)
		add.w	d1,d1
		add.w	d1,d1
		move.w	d1,objoff_2E(a0)						; set wait

		; set xvel
		movea.w	parent3(a0),a1							; load egg capsule address
		move.w	x_pos(a0),d0
		move.w	#$200,d1
		cmp.w	x_pos(a1),d0
		bhs.s	.setxvel
		neg.w	d1

.setxvel
		move.w	d1,x_vel(a0)
		jmp	(Change_FlipXWithVelocity2).w

; =============== S U B R O U T I N E =======================================

; mapping
ObjDat_EggCapsule:			subObjData Map_EggCapsule, $494, 0, 1, 64, 64, 4, 0, 0
ObjDat_EggCapsule_Button:		subObjData FALSE, FALSE, 0, 0, 16, 32, 4, 5, 0
ObjDat3_EggCapsule_Propeller:		subObjData FALSE, FALSE, 0, 0, 8, 40, 4, 6, 0
ObjDat_EggCapsule_Pieces:		subObjData Map_EggCapsule, $494, 0, 1, 24, 24, 3, 0, 0
ObjDat_EggCapsule_Animals:		subObjData FALSE, FALSE, 0, 0, 24, 16, 5, 2, 0

Child6_EggCapsule:
		dc.w 1-1
		dc.l Obj_EggCapsule
Child1_EggCapsule_Button:
		dc.w 1-1
		dc.l Obj_EggCapsule_Button
		dc.b 0, -36
Child1_EggCapsule_FlippedButton:
		dc.w 1-1
		dc.l Obj_EggCapsule_FlippedButton
		dc.b 0, 36
Child1_EggCapsule_Propeller:
		dc.w 2-1
		dc.l Obj_EggCapsule_Propeller
		dc.b -20, -36
		dc.l Obj_EggCapsule_Propeller
		dc.b 20, -36
Child1_EggCapsule_Pieces:
		dc.w 5-1
		dc.l Obj_EggCapsule_Pieces
		dc.b 0, -8
		dc.l Obj_EggCapsule_Pieces
		dc.b -16, -8
		dc.l Obj_EggCapsule_Pieces
		dc.b 16, -8
		dc.l Obj_EggCapsule_Pieces
		dc.b -24, -8
		dc.l Obj_EggCapsule_Pieces
		dc.b 24, -8
Child1_EggCapsule_Animals:
		dc.w 9-1
		dc.l Obj_EggCapsule_Animals
		dc.b 0, -4
		dc.l Obj_EggCapsule_Animals
		dc.b -8, -4
		dc.l Obj_EggCapsule_Animals
		dc.b 8, -4
		dc.l Obj_EggCapsule_Animals
		dc.b 16, -4
		dc.l Obj_EggCapsule_Animals
		dc.b -16, -4
		dc.l Obj_EggCapsule_Animals
		dc.b -24, -4
		dc.l Obj_EggCapsule_Animals
		dc.b 24, -4
		dc.l Obj_EggCapsule_Animals
		dc.b -4, -4
		dc.l Obj_EggCapsule_Animals
		dc.b 4, -4

PLC_EggCapsule: plrlistheader
		plreq $494, ArtKosPM_EggCapsule
		plreq ArtTile_Explosion, ArtKosPM_Explosion
PLC_EggCapsule_end
; ---------------------------------------------------------------------------

		include "Objects/Main/Egg Capsule/Object Data/Map - Egg Capsule.asm"
