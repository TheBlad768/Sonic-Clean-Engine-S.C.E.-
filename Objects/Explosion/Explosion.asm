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
		ori.w	#ArtTile_Explosion,d0							; VRAM
		move.w	d0,art_tile(a0)
		move.b	#4,render_flags(a0)							; use screen coordinates
		clr.b	collision_flags(a0)
		move.l	#bytes_word_to_long(24/2,24/2,priority_1),height_pixels(a0)	; set height, width and priority
		move.b	#3,anim_frame_timer(a0)
		clr.b	mapping_frame(a0)

.main

		; wait
		subq.b	#1,anim_frame_timer(a0)						; decrement timer
		bpl.s	.draw										; if time remains, branch
		addq.b	#7+1,anim_frame_timer(a0)					; reset timer to 7 frames

		; next frame
		addq.b	#1,mapping_frame(a0)
		cmpi.b	#5,mapping_frame(a0)
		beq.w	sub_1E6EC.delete

.draw
		jmp	(Draw_Sprite).w

; ---------------------------------------------------------------------------
; FireShield dissipate (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_FireShield_Dissipate:

		; init
		move.l	#Map_Explosion,mappings(a0)
		move.w	#make_art_tile(ArtTile_Explosion,0,0),art_tile(a0)
		move.b	#4,render_flags(a0)							; use screen coordinates
		move.l	#bytes_word_to_long(24/2,24/2,priority_5),height_pixels(a0)	; set height, width and priority
		move.b	#3,anim_frame_timer(a0)
		move.b	#1,mapping_frame(a0)
		move.l	#.main,address(a0)

.main
		jsr	(MoveSprite2).w

		; wait
		subq.b	#1,anim_frame_timer(a0)						; decrement timer
		bpl.s	.draw										; if time remains, branch
		addq.b	#3+1,anim_frame_timer(a0)					; reset timer to 3 frames

		; next frame
		addq.b	#1,mapping_frame(a0)
		cmpi.b	#5,mapping_frame(a0)
		beq.s	sub_1E6EC.delete

.draw
		jmp	(Draw_Sprite).w

; ---------------------------------------------------------------------------
; Extra explosion (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

sub_1E6EC:

		; init
		move.l	#Map_Explosion,mappings(a0)
		move.w	#make_art_tile(ArtTile_Explosion,0,1),art_tile(a0)
		move.b	#4,render_flags(a0)							; use screen coordinates
		move.l	#bytes_word_to_long(24/2,24/2,priority_2),height_pixels(a0)	; set height, width and priority
		clr.b	mapping_frame(a0)
		move.l	#.wait,address(a0)

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
		bpl.s	.draw										; if time remains, branch
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
		move.l	#Map_EnemyScore,mappings(a0)
		move.w	#make_art_tile(ArtTile_StarPost,0,1),art_tile(a0)
		move.b	#4,render_flags(a0)							; use screen coordinates
		move.l	#bytes_word_to_long(8/2,32/2,priority_1),height_pixels(a0)	; set height, width and priority
		move.w	#-$300,y_vel(a0)
		move.l	#.main,address(a0)

.main
		jsr	(MoveSprite2).w
		addi.w	#$18,y_vel(a0)
		bpl.s	sub_1E6EC.delete
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

		include "Objects/Explosion/Object Data/Map - Explosion.asm"
