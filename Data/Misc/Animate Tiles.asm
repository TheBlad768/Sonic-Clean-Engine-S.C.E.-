; ---------------------------------------------------------------------------
; Subroutine to animate level graphics
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Animate_Tiles:
		lea	(Level_data_addr_RAM.AnimateTiles).w,a0
		movea.l	(a0)+,a1
		movea.l	(a0)+,a2
		jmp	(a1)

; =============== S U B R O U T I N E =======================================

AnimateTiles_NULL:
		rts

; =============== S U B R O U T I N E =======================================

AnimateTiles_DoAniPLC:
		lea	(Anim_Counters).w,a3
		move.w	(a2)+,d6			; Get number of scripts in list
		bpl.s	.listnotempty		; If there are any, continue
		rts
; ---------------------------------------------------------------------------
.listnotempty:
AnimateTiles_DoAniPLC_Part2:
.loop:
		subq.b	#1,(a3)			; Tick down frame duration
		bcc.s	.nextscript		; If frame isn't over, move on to next script

;.nextframe:
		moveq	#0,d0
		move.b	1(a3),d0			; Get current frame
		cmp.b	6(a2),d0			; Have we processed the last frame in the script?
		blo.s		.notlastframe
		moveq	#0,d0			; If so, reset to first frame
		move.b	d0,1(a3)

.notlastframe:
		addq.b	#1,1(a3)			; Consider this frame processed; set counter to next frame
		move.b	(a2),(a3)			; Set frame duration to global duration value
		bpl.s	.globalduration
		; If script uses per-frame durations, use those instead
		add.w	d0,d0
		move.b	9(a2,d0.w),(a3)	; Set frame duration to current frame's duration value

.globalduration:
; Prepare for DMA transfer
		; Get relative address of frame's art
		move.b	8(a2,d0.w),d0	; Get tile ID
		lsl.w	#4,d0				; Turn it into an offset
		; Get VRAM destination address
		move.w	4(a2),d2
		; Get ROM source address
		move.l	(a2),d1			; Get start address of animated tile art
		andi.l	#$FFFFFF,d1
		add.l	d0,d1			; Offset into art, to get the address of new frame
		; Get size of art to be transferred
		moveq	#0,d3
		move.b	7(a2),d3
		lsl.w	#4,d3				; Turn it into actual size (in words)
		; Use d1, d2 and d3 to queue art for transfer
		jsr	(Add_To_DMA_Queue).w

.nextscript:
		move.b	6(a2),d0			; Get total size of frame data
		tst.b	(a2)					; Is per-frame duration data present?
		bpl.s	.globalduration2	; If not, keep the current size; it's correct
		add.b	d0,d0			; Double size to account for the additional frame duration data

.globalduration2:
		addq.b	#1,d0
		andi.w	#$FE,d0			; Round to next even address, if it isn't already
		lea	8(a2,d0.w),a2			; Advance to next script in list
		addq.w	#2,a3			; Advance to next script's slot in a3 (usually Anim_Counters)
		dbf	d6,.loop
		rts
; End of function AnimateTiles_DoAniPLC
; ===========================================================================
; ZONE ANIMATION SCRIPTS
;
; The AnimateTiles_DoAniPLC subroutine uses these scripts to reload certain tiles,
; thus animating them. All the relevant art must be uncompressed, because
; otherwise the subroutine would spend so much time waiting for the art to be
; decompressed that the VBLANK window would close before all the animating was done.

;    zoneanimdecl -1, ArtUnc_Flowers1, ArtTile_ArtUnc_Flowers1, 6, 2
;	-1						Global frame duration. If -1, then each frame will use its own duration, instead

;	ArtUnc_Flowers1			Source address
;	ArtTile_ArtUnc_Flowers1	Destination VRAM address
;	6						Number of frames
;	2						Number of tiles to load into VRAM for each frame

;    dc.b   0,$7F				Start of the script proper
;	0						Tile ID of first tile in ArtUnc_Flowers1 to transfer
;	$7F						Frame duration. Only here if global duration is -1
; ---------------------------------------------------------------------------

AniPLC_NULL:	zoneanimstart

	zoneanimend
