; ---------------------------------------------------------------------------
; Explosion (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_Explosion:

		; create animal
		jsr	(Create_New_Sprite).w
		bne.s	.skipanimal
		move.l	#Obj_Animal,address(a1)
		move.w	x_pos(a0),x_pos(a1)
		move.w	y_pos(a0),y_pos(a1)
		move.w	objoff_3E(a0),objoff_3E(a1)

.skipanimal
		sfx	sfx_Break

.skipsound

		; init
		move.l	#.main,address(a0)
		move.l	#Map_Explosion,mappings(a0)
		move.w	art_tile(a0),d0
		andi.w	#$8000,d0
		ori.w	#ArtTile_Explosion,d0						; VRAM
		move.w	d0,art_tile(a0)
		move.b	#setBit(render_flags.level),render_flags(a0)			; use screen coordinates
		clr.b	collision_flags(a0)
		move.l	#bytes_word_to_long(24/2,24/2,priority_1),height_pixels(a0)	; set height, width and priority
		move.b	#3,anim_frame_timer(a0)
		clr.b	mapping_frame(a0)

.main

		; wait
		subq.b	#1,anim_frame_timer(a0)						; decrement timer
		bpl.s	.draw								; if time remains, branch
		addq.b	#7+1,anim_frame_timer(a0)					; reset timer to 7 frames

		; next frame
		addq.b	#1,mapping_frame(a0)
		cmpi.b	#5,mapping_frame(a0)
		beq.s	Obj_TensionBridge_Explosion.delete

.draw
		jmp	(Draw_Sprite).w

; ---------------------------------------------------------------------------
; FireShield dissipate (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_FireShield_Dissipate:

		; init
		movem.l	ObjDat_FireShield_Dissipate(pc),d0-d3				; copy data to d0-d3
		movem.l	d0-d3,address(a0)						; set data from d0-d3 to current object
		move.b	#3,anim_frame_timer(a0)
		move.b	#1,mapping_frame(a0)

.main
		jsr	(MoveSprite2).w

		; wait
		subq.b	#1,anim_frame_timer(a0)						; decrement timer
		bpl.s	.draw								; if time remains, branch
		addq.b	#3+1,anim_frame_timer(a0)					; reset timer to 3 frames

		; next frame
		addq.b	#1,mapping_frame(a0)
		cmpi.b	#5,mapping_frame(a0)
		beq.s	Obj_TensionBridge_Explosion.delete

.draw
		jmp	(Draw_Sprite).w

; ---------------------------------------------------------------------------
; Tension Bridge explosion (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_TensionBridge_Explosion:

		; init
		movem.l	ObjDat_TensionBridge_Explosion(pc),d0-d3			; copy data to d0-d3
		movem.l	d0-d3,address(a0)						; set data from d0-d3 to current object
		clr.b	mapping_frame(a0)

.wait
		subq.b	#1,anim_frame_timer(a0)
		bmi.s	.set
		rts
; ---------------------------------------------------------------------------

.set
		move.b	#3,anim_frame_timer(a0)
		move.l	#.main,address(a0)

.main
		jsr	(MoveSprite2).w

		; wait
		subq.b	#1,anim_frame_timer(a0)						; decrement timer
		bpl.s	.draw								; if time remains, branch
		addq.b	#7+1,anim_frame_timer(a0)					; reset timer to 7 frames

		; next frame
		addq.b	#1,mapping_frame(a0)
		cmpi.b	#5,mapping_frame(a0)
		beq.s	.delete

.draw
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.delete
		jmp	(Delete_Current_Sprite).w

; ---------------------------------------------------------------------------
; Enemy score (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_EnemyScore:

		; init
		movem.l	ObjDat_EnemyScore(pc),d0-d3					; copy data to d0-d3
		movem.l	d0-d3,address(a0)						; set data from d0-d3 to current object
		move.w	#-$300,y_vel(a0)

.main
		MoveSprite2YOnly a0
		addi.w	#$18,y_vel(a0)
		bpl.s	Obj_TensionBridge_Explosion.delete
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

; mapping
ObjDat_FireShield_Dissipate:		subObjMainData Obj_FireShield_Dissipate.main, setBit(render_flags.level), 0, 24, 24, 5, ArtTile_Explosion, 0, 0, Map_Explosion
ObjDat_TensionBridge_Explosion:		subObjMainData Obj_TensionBridge_Explosion.wait, setBit(render_flags.level), 0, 24, 24, 2, ArtTile_Explosion, 0, 1, Map_Explosion
ObjDat_EnemyScore:			subObjMainData Obj_EnemyScore.main, setBit(render_flags.level), 0, 8, 32, 1, ArtTile_StarPost, 0, 1, Map_EnemyScore
; ---------------------------------------------------------------------------

		include "Objects/Main/Explosion/Object Data/Map - Explosion.asm"
