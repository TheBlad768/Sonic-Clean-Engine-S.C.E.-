; ---------------------------------------------------------------------------
; Spring (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_Spring:

		; init
		move.l	#Map_Spring,mappings(a0)
		move.w	#make_art_tile(ArtTile_SpikesSprings+$10,0,0),art_tile(a0)	; set red
		ori.b	#setBit(render_flags.level),render_flags(a0)			; use screen coordinates
		move.l	#bytes_word_to_long(32/2,32/2,priority_4),height_pixels(a0)	; set height, width and priority
		move.w	x_pos(a0),objoff_32(a0)
		move.w	y_pos(a0),objoff_34(a0)

		; next
		move.b	subtype(a0),d0
		lsr.w	#3,d0
		andi.w	#$E,d0
		jmp	.index(pc,d0.w)
; ---------------------------------------------------------------------------

.index
		bra.s	Spring_Up							; 0
		bra.s	Spring_Horizontal						; 2
		bra.s	Spring_Down							; 4
		bra.s	Spring_UpDiag							; 6
; ---------------------------------------------------------------------------

		; down diag								; 8
		move.b	#4,anim(a0)
		move.b	#$A,mapping_frame(a0)
		move.w	#make_art_tile($468,0,0),art_tile(a0)				; set diagonal
		bset	#status.npc.y_flip,status(a0)
		move.l	#Obj_Spring_DownDiag,address(a0)
		bra.s	Spring_Common
; ---------------------------------------------------------------------------

Spring_UpDiag:
		move.b	#4,anim(a0)
		move.b	#7,mapping_frame(a0)
		move.w	#make_art_tile($468,0,0),art_tile(a0)				; set diagonal
		move.l	#Obj_Spring_UpDiag,address(a0)
		bra.s	Spring_Common
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
		bset	#status.npc.y_flip,status(a0)

loc_22DFC:
		move.b	#6,mapping_frame(a0)
		move.l	#Obj_Spring_Down,address(a0)
		bra.s	Spring_Common
; ---------------------------------------------------------------------------

Spring_Up:
		tst.b	(Reverse_gravity_flag).w
		bne.s	loc_22DFC

loc_22E96:
		move.l	#Obj_Spring_Up,address(a0)
		tst.b	subtype(a0)
		bpl.s	Spring_Common
		move.l	#Obj_Spring_Up_NoSolid,address(a0)

Spring_Common:
		moveq	#2,d0
		and.b	subtype(a0),d0
		move.w	word_22EF0(pc,d0.w),objoff_30(a0)
		btst	#1,d0
		beq.s	locret_22EEE
		move.l	#Map_Spring2,mappings(a0)					; set yellow

locret_22EEE:
		rts
; ---------------------------------------------------------------------------

word_22EF0:	dc.w -$1000, -$A00

; =============== S U B R O U T I N E =======================================

Obj_Spring_Up:
		moveq	#(32/2)+$B,d1							; width
		moveq	#16/2,d2							; height
		moveq	#32/2,d3							; height+1
		move.w	x_pos(a0),d4
		lea	(Player_1).w,a1							; a1=character
		moveq	#p1_standing_bit,d6
		jsr	(SolidObjectFull2.check).w
		btst	#p1_standing_bit,status(a0)
		beq.s	.anim
		bsr.s	sub_22F98

.anim
		lea	Ani_Spring(pc),a1
		jsr	(Animate_Sprite).w
		jmp	(Sprite_OnScreen_Test).w

; =============== S U B R O U T I N E =======================================

Obj_Spring_Up_NoSolid:
		moveq	#(32/2)+$B,d1							; width
		moveq	#16/2,d3							; height
		move.w	x_pos(a0),d4
		lea	(Player_1).w,a1							; a1=character
		moveq	#p1_standing_bit,d6
		jsr	(SolidObjectTop.check).w
		btst	#p1_standing_bit,status(a0)
		beq.s	.anim
		bsr.s	sub_22F98

.anim
		lea	Ani_Spring(pc),a1
		jsr	(Animate_Sprite).w
		jmp	(Sprite_OnScreen_Test).w

; =============== S U B R O U T I N E =======================================

sub_22F98:
		move.w	#bytes_to_word(1,0),anim(a0)					; set anim and clear next_anim/prev_anim
		addq.w	#8,y_pos(a1)
		tst.b	(Reverse_gravity_flag).w
		beq.s	.notgrav
		subi.w	#8*2,y_pos(a1)

.notgrav
		move.w	objoff_30(a0),y_vel(a1)
		bset	#status.player.in_air,status(a1)
		bclr	#status.player.on_object,status(a1)
		clr.b	jumping(a1)
		clr.b	spin_dash_flag(a1)
		move.b	#AniIDSonAni_Spring,anim(a1)
		move.b	#PlayerID_Control,routine(a1)
		move.b	subtype(a0),d0
		btst	#0,d0
		beq.s	loc_23020
		move.w	#1,ground_vel(a1)
		move.b	#1,flip_angle(a1)
		clr.b	anim(a1)							; AniIDSonAni_Walk
		clr.b	flips_remaining(a1)
		move.b	#4,flip_speed(a1)
		btst	#1,d0
		bne.s	loc_23010
		move.b	#1,flips_remaining(a1)

loc_23010:
		btst	#status.player.x_flip,status(a1)
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
		moveq	#(16/2)+$B,d1							; width
		moveq	#28/2,d2							; height
		moveq	#(28/2)+1,d3							; height+1
		move.w	x_pos(a0),d4
		lea	(Player_1).w,a1							; a1=character
		moveq	#p1_standing_bit,d6
		jsr	(SolidObjectFull2.check).w
		swap	d6
		andi.w	#p1_touch_side,d6
		beq.s	loc_23092
		move.b	status(a0),d1
		move.w	x_pos(a0),d0
		sub.w	x_pos(a1),d0
		blo.s	loc_23088
		eori.b	#1,d1

loc_23088:
		andi.b	#1,d1
		bne.s	loc_23092
		bsr.s	sub_23190

loc_23092:
		bsr.w	sub_2326C
		lea	Ani_Spring(pc),a1
		jsr	(Animate_Sprite).w

		; draw
		moveq	#-$80,d0							; round down to nearest $80
		and.w	objoff_32(a0),d0						; get object position
		jmp	(Sprite_OnScreen_Test2).w

; =============== S U B R O U T I N E =======================================

sub_23190:
		move.w	#bytes_to_word(3,0),anim(a0)					; set anim and clear next_anim/prev_anim
		move.w	objoff_30(a0),x_vel(a1)
		addq.w	#8,x_pos(a1)
		bset	#status.player.x_flip,status(a1)
		btst	#status.npc.x_flip,status(a0)
		bne.s	loc_231BE
		bclr	#status.player.x_flip,status(a1)
		subi.w	#8*2,x_pos(a1)
		neg.w	x_vel(a1)

loc_231BE:
		move.w	#15,move_lock(a1)
		move.w	x_vel(a1),ground_vel(a1)
		btst	#status.player.rolling,status(a1)
		bne.s	loc_231D8
		clr.b	anim(a1)							; AniIDSonAni_Walk

loc_231D8:
		move.b	subtype(a0),d0
		btst	#0,d0
		beq.s	loc_23224
		move.w	#1,ground_vel(a1)
		move.b	#1,flip_angle(a1)
		clr.b	anim(a1)							; AniIDSonAni_Walk
		move.b	#1,flips_remaining(a1)
		move.b	#8,flip_speed(a1)
		btst	#1,d0
		bne.s	loc_23214
		move.b	#3,flips_remaining(a1)

loc_23214:
		btst	#status.player.x_flip,status(a1)
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
		bclr	#p1_pushing_bit,status(a0)
		bclr	#p2_pushing_bit,status(a0)
		bclr	#status.player.pushing,status(a1)
		clr.b	double_jump_flag(a1)
		sfx	sfx_Spring,1

; =============== S U B R O U T I N E =======================================

sub_2326C:
		cmpi.b	#3,anim(a0)
		beq.s	locret_23324
		move.w	x_pos(a0),d0
		move.w	d0,d1
		addi.w	#40,d1
		btst	#status.npc.x_flip,status(a0)
		beq.s	loc_2328E
		move.w	d0,d1
		subi.w	#40,d0

loc_2328E:
		move.w	y_pos(a0),d2
		move.w	d2,d3
		subi.w	#24,d2
		addi.w	#24,d3
		lea	(Player_1).w,a1							; a1=character
		tst.b	object_control(a1)
		bmi.s	locret_23324
		cmpi.b	#PlayerID_Death,routine(a1)					; has player just died?
		bhs.s	locret_23324							; if yes, branch
		tst.w	(Debug_placement_mode).w					; is debug mode on?
		bne.s	locret_23324							; if yes, branch
		btst	#status.player.in_air,status(a1)				; is the player in the air?
		bne.s	locret_23324							; if yes, branch
		move.w	ground_vel(a1),d4
		btst	#status.npc.x_flip,status(a0)
		beq.s	loc_232B6
		neg.w	d4

loc_232B6:
		tst.w	d4
		bmi.s	locret_23324
		move.w	x_pos(a1),d4
		cmp.w	d0,d4
		blo.s	locret_23324
		cmp.w	d1,d4
		bhs.s	locret_23324
		move.w	y_pos(a1),d4
		cmp.w	d2,d4
		blo.s	locret_23324
		cmp.w	d3,d4
		bhs.s	locret_23324
		bra.w	sub_23190
; ---------------------------------------------------------------------------

locret_23324:
		rts

; =============== S U B R O U T I N E =======================================

Obj_Spring_Down:
		moveq	#(32/2)+$B,d1							; width
		moveq	#16/2,d2							; height
		moveq	#(16/2)+1,d3							; height+1
		move.w	x_pos(a0),d4
		lea	(Player_1).w,a1							; a1=character
		moveq	#p1_standing_bit,d6
		jsr	(SolidObjectFull2.check).w
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
		beq.s	.notgrav
		addi.w	#8*2,y_pos(a1)

.notgrav
		move.w	#bytes_to_word(1,0),anim(a0)					; set anim and clear next_anim/prev_anim
		move.w	objoff_30(a0),y_vel(a1)
		neg.w	y_vel(a1)
		cmpi.w	#$1000,y_vel(a1)
		bne.s	loc_233F8
		move.w	#$D00,y_vel(a1)

loc_233F8:
		move.b	subtype(a0),d0
		btst	#0,d0
		beq.s	loc_23444
		move.w	#1,ground_vel(a1)
		move.b	#1,flip_angle(a1)
		clr.b	anim(a1)							; AniIDSonAni_Walk
		clr.b	flips_remaining(a1)
		move.b	#4,flip_speed(a1)
		btst	#1,d0
		bne.s	loc_23434
		move.b	#1,flips_remaining(a1)

loc_23434:
		btst	#status.player.x_flip,status(a1)
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
		bset	#status.player.in_air,status(a1)
		bclr	#status.player.on_object,status(a1)
		clr.b	jumping(a1)
		move.b	#PlayerID_Control,routine(a1)
		clr.b	double_jump_flag(a1)
		sfx	sfx_Spring,1

; =============== S U B R O U T I N E =======================================

Obj_Spring_UpDiag:
		moveq	#(32/2)+$B,d1							; width
		moveq	#32/2,d2							; height
		move.w	x_pos(a0),d4
		lea	ObjSpring_SlopeData_DiagUp(pc),a2
		lea	(Player_1).w,a1							; a1=character
		moveq	#p1_standing_bit,d6
		jsr	(SolidObjectFullSloped_Spring.check).w
		btst	#p1_standing_bit,status(a0)
		beq.s	loc_234B8
		bsr.s	sub_234E6

loc_234B8:
		lea	Ani_Spring(pc),a1
		jsr	(Animate_Sprite).w

		; draw
		moveq	#-$80,d0							; round down to nearest $80
		and.w	objoff_32(a0),d0						; get object position
		jmp	(Sprite_OnScreen_Test2).w

; =============== S U B R O U T I N E =======================================

sub_234E6:
		btst	#status.npc.x_flip,status(a0)
		bne.s	loc_234FC
		move.w	x_pos(a0),d0
		subq.w	#4,d0
		cmp.w	x_pos(a1),d0
		blo.s	loc_2350A
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
		move.w	#bytes_to_word(5,0),anim(a0)					; set anim and clear next_anim/prev_anim
		move.w	objoff_30(a0),d0
		move.w	d0,x_vel(a1)
		move.w	d0,y_vel(a1)
		addq.w	#6,y_pos(a1)
		addq.w	#6,x_pos(a1)
		bset	#status.player.x_flip,status(a1)
		btst	#status.npc.x_flip,status(a0)
		bne.s	loc_23542
		bclr	#status.player.x_flip,status(a1)
		subi.w	#6*2,x_pos(a1)
		neg.w	x_vel(a1)

loc_23542:
		bset	#status.player.in_air,status(a1)
		bclr	#status.player.on_object,status(a1)
		clr.b	jumping(a1)
		move.b	#AniIDSonAni_Spring,anim(a1)
		move.b	#PlayerID_Control,routine(a1)
		move.b	subtype(a0),d0
		btst	#0,d0
		beq.s	loc_235A2
		move.w	#1,ground_vel(a1)
		move.b	#1,flip_angle(a1)
		clr.b	anim(a1)							; AniIDSonAni_Walk
		move.b	#1,flips_remaining(a1)
		move.b	#8,flip_speed(a1)
		btst	#1,d0
		bne.s	loc_23592
		move.b	#3,flips_remaining(a1)

loc_23592:
		btst	#status.player.x_flip,status(a1)
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
		moveq	#(32/2)+$B,d1							; width
		moveq	#32/2,d2							; height
		move.w	x_pos(a0),d4
		lea	ObjSpring_SlopeData_DiagDown(pc),a2
		lea	(Player_1).w,a1							; a1=character
		moveq	#p1_standing_bit,d6
		jsr	(SolidObjectFullSloped_Spring.check).w
		cmpi.w	#-2,d4
		bne.s	loc_235F8
		bsr.s	sub_23624

loc_235F8:
		lea	Ani_Spring(pc),a1
		jsr	(Animate_Sprite).w

		; draw
		moveq	#-$80,d0							; round down to nearest $80
		and.w	objoff_32(a0),d0						; get object position
		jmp	(Sprite_OnScreen_Test2).w

; =============== S U B R O U T I N E =======================================

sub_23624:
		move.w	#bytes_to_word(5,0),anim(a0)					; set anim and clear next_anim/prev_anim
		move.w	objoff_30(a0),d0
		move.w	d0,x_vel(a1)
		move.w	d0,y_vel(a1)
		neg.w	y_vel(a1)
		subq.w	#6,y_pos(a1)
		addq.w	#6,x_pos(a1)
		bset	#status.player.x_flip,status(a1)
		btst	#status.npc.x_flip,status(a0)
		bne.s	loc_23660
		bclr	#status.player.x_flip,status(a1)
		subi.w	#6*2,x_pos(a1)
		neg.w	x_vel(a1)

loc_23660:
		bset	#status.player.in_air,status(a1)
		bclr	#status.player.on_object,status(a1)
		clr.b	jumping(a1)
		move.b	#PlayerID_Control,routine(a1)
		move.b	subtype(a0),d0
		btst	#0,d0
		beq.s	loc_236BA
		move.w	#1,ground_vel(a1)
		move.b	#1,flip_angle(a1)
		clr.b	anim(a1)							; AniIDSonAni_Walk
		move.b	#1,flips_remaining(a1)
		move.b	#8,flip_speed(a1)
		btst	#1,d0
		bne.s	loc_236AA
		move.b	#3,flips_remaining(a1)

loc_236AA:
		btst	#status.player.x_flip,status(a1)
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

; data
ObjSpring_SlopeData_DiagUp:	binclude "Objects/Main/Spring/Object Data/Heightmap1.bin"
	even
ObjSpring_SlopeData_DiagDown:	binclude "Objects/Main/Spring/Object Data/Heightmap2.bin"
	even
; ---------------------------------------------------------------------------

		include "Objects/Main/Spring/Object Data/Anim - Spring.asm"
		include "Objects/Main/Spring/Object Data/Map - Spring(Red).asm"
		include "Objects/Main/Spring/Object Data/Map - Spring(Yellow).asm"
