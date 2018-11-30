
; =============== S U B R O U T I N E =======================================

Pal_FadeTo:
PaletteFadeIn:
Pal_FadeFromBlack:
		move.w	#$3F,(Palette_fade_info).w
		jsr	Pal_FillBlack(pc)
		move.w	#$15,d4

-		move.b	#VintID_Fade,(V_int_routine).w
		bsr.w	Wait_VSync
		bsr.s	Pal_FromBlack
		bsr.w	Process_Nem_Queue_Init
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
		move.w	d1,-$82(a0)
+		dbf	d0,-
		rts
; End of function Pal_FillBlack

; =============== S U B R O U T I N E =======================================

Pal_FadeFrom:
PaletteFadeOut:
Pal_FadeToBlack:
		move.w	#$3F,(Palette_fade_info).w
		move.w	#$15,d4

-		move.b	#VintID_Fade,(V_int_routine).w
		bsr.w	Wait_VSync
		bsr.s	Pal_ToBlack
		bsr.w	Process_Nem_Queue_Init
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
