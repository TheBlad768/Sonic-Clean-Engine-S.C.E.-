; ---------------------------------------------------------------------------
; Bubbler (Object)
; ---------------------------------------------------------------------------

; dynamic object variables

	dsset animations_addr								; pretend we're in the RAM

bubbler.timer				ds.b 1						; current time remaining (1 byte)
bubbler.delay				ds.b 1						; time delay (1 byte)
bubbler.state_flags			ds.b 1						; (1 byte)
bubbler.type_index			ds.b 1						; (1 byte)
bubbler.types_ptr			ds.l 1						; (4 bytes)

	dsreset										; stop pretending and reset the program counter

; =============== S U B R O U T I N E =======================================

Obj_Bubbler:

		; set
		moveq	#$7F,d0
		and.b	subtype.byte(a0),d0
		move.b	d0,bubbler.timer(a0)
		move.b	d0,bubbler.delay(a0)

		; init
		movem.l	ObjDat_Bubbler(pc),d0-d3					; copy data to d0-d3
		movem.l	d0-d3,code_addr(a0)						; set data from d0-d3 to current object
		move.b	#8,anim(a0)

.main
		tst.b	bubbler.state_flags(a0)
		bne.s	.wait

		; check water
		move.w	(Water_level).w,d0
		cmp.w	y_pos(a0),d0							; is bubbler above the water?
		bhs.w	.chkdel								; if yes, branch
		tst.b	render_flags(a0)						; object visible on the screen?
		bpl.w	.chkdel								; if not, branch

		; wait
		subq.w	#1,wait_timer(a0)						; subtract 1 from time delay
		bpl.w	.anim								; if time still remains, branch
		bset	#0,bubbler.state_flags(a0)

.find_type_index
		jsr	(Random_Number).w
		move.w	d0,d1
		andi.w	#7,d0
		cmpi.w	#6,d0
		bhs.s	.find_type_index

		; set type
		move.b	d0,bubbler.type_index(a0)					; 0, 1, 2, 3, 4, 5 index only
		andi.w	#$C,d1								; 0, 4, 8, $C offset only
		lea	.types_index(pc,d1.w),a1
		move.l	a1,bubbler.types_ptr(a0)					; save current bubbles types address

		; wait
		subq.b	#1,bubbler.timer(a0)						; subtract 1 from time delay
		bpl.s	.create								; if time still remains, branch
		move.b	bubbler.delay(a0),bubbler.timer(a0)				; reset time delay

		; next
		bset	#7,bubbler.state_flags(a0)
		bra.s	.create

; ---------------------------------------------------------------------------
; bubble production sequence
; 0 = small bubble, 1 = large bubble
; ---------------------------------------------------------------------------

.types_index

		; index (0-5)
		dc.b 0, 1, 0, 0								; 0
		dc.b 0, 0, 1, 0								; 4
		dc.b 0, 0, 0, 1								; 8
		dc.b 0, 1, 0, 0								; $C
		dc.b 1, 0								; extra bytes for type index (4 and 5)
	even
; ---------------------------------------------------------------------------

.wait
		subq.w	#1,wait_timer(a0)						; subtract 1 from time delay
		bpl.w	.anim								; if time still remains, branch

.create

		; set wait time
		jsr	(Random_Number).w
		andi.w	#$1F,d0
		move.w	d0,wait_timer(a0)

		; create bubbles
		jsr	(Create_New_Object_3).w
		bne.s	.set_wait
		move.l	#Obj_Bubbler_Bubbles,code_addr(a1)
		move.l	mappings_addr(a0),mappings_addr(a1)
		move.w	art_tile(a0),art_tile(a1)
		move.l	height_pixels(a0),height_pixels(a1)				; set height, width and priority

		; set xypos
		jsr	(Random_Number).w
		andi.w	#$F,d0
		subq.w	#8,d0
		add.w	x_pos(a0),d0
		move.w	d0,x_pos(a1)
		move.w	y_pos(a0),y_pos(a1)

		; set subtype
		moveq	#0,d0
		movea.l	bubbler.types_ptr(a0),a2					; load current bubbles types address
		move.b	bubbler.type_index(a0),d0
		move.b	(a2,d0.w),subtype.byte(a1)

		; check
		btst	#7,bubbler.state_flags(a0)
		beq.s	.set_wait
		jsr	(Random_Number).w
		andi.w	#3,d0
		bne.s	.check2
		bset	#6,bubbler.state_flags(a0)
		bne.s	.set_wait
		move.b	#2,subtype.byte(a1)

.check2
		tst.b	bubbler.type_index(a0)
		bne.s	.set_wait
		bset	#6,bubbler.state_flags(a0)
		bne.s	.set_wait
		move.b	#2,subtype.byte(a1)

.set_wait
		subq.b	#1,bubbler.type_index(a0)
		bpl.s	.anim

		; set extra wait time
		jsr	(Random_Number).w
		andi.w	#$7F,d0
		addi.w	#$80,d0
		add.w	d0,wait_timer(a0)
		clr.b	bubbler.state_flags(a0)

.anim
		lea	Ani_Bubbler(pc),a1
		jsr	(Animate_SpriteNoSST).w

.chkdel
		out_of_xrange.s	.offscreen

		; check water
		move.w	(Water_level).w,d0
		cmp.w	y_pos(a0),d0							; is bubbler above the water?
		blo.s	.draw								; if not, branch
		rts
; ---------------------------------------------------------------------------

.draw
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.offscreen
		move.w	respawn_addr(a0),d0						; get address in respawn table
		beq.s	.delete								; if it's zero, it isn't remembered
		movea.w	d0,a2								; load address into a2
		bclr	#respawn_addr.state,(a2)					; turn on the slot

.delete
		jmp	(Delete_Current_Object).w

; ---------------------------------------------------------------------------
; Bubbler bubbles (Object)
; ---------------------------------------------------------------------------

; dynamic object variables

	dsset animations_addr								; pretend we're in the RAM

bubbler_bubbles.origX			ds.w 1						; original x-axis position (2 bytes)
bubbler_bubbles.flag			ds.b 1						; if set, player can collect air (1 byte)

	dsreset										; stop pretending and reset the program counter

; =============== S U B R O U T I N E =======================================

Obj_Bubbler_Bubbles:
		move.b	subtype.byte(a0),anim(a0)

		; use screen coordinates
		move.b	#( \
			setBit(render_flags.level) | \
			setBit(render_flags.on_screen) \
		),render_flags(a0)

		move.w	x_pos(a0),bubbler_bubbles.origX(a0)
		move.w	#-$88,y_vel(a0)
		jsr	(Random_Number).w
		move.b	d0,angle(a0)
		move.l	#.animate,code_addr(a0)

.animate
		lea	Ani_Bubbler(pc),a1
		jsr	(Animate_SpriteNoSST).w
		tst.b	routine(a0)							; changed by Animate_Sprite
		beq.s	.rskip
		clr.b	routine(a0)
		move.l	#.chkwater,code_addr(a0)

.rskip
		cmpi.b	#6,mapping_frame(a0)
		bne.s	.chkwater
		st	bubbler_bubbles.flag(a0)

.chkwater

		; check water
		move.w	(Water_level).w,d0
		cmp.w	y_pos(a0),d0							; is bubble above the water?
		blo.s	.wobble								; if not, branch

.burst
		addq.b	#4,anim(a0)							; burst animation
		move.l	#.burst_draw,code_addr(a0)

.burst_draw
		lea	Ani_Bubbler(pc),a1
		jsr	(Animate_SpriteNoSST).w
		tst.b	routine(a0)							; changed by Animate_Sprite
		bne.s	Obj_Bubbler.delete
		tst.b	render_flags(a0)						; object visible on the screen?
		bpl.s	Obj_Bubbler.delete						; if not, branch
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.wobble

		; wiggle the bubble left and right
		moveq	#$7F,d0
		and.b	angle(a0),d0
		addq.b	#1,angle(a0)							; next
		lea	AirCountdown_WobbleData(pc),a1
		move.b	(a1,d0.w),d0
		ext.w	d0
		add.w	bubbler_bubbles.origX(a0),d0
		move.w	d0,x_pos(a0)

		; check flag
		tst.b	bubbler_bubbles.flag(a0)
		beq.s	.wobble_draw
		bsr.s	.check_range

.wobble_draw
		jsr	(MoveSprite2).w
		tst.b	render_flags(a0)						; object visible on the screen?
		bpl.w	Obj_Bubbler.delete						; if not, branch
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.return
		rts

; =============== S U B R O U T I N E =======================================

.check_range
		tst.w	(Debug_placement_mode).w					; is debug mode on?
		bne.s	.return								; if yes, branch
		lea	(Player_1).w,a1							; a1=character

		; main
		tst.b	object_control(a1)
		bmi.s	.return
		btst	#status_secondary.bubble_shield,status_secondary(a1)		; does Sonic have a Bubble Shield?
		bne.s	.return								; if yes, branch

		; check xypos
		lea	.range(pc),a2
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
		bset	#status.player.in_air,status(a1)
		bclr	#status.player.pushing,status(a1)

	if PlayerRollJumpLock
		bclr	#status.player.rolljumping,status(a1)
	endif

		bclr	#status.player.rolling,status(a1)
		beq.s	.back

		; fix player ypos
		move.b	y_radius(a1),d0
		sub.b	default_y_radius(a1),d0
		ext.w	d0
		tst.b	(Reverse_gravity_flag).w					; are we in reverse gravity mode?
		beq.s	.notgrav							; if not, branch
		neg.w	d0

.notgrav
		add.w	d0,y_pos(a1)

.back
		move.w	default_y_radius(a1),y_radius(a1)				; set y_radius and x_radius
		bra.w	Obj_Bubbler_Bubbles.burst
; ---------------------------------------------------------------------------

.range
		dc.w -16, 32	; xpos, xpos (16 pixels width)
		dc.w 0, 16	; ypos, ypos (16 pixels height)

; =============== S U B R O U T I N E =======================================

; init
ObjDat_Bubbler:		subObjMainData \
			Obj_Bubbler.main, \
				setBit(render_flags.level) | \
				setBit(render_flags.on_screen), \
			0, 32, 32, 1, $348, 0, FALSE, Map_Bubbler
; ---------------------------------------------------------------------------

		; mappings
		include "Objects/Main/Bubbler/Object Data/Anim - Bubbler.asm"
		include "Objects/Main/Bubbler/Object Data/Map - Bubbler.asm"
