; ---------------------------------------------------------------------------
; Load Signpost (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_EndSignControl:
		move.l	#Obj_Wait,address(a0)
		st	(Level_results_flag).w						; end of level is in effect
		move.w	#(2*60)-1,objoff_2E(a0)
		move.l	#Obj_EndSignControlDoSign,objoff_34(a0)

.return
		rts
; ---------------------------------------------------------------------------

Obj_EndSignControlDoSign:
		move.l	#Obj_EndSignControlAwaitStart,address(a0)
		clr.b	(Boss_flag).w
		lea	Child6_EndSign(pc),a2
		jsr	(CreateChild6_Simple).w

AfterBoss_Cleanup:
		move.l	(Level_data_addr_RAM.AfterBoss).w,d0
		beq.s	Obj_EndSignControl.return
		movea.l	d0,a1
		jmp	(a1)
; ---------------------------------------------------------------------------

Obj_EndSignControlAwaitStart:
		tst.b	(Level_results_flag).w
		bne.s	Obj_EndSignControl.return
		move.l	#Obj_EndSignControlDoStart,address(a0)

		; restore control
		clr.b	(Ctrl_1_locked).w						; unlock control 1
		jmp	(Restore_PlayerControl).w
; ---------------------------------------------------------------------------

Obj_EndSignControlDoStart:
		tst.b	(End_of_level_flag).w						; wait for title card to finish
		beq.s	Obj_EndSignControl.return
		jsr	(Change_ActSizes).w						; set level size
		jmp	(Delete_Current_Sprite).w

; ---------------------------------------------------------------------------
; Signpost (Object)
; ---------------------------------------------------------------------------

; Dynamic object variables
sign_timer			= objoff_2E	; .w
sign_aniraw			= objoff_30	; .l

sign_dplcframe			= objoff_3A	; .b
sign_rosbit			= objoff_3B	; .b
sign_rosaddr			= objoff_3C	; .w

; =============== S U B R O U T I N E =======================================

Obj_EndSign:

.artsize	:= (ArtUnc_SignpostStub_end-ArtUnc_SignpostStub)&$FFFF

		; load stub art
		QueueStaticDMA ArtUnc_SignpostStub,.artsize,tiles_to_bytes($492)

		; init
		lea	ObjSlot_EndSigns(pc),a1
		jsr	(SetUp_ObjAttributesSlotted).w
		move.l	#.signfall,address(a0)

		; check priority
		btst	#high_priority_bit,(Player_1+art_tile).w			; is Sonic has high priority?
		beq.s	.nothighpriority						; if not, branch
		bset	#high_priority_bit,art_tile(a0)					; signs have same priority as Sonic (high priority)

.nothighpriority
		move.w	a0,(Signpost_addr).w						; put RAM address here for use by hidden monitor object
		move.w	#bytes_to_word(60/2,48/2),y_radius(a0)				; set y_radius and x_radius
		move.l	#AniRaw_EndSigns1,objoff_30(a0)
		moveq	#-32,d0
		add.w	(Camera_Y_pos).w,d0
		move.w	d0,y_pos(a0)							; place vertical position at top of screen
		sfx	sfx_Signpost
		lea	Child1_EndSignStub(pc),a2					; make the little stub at the bottom of the signpost
		jsr	(CreateChild1_Normal).w

.signfall
		bsr.w	EndSign_CheckPlayerHit

		; sparkle
		moveq	#3,d0
		and.b	(V_int_run_count+3).w,d0
		bne.s	.skip
		lea	Child6_EndSignSparkle(pc),a2					; create a signpost sparkle every 4 frames
		jsr	(CreateChild6_Simple).w

.skip
		moveq	#$C,d1
		jsr	(MoveSprite_CustomGravity).w					; move downward
		bsr.w	EndSign_CheckWall
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
		move.l	#.signlanded,address(a0)
		bset	#0,objoff_38(a0)
		move.w	#(1*60)+4,objoff_2E(a0)

.draw
		lea	PLCPtr_EndSigns(pc),a2
		jsr	(Perform_DPLC).w
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.signlanded
		btst	#0,objoff_38(a0)
		beq.s	.hmon
		jsr	(Animate_Raw).w
		subq.w	#1,objoff_2E(a0)						; keep animating while landing for X amount of frames
		bmi.s	.endtime
		bra.s	.draw
; ---------------------------------------------------------------------------

.endtime
		move.l	#.signresults,address(a0)
		clr.l	x_vel(a0)							; clear velocity
		clr.b	mapping_frame(a0)
		bra.s	.draw
; ---------------------------------------------------------------------------

.hmon
		move.l	#.signfall,address(a0)						; if a hidden monitor was hit, bounce ths signpost again
		move.b	#32,objoff_20(a0)						; set delay for when it checks for the next hit
		move.w	#-$200,y_vel(a0)
		bra.s	.draw
; ---------------------------------------------------------------------------

.signresults
		lea	(Player_1).w,a1							; a1=character
		btst	#status.player.in_air,status(a1)
		bne.s	.draw2								; if player is not standing on the ground, wait until he is
		move.l	#.signafter,address(a0)
		st	(Ctrl_1_locked).w						; null Sonic's input
		jsr	(Set_PlayerEndingPose).w
		jsr	(Create_New_Sprite).w
		bne.s	.draw2
		move.l	#Obj_LevelResults,address(a1)
		bra.s	.draw2
; ---------------------------------------------------------------------------

.signafter
		clr.w	y_vel(a0)							; clear vertical velocity
		out_of_xrange.s	.offscreen						; check for whether signpost goes out of range
		out_of_yrange.s	.offscreen

.draw2
		lea	PLCPtr_EndSigns(pc),a2
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
		jmp	(Go_Delete_Sprite).w

; ---------------------------------------------------------------------------
; Signpost (Sparkle)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_SignpostSparkle:

		; init
		lea	ObjDat_SignpostSparkle(pc),a1
		jsr	(SetUp_ObjAttributes).w

		; check priority
		btst	#high_priority_bit,(Player_1+art_tile).w			; is Sonic has high priority?
		beq.s	.nothighpriority						; if not, branch
		bset	#high_priority_bit,art_tile(a0)					; sparkles have same priority as Sonic (high priority)

.nothighpriority
		move.l	#.main,address(a0)
		jsr	(Random_Number).w
		andi.w	#$1F,d0
		subi.w	#$10,d0
		add.w	d0,y_pos(a0)							; random vertical position
		move.w	x_pos(a0),objoff_3A(a0)
		move.w	#$1000,x_vel(a0)
		move.w	#32,objoff_2E(a0)
		move.l	#Go_Delete_Sprite,objoff_34(a0)

.main
		move.w	#$400,d0							; right
		move.w	x_pos(a0),d1
		cmp.w	objoff_3A(a0),d1
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
		lea	AniRaw_SignpostSparkle(pc),a1
		jsr	(Animate_RawNoSST).w
		jsr	(Obj_Wait).w
		jmp	(Draw_Sprite).w

; ---------------------------------------------------------------------------
; Signpost (Stub)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_SignpostStub:

		; init
		lea	ObjDat_SignpostStub(pc),a1
		jsr	(SetUp_ObjAttributes).w
		bset	#render_flags.static_mappings,render_flags(a0)			; set flag to "static mappings flag"
		move.l	#.main,address(a0)

		; check priority
		btst	#high_priority_bit,(Player_1+art_tile).w			; is Sonic has high priority?
		beq.s	.main								; if not, branch
		bset	#high_priority_bit,art_tile(a0)					; stub have same priority as Sonic (high priority)

.main
		jsr	(Refresh_ChildPosition).w
		jsr	(Child_GetPriority).w
		jmp	(Child_Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

EndSign_CheckPlayerHit:
		tst.b	objoff_20(a0)
		bne.s	.subtime
		lea	EndSign_Range(pc),a1
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
		move.b	#32,objoff_20(a0)						; set delay for when it checks for the next hit
		move.w	x_pos(a0),d0
		sub.w	x_pos(a1),d0							; get velocity
		bne.s	.notzero
		moveq	#8,d0								; set velocity

.notzero
		asl.w	#4,d0								; calc velocity
		move.w	d0,x_vel(a0)							; modify strength of X velocity based on how far to the left/right player is
		move.w	#-$200,y_vel(a0)						; new vertical velocity is always the same
		sfx	sfx_Signpost
		lea	Child6_EndSignScore(pc),a2
		jsr	(CreateChild6_Simple).w
		moveq	#10,d0
		jmp	(HUD_AddToScore).w						; add 100 points whenever hit
; ---------------------------------------------------------------------------

.subtime
		subq.b	#1,objoff_20(a0)

.return
		rts
; ---------------------------------------------------------------------------

EndSign_Range:
		dc.w -32, 64	; xpos
		dc.w -24, 48	; ypos

; =============== S U B R O U T I N E =======================================

EndSign_CheckWall:
		move.w	(Camera_X_pos).w,d0
		tst.w	x_vel(a0)
		bmi.s	.leftside

		; check right side
		addi.w	#320-24,d0
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

; mapping
ObjSlot_EndSigns:		subObjSlotData 1-1, $494, 0, 0, $18, 0, Map_EndSigns, 32, 48, 6, 0, 0
ObjDat_SignpostStub:		subObjData Map_SignpostStub, $492, 0, 0, 16, 8, 6, 0, 0
ObjDat_SignpostSparkle:		subObjData Map_Ring, ArtTile_Ring, 1, 0, 16, 16, 5, 4, 0

; dplc
PLCPtr_EndSigns:		dc.l dmaSource(ArtUnc_EndSigns), DPLC_EndSigns

Child6_EndSign:
		dc.w 1-1
		dc.l Obj_EndSign
Child1_EndSignStub:
		dc.w 1-1
		dc.l Obj_SignpostStub
		dc.b 0, 24
Child6_EndSignSparkle:
		dc.w 1-1
		dc.l Obj_SignpostSparkle
Child6_EndSignScore:
		dc.w 1-1
		dc.l Obj_EnemyScore

AniRaw_EndSigns1:		dc.b 1, 0, 4, 5, 6, 1, 4, 5, 6, 3, 4, 5, 6, arfEnd	; Sonic
AniRaw_EndSigns2:		dc.b 1, 1, 4, 5, 6, 2, 4, 5, 6, 3, 4, 5, 6, arfEnd	; Knuckles
AniRaw_SignpostSparkle:		dc.b 1, 1, 2, 3, 4, arfEnd
	even
; ---------------------------------------------------------------------------

		include "Objects/Main/Signpost/Object Data/Map - End Signs.asm"
		include "Objects/Main/Signpost/Object Data/DPLC - End Signs.asm"
		include "Objects/Main/Signpost/Object Data/Map - Signpost Stub.asm"
