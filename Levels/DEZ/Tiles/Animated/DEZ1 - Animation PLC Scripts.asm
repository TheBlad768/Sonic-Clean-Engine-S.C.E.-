; ===========================================================================
; ZONE ANIMATION SCRIPTS
;
; The AnimateTiles_DoAniPLC subroutine uses these scripts to reload certain tiles,
; thus animating them. All the relevant art must be uncompressed, because
; otherwise the subroutine would spend so much time waiting for the art to be
; decompressed that the VBLANK window would close before all the animating was done.
;
; zoneanimplcdecl -1, ArtUnc_Flowers1, ArtTile_ArtUnc_Flowers1, 6, 2
; -1						Global frame duration. If -1, then each frame will use its own duration, instead
;
; ArtUnc_Flowers1				Source address
; ArtTile_ArtUnc_Flowers1			Destination VRAM address
; 6						Number of frames
; 2						Number of tiles to load into VRAM for each frame
;
; dc.b 0,$7F					Start of the script proper
; 0						Tile ID of first tile in ArtUnc_Flowers1 to transfer
; $7F						Frame duration. Only here if global duration is -1
; ===========================================================================

AniPLC_DEZ: zoneanimstart

	zoneanimplcdecl -1, ArtUnc_AniDEZ__3, $50, 4, 6
	dc.b 0, 9
	dc.b 6, 4
	dc.b $C, 9
	dc.b 6, 4
	even

	zoneanimplcdecl 4, ArtUnc_AniDEZ__4, $3F, 4, 2
	dc.b 0
	dc.b 2
	dc.b 4
	dc.b 2
	even

	zoneanimplcdecl 4, ArtUnc_AniDEZ__5, $5C, 6, 3
	dc.b 0
	dc.b 3
	dc.b 6
	dc.b 0
	dc.b 3
	dc.b 6
	even

	zoneanimplcdecl 1, ArtUnc_AniDEZ__6, $1C, 2, 8
	dc.b 0
	dc.b 8
	even

	zoneanimend
