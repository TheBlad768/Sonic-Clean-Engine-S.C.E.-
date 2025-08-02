; ---------------------------------------------------------------------------
; Sprite mask
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_SpriteMask:
		bset	#render_flags.level,render_flags(a0)				; use screen coordinates

Obj_SpriteMask2:

		; init
		clr.w	art_tile(a0)
		move.l	#Map_SpriteMask,mappings(a0)
		move.b	#64/2,width_pixels(a0)
		move.l	#.level,address(a0)						; level
		move.b	subtype(a0),d0
		btst	#3,d0								; 8
		beq.s	.skip
		move.l	#.parent,address(a0)						; parent

.skip
		move.b	d0,d1
		andi.w	#7,d1
		andi.w	#$F0,d0
		lsr.w	#2,d0
		move.b	d0,height_pixels(a0)
		lsr.w	#2,d0
		move.b	d0,mapping_frame(a0)
		lsl.w	#7,d1								; multiply by $80
		move.w	d1,priority(a0)
		rts
; ---------------------------------------------------------------------------

.level
		st	(Spritemask_flag).w
		jmp	(Sprite_OnScreen_Test).w
; ---------------------------------------------------------------------------

.parent
		st	(Spritemask_flag).w
		movea.w	parent3(a0),a1							; a1=parent object
		btst	#5,objoff_38(a1)
		bne.s	.delete
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.delete
		jmp	(Delete_Current_Sprite).w

; =============== S U B R O U T I N E =======================================

Child6_SpriteMask:
		dc.w 1-1
		dc.l Obj_SpriteMask
Child6_SpriteMask2:
		dc.w 1-1
		dc.l Obj_SpriteMask2
; ---------------------------------------------------------------------------

		include "Objects/Main/Sprite Mask/Object Data/Map - Sprite Mask.asm"
