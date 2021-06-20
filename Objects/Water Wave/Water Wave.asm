
; =============== S U B R O U T I N E =======================================

Obj_WaterWave:
		move.l	#Map_WaterWave,mappings(a0)
		move.w	#$87C0,art_tile(a0)
		move.b	#4,render_flags(a0)
		move.b	#256/2,width_pixels(a0)
		move.b	#16/2,height_pixels(a0)
		bset	#6,render_flags(a0)		; set multi-draw flag
		move.w	#1,mainspr_childsprites(a0)
		lea	sub2_x_pos(a0),a2
		move.w	x_pos(a0),(a2)
		addi.w	#$C0,(a2)+
		move.w	y_pos(a0),(a2)+
		move.l	#+,address(a0)
+		move.w	(Camera_X_pos).w,d1
		andi.w	#-$20,d1
		addi.w	#$60,d1
		btst	#0,(Level_frame_counter+1).w
		beq.s	+
		addi.w	#$20,d1
+		move.w	d1,x_pos(a0)
		move.w	(Water_level).w,d1
		move.w	d1,y_pos(a0)
		lea	sub2_x_pos(a0),a2
		move.w	x_pos(a0),(a2)
		addi.w	#$C0,(a2)+
		move.w	y_pos(a0),(a2)+
		tst.b	$32(a0)
		bne.s	+
		tst.b	(Ctrl_1_pressed_logical).w
		bpl.s	++
		addq.b	#3,mapping_frame(a0)
		move.b	#1,$32(a0)
		bra.s	+++
; ---------------------------------------------------------------------------
+		tst.b	(Game_paused).w
		bne.s	++
		clr.b	$32(a0)
		subq.b	#3,mapping_frame(a0)
+		subq.b	#1,anim_frame_timer(a0)
		bpl.s	+
		move.b	#9,anim_frame_timer(a0)
		addq.b	#1,mapping_frame(a0)
		cmpi.b	#4,mapping_frame(a0)
		bcs.s	+
		move.b	#1,mapping_frame(a0)
+		move.b	mapping_frame(a0),1(a2)
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

		include "Objects/Water Wave/Object Data/Map - Water Wave.asm"