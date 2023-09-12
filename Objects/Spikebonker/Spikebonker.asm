; ---------------------------------------------------------------------------
; Spikebonker (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_Spikebonker:
		jsr	(Obj_WaitOffscreen).w
		lea	ObjDat_Spikebonker(pc),a1
		jsr	(SetUp_ObjAttributes).w
		clr.b	routine(a0)
		move.l	#.main,address(a0)
		moveq	#signextendB($80),d0
		btst	#0,render_flags(a0)
		beq.s	.notflipx
		neg.w	d0

.notflipx
		move.w	d0,x_vel(a0)
		moveq	#0,d0
		move.b	subtype(a0),d0
		move.w	d0,d1
		subq.w	#1,d0
		move.w	d0,wait(a0)
		add.w	d1,d1
		subq.w	#1,d1
		move.w	d1,objoff_3A(a0)
		move.l	#.changeside,jump(a0)
		moveq	#$40,d0
		move.w	d0,objoff_3E(a0)
		move.w	d0,y_vel(a0)
		move.w	#4,objoff_40(a0)
		bclr	#0,objoff_38(a0)		; clear swing flag
		lea	ChildObjDat_Spikebonker_Control(pc),a2
		jmp	(CreateChild1_Normal).w
; ---------------------------------------------------------------------------

.main
		pea	(Sprite_CheckDeleteTouch).w
		jsr	(Find_SonicObject).w
		cmpi.w	#96,d2
		bhs.s	.notfound
		btst	#0,render_flags(a0)
		beq.s	.notflipx2
		subq.w	#2,d0

.notflipx2
		tst.w	d0
		beq.s	.attack

.notfound
		jsr	(Swing_UpAndDown).w
		jsr	(MoveSprite2).w
		jmp	(Obj_Wait).w
; ---------------------------------------------------------------------------

.attack
		move.l	#.wait,address(a0)
		bset	#3,objoff_38(a0)	; set attack flag
		sfx	sfx_Dash,1
; ---------------------------------------------------------------------------

.changeside
		neg.w	x_vel(a0)
		bchg	#0,render_flags(a0)
		move.w	objoff_3A(a0),wait(a0)
		rts
; ---------------------------------------------------------------------------

.wait
		pea	(Sprite_CheckDeleteTouch).w
		btst	#3,objoff_38(a0)	; check attack flag
		bne.s	.return
		move.l	#.main,address(a0)

.return
		rts

; ---------------------------------------------------------------------------
; Spikebonker (Control)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_Spikebonker_Control:
		lea	ChildObjDat_Spikebonker_Spike(pc),a2
		jsr	(CreateChild6_Simple).w
		move.l	#.main,address(a0)

.main
		jsr	(Refresh_ChildPositionAdjusted).w
		movea.w	parent4(a0),a1	; spikeball
		move.b	objoff_3C(a1),d0	; angle
		bne.s	.loc_91B08
		movea.w	parent3(a0),a2	; spikebonker (main)
		btst	#3,objoff_38(a2)		; check attack flag
		bne.s	.loc_91B14

.loc_91B08:
		subq.b	#8,d0
		move.b	d0,objoff_3C(a1)
		jmp	(Child_CheckParent).w
; ---------------------------------------------------------------------------

.loc_91B14:
		move.l	#.loc_91B3E,address(a0)
		moveq	#-4,d0
		btst	#0,render_flags(a0)
		beq.s	.notflipx
		neg.w	d0

.notflipx
		move.w	d0,x_vel(a0)
		move.w	#$1F,wait(a0)
		move.l	#.loc_91B68,jump(a0)
		jmp	(Child_CheckParent).w
; ---------------------------------------------------------------------------

.loc_91B3E:
		move.w	x_pos(a0),d0
		add.w	x_vel(a0),d0
		move.w	d0,x_pos(a0)
		jsr	(Obj_Wait).w
		jmp	(Child_CheckParent).w
; ---------------------------------------------------------------------------

.loc_91B68:
		move.l	#.loc_91B70,address(a0)
		rts
; ---------------------------------------------------------------------------

.loc_91B70:
		movea.w	parent4(a0),a1
		move.b	objoff_3C(a1),d0	; angle
		cmpi.b	#$80,d0
		beq.s	.loc_91B8A
		subq.b	#8,d0
		move.b	d0,objoff_3C(a1)
		jmp	(Child_CheckParent).w
; ---------------------------------------------------------------------------

.loc_91B8A:
		move.l	#.loc_91B3E,address(a0)
		neg.w	x_vel(a0)
		move.w	#$1F,wait(a0)
		move.l	#.loc_91B56,jump(a0)
		jmp	(Child_CheckParent).w
; ---------------------------------------------------------------------------

.loc_91B56:
		move.l	#.main,address(a0)
		movea.w	parent3(a0),a1	; spikebonker (main)
		bclr	#3,objoff_38(a1)		; clear attack flag
		rts

; ---------------------------------------------------------------------------
; Spikebonker (SpikeBall)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_Spikebonker_SpikeBall:
		lea	ObjDat3_Spikebonker_SpikeBall(pc),a1
		jsr	(SetUp_ObjAttributes3).w
		movea.w	parent3(a0),a1	; spikebonker (main)
		move.w	a0,parent4(a1)	; spikeball
		move.l	#.main,address(a0)

.main
		move.b	objoff_3C(a0),d0	; angle
		bsr.s	.findangle
		move.w	#$200,d1
		addi.b	#$40,d0
		bpl.s	.highpriority
		move.w	#$280,d1

.highpriority
		move.w	d1,priority(a0)
		lea	(AngleLookup_1).w,a1
		jsr	(MoveSprite_AngleXLookupOffset).w
		jmp	(Child_DrawTouch_Sprite).w
; ---------------------------------------------------------------------------

.findangle
		moveq	#0,d1

.find
		lea	.data(pc,d1.w),a1
		cmp.b	(a1)+,d0
		bls.s		.found
		addq.w	#2,d1
		bra.s	.find
; ---------------------------------------------------------------------------

.found
		move.b	(a1),mapping_frame(a0)
		rts
; ---------------------------------------------------------------------------

.data
		dc.b 0, 1		; angle, frame
		dc.b $30, 1
		dc.b $50, 2
		dc.b $B0, 3
		dc.b $D0, 2
		dc.b $FF, 1

; =============== S U B R O U T I N E =======================================

ObjDat_Spikebonker:
		dc.l Map_Spikebonker
		dc.w $8500
		dc.w $280
		dc.b 40/2
		dc.b 40/2
		dc.b 0
		dc.b $1A
ObjDat3_Spikebonker_SpikeBall:
		dc.w $200
		dc.b 32/2
		dc.b 32/2
		dc.b 1
		dc.b $1A|$80
ChildObjDat_Spikebonker_Control:
		dc.w 1-1
		dc.l Obj_Spikebonker_Control
		dc.b 0, 20
ChildObjDat_Spikebonker_Spike:
		dc.w 1-1
		dc.l Obj_Spikebonker_SpikeBall
; ---------------------------------------------------------------------------

		include "Objects/Spikebonker/Object Data/Map - Spikebonker.asm"
