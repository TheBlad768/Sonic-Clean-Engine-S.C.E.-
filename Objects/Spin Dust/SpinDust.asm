; ---------------------------------------------------------------------------
; Dash Dust (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_DashDust:
		moveq	#0,d0
		move.b	routine(a0),d0
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
		addq.b	#2,routine(a0)
		move.l	#Map_DashDust,mappings(a0)
		ori.b	#4,render_flags(a0)
		move.w	#$80,priority(a0)
		move.b	#32/2,width_pixels(a0)
		move.w	#ArtTile_DashDust,art_tile(a0)
		move.w	#tiles_to_bytes(ArtTile_DashDust),vram_art(a0)
		lea	(Player_1).w,a1
		cmpi.b	#1,character_id(a1)
		bne.s	loc_18BAA
		move.b	#1,character_id(a0)

loc_18BAA:
		lea	(Player_1).w,a2
		moveq	#0,d0
		move.b	anim(a0),d0
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
		move.w	(Water_level).w,y_pos(a0)
		tst.b	$21(a0)
		bne.w	loc_18C94
		move.w	x_pos(a2),x_pos(a0)
		clr.b	status(a0)
		andi.w	#$7FFF,art_tile(a0)
		bra.w	loc_18C94
; ---------------------------------------------------------------------------

loc_18BEC:
		tst.b	$21(a0)
		bne.s	+
		move.w	x_pos(a2),x_pos(a0)
		clr.b	status(a0)
		andi.w	#$7FFF,art_tile(a0)
+		lea	Ani_DashSplashDrown(pc),a1
		jsr	(Animate_Sprite).w
		move.l	#ArtUnc_SplashDrown>>1,d6
		bsr.w	SplashDrown_Load_DPLC
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

loc_18C20:
		cmpi.b	#12,air_left(a2)
		blo.w	loc_18CAA
		cmpi.b	#4,routine(a2)
		bhs.s	loc_18CAA
		tst.b	$3D(a2)
		beq.s	loc_18CAA
		move.w	x_pos(a2),x_pos(a0)
		move.w	y_pos(a2),y_pos(a0)
		move.b	status(a2),status(a0)
		andi.b	#1,status(a0)
		moveq	#4,d1
		tst.b	(Reverse_gravity_flag).w
		beq.s	loc_18C60
		ori.b	#2,status(a0)
		neg.w	d1

loc_18C60:
		tst.b	$38(a0)
		beq.s	+
		sub.w	d1,y_pos(a0)
+		tst.b	$21(a0)
		bne.s	loc_18C94
		andi.w	#$7FFF,art_tile(a0)
		tst.w	art_tile(a2)
		bpl.s	loc_18C94
		ori.w	#$8000,art_tile(a0)
		bra.s	loc_18C94
; ---------------------------------------------------------------------------

loc_18C84:
		cmpi.b	#12,air_left(a2)
		blo.s		loc_18CAA
		btst	#6,status(a0)
		bne.s	loc_18CAA

loc_18C94:
		lea	Ani_DashSplashDrown(pc),a1
		jsr	(Animate_Sprite).w
		bsr.w	DashDust_Load_DPLC
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

loc_18CAA:
		clr.b	anim(a0)
		rts
; ---------------------------------------------------------------------------

loc_18CB2:
		jmp	(Delete_Current_Sprite).w
; ---------------------------------------------------------------------------

loc_18CB6:
		lea	(Player_1).w,a2
		moveq	#$10,d1
		cmpi.b	#id_Stop,anim(a2)
		beq.s	loc_18CE4
		cmpi.b	#2,character_id(a2)
		bne.s	loc_18CD6
		moveq	#6,d1
		cmpi.b	#3,double_jump_flag(a2)
		beq.s	loc_18CE4

loc_18CD6:
		move.b	#2,routine(a0)
		clr.b	$36(a0)
		rts
; ---------------------------------------------------------------------------

loc_18CE4:
		subq.b	#1,$36(a0)
		bpl.s	DashDust_Load_DPLC
		move.b	#3,$36(a0)
		btst	#Status_Underwater,status(a2)
		bne.s	DashDust_Load_DPLC
		jsr	(Create_New_Sprite).w
		bne.s	DashDust_Load_DPLC
		move.l	address(a0),address(a1)
		move.w	x_pos(a2),x_pos(a1)
		move.w	y_pos(a2),y_pos(a1)
		tst.b	$38(a0)
		beq.s	+
		subq.w	#4,d1
+		tst.b	(Reverse_gravity_flag).w
		beq.s	+
		neg.w	d1
+		add.w	d1,y_pos(a1)
		clr.b	status(a1)
		move.b	#id_Roll2,anim(a1)
		addq.b	#2,routine(a1)
		move.l	mappings(a0),mappings(a1)
		move.b	render_flags(a0),render_flags(a1)
		move.w	#$80,priority(a1)
		move.b	#8/2,width_pixels(a1)
		move.w	art_tile(a0),art_tile(a1)
		andi.w	#$7FFF,art_tile(a1)
		tst.w	art_tile(a2)
		bpl.s	DashDust_Load_DPLC
		ori.w	#$8000,art_tile(a1)

; =============== S U B R O U T I N E =======================================

DashDust_Load_DPLC:
		move.l	#ArtUnc_DashDust>>1,d6

SplashDrown_Load_DPLC:
		moveq	#0,d0
		move.b	mapping_frame(a0),d0
		cmp.b	$34(a0),d0
		beq.s	+
		move.b	d0,$34(a0)
		lea	DPLC_DashSplashDrown(pc),a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		move.w	(a2)+,d5
		subq.w	#1,d5
		bmi.s	+
		move.w	vram_art(a0),d4

-		moveq	#0,d1
		move.w	(a2)+,d1
		move.w	d1,d3
		lsr.w	#8,d3
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1
		lsl.l	#4,d1
		add.l	d6,d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr	(Add_To_DMA_Queue).w
		dbf	d5,-
+		rts
; ---------------------------------------------------------------------------

		include "Objects/Spin Dust/Object Data/Anim - Dash Splash Drown.asm"
		include "Objects/Spin Dust/Object Data/Map - Dash Dust.asm"
		include "Objects/Spin Dust/Object Data/DPLC - Dash Splash Drown.asm"
