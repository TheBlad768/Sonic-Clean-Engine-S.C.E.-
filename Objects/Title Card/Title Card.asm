; ---------------------------------------------------------------------------
; TitleCard (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_TitleCard:
		moveq	#0,d0
		move.b	routine(a0),d0
		move.w	TitleCard_Index(pc,d0.w),d1
		jmp	TitleCard_Index(pc,d1.w)
; ---------------------------------------------------------------------------

TitleCard_Index: offsetTable
		offsetTableEntry.w Obj_TitleCardInit
		offsetTableEntry.w Obj_TitleCardCreate
		offsetTableEntry.w Obj_TitleCardWait
		offsetTableEntry.w Obj_TitleCardWait2
; ---------------------------------------------------------------------------

Obj_TitleCardInit:
		lea	(ArtKosM_TitleCardRedAct).l,a1
		move.w	#tiles_to_bytes($500),d2
		jsr	(Queue_Kos_Module).w
		moveq	#0,d0
		move.b	(Current_act).w,d0
		lsl.w	#2,d0
		movea.l	TitleCardAct_Index(pc,d0.w),a1
		move.w	#tiles_to_bytes($53D),d2
		jsr	(Queue_Kos_Module).w
		moveq	#0,d0
		lea	TitleCard_LevelGfx(pc),a1
		move.b	(Current_zone).w,d0			; Otherwise, just use current zone
		lsl.w	#2,d0
		movea.l	(a1,d0.w),a1
		move.w	#tiles_to_bytes($54D),d2
		jsr	(Queue_Kos_Module).w
		move.w	#$5A,$2E(a0)				; Set wait value
		clr.w	$32(a0)
		st	$48(a0)
		addq.b	#2,routine(a0)
		rts
; ---------------------------------------------------------------------------

TitleCardAct_Index:
		dc.l ArtKosM_TitleCardNum1
		dc.l ArtKosM_TitleCardNum2
		dc.l ArtKosM_TitleCardNum3
		dc.l ArtKosM_TitleCardNum4
; ---------------------------------------------------------------------------

Obj_TitleCardCreate:
		tst.w	(Kos_modules_left).w
		bne.s	Obj_TitleCard_Return			; Wait for KosM queue to clear
		jsr	(Create_New_Sprite3).w
		bne.s	Obj_TitleCard_Return
		lea	ObjArray_TtlCard(pc),a2
		moveq	#4-1,d1
		tst.b	$44(a0)
		beq.s	.loop
		lea	ObjArray_TtlCard2(pc),a2
		moveq	#1-1,d1

.loop	addq.w	#1,$30(a0)
		move.l	(a2)+,address(a1)
		move.w	(a2)+,$46(a1)
		move.w	(a2)+,x_pos(a1)
		move.w	(a2)+,y_pos(a1)
		move.b	(a2)+,mapping_frame(a1)
		move.b	(a2)+,width_pixels(a1)
		move.w	(a2)+,d2
		move.b	d2,$28(a1)
		move.b	#$40,render_flags(a1)
		move.l	#Map_TitleCard,mappings(a1)
		move.w	a0,parent2(a1)
		jsr	(Create_New_Sprite4).w
		dbne	d1,.loop
		addq.b	#2,routine(a0)

Obj_TitleCard_Return:
		rts
; ---------------------------------------------------------------------------

Obj_TitleCardWait:
		tst.w	$34(a0)
		beq.s	+
		clr.w	$34(a0)
		rts
; ---------------------------------------------------------------------------
+		tst.w	$3E(a0)
		beq.s	+
		clr.l	(Timer).w					; If using in-level title card
		clr.w	(Ring_count).w			; Reset HUD rings and timer
		st	(Update_HUD_timer).w
		st	(Update_HUD_ring_count).w	; Start updating timer and rings again
		move.b	#30,(Player_1+air_left).w	; Reset air
		jsr	(Restore_LevelMusic).w		; Play music
+		clr.w	$48(a0)
		addq.b	#2,routine(a0)
		rts
; ---------------------------------------------------------------------------

Obj_TitleCardWait2:
		tst.w	$2E(a0)
		beq.s	+
		subq.w	#1,$2E(a0)
		rts
; ---------------------------------------------------------------------------
+		tst.w	$30(a0)
		beq.s	+
		addq.w	#1,$32(a0)
		rts
; ---------------------------------------------------------------------------
+		tst.b	$44(a0)
		bne.s	++
		tst.w	$3E(a0)
		beq.s	+
		st	(TitleCard_end_flag).w		; If in-level, set end of title card flag.
+		lea	(PLC_Main2).l,a5
		jsr	(LoadPLC_Raw_KosM).w
		jsr	(LoadPLC2_KosM).w
		jsr	LoadPLC_Animals(pc)
		move.b	#1,(HUD_RAM.status).w
		clr.b	(Ctrl_1_locked).w
+		jmp	(Delete_Current_Sprite).w
; ---------------------------------------------------------------------------

Obj_TitleCardRedBanner:
		movea.w	parent2(a0),a1
		move.w	$32(a1),d0
		beq.s	++
		tst.b	render_flags(a0)
		bmi.s	+
		subq.w	#1,$30(a1)
		jmp	(Delete_Current_Sprite).w
; ---------------------------------------------------------------------------
+		cmp.b	$28(a0),d0
		blo.s		++
		subi.w	#$20,y_pos(a0)
		bra.s	++
; ---------------------------------------------------------------------------
+		move.w	y_pos(a0),d0
		cmp.w	$46(a0),d0
		beq.s	+
		addi.w	#$10,d0
		move.w	d0,y_pos(a0)
		st	$34(a1)
+		move.b	#$70,6(a0)
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

Obj_TitleCardName:
		move.b	(Current_zone).w,d0
		add.b	d0,mapping_frame(a0)
		move.l	#Obj_TitleCardElement,address(a0)

Obj_TitleCardElement:
		movea.w	parent2(a0),a1
		move.w	$32(a1),d0
		beq.s	++
		tst.b	render_flags(a0)
		bmi.s	+
		subq.w	#1,$30(a1)
		jmp	(Delete_Current_Sprite).w
; ---------------------------------------------------------------------------
+		cmp.b	$28(a0),d0
		blo.s		++
		addi.w	#$20,x_pos(a0)
		bra.s	++
; ---------------------------------------------------------------------------
+		move.w	x_pos(a0),d0
		cmp.w	$46(a0),d0
		beq.s	+
		subi.w	#$10,d0
		move.w	d0,x_pos(a0)
		st	$34(a1)
+		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

Obj_TitleCardAct:
		move.l	#Obj_TitleCardElement,address(a0)
		bra.s	Obj_TitleCardElement

; Remove a number of the act, if not needed
;		movea.w	parent2(a0),a1
;		subq.w	#1,$30(a1)
;		jmp	(Delete_Current_Sprite).w
; ---------------------------------------------------------------------------

Obj_TitleCardElement2:
		clr.b	render_flags(a0)			; I'm not entirely sure what this is used for
		movea.w	parent2(a0),a1
		move.w	$32(a1),d0
		beq.s	++
		cmpi.w	#$20C,x_pos(a0)
		blo.s		+
		subq.w	#1,$30(a1)
		jmp	(Delete_Current_Sprite).w
; ---------------------------------------------------------------------------
+		cmp.b	$28(a0),d0
		blo.s		++
		addi.w	#$20,x_pos(a0)
		bra.s	++
; ---------------------------------------------------------------------------
+		move.w	x_pos(a0),d0
		cmp.w	$46(a0),d0
		beq.s	+
		subi.w	#$10,d0
		move.w	d0,x_pos(a0)
		st	$34(a1)
+		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

ObjArray_TtlCard:
		dc.l Obj_TitleCardName
		dc.w $120
		dc.w $260
		dc.w $E0
		dc.b 4
		dc.b $80
		dc.w 3
		dc.l Obj_TitleCardElement
		dc.w $17C
		dc.w $2FC
		dc.w $100
		dc.b 3
		dc.b $24
		dc.w 5
		dc.l Obj_TitleCardAct
		dc.w $184
		dc.w $344
		dc.w $120
		dc.b 2
		dc.b $1C
		dc.w 7
		dc.l Obj_TitleCardRedBanner
		dc.w $C0
		dc.w $E0
		dc.w $10
		dc.b 1
		dc.b 0
		dc.w 1
ObjArray_TtlCard2:
		dc.l Obj_TitleCardElement2
		dc.w $15C
		dc.w $21C
		dc.w $BC
		dc.b $12
		dc.b $80
		dc.w 1
ObjArray_TtlCardBonus:
		dc.l Obj_TitleCardElement
		dc.w $C8
		dc.w $188
		dc.w $E8
		dc.b $13
		dc.b $80
		dc.w 1
		dc.l Obj_TitleCardElement
		dc.w $128
		dc.w $1E8
		dc.w $E8
		dc.b $14
		dc.b $80
		dc.w 1
; ---------------------------------------------------------------------------
; The letters for the name of the zone.
; Exception: ENOZ>ZONE. These letters are already in VRAM.

TitleCard_LevelGfx:
		dc.l ArtKosM_DEZTitleCard	; DEZ

		zonewarning TitleCard_LevelGfx,4
; ---------------------------------------------------------------------------

		include "Objects/Title Card/Object Data/Map - Title Card.asm"
