; ---------------------------------------------------------------------------
; Start New Level (Object)
; set flipx to horizontal range
; ---------------------------------------------------------------------------

; levels list (subtype)
; $00	= $000 (DEZ1)
; $01	= $001 (DEZ2)
; $02	= $002 (DEZ3)
; $03	= $003 (DEZ4)

; =============== S U B R O U T I N E =======================================

Obj_StartNewLevel:
		move.l	#Map_InvisibleBlock,mappings(a0)
		move.w	#make_art_tile(ArtTile_Monitors,0,1),art_tile(a0)
		ori.b	#4,render_flags(a0)
		move.w	#$200,priority(a0)
		move.l	#.main,address(a0)

		; get xydata
		lea	.vertical(pc),a2								; vertical
		btst	#0,status(a0)									; is it flipx?
		beq.s	.set										; if not, branch
		addq.w	#(.horizontal-.vertical),a2					; horizontal

.set
		move.l	a2,objoff_30(a0)							; save data

.main
		lea	(Player_1).w,a1
		movea.l	objoff_30(a0),a2							; load xydata
		jsr	(Check_InMyRange).w
		beq.s	.chkdel

		; load zone and act
		move.w	subtype(a0),d0
		lsr.w	#2,d0
		rol.b	#2,d0
		jmp	(StartNewLevel).w
; ---------------------------------------------------------------------------

.chkdel
		out_of_xrange.w	.offscreen
		tst.w	(Debug_placement_mode).w
		beq.s	.return
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.return
		rts
; ---------------------------------------------------------------------------

.offscreen
		move.w	respawn_addr(a0),d0
		beq.s	.delete
		movea.w	d0,a2
		bclr	#7,(a2)

.delete
		jmp	(Delete_Current_Sprite).w
; ---------------------------------------------------------------------------

.vertical
		dc.w -16, 32		; xpos
.horizontal
		dc.w -128, 256	; ypos/xpos
		dc.w -16, 32		; ypos
