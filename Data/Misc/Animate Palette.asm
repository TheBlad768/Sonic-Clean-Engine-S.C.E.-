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
		moveq	#0,d2
		moveq	#0,d0
		move.w	(Current_zone_and_act).w,d0
		lsl.b	#6,d0
		lsr.w	#5,d0
		move.w	Offs_AnPal(pc,d0.w),d0
		jmp	Offs_AnPal(pc,d0.w)
; ---------------------------------------------------------------------------

Offs_AnPal: offsetTable
		offsetTableEntry.w AnPal_None		; DEZ 1
		offsetTableEntry.w AnPal_None		; DEZ 2
		offsetTableEntry.w AnPal_None		; DEZ 3
		offsetTableEntry.w AnPal_None		; DEZ 4

		zonewarning Offs_AnPal,(2*4)

; =============== S U B R O U T I N E =======================================