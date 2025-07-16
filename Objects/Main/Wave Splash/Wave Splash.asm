; ---------------------------------------------------------------------------
; Wave Splash (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_WaveSplash:

		; init
		movem.l	ObjDat_WaveSplash(pc),d0-d3					; copy data to d0-d3
		movem.l	d0-d3,address(a0)						; set data from d0-d3 to current object
		move.w	#1,mainspr_childsprites(a0)
		lea	sub2_x_pos(a0),a2
		move.w	x_pos(a0),(a2)
		addi.w	#$C0,(a2)+
		move.w	y_pos(a0),(a2)+

.main
		moveq	#-32,d1								; set align (32 pixels)
		and.w	(Camera_X_pos).w,d1
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
		move.w	d1,(a2)+

		; check
		tst.b	objoff_32(a0)							; is pause flag set?
		bne.s	.checkpause							; if yes, branch
		tst.b	(Ctrl_1_pressed_logical).w					; is Start pressed?
		bpl.s	.anim								; if not, branch

		; set flag
		st	objoff_32(a0)							; set pause flag
		addq.b	#3,mapping_frame(a0)
		bra.s	.setframe
; ---------------------------------------------------------------------------

.checkpause
		tst.b	(Game_paused).w							; still pause?
		bne.s	.setframe							; if yes, branch
		clr.b	objoff_32(a0)							; clear pause flag
		subq.b	#3,mapping_frame(a0)

.anim

		; wait
		subq.b	#1,anim_frame_timer(a0)						; decrement timer
		bpl.s	.setframe							; if time remains, branch
		move.b	#9,anim_frame_timer(a0)						; reset timer to 9 frames

		; next frame
		addq.b	#1,mapping_frame(a0)
		cmpi.b	#4,mapping_frame(a0)
		blo.s	.setframe
		move.b	#1,mapping_frame(a0)

.setframe
		move.b	mapping_frame(a0),1(a2)

		; draw
		lea	(Sprite_table_input+priority_0).w,a1
		jmp	(Draw_Sprite.find).w

; =============== S U B R O U T I N E =======================================

; mapping
ObjDat_WaveSplash:	subObjMainData \
			Obj_WaveSplash.main, \
				setBit(render_flags.level) | \
				setBit(render_flags.multi_sprite), \
			0, 24, 256, 0, $300, 0, 1, Map_WaveSplash
; ---------------------------------------------------------------------------

		include "Objects/Main/Wave Splash/Object Data/Map - Wave Splash.asm"
