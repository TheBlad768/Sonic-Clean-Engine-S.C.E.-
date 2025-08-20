; ---------------------------------------------------------------------------
; Subroutine to convert mappings (etc) to proper Megadrive sprites
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Init_SpriteTable:
		clearRAM Sprite_table_input, Sprite_table_input_end

		; clear
		move.b	d0,(Spritemask_flag).w
		lea	(Sprite_table_buffer).w,a0
		moveq	#1,d1								; set link number
		moveq	#80-1,d7

.loop
		move.w	d0,(a0)
		move.b	d1,3(a0)							; set link number
		addq.w	#1,d1								; next link number
		addq.w	#8,a0
		dbf	d7,.loop
		move.b	d0,-5(a0)
		rts

; =============== S U B R O U T I N E =======================================

Render_Sprites:
		moveq	#80-1,d7
		moveq	#0,d6
		lea	(Sprite_table_input).w,a5
		lea	(Camera_X_pos_copy).w,a3
		lea	(Sprite_table_buffer).w,a6

		; check
		tst.b	(Level_started_flag).w
		beq.s	Render_Sprites_LevelLoop

		; render first extra sprites
		lea	(Render_sprite_first_RAM).w,a2

.loop
		move.l	(a2)+,d0
		beq.s	Render_Sprites_LevelLoop

		; jump
		movea.l	d0,a1
		jsr	(a1)

		; next
		bra.s	.loop
; ---------------------------------------------------------------------------

Render_Sprites_LevelLoop:
		tst.w	(a5)								; does this level have any objects?
		beq.w	Render_Sprites_NextLevel					; if not, check the next one
		lea	2(a5),a4

Render_Sprites_ObjLoop:
		movea.w	(a4)+,a0							; a0=object

	ifdef __DEBUG__	; assert is only available in DEBUG builds
		jsr	(Render_Sprites_Assert).l						; raise an error if there is no object or mappings address here
	endif

		; clear on-screen flag
		andi.b	#signextendB( \
			~setBit(render_flags.on_screen)&$FF \
		),render_flags(a0)

		move.b	render_flags(a0),d6
		move.w	x_pos(a0),d0
		move.w	y_pos(a0),d1
		btst	#render_flags.multi_sprite,d6					; is the multi-draw flag set?
		bne.w	Render_Sprites_MultiDraw					; if it is, branch
		btst	#render_flags.level,d6						; is this to be positioned by screen coordinates?
		beq.s	Render_Sprites_ScreenSpaceObj					; if not, branch
		moveq	#0,d2
		move.b	width_pixels(a0),d2
		sub.w	(a3),d0
		move.w	d0,d3
		add.w	d2,d3								; is the object right edge to the left of the screen?
		bmi.s	Render_Sprites_NextObj						; if it is, branch
		move.w	d0,d3
		sub.w	d2,d3
		cmpi.w	#320,d3								; is the object left edge to the right of the screen?
		bge.s	Render_Sprites_NextObj						; if it is, branch
		addi.w	#128,d0
		sub.w	4(a3),d1
		move.b	height_pixels(a0),d2
		add.w	d2,d1
		and.w	(Screen_Y_wrap_value).w,d1
		move.w	d2,d3
		add.w	d2,d2
		addi.w	#224,d2
		cmp.w	d2,d1
		bhs.s	Render_Sprites_NextObj						; if the object is below the screen
		addi.w	#128,d1
		sub.w	d3,d1

Render_Sprites_ScreenSpaceObj:
		ori.b	#setBit(render_flags.on_screen),render_flags(a0)		; set on-screen flag
		tst.w	d7
		bmi.s	Render_Sprites_NextObj
		movea.l	mappings(a0),a1
		moveq	#0,d4
		btst	#render_flags.static_mappings,d6				; is the static mappings flag set?
		bne.s	.load								; if it is, branch

		; calc
		move.b	mapping_frame(a0),d4
		add.w	d4,d4
		adda.w	(a1,d4.w),a1
		move.w	(a1)+,d4
		subq.w	#1,d4								; get number of pieces
		bmi.s	Render_Sprites_NextObj						; if there are 0 pieces, branch

.load
		move.w	art_tile(a0),d5
		bsr.w	sub_1AF6C

Render_Sprites_NextObj:
		subq.w	#2,(a5)								; decrement object count
		bne.w	Render_Sprites_ObjLoop						; if there are objects left, repeat

Render_Sprites_NextLevel:
		cmpa.w	#Sprite_table_input,a5
		bne.s	Render_Sprites_NextLevel2

		; render last extra sprites
		move.l	(Render_sprite_last_RAM).w,d0
		beq.s	Render_Sprites_NextLevel2
		movea.l	d0,a1
		jsr	(a1)

Render_Sprites_NextLevel2:
		lea	$80(a5),a5							; load next priority level
		cmpa.w	#Sprite_table_input_end,a5
		blo.w	Render_Sprites_LevelLoop

		; finish
		move.w	d7,d6
		bmi.s	.end
		moveq	#0,d0

.clear
		move.w	d0,(a6)
		addq.w	#8,a6
		dbf	d7,.clear

.end
		subi.w	#80-1,d6
		neg.w	d6
		move.b	d6,(Sprites_drawn).w

		; sprite mask
		tst.b	(Spritemask_flag).w
		beq.s	locret_1AE56
		cmpi.b	#PlayerID_Death,(Player_1+routine).w				; has Sonic just died?
		bhs.s	loc_1AE34							; if yes, branch
		clr.b	(Spritemask_flag).w

loc_1AE34:
		lea	(Sprite_table_buffer-4).w,a0
		move.w	#$7C0,d0
		moveq	#(Sprite_table_buffer_end-Sprite_table_buffer)/8-2,d1

loc_1AE3E:
		addq.w	#8,a0
		cmp.w	(a0),d0
		dbeq	d1,loc_1AE3E
		bne.s	locret_1AE56
		move.w	#1,2(a0)
		clr.w	$A(a0)
		dbf	d1,loc_1AE3E

locret_1AE56:
		rts

; =============== S U B R O U T I N E =======================================

Render_Sprites_MultiDraw:
		btst	#render_flags.level,d6						; is this to be positioned by screen coordinates?
		bne.s	loc_1AEA2							; if it is, branch
		moveq	#0,d2

		; check if object is within X bounds
		move.b	width_pixels(a0),d2
		subi.w	#128,d0
		move.w	d0,d3
		add.w	d2,d3
		bmi.w	Render_Sprites_NextObj
		move.w	d0,d3
		sub.w	d2,d3
		cmpi.w	#320,d3
		bge.w	Render_Sprites_NextObj
		addi.w	#128,d0

		; check if object is within Y bounds
		move.b	height_pixels(a0),d2
		subi.w	#128,d1
		move.w	d1,d3
		add.w	d2,d3
		bmi.w	Render_Sprites_NextObj
		move.w	d1,d3
		sub.w	d2,d3
		cmpi.w	#224,d3
		bge.w	Render_Sprites_NextObj
		addi.w	#128,d1
		bra.s	loc_1AEE4
; ---------------------------------------------------------------------------

loc_1AEA2:
		moveq	#0,d2
		move.b	width_pixels(a0),d2
		sub.w	(a3),d0
		move.w	d0,d3
		add.w	d2,d3
		bmi.w	Render_Sprites_NextObj
		move.w	d0,d3
		sub.w	d2,d3
		cmpi.w	#320,d3
		bge.w	Render_Sprites_NextObj
		addi.w	#128,d0
		sub.w	4(a3),d1
		move.b	height_pixels(a0),d2
		add.w	d2,d1
		and.w	(Screen_Y_wrap_value).w,d1
		move.w	d2,d3
		add.w	d2,d2
		addi.w	#224,d2
		cmp.w	d2,d1
		bhs.w	Render_Sprites_NextObj
		addi.w	#128,d1
		sub.w	d3,d1

loc_1AEE4:
		ori.b	#setBit(render_flags.on_screen),render_flags(a0)		; set on-screen flag
		tst.w	d7
		bmi.w	Render_Sprites_NextObj
		move.w	art_tile(a0),d5
		movea.l	mappings(a0),a2
		moveq	#0,d4
		move.b	mapping_frame(a0),d4
		beq.s	loc_1AF1C
		add.w	d4,d4
		lea	(a2),a1
		adda.w	(a1,d4.w),a1
		move.w	(a1)+,d4
		subq.w	#1,d4
		bmi.s	loc_1AF1C
		move.w	d6,d3
		bsr.w	sub_1B070
		move.w	d3,d6
		tst.w	d7
		bmi.w	Render_Sprites_NextObj

loc_1AF1C:
		move.w	mainspr_childsprites(a0),d3
		subq.w	#1,d3
		blo.w	Render_Sprites_NextObj
		lea	sub2_x_pos(a0),a0

loc_1AF2A:
		move.w	(a0)+,d0
		move.w	(a0)+,d1
		btst	#render_flags.level,d6						; is this to be positioned by screen coordinates?
		beq.s	loc_1AF46							; if not, branch
		sub.w	(a3),d0
		addi.w	#128,d0
		sub.w	4(a3),d1
		addi.w	#128,d1
		and.w	(Screen_Y_wrap_value).w,d1

loc_1AF46:
		addq.w	#1,a0
		moveq	#0,d4
		move.b	(a0)+,d4
		add.w	d4,d4
		lea	(a2),a1
		adda.w	(a1,d4.w),a1
		move.w	(a1)+,d4
		subq.w	#1,d4
		bmi.s	loc_1AF62
		move.w	d6,-(sp)
		bsr.w	sub_1B070
		move.w	(sp)+,d6

loc_1AF62:
		tst.w	d7
		dbmi	d3,loc_1AF2A
		bra.w	Render_Sprites_NextObj

; =============== S U B R O U T I N E =======================================

sub_1AF6C:
		lsr.b	d6
		blo.s	loc_1AF9E
		lsr.b	d6
		blo.w	loc_1B038

loc_1AF76:
		move.b	(a1)+,d2
		ext.w	d2
		add.w	d1,d2
		move.w	d2,(a6)+
		move.b	(a1)+,(a6)+
		addq.w	#1,a6
		move.w	(a1)+,d2
		add.w	d5,d2
		move.w	d2,(a6)+
		move.w	(a1)+,d2
		add.w	d0,d2
		andi.w	#$1FF,d2
		bne.s	loc_1AF94
		addq.w	#1,d2

loc_1AF94:
		move.w	d2,(a6)+
		subq.w	#1,d7
		dbmi	d4,loc_1AF76
		rts
; ---------------------------------------------------------------------------

loc_1AF9E:
		lsr.b	d6
		blo.s	loc_1AFE8

loc_1AFA2:
		move.b	(a1)+,d2
		ext.w	d2
		add.w	d1,d2
		move.w	d2,(a6)+
		move.b	(a1)+,d6
		move.b	d6,(a6)+
		addq.w	#1,a6
		move.w	(a1)+,d2
		add.w	d5,d2
		eori.w	#flip_x,d2
		move.w	d2,(a6)+
		move.w	(a1)+,d2
		neg.w	d2
		move.b	byte_1AFD8(pc,d6.w),d6
		sub.w	d6,d2
		add.w	d0,d2
		andi.w	#$1FF,d2
		bne.s	loc_1AFCE
		addq.w	#1,d2

loc_1AFCE:
		move.w	d2,(a6)+
		subq.w	#1,d7
		dbmi	d4,loc_1AFA2
		rts
; ---------------------------------------------------------------------------

byte_1AFD8:
		dc.b 8, 8, 8, 8
		dc.b 16, 16, 16, 16
		dc.b 24, 24, 24, 24
		dc.b 32, 32, 32, 32
; ---------------------------------------------------------------------------

loc_1AFE8:
		move.b	(a1)+,d2
		ext.w	d2
		neg.w	d2
		move.b	(a1),d6
		move.b	byte_1B028(pc,d6.w),d6
		sub.w	d6,d2
		add.w	d1,d2
		move.w	d2,(a6)+
		move.b	(a1)+,d6
		move.b	d6,(a6)+
		addq.w	#1,a6
		move.w	(a1)+,d2
		add.w	d5,d2
		eori.w	#flip_x+flip_y,d2
		move.w	d2,(a6)+
		move.w	(a1)+,d2
		neg.w	d2
		move.b	byte_1AFD8(pc,d6.w),d6
		sub.w	d6,d2
		add.w	d0,d2
		andi.w	#$1FF,d2
		bne.s	loc_1B01E
		addq.w	#1,d2

loc_1B01E:
		move.w	d2,(a6)+
		subq.w	#1,d7
		dbmi	d4,loc_1AFE8
		rts
; ---------------------------------------------------------------------------

byte_1B028:
		dc.b 8, 16, 24, 32
		dc.b 8, 16, 24, 32
		dc.b 8, 16, 24, 32
		dc.b 8, 16, 24, 32
; ---------------------------------------------------------------------------

loc_1B038:
		move.b	(a1)+,d2
		ext.w	d2
		neg.w	d2
		move.b	(a1)+,d6
		move.b	d6,2(a6)
		move.b	byte_1B028(pc,d6.w),d6
		sub.w	d6,d2
		add.w	d1,d2
		move.w	d2,(a6)+
		addq.w	#2,a6
		move.w	(a1)+,d2
		add.w	d5,d2
		eori.w	#flip_y,d2
		move.w	d2,(a6)+
		move.w	(a1)+,d2
		add.w	d0,d2
		andi.w	#$1FF,d2
		bne.s	loc_1B066
		addq.w	#1,d2

loc_1B066:
		move.w	d2,(a6)+
		subq.w	#1,d7
		dbmi	d4,loc_1B038
		rts

; =============== S U B R O U T I N E =======================================

sub_1B070:
		lsr.b	d6
		blo.s	loc_1B0C2
		lsr.b	d6
		blo.w	loc_1B19C

loc_1B07A:
		move.b	(a1)+,d2
		ext.w	d2
		add.w	d1,d2
		cmpi.w	#-32+128,d2
		bls.s	loc_1B0BA
		cmpi.w	#224+128,d2
		bhs.s	loc_1B0BA
		move.w	d2,(a6)+
		move.b	(a1)+,(a6)+
		addq.w	#1,a6
		move.w	(a1)+,d2
		add.w	d5,d2
		move.w	d2,(a6)+
		move.w	(a1)+,d2
		add.w	d0,d2
		cmpi.w	#-32+128,d2
		bls.s	loc_1B0B2
		cmpi.w	#320+128,d2
		bhs.s	loc_1B0B2
		move.w	d2,(a6)+
		subq.w	#1,d7
		dbmi	d4,loc_1B07A
		rts
; ---------------------------------------------------------------------------

loc_1B0B2:
		subq.w	#6,a6
		dbf	d4,loc_1B07A
		rts
; ---------------------------------------------------------------------------

loc_1B0BA:
		addq.w	#5,a1
		dbf	d4,loc_1B07A
		rts
; ---------------------------------------------------------------------------

loc_1B0C2:
		lsr.b	d6
		blo.s	loc_1B12C

loc_1B0C6:
		move.b	(a1)+,d2
		ext.w	d2
		add.w	d1,d2
		cmpi.w	#-32+128,d2
		bls.s	loc_1B114
		cmpi.w	#224+128,d2
		bhs.s	loc_1B114
		move.w	d2,(a6)+
		move.b	(a1)+,d6
		move.b	d6,(a6)+
		addq.w	#1,a6
		move.w	(a1)+,d2
		add.w	d5,d2
		eori.w	#flip_x,d2
		move.w	d2,(a6)+
		move.w	(a1)+,d2
		neg.w	d2
		move.b	byte_1B11C(pc,d6.w),d6
		sub.w	d6,d2
		add.w	d0,d2
		cmpi.w	#-32+128,d2
		bls.s	loc_1B10C
		cmpi.w	#320+128,d2
		bhs.s	loc_1B10C
		move.w	d2,(a6)+
		subq.w	#1,d7
		dbmi	d4,loc_1B0C6
		rts
; ---------------------------------------------------------------------------

loc_1B10C:
		subq.w	#6,a6
		dbf	d4,loc_1B0C6
		rts
; ---------------------------------------------------------------------------

loc_1B114:
		addq.w	#5,a1
		dbf	d4,loc_1B0C6
		rts
; ---------------------------------------------------------------------------

byte_1B11C:
		dc.b 8, 8, 8, 8
		dc.b 16, 16, 16, 16
		dc.b 24, 24, 24, 24
		dc.b 32, 32, 32, 32
; ---------------------------------------------------------------------------

loc_1B12C:
		move.b	(a1)+,d2
		ext.w	d2
		neg.w	d2
		move.b	(a1),d6
		move.b	byte_1B18C(pc,d6.w),d6
		sub.w	d6,d2
		add.w	d1,d2
		cmpi.w	#-32+128,d2
		bls.s	loc_1B184
		cmpi.w	#224+128,d2
		bhs.s	loc_1B184
		move.w	d2,(a6)+
		move.b	(a1)+,d6
		move.b	d6,(a6)+
		addq.w	#1,a6
		move.w	(a1)+,d2
		add.w	d5,d2
		eori.w	#flip_x+flip_y,d2
		move.w	d2,(a6)+
		move.w	(a1)+,d2
		neg.w	d2
		move.b	byte_1B11C(pc,d6.w),d6
		sub.w	d6,d2
		add.w	d0,d2
		cmpi.w	#-32+128,d2
		bls.s	loc_1B17C
		cmpi.w	#320+128,d2
		bhs.s	loc_1B17C
		move.w	d2,(a6)+
		subq.w	#1,d7
		dbmi	d4,loc_1B12C
		rts
; ---------------------------------------------------------------------------

loc_1B17C:
		subq.w	#6,a6
		dbf	d4,loc_1B12C
		rts
; ---------------------------------------------------------------------------

loc_1B184:
		addq.w	#5,a1
		dbf	d4,loc_1B12C
		rts
; ---------------------------------------------------------------------------

byte_1B18C:
		dc.b 8, 16, 24, 32
		dc.b 8, 16, 24, 32
		dc.b 8, 16, 24, 32
		dc.b 8, 16, 24, 32
; ---------------------------------------------------------------------------

loc_1B19C:
		move.b	(a1)+,d2
		ext.w	d2
		neg.w	d2
		move.b	(a1)+,d6
		move.b	d6,2(a6)
		move.b	byte_1B18C(pc,d6.w),d6
		sub.w	d6,d2
		add.w	d1,d2
		cmpi.w	#-32+128,d2
		bls.s	loc_1B1EC
		cmpi.w	#224+128,d2
		bhs.s	loc_1B1EC
		move.w	d2,(a6)+
		addq.w	#2,a6
		move.w	(a1)+,d2
		add.w	d5,d2
		eori.w	#flip_y,d2
		move.w	d2,(a6)+
		move.w	(a1)+,d2
		add.w	d0,d2
		cmpi.w	#-32+128,d2
		bls.s	loc_1B1E4
		cmpi.w	#320+128,d2
		bhs.s	loc_1B1E4
		move.w	d2,(a6)+
		subq.w	#1,d7
		dbmi	d4,loc_1B19C
		rts
; ---------------------------------------------------------------------------

loc_1B1E4:
		subq.w	#6,a6
		dbf	d4,loc_1B19C
		rts
; ---------------------------------------------------------------------------

loc_1B1EC:
		addq.w	#4,a1
		dbf	d4,loc_1B19C
		rts

; ---------------------------------------------------------------------------
; Load extra sprites
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Load_ExtraRender:
		lea	(Render_sprite_first_RAM).w,a2
		move.w	(a1)+,d1

.load
		move.l	(a1)+,(a2)+
		dbf	d1,.load

		; end marker
		clr.l	(a2)
		rts

; ---------------------------------------------------------------------------
; Add new extra sprites slot
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

AddSlot_ExtraRender:
		andi.w	#7,d1								; maximum 8 slots

		; calc slot
		lea	(Render_sprite_first_RAM_end).w,a1
		add.w	d1,d1								; multiply by 4
		add.w	d1,d1
		jmp	.shift(pc,d1.w)
; ---------------------------------------------------------------------------

.shift

	rept ((Render_sprite_first_RAM_end-Render_sprite_first_RAM)/4)
		subq.w	#4+4,a1								; next
		move.l	(a1)+,(a1)							; shift data
	endr

		; save new pointer
		move.l	d0,(a1)
		rts

; ---------------------------------------------------------------------------
; Delete extra sprites slot
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

DeleteSlot_ExtraRender:
		andi.w	#7,d1								; maximum 8 slots

		; calc slot
		lea	(Render_sprite_first_RAM+4).w,a1
		add.w	d1,d1								; multiply by 4
		add.w	d1,d1
		adda.w	d1,a1
		jmp	.shift(pc,d1.w)
; ---------------------------------------------------------------------------

.shift

	rept ((Render_sprite_first_RAM_end-Render_sprite_first_RAM)/4)-1
		move.l	(a1),-(a1)							; shift data
		addq.w	#4+4,a1								; next
	endr

		; last shift data
		move.l	(a1),-(a1)
		rts
