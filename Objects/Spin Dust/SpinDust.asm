
; =============== S U B R O U T I N E =======================================

Obj_DashDust:
		moveq	#0,d0
		move.b	5(a0),d0
		move.w	off_18B4C(pc,d0.w),d1
		jmp	off_18B4C(pc,d1.w)
; ---------------------------------------------------------------------------

off_18B4C: offsetTable
		offsetTableEntry.w loc_18B54
		offsetTableEntry.w loc_18BAA
		offsetTableEntry.w loc_18CB2
		offsetTableEntry.w loc_18CB6
; ---------------------------------------------------------------------------

loc_18B54:
		addq.b	#2,5(a0)
		move.l	#Map_DashDust,$C(a0)
		ori.b	#4,4(a0)
		move.w	#$80,8(a0)
		move.b	#$10,7(a0)
		move.w	#$7F0,$A(a0)
		lea	(Player_1).w,a1
		move.w	a1,$42(a0)
		move.w	#$FE00,$40(a0)
		cmpi.b	#1,character_id(a1)
		bne.s	loc_18BAA
		move.b	#1,$38(a0)

loc_18BAA:
		movea.w	$42(a0),a2
		moveq	#0,d0
		move.b	$20(a0),d0
		add.w	d0,d0
		move.w	off_18BBE(pc,d0.w),d1
		jmp	off_18BBE(pc,d1.w)
; ---------------------------------------------------------------------------

off_18BBE: offsetTable
		offsetTableEntry.w loc_18C94
		offsetTableEntry.w loc_18BC8
		offsetTableEntry.w loc_18C20
		offsetTableEntry.w loc_18C84
		offsetTableEntry.w loc_18BEC
; ---------------------------------------------------------------------------

loc_18BC8:
		move.w	(Water_level).w,$14(a0)
		tst.b	$21(a0)
		bne.w	loc_18C94
		move.w	$10(a2),$10(a0)
		move.b	#0,$2A(a0)
		andi.w	#$7FFF,$A(a0)
		bra.w	loc_18C94
; ---------------------------------------------------------------------------

loc_18BEC:
		tst.b	$21(a0)
		bne.s	+
		move.w	$10(a2),$10(a0)
		move.b	#0,$2A(a0)
		andi.w	#$7FFF,$A(a0)
+		lea	Ani_DashSplashDrown(pc),a1
		jsr	(Animate_Sprite).l
		move.l	#ArtUnc_SplashDrown,d6
		bsr.w	SplashDrown_Load_DPLC
		jmp	(Draw_Sprite).l
; ---------------------------------------------------------------------------

loc_18C20:
		cmpi.b	#$C,$2C(a2)
		blo.w	loc_18CAA
		cmpi.b	#4,5(a2)
		bhs.s	loc_18CAA
		tst.b	$3D(a2)
		beq.s	loc_18CAA
		move.w	$10(a2),$10(a0)
		move.w	$14(a2),$14(a0)
		move.b	$2A(a2),$2A(a0)
		andi.b	#1,$2A(a0)
		moveq	#4,d1
		tst.b	(Reverse_gravity_flag).w
		beq.s	loc_18C60
		ori.b	#2,$2A(a0)
		neg.w	d1

loc_18C60:
		tst.b	$38(a0)
		beq.s	+
		sub.w	d1,$14(a0)
+		tst.b	$21(a0)
		bne.s	loc_18C94
		andi.w	#$7FFF,$A(a0)
		tst.w	$A(a2)
		bpl.s	loc_18C94
		ori.w	#$8000,$A(a0)
		bra.s	loc_18C94
; ---------------------------------------------------------------------------

loc_18C84:
		cmpi.b	#$C,$2C(a2)
		blo.s		loc_18CAA
		btst	#6,$2A(a0)
		bne.s	loc_18CAA

loc_18C94:
		lea	Ani_DashSplashDrown(pc),a1
		jsr	(Animate_Sprite).l
		bsr.w	DashDust_Load_DPLC
		jmp	(Draw_Sprite).l
; ---------------------------------------------------------------------------

loc_18CAA:
		move.b	#0,$20(a0)
		rts
; ---------------------------------------------------------------------------

loc_18CB2:
		bra.w	Delete_Current_Sprite
; ---------------------------------------------------------------------------

loc_18CB6:
		movea.w	$42(a0),a2
		moveq	#$10,d1
		cmpi.b	#id_Stop,$20(a2)
		beq.s	loc_18CE4
		cmpi.b	#2,$38(a2)
		bne.s	loc_18CD6
		moveq	#6,d1
		cmpi.b	#3,$2F(a2)
		beq.s	loc_18CE4

loc_18CD6:
		move.b	#2,5(a0)
		move.b	#0,$36(a0)
		rts
; ---------------------------------------------------------------------------

loc_18CE4:
		subq.b	#1,$36(a0)
		bpl.s	DashDust_Load_DPLC
		move.b	#3,$36(a0)
		btst	#6,$2A(a2)
		bne.s	DashDust_Load_DPLC
		bsr.w	Create_New_Sprite
		bne.s	DashDust_Load_DPLC
		move.l	(a0),(a1)
		move.w	$10(a2),$10(a1)
		move.w	$14(a2),$14(a1)
		tst.b	$38(a0)
		beq.s	+
		subq.w	#4,d1
+		tst.b	(Reverse_gravity_flag).w
		beq.s	+
		neg.w	d1
+		add.w	d1,$14(a1)
		move.b	#0,$2A(a1)
		move.b	#id_Roll2,$20(a1)
		addq.b	#2,5(a1)
		move.l	$C(a0),$C(a1)
		move.b	4(a0),4(a1)
		move.w	#$80,8(a1)
		move.b	#4,7(a1)
		move.w	$A(a0),$A(a1)
		move.w	$42(a0),$42(a1)
		andi.w	#$7FFF,$A(a1)
		tst.w	$A(a2)
		bpl.s	DashDust_Load_DPLC
		ori.w	#$8000,$A(a1)

; =============== S U B R O U T I N E =======================================

DashDust_Load_DPLC:
		move.l	#ArtUnc_DashDust,d6

SplashDrown_Load_DPLC:
		moveq	#0,d0
		move.b	$22(a0),d0
		cmp.b	$34(a0),d0
		beq.s	+
		move.b	d0,$34(a0)
		lea	DPLC_DashSplashDrown(pc),a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		move.w	(a2)+,d5
		subq.w	#1,d5
		bmi.s	+
		move.w	$40(a0),d4

-		moveq	#0,d1
		move.w	(a2)+,d1
		move.w	d1,d3
		lsr.w	#8,d3
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1
		lsl.l	#5,d1
		add.l	d6,d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr	(Add_To_DMA_Queue).l
		dbf	d5,-
+		rts
; End of function DashDust_Load_DPLC
; ---------------------------------------------------------------------------

		include "Objects/Spin Dust/Object Data/Anim - Dash Splash Drown.asm"
		include "Objects/Spin Dust/Object Data/Map - Dash Dust.asm"
		include "Objects/Spin Dust/Object Data/DPLC - Dash Splash Drown.asm"