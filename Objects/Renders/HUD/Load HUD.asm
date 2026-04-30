; ---------------------------------------------------------------------------
; Render HUD
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Render_HUD:
		lea	(HUD_RAM).w,a1
		move.b	HUD_RAM.status-HUD_RAM(a1),d0
		beq.s	.return								; if 0, branch

	if ~~HUDScroll
		subq.b	#1,d0
		bne.s	.process							; if 2, branch
		move.w	#spriteScreenPositionX(16),HUD_RAM.xpos-HUD_RAM(a1)
		move.w	#spriteScreenPositionY(screen_height/2+(block_height+tile_height)),HUD_RAM.ypos-HUD_RAM(a1)
		addq.b	#1,HUD_RAM.status-HUD_RAM(a1)					; set 2
	else
		bmi.s	.left								; if -1, branch
		cmpi.b	#3,d0
		beq.s	.check								; if 3, branch
		subq.b	#1,d0
		bne.s	.right								; if 2, branch

.init
		move.w	#block_width,HUD_RAM.xpos-HUD_RAM(a1)
		move.w	#spriteScreenPositionY(screen_height/2+(block_height+tile_height)),HUD_RAM.ypos-HUD_RAM(a1)
		addq.b	#1,HUD_RAM.status-HUD_RAM(a1)					; set 2

.right
		addq.w	#2,HUD_RAM.xpos-HUD_RAM(a1)
		cmpi.w	#spriteScreenPositionX(16),HUD_RAM.xpos-HUD_RAM(a1)
		bne.s	.check
		addq.b	#1,HUD_RAM.status-HUD_RAM(a1)					; set 3

.check
		tst.b	(Level_results_flag).w
		beq.s	.process
		st	HUD_RAM.status-HUD_RAM(a1)

.left
		subq.w	#2,HUD_RAM.xpos-HUD_RAM(a1)
		cmpi.w	#block_width,HUD_RAM.xpos-HUD_RAM(a1)
		bhs.s	.process
		clr.b	HUD_RAM.status-HUD_RAM(a1)
	endif

.process
		moveq	#0,d4								; frame #0
		btst	#3,(Level_frame_counter.byte).w
		bne.s	.draw
		tst.w	(Ring_count).w							; do you have any rings?
		bne.s	.time								; if yes, branch
		addq.b	#1*2,d4								; hide rings counter

.time
		cmpi.b	#9,(Timer_minute).w						; have 9 minutes elapsed?
		bne.s	.draw								; if not, branch
		addq.b	#2*2,d4								; hide time counter

.draw
		movem.w	HUD_RAM.xpos-HUD_RAM(a1),d0-d1					; xpos and ypos
		move.w	#make_art_tile(ArtTile_HUD,0,TRUE),d5				; VRAM
		lea	Map_HUD(pc),a1
		adda.w	(a1,d4.w),a1
		move.w	(a1)+,d4
		subq.w	#1,d4
		bmi.s	.return
		jmp	(loc_1AF76).w							; draw
; ---------------------------------------------------------------------------

.return
		rts
; ---------------------------------------------------------------------------

		; mappings

	if HUDCentiseconds
		include "Objects/Renders/HUD/Object Data/Map - HUD.asm"
	else
		include "Objects/Renders/HUD/Object Data/Map - HUD (NoCentiseconds).asm"
	endif
