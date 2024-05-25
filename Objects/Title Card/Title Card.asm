; ---------------------------------------------------------------------------
; TitleCard (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

TitleCardAct_Index:
		dc.l ArtKosM_TitleCardNum1		; 0
		dc.l ArtKosM_TitleCardNum2		; 1
		dc.l ArtKosM_TitleCardNum3		; 2
		dc.l ArtKosM_TitleCardNum4		; 3
; ---------------------------------------------------------------------------

Obj_TitleCard:

		; load general art
		lea	(ArtKosM_TitleCardRedAct).l,a1
		move.w	#tiles_to_bytes($500),d2
		jsr	(Queue_Kos_Module).w

		; load act number art
		moveq	#0,d0
		move.b	(Current_act).w,d0
		add.w	d0,d0
		add.w	d0,d0
		movea.l	TitleCardAct_Index(pc,d0.w),a1
		move.w	#tiles_to_bytes($53D),d2
		jsr	(Queue_Kos_Module).w

		; load zone name art
		moveq	#0,d0
		move.b	(Current_zone).w,d0									; otherwise, just use current zone
		add.w	d0,d0
		add.w	d0,d0
		movea.l	.levelgfx(pc,d0.w),a1
		move.w	#tiles_to_bytes($54D),d2
		jsr	(Queue_Kos_Module).w

		; next
		move.w	#1*60+30,objoff_2E(a0)								; set wait value
		clr.w	objoff_32(a0)
		st	objoff_48(a0)
		move.l	#.create,address(a0)
		rts

; ---------------------------------------------------------------------------
; The letters for the name of the zone.
; Exception: ENOZ/ZONE. These letters are already in VRAM.
; ---------------------------------------------------------------------------

.levelgfx
		dc.l ArtKosM_DEZTitleCard	; DEZ

		zonewarning .levelgfx,4
; ---------------------------------------------------------------------------

.create
		tst.w	(Kos_modules_left).w
		bne.s	.return												; don't load the objects until the art has been loaded
		jsr	(Create_New_Sprite3).w
		bne.s	.return
		lea	ObjArray_TtlCard(pc),a2
		move.w	(a2)+,d1												; make objects

.loop
		addq.w	#1,objoff_30(a0)
		move.l	(a2)+,address(a1)
		move.w	(a2)+,objoff_46(a1)
		move.w	(a2)+,x_pos(a1)
		move.w	(a2)+,y_pos(a1)
		move.b	(a2)+,mapping_frame(a1)
		move.b	(a2)+,width_pixels(a1)
		move.w	(a2)+,d2
		move.b	d2,objoff_28(a1)
		move.b	#rfMulti,render_flags(a1)
		move.l	#Map_TitleCard,mappings(a1)
		move.w	#$500,art_tile(a1)
		move.w	a0,parent2(a1)
		jsr	(Create_New_Sprite4).w
		dbne	d1,.loop

		; next
		move.l	#.wait,address(a0)

.return
		rts
; ---------------------------------------------------------------------------

.wait
		tst.w	objoff_34(a0)
		beq.s	.branch
		clr.w	objoff_34(a0)
		rts
; ---------------------------------------------------------------------------

.branch
		tst.w	objoff_3E(a0)
		beq.s	.skiplevel

		; reset level flags
		clr.l	(Timer).w												; if using in-level title card
		clr.w	(Ring_count).w										; reset HUD rings and timer
		st	(Update_HUD_timer).w
		st	(Update_HUD_ring_count).w								; start updating timer and rings again
		move.b	#30,(Player_1+air_left).w								; reset air
		jsr	(Restore_LevelMusic).w									; play music

.skiplevel
		clr.w	objoff_48(a0)
		move.l	#.wait2,address(a0)
		rts
; ---------------------------------------------------------------------------

.wait2
		tst.w	objoff_2E(a0)
		beq.s	.endtimer
		subq.w	#1,objoff_2E(a0)
		rts
; ---------------------------------------------------------------------------

.endtimer
		tst.w	objoff_30(a0)
		beq.s	.branch2
		addq.w	#1,objoff_32(a0)
		rts
; ---------------------------------------------------------------------------

.branch2
		tst.w	objoff_3E(a0)
		beq.s	.skiplevel2
		st	(TitleCard_end_flag).w										; if in-level, set end of title card flag

.skiplevel2
		lea	(PLC2_Sonic).l,a5
		jsr	(LoadPLC_Raw_KosM).w
		movea.l	(Level_data_addr_RAM.PLC2).w,a5
		jsr	(LoadPLC_Raw_KosM).w									; load main art
		movea.l	(Level_data_addr_RAM.PLCAnimals).w,a5
		jsr	(LoadPLC_Raw_KosM).w									; load animals art
		move.b	#1,(HUD_RAM.status).w								; load HUD
		clr.b	(Ctrl_1_locked).w											; unlock control 1

		; delete
		jmp	(Delete_Current_Sprite).w

; =============== S U B R O U T I N E =======================================

Obj_TitleCardRedBanner:
		movea.w	parent2(a0),a1
		move.w	objoff_32(a1),d0
		beq.s	.loc_2D90A
		tst.b	render_flags(a0)
		bmi.s	.loc_2D8FC
		subq.w	#1,objoff_30(a1)
		jmp	(Delete_Current_Sprite).w
; ---------------------------------------------------------------------------

.loc_2D8FC
		cmp.b	objoff_28(a0),d0
		blo.s		.loc_2D920
		subi.w	#32,y_pos(a0)
		bra.s	.loc_2D920
; ---------------------------------------------------------------------------

.loc_2D90A
		move.w	y_pos(a0),d0
		cmp.w	objoff_46(a0),d0
		beq.s	.loc_2D920
		addi.w	#16,d0
		move.w	d0,y_pos(a0)
		st	objoff_34(a1)

.loc_2D920
		move.b	#224/2,height_pixels(a0)
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

Obj_TitleCardName:
		move.b	(Current_zone).w,d0
		add.b	d0,mapping_frame(a0)
		move.l	#Obj_TitleCardElement,address(a0)

; =============== S U B R O U T I N E =======================================

Obj_TitleCardElement:
		movea.w	parent2(a0),a1
		move.w	objoff_32(a1),d0
		beq.s	.loc_2D984
		tst.b	render_flags(a0)
		bmi.s	.loc_2D976
		subq.w	#1,objoff_30(a1)
		jmp	(Delete_Current_Sprite).w
; ---------------------------------------------------------------------------

.loc_2D976
		cmp.b	objoff_28(a0),d0
		blo.s		.loc_2D99A
		addi.w	#32,x_pos(a0)
		bra.s	.loc_2D99A
; ---------------------------------------------------------------------------

.loc_2D984
		move.w	x_pos(a0),d0
		cmp.w	objoff_46(a0),d0
		beq.s	.loc_2D99A
		subi.w	#16,d0
		move.w	d0,x_pos(a0)
		st	objoff_34(a1)

.loc_2D99A
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

Obj_TitleCardAct:
		move.l	#Obj_TitleCardElement,address(a0)
		bra.s	Obj_TitleCardElement

		; delete
;		movea.w	parent2(a0),a1										; remove a number of the act, if not needed
;		subq.w	#1,objoff_30(a1)
;		jmp	(Delete_Current_Sprite).w
; ---------------------------------------------------------------------------

ObjArray_TtlCard:
		dc.w ((ObjArray_TtlCard_end-ObjArray_TtlCard)/$E)-1			; count

		; 1
		dc.l Obj_TitleCardName										; object address
		dc.w $120													; x destination
		dc.w $260													; xpos
		dc.w $E0													; ypos
		dc.b 4														; mapping frame
		dc.b $80														; width
		dc.w 3														; place in exit queue

		; 2
		dc.l Obj_TitleCardElement
		dc.w $17C
		dc.w $2FC
		dc.w $100
		dc.b 3
		dc.b $24
		dc.w 5

		; 3
		dc.l Obj_TitleCardAct
		dc.w $184
		dc.w $344
		dc.w $120
		dc.b 2
		dc.b $1C
		dc.w 7

		; 4
		dc.l Obj_TitleCardRedBanner
		dc.w $C0
		dc.w $E0
		dc.w $10
		dc.b 1
		dc.b 0
		dc.w 1

ObjArray_TtlCard_end

ObjArray_TtlCardBonus:
		dc.w ((ObjArray_TtlCardBonus_end-ObjArray_TtlCardBonus)/$E)-1

		; 1
		dc.l Obj_TitleCardElement
		dc.w $C8
		dc.w $188
		dc.w $E8
		dc.b $13
		dc.b $80
		dc.w 1

		; 2
		dc.l Obj_TitleCardElement
		dc.w $128
		dc.w $1E8
		dc.w $E8
		dc.b $14
		dc.b $80
		dc.w 1

ObjArray_TtlCardBonus_end
; ---------------------------------------------------------------------------

		include "Objects/Title Card/Object Data/Map - Title Card.asm"
