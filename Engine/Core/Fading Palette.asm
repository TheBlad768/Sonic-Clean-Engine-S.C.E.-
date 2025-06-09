; ---------------------------------------------------------------------------
; Fade palette subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Pal_FillBlack:
		moveq	#0,d0
		lea	(Normal_palette).w,a0
		move.b	(Palette_fade_info).w,d0
		adda.w	d0,a0
		moveq	#cBlack,d1
		move.b	(Palette_fade_count).w,d0

.palettewrite
		move.w	d1,(a0)+									; fill palette with $000 (black)

		; check water
		tst.b	(Water_flag).w									; does level have water?
		beq.s	.notwater									; if not, branch
		move.w	d1,-(Normal_palette-(Water_palette-2))(a0)					; fill water palette with $000 (black)

.notwater
		dbf	d0,.palettewrite
		rts

; =============== S U B R O U T I N E =======================================

Pal_FadeFromBlack:
		move.w	#bytes_to_word((palette_line_0>>8),64-1),(Palette_fade_info).w			; set fade info and fade count
		bsr.s	Pal_FillBlack
		moveq	#$15,d4

.nextframe
		move.w	d4,-(sp)
		move.b	#VintID_Fade,(V_int_routine).w
		bsr.w	Process_KosPlus_Queue
		bsr.w	Wait_VSync
		bsr.s	Pal_FromBlack
		bsr.w	Process_KosPlus_Module_Queue
		move.w	(sp)+,d4
		dbf	d4,.nextframe
		rts

; =============== S U B R O U T I N E =======================================

Pal_FromBlack:
		moveq	#0,d0
		lea	(Normal_palette).w,a0
		lea	(Target_palette).w,a1
		move.b	(Palette_fade_info).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(Palette_fade_count).w,d0

.nextcolour
		bsr.s	Pal_AddColor
		dbf	d0,.nextcolour

		; check water
		tst.b	(Water_flag).w									; does level have water?
		beq.s	.notwater									; if not, branch

		; update underwater palette
		moveq	#0,d0
		lea	(Water_palette).w,a0
		lea	(Target_water_palette).w,a1
		move.b	(Palette_fade_info).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(Palette_fade_count).w,d0

.nextcolour2
		bsr.s	Pal_AddColor
		dbf	d0,.nextcolour2

.notwater
		rts

; =============== S U B R O U T I N E =======================================

Pal_AddColor:
		move.w	(a1)+,d2
		move.w	(a0),d3
		cmp.w	d2,d3										; is it the same color?
		beq.s	.updatenone									; if yes, branch

		; update blue
		move.w	d3,d1
		addi.w	#$200,d1									; increase blue value
		cmp.w	d2,d1										; has blue reached threshold level?
		bhi.s	.updategreen									; if yes, branch
		move.w	d1,(a0)+									; update palette
		rts
; ---------------------------------------------------------------------------

.updategreen
		move.w	d3,d1
		addi.w	#$20,d1										; increase green value
		cmp.w	d2,d1										; has green reached threshold level?
		bhi.s	.updatered									; if yes, branch
		move.w	d1,(a0)+									; update palette
		rts
; ---------------------------------------------------------------------------

.updatered
		addq.w	#2,(a0)+									; increase red value
		rts
; ---------------------------------------------------------------------------

.updatenone
		addq.w	#2,a0										; skip color
		rts

; =============== S U B R O U T I N E =======================================

Pal_FadeToBlack:
		move.w	#bytes_to_word((palette_line_0>>8),64-1),(Palette_fade_info).w			; set fade info and fade count
		moveq	#$15,d4

.nextframe
		move.w	d4,-(sp)
		move.b	#VintID_Fade,(V_int_routine).w
		bsr.w	Process_KosPlus_Queue
		bsr.w	Wait_VSync
		bsr.s	Pal_ToBlack
		bsr.w	Process_KosPlus_Module_Queue
		move.w	(sp)+,d4
		dbf	d4,.nextframe
		rts

; =============== S U B R O U T I N E =======================================

Pal_ToBlack:
		moveq	#0,d0
		lea	(Normal_palette).w,a0
		move.b	(Palette_fade_info).w,d0
		adda.w	d0,a0
		move.b	(Palette_fade_count).w,d0

.nextcolour
		bsr.s	Pal_DecColor
		dbf	d0,.nextcolour

		; check water
		tst.b	(Water_flag).w									; does level have water?
		beq.s	.notwater									; if not, branch

		; update underwater palette
		moveq	#0,d0
		lea	(Water_palette).w,a0
		move.b	(Palette_fade_info).w,d0
		adda.w	d0,a0
		move.b	(Palette_fade_count).w,d0

.nextcolour2
		bsr.s	Pal_DecColor
		dbf	d0,.nextcolour2

.notwater
		rts

; =============== S U B R O U T I N E =======================================

Pal_DecColor:
		move.w	(a0),d2
		beq.s	.updatenone									; branch, if the color is already black

		; update red
		move.w	d2,d1
		andi.w	#cRed,d1
		beq.s	.updategreen
		subq.w	#2,(a0)+									; decrease red value
		rts
; ---------------------------------------------------------------------------

.updategreen
		move.w	d2,d1
		andi.w	#cGreen,d1
		beq.s	.updateblue
		subi.w	#$20,(a0)+									; decrease green value
		rts
; ---------------------------------------------------------------------------

.updateblue
		move.w	d2,d1
		andi.w	#cBlue,d1
		beq.s	.updatenone
		subi.w	#$200,(a0)+									; decrease blue value
		rts
; ---------------------------------------------------------------------------

.updatenone
		addq.w	#2,a0										; skip color
		rts

; =============== S U B R O U T I N E =======================================

Pal_FillWhite:
		moveq	#0,d0
		move.w	d0,(Pal_fade_delay2).w
		lea	(Normal_palette).w,a0
		move.b	(Palette_fade_info).w,d0
		adda.w	d0,a0
		move.w	#cWhite,d1
		move.b	(Palette_fade_count).w,d0

.palettewrite
		move.w	d1,(a0)+
		dbf	d0,.palettewrite
		rts

; =============== S U B R O U T I N E =======================================

Pal_FadeFromWhite:
		move.w	#bytes_to_word((palette_line_0>>8),64-1),(Palette_fade_info).w			; set fade info and fade count
		bsr.s	Pal_FillWhite
		moveq	#$15,d4

.nextframe
		move.w	d4,-(sp)
		move.b	#VintID_Fade,(V_int_routine).w
		bsr.w	Process_KosPlus_Queue
		bsr.w	Wait_VSync
		bsr.s	Pal_FromWhite
		bsr.w	Process_KosPlus_Module_Queue
		move.w	(sp)+,d4
		dbf	d4,.nextframe
		rts

; =============== S U B R O U T I N E =======================================

Pal_FromWhite:
		subq.w	#1,(Pal_fade_delay2).w
		bpl.s	.notwater
		move.w	#2,(Pal_fade_delay2).w
		moveq	#0,d0
		lea	(Normal_palette).w,a0
		lea	(Target_palette).w,a1
		move.b	(Palette_fade_info).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(Palette_fade_count).w,d0

.nextcolour
		bsr.s	Pal_DecColor2
		dbf	d0,.nextcolour

		; check water
		tst.b	(Water_flag).w									; does level have water?
		beq.s	.notwater									; if not, branch

		; update underwater palette
		moveq	#0,d0
		lea	(Water_palette).w,a0
		lea	(Target_water_palette).w,a1
		move.b	(Palette_fade_info).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(Palette_fade_count).w,d0

.nextcolour2
		bsr.s	Pal_DecColor2
		dbf	d0,.nextcolour2

.notwater
		rts

; =============== S U B R O U T I N E =======================================

Pal_DecColor2:
		moveq	#$E,d2
		and.b	(a1)+,d2
		moveq	#$E,d3
		and.b	(a0),d3
		cmp.b	d2,d3
		bls.s	.skip
		subq.b	#2,d3

.skip
		move.b	d3,(a0)+
		move.b	(a1)+,d1
		move.b	d1,d2
		andi.b	#$E0,d1
		move.b	(a0),d3
		move.b	d3,d5
		andi.b	#$E0,d3
		cmp.b	d1,d3
		bls.s	.skip2
		subi.b	#$20,d3

.skip2
		andi.b	#$E,d2
		andi.b	#$E,d5
		cmp.b	d2,d5
		bls.s	.skip3
		subq.b	#2,d5

.skip3
		or.b	d5,d3
		move.b	d3,(a0)+
		rts

; =============== S U B R O U T I N E =======================================

Pal_FadeToWhite:
		move.w	#bytes_to_word((palette_line_0>>8),64-1),(Palette_fade_info).w			; set fade info and fade count
		moveq	#$15,d4

.nextframe
		move.w	d4,-(sp)
		move.b	#VintID_Fade,(V_int_routine).w
		bsr.w	Process_KosPlus_Queue
		bsr.w	Wait_VSync
		bsr.s	Pal_ToWhite
		bsr.w	Process_KosPlus_Module_Queue
		move.w	(sp)+,d4
		dbf	d4,.nextframe
		rts

; =============== S U B R O U T I N E =======================================

Pal_ToWhite:
		moveq	#0,d0
		lea	(Normal_palette).w,a0
		move.b	(Palette_fade_info).w,d0
		adda.w	d0,a0
		move.b	(Palette_fade_count).w,d0

.nextcolour
		bsr.s	Pal_AddColor2
		dbf	d0,.nextcolour

		; check water
		tst.b	(Water_flag).w									; does level have water?
		beq.s	.notwater									; if not, branch

		; update underwater palette
		moveq	#0,d0
		lea	(Water_palette).w,a0
		move.b	(Palette_fade_info).w,d0
		adda.w	d0,a0
		move.b	(Palette_fade_count).w,d0

.nextcolour2
		bsr.s	Pal_AddColor2
		dbf	d0,.nextcolour2

.notwater
		rts

; =============== S U B R O U T I N E =======================================

Pal_AddColor2:
		move.w	(a0),d2
		cmpi.w	#cWhite,d2									; is the color already white?
		beq.s	.updatenone									; if yes, branch

		; update red
		move.w	d2,d1
		andi.w	#cRed,d1									; get only red color from RAM
		cmpi.w	#cRed,d1									; has red reached threshold level?
		beq.s	.updategreen									; if yes, branch
		addq.w	#2,(a0)+									; increase red value
		rts
; ---------------------------------------------------------------------------

.updategreen
		move.w	d2,d1
		andi.w	#cGreen,d1									; get only green color from RAM
		cmpi.w	#cGreen,d1									; has green reached threshold level?
		beq.s	.updateblue									; if yes, branch
		addi.w	#$20,(a0)+									; increase green value
		rts
; ---------------------------------------------------------------------------

.updateblue
		move.w	d2,d1
		andi.w	#cBlue,d1									; get only blue color from RAM
		cmpi.w	#cBlue,d1									; has blue reached threshold level?
		beq.s	.updatenone									; if yes, branch
		addi.w	#$200,(a0)+									; increase blue value
		rts
; ---------------------------------------------------------------------------

.updatenone
		addq.w	#2,a0										; skip color
		rts

; =============== S U B R O U T I N E =======================================

Pal_SmoothToPalette:

.process
		move.w	(a1),d1										; palette RAM (to)
		move.w	(a2)+,d2									; palette pointer (from)
		move.w	d1,d3										; copy color from RAM to d3
		move.w	d2,d4										; copy color from pointer to d4

		; get red
		andi.w	#cRed,d3									; get only red color from RAM
		andi.w	#cRed,d4									; get only red color from pointer
		cmp.w	d3,d4										; has red reached threshold level?
		beq.s	.getgreen									; if yes, branch
		blo.s	.decred										; "

		; add red
		andi.w	#$FFF1,d1									; clear red color in RAM
		addq.w	#2,d3										; increase red value
		or.w	d3,d1										; set color
		bra.s	.getgreen									; "
; ---------------------------------------------------------------------------

.decred
		andi.w	#$FFF1,d1									; clear red color in RAM
		subq.w	#2,d3										; decrease red value
		or.w	d3,d1										; set color

.getgreen
		move.w	d1,d3										; copy color from RAM to d3
		move.w	d2,d4										; copy color from pointer to d4
		andi.w	#cGreen,d3									; get only green color from RAM
		andi.w	#cGreen,d4									; get only green color from pointer
		cmp.w	d3,d4										; has green reached threshold level?
		beq.s	.getblue									; if yes, branch
		blo.s	.decgreen									; "

		; add green
		andi.w	#$FF1F,d1									; clear green color in RAM
		addi.w	#$20,d3										; increase green value
		or.w	d3,d1										; set color
		bra.s	.getblue									; "
; ---------------------------------------------------------------------------

.decgreen
		andi.w	#$FF1F,d1									; clear green color in RAM
		subi.w	#$20,d3										; decrease green value
		or.w	d3,d1										; set color

.getblue
		move.w	d1,d3										; copy color from RAM to d3
		move.w	d2,d4										; copy color from pointer to d4
		andi.w	#cBlue,d3									; get only blue color from RAM
		andi.w	#cBlue,d4									; get only blue color from pointer
		cmp.w	d3,d4										; has blue reached threshold level?
		beq.s	.setcolor									; if yes, branch
		blo.s	.decblue									; "

		; add blue
		andi.w	#$F1FF,d1									; clear blue color in RAM
		addi.w	#$200,d3									; increase blue value
		or.w	d3,d1										; set color
		bra.s	.setcolor									; "
; ---------------------------------------------------------------------------

.decblue
		andi.w	#$F1FF,d1									; clear blue color in RAM
		subi.w	#$200,d3									; decrease blue value
		or.w	d3,d1										; set color

.setcolor
		move.w	d1,(a1)+									; set color to RAM
		dbf	d0,.process									; "
		rts

; =============== S U B R O U T I N E =======================================

DecColor_Obj:
		move.b	(a1),d3
		and.b	d1,d3
		beq.s	.skip
		subq.b	#2,d3

.skip
		move.b	d3,(a1)+
		move.b	(a1),d3
		move.b	d3,d4
		and.b	d2,d3
		beq.s	.skip2
		subi.b	#$20,d3

.skip2
		and.b	d1,d4
		beq.s	.skip3
		subq.b	#2,d4

.skip3
		or.b	d3,d4
		move.b	d4,(a1)+
		rts

; =============== S U B R O U T I N E =======================================

IncColor_Obj:
		move.b	(a1),d3
		and.b	d1,d3
		move.b	(a2)+,d4
		and.b	d1,d4
		cmp.b	d4,d3
		bhs.s	.skip
		addq.b	#2,d3

.skip
		move.b	d3,(a1)+
		move.b	(a1),d3
		move.b	d3,d4
		and.b	d2,d3
		move.b	(a2)+,d5
		move.b	d5,d6
		and.b	d2,d5
		cmp.b	d5,d3
		bhs.s	.skip2
		addi.b	#$20,d3

.skip2
		and.b	d1,d4
		and.b	d1,d6
		cmp.b	d6,d4
		bhs.s	.skip3
		addq.b	#2,d4

.skip3
		or.b	d3,d4
		move.b	d4,(a1)+
		rts

; =============== S U B R O U T I N E =======================================

IncColor_Obj2:
		moveq	#$E,d2										; cWhite
		move.b	(a1),d3
		and.b	d2,d3
		cmp.b	d2,d3
		bhs.s	.skip
		addq.b	#2,d3
		move.b	d3,(a1)

.skip
		addq.w	#1,a1
		move.b	(a1),d3
		move.b	d3,d4
		andi.b	#$E0,d3
		andi.b	#$E,d4
		cmpi.b	#$E0,d3
		bhs.s	.skip2
		addi.b	#$20,d3

.skip2
		cmp.b	d2,d4
		bhs.s	.skip3
		addq.b	#2,d4

.skip3
		or.b	d3,d4
		move.b	d4,(a1)+
		rts

; =============== S U B R O U T I N E =======================================

DecColor_Obj2:
		moveq	#$E,d2
		and.b	(a2)+,d2
		move.b	(a1),d3
		cmp.b	d2,d3
		bls.s	.skip
		subq.b	#2,d3
		move.b	d3,(a1)

.skip
		addq.w	#1,a1
		move.b	(a2)+,d2
		move.b	d2,d3
		andi.b	#$E0,d2
		andi.b	#$E,d3
		move.b	(a1),d4
		move.b	d4,d5
		andi.b	#$E0,d4
		andi.b	#$E,d5
		cmp.b	d2,d4
		bls.s	.skip2
		subi.b	#$20,d4

.skip2
		cmp.b	d3,d5
		bls.s	.skip3
		subq.b	#2,d5

.skip3
		or.b	d4,d5
		move.b	d5,(a1)+
		rts
