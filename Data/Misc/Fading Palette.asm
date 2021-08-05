
; =============== S U B R O U T I N E =======================================

Pal_FadeTo:
PaletteFadeIn:
Pal_FadeFromBlack:
		move.w	#$3F,(Palette_fade_info).w
		bsr.w	Pal_FillBlack
		moveq	#$15,d4

-		move.b	#VintID_Fade,(V_int_routine).w
		bsr.w	Wait_VSync
		bsr.s	Pal_FromBlack
		dbf	d4,-
		rts
; End of function Pal_FadeFromBlack

; =============== S U B R O U T I N E =======================================

Pal_FadeIn:
Pal_FromBlack:
FadeIn_FromBlack:
		moveq	#0,d0
		lea	(Normal_palette).w,a0
		lea	(Target_palette).w,a1
		move.b	(Palette_fade_info).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(Palette_fade_count).w,d0

-		bsr.s	Pal_AddColor
		dbf	d0,-
		tst.b	(Water_flag).w
		beq.s	+
		moveq	#0,d0
		lea	(Water_palette).w,a0
		lea	(Target_water_palette).w,a1
		move.b	(Palette_fade_info).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(Palette_fade_count).w,d0

-		bsr.s	Pal_AddColor
		dbf	d0,-
+		rts
; End of function Pal_FromBlack

; =============== S U B R O U T I N E =======================================

Pal_AddColor:
		move.w	(a1)+,d2
		move.w	(a0),d3
		cmp.w	d2,d3
		beq.s	+++
		move.w	d3,d1
		addi.w	#$200,d1
		cmp.w	d2,d1
		bhi.s	+
		move.w	d1,(a0)+
		rts
+		move.w	d3,d1
		addi.w	#$20,d1
		cmp.w	d2,d1
		bhi.s	+
		move.w	d1,(a0)+
		rts
+		addq.w	#2,(a0)+
		rts
+		addq.w	#2,a0
		rts
; End of function Pal_AddColor

; =============== S U B R O U T I N E =======================================

Pal_FillBlack:
		moveq	#0,d0
		lea	(Normal_palette).w,a0
		move.b	(Palette_fade_info).w,d0
		adda.w	d0,a0
		moveq	#0,d1
		move.b	(Palette_fade_count).w,d0

-		move.w	d1,(a0)+
		tst.b	(Water_flag).w
		beq.s	+
		move.w	d1,-(Normal_palette-(Water_palette-2))(a0)
+		dbf	d0,-
		rts
; End of function Pal_FillBlack

; =============== S U B R O U T I N E =======================================

Pal_FadeFrom:
PaletteFadeOut:
Pal_FadeToBlack:
		move.w	#$3F,(Palette_fade_info).w
		moveq	#$15,d4

-		move.b	#VintID_Fade,(V_int_routine).w
		bsr.w	Wait_VSync
		bsr.s	Pal_ToBlack
		dbf	d4,-
		rts
; End of function Pal_FadeToBlack

; =============== S U B R O U T I N E =======================================

Pal_ToBlack:
Pal_FadeOut:
FadeOut_ToBlack:
		moveq	#0,d0
		lea	(Normal_palette).w,a0
		move.b	(Palette_fade_info).w,d0
		adda.w	d0,a0
		move.b	(Palette_fade_count).w,d0

-		bsr.s	Pal_DecColor
		dbf	d0,-
		moveq	#0,d0
		lea	(Water_palette).w,a0
		move.b	(Palette_fade_info).w,d0
		adda.w	d0,a0
		move.b	(Palette_fade_count).w,d0

-		bsr.s	Pal_DecColor
		dbf	d0,-
		rts
; End of function Pal_ToBlack

; =============== S U B R O U T I N E =======================================

Pal_DecColor:
		move.w	(a0),d2
		beq.s	+++
		move.w	d2,d1
		andi.w	#$E,d1
		beq.s	+
		subq.w	#2,(a0)+
		rts
+		move.w	d2,d1
		andi.w	#$E0,d1
		beq.s	+
		subi.w	#$20,(a0)+
		rts
+		move.w	d2,d1
		andi.w	#$E00,d1
		beq.s	+
		subi.w	#$200,(a0)+
		rts
+		addq.w	#2,a0
		rts
; End of function Pal_DecColor

; =============== S U B R O U T I N E =======================================

Pal_FillWhite:
		moveq	#0,d0
		lea	(Normal_palette).w,a0
		move.b	(Palette_fade_info).w,d0
		adda.w	d0,a0
		move.w	#$EEE,d1
		move.b	(Palette_fade_count).w,d0

-		move.w	d1,(a0)+
		dbf	d0,-
		clr.w	(Pal_fade_delay2).w
		rts
; End of function Pal_FillWhite

; =============== S U B R O U T I N E =======================================

Pal_FromBlackWhite:
		move.w	#$3F,(Palette_fade_info).w
		bsr.s	Pal_FillWhite
		moveq	#$15,d4

-		move.b	#VintID_Fade,(V_int_routine).w
		bsr.w	Wait_VSync
		bsr.s	Pal_FromWhite
		dbf	d4,-
		rts
; End of function Pal_FromBlackWhite

; =============== S U B R O U T I N E =======================================

Pal_FromWhite:
		subq.w	#1,(Pal_fade_delay2).w
		bpl.s	+
		move.w	#2,(Pal_fade_delay2).w
		moveq	#0,d0
		lea	(Normal_palette).w,a0
		lea	(Target_palette).w,a1
		move.b	(Palette_fade_info).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(Palette_fade_count).w,d0

-		bsr.s	Pal_DecColor2
		dbf	d0,-
		tst.b	(Water_flag).w
		beq.s	+
		moveq	#0,d0
		lea	(Water_palette).w,a0
		lea	(Target_water_palette).w,a1
		move.b	(Palette_fade_info).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(Palette_fade_count).w,d0

-		bsr.s	Pal_DecColor2
		dbf	d0,-
+		rts
; End of function Pal_FromWhite

; =============== S U B R O U T I N E =======================================

Pal_DecColor2:
		move.b	(a1)+,d2
		andi.b	#$E,d2
		move.b	(a0),d3
		andi.b	#$E,d3
		cmp.b	d2,d3
		bls.s		+
		subq.b	#2,d3
+		move.b	d3,(a0)+
		move.b	(a1)+,d1
		move.b	d1,d2
		andi.b	#$E0,d1
		move.b	(a0),d3
		move.b	d3,d5
		andi.b	#$E0,d3
		cmp.b	d1,d3
		bls.s		+
		subi.b	#$20,d3
+		andi.b	#$E,d2
		andi.b	#$E,d5
		cmp.b	d2,d5
		bls.s		+
		subq.b	#2,d5
+		or.b	d5,d3
		move.b	d3,(a0)+
		rts
; End of function Pal_DecColor2

; =============== S U B R O U T I N E =======================================

Pal_FadeToWhite:
		move.w	#$3F,(Palette_fade_info).w
		moveq	#$15,d4

-		move.b	#VintID_Fade,(V_int_routine).w
		bsr.w	Wait_VSync
		bsr.s	Pal_ToWhite
		dbf	d4,-
		rts
; End of function Pal_FadeToWhite

; =============== S U B R O U T I N E =======================================

Pal_ToWhite:
		moveq	#0,d0
		lea	(Normal_palette).w,a0
		move.b	(Palette_fade_info).w,d0
		adda.w	d0,a0
		move.b	(Palette_fade_count).w,d0

-		bsr.s	Pal_AddColor2
		dbf	d0,-
		moveq	#0,d0
		lea	(Water_palette).w,a0
		move.b	(Palette_fade_info).w,d0
		adda.w	d0,a0
		move.b	(Palette_fade_count).w,d0

-		bsr.s	Pal_AddColor2
		dbf	d0,-
		rts
; End of function Pal_ToWhite

; =============== S U B R O U T I N E =======================================

Pal_AddColor2:
		move.w	(a0),d2
		cmpi.w	#$EEE,d2
		beq.s	+++
		move.w	d2,d1
		andi.w	#$E,d1
		cmpi.w	#$E,d1
		beq.s	+
		addq.w	#2,(a0)+
		rts
+		move.w	d2,d1
		andi.w	#$E0,d1
		cmpi.w	#$E0,d1
		beq.s	+
		addi.w	#$20,(a0)+
		rts
+		move.w	d2,d1
		andi.w	#$E00,d1
		cmpi.w	#$E00,d1
		beq.s	+
		addi.w	#$200,(a0)+
		rts
+		addq.w	#2,a0
		rts
; End of function Pal_AddColor2
