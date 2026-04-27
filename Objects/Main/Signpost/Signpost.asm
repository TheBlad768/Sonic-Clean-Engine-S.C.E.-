; ---------------------------------------------------------------------------
; Create Signpost (Object)
; ---------------------------------------------------------------------------

; dynamic object variables

; =============== S U B R O U T I N E =======================================

Obj_Signpost_Control:
		st	(Level_results_flag).w						; end of level is in effect
		move.w	#(2*60)-1,wait_timer(a0)
		move.l	#.create,wait_addr(a0)
		move.l	#Obj_Wait,code_addr(a0)

.return
		rts
; ---------------------------------------------------------------------------

.create
		clr.b	(Boss_flag).w							; clear boss flag
		move.l	#Signpost_Control_AwaitStart,code_addr(a0)

		; create signpost
		lea	Child6_Signpost(pc),a2
		jsr	(CreateChild6_Simple).w

AfterBoss_Cleanup:

		; check after boss
		move.l	(Level_data_addr_RAM.AfterBoss).w,d0
		beq.s	Obj_Signpost_Control.return
		movea.l	d0,a1
		jmp	(a1)
; ---------------------------------------------------------------------------

Signpost_Control_AwaitStart:

		; check level results flag
		tst.b	(Level_results_flag).w						; is level over?
		bne.s	Obj_Signpost_Control.return					; if yes, branch
		move.l	#.check,code_addr(a0)

		; restore control
		clr.b	(Ctrl_1_locked).w						; unlock control 1
		jmp	(Restore_PlayerControl).w
; ---------------------------------------------------------------------------

.check

		; check end level flag
		tst.b	(End_of_level_flag).w						; wait for title card to finish
		beq.s	Obj_Signpost_Control.return

		; exit
		jsr	(Change_ActSizes).w						; set level size
		jmp	(Delete_Current_Object).w

; ---------------------------------------------------------------------------
; Signpost (Object)
; ---------------------------------------------------------------------------

; dynamic object variables

	dsset anim									; pretend we're in the RAM

signpost.timer				ds.b 1						; delay while check the next hit (1 byte)

	dsreset										; stop pretending and reset the program counter

; =============== S U B R O U T I N E =======================================

Obj_Signpost:

.artsize	:= (ArtUnc_SignpostStub_end-ArtUnc_SignpostStub)&$FFFF

		; load stub art
		QueueStaticDMA ArtUnc_SignpostStub,.artsize,tiles_to_bytes($492)

		; init
		lea	ObjSlot_Signpost(pc),a1
		jsr	(SetUp_ObjAttributesSlotted).w
		move.l	#.signfall,code_addr(a0)

		; check priority
		btst	#high_priority_bit,(Player_1+art_tile).w			; is Sonic has high priority?
		beq.s	.nothighpriority						; if not, branch
		bset	#high_priority_bit,art_tile(a0)					; signs have same priority as Sonic (high priority)

.nothighpriority
		move.w	a0,(Signpost_addr).w						; put RAM address here for use by hidden monitor object
		move.w	#bytes_to_word(60/2,48/2),y_radius(a0)				; set y_radius and x_radius
		move.l	#AniRaw_Signpost1,animations(a0)

		; create stub
		lea	Child1_Signpost_Stub(pc),a2					; make the little stub at the bottom of the signpost
		jsr	(CreateChild1_Normal).w

		; set
		moveq	#-32,d0
		add.w	(Camera_Y_pos).w,d0
		move.w	d0,y_pos(a0)							; place vertical position at top of screen
		sfx	sfx_Signpost

.signfall
		bsr.w	Signpost_CheckPlayerHit

.sparkle
		moveq	#3,d0
		and.b	(V_int_run_count.byte).w,d0
		bne.s	.skip
		lea	Child6_Signpost_Sparkle(pc),a2					; create a signpost sparkle every 4 frames
		jsr	(CreateChild6_Simple).w

.skip
		MoveSprite , $C								; move downward
		bsr.w	Signpost_CheckWall
		jsr	(Animate_Raw).w
		moveq	#80,d0
		add.w	(Camera_Y_pos).w,d0
		cmp.w	y_pos(a0),d0
		bhi.s	.draw								; ensure that signpost can't land if too far up the screen itself
		tst.w	y_vel(a0)
		bmi.s	.draw								; and also when the signpost is still moving up
		jsr	(ObjCheckFloorDist).w
		tst.w	d1
		bpl.s	.draw
		add.w	d1,y_pos(a0)
		move.l	#.signlanded,code_addr(a0)
		bset	#0,state_flags(a0)						; signpost landed flag
		move.w	#(1*60)+4,wait_timer(a0)

.draw
		lea	PLCPtr_Signpost(pc),a2
		jsr	(Perform_DPLC).w
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.signlanded
		btst	#0,state_flags(a0)
		beq.s	.hmon								; if signpost hasn't landed, branch
		jsr	(Animate_Raw).w
		subq.w	#1,wait_timer(a0)						; keep animating while landing for X amount of frames
		bmi.s	.endtime
		bra.s	.draw
; ---------------------------------------------------------------------------

.endtime
		move.l	#.signresults,code_addr(a0)
		clr.l	x_vel(a0)							; clear velocity
		clr.b	mapping_frame(a0)						; set frame
		bra.s	.draw
; ---------------------------------------------------------------------------

.hmon
		move.l	#.signfall,code_addr(a0)					; if a hidden monitor was hit, bounce ths signpost again
		move.b	#32,signpost.timer(a0)						; set delay for when it checks for the next hit
		move.w	#-$200,y_vel(a0)
		bra.s	.draw
; ---------------------------------------------------------------------------

.signresults
		lea	(Player_1).w,a1							; a1=character
		btst	#status.player.in_air,status(a1)
		bne.s	.draw2								; if player is not standing on the ground, wait until he is
		move.l	#.signafter,code_addr(a0)
		st	(Ctrl_1_locked).w						; null Sonic's input
		jsr	(Set_PlayerEndingPose).w
		jsr	(Create_New_Object).w
		bne.s	.draw2
		move.l	#Obj_LevelResults,code_addr(a1)
		bra.s	.draw2
; ---------------------------------------------------------------------------

.signafter
		clr.w	y_vel(a0)							; clear vertical velocity
		out_of_xrange.s	.offscreen						; check for whether signpost goes out of range
		out_of_yrange.s	.offscreen

.draw2
		lea	PLCPtr_Signpost(pc),a2
		jsr	(Perform_DPLC).w
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.offscreen

		; load second main plc
		lea	(PLC2_Sonic).l,a5
		jsr	(LoadPLC_Raw_KosPlusM).w

		; exit from dplc slot
		jsr	(Remove_From_TrackingSlot).w

		; delete
		clr.w	(Signpost_addr).w						; clear RAM address
		jmp	(Go_Delete_Object).w

; ---------------------------------------------------------------------------
; Signpost (Sparkle)
; ---------------------------------------------------------------------------

; dynamic object variables

	dsset animations								; pretend we're in the RAM

signpost_sparkle.origX			ds.w 1						; original x-axis position (2 bytes)

	dsreset										; stop pretending and reset the program counter

; =============== S U B R O U T I N E =======================================

Obj_Signpost_Sparkle:

		; init
		lea	ObjDat_Signpost_Sparkle(pc),a1
		jsr	(SetUp_ObjAttributes).w

		; check priority
		btst	#high_priority_bit,(Player_1+art_tile).w			; is Sonic has high priority?
		beq.s	.nothighpriority						; if not, branch
		bset	#high_priority_bit,art_tile(a0)					; sparkles have same priority as Sonic (high priority)

.nothighpriority
		move.l	#.main,code_addr(a0)
		jsr	(Random_Number).w
		andi.w	#$1F,d0
		subi.w	#$10,d0
		add.w	d0,y_pos(a0)							; random vertical position
		move.w	x_pos(a0),signpost_sparkle.origX(a0)
		move.w	#$1000,x_vel(a0)
		move.w	#32,wait_timer(a0)
		move.l	#Go_Delete_Object,wait_addr(a0)

.main
		move.w	#$400,d0							; right
		move.w	x_pos(a0),d1
		cmp.w	signpost_sparkle.origX(a0),d1
		blo.s	.skip
		neg.w	d0								; left

.skip
		move.w	#priority_5,d1							; high priority
		add.w	d0,x_vel(a0)							; do rotation around sign
		bpl.s	.priority
		move.w	#priority_7,d1							; low priority

.priority
		move.w	d1,priority(a0)							; set priority
		jsr	(MoveSprite2).w
		lea	AniRaw_Signpost_Sparkle(pc),a1
		jsr	(Animate_RawNoSST).w
		jsr	(Obj_Wait).w
		jmp	(Draw_Sprite).w

; ---------------------------------------------------------------------------
; Signpost (Stub)
; ---------------------------------------------------------------------------

; dynamic object variables

; =============== S U B R O U T I N E =======================================

Obj_Signpost_Stub:

		; init
		lea	ObjDat_Signpost_Stub(pc),a1
		jsr	(SetUp_ObjAttributes).w
		bset	#render_flags.static_mappings,render_flags(a0)			; set flag to "static mappings flag"
		move.l	#.main,code_addr(a0)

		; check priority
		btst	#high_priority_bit,(Player_1+art_tile).w			; is Sonic has high priority?
		beq.s	.main								; if not, branch
		bset	#high_priority_bit,art_tile(a0)					; stub have same priority as Sonic (high priority)

.main
		jsr	(Refresh_ChildPosition).w
		jsr	(Child_GetPriority).w
		jmp	(Child_Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

Signpost_CheckPlayerHit:

		; wait
		tst.b	signpost.timer(a0)						; is timer over?
		bne.s	.subtime							; if not, branch

		; check player hit
		lea	Signpost_Range(pc),a1
		jsr	(Check_PlayerInRange).w
		tst.l	d0								; check Tails and Sonic address
		beq.s	.return								; if neither player is in range, don't do anything
		tst.w	d0								; is Sonic?
		beq.s	.notp1								; if it's not Sonic, branch
		move.l	d0,-(sp)							; save players address
		bsr.s	.checkhit
		move.l	(sp)+,d0							; restore players address

.notp1
		swap	d0								; get Tails address
		tst.w	d0								; is Tails?
		beq.s	.return								; if not, branch

.checkhit
		movea.w	d0,a1								; this can be done up to twice depending on who hit the signpost
		cmpi.b	#AniIDSonAni_Roll,anim(a1)
		bne.s	.return								; only go on if player is currently jumping
		tst.w	y_vel(a1)
		bpl.s	.return								; and if he's actually moving upwards
		move.b	#32,signpost.timer(a0)						; set delay for when it checks for the next hit
		move.w	x_pos(a0),d0
		sub.w	x_pos(a1),d0							; get velocity
		bne.s	.notzero
		moveq	#8,d0								; set velocity

.notzero
		asl.w	#4,d0								; calc velocity
		move.w	d0,x_vel(a0)							; modify strength of X velocity based on how far to the left/right player is
		move.w	#-$200,y_vel(a0)						; new vertical velocity is always the same
		sfx	sfx_Signpost							; play signpost sound

		; create and add score
		lea	Child6_EnemyScore(pc),a2
		jsr	(CreateChild6_Simple).w
		moveq	#10,d0
		jmp	(HUD_AddToScore).w						; add 100 points whenever hit
; ---------------------------------------------------------------------------

.subtime
		subq.b	#1,signpost.timer(a0)						; decrement timer

.return
		rts
; ---------------------------------------------------------------------------

Signpost_Range:
		dc.w -32, 64	; xpos
		dc.w -24, 48	; ypos

; =============== S U B R O U T I N E =======================================

Signpost_CheckWall:

		; check move
		move.w	(Camera_X_pos).w,d0
		tst.w	x_vel(a0)							; check x velocity
		bmi.s	.leftside							; left move

		; check right side
		addi.w	#screen_width-24,d0
		cmp.w	x_pos(a0),d0
		blo.s	.negx

		; check right wall
		moveq	#64/2,d3
		jsr	(ObjCheckRightWallDist).w
		tst.w	d1
		bmi.s	.negx
		rts
; ---------------------------------------------------------------------------

.leftside

		; check left side
		addi.w	#24,d0
		cmp.w	x_pos(a0),d0
		bhi.s	.negx

		; check left wall
		moveq	#-(64/2),d3
		jsr	(ObjCheckLeftWallDist).w
		tst.w	d1
		bpl.s	.return

.negx
		neg.w	x_vel(a0)

.return
		rts

; =============== S U B R O U T I N E =======================================

; init
ObjSlot_Signpost:		subObjSlotData 1-1, $494, 0, FALSE, $18, 0, Map_Signpost, 32, 48, 6, 0, collision_type.npc.none, 0, 0
ObjDat_Signpost_Stub:		subObjData Map_Signpost_Stub, $492, 0, FALSE, 16, 8, 6, 0, collision_type.npc.none, 0, 0
ObjDat_Signpost_Sparkle:	subObjData Map_Ring, ArtTile_Ring, 1, FALSE, 16, 16, 5, 4, collision_type.npc.none, 0, 0

; dplc
PLCPtr_Signpost:		DPLCEntry ArtUnc_Signpost, DPLC_Signpost

Child6_Signpost:
		dc.w 1-1
		dc.l Obj_Signpost
Child1_Signpost_Stub:
		dc.w 1-1
		dc.l Obj_Signpost_Stub
		dc.b 0, 24
Child6_Signpost_Sparkle:
		dc.w 1-1
		dc.l Obj_Signpost_Sparkle

AniRaw_Signpost1:		dc.b 1, 0, 4, 5, 6, 1, 4, 5, 6, 3, 4, 5, 6, arfEnd	; Sonic
AniRaw_Signpost2:		dc.b 1, 1, 4, 5, 6, 2, 4, 5, 6, 3, 4, 5, 6, arfEnd	; Knuckles
AniRaw_Signpost_Sparkle:	dc.b 1, 1, 2, 3, 4, arfEnd				; ring sparkle
	even
; ---------------------------------------------------------------------------

		; mappings
		include "Objects/Main/Signpost/Object Data/Map - Signpost.asm"
		include "Objects/Main/Signpost/Object Data/DPLC - Signpost.asm"
		include "Objects/Main/Signpost/Object Data/Map - Signpost Stub.asm"
