
; =============== S U B R O U T I N E =======================================

Render_HUD:
		lea	(HUD_RAM).w,a1
		move.b	HUD_RAM.status-HUD_RAM(a1),d0
		beq.s	Render_HUD_Return
		bmi.s	Render_HUD_Left
		cmpi.b	#3,d0
		beq.s	Render_HUD_Check
		subq.b	#1,d0
		bne.s	Render_HUD_Right					; If 2, branch

Render_HUD_Init:
		move.w	#$10,HUD_RAM.Xpos-HUD_RAM(a1)
		move.w	#$108,HUD_RAM.Ypos-HUD_RAM(a1)
		addq.b	#1,HUD_RAM.status-HUD_RAM(a1)		; Set 2

Render_HUD_Right:
		addq.w	#2,HUD_RAM.Xpos-HUD_RAM(a1)
		cmpi.w	#$90,HUD_RAM.Xpos-HUD_RAM(a1)
		bne.s	Render_HUD_Check
		addq.b	#1,HUD_RAM.status-HUD_RAM(a1)		; Set 3

Render_HUD_Check:
		tst.b	(Level_end_flag).w
		beq.s	Render_HUD_Process
		st	HUD_RAM.status-HUD_RAM(a1)

Render_HUD_Left:
		subq.w	#2,HUD_RAM.Xpos-HUD_RAM(a1)
		cmpi.w	#$10,HUD_RAM.Xpos-HUD_RAM(a1)
		bhs.s	Render_HUD_Process
		clr.b	HUD_RAM.status-HUD_RAM(a1)

Render_HUD_Process:
		moveq	#0,d4								; Frame #0
		btst	#3,(Level_frame_counter+1).w
		bne.s	Render_HUD_Draw
		tst.w	(Ring_count).w						; Do you have any rings?
		bne.s	Render_HUD_Process_Time			; If yes, branch
		addq.w	#1*2,d4								; Hide rings counter

Render_HUD_Process_Time:
		cmpi.b	#9,(Timer_minute).w					; Have 9 minutes elapsed?
		bne.s	Render_HUD_Draw					; If not, branch
		addq.w	#2*2,d4								; Hide time counter

Render_HUD_Draw:
		move.w	HUD_RAM.Xpos-HUD_RAM(a1),d0		; Xpos
		move.w	HUD_RAM.Ypos-HUD_RAM(a1),d1		; Ypos
		move.w	#make_art_tile(ArtTile_HUD,0,1),d5		; VRAM
		lea	Map_HUD(pc),a1
		adda.w	(a1,d4.w),a1
		move.w	(a1)+,d4
		subq.w	#1,d4
		bmi.s	Render_HUD_Return
		bra.w	sub_1AF6C							; Draw
; ---------------------------------------------------------------------------

Render_HUD_Return:
		rts
; End of function Render_HUD
; ---------------------------------------------------------------------------

		include	"Objects/HUD/Object Data/Map - HUD.asm"