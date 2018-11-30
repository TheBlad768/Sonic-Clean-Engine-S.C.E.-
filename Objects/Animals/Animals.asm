
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
		dc.b 5	; DEZ
		dc.b 5	; Null
word_2C7EA:
		dc.w $FE00
		dc.w $FC00
		dc.l Map_Animals5
		dc.w $FE00
		dc.w $FD00
		dc.l Map_Animals1
		dc.w $FE80
		dc.w $FD00
		dc.l Map_Animals5
		dc.w $FEC0
		dc.w $FE80
		dc.l Map_Animals4
		dc.w $FE40
		dc.w $FD00
		dc.l Map_Animals3
		dc.w $FD00
		dc.w $FC00
		dc.l Map_Animals1
		dc.w $FD80
		dc.w $FC80
		dc.l Map_Animals2
		dc.w $FD80
		dc.w $FD00
		dc.l Map_Animals1
		dc.w $FE00
		dc.w $FC80
		dc.l Map_Animals2
		dc.w $FD40
		dc.w $FD00
		dc.l Map_Animals2
		dc.w $FEC0
		dc.w $FE00
		dc.l Map_Animals2
		dc.w $FE00
		dc.w $FD00
		dc.l Map_Animals2
word_2C84A:
		dc.w $FBC0, $FC00
		dc.w $FBC0, $FC00
		dc.w $FBC0, $FC00
		dc.w $FD00, $FC00
		dc.w $FD00, $FC00
		dc.w $FE80, $FD00
		dc.w $FE80, $FD00
		dc.w $FEC0, $FE80
		dc.w $FE40, $FD00
		dc.w $FE00, $FD00
		dc.w $FD80, $FC80
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
		tst.b	$2C(a0)
		beq.w	loc_2C924
		moveq	#0,d0
		move.b	$2C(a0),d0
		add.w	d0,d0
		move.b	d0,5(a0)
		subi.w	#$14,d0
		move.w	word_2C8A2(pc,d0.w),$A(a0)
		add.w	d0,d0
		move.l	off_2C876(pc,d0.w),$C(a0)
		lea	word_2C84A(pc),a1
		move.w	(a1,d0.w),$32(a0)
		move.w	(a1,d0.w),$18(a0)
		move.w	2(a1,d0.w),$34(a0)
		move.w	2(a1,d0.w),$1A(a0)
		move.b	#$C,$1E(a0)
		move.b	#4,4(a0)
		bset	#0,4(a0)
		move.w	#$300,8(a0)
		move.b	#8,7(a0)
		move.b	#7,$24(a0)
		jmp	(Draw_Sprite).l
; ---------------------------------------------------------------------------

loc_2C924:
		addq.b	#2,5(a0)
		jsr	(Random_Number).l
		move.w	#$580,$A(a0)
		andi.w	#1,d0
		beq.s	loc_2C940
		move.w	#$592,$A(a0)

loc_2C940:
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
		move.l	(a1)+,$C(a0)
		move.b	#$C,$1E(a0)
		move.b	#4,4(a0)
		bset	#0,4(a0)
		move.w	#$300,8(a0)
		move.b	#8,7(a0)
		move.b	#7,$24(a0)
		move.b	#2,$22(a0)
		move.w	#-$400,$1A(a0)
		tst.b	$38(a0)
		bne.s	loc_2C9CA
		jsr	(Create_New_Sprite).l
		bne.s	loc_2C9C4
		move.l	#Obj_EnemyScore,(a1)
		move.w	$10(a0),$10(a1)
		move.w	$14(a0),$14(a1)
		move.w	$3E(a0),d0
		lsr.w	#1,d0
		move.b	d0,$22(a1)

loc_2C9C4:
		jmp	(Draw_Sprite).l
; ---------------------------------------------------------------------------

loc_2C9CA:
		move.b	#$1C,5(a0)
		clr.w	$18(a0)
		jmp	(Draw_Sprite).l
; ---------------------------------------------------------------------------

loc_2C9DA:
		jmp	(Delete_Current_Sprite).l
; ---------------------------------------------------------------------------

loc_2C9E0:
		tst.b	4(a0)
		bpl.s	loc_2C9DA
		jsr	(MoveSprite).l
		tst.w	$1A(a0)
		bmi.s	loc_2CA36
		jsr	(ObjCheckFloorDist).l
		tst.w	d1
		bpl.s	loc_2CA36
		add.w	d1,$14(a0)
		move.w	$32(a0),$18(a0)
		move.w	$34(a0),$1A(a0)
		move.b	#1,$22(a0)
		move.b	$30(a0),d0
		add.b	d0,d0
		addq.b	#4,d0
		move.b	d0,5(a0)
		tst.b	$38(a0)
		beq.s	loc_2CA36
		btst	#4,(V_int_run_count+3).w
		beq.s	loc_2CA36
		neg.w	$18(a0)
		bchg	#0,4(a0)

loc_2CA36:
		jmp	(Draw_Sprite).l
; ---------------------------------------------------------------------------

loc_2CA3C:
		jsr	(MoveSprite).l
		move.b	#1,$22(a0)
		tst.w	$1A(a0)
		bmi.s	loc_2CA68
		move.b	#0,$22(a0)
		jsr	(ObjCheckFloorDist).l
		tst.w	d1
		bpl.s	loc_2CA68
		add.w	d1,$14(a0)
		move.w	$34(a0),$1A(a0)

loc_2CA68:
		tst.b	$2C(a0)
		bne.s	loc_2CAE4
		tst.b	4(a0)
		bpl.w	loc_2C9DA
		jmp	(Draw_Sprite).l
; ---------------------------------------------------------------------------

loc_2CA7C:
		jsr	(MoveSprite2).l
		addi.w	#$18,$1A(a0)
		tst.w	$1A(a0)
		bmi.s	loc_2CABA
		jsr	(ObjCheckFloorDist).l
		tst.w	d1
		bpl.s	loc_2CABA
		add.w	d1,$14(a0)
		move.w	$34(a0),$1A(a0)
		tst.b	$2C(a0)
		beq.s	loc_2CABA
		cmpi.b	#$A,$2C(a0)
		beq.s	loc_2CABA
		neg.w	$18(a0)
		bchg	#0,4(a0)

loc_2CABA:
		subq.b	#1,$24(a0)
		bpl.s	loc_2CAD0
		move.b	#1,$24(a0)
		addq.b	#1,$22(a0)
		andi.b	#1,$22(a0)

loc_2CAD0:
		tst.b	$2C(a0)
		bne.s	loc_2CAE4
		tst.b	4(a0)
		bpl.w	loc_2C9DA
		jmp	(Draw_Sprite).l
; ---------------------------------------------------------------------------

loc_2CAE4:
		move.w	$10(a0),d0
		sub.w	(Player_1+$10).w,d0
		bcs.s	loc_2CAFC
		subi.w	#$180,d0
		bpl.s	loc_2CAFC
		tst.b	4(a0)
		bpl.w	loc_2C9DA

loc_2CAFC:
		jmp	(Draw_Sprite).l
; ---------------------------------------------------------------------------

loc_2CB02:
		tst.b	4(a0)
		bpl.w	loc_2C9DA
		subq.w	#1,$36(a0)
		bne.w	loc_2CB1E
		move.b	#2,5(a0)
		move.w	#$80,8(a0)

loc_2CB1E:
		jmp	(Draw_Sprite).l
; ---------------------------------------------------------------------------

loc_2CB24:
		bsr.w	sub_2CCD2
		bcc.s	loc_2CB40
		move.w	$32(a0),$18(a0)
		move.w	$34(a0),$1A(a0)
		move.b	#$E,5(a0)
		bra.w	loc_2CA7C
; ---------------------------------------------------------------------------

loc_2CB40:
		bra.w	loc_2CAE4
; ---------------------------------------------------------------------------

loc_2CB44:
		bsr.w	sub_2CCD2
		bpl.s	loc_2CB7C
		clr.w	$18(a0)
		clr.w	$32(a0)
		jsr	(MoveSprite2).l
		addi.w	#$18,$1A(a0)
		bsr.w	sub_2CC92
		bsr.w	sub_2CCBA
		subq.b	#1,$24(a0)
		bpl.s	loc_2CB7C
		move.b	#1,$24(a0)
		addq.b	#1,$22(a0)
		andi.b	#1,$22(a0)

loc_2CB7C:
		bra.w	loc_2CAE4
; ---------------------------------------------------------------------------

loc_2CB80:
		bsr.w	sub_2CCD2
		bpl.s	loc_2CBD8
		move.w	$32(a0),$18(a0)
		move.w	$34(a0),$1A(a0)
		move.b	#4,5(a0)
		bra.w	loc_2CA3C
; ---------------------------------------------------------------------------

loc_2CB9C:
		jsr	(MoveSprite).l
		move.b	#1,$22(a0)
		tst.w	$1A(a0)
		bmi.s	loc_2CBD8
		move.b	#0,$22(a0)
		jsr	(ObjCheckFloorDist).l
		tst.w	d1
		bpl.s	loc_2CBD8
		not.b	$2D(a0)
		bne.s	loc_2CBCE
		neg.w	$18(a0)
		bchg	#0,4(a0)

loc_2CBCE:
		add.w	d1,$14(a0)
		move.w	$34(a0),$1A(a0)

loc_2CBD8:
		bra.w	loc_2CAE4
; ---------------------------------------------------------------------------

loc_2CBDC:
		bsr.w	sub_2CCD2
		bpl.s	loc_2CBF8
		clr.w	$18(a0)
		clr.w	$32(a0)
		jsr	(MoveSprite).l
		bsr.w	sub_2CC92
		bsr.w	sub_2CCBA

loc_2CBF8:
		bra.w	loc_2CAE4
; ---------------------------------------------------------------------------

loc_2CBFC:
		bsr.w	sub_2CCD2
		bpl.s	loc_2CC38
		jsr	(MoveSprite).l
		move.b	#1,$22(a0)
		tst.w	$1A(a0)
		bmi.s	loc_2CC38
		move.b	#0,$22(a0)
		jsr	(ObjCheckFloorDist).l
		tst.w	d1
		bpl.s	loc_2CC38
		neg.w	$18(a0)
		bchg	#0,4(a0)
		add.w	d1,$14(a0)
		move.w	$34(a0),$1A(a0)

loc_2CC38:
		bra.w	loc_2CAE4
; ---------------------------------------------------------------------------

loc_2CC3C:
		bsr.w	sub_2CCD2
		bpl.s	loc_2CC8E
		jsr	(MoveSprite2).l
		addi.w	#$18,$1A(a0)
		tst.w	$1A(a0)
		bmi.s	loc_2CC78
		jsr	(ObjCheckFloorDist).l
		tst.w	d1
		bpl.s	loc_2CC78
		not.b	$2D(a0)
		bne.s	loc_2CC6E
		neg.w	$18(a0)
		bchg	#0,4(a0)

loc_2CC6E:
		add.w	d1,$14(a0)
		move.w	$34(a0),$1A(a0)

loc_2CC78:
		subq.b	#1,$24(a0)
		bpl.s	loc_2CC8E
		move.b	#1,$24(a0)

loc_2CC84:
		addq.b	#1,$22(a0)
		andi.b	#1,$22(a0)

loc_2CC8E:
		bra.w	loc_2CAE4

; =============== S U B R O U T I N E =======================================

sub_2CC92:
		move.b	#1,$22(a0)
		tst.w	$1A(a0)
		bmi.s	locret_2CCB8
		move.b	#0,$22(a0)
		jsr	(ObjCheckFloorDist).l
		tst.w	d1
		bpl.s	locret_2CCB8
		add.w	d1,$14(a0)
		move.w	$34(a0),$1A(a0)

locret_2CCB8:
		rts
; End of function sub_2CC92

; =============== S U B R O U T I N E =======================================

sub_2CCBA:
		bset	#0,4(a0)
		move.w	$10(a0),d0
		sub.w	(Player_1+$10).w,d0
		bcc.s	locret_2CCD0
		bclr	#0,4(a0)

locret_2CCD0:
		rts
; End of function sub_2CCBA

; =============== S U B R O U T I N E =======================================

sub_2CCD2:
		move.w	(Player_1+$10).w,d0
		sub.w	$10(a0),d0
		subi.w	#$B8,d0
		rts
; End of function sub_2CCD2
; ---------------------------------------------------------------------------

		include "Objects/Animals/Object Data/Map - Animals 1.asm"
		include "Objects/Animals/Object Data/Map - Animals 2.asm"
		include "Objects/Animals/Object Data/Map - Animals 3.asm"
		include "Objects/Animals/Object Data/Map - Animals 4.asm"
		include "Objects/Animals/Object Data/Map - Animals 5.asm"