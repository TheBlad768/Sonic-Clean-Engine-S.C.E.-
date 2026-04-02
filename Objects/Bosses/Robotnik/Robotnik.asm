; ---------------------------------------------------------------------------
; Robotnik head 3
; ---------------------------------------------------------------------------

; dynamic object variables

; =============== S U B R O U T I N E =======================================

Obj_RobotnikHead3:
		jsr	(Refresh_ChildPositionAdjusted).w
		moveq	#0,d0
		move.b	routine(a0),d0
		move.w	RobotnikHead3_Index(pc,d0.w),d0
		jsr	RobotnikHead3_Index(pc,d0.w)
		jmp	(Child_Draw_Sprite2).w
; ---------------------------------------------------------------------------

RobotnikHead3_Index: offsetTable
		offsetTableEntry.w Obj_RobotnikHead3Init				; 0
		offsetTableEntry.w Obj_RobotnikHead3Main				; 2
		offsetTableEntry.w Obj_RobotnikHead3End					; 4
; ---------------------------------------------------------------------------

Obj_RobotnikHead3Init:

		; init
		lea	ObjDat_RobotnikHead(pc),a1
		jsr	(SetUp_ObjAttributes).w
		move.l	#AniRaw_RobotnikHead,animations(a0)

		; check
		movea.w	parent3(a0),a1							; a1=parent object
		btst	#high_priority_bit,art_tile(a1)					; is parent object has high priority?
		beq.s	.nothighpriority						; if not, branch
		bset	#high_priority_bit,art_tile(a0)					; high priority

.nothighpriority
		rts
; ---------------------------------------------------------------------------

Obj_RobotnikHead3Main:
		cmpi.b	#PlayerID_Hurt,(Player_1+routine).w				; is Sonic falling back from getting hurt?
		bhs.s	Obj_RobotnikHead3_Laugh						; if yes, branch
		jsr	(Animate_Raw).w

		; check
		movea.w	parent3(a0),a1							; a1=parent object
		btst	#status.npc.defeated,status(a1)					; is boss defeated?
		bne.s	.defeated							; if yes, branch
		btst	#status.npc.touch,status(a1)					; is player hit boss?
		beq.s	.return								; if not, branch
		move.b	#2,mapping_frame(a0)

.return
		rts
; ---------------------------------------------------------------------------

.defeated
		move.b	#4,routine(a0)
		move.b	#5,mapping_frame(a0)						; Robotnik frame

Obj_RobotnikHeadEnd:
		rts
; ---------------------------------------------------------------------------

Obj_RobotnikHead3End:
		movea.w	parent3(a0),a1							; a1=parent object
		btst	#status.npc.defeated,status(a1)					; is boss defeated?
		bne.s	Obj_RobotnikHeadEnd						; if yes, branch
		lea	AniRaw_RobotnikHead(pc),a1
		jmp	(Animate_RawNoSST).w
; ---------------------------------------------------------------------------

Obj_RobotnikHead3_Laugh:
		lea	AniRaw_RobotnikHead_Laugh(pc),a1
		jmp	(Animate_RawNoSST).w

; ---------------------------------------------------------------------------
; Robotnik head 4
; ---------------------------------------------------------------------------

; dynamic object variables

; =============== S U B R O U T I N E =======================================

Obj_RobotnikHead4:
		jsr	(Refresh_ChildPositionAdjusted).w
		jsr	(Child_GetPriority).w
		moveq	#0,d0
		move.b	routine(a0),d0
		move.w	RobotnikHead4_Index(pc,d0.w),d0
		jsr	RobotnikHead4_Index(pc,d0.w)

		; check
		movea.w	parent3(a0),a1							; a1=parent object
		btst	#5,state_flags(a1)
		bne.s	.delete
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.delete
		jmp	(Delete_Current_Object).w
; ---------------------------------------------------------------------------

RobotnikHead4_Index: offsetTable
		offsetTableEntry.w Obj_RobotnikHead3Init				; 0
		offsetTableEntry.w Obj_RobotnikHead3Main				; 2
		offsetTableEntry.w Obj_RobotnikHead3End					; 4

; ---------------------------------------------------------------------------
; Robotnik ship flame
; ---------------------------------------------------------------------------

; dynamic object variables

; =============== S U B R O U T I N E =======================================

Obj_RobotnikShipFlame:

		; init
		lea	ObjDat2_RoboShipFlame(pc),a1
		jsr	(SetUp_ObjAttributes3).w
		move.l	#RobotnikShipFlame_Main,code_addr(a0)

RobotnikShipFlame_Main:
		movea.w	parent3(a0),a1							; a1=parent object
		btst	#4,state_flags(a1)
		bne.s	Obj_RobotnikHead4.delete
		jsr	(Refresh_ChildPositionAdjusted).w
		btst	#0,(V_int_run_count+3).w
		bne.s	Obj_RobotnikHeadEnd
		tst.w	x_vel(a1)
		beq.s	Obj_RobotnikHeadEnd

		; draw
		jmp	(Draw_Sprite).w

; ---------------------------------------------------------------------------
; Robotnik ship pieces
; ---------------------------------------------------------------------------

; dynamic object variables

; =============== S U B R O U T I N E =======================================

Obj_RobotnikShipPieces:

		; init
		lea	ObjDat_RobotnikShipPieces(pc),a1
		jsr	(SetUp_ObjAttributes).w
		move.l	#Obj_FlickerMove,code_addr(a0)
		move.b	subtype(a0),d0
		lsr.b	d0								; division by 2
		move.b	d0,mapping_frame(a0)
		moveq	#2<<2,d0							; set index velocity
		jmp	(Set_IndexedVelocity).w

; =============== S U B R O U T I N E =======================================

; init
ObjDat_RobotnikShip:		subObjData Map_RobotnikShip, $52E, 0, FALSE, 64, 64, 4, $C, $F|collision_flags.npc.touch
ObjDat_RobotnikShip_Glass:	subObjData Map_RobotnikShip, $52E, 0, FALSE, 64, 64, 4, 7, $F|collision_flags.npc.touch
ObjDat_RobotnikHead:		subObjData Map_RobotnikShip, $52E, 0, FALSE, 16, 32, 5, 0, 0
ObjDat2_RoboShipFlame:		subObjData FALSE, FALSE, 0, FALSE, 8, 16, 5, 8, 0
ObjDat_RobotnikShipPieces:	subObjData Map_RobotnikShipPieces, $52E, 0, TRUE, 64, 64, 0, 0, 0

AniRaw_RobotnikHead:
		dc.b 5, 0, 1, arfEnd
AniRaw_RobotnikHead_Laugh:
		dc.b 5, 3, 4, arfEnd
Child1_MakeRoboHead3:
		dc.w 1-1
		dc.l Obj_RobotnikHead3
		dc.b 0, -28
Child1_MakeRoboHead4:
		dc.w 1-1
		dc.l Obj_RobotnikHead4
		dc.b 0, -28
Child1_MakeRoboShipFlame:
		dc.w 1-1
		dc.l Obj_RobotnikShipFlame
		dc.b 30, 0
Child6_MakeRobotnikShipPieces:
		dc.w 4-1
		dc.l Obj_RobotnikShipPieces
; ---------------------------------------------------------------------------

		; data
		incfile.ba	AngleLookup_1, "Objects/Bosses/Robotnik/Object Data/AngleLookup1.bin"
		incfile.ba	AngleLookup_2, "Objects/Bosses/Robotnik/Object Data/AngleLookup2.bin"
		incfile.ba	AngleLookup_3, "Objects/Bosses/Robotnik/Object Data/AngleLookup3.bin"
; ---------------------------------------------------------------------------

		; mappings
		include "Objects/Bosses/Robotnik/Object Data/Map - Robotnik Ship.asm"
		include "Objects/Bosses/Robotnik/Object Data/Map - Robotnik Ship Pieces.asm"
