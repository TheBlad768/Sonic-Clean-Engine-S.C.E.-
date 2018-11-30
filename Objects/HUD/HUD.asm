
; =============== S U B R O U T I N E =======================================

Obj_HUD:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Obj21_Index(pc,d0.w),d0
		jmp	Obj21_Index(pc,d0.w)
; ---------------------------------------------------------------------------

Obj21_Index: offsetTable
		offsetTableEntry.w Obj21_Init
		offsetTableEntry.w Obj21_Right
		offsetTableEntry.w Obj21_Check
		offsetTableEntry.w Obj21_Left
		offsetTableEntry.w Obj21_Delete
; ---------------------------------------------------------------------------

Obj21_Init:
		addq.b  #2,obRoutine(a0)
		move.l	#Map_HUD,obMap(a0)
		move.w	#$6C2,obGfx(a0)
		move.w	#$80,obX(a0)
		move.w	#$108,obY(a0)

Obj21_Right:
		addq.w	#2,obX(a0)
		cmpi.w	#$100,obX(a0)
		bne.s	Obj21_Check
		addq.b	#2,obRoutine(a0)

Obj21_Check:
		tst.b	(Level_end_flag).w
		beq.s	Obj21_Flash

Obj21_Next:
		addq.b	#2,obRoutine(a0)

Obj21_Left:
		subq.w	#2,obX(a0)
		cmpi.w	#$80,obX(a0)
		bhs.s	Obj21_Flash
		addq.b	#2,obRoutine(a0)

Obj21_Flash:
		moveq	#0,d0
		btst	#3,(v_framebyte).w
		bne.s	Obj21_Display
		tst.w	(v_rings).w			; do you have any rings?
		bne.s	Obj21_Time			; if not, branch
		addq.w	#1,d0				; make ring counter flash red

Obj21_Time:
		cmpi.b	#9,(v_timemin).w		; have 9 minutes elapsed?
		bne.s	Obj21_Display		; if not, branch
		addq.w	#2,d0				; make time counter flash red

Obj21_Display:
		move.b	d0,obFrame(a0)
		jmp	(DisplaySprite).l
; ---------------------------------------------------------------------------

Obj21_Delete:
		jmp	(DeleteObject).l
; ---------------------------------------------------------------------------

		include	"Objects/HUD/Object Data/Map - HUD.asm"