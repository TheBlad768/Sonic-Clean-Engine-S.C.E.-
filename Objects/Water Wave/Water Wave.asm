; ---------------------------------------------------------------------------
; Water Wave (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_WaterWave:
		move.l	#Map_WaterWave,mappings(a0)
		move.w	#$87C0,art_tile(a0)
		move.b	#rfCoord+rfMulti,render_flags(a0)		; set screen coordinates and multi-draw flag
		move.w	#bytes_to_word(24/2,256/2),height_pixels(a0)	; set height and width
		move.w	#1,mainspr_childsprites(a0)
		lea	sub2_x_pos(a0),a2
		move.w	x_pos(a0),(a2)
		addi.w	#$C0,(a2)+
		move.w	y_pos(a0),(a2)+
		move.l	#.main,address(a0)

.main
		move.w	(Camera_X_pos).w,d1
		andi.w	#$FFE0,d1
		addi.w	#96,d1
		btst	#0,(Level_frame_counter+1).w
		beq.s	.skip
		addi.w	#32,d1

.skip
		move.w	d1,x_pos(a0)
		move.w	(Water_level).w,d1
		move.w	d1,y_pos(a0)
		lea	sub2_x_pos(a0),a2
		move.w	x_pos(a0),(a2)
		addi.w	#$C0,(a2)+
		move.w	y_pos(a0),(a2)+

		tst.b	objoff_32(a0)					; is pause flag set?
		bne.s	.checkpause				; if yes, branch
		tst.b	(Ctrl_1_pressed_logical).w		; is Start pressed?
		bpl.s	.anim					; if not, branch
		addq.b	#3,mapping_frame(a0)
		st	objoff_32(a0)					; set pause flag
		bra.s	.setframe
; ---------------------------------------------------------------------------

.checkpause
		tst.b	(Game_paused).w				; still pause?
		bne.s	.setframe					; if yes, branch
		clr.b	objoff_32(a0)					; clear pause flag
		subq.b	#3,mapping_frame(a0)

.anim
		subq.b	#1,anim_frame_timer(a0)
		bpl.s	.setframe
		move.b	#9,anim_frame_timer(a0)
		addq.b	#1,mapping_frame(a0)
		cmpi.b	#4,mapping_frame(a0)
		blo.s		.setframe
		move.b	#1,mapping_frame(a0)

.setframe
		move.b	mapping_frame(a0),1(a2)
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

		include "Objects/Water Wave/Object Data/Map - Water Wave.asm"
