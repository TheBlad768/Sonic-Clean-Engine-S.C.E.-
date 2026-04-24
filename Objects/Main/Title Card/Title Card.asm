; ---------------------------------------------------------------------------
; Title Card (Object)
; ---------------------------------------------------------------------------

; dynamic object variables

	dsset animations								; pretend we're in the RAM

titlecard.elements_count		ds.b 1						; (1 byte)
titlecard.exit_phase			ds.b 1						; (1 byte)
titlecard.elements_moving_flag		ds.b 1						; (1 byte)
titlecard.in_level_flag			ds.b 1						; (1 byte)

titlecard.queue_id =			collision_type					; (1 byte)
titlecard.destination =			parent3						; (2 bytes)
titlecard.process =			parent2						; (1 byte)

	dsreset										; stop pretending and reset the program counter

; =============== S U B R O U T I N E =======================================

TitleCardAct_Index:
		dc.l ArtKosPlusM_TitleCardNum1	; 0
		dc.l ArtKosPlusM_TitleCardNum2	; 1
		dc.l ArtKosPlusM_TitleCardNum3	; 2
		dc.l ArtKosPlusM_TitleCardNum4	; 3
; ---------------------------------------------------------------------------

Obj_TitleCard:

		; load general art
		QueueKosPlusModule	ArtKosPlusM_TitleCardRedAct, $500

		; load act number art
		moveq	#0,d0
		move.b	(Current_act).w,d0
		add.w	d0,d0								; multiply by 4
		add.w	d0,d0
		movea.l	TitleCardAct_Index(pc,d0.w),a1
		move.w	#tiles_to_bytes($53D),d2
		jsr	(Queue_KosPlus_Module).w

		; next
		move.w	#(1*60)+30,wait_timer(a0)					; set wait value
		clr.w	titlecard.elements_count(a0)					; clear elements_count and exit_phase
		st	titlecard.process(a0)						; set Title Card process flag
		move.l	#.create,code_addr(a0)
		rts
; ---------------------------------------------------------------------------

.create
		tst.w	(KosPlus_modules_left).w
		bne.s	.return								; don't load the objects until the art has been loaded
		jsr	(Create_New_Object_3).w						; find new object slot
		bne.s	.return								; branch, if there are no free object slots here
		lea	ObjArray_TitleCard(pc),a2
		move.w	(a2)+,d1							; make objects

.loop
		addq.b	#1,titlecard.elements_count(a0)					; number of elements
		move.l	(a2)+,code_addr(a1)						; object code address
		move.w	(a2)+,titlecard.destination(a1)					; destination
		move.w	(a2)+,x_pos(a1)
		move.w	(a2)+,y_pos(a1)
		move.b	(a2)+,mapping_frame(a1)
		move.b	(a2)+,width_pixels(a1)
		move.w	(a2)+,d2
		move.b	d2,titlecard.queue_id(a1)					; place in exit queue
		move.b	#setBit(render_flags.multi_sprite),render_flags(a1)
		move.l	#Map_TitleCard,mappings(a1)
		move.w	#make_art_tile($500,0,FALSE),art_tile(a1)
		move.w	a0,parent2(a1)

		; create next object
		jsr	(Create_New_Object_4).w						; find next free object slot
		dbne	d1,.loop

		; next
		move.l	#.wait,code_addr(a0)

.return
		rts
; ---------------------------------------------------------------------------

.wait
		tst.b	titlecard.elements_moving_flag(a0)				; are the elements still moving in?
		beq.s	.branch								; if not, branch
		clr.b	titlecard.elements_moving_flag(a0)
		rts
; ---------------------------------------------------------------------------

.branch
		tst.b	titlecard.in_level_flag(a0)
		beq.s	.not_in_level

		; reset level flags
		clr.l	(Timer).w							; if using in-level title card
		clr.w	(Ring_count).w							; reset HUD rings and timer
		st	(Update_HUD_timer).w
		st	(Update_HUD_ring_count).w					; start updating timer and rings again
		move.b	#30,(Player_1+air_left).w					; reset air p1
		jsr	(Restore_LevelMusic).w						; play music

.not_in_level
		sf	titlecard.process(a0)						; clear Title Card process flag
		move.l	#.wait2,code_addr(a0)
		rts
; ---------------------------------------------------------------------------

.wait2
		tst.w	wait_timer(a0)
		beq.s	.endtimer
		subq.w	#1,wait_timer(a0)
		rts
; ---------------------------------------------------------------------------

.endtimer
		tst.b	titlecard.elements_count(a0)					; wait for title screen objects to disappear
		beq.s	.branch2
		addq.b	#1,titlecard.exit_phase(a0)
		rts
; ---------------------------------------------------------------------------

.branch2
		tst.b	titlecard.in_level_flag(a0)
		beq.s	.not_in_level_2
		st	(End_of_level_flag).w						; if in-level, set end of title card flag. No need to reload PLCs
		bra.s	.not_in_level_3
; ---------------------------------------------------------------------------

.not_in_level_2

		; load second main plc
		lea	(PLC2_Sonic).l,a5
		jsr	(LoadPLC_Raw_KosPlusM).w					; load main art
		movea.l	(Level_data_addr_RAM.PLC2).w,a5
		jsr	(LoadPLC_Raw_KosPlusM).w					; load PLC2 art

.not_in_level_3
		movea.l	(Level_data_addr_RAM.PLCAnimals).w,a5
		jsr	(LoadPLC_Raw_KosPlusM).w					; load animals art
		moveq	#1,d0
		move.b	d0,(HUD_RAM.status).w						; load HUD
		move.b	d0,(Update_HUD_timer).w						; update time counter
		clr.b	(Ctrl_1_locked).w						; unlock control 1

		; delete
		jmp	(Delete_Current_Object).w

; ---------------------------------------------------------------------------
; Title Card red banner (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_TitleCardRedBanner:
		movea.w	parent2(a0),a1							; a1=parent object

		; check move
		move.b	titlecard.exit_phase(a1),d0
		beq.s	.move_in							; if zero, move in

		; check delete
		tst.b	render_flags(a0)						; is the object visible on the screen?
		bmi.s	.check_queue							; if yes, branch

		; delete
		subq.b	#1,titlecard.elements_count(a1)					; if offscreen, subtract from number of elements and delete
		jmp	(Delete_Current_Object).w
; ---------------------------------------------------------------------------

.check_queue
		cmp.b	titlecard.queue_id(a0),d0					; level element moving out. Test if value of parent queue matches given queue value
		blo.s	.draw								; if not, branch

		; move out
		subi.w	#16*2,y_pos(a0)							; if so, move out
		bra.s	.draw
; ---------------------------------------------------------------------------

.move_in
		move.w	y_pos(a0),d0
		cmp.w	titlecard.destination(a0),d0
		beq.s	.draw								; if y position has reached destination, don't do anything else
		addi.w	#16,d0								; level element moving in
		move.w	d0,y_pos(a0)
		st	titlecard.elements_moving_flag(a1)				; set moving flag

.draw
		move.b	#screen_height/2,height_pixels(a0)
		jmp	(Draw_Sprite).w

; ---------------------------------------------------------------------------
; Title Card name (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_TitleCardName:
		move.b	(Current_zone).w,d0
		add.b	d0,mapping_frame(a0)
		move.l	#Obj_TitleCardElement,code_addr(a0)

; ---------------------------------------------------------------------------
; Title Card element (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_TitleCardElement:
		movea.w	parent2(a0),a1							; a1=parent object

		; check move
		move.b	titlecard.exit_phase(a1),d0
		beq.s	.move_in							; if zero, move in

		; check delete
		tst.b	render_flags(a0)						; is the object visible on the screen?
		bmi.s	.check_queue							; if yes, branch

		; delete
		subq.b	#1,titlecard.elements_count(a1)					; if offscreen, subtract from number of elements and delete
		jmp	(Delete_Current_Object).w
; ---------------------------------------------------------------------------

.check_queue
		cmp.b	titlecard.queue_id(a0),d0					; level element moving out. Test if value of parent queue matches given queue value
		blo.s	.draw								; if not, branch

		; move out
		addi.w	#32,x_pos(a0)							; if so, move out
		bra.s	.draw
; ---------------------------------------------------------------------------

.move_in
		move.w	x_pos(a0),d0
		cmp.w	titlecard.destination(a0),d0
		beq.s	.draw
		subi.w	#16,d0								; level element moving in
		move.w	d0,x_pos(a0)
		st	titlecard.elements_moving_flag(a1)				; set moving flag

.draw
		jmp	(Draw_Sprite).w

; ---------------------------------------------------------------------------
; Title Card act (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_TitleCardAct:
		move.l	#Obj_TitleCardElement,code_addr(a0)
		bra.s	Obj_TitleCardElement
; ---------------------------------------------------------------------------

		; remove a number of the act, if not needed
		movea.w	parent2(a0),a1							; a1=parent object
		subq.b	#1,titlecard.elements_count(a1)					; subtract from number of elements and delete
		jmp	(Delete_Current_Object).w
; ---------------------------------------------------------------------------

ObjArray_TitleCard: titlecardresultsheader
		titlecardresultsobjdata	Obj_TitleCardName, 160, 480, 96, 4, 256, 3		; 1
		titlecardresultsobjdata	Obj_TitleCardElement, 252, 636, 128, 3, 72, 5		; 2
		titlecardresultsobjdata	Obj_TitleCardAct, 260, 708, 160, 2, 56, 7		; 3
		titlecardresultsobjdata	Obj_TitleCardRedBanner, 64, 96, 16-128, 1, 0, 1		; 4
		titlecardresultsend

ObjArray_TitleCard_Bonus: titlecardresultsheader
		titlecardresultsobjdata	Obj_TitleCardElement, 72, 264, 104, $13, 256, 1		; 1
		titlecardresultsobjdata	Obj_TitleCardElement, 168, 360, 104, $14, 256, 1	; 2
		titlecardresultsend

; ---------------------------------------------------------------------------
; Title Card load letters to VRAM
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

TitleCard_LoadLetters:

.decomp =	0

		lea	VDP_data_port-VDP_control_port(a5),a6				; load VDP data address to a6

	if .decomp
		lea	(ArtKosP_TitleCardLargeText).l,a0
		lea	(RAM_start).l,a1
		lea	(a1),a3
		jsr	(KosPlus_Decomp).w
		lea	(a3),a2
	else
		lea	(ArtUnc_TitleCardLargeText).l,a2
	endif

		locVRAM	tiles_to_bytes($522),VDP_control_port-VDP_control_port(a5)

		; load "ZONE" art
		lea	VRAM_TitleCard_ZONE(pc),a1
		bsr.s	.find

		locVRAM	tiles_to_bytes($54D),VDP_control_port-VDP_control_port(a5)

		; load zone name art
		moveq	#0,d0
		move.b	(Current_zone).w,d0						; otherwise, just use current zone
		add.w	d0,d0								; multiply by 2
		lea	TitleCardVRAMLetters_Index(pc),a1
		adda.w	(a1,d0.w),a1

.find
		moveq	#0,d0
		move.b	(a1)+,d0							; get letter to d0
		bmi.s	.exit								; if minus, branch
		subq.w	#1,d0								; dbf fix
		add.w	d0,d0								; multiply by 4
		add.w	d0,d0								; "
		movem.w	.letters(pc,d0.w),d0-d1						; get id and size letter
		lsl.w	#5,d0								; multiply by $20
		lea	(a2,d0.w),a4							; load art letter address to a4

.copy

	rept 8*3
		move.l	(a4)+,VDP_data_port-VDP_data_port(a6)				; copy to VRAM
	endr

		dbf	d1,.copy							; next data

		; next letter
		bra.s	.find
; ---------------------------------------------------------------------------

.exit
		rts
; ---------------------------------------------------------------------------

.letters
		creditsletters "ABCDEFGHIJKLMNOPQRSTUVWXYZ.()0123456789!"
; ---------------------------------------------------------------------------

		; mappings
		include "Objects/Main/Title Card/Text Data/VRAM - Text Data.asm"
		include "Objects/Main/Title Card/Object Data/Map - Title Card.asm"
		include "Objects/Main/Title Card/Text Data/Map - Text Data.asm"
