; ---------------------------------------------------------------------------
; Dash Dust (Object)
; ---------------------------------------------------------------------------

; dynamic object variables

	dsset aniraw_ptr								; pretend we're in the RAM

dashdust =			*

.timer				ds.b 1							; (1 byte)
.tails_flag			ds.b 1							; (1 byte)

	dsreset										; stop pretending and reset the program counter

; =============== S U B R O U T I N E =======================================

Obj_DashDust:

		; init
		movem.l	ObjDat_DashDust(pc),d0-d3					; copy data to d0-d3
		movem.l	d0-d3,address(a0)						; set data from d0-d3 to current object
		move.w	#Player_1,parent(a0)

		; check Tails
		cmpa.w	#Dust,a0
		beq.s	.main
		st	dashdust.tails_flag(a0)						; Tails flag

.main
		movea.w	parent(a0),a2							; a2=character
		moveq	#0,d0
		move.b	anim(a0),d0							; use current animation as a secondary routine counter
		beq.s	.return								; 0 (null)
		add.w	d0,d0
		jmp	.index-2(pc,d0.w)
; ---------------------------------------------------------------------------

.return
		rts
; ---------------------------------------------------------------------------

.index
		bra.s	.splash								; 1
		bra.s	.spindashdust							; 2

; =============== S U B R O U T I N E =======================================

		; fromground								; 3 (LBZ1 only)
		tst.b	prev_anim(a0)
		bne.s	.anim
		move.w	x_pos(a2),x_pos(a0)
		clr.b	status(a0)
		andi.w	#drawing_mask,art_tile(a0)

.anim
		lea	Ani_DashSplashDrown(pc),a1
		jsr	(Animate_Sprite).w

		; draw
		lea	PLCPtr_SplashDrown(pc),a2
		jsr	(Perform_DPLC).w
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.splash
		move.w	(Water_level).w,y_pos(a0)
		tst.b	prev_anim(a0)
		bne.s	.draw
		move.w	x_pos(a2),x_pos(a0)
		clr.b	status(a0)
		andi.w	#drawing_mask,art_tile(a0)
		bra.s	.draw
; ---------------------------------------------------------------------------

.spindashdust

		; check
		cmpi.b	#12,air_left(a2)						; check air remaining
		blo.s	.reset								; if less than 12, branch
		cmpi.b	#PlayerID_Hurt,routine(a2)					; is player falling back from getting hurt?
		bhs.s	.reset								; if yes, branch
		tst.b	spin_dash_flag(a2)						; is player charging his spin dash?
		beq.s	.reset								; if not, branch

		; start dust
		move.w	x_pos(a2),x_pos(a0)
		move.w	y_pos(a2),y_pos(a0)
		move.b	status(a2),status(a0)
		andi.b	#setBit(status.npc.x_flip),status(a0)
		moveq	#4,d1
		tst.b	(Reverse_gravity_flag).w
		beq.s	.notgrav
		ori.b	#setBit(status.npc.y_flip),status(a0)
		neg.w	d1

.notgrav
		tst.b	dashdust.tails_flag(a0)
		beq.s	.skip
		sub.w	d1,y_pos(a0)

.skip
		tst.b	prev_anim(a0)
		bne.s	.draw
		andi.w	#drawing_mask,art_tile(a0)
		tst.w	art_tile(a2)
		bpl.s	.draw
		ori.w	#high_priority,art_tile(a0)

.draw
		lea	Ani_DashSplashDrown(pc),a1
		jsr	(Animate_Sprite).w

		; check reset frame
		tst.b	anim(a0)							; changed by Animate_Sprite
		beq.s	.reset

		; draw
		lea	PLCPtr_DashDust(pc),a2
		jsr	(Perform_DPLC).w
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.reset
		clr.b	anim(a0)							; set null
		clr.w	mapping_frame(a0)						; clear mapping frame and anim frame
		clr.b	anim_frame_timer(a0)
		rts

; ---------------------------------------------------------------------------
; Dash Dust (Check skid)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

DashDust_CheckSkid:
		movea.w	parent(a0),a2							; a2=character
		moveq	#16,d1
		cmpi.b	#AniIDSonAni_Stop,anim(a2)					; is Sonic stopped?
		beq.s	.create								; if so, branch
		cmpi.b	#PlayerID_Knuckles,character_id(a2)				; is player Knuckles?
		bne.s	.back								; if not, branch
		moveq	#6,d1
		cmpi.b	#3,double_jump_flag(a2)						; is Knuckles sliding across the ground after gliding?
		beq.s	.create								; if so, branch

.back
		move.l	#Obj_DashDust.main,address(a0)					; back
		clr.b	dashdust.timer(a0)						; clear timer
		rts
; ---------------------------------------------------------------------------

.create

		; wait
		subq.b	#1,dashdust.timer(a0)						; decrement timer
		bpl.s	.dplc								; if time remains, branch
		addq.b	#3+1,dashdust.timer(a0)						; reset timer to 3+1 frames

		; check
		btst	#status.player.underwater,status(a2)				; is player underwater?
		bne.s	.dplc								; if yes, branch

		; create dust clouds
		jsr	(Create_New_Object).w
		bne.s	.dplc
		move.l	#Obj_DashDust_SkidDust,address(a1)
		move.w	x_pos(a2),x_pos(a1)
		move.w	y_pos(a2),y_pos(a1)
		tst.b	dashdust.tails_flag(a0)
		beq.s	.skip
		subq.w	#4,d1

.skip
		tst.b	(Reverse_gravity_flag).w
		beq.s	.notgrav
		neg.w	d1

.notgrav
		add.w	d1,y_pos(a1)
		clr.b	status(a1)
		move.b	#4,anim(a1)							; skid dust anim
		move.l	mappings(a0),mappings(a1)
		move.b	render_flags(a0),render_flags(a1)
		move.l	#bytes_word_to_long(8/2,8/2,priority_1),height_pixels(a1)	; set height, width and priority
		move.w	art_tile(a0),art_tile(a1)
		move.w	parent(a0),parent(a1)
		andi.w	#drawing_mask,art_tile(a1)
		tst.w	art_tile(a2)
		bpl.s	.dplc
		ori.w	#high_priority,art_tile(a1)

.dplc
		lea	PLCPtr_DashDust(pc),a2
		jmp	(Perform_DPLC).w

; ---------------------------------------------------------------------------
; Dash Dust (Skid dust)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_DashDust_SkidDust:
		movea.w	parent(a0),a2							; a2=character

		; check
		cmpi.b	#12,air_left(a2)						; check air remaining
		blo.s	.delete								; if less than 12, branch
		btst	#status.player.underwater,status(a2)				; is player underwater?
		bne.s	.delete								; if yes, branch

		; draw
		lea	Ani_DashSplashDrown(pc),a1
		jsr	(Animate_Sprite).w
		tst.b	routine(a0)							; changed by Animate_Sprite
		bne.s	.delete

		; draw
		lea	PLCPtr_DashDust(pc),a2
		jsr	(Perform_DPLC).w
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.delete
		jmp	(Delete_Current_Object).w

; =============== S U B R O U T I N E =======================================

; init
ObjDat_DashDust:	subObjMainData \
			Obj_DashDust.main, \
				setBit(render_flags.level), \
			0, 32, 32, 1, ArtTile_DashDust, 0, FALSE, Map_DashDust

; dplc
PLCPtr_DashDust:	DPLCEntry ArtUnc_DashDust, DPLC_DashSplashDrown
PLCPtr_SplashDrown:	DPLCEntry ArtUnc_SplashDrown, DPLC_DashSplashDrown
; ---------------------------------------------------------------------------

		; mappings
		include "Objects/Players/Spin Dust/Object Data/Anim - Dash Splash Drown.asm"
		include "Objects/Players/Spin Dust/Object Data/Map - Dash Dust.asm"
		include "Objects/Players/Spin Dust/Object Data/DPLC - Dash Splash Drown.asm"
