; ---------------------------------------------------------------------------
; Hidden Monitor (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_HiddenMonitor:
		lea	ObjDat_HiddenMonitor(pc),a1
		jsr	(SetUp_ObjAttributes).w
		move.l	#Obj_HiddenMonitorMain,address(a0)
		move.w	#bytes_to_word(30/2,30/2),y_radius(a0)		; set y_radius and x_radius
		move.b	#6|$40,collision_flags(a0)
		move.b	subtype(a0),anim(a0)			; backup object subtype
		rts
; ---------------------------------------------------------------------------

Obj_HiddenMonitorMain:
		move.w	(Signpost_addr).w,d0
		beq.s	loc_8375A
		movea.w	d0,a1						; get Signpost address
		cmpi.l	#Obj_EndSign,address(a1)
		bne.s	loc_8375A					; if no signpost is active, branch
		btst	#0,objoff_38(a1)
		beq.s	loc_8375A					; if signpost hasn't landed, branch
		lea	word_8379E(pc),a2
		move.w	x_pos(a0),d0
		move.w	x_pos(a1),d1
		add.w	(a2)+,d0
		cmp.w	d0,d1
		blo.s		loc_8374C
		add.w	(a2)+,d0
		cmp.w	d0,d1
		bhs.s	loc_8374C
		move.w	y_pos(a0),d0
		move.w	y_pos(a1),d1
		add.w	(a2)+,d0
		cmp.w	d0,d1
		blo.s		loc_8374C
		add.w	(a2)+,d0
		cmp.w	d0,d1
		blo.s		loc_83760

loc_8374C:
		sfx	sfx_Signpost							; if signpost has landed
		move.l	#Sprite_OnScreen_Test,address(a0)

loc_8375A:
		jmp	(Delete_Sprite_If_Not_In_Range).w
; ---------------------------------------------------------------------------

loc_83760:
		bclr	#0,objoff_38(a1)						; if signpost has landed and is in range
		move.l	#Obj_Monitor,address(a0)			; make this object a monitor
		move.b	#2,routine(a0)
		move.b	#4,objoff_3C(a0)
		move.w	#-$500,y_vel(a0)
		sfx	sfx_BubbleAttack
		bclr	#0,render_flags(a0)
		beq.s	loc_83798
		bset	#7,art_tile(a0)
		clr.b	status(a0)

loc_83798:
		jmp	(Sprite_OnScreen_Test).w
; ---------------------------------------------------------------------------

word_8379E:		dc.w  -$E, $1C, -$80, $C0

ObjDat_HiddenMonitor:
		dc.l Map_Monitor
		dc.w make_art_tile(ArtTile_Monitors,0,0)
		dc.w $280
		dc.b 28/2
		dc.b 32/2
		dc.b 0
		dc.b 0