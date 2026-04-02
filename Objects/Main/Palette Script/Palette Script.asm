; ---------------------------------------------------------------------------
; Smooth Palette (Object)
; ---------------------------------------------------------------------------

; dynamic object variables

	dsset animations								; pretend we're in the RAM

smoothpalette.delay			ds.w 1						; (2 bytes)
smoothpalette.destination		ds.w 1						; (2 bytes)
smoothpalette.source			ds.l 1						; (4 bytes)
smoothpalette.size			ds.w 1						; (2 bytes)

	dsreset										; stop pretending and reset the program counter

; =============== S U B R O U T I N E =======================================

Obj_SmoothPalette:
		move.l	#.main,code_addr(a0)
		move.b	#7,count(a0)							; set 7 for normal fade
		st	(Palette_rotation_disable).w

.main

		; wait
		subq.w	#1,wait_timer(a0)						; subtract 1 from time delay
		bpl.s	.return								; if time still remains, branch
		move.w	smoothpalette.delay(a0),wait_timer(a0)				; reset time delay

		; load data
		movea.w	smoothpalette.destination(a0),a1				; palette RAM address
		movea.l	smoothpalette.source(a0),a2					; palette pointer
		move.w	smoothpalette.size(a0),d0					; palette size
		jsr	(Pal_SmoothToPalette).w

		; check delete
		subq.b	#1,count(a0)
		bpl.s	.return

		; delete
		clr.b	(Palette_rotation_disable).w
		jmp	(Go_Delete_Object).w
; ---------------------------------------------------------------------------

.return
		rts

; ---------------------------------------------------------------------------
; Smooth Palette 2 (Object)
; ---------------------------------------------------------------------------

; dynamic object variables

	dsset animations								; pretend we're in the RAM

smoothpalette2.delay			ds.w 1						; (2 bytes)
smoothpalette2.source			ds.l 1						; script pointer (4 bytes)

	dsreset										; stop pretending and reset the program counter

; =============== S U B R O U T I N E =======================================

Obj_SmoothPalette2:
		move.l	#.main,code_addr(a0)
		move.b	#7,count(a0)							; set 7-1 for normal fade
		st	(Palette_rotation_disable).w

.main

		; wait
		subq.w	#1,wait_timer(a0)						; subtract 1 from time delay
		bpl.s	.return								; if time still remains, branch
		move.w	smoothpalette2.delay(a0),wait_timer(a0)				; reset time delay

		; load data
		movea.l	smoothpalette2.source(a0),a3
		move.w	(a3)+,d6							; loop count

.loop
		movea.l	(a3)+,a2							; palette pointer
		movea.w	(a3)+,a1							; palette RAM address
		move.w	(a3)+,d0							; palette size
		jsr	(Pal_SmoothToPalette).w
		dbf	d6,.loop

		; check delete
		subq.b	#1,count(a0)
		bpl.s	.return

		; delete
		clr.b	(Palette_rotation_disable).w
		jmp	(Go_Delete_Object).w
; ---------------------------------------------------------------------------

.return
		rts
; ---------------------------------------------------------------------------

Child6_SmoothPalette:
		dc.w 1-1
		dc.l Obj_SmoothPalette
Child6_SmoothPalette2:
		dc.w 1-1
		dc.l Obj_SmoothPalette2

; ---------------------------------------------------------------------------
; Fade selected to black (Object)
; ---------------------------------------------------------------------------

; dynamic object variables

	dsset animations								; pretend we're in the RAM

fadeselectedtoblack.delay		ds.w 1						; (2 bytes)
fadeselectedtoblack.source		ds.w 1						; (2 bytes)
fadeselectedtoblack.size		ds.w 1						; (2 bytes)

	dsreset										; stop pretending and reset the program counter

; =============== S U B R O U T I N E =======================================

Obj_FadeSelectedToBlack:
		move.l	#.main,code_addr(a0)
		move.b	#7,count(a0)							; set 7 for normal fade
		st	(Palette_rotation_disable).w

.main

		; wait
		subq.w	#1,wait_timer(a0)						; subtract 1 from time delay
		bpl.s	Obj_SmoothPalette2.return					; if time still remains, branch
		move.w	fadeselectedtoblack.delay(a0),wait_timer(a0)			; reset time delay

		; load data
		movea.w	fadeselectedtoblack.source(a0),a1				; palette RAM address
		move.w	fadeselectedtoblack.size(a0),d0					; palette size
		moveq	#$E,d1
		moveq	#signextendB($E0),d2

.loop
		jsr	(DecColor_Obj).w
		dbf	d0,.loop

		; check delete
		subq.b	#1,count(a0)
		bpl.s	Obj_SmoothPalette2.return

		; delete
		clr.b	(Palette_rotation_disable).w
		jmp	(Go_Delete_Object).w

; ---------------------------------------------------------------------------
; Fade selected from black (Object)
; ---------------------------------------------------------------------------

; dynamic object variables

	dsset animations								; pretend we're in the RAM

fadeselectedfromblack.delay		ds.w 1						; (2 bytes)
fadeselectedfromblack.source		ds.w 1						; (2 bytes)
fadeselectedfromblack.source2		ds.w 1						; (2 bytes)
fadeselectedfromblack.size		ds.w 1						; (2 bytes)

	dsreset										; stop pretending and reset the program counter

; =============== S U B R O U T I N E =======================================

Obj_FadeSelectedFromBlack:
		move.l	#.main,code_addr(a0)
		move.b	#7,count(a0)							; set 7 for normal fade
		st	(Palette_rotation_disable).w

.main

		; wait
		subq.w	#1,wait_timer(a0)						; subtract 1 from time delay
		bpl.s	Obj_FadeToWhite.return						; if time still remains, branch
		move.w	fadeselectedfromblack.delay(a0),wait_timer(a0)			; reset time delay

		; load data
		movea.w	fadeselectedfromblack.source(a0),a1				; normal palette RAM address
		movea.w	fadeselectedfromblack.source2(a0),a2				; target palette RAM address
		move.w	fadeselectedfromblack.size(a0),d0				; palette size
		moveq	#$E,d1
		moveq	#signextendB($E0),d2

.loop
		jsr	(IncColor_Obj).w
		dbf	d0,.loop

		; check delete
		subq.b	#1,count(a0)
		bpl.s	Obj_FadeToWhite.return

		; delete
		clr.b	(Palette_rotation_disable).w
		jmp	(Go_Delete_Object).w

; ---------------------------------------------------------------------------
; Fade selected to white (Object)
; ---------------------------------------------------------------------------

; dynamic object variables

	dsset animations								; pretend we're in the RAM

fadetowhite.delay			ds.w 1						; (2 bytes)

	dsreset										; stop pretending and reset the program counter

; =============== S U B R O U T I N E =======================================

Obj_FadeToWhite:
		move.l	#.main,code_addr(a0)
		move.b	#7,count(a0)							; set 7 for normal fade
		st	(Palette_rotation_disable).w

.main

		; wait
		subq.w	#1,wait_timer(a0)						; subtract 1 from time delay
		bpl.s	.return								; if time still remains, branch
		move.w	fadetowhite.delay(a0),wait_timer(a0)				; reset time delay

		; start
		lea	(Normal_palette).w,a1						; palette pointer
		moveq	#64-1,d0							; palette size

.loop
		jsr	(IncColor_Obj2).w
		dbf	d0,.loop

		; check delete
		subq.b	#1,count(a0)
		bpl.s	.return

		; check exit
		tst.b	subtype(a0)
		beq.s	.delete
		move.l	#Obj_FadeFromWhite,code_addr(a0)
		bset	#5,state_flags(a0)

.return
		rts
; ---------------------------------------------------------------------------

.delete
		clr.b	(Palette_rotation_disable).w
		jmp	(Go_Delete_Object).w

; ---------------------------------------------------------------------------
; Fade selected from white (Object)
; ---------------------------------------------------------------------------

; dynamic object variables

; =============== S U B R O U T I N E =======================================

Obj_FadeFromWhite:
		move.l	#.main,code_addr(a0)
		move.b	#7,count(a0)							; set 7 for normal fade
		move.w	#3,wait_timer(a0)						; set wait time

.main

		; wait
		subq.w	#1,wait_timer(a0)						; subtract 1 from time delay
		bpl.s	Obj_FadeToWhite.return						; if time still remains, branch
		addq.w	#3+1,wait_timer(a0)						; reset time delay

		; start
		lea	(Normal_palette).w,a1						; normal palette RAM address
		lea	(Target_palette).w,a2						; target palette RAM address
		moveq	#64-1,d0							; palette size

.loop
		jsr	(DecColor_Obj2).w
		dbf	d0,.loop

		; check delete
		subq.b	#1,count(a0)
		bpl.s	Obj_FadeToWhite.return

		; delete
		clr.b	(Palette_rotation_disable).w
		jmp	(Go_Delete_Object).w
