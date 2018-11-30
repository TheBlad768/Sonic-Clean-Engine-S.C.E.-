
; =============== S U B R O U T I N E =======================================

Obj_EndSignControl:
		move.l	#Obj_Wait,(a0)
		st	(Level_end_flag).w		; End of level is in effect
		clr.b	(TitleCard_end_flag).w
		bset	#4,$38(a0)
		move.w	#$77,$2E(a0)
		move.l	#Obj_EndSignControlDoSign,$34(a0)

.locret:
		rts
; ---------------------------------------------------------------------------

Obj_EndSignControlDoSign:
		move.l	#Obj_EndSignControlAwaitStart,(a0)
		lea	Child6_EndSign(pc),a2
		jsr	(CreateChild6_Simple).l
		lea	PLC_EndSignStuff(pc),a1
		jsr	(LoadPLC_Raw_Nem).l
		jmp	(AfterBoss_Cleanup).l
; ---------------------------------------------------------------------------

Obj_EndSignControlAwaitStart:
		tst.b	(Level_end_flag).w
		bne.s	Obj_EndSignControl.locret
		move.l	#Obj_EndSignControlDoStart,(a0)
		jmp	(Restore_PlayerControl).l
; ---------------------------------------------------------------------------

Obj_EndSignControlDoStart:
		tst.b	(TitleCard_end_flag).w				; Wait for title card to finish
		beq.s	Obj_EndSignControl.locret
		jsr	(Change_ActSizes).l				; Set level size
		jmp	(Delete_Current_Sprite).l
; End of function Obj_EndSignControl

; =============== S U B R O U T I N E =======================================

Obj_EndSign:
		moveq	#0,d0
		move.b	5(a0),d0
		move.w	EndSign_Index(pc,d0.w),d1
		jsr	EndSign_Index(pc,d1.w)
		lea	PLCPtr_EndSigns(pc),a2
		jsr	(Perform_DPLC).l
		jmp	(Draw_Sprite).l
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
		jsr	(SetUp_ObjAttributesSlotted).l
		btst	#7,(Player_1+art_tile).w
		beq.s	loc_837EE
		bset	#7,$A(a0)			; Signs have same priority as Sonic

loc_837EE:
		move.b	#$18,$1F(a0)
		move.b	#$1E,$1E(a0)
		move.l	#AniRaw_EndSigns1,$30(a0)
		move.w	(Camera_Y_pos).w,d0
		subi.w	#$20,d0
		move.w	d0,$14(a0)			; Place vertical position at top of screen
		sfx	sfx_Signpost,0,0,0
		lea	Child1_EndSignStub(pc),a2	; Make the little stub at the bottom of the signpost
		jmp	(CreateChild1_Normal).l
; ---------------------------------------------------------------------------

Obj_EndSignFall:
		move.b	(V_int_run_count+3).w,d0
		andi.b	#3,d0
		bne.s	loc_83844
		lea	Child6_EndSignSparkle(pc),a2	; Create a signpost sparkle every 4 frames
		jsr	(CreateChild6_Simple).l

loc_83844:
		bsr.w	EndSign_CheckPlayerHit
		addi.w	#$C,$1A(a0)
		jsr	(MoveSprite2).l					; Move downward
		bsr.w	EndSign_CheckWall
		jsr	(Animate_Raw).l
		move.w	(Camera_Y_pos).w,d0
		addi.w	#$50,d0
		cmp.w	$14(a0),d0
		bhi.s	locret_838BC		; Ensure that signpost can't land if too far up the screen itself
		tst.w	$1A(a0)
		bmi.s	locret_838BC		; And also when the signpost is still moving up
		jsr	(ObjCheckFloorDist).l
		tst.w	d1
		bpl.s	locret_838BC
		add.w	d1,$14(a0)
		move.b	#4,5(a0)			; If signpost has landed
		bset	#0,$38(a0)
		move.w	#$40,$2E(a0)

locret_838BC:
		rts
; ---------------------------------------------------------------------------

Obj_EndSignLanded:
		jsr	(Animate_Raw).l
		subq.w	#1,$2E(a0)			; Keep animating while landing for X amount of frames
		bmi.s	loc_838D6
		rts
; ---------------------------------------------------------------------------

loc_838D6:
		move.b	#6,5(a0)
		clr.w	$18(a0)
		clr.w	$1A(a0)				; Null velocity
		move.b	#0,$22(a0)
		rts
; ---------------------------------------------------------------------------

Obj_EndSignResults:
		lea	(Player_1).w,a1
		btst	#Status_InAir,obStatus(a1)
		bne.s	locret_83936			; If player is not standing on the ground, wait until he is
		move.b	#8,5(a0)
		jsr	(Set_PlayerEndingPose).l
		jsr	(Create_New_Sprite).l
		bne.s	locret_83936
		move.l	#Obj_LevelResults,(a1)

locret_83936:
		rts
; ---------------------------------------------------------------------------

Obj_EndSignAfter:
		clr.w	$1A(a0)				; Null vertical velocity
		move.w	$10(a0),d0			; Check for whether signpost goes out of range
		andi.w	#-$80,d0
		sub.w	(Camera_X_pos_coarse_back).w,d0
		cmpi.w	#$280,d0
		bhi.s	loc_83988
		move.w	$14(a0),d0
		sub.w	(Camera_Y_pos).w,d0
		addi.w	#$80,d0
		cmpi.w	#$200,d0
		bhi.s	loc_83988
		rts
; ---------------------------------------------------------------------------

loc_83988:
		lea	PLC_Main2(pc),a1
		jsr	(LoadPLC_Raw_Nem).l
		jsr	(Remove_From_TrackingSlot).l
		jmp	(Go_Delete_Sprite).l
; ---------------------------------------------------------------------------

Obj_SignpostSparkle:
		lea	ObjDat_SignpostSparkle(pc),a1
		jsr	(SetUp_ObjAttributes).l
		btst	#7,(Player_1+art_tile).w
		beq.s	loc_839B8
		bset	#7,art_tile(a0)

loc_839B8:
		move.l	#Obj_SignpostSparkleMain,(a0)
		jsr	(Random_Number).l
		andi.w	#$1F,d0
		subi.w	#$10,d0
		add.w	d0,$14(a0)			; Random vertical position
		move.w	$10(a0),$3A(a0)
		move.w	#$1000,$18(a0)
		move.w	#$20,$2E(a0)
		move.l	#Go_Delete_Sprite,$34(a0)

Obj_SignpostSparkleMain:
		move.w	#$400,d0
		move.w	$10(a0),d1
		cmp.w	$3A(a0),d1
		blo.s		loc_839FA
		neg.w	d0

loc_839FA:
		move.w	#$280,d1
		add.w	d0,$18(a0)		; Do rotation around sign
		bpl.s	loc_83A08
		move.w	#$380,d1

loc_83A08:
		move.w	d1,8(a0)
		jsr	(MoveSprite2).l
		lea	AniRaw_SignpostSparkle(pc),a1
		jsr	(Animate_RawNoSST).l
		jsr	(Obj_Wait).l
		jmp	(Draw_Sprite).l
; ---------------------------------------------------------------------------

Obj_SignpostStub:
		lea	ObjDat_SignpostStub(pc),a1
		jsr	(SetUp_ObjAttributes).l
		move.l	#Obj_SignpostStubMain,(a0)
		btst	#7,(Player_1+art_tile).w
		beq.s	Obj_SignpostStubMain
		bset	#7,art_tile(a0)

Obj_SignpostStubMain:
		jsr	(Refresh_ChildPosition).l
		jsr	(Child_GetPriority).l
		jmp	(Child_Draw_Sprite).l

; =============== S U B R O U T I N E =======================================

EndSign_CheckPlayerHit:
		tst.b	$20(a0)
		bne.s	loc_83AB8
		lea	EndSign_Range(pc),a1
		jsr	(Check_PlayerInRange).l
		tst.l	d0
		beq.s	locret_83ABC		; If neither player is in range, don't do anything
		tst.w	d0
		beq.s	loc_83A6A
		bsr.w	sub_83A70

loc_83A6A:
		swap	d0
		tst.w	d0
		beq.s	locret_83ABC
; End of function EndSign_CheckPlayerHit

; =============== S U B R O U T I N E =======================================

sub_83A70:
		movea.w	d0,a1				; This can be done up to twice depending on who hit the signpost
		cmpi.b	#2,$20(a1)
		bne.s	locret_83ABC		; only go on if Player is currently jumping
		tst.w	$1A(a1)
		bpl.s	locret_83ABC		; And if he's actually moving upwards
		move.b	#$20,$20(a0)		; Set delay for when it checks for the next hit
		move.w	$10(a0),d0
		sub.w	$10(a1),d0
		bne.s	loc_83A92
		moveq	#8,d0

loc_83A92:
		lsl.w	#4,d0
		move.w	d0,$18(a0)			; Modify strength of X velocity based on how far to the left/right player is
		move.w	#-$200,$1A(a0)		; New vertical velocity is always the same
		sfx	sfx_Signpost,0,0,0
		lea	Child6_EndSignScore(pc),a2
		jsr	(CreateChild6_Simple).l
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
		tst.w	$18(a0)
		bmi.s	loc_83AE8
		addi.w	#$128,d0
		cmp.w	$10(a0),d0
		blo.s		loc_83AFE
		moveq	#$20,d3
		jsr	(ObjCheckRightWallDist).l
		tst.w	d1
		bmi.s	loc_83AFE
		rts
; ---------------------------------------------------------------------------

loc_83AE8:
		addi.w	#$18,d0
		cmp.w	$10(a0),d0
		bhi.s	loc_83AFE
		moveq	#-$20,d3
		jsr	(ObjCheckLeftWallDist).l
		tst.w	d1
		bpl.s	locret_83B02

loc_83AFE:
		neg.w	$18(a0)

locret_83B02:
		rts
; End of function EndSign_CheckWall
; ---------------------------------------------------------------------------

EndSign_Range:	dc.w -$20, $40, -$18, $30
ObjSlot_EndSigns:		subObjSlotData 0,$5CA,$C,0,Map_EndSigns,$300,$18,$10,0,0
ObjDat_SignpostStub:		subObjData Map_SignpostStub,$5E2,$300,4,8,0,0
ObjDat_SignpostSparkle:	subObjData Map_Ring,make_art_tile(ArtTile_ArtNem_Ring,1,0),$280,8,8,4,0
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
		dc.b	1,   4
		dc.b	5,   6
		dc.b	7, $FC
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