; ---------------------------------------------------------------------------
; Animal (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_Animal:
		moveq	#0,d0
		move.b	routine(a0),d0
		move.w	off_2C786(pc,d0.w),d1
		jmp	off_2C786(pc,d1.w)
; ---------------------------------------------------------------------------

off_2C786: offsetTable
		offsetTableEntry.w loc_2C8B8
		offsetTableEntry.w loc_2C9E0
		offsetTableEntry.w loc_2CA3C
		offsetTableEntry.w loc_2CA7C
		offsetTableEntry.w loc_2CA3C
		offsetTableEntry.w loc_2CA3C
		offsetTableEntry.w loc_2CA3C
		offsetTableEntry.w loc_2CA7C
		offsetTableEntry.w loc_2CA3C
		offsetTableEntry.w loc_2CA7C
		offsetTableEntry.w loc_2CA3C
		offsetTableEntry.w loc_2CA3C
		offsetTableEntry.w loc_2CA3C
		offsetTableEntry.w loc_2CA3C
		offsetTableEntry.w loc_2CB02
		offsetTableEntry.w loc_2CB24
		offsetTableEntry.w loc_2CB24
		offsetTableEntry.w loc_2CB44
		offsetTableEntry.w loc_2CB80
		offsetTableEntry.w loc_2CBDC
		offsetTableEntry.w loc_2CBFC
		offsetTableEntry.w loc_2CBDC
		offsetTableEntry.w loc_2CBFC
		offsetTableEntry.w loc_2CBDC
		offsetTableEntry.w loc_2CC3C
		offsetTableEntry.w loc_2CB9C
byte_2C7BA:
		dc.b 5, 1	; DEZ
word_2C7EA:
		dc.w -$200
		dc.w -$400
		dc.l Map_Animals5
		dc.w -$200
		dc.w -$300
		dc.l Map_Animals1
		dc.w -$180
		dc.w -$300
		dc.l Map_Animals5
		dc.w -$140
		dc.w -$180
		dc.l Map_Animals4
		dc.w -$1C0
		dc.w -$300
		dc.l Map_Animals3
		dc.w -$300
		dc.w -$400
		dc.l Map_Animals1
		dc.w -$280
		dc.w -$380
		dc.l Map_Animals2
		dc.w -$280
		dc.w -$300
		dc.l Map_Animals1
		dc.w -$200
		dc.w -$380
		dc.l Map_Animals2
		dc.w -$2C0
		dc.w -$300
		dc.l Map_Animals2
		dc.w -$140
		dc.w -$200
		dc.l Map_Animals2
		dc.w -$200
		dc.w -$300
		dc.l Map_Animals2
word_2C84A:
		dc.w -$440, -$400
		dc.w -$440, -$400
		dc.w -$440, -$400
		dc.w -$300, -$400
		dc.w -$300, -$400
		dc.w -$180, -$300
		dc.w -$180, -$300
		dc.w -$140, -$180
		dc.w -$1C0, -$300
		dc.w -$200, -$300
		dc.w -$280, -$380
off_2C876:
		dc.l Map_Animals1
		dc.l Map_Animals1
		dc.l Map_Animals1
		dc.l Map_Animals5
		dc.l Map_Animals5
		dc.l Map_Animals5
		dc.l Map_Animals5
		dc.l Map_Animals4
		dc.l Map_Animals3
		dc.l Map_Animals1
		dc.l Map_Animals2
word_2C8A2:
		dc.w $5A5
		dc.w $5A5
		dc.w $5A5
		dc.w $553
		dc.w $553
		dc.w $573
		dc.w $573
		dc.w $585
		dc.w $593
		dc.w $565
		dc.w $5B3
; ---------------------------------------------------------------------------

loc_2C8B8:
		tst.b	subtype(a0)
		beq.s	loc_2C924
		moveq	#0,d0
		move.b	subtype(a0),d0
		add.w	d0,d0
		move.b	d0,routine(a0)
		subi.w	#$14,d0
		move.w	word_2C8A2(pc,d0.w),art_tile(a0)
		add.w	d0,d0
		move.l	off_2C876(pc,d0.w),mappings(a0)
		lea	word_2C84A(pc),a1
		move.w	(a1,d0.w),$32(a0)
		move.w	(a1,d0.w),x_vel(a0)
		move.w	2(a1,d0.w),$34(a0)
		move.w	2(a1,d0.w),y_vel(a0)
		move.b	#24/2,y_radius(a0)
		move.b	#4,render_flags(a0)
		bset	#0,render_flags(a0)
		move.w	#$300,priority(a0)
		move.b	#16/2,width_pixels(a0)
		move.b	#7,anim_frame_timer(a0)
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

loc_2C924:
		addq.b	#2,routine(a0)
		jsr	(Random_Number).w
		move.w	#$580,d1
		andi.w	#1,d0
		beq.s	+
		move.w	#$592,d1
+		move.w	d1,art_tile(a0)
		moveq	#0,d1
		move.b	(Current_zone).w,d1
		add.w	d1,d1
		add.w	d0,d1
		lea	byte_2C7BA(pc),a1
		move.b	(a1,d1.w),d0
		move.b	d0,$30(a0)
		lsl.w	#3,d0
		lea	word_2C7EA(pc),a1
		adda.w	d0,a1
		move.w	(a1)+,$32(a0)
		move.w	(a1)+,$34(a0)
		move.l	(a1)+,mappings(a0)
		move.b	#24/2,y_radius(a0)
		move.b	#4,render_flags(a0)
		bset	#0,render_flags(a0)
		move.w	#$300,priority(a0)
		move.b	#16/2,width_pixels(a0)
		move.b	#7,anim_frame_timer(a0)
		move.b	#2,mapping_frame(a0)
		move.w	#-$400,y_vel(a0)
		tst.b	$38(a0)
		bne.s	loc_2C9CA
		jsr	(Create_New_Sprite).w
		bne.s	+
		move.l	#Obj_EnemyScore,address(a1)
		move.w	x_pos(a0),x_pos(a1)
		move.w	y_pos(a0),y_pos(a1)
		move.w	$3E(a0),d0
		lsr.w	#1,d0
		move.b	d0,mapping_frame(a1)
+		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

loc_2C9CA:
		move.b	#$1C,routine(a0)
		clr.w	x_vel(a0)
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

loc_2C9E0:
		tst.b	render_flags(a0)
		bpl.s	loc_2C9DA
		jsr	(MoveSprite).w
		tst.w	y_vel(a0)
		bmi.s	+
		jsr	(ObjCheckFloorDist).w
		tst.w	d1
		bpl.s	+
		add.w	d1,y_pos(a0)
		move.w	$32(a0),x_vel(a0)
		move.w	$34(a0),y_vel(a0)
		move.b	#1,mapping_frame(a0)
		move.b	$30(a0),d0
		add.b	d0,d0
		addq.b	#4,d0
		move.b	d0,routine(a0)
		tst.b	$38(a0)
		beq.s	+
		btst	#4,(V_int_run_count+3).w
		beq.s	+
		neg.w	x_vel(a0)
		bchg	#0,render_flags(a0)
+		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

loc_2C9DA:
		jmp	(Delete_Current_Sprite).w
; ---------------------------------------------------------------------------

loc_2CA3C:
		jsr	(MoveSprite).w
		move.b	#1,mapping_frame(a0)
		tst.w	y_vel(a0)
		bmi.s	+
		clr.b	mapping_frame(a0)
		jsr	(ObjCheckFloorDist).w
		tst.w	d1
		bpl.s	+
		add.w	d1,y_pos(a0)
		move.w	$34(a0),y_vel(a0)
+		tst.b	subtype(a0)
		bne.s	loc_2CAE4
		tst.b	render_flags(a0)
		bpl.s	loc_2C9DA
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

loc_2CA7C:
		jsr	(MoveSprite2).w
		addi.w	#$18,y_vel(a0)
		tst.w	y_vel(a0)
		bmi.s	+
		jsr	(ObjCheckFloorDist).w
		tst.w	d1
		bpl.s	+
		add.w	d1,y_pos(a0)
		move.w	$34(a0),y_vel(a0)
		tst.b	subtype(a0)
		beq.s	+
		cmpi.b	#$A,subtype(a0)
		beq.s	+
		neg.w	x_vel(a0)
		bchg	#0,render_flags(a0)
+		subq.b	#1,anim_frame_timer(a0)
		bpl.s	+
		move.b	#1,anim_frame_timer(a0)
		addq.b	#1,mapping_frame(a0)
		andi.b	#1,mapping_frame(a0)
+		tst.b	subtype(a0)
		bne.s	loc_2CAE4
		tst.b	render_flags(a0)
		bpl.w	loc_2C9DA
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

loc_2CAE4:
		move.w	x_pos(a0),d0
		sub.w	(Player_1+x_pos).w,d0
		bcs.s	+
		subi.w	#$180,d0
		bpl.s	+
		tst.b	render_flags(a0)
		bpl.w	loc_2C9DA
+		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

loc_2CB02:
		tst.b	render_flags(a0)
		bpl.w	loc_2C9DA
		subq.w	#1,$36(a0)
		bne.s	+
		move.b	#2,routine(a0)
		move.w	#$80,priority(a0)
+		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

loc_2CB24:
		bsr.w	sub_2CCD2
		bcc.s	loc_2CAE4
		move.w	$32(a0),x_vel(a0)
		move.w	$34(a0),y_vel(a0)
		move.b	#$E,routine(a0)
		bra.w	loc_2CA7C
; ---------------------------------------------------------------------------

loc_2CB44:
		bsr.w	sub_2CCD2
		bpl.s	+
		clr.w	x_vel(a0)
		clr.w	$32(a0)
		jsr	(MoveSprite2).w
		addi.w	#$18,y_vel(a0)
		bsr.w	sub_2CC92
		bsr.w	sub_2CCBA
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	+
		move.b	#1,anim_frame_timer(a0)
		addq.b	#1,mapping_frame(a0)
		andi.b	#1,mapping_frame(a0)
+		bra.w	loc_2CAE4
; ---------------------------------------------------------------------------

loc_2CB80:
		bsr.w	sub_2CCD2
		bpl.s	loc_2CBD8
		move.w	$32(a0),x_vel(a0)
		move.w	$34(a0),y_vel(a0)
		move.b	#4,routine(a0)
		bra.w	loc_2CA3C
; ---------------------------------------------------------------------------

loc_2CB9C:
		jsr	(MoveSprite).w
		move.b	#1,mapping_frame(a0)
		tst.w	y_vel(a0)
		bmi.s	loc_2CBD8
		clr.b	mapping_frame(a0)
		jsr	(ObjCheckFloorDist).w
		tst.w	d1
		bpl.s	loc_2CBD8
		not.b	$2D(a0)
		bne.s	+
		neg.w	x_vel(a0)
		bchg	#0,render_flags(a0)
+		add.w	d1,y_pos(a0)
		move.w	$34(a0),y_vel(a0)

loc_2CBD8:
		bra.w	loc_2CAE4
; ---------------------------------------------------------------------------

loc_2CBDC:
		bsr.w	sub_2CCD2
		bpl.s	+
		clr.w	x_vel(a0)
		clr.w	$32(a0)
		jsr	(MoveSprite).w
		bsr.w	sub_2CC92
		bsr.w	sub_2CCBA
+		bra.w	loc_2CAE4
; ---------------------------------------------------------------------------

loc_2CBFC:
		bsr.w	sub_2CCD2
		bpl.s	+
		jsr	(MoveSprite).w
		move.b	#1,mapping_frame(a0)
		tst.w	y_vel(a0)
		bmi.s	+
		clr.b	mapping_frame(a0)
		jsr	(ObjCheckFloorDist).w
		tst.w	d1
		bpl.s	+
		neg.w	x_vel(a0)
		bchg	#0,render_flags(a0)
		add.w	d1,y_pos(a0)
		move.w	$34(a0),y_vel(a0)
+		bra.w	loc_2CAE4
; ---------------------------------------------------------------------------

loc_2CC3C:
		bsr.w	sub_2CCD2
		bpl.s	+++
		jsr	(MoveSprite2).w
		addi.w	#$18,y_vel(a0)
		tst.w	y_vel(a0)
		bmi.s	++
		jsr	(ObjCheckFloorDist).w
		tst.w	d1
		bpl.s	++
		not.b	$2D(a0)
		bne.s	+
		neg.w	x_vel(a0)
		bchg	#0,render_flags(a0)
+		add.w	d1,y_pos(a0)
		move.w	$34(a0),y_vel(a0)
+		subq.b	#1,anim_frame_timer(a0)
		bpl.s	+
		move.b	#1,anim_frame_timer(a0)
		addq.b	#1,mapping_frame(a0)
		andi.b	#1,mapping_frame(a0)
+		bra.w	loc_2CAE4

; =============== S U B R O U T I N E =======================================

sub_2CC92:
		move.b	#1,mapping_frame(a0)
		tst.w	y_vel(a0)
		bmi.s	+
		clr.b	mapping_frame(a0)
		jsr	(ObjCheckFloorDist).w
		tst.w	d1
		bpl.s	+
		add.w	d1,y_pos(a0)
		move.w	$34(a0),y_vel(a0)
+		rts

; =============== S U B R O U T I N E =======================================

sub_2CCBA:
		bset	#0,render_flags(a0)
		move.w	x_pos(a0),d0
		sub.w	(Player_1+x_pos).w,d0
		bcc.s	+
		bclr	#0,render_flags(a0)
+		rts

; =============== S U B R O U T I N E =======================================

sub_2CCD2:
		move.w	(Player_1+x_pos).w,d0
		sub.w	x_pos(a0),d0
		subi.w	#$B8,d0
		rts
; ---------------------------------------------------------------------------

		include "Objects/Animals/Object Data/Map - Animals 1.asm"
		include "Objects/Animals/Object Data/Map - Animals 2.asm"
		include "Objects/Animals/Object Data/Map - Animals 3.asm"
		include "Objects/Animals/Object Data/Map - Animals 4.asm"
		include "Objects/Animals/Object Data/Map - Animals 5.asm"
