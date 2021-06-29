; ---------------------------------------------------------------------------
; Palette cycling routine loading subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Animate_Palette:
		tst.w	(Palette_fade_timer).w
		bmi.s	AnPal_None
		beq.s	AnPal_Load
		subq.w	#1,(Palette_fade_timer).w
		bra.w	Pal_FromBlack
; ---------------------------------------------------------------------------

AnPal_None:
		rts
; ---------------------------------------------------------------------------

AnPal_Load:
		movea.l	(Level_data_addr_RAM.AnPal).w,a0
		jmp	(a0)

; =============== S U B R O U T I N E =======================================