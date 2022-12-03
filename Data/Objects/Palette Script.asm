; ---------------------------------------------------------------------------
; Palette script subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Run_PalRotationScript:
		tst.b	(Palette_rotation_disable).w
		bne.s	locret_85A00
		lea	(Palette_rotation_data).w,a1

loc_85994:
		move.w	(a1),d0						; load palette displacement to d0
		beq.s	locret_85A00					; if 0, return
		subq.b	#1,2(a1)						; decrement delay
		bpl.s	loc_859CA					; if still positive, go to next entry
		movea.l	4(a1),a2						; load palette script address to a2
		movea.w	(a2),a3						; load destination address to a3
		movea.l	a2,a4						; copy script address to a4
		adda.w	d0,a4						; skip to palette data
		move.w	(a4),d1						; load the first entry to d1
		bpl.s	+							; if positive, it is a normal entry
		bsr.s	Run_PalRotationScript_Main	; this is a command
+		moveq	#0,d2
		move.b	2(a2),d2						; load number of colors to d2

-		move.w	(a4)+,(a3)+					; copy the next color into destination
		dbf	d2,-								; loop for every color
		move.w	(a4)+,d0						; load next delay
		move.b	d0,2(a1)						; save the delay
		move.l	a4,d0						; copy current script position into d0
		move.l	a2,d1						; copy palette script origin to d1
		sub.l	d1,d0						; calculate the current displacement
		move.w	d0,(a1)						; store it back

loc_859CA:
		addq.w	#8,a1						; go to next script
		bra.s	loc_85994					; run the code again

; =============== S U B R O U T I N E =======================================

Run_PalRotationScript_Main:
		move.b	3(a2),d2						; load additional parameter to d2
		beq.s	loc_859FC
		neg.w	d1
		jmp	.table-8(pc,d1.w)
; ---------------------------------------------------------------------------

.table:
		bra.w	loc_859E2
		bra.w	loc_85A02
; ---------------------------------------------------------------------------

loc_859E2:
		addq.b	#1,3(a1)						; Add one to counter
		cmp.b	3(a1),d2						; Compare with max counter
		bhi.s	loc_859FC
		move.w	2(a4),d2
		adda.w	d2,a2
		move.l	a2,4(a1)						; Load new script after counter has finished
		movea.w	(a2),a3
		clr.w	2(a1)

loc_859FC:
		movea.l	a2,a4						; Start from the beginning of the rotation
		addq.l	#4,a4

locret_85A00:
		rts
; ---------------------------------------------------------------------------

loc_85A02:
		addq.b	#1,3(a1)
		cmp.b	3(a1),d2
		bhi.s	loc_859FC			; Wait for counter to finish
		movea.l	(Palette_rotation_custom).w,a2
		pea	(a1)
		jsr	(a2)						; Run custom routine
		movea.l	(sp)+,a1
		addq.w	#4,sp
		bra.s	loc_859CA

; =============== S U B R O U T I N E =======================================

Run_PalRotationScript2:
		tst.b	(Palette_rotation_disable).w
		bne.s	locret_85A58
		subq.b	#1,$3A(a0)
		bpl.s	locret_85A58
		movea.l	(a1)+,a3				; Address of Palette animation data
		move.w	(a1)+,d0				; Number of colors to replace
		moveq	#0,d1
		move.b	$3B(a0),d1
		addq.b	#2,d1
		moveq	#0,d2
		move.b	(a1,d1.w),d2
		bpl.s	+
		moveq	#0,d1
		move.b	(a1),d2
+		move.b	d1,$3B(a0)
		move.b	1(a1,d1.w),$3A(a0)
		add.w	d2,d2
		move.w	(a3,d2.w),d2
		lea	(a3,d2.w),a3

-		move.w	(a3)+,(a2)+
		dbf	d0,-

locret_85A58:
		rts

; =============== S U B R O U T I N E =======================================

SetPointer_PalRotation:
		lea	(Palette_rotation_data).w,a2
		move.l	(a1)+,(a2)+
		move.l	(a1)+,(a2)+
		clr.w	(a2)
		rts

; =============== S U B R O U T I N E =======================================

Obj_FadeSelectedToBlack:
		move.l	#+,address(a0)
		move.b	#7,$39(a0)
		st	(Palette_rotation_disable).w
+		subq.w	#1,$2E(a0)
		bpl.s	locret_85A58
		move.w	$3A(a0),$2E(a0)
		movea.w	$30(a0),a1
		move.w	$3C(a0),d0
		moveq	#$E,d1
		moveq	#-$20,d2

-		bsr.s	DecColor_Obj
		dbf	d0,-
		subq.b	#1,$39(a0)
		bpl.s	locret_85A58
		clr.b	(Palette_rotation_disable).w
		jmp	(Go_Delete_Sprite).w

; =============== S U B R O U T I N E =======================================

DecColor_Obj:
		move.b	(a1),d3
		and.b	d1,d3
		beq.s	+
		subq.b	#2,d3
+		move.b	d3,(a1)+
		move.b	(a1),d3
		move.b	d3,d4
		and.b	d2,d3
		beq.s	+
		subi.b	#$20,d3
+		and.b	d1,d4
		beq.s	+
		subq.b	#2,d4
+		or.b	d3,d4
		move.b	d4,(a1)+

locret_855B0:
		rts

; =============== S U B R O U T I N E =======================================

Obj_FadeSelectedFromBlack:
		move.l	#+,address(a0)
		move.b	#7,$39(a0)
		st	(Palette_rotation_disable).w
+		subq.w	#1,$2E(a0)
		bpl.s	locret_855B0
		move.w	$3A(a0),$2E(a0)
		movea.w	$30(a0),a1
		movea.w	$32(a0),a2
		move.w	$3C(a0),d0
		moveq	#$E,d1
		moveq	#-$20,d2

-		bsr.s	IncColor_Obj
		dbf	d0,-
		subq.b	#1,$39(a0)
		bpl.s	locret_855B0
		clr.b	(Palette_rotation_disable).w
		jmp	(Go_Delete_Sprite).w

; =============== S U B R O U T I N E =======================================

IncColor_Obj:
		move.b	(a1),d3
		and.b	d1,d3
		move.b	(a2)+,d4
		and.b	d1,d4
		cmp.b	d4,d3
		bhs.s	+
		addq.b	#2,d3
+		move.b	d3,(a1)+
		move.b	(a1),d3
		move.b	d3,d4
		and.b	d2,d3
		move.b	(a2)+,d5
		move.b	d5,d6
		and.b	d2,d5
		cmp.b	d5,d3
		bhs.s	+
		addi.b	#$20,d3
+		and.b	d1,d4
		and.b	d1,d6
		cmp.b	d6,d4
		bhs.s	+
		addq.b	#2,d4
+		or.b	d3,d4
		move.b	d4,(a1)+
		rts

; =============== S U B R O U T I N E =======================================

sub_85E64:
		move.l	#+,address(a0)
		move.b	#7,$39(a0)
		st	(Palette_rotation_disable).w
+		subq.w	#1,$2E(a0)
		bpl.s	locret_85EA8
		move.w	$3A(a0),$2E(a0)
		lea	(Normal_palette).w,a1
		moveq	#64-1,d0

-		bsr.s	IncColor_Obj2
		dbf	d0,-
		subq.b	#1,$39(a0)
		bpl.s	locret_85EA8
		tst.b	$2C(a0)
		beq.s	+
		move.l	#sub_85EE6,address(a0)
		bset	#5,$38(a0)

locret_85EA8:
		rts
; ---------------------------------------------------------------------------
+		clr.b	(Palette_rotation_disable).w
		jmp	(Go_Delete_Sprite).w

; =============== S U B R O U T I N E =======================================

IncColor_Obj2:
		moveq	#$E,d2
		move.b	(a1),d3
		and.b	d2,d3
		cmp.b	d2,d3
		bhs.s	+
		addq.b	#2,d3
		move.b	d3,(a1)
+		addq.w	#1,a1
		move.b	(a1),d3
		move.b	d3,d4
		andi.b	#-$20,d3
		andi.b	#$E,d4
		cmpi.b	#-$20,d3
		bhs.s	+
		addi.b	#$20,d3
+		cmp.b	d2,d4
		bhs.s	+
		addq.b	#2,d4
+		or.b	d3,d4
		move.b	d4,(a1)+

locret_85EE4:
		rts

; =============== S U B R O U T I N E =======================================

sub_85EE6:
		move.l	#+,address(a0)
		move.b	#7,$39(a0)
		move.w	#3,$2E(a0)
+		subq.w	#1,$2E(a0)
		bpl.s	locret_85EE4
		move.w	#3,$2E(a0)
		lea	(Normal_palette).w,a1
		lea	(Target_palette).w,a2
		moveq	#64-1,d0

-		bsr.s	DecColor_Obj2
		dbf	d0,-
		subq.b	#1,$39(a0)
		bpl.s	locret_85EE4
		clr.b	(Palette_rotation_disable).w
		jmp	(Go_Delete_Sprite).w

; =============== S U B R O U T I N E =======================================

DecColor_Obj2:
		move.b	(a2)+,d2
		andi.b	#$E,d2
		move.b	(a1),d3
		cmp.b	d2,d3
		bls.s		+
		subq.b	#2,d3
		move.b	d3,(a1)
+		addq.w	#1,a1
		move.b	(a2)+,d2
		move.b	d2,d3
		andi.b	#-$20,d2
		andi.b	#$E,d3
		move.b	(a1),d4
		move.b	d4,d5
		andi.b	#-$20,d4
		andi.b	#$E,d5
		cmp.b	d2,d4
		bls.s		+
		subi.b	#$20,d4
+		cmp.b	d3,d5
		bls.s		+
		subq.b	#2,d5
+		or.b	d4,d5
		move.b	d5,(a1)+
		rts
