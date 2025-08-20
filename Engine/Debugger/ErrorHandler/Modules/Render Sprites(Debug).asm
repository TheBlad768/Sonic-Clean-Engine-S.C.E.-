; ---------------------------------------------------------------
; Debug
; ---------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Render_Sprites_Assert:

		; debug
		assert.l	address(a0),ne						; raise an error if there is no object address here
		assert.l	mappings(a0),ne						; raise an error if there is no mappings address here
		rts