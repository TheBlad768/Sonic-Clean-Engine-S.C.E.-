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
		move.l	#.main,address(a0)
		move.l	#Map_Explosion,mappings(a0)
		move.w	art_tile(a0),d0
		andi.w	#$8000,d0
		ori.w	#$5A0,d0
		move.w	d0,art_tile(a0)
		move.b	#4,render_flags(a0)
		move.w	#$80,priority(a0)
		clr.b	collision_flags(a0)
		move.w	#bytes_to_word(24/2,24/2),height_pixels(a0)		; set height and width
		move.b	#3,anim_frame_timer(a0)
		clr.b	mapping_frame(a0)

.main
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	.draw
		move.b	#7,anim_frame_timer(a0)
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
		move.l	#Map_Explosion,mappings(a0)
		move.w	#$5A0,art_tile(a0)
		move.b	#4,render_flags(a0)
		move.w	#$280,priority(a0)
		move.w	#bytes_to_word(24/2,24/2),height_pixels(a0)		; set height and width
		move.b	#3,anim_frame_timer(a0)
		move.b	#1,mapping_frame(a0)
		move.l	#.main,address(a0)

.main
		jsr	(MoveSprite2).w
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	.draw
		move.b	#3,anim_frame_timer(a0)
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
		move.l	#Map_Explosion,mappings(a0)
		move.w	#$85A0,art_tile(a0)
		move.b	#4,render_flags(a0)
		move.w	#$100,priority(a0)
		move.w	#bytes_to_word(24/2,24/2),height_pixels(a0)		; set height and width
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
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	.draw
		move.b	#7,anim_frame_timer(a0)
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
		move.l	#Map_EnemyScore,mappings(a0)
		move.w	#make_art_tile(ArtTile_StarPost,0,1),art_tile(a0)
		move.b	#4,render_flags(a0)
		move.w	#$80,priority(a0)
		move.w	#bytes_to_word(8/2,32/2),height_pixels(a0)		; set height and width
		move.w	#-$300,y_vel(a0)
		move.l	#.main,address(a0)

.main
		jsr	(MoveSprite2).w
		addi.w	#$18,y_vel(a0)
		bpl.s	sub_1E6EC.delete
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

		include "Objects/Explosion/Object Data/Map - Explosion.asm"
