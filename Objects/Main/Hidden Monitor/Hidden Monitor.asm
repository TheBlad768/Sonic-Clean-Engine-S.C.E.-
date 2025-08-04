; ---------------------------------------------------------------------------
; Hidden Monitor (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_HiddenMonitor:

		; init
		lea	ObjDat_HiddenMonitor(pc),a1
		jsr	(SetUp_ObjAttributes).w
		move.l	#.main,address(a0)
		move.w	#bytes_to_word(30/2,30/2),y_radius(a0)				; set y_radius and x_radius
		move.b	#6|collision_flags.npc.item,collision_flags(a0)
		move.b	subtype(a0),anim(a0)						; set monitor content id
		rts
; ---------------------------------------------------------------------------

.main
		move.w	(Signpost_addr).w,d0						; address is empty?
		beq.s	.notdraw							; if it is, branch
		movea.w	d0,a1								; get signpost address
		btst	#0,objoff_38(a1)
		beq.s	.notdraw							; if signpost hasn't landed, branch

		; check xypos
		lea	HiddenMonitor_Range(pc),a2
		jsr	(Check_InTheirRange).w
		bne.s	.bounceup

		; landed
		sfx	sfx_Signpost							; if signpost has landed
		move.l	#Delete_Sprite_If_Not_In_Range,address(a0)			; not draw hidden monitor

.notdraw
		jmp	(Delete_Sprite_If_Not_In_Range).w
; ---------------------------------------------------------------------------

.bounceup
		bclr	#0,objoff_38(a1)						; if signpost has landed and is in range
		move.l	#Obj_Monitor.main,address(a0)					; make this object a monitor
		move.b	#4,objoff_3C(a0)
		move.w	#-$500,y_vel(a0)
		sfx	sfx_BubbleAttack						; play sfx
		bclr	#render_flags.x_flip,render_flags(a0)
		beq.s	.draw
		bset	#high_priority_bit,art_tile(a0)					; high priority
		clr.b	status(a0)

.draw
		jmp	(Sprite_OnScreen_Test).w

; =============== S U B R O U T I N E =======================================

; mapping
ObjDat_HiddenMonitor:	subObjData Map_Monitor, ArtTile_Monitors, 0, 0, 32, 28, 5, 0, 0

HiddenMonitor_Range:
		dc.w -14, 28	; xpos
		dc.w -128, 192	; ypos
