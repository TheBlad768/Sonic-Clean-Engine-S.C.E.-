; ---------------------------------------------------------------------------
; Bubbler (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_Bubbler:

		; set
		moveq	#$7F,d0
		and.b	subtype(a0),d0
		move.b	d0,objoff_32(a0)
		move.b	d0,objoff_33(a0)

		; init
		movem.l	ObjDat_Bubbler(pc),d0-d3					; copy data to d0-d3
		movem.l	d0-d3,address(a0)						; set data from d0-d3 to current object
		move.b	#8,anim(a0)

.main
		tst.w	objoff_36(a0)
		bne.s	loc_2FAB2
		move.w	(Water_level).w,d0
		cmp.w	y_pos(a0),d0
		bhs.w	loc_2FB5C
		tst.b	render_flags(a0)						; object visible on the screen?
		bpl.w	loc_2FB5C							; if not, branch
		subq.w	#1,objoff_38(a0)
		bpl.w	loc_2FB50
		move.w	#1,objoff_36(a0)

loc_2FA78:
		jsr	(Random_Number).w
		move.w	d0,d1
		andi.w	#7,d0
		cmpi.w	#6,d0
		bhs.s	loc_2FA78
		move.b	d0,objoff_34(a0)
		andi.w	#$C,d1
		lea	Bub_BblTypes(pc,d1.w),a1
		move.l	a1,objoff_3C(a0)						; save "Bub_BblTypes" address
		subq.b	#1,objoff_32(a0)
		bpl.s	loc_2FABA
		move.b	objoff_33(a0),objoff_32(a0)
		bset	#7,objoff_36(a0)
		bra.s	loc_2FABA

; ---------------------------------------------------------------------------
; bubble production sequence
; 0 = small bubble, 1 =	large bubble
; ---------------------------------------------------------------------------

Bub_BblTypes:	dc.b 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0
	even
; ---------------------------------------------------------------------------

loc_2FAB2:
		subq.w	#1,objoff_38(a0)
		bpl.w	loc_2FB50

loc_2FABA:
		jsr	(Random_Number).w
		andi.w	#$1F,d0
		move.w	d0,objoff_38(a0)

		; create bubbles
		jsr	(Create_New_Sprite3).w
		bne.s	loc_2FB34
		move.l	#Obj_Bubbler_Bubbles,address(a1)
		move.l	mappings(a0),mappings(a1)
		move.w	art_tile(a0),art_tile(a1)
		move.w	priority(a0),priority(a1)
		move.w	height_pixels(a0),height_pixels(a1)				; set height and width
		move.w	x_pos(a0),x_pos(a1)
		jsr	(Random_Number).w
		andi.w	#$F,d0
		subq.w	#8,d0
		add.w	d0,x_pos(a1)
		move.w	y_pos(a0),y_pos(a1)
		moveq	#0,d0
		move.b	objoff_34(a0),d0
		movea.l	objoff_3C(a0),a2						; load "Bub_BblTypes" address
		move.b	(a2,d0.w),subtype(a1)
		btst	#7,objoff_36(a0)
		beq.s	loc_2FB34
		jsr	(Random_Number).w
		andi.w	#3,d0
		bne.s	loc_2FB20
		bset	#6,objoff_36(a0)
		bne.s	loc_2FB34
		move.b	#2,subtype(a1)

loc_2FB20:
		tst.b	objoff_34(a0)
		bne.s	loc_2FB34
		bset	#6,objoff_36(a0)
		bne.s	loc_2FB34
		move.b	#2,subtype(a1)

loc_2FB34:
		subq.b	#1,objoff_34(a0)
		bpl.s	loc_2FB50
		jsr	(Random_Number).w
		andi.w	#$7F,d0
		addi.w	#$80,d0
		add.w	d0,objoff_38(a0)
		clr.w	objoff_36(a0)

loc_2FB50:
		lea	Ani_Bubbler(pc),a1
		jsr	(Animate_Sprite).w

loc_2FB5C:
		out_of_xrange.s	.offscreen

		; check water
		move.w	(Water_level).w,d0
		cmp.w	y_pos(a0),d0
		blo.s	.draw
		rts
; ---------------------------------------------------------------------------

.draw
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.offscreen
		move.w	respawn_addr(a0),d0						; get address in respawn table
		beq.s	Bubbler_Delete							; if it's zero, it isn't remembered
		movea.w	d0,a2								; load address into a2
		bclr	#7,(a2)

Bubbler_Delete:
		jmp	(Delete_Current_Sprite).w

; ---------------------------------------------------------------------------
; Bubbler (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_Bubbler_Bubbles:
		move.b	subtype(a0),anim(a0)

		; use screen coordinates
		move.b	#( \
			setBit(render_flags.level) | \
			setBit(render_flags.on_screen) \
		),render_flags(a0)

		move.w	x_pos(a0),objoff_30(a0)
		move.w	#-$88,y_vel(a0)
		jsr	(Random_Number).w
		move.b	d0,angle(a0)
		move.l	#.animate,address(a0)

.animate
		lea	Ani_Bubbler(pc),a1
		jsr	(Animate_Sprite).w
		tst.b	routine(a0)
		beq.s	.rskip
		clr.b	routine(a0)
		move.l	#.chkwater,address(a0)

.rskip
		cmpi.b	#6,mapping_frame(a0)
		bne.s	.chkwater
		move.b	#1,objoff_2E(a0)

.chkwater
		move.w	(Water_level).w,d0
		cmp.w	y_pos(a0),d0
		blo.s	loc_2F9E2

.sanim
		addq.b	#4,anim(a0)
		move.l	#Bubbler_Bubbles_Display,address(a0)

Bubbler_Bubbles_Display:
		lea	Ani_Bubbler(pc),a1
		jsr	(Animate_Sprite).w
		tst.b	routine(a0)
		bne.s	Bubbler_Delete
		tst.b	render_flags(a0)						; object visible on the screen?
		bpl.s	Bubbler_Delete							; if not, branch
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

loc_2F9E2:
		moveq	#$7F,d0
		and.b	angle(a0),d0
		addq.b	#1,angle(a0)
		lea	AirCountdown_WobbleData(pc),a1
		move.b	(a1,d0.w),d0
		ext.w	d0
		add.w	objoff_30(a0),d0
		move.w	d0,x_pos(a0)
		tst.b	objoff_2E(a0)
		beq.s	loc_2FA14
		bsr.s	sub_2FBA8

loc_2FA14:
		jsr	(MoveSprite2).w
		tst.b	render_flags(a0)						; object visible on the screen?
		bpl.w	Bubbler_Delete							; if not, branch
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

sub_2FBA8:
		tst.w	(Debug_placement_mode).w					; is debug mode on?
		bne.s	.return								; if yes, branch
		lea	(Player_1).w,a1							; a1=character

		; main
		tst.b	object_control(a1)
		bmi.s	.return
		btst	#shield_reaction.bubble_shield,shield_reaction(a1)
		bne.s	.return

		; check xypos
		lea	.xydata(pc),a2
		jsr	(Check_InMyRange).w
		beq.s	.return

		; get air
		bsr.w	Player_ResetAirTimer
		sfx	sfx_Bubble
		clr.l	x_vel(a1)
		clr.w	ground_vel(a1)
		move.b	#AniIDSonAni_GetAir,anim(a1)
		move.w	#35,move_lock(a1)
		clr.b	jumping(a1)
		clr.b	double_jump_flag(a1)
		clr.b	spin_dash_flag(a1)
		bclr	#status.player.pushing,status(a1)
		bclr	#status.player.rolling,status(a1)
		beq.s	.back

		; fix player ypos
		move.b	y_radius(a1),d0
		sub.b	default_y_radius(a1),d0
		ext.w	d0
		tst.b	(Reverse_gravity_flag).w
		beq.s	.notgrav
		neg.w	d0

.notgrav
		add.w	d0,y_pos(a1)

.back
		move.w	default_y_radius(a1),y_radius(a1)				; set y_radius and x_radius
		bra.w	Obj_Bubbler_Bubbles.sanim
; ---------------------------------------------------------------------------

.return
		rts
; ---------------------------------------------------------------------------

.xydata
		dc.w -16, 32	; xpos
		dc.w 0, 16	; ypos

; =============== S U B R O U T I N E =======================================

; mapping
ObjDat_Bubbler:		subObjMainData \
			Obj_Bubbler.main, \
				setBit(render_flags.level) | \
				setBit(render_flags.on_screen), \
			0, 32, 32, 1, $348, 0, 0, Map_Bubbler
; ---------------------------------------------------------------------------

		include "Objects/Main/Bubbler/Object Data/Anim - Bubbler.asm"
		include "Objects/Main/Bubbler/Object Data/Map - Bubbler.asm"
