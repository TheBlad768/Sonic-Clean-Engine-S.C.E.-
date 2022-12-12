; ---------------------------------------------------------------------------
; Spring (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_Spring:
		move.l	#Map_Spring,mappings(a0)
		move.w	#make_art_tile(ArtTile_SpikesSprings+$10,0,0),art_tile(a0)	; set red
		ori.b	#4,render_flags(a0)
		move.w	#bytes_to_word(32/2,32/2),height_pixels(a0)		; set height and width
		move.w	#$200,priority(a0)
		move.w	x_pos(a0),objoff_32(a0)
		move.w	y_pos(a0),objoff_34(a0)
		move.b	subtype(a0),d0
		lsr.w	#3,d0
		andi.w	#$E,d0
		move.w	Spring_Index(pc,d0.w),d0
		jmp	Spring_Index(pc,d0.w)
; ---------------------------------------------------------------------------

Spring_Index: offsetTable
		offsetTableEntry.w Spring_Up			; 0
		offsetTableEntry.w Spring_Horizontal	; 2
		offsetTableEntry.w Spring_Down		; 4
		offsetTableEntry.w Spring_UpDiag		; 6
		offsetTableEntry.w Spring_DownDiag	; 8
; ---------------------------------------------------------------------------

Spring_Horizontal:
		move.b	#2,anim(a0)
		move.b	#3,mapping_frame(a0)
		move.w	#make_art_tile(ArtTile_SpikesSprings+$1C,0,0),art_tile(a0)	; set yellow
		move.b	#16/2,width_pixels(a0)
		move.l	#Obj_Spring_Horizontal,address(a0)
		bra.s	Spring_Common
; ---------------------------------------------------------------------------

Spring_Down:
		tst.b	(Reverse_gravity_flag).w
		bne.s	loc_22E96
		bset	#1,status(a0)

loc_22DFC:
		move.b	#6,mapping_frame(a0)
		move.l	#Obj_Spring_Down,address(a0)
		bra.s	Spring_Common
; ---------------------------------------------------------------------------

Spring_UpDiag:
		move.b	#4,anim(a0)
		move.b	#7,mapping_frame(a0)
		move.w	#$468,art_tile(a0)	; set diagonal
		move.l	#Obj_Spring_UpDiag,address(a0)
		bra.s	Spring_Common
; ---------------------------------------------------------------------------

Spring_DownDiag:
		move.b	#4,anim(a0)
		move.b	#$A,mapping_frame(a0)
		move.w	#$468,art_tile(a0)	; set diagonal
		bset	#1,status(a0)
		move.l	#Obj_Spring_DownDiag,address(a0)
		bra.s	Spring_Common
; ---------------------------------------------------------------------------

Spring_Up:
		tst.b	(Reverse_gravity_flag).w
		bne.s	loc_22DFC

loc_22E96:
		move.l	#Obj_Spring_Up,address(a0)

Spring_Common:
		move.b	subtype(a0),d0
		andi.w	#2,d0
		move.w	word_22EF0(pc,d0.w),objoff_30(a0)
		btst	#1,d0
		beq.s	locret_22EEE
		move.l	#Map_Spring2,mappings(a0)	; set yellow

locret_22EEE:
		rts
; ---------------------------------------------------------------------------

word_22EF0:		dc.w -$1000, -$A00

; =============== S U B R O U T I N E =======================================

Obj_Spring_Up:
		moveq	#$1B,d1
		moveq	#8,d2
		moveq	#$10,d3
		move.w	x_pos(a0),d4
		lea	(Player_1).w,a1
		moveq	#p1_standing_bit,d6
		jsr	SolidObjectFull2_1P(pc)
		btst	#p1_standing_bit,status(a0)
		beq.s	loc_22F1C
		bsr.s	sub_22F98

loc_22F1C:
		lea	Ani_Spring(pc),a1
		jsr	(Animate_Sprite).w
		jmp	(Sprite_OnScreen_Test).w

; =============== S U B R O U T I N E =======================================

sub_22F98:
		move.w	#bytes_to_word(1,0),anim(a0)	; set anim and clear next_anim/prev_anim
		addq.w	#8,y_pos(a1)
		tst.b	(Reverse_gravity_flag).w
		beq.s	+
		subi.w	#$10,y_pos(a1)
+		move.w	objoff_30(a0),y_vel(a1)
		bset	#Status_InAir,status(a1)
		bclr	#Status_OnObj,status(a1)
		clr.b	jumping(a1)
		clr.b	spin_dash_flag(a1)
		move.b	#id_Spring,anim(a1)
		move.b	#id_SonicControl,routine(a1)
		move.b	subtype(a0),d0
		bpl.s	loc_22FE0
		clr.w	x_vel(a1)

loc_22FE0:
		btst	#0,d0
		beq.s	loc_23020
		move.w	#1,ground_vel(a1)
		move.b	#1,flip_angle(a1)
		clr.b	anim(a1)		; id_Walk
		clr.b	flips_remaining(a1)
		move.b	#4,flip_speed(a1)
		btst	#1,d0
		bne.s	loc_23010
		move.b	#1,flips_remaining(a1)

loc_23010:
		btst	#Status_Facing,status(a1)
		beq.s	loc_23020
		neg.b	flip_angle(a1)
		neg.w	ground_vel(a1)

loc_23020:
		andi.b	#$C,d0
		cmpi.b	#4,d0
		bne.s	loc_23036
		move.b	#$C,top_solid_bit(a1)
		move.b	#$D,lrb_solid_bit(a1)

loc_23036:
		cmpi.b	#8,d0
		bne.s	loc_23048
		move.b	#$E,top_solid_bit(a1)
		move.b	#$F,lrb_solid_bit(a1)

loc_23048:
		sfx	sfx_Spring,1

; =============== S U B R O U T I N E =======================================

Obj_Spring_Horizontal:
		move.w	#$13,d1
		move.w	#$E,d2
		move.w	#$F,d3
		move.w	x_pos(a0),d4
		lea	(Player_1).w,a1
		moveq	#p1_standing_bit,d6
		jsr	SolidObjectFull2_1P(pc)
		swap	d6
		andi.w	#1,d6
		beq.s	loc_23092
		move.b	status(a0),d1
		move.w	x_pos(a0),d0
		sub.w	x_pos(a1),d0
		bcs.s	loc_23088
		eori.b	#1,d1

loc_23088:
		andi.b	#1,d1
		bne.s	loc_23092
		bsr.s	sub_23190

loc_23092:
		bsr.w	sub_2326C
		lea	Ani_Spring(pc),a1
		jsr	(Animate_Sprite).w
		move.w	objoff_32(a0),d0
		jmp	(Sprite_OnScreen_Test2).w

; =============== S U B R O U T I N E =======================================

sub_23190:
		move.w	#bytes_to_word(3,0),anim(a0)	; set anim and clear next_anim/prev_anim
		move.w	objoff_30(a0),x_vel(a1)
		addq.w	#8,x_pos(a1)
		bset	#Status_Facing,status(a1)
		btst	#0,status(a0)
		bne.s	loc_231BE
		bclr	#Status_Facing,status(a1)
		subi.w	#$10,x_pos(a1)
		neg.w	x_vel(a1)

loc_231BE:
		move.w	#$F,move_lock(a1)
		move.w	x_vel(a1),ground_vel(a1)
		btst	#Status_Roll,status(a1)
		bne.s	loc_231D8
		clr.b	anim(a1)		; id_Walk

loc_231D8:
		move.b	subtype(a0),d0
		bpl.s	loc_231E4
		clr.w	y_vel(a1)

loc_231E4:
		btst	#0,d0
		beq.s	loc_23224
		move.w	#1,ground_vel(a1)
		move.b	#1,flip_angle(a1)
		clr.b	anim(a1)		; id_Walk
		move.b	#1,flips_remaining(a1)
		move.b	#8,flip_speed(a1)
		btst	#1,d0
		bne.s	loc_23214
		move.b	#3,flips_remaining(a1)

loc_23214:
		btst	#Status_Facing,status(a1)
		beq.s	loc_23224
		neg.b	flip_angle(a1)
		neg.w	ground_vel(a1)

loc_23224:
		andi.b	#$C,d0
		cmpi.b	#4,d0
		bne.s	loc_2323A
		move.b	#$C,top_solid_bit(a1)
		move.b	#$D,lrb_solid_bit(a1)

loc_2323A:
		cmpi.b	#8,d0
		bne.s	loc_2324C
		move.b	#$E,top_solid_bit(a1)
		move.b	#$F,lrb_solid_bit(a1)

loc_2324C:
		bclr	#5,status(a0)
		bclr	#6,status(a0)
		bclr	#Status_Push,status(a1)
		clr.b	double_jump_flag(a1)
		sfx	sfx_Spring,1

; =============== S U B R O U T I N E =======================================

sub_2326C:
		cmpi.b	#3,anim(a0)
		beq.s	locret_23324
		move.w	x_pos(a0),d0
		move.w	d0,d1
		addi.w	#$28,d1
		btst	#0,status(a0)
		beq.s	loc_2328E
		move.w	d0,d1
		subi.w	#$28,d0

loc_2328E:
		move.w	y_pos(a0),d2
		move.w	d2,d3
		subi.w	#$18,d2
		addi.w	#$18,d3
		lea	(Player_1).w,a1
		btst	#Status_InAir,status(a1)
		bne.s	locret_23324
		move.w	ground_vel(a1),d4
		btst	#0,status(a0)
		beq.s	loc_232B6
		neg.w	d4

loc_232B6:
		tst.w	d4
		bmi.s	locret_23324
		move.w	x_pos(a1),d4
		cmp.w	d0,d4
		blo.s		locret_23324
		cmp.w	d1,d4
		bhs.s	locret_23324
		move.w	y_pos(a1),d4
		cmp.w	d2,d4
		blo.s		locret_23324
		cmp.w	d3,d4
		bhs.s	locret_23324
		bsr.w	sub_23190

locret_23324:
		rts

; =============== S U B R O U T I N E =======================================

Obj_Spring_Down:
		move.w	#$1B,d1
		move.w	#8,d2
		move.w	#9,d3
		move.w	x_pos(a0),d4
		lea	(Player_1).w,a1
		moveq	#p1_standing_bit,d6
		jsr	SolidObjectFull2_1P(pc)
		cmpi.w	#-2,d4
		bne.s	loc_2334C
		bsr.s	sub_233CA

loc_2334C:
		lea	Ani_Spring(pc),a1
		jsr	(Animate_Sprite).w
		jmp	(Sprite_OnScreen_Test).w

; =============== S U B R O U T I N E =======================================

sub_233CA:
		subq.w	#8,y_pos(a1)
		tst.b	(Reverse_gravity_flag).w
		beq.s	+
		addi.w	#$10,y_pos(a1)
+		move.w	#bytes_to_word(1,0),anim(a0)	; set anim and clear next_anim/prev_anim
		move.w	objoff_30(a0),y_vel(a1)
		neg.w	y_vel(a1)
		cmpi.w	#$1000,y_vel(a1)
		bne.s	loc_233F8
		move.w	#$D00,y_vel(a1)

loc_233F8:
		move.b	subtype(a0),d0
		bpl.s	loc_23404
		clr.w	x_vel(a1)

loc_23404:
		btst	#0,d0
		beq.s	loc_23444
		move.w	#1,ground_vel(a1)
		move.b	#1,flip_angle(a1)
		clr.b	anim(a1)		; id_Walk
		clr.b	flips_remaining(a1)
		move.b	#4,flip_speed(a1)
		btst	#1,d0
		bne.s	loc_23434
		move.b	#1,flips_remaining(a1)

loc_23434:
		btst	#Status_Facing,status(a1)
		beq.s	loc_23444
		neg.b	flip_angle(a1)
		neg.w	ground_vel(a1)

loc_23444:
		andi.b	#$C,d0
		cmpi.b	#4,d0
		bne.s	loc_2345A
		move.b	#$C,top_solid_bit(a1)
		move.b	#$D,lrb_solid_bit(a1)

loc_2345A:
		cmpi.b	#8,d0
		bne.s	loc_2346C
		move.b	#$E,top_solid_bit(a1)
		move.b	#$F,lrb_solid_bit(a1)

loc_2346C:
		bset	#Status_InAir,status(a1)
		bclr	#Status_OnObj,status(a1)
		clr.b	jumping(a1)
		move.b	#id_SonicControl,routine(a1)
		clr.b	double_jump_flag(a1)
		sfx	sfx_Spring,1

; =============== S U B R O U T I N E =======================================

Obj_Spring_UpDiag:
		moveq	#$1B,d1
		moveq	#$10,d2
		move.w	x_pos(a0),d4
		lea	ObjSpring_SlopeData_DiagUp(pc),a2
		lea	(Player_1).w,a1
		moveq	#p1_standing_bit,d6
		jsr	sub_1DD24(pc)
		btst	#p1_standing_bit,status(a0)
		beq.s	loc_234B8
		bsr.s	sub_234E6

loc_234B8:
		lea	Ani_Spring(pc),a1
		jsr	(Animate_Sprite).w
		move.w	objoff_32(a0),d0
		jmp	(Sprite_OnScreen_Test2).w

; =============== S U B R O U T I N E =======================================

sub_234E6:
		btst	#0,status(a0)
		bne.s	loc_234FC
		move.w	x_pos(a0),d0
		subq.w	#4,d0
		cmp.w	x_pos(a1),d0
		blo.s		loc_2350A
		rts
; ---------------------------------------------------------------------------

loc_234FC:
		move.w	x_pos(a0),d0
		addq.w	#4,d0
		cmp.w	x_pos(a1),d0
		bhs.s	loc_2350A
		rts
; ---------------------------------------------------------------------------

loc_2350A:
		move.w	#bytes_to_word(5,0),anim(a0)	; set anim and clear next_anim/prev_anim
		move.w	objoff_30(a0),y_vel(a1)
		move.w	objoff_30(a0),x_vel(a1)
		addq.w	#6,y_pos(a1)
		addq.w	#6,x_pos(a1)
		bset	#Status_Facing,status(a1)
		btst	#0,status(a0)
		bne.s	loc_23542
		bclr	#Status_Facing,status(a1)
		subi.w	#$C,x_pos(a1)
		neg.w	x_vel(a1)

loc_23542:
		bset	#Status_InAir,status(a1)
		bclr	#Status_OnObj,status(a1)
		clr.b	jumping(a1)
		move.b	#id_Spring,anim(a1)
		move.b	#id_SonicControl,routine(a1)
		move.b	subtype(a0),d0
		btst	#0,d0
		beq.s	loc_235A2
		move.w	#1,ground_vel(a1)
		move.b	#1,flip_angle(a1)
		clr.b	anim(a1)		; id_Walk
		move.b	#1,flips_remaining(a1)
		move.b	#8,flip_speed(a1)
		btst	#1,d0
		bne.s	loc_23592
		move.b	#3,flips_remaining(a1)

loc_23592:
		btst	#Status_Facing,status(a1)
		beq.s	loc_235A2
		neg.b	flip_angle(a1)
		neg.w	ground_vel(a1)

loc_235A2:
		andi.b	#$C,d0
		cmpi.b	#4,d0
		bne.s	loc_235B8
		move.b	#$C,top_solid_bit(a1)
		move.b	#$D,lrb_solid_bit(a1)

loc_235B8:
		cmpi.b	#8,d0
		bne.s	loc_235CA
		move.b	#$E,top_solid_bit(a1)
		move.b	#$F,lrb_solid_bit(a1)

loc_235CA:
		sfx	sfx_Spring,1

; =============== S U B R O U T I N E =======================================

Obj_Spring_DownDiag:
		moveq	#$1B,d1
		moveq	#$10,d2
		move.w	x_pos(a0),d4
		lea	ObjSpring_SlopeData_DiagDown(pc),a2
		lea	(Player_1).w,a1
		moveq	#p1_standing_bit,d6
		jsr	sub_1DD24(pc)
		cmpi.w	#-2,d4
		bne.s	loc_235F8
		bsr.s	sub_23624

loc_235F8:
		lea	Ani_Spring(pc),a1
		jsr	(Animate_Sprite).w
		move.w	objoff_32(a0),d0
		jmp	(Sprite_OnScreen_Test2).w

; =============== S U B R O U T I N E =======================================

sub_23624:
		move.w	#bytes_to_word(5,0),anim(a0)	; Set anim and clear next_anim/prev_anim
		move.w	objoff_30(a0),y_vel(a1)
		neg.w	y_vel(a1)
		move.w	objoff_30(a0),x_vel(a1)
		subq.w	#6,y_pos(a1)
		addq.w	#6,x_pos(a1)
		bset	#Status_Facing,status(a1)
		btst	#0,status(a0)
		bne.s	loc_23660
		bclr	#Status_Facing,status(a1)
		subi.w	#$C,x_pos(a1)
		neg.w	x_vel(a1)

loc_23660:
		bset	#Status_InAir,status(a1)
		bclr	#Status_OnObj,status(a1)
		clr.b	jumping(a1)
		move.b	#id_SonicControl,routine(a1)
		move.b	subtype(a0),d0
		btst	#0,d0
		beq.s	loc_236BA
		move.w	#1,ground_vel(a1)
		move.b	#1,flip_angle(a1)
		clr.b	anim(a1)		; id_Walk
		move.b	#1,flips_remaining(a1)
		move.b	#8,flip_speed(a1)
		btst	#1,d0
		bne.s	loc_236AA
		move.b	#3,flips_remaining(a1)

loc_236AA:
		btst	#Status_Facing,status(a1)
		beq.s	loc_236BA
		neg.b	flip_angle(a1)
		neg.w	ground_vel(a1)

loc_236BA:
		andi.b	#$C,d0
		cmpi.b	#4,d0
		bne.s	loc_236D0
		move.b	#$C,top_solid_bit(a1)
		move.b	#$D,lrb_solid_bit(a1)

loc_236D0:
		cmpi.b	#8,d0
		bne.s	loc_236E2
		move.b	#$E,top_solid_bit(a1)
		move.b	#$F,lrb_solid_bit(a1)

loc_236E2:
		sfx	sfx_Spring,1
; ---------------------------------------------------------------------------

ObjSpring_SlopeData_DiagUp:
		dc.b $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $E, $C, $A, 8
		dc.b 6, 4, 2, 0, $FE, $FC, $FC, $FC, $FC, $FC, $FC, $FC
ObjSpring_SlopeData_DiagDown:
		dc.b $F4, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F2, $F4, $F6, $F8
		dc.b $FA, $FC, $FE, 0, 2, 4, 4, 4, 4, 4, 4, 4
; ---------------------------------------------------------------------------

		include "Objects/Spring/Object Data/Anim - Spring.asm"
		include "Objects/Spring/Object Data/Map - Spring(Red).asm"
		include "Objects/Spring/Object Data/Map - Spring(Yellow).asm"
