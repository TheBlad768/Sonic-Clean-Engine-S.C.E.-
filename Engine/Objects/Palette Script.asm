; ---------------------------------------------------------------------------
; Palette script subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Run_PalRotationScript:

		; check disable flag
		tst.b	(Palette_rotation_disable).w
		bne.w	locret_85A00
		lea	(Palette_rotation_data).w,a1

loc_85994:
		move.w	(a1),d0								; load palette displacement to d0
		beq.s	locret_85A00							; if 0, return
		subq.b	#1,2(a1)							; decrement delay
		bpl.s	loc_859CA							; if still positive, go to next entry
		movea.l	4(a1),a2							; load palette script address to a2
		movea.w	(a2),a3								; load destination address to a3
		lea	(a2),a4								; copy script ROM address to a4
		adda.w	d0,a4								; skip to palette data
		move.w	(a4),d1								; load the first entry to d1
		bpl.s	.skip								; if positive, it is a normal entry
		bsr.s	Run_PalRotationScript_Main					; this is a command

.skip
		moveq	#0,d2
		move.b	2(a2),d2							; load number of colors to d2

.loop
		move.w	(a4)+,(a3)+							; copy the next color into destination
		dbf	d2,.loop							; loop for every color
		move.w	(a4)+,d0							; load next delay
		move.b	d0,2(a1)							; save the delay
		move.l	a4,d0								; copy current script position into d0
		move.l	a2,d1								; copy palette script origin to d1
		sub.l	d1,d0								; calculate the current displacement
		move.w	d0,(a1)								; store it back

loc_859CA:
		addq.w	#8,a1								; go to next script
		bra.s	loc_85994							; run the code again
; ---------------------------------------------------------------------------

Run_PalRotationScript_Main:
		move.b	3(a2),d2							; load additional parameter to d2
		beq.s	loc_859FC							; FE (repeat)
		neg.w	d1
		jmp	.index-4(pc,d1.w)
; ---------------------------------------------------------------------------

.index
		bra.s	loc_859E2							; FC (loop)
; ---------------------------------------------------------------------------

		; custom code								; FA (run)
		addq.b	#1,3(a1)
		cmp.b	3(a1),d2
		bhi.s	loc_859FC							; wait for counter to finish
		movea.l	(Palette_rotation_custom).w,a2
		pea	(a1)								; save a1
		jsr	(a2)								; run custom routine
		movea.l	(sp)+,a1							; restore a1
		addq.w	#4,sp								; exit
		bra.s	loc_859CA
; ---------------------------------------------------------------------------

loc_859E2:
		addq.b	#1,3(a1)							; add one to counter
		cmp.b	3(a1),d2							; compare with max counter
		bhi.s	loc_859FC
		move.w	2(a4),d2
		adda.w	d2,a2
		move.l	a2,4(a1)							; load new script after counter has finished
		movea.w	(a2),a3
		clr.w	2(a1)

loc_859FC:
		lea	4(a2),a4							; start from the beginning of the rotation

locret_85A00:
		rts

; ---------------------------------------------------------------------------
; Palette script 2 subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Run_PalRotationScript2:

		; check disable flag
		tst.b	(Palette_rotation_disable).w
		bne.s	.return

		; wait
		subq.b	#1,palrotation_frame_timer(a0)					; subtract 1 from frame duration
		bpl.s	.return								; if time remains, branch

		; run
		movea.l	(a1)+,a3							; address of palette animation data
		move.w	(a1)+,d0							; number of colors to replace
		moveq	#2,d1
		add.b	palrotation_frame(a0),d1					; next frame number
		moveq	#0,d2
		move.b	(a1,d1.w),d2							; read frame from script
		bpl.s	.skip								; if animation is not complete, branch

		; repeat animation from beginning
		moveq	#0,d1
		move.b	(a1),d2

.skip
		move.b	d1,palrotation_frame(a0)					; set frame
		move.b	1(a1,d1.w),palrotation_frame_timer(a0)				; set frame duration
		add.w	d2,d2								; multiply by 2
		adda.w	(a3,d2.w),a3

.loop
		move.w	(a3)+,(a2)+
		dbf	d0,.loop

.return
		rts

; ---------------------------------------------------------------------------
; Set palette script subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Run_PalRotationSetScript:
		lea	(Palette_rotation_data).w,a2
		move.l	(a1)+,(a2)+
		move.l	(a1)+,(a2)+
		clr.w	(a2)
		rts
