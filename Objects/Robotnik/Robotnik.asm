; ---------------------------------------------------------------------------
; Robotnik Head 3
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_RobotnikHead3:
		jsr	(Refresh_ChildPositionAdjusted).w
		moveq	#0,d0
		move.b	routine(a0),d0
		move.w	RobotnikHead3_Index(pc,d0.w),d1
		jsr	RobotnikHead3_Index(pc,d1.w)
		jmp	(Child_Draw_Sprite2).w
; ---------------------------------------------------------------------------

RobotnikHead3_Index: offsetTable
		offsetTableEntry.w Obj_RobotnikHead3Init
		offsetTableEntry.w Obj_RobotnikHead3Main
		offsetTableEntry.w Obj_RobotnikHead3End
; ---------------------------------------------------------------------------

Obj_RobotnikHead3Init:
		lea	ObjDat_RobotnikHead(pc),a1
		jsr	(SetUp_ObjAttributes).w
		move.l	#AniRaw_RobotnikHead,$30(a0)
		movea.w	parent3(a0),a1
		btst	#7,art_tile(a1)
		beq.s	+
		bset	#7,art_tile(a0)
+		rts
; ---------------------------------------------------------------------------

Obj_RobotnikHead3Main:
		cmpi.b	#id_SonicHurt,(Player_1+routine).w
		bhs.s	Obj_RobotnikHead3_Laugh
		jsr	(Animate_Raw).w
		movea.w	parent3(a0),a1
		btst	#7,status(a1)
		bne.s	++
		btst	#6,status(a1)
		beq.s	+
		move.b	#2,mapping_frame(a0)
+		rts
; ---------------------------------------------------------------------------
+		move.b	#4,routine(a0)
		move.b	#5,mapping_frame(a0)

Obj_RobotnikHeadEnd:
		rts
; ---------------------------------------------------------------------------

Obj_RobotnikHead3End:
		movea.w	parent3(a0),a1
		btst	#7,status(a1)
		bne.s	Obj_RobotnikHeadEnd
		lea	AniRaw_RobotnikHead(pc),a1
		jmp	(Animate_RawNoSST).w
; ---------------------------------------------------------------------------

Obj_RobotnikHead3_Laugh:
		lea	AniRaw_RobotnikHead_Laugh(pc),a1
		jmp	(Animate_RawNoSST).w
; ---------------------------------------------------------------------------
; Robotnik Head 4
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_RobotnikHead4:
		jsr	(Refresh_ChildPositionAdjusted).w
		jsr	(Child_GetPriority).w
		moveq	#0,d0
		move.b	routine(a0),d0
		move.w	RobotnikHead4_Index(pc,d0.w),d1
		jsr	RobotnikHead4_Index(pc,d1.w)
		movea.w	parent3(a0),a1
		btst	#5,$38(a1)
		bne.s	loc_67CFE
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

RobotnikHead4_Index: offsetTable
		offsetTableEntry.w Obj_RobotnikHead3Init
		offsetTableEntry.w Obj_RobotnikHead3Main
		offsetTableEntry.w Obj_RobotnikHead3End
; ---------------------------------------------------------------------------

loc_67CFE:
		jmp	(Delete_Current_Sprite).w
; ---------------------------------------------------------------------------
; Robotnik Ship Flame
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_RobotnikShipFlame:
		lea	ObjDat2_RoboShipFlame(pc),a1
		jsr	(SetUp_ObjAttributes3).w
		move.l	#RobotnikShipFlame_Main,address(a0)

RobotnikShipFlame_Main:
		movea.w	parent3(a0),a1
		btst	#4,$38(a1)
		bne.s	loc_67CFE
		jsr	(Refresh_ChildPositionAdjusted).w
		btst	#0,(V_int_run_count+3).w
		bne.s	Obj_RobotnikHeadEnd
		tst.w	x_vel(a1)
		beq.s	Obj_RobotnikHeadEnd
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

ObjDat_RobotnikHead:
		dc.l Map_RobotnikShip
		dc.w $52E
		dc.w $280
		dc.b 32/2
		dc.b 16/2
		dc.b 0
		dc.b 0
ObjDat2_RoboShipFlame:
		dc.w $280
		dc.b 16/2
		dc.b 8/2
		dc.b 8
		dc.b 0
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
; ---------------------------------------------------------------------------

		include "Objects/Robotnik/Object Data/Map - Robotnik Ship.asm"
