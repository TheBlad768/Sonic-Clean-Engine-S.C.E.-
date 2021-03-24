
; =============== S U B R O U T I N E =======================================

Obj_EndSignControl:
		move.l	#Obj_Wait,address(a0)
		st	(Level_end_flag).w		; End of level is in effect
		clr.b	(TitleCard_end_flag).w
		bset	#4,$38(a0)
		move.w	#$77,$2E(a0)
		move.l	#Obj_EndSignControlDoSign,$34(a0)

.locret:
		rts
; ---------------------------------------------------------------------------

Obj_EndSignControlDoSign:
		move.l	#Obj_EndSignControlAwaitStart,address(a0)
		lea	Child6_EndSign(pc),a2
		bsr.w	CreateChild6_Simple
		lea	PLC_EndSignStuff(pc),a1
		jsr	(LoadPLC_Raw_Nem).l
		bra.w	AfterBoss_Cleanup
; ---------------------------------------------------------------------------

Obj_EndSignControlAwaitStart:
		tst.b	(Level_end_flag).w
		bne.s	Obj_EndSignControl.locret
		move.l	#Obj_EndSignControlDoStart,address(a0)
		bra.w	Restore_PlayerControl
; ---------------------------------------------------------------------------

Obj_EndSignControlDoStart:
		tst.b	(TitleCard_end_flag).w				; Wait for title card to finish
		beq.s	Obj_EndSignControl.locret
		jsr	(Change_ActSizes).l				; Set level size
		bra.w	Delete_Current_Sprite
; End of function Obj_EndSignControl

; =============== S U B R O U T I N E =======================================

Obj_EndSign:
		moveq	#0,d0
		move.b	routine(a0),d0
		move.w	EndSign_Index(pc,d0.w),d1
		jsr	EndSign_Index(pc,d1.w)
		lea	PLCPtr_EndSigns(pc),a2
		bsr.w	Perform_DPLC
		bra.w	Draw_Sprite
; ---------------------------------------------------------------------------

EndSign_Index: offsetTable
		offsetTableEntry.w Obj_EndSignInit
		offsetTableEntry.w Obj_EndSignFall
		offsetTableEntry.w Obj_EndSignLanded
		offsetTableEntry.w Obj_EndSignResults
		offsetTableEntry.w Obj_EndSignAfter
; ---------------------------------------------------------------------------

Obj_EndSignInit:
		lea	ObjSlot_EndSigns(pc),a1
		bsr.w	SetUp_ObjAttributesSlotted
		btst	#7,(Player_1+art_tile).w
		beq.s	+
		bset	#7,art_tile(a0)					; Signs have same priority as Sonic
+		move.b	#48/2,x_radius(a0)
		move.b	#60/2,y_radius(a0)
		move.l	#AniRaw_EndSigns1,$30(a0)
		move.w	(Camera_Y_pos).w,d0
		subi.w	#$20,d0
		move.w	d0,y_pos(a0)					; Place vertical position at top of screen
		sfx	sfx_Signpost,0,0,0
		lea	Child1_EndSignStub(pc),a2			; Make the little stub at the bottom of the signpost
		bra.w	CreateChild1_Normal
; ---------------------------------------------------------------------------

Obj_EndSignFall:
		move.b	(V_int_run_count+3).w,d0
		andi.b	#3,d0
		bne.s	+
		lea	Child6_EndSignSparkle(pc),a2		; Create a signpost sparkle every 4 frames
		bsr.w	CreateChild6_Simple
+		bsr.w	EndSign_CheckPlayerHit
		addi.w	#$C,y_vel(a0)
		bsr.w	MoveSprite2					; Move downward
		bsr.w	EndSign_CheckWall
		bsr.w	Animate_Raw
		move.w	(Camera_Y_pos).w,d0
		addi.w	#$50,d0
		cmp.w	y_pos(a0),d0
		bhi.s	+							; Ensure that signpost can't land if too far up the screen itself
		tst.w	y_vel(a0)
		bmi.s	+							; And also when the signpost is still moving up
		jsr	(ObjCheckFloorDist).l
		tst.w	d1
		bpl.s	+
		add.w	d1,y_pos(a0)
		move.b	#4,routine(a0)				; If signpost has landed
		bset	#0,$38(a0)
		move.w	#$40,$2E(a0)
+		rts
; ---------------------------------------------------------------------------

Obj_EndSignLanded:
		bsr.w	Animate_Raw
		subq.w	#1,$2E(a0)					; Keep animating while landing for X amount of frames
		bmi.s	+
		rts
; ---------------------------------------------------------------------------
+		move.b	#6,routine(a0)
		clr.l	x_vel(a0)						; Null velocity
		clr.b	mapping_frame(a0)
		rts
; ---------------------------------------------------------------------------

Obj_EndSignResults:
		lea	(Player_1).w,a1
		btst	#Status_InAir,obStatus(a1)
		bne.s	locret_83936					; If player is not standing on the ground, wait until he is
		move.b	#8,routine(a0)
		bsr.w	Set_PlayerEndingPose
		bsr.w	Create_New_Sprite
		bne.s	locret_83936
		move.l	#Obj_LevelResults,address(a1)

locret_83936:
		rts
; ---------------------------------------------------------------------------

Obj_EndSignAfter:
		clr.w	y_vel(a0)					; Null vertical velocity
		move.w	x_pos(a0),d0					; Check for whether signpost goes out of range
		andi.w	#-$80,d0
		sub.w	(Camera_X_pos_coarse_back).w,d0
		cmpi.w	#$280,d0
		bhi.s	loc_83988
		move.w	y_pos(a0),d0
		sub.w	(Camera_Y_pos).w,d0
		addi.w	#$80,d0
		cmpi.w	#$200,d0
		bhi.s	loc_83988
		rts
; ---------------------------------------------------------------------------

loc_83988:
		lea	PLC_Main2(pc),a1
		jsr	(LoadPLC_Raw_Nem).l
		bsr.w	Remove_From_TrackingSlot
		bra.w	Go_Delete_Sprite
; ---------------------------------------------------------------------------

Obj_SignpostSparkle:
		lea	ObjDat_SignpostSparkle(pc),a1
		bsr.w	SetUp_ObjAttributes
		btst	#7,(Player_1+art_tile).w
		beq.s	+
		bset	#7,art_tile(a0)
+		move.l	#Obj_SignpostSparkleMain,address(a0)
		jsr	(Random_Number).l
		andi.w	#$1F,d0
		subi.w	#$10,d0
		add.w	d0,y_pos(a0)			; Random vertical position
		move.w	x_pos(a0),$3A(a0)
		move.w	#$1000,x_vel(a0)
		move.w	#$20,$2E(a0)
		move.l	#Go_Delete_Sprite,$34(a0)

Obj_SignpostSparkleMain:
		move.w	#$400,d0
		move.w	x_pos(a0),d1
		cmp.w	$3A(a0),d1
		blo.s		+
		neg.w	d0
+		move.w	#$280,d1
		add.w	d0,x_vel(a0)		; Do rotation around sign
		bpl.s	+
		move.w	#$380,d1
+		move.w	d1,priority(a0)
		bsr.w	MoveSprite2
		lea	AniRaw_SignpostSparkle(pc),a1
		bsr.w	Animate_RawNoSST
		bsr.w	Obj_Wait
		bra.w	Draw_Sprite
; ---------------------------------------------------------------------------

Obj_SignpostStub:
		lea	ObjDat_SignpostStub(pc),a1
		bsr.w	SetUp_ObjAttributes
		move.l	#Obj_SignpostStubMain,address(a0)
		btst	#7,(Player_1+art_tile).w
		beq.s	Obj_SignpostStubMain
		bset	#7,art_tile(a0)

Obj_SignpostStubMain:
		bsr.w	Refresh_ChildPosition
		bsr.w	Child_GetPriority
		bra.w	Child_Draw_Sprite

; =============== S U B R O U T I N E =======================================

EndSign_CheckPlayerHit:
		tst.b	$20(a0)
		bne.s	loc_83AB8
		lea	EndSign_Range(pc),a1
		bsr.w	Check_PlayerInRange
		tst.l	d0
		beq.s	locret_83ABC		; If neither player is in range, don't do anything
		tst.w	d0
		beq.s	+
		bsr.s	sub_83A70
+		swap	d0
		tst.w	d0
		beq.s	locret_83ABC
; End of function EndSign_CheckPlayerHit

; =============== S U B R O U T I N E =======================================

sub_83A70:
		movea.w	d0,a1					; This can be done up to twice depending on who hit the signpost
		cmpi.b	#id_Roll,anim(a1)
		bne.s	locret_83ABC				; only go on if Player is currently jumping
		tst.w	y_vel(a1)
		bpl.s	locret_83ABC				; And if he's actually moving upwards
		move.b	#$20,$20(a0)			; Set delay for when it checks for the next hit
		move.w	x_pos(a0),d0
		sub.w	x_pos(a1),d0
		bne.s	+
		moveq	#8,d0
+		lsl.w	#4,d0
		move.w	d0,x_vel(a0)				; Modify strength of X velocity based on how far to the left/right player is
		move.w	#-$200,y_vel(a0)			; New vertical velocity is always the same
		sfx	sfx_Signpost,0,0,0
		lea	Child6_EndSignScore(pc),a2
		bsr.w	CreateChild6_Simple
		moveq	#10,d0
		movea.l	a1,a3
		jmp	(HUD_AddToScore).l			; Add 100 points whenever hit
; ---------------------------------------------------------------------------

loc_83AB8:
		subq.b	#1,$20(a0)

locret_83ABC:
		rts
; End of function sub_83A70

; =============== S U B R O U T I N E =======================================

EndSign_CheckWall:
		move.w	(Camera_X_pos).w,d0
		tst.w	x_vel(a0)
		bmi.s	loc_83AE8
		addi.w	#$128,d0
		cmp.w	x_pos(a0),d0
		blo.s		loc_83AFE
		moveq	#$20,d3
		jsr	(ObjCheckRightWallDist).l
		tst.w	d1
		bmi.s	loc_83AFE
		rts
; ---------------------------------------------------------------------------

loc_83AE8:
		addi.w	#$18,d0
		cmp.w	x_pos(a0),d0
		bhi.s	loc_83AFE
		moveq	#-$20,d3
		jsr	(ObjCheckLeftWallDist).l
		tst.w	d1
		bpl.s	locret_83B02

loc_83AFE:
		neg.w	x_vel(a0)

locret_83B02:
		rts
; End of function EndSign_CheckWall
; ---------------------------------------------------------------------------

EndSign_Range:	dc.w -$20, $40, -$18, $30
ObjSlot_EndSigns:		subObjSlotData 0,$5CA,$C,0,Map_EndSigns,$300,$18,$10,0,0
ObjDat_SignpostStub:		subObjData Map_SignpostStub,$5E2,$300,4,8,0,0
ObjDat_SignpostSparkle:	subObjData Map_Ring,make_art_tile(ArtTile_Ring,1,0),$280,8,8,4,0
Child1_EndSignStub:
		dc.w 0
		dc.l Obj_SignpostStub
		dc.b 0, $18
Child6_EndSignSparkle:
		dc.w 0
		dc.l Obj_SignpostSparkle
Child6_EndSignScore:
		dc.w 0
		dc.l Obj_EnemyScore
PLCPtr_EndSigns:
		dc.l ArtUnc_EndSigns, DPLC_EndSigns
AniRaw_EndSigns1:
		dc.b	1,   0
		dc.b	4,   5
		dc.b	6,   1
		dc.b	4,   5
		dc.b	6,   3
		dc.b	4,   5
		dc.b	6, $FC
AniRaw_EndSigns2:
		dc.b	1,   1
		dc.b	4,   5
		dc.b	6,   2
		dc.b	4,   5
		dc.b	6,   3
		dc.b	4,   5
		dc.b	6, $FC
AniRaw_SignpostSparkle:
		dc.b	1,   1
		dc.b	2,   3
		dc.b	4, $FC
Child6_EndSign:
		dc.w 0
		dc.l Obj_EndSign
PLC_EndSignStuff: plrlistheader
		plreq $5E2, ArtNem_SignpostStub
PLC_EndSignStuff_End
; ---------------------------------------------------------------------------

DPLC_EndSigns:		include "Objects/Signpost/Object Data/DPLC - End Signs.asm"
Map_EndSigns:		include "Objects/Signpost/Object Data/Map - End Signs.asm"
Map_SignpostStub:	include "Objects/Signpost/Object Data/Map - Signpost Stub.asm"