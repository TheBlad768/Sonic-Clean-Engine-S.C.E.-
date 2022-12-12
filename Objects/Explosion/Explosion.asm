; ---------------------------------------------------------------------------
; Explosion (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_Explosion:
		moveq	#0,d0
		move.b	routine(a0),d0
		move.w	off_1E5EE(pc,d0.w),d1
		jmp	off_1E5EE(pc,d1.w)
; ---------------------------------------------------------------------------

off_1E5EE: offsetTable
		offsetTableEntry.w loc_1E5F6	; 0
		offsetTableEntry.w loc_1E61A	; 2
		offsetTableEntry.w loc_1E66E	; 4
		offsetTableEntry.w loc_1E626	; 6
; ---------------------------------------------------------------------------

loc_1E5F6:
		addq.b	#2,routine(a0)
		jsr	(Create_New_Sprite).w
		bne.s	loc_1E61A
		move.l	#Obj_Animal,address(a1)
		move.w	x_pos(a0),x_pos(a1)
		move.w	y_pos(a0),y_pos(a1)
		move.w	objoff_3E(a0),objoff_3E(a1)

loc_1E61A:
		sfx	sfx_Break
		addq.b	#2,routine(a0)

loc_1E626:
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
		move.l	#loc_1E66E,address(a0)

loc_1E66E:
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	+
		move.b	#7,anim_frame_timer(a0)
		addq.b	#1,mapping_frame(a0)
		cmpi.b	#5,mapping_frame(a0)
		beq.w	loc_1E758
+		jmp	(Draw_Sprite).w
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
		move.l	#+,address(a0)
+		jsr	(MoveSprite2).w
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	+
		move.b	#3,anim_frame_timer(a0)
		addq.b	#1,mapping_frame(a0)
		cmpi.b	#5,mapping_frame(a0)
		beq.s	loc_1E758
+		jmp	(Draw_Sprite).w
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
		move.l	#+,address(a0)
+		subq.b	#1,anim_frame_timer(a0)
		bmi.s	+
		rts
; ---------------------------------------------------------------------------
+		move.b	#3,anim_frame_timer(a0)
		move.l	#+,address(a0)
+		jsr	(MoveSprite2).w
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	+
		move.b	#7,anim_frame_timer(a0)
		addq.b	#1,mapping_frame(a0)
		cmpi.b	#5,mapping_frame(a0)
		beq.s	loc_1E758
+		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

loc_1E758:
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
		move.b	#16/2,width_pixels(a0)
		move.w	#-$300,y_vel(a0)
		move.l	#.main,address(a0)

.main
		jsr	(MoveSprite2).w
		addi.w	#$18,y_vel(a0)
		bpl.s	loc_1E758
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

		include "Objects/Explosion/Object Data/Map - Explosion.asm"
