; ---------------------------------------------------------------------------
; Load level rings
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Load_Rings:
		movea.l	(Rings_manager_addr_RAM).w,a0
		jmp	(a0)

; =============== S U B R O U T I N E =======================================

Load_Rings_Init:
		move.l	#Load_Rings_Main,(Rings_manager_addr_RAM).w
		tst.b	(Respawn_table_keep).w
		bne.s	.skip
		clearRAM Ring_status_table, Ring_status_table_end

.skip
		clearRAM Ring_consumption_table, Ring_consumption_table_end
		movea.l	(Level_data_addr_RAM.RingsRAM).w,a1
		move.l	a1,(Ring_start_addr_ROM).w
		lea	(Ring_status_table).w,a2
		move.w	(Camera_X_pos).w,d4
		subq.w	#8,d4
		bhi.s	.check
		moveq	#1,d4										; no negative values allowed
		bra.s	.check
; ---------------------------------------------------------------------------

.next
		addq.w	#4,a1										; load next ring
		addq.w	#2,a2										; load next ring status

.check
		cmp.w	(a1),d4										; is the X pos of the ring < camera X pos?
		bhi.s	.next										; if it is, check next ring
		move.l	a1,(Ring_start_addr_ROM).w							; set start addresses
		move.w	a2,(Ring_start_addr_RAM).w
		addi.w	#320+16,d4									; advance by a screen
		bra.s	.check2
; ---------------------------------------------------------------------------

.next2
		addq.w	#4,a1										; load next ring

.check2
		cmp.w	(a1),d4										; is the X pos of the ring < camera X + 336?
		bhi.s	.next2										; if it is, check next ring
		move.l	a1,(Ring_end_addr_ROM).w							; set end addresses
		rts
; ---------------------------------------------------------------------------

Load_Rings_Main:
		bsr.s	sub_E994

		; update ring start and end addresses
		movea.l	(Ring_start_addr_ROM).w,a1
		movea.w	(Ring_start_addr_RAM).w,a2
		move.w	(Camera_X_pos).w,d4
		subq.w	#8,d4
		bhi.s	.check
		moveq	#1,d4										; no negative values allowed
		bra.s	.check
; ---------------------------------------------------------------------------

.next
		addq.w	#4,a1										; load next ring
		addq.w	#2,a2										; load next ring status

.check
		cmp.w	(a1),d4
		bhi.s	.next
		bra.s	.check2
; ---------------------------------------------------------------------------

.prev
		subq.w	#4,a1										; load previous ring
		subq.w	#2,a2										; load previous ring status

.check2
		cmp.w	-4(a1),d4
		bls.s	.prev
		move.l	a1,(Ring_start_addr_ROM).w
		move.w	a2,(Ring_start_addr_RAM).w

	ifdef __DEBUG__	; RaiseError is only available in DEBUG builds
		jsr	(Load_Rings_RaiseError).l							; raise an error if there is ring status table overflow
	endif

		movea.l	(Ring_end_addr_ROM).w,a2
		addi.w	#320+16,d4									; advance by a screen
		bra.s	.check3
; ---------------------------------------------------------------------------

.next2
		addq.w	#4,a2										; load next ring

.check3
		cmp.w	(a2),d4
		bhi.s	.next2
		bra.s	.check4
; ---------------------------------------------------------------------------

.prev2
		subq.w	#4,a2										; load previous ring

.check4
		cmp.w	-4(a2),d4
		bls.s	.prev2
		move.l	a2,(Ring_end_addr_ROM).w
		rts

; =============== S U B R O U T I N E =======================================

sub_E994:
		lea	(Ring_consumption_table).w,a2
		move.w	(a2)+,d1
		subq.w	#1,d1										; are any rings currently being consumed?
		blo.s	.return										; if not, branch

.find
		move.w	(a2)+,d0									; is there a ring in this slot?
		beq.s	.find										; if not, branch
		movea.w	d0,a1										; load ring address

		; wait
		subq.b	#1,(a1)										; decrement timer
		bne.s	.next										; if it's not 0 yet, branch
		addq.b	#6,(a1)										; reset timer

		; frame
		addq.b	#1,1(a1)									; increment frame
		cmpi.b	#(CMap_Ring_end-CMap_Ring)/2,1(a1)						; is it destruction time yet?
		bne.s	.next										; if not, branch
		move.w	#-1,(a1)									; destroy ring

		clr.w	-2(a2)										; clear ring entry
		subq.w	#1,(Ring_consumption_table).w							; subtract count

.next
		dbf	d1,.find									; repeat for all rings in table

.return
		rts

; =============== S U B R O U T I N E =======================================

Test_Ring_Collisions:
		cmpi.b	#90,invulnerability_timer(a0)
		bhs.s	sub_E994.return
		movea.l	(Ring_start_addr_ROM).w,a1
		movea.l	(Ring_end_addr_ROM).w,a2
		cmpa.l	a1,a2
		beq.s	sub_E994.return
		movea.w	(Ring_start_addr_RAM).w,a4
		btst	#status_secondary.lightning_shield,status_secondary(a0)				; does Sonic have a Lightning Shield?
		beq.s	Test_Ring_Collisions_NoAttraction						; if not, branch
		moveq	#-64,d2
		add.w	x_pos(a0),d2
		moveq	#-64,d3
		add.w	y_pos(a0),d3
		moveq	#6,d1
		moveq	#$C,d6
		move.w	#$80,d4
		move.w	#$80,d5
		bra.s	Test_Ring_Collisions_NextRing
; ---------------------------------------------------------------------------

Test_Ring_Collisions_NoAttraction:
		move.w	x_pos(a0),d2
		move.w	y_pos(a0),d3
		subq.w	#8,d2
		moveq	#0,d5
		move.b	y_radius(a0),d5
		subq.b	#3,d5
		sub.w	d5,d3
		cmpi.b	#AniIDSonAni_Duck,anim(a0)							; is player ducking?
		bne.s	.notduck									; if not, branch
		addi.w	#$C,d3
		moveq	#$A,d5

.notduck
		moveq	#6,d1
		moveq	#$C,d6
		moveq	#$10,d4
		add.w	d5,d5

Test_Ring_Collisions_NextRing:
		tst.w	(a4)
		bne.s	loc_EADA
		move.w	(a1),d0
		sub.w	d1,d0
		sub.w	d2,d0
		bhs.s	loc_EAA0
		add.w	d6,d0
		blo.s	loc_EAA6
		bra.s	loc_EADA
; ---------------------------------------------------------------------------

loc_EAA0:
		cmp.w	d4,d0
		bhi.s	loc_EADA

loc_EAA6:
		move.w	2(a1),d0
		sub.w	d1,d0
		sub.w	d3,d0
		bhs.s	loc_EAB8
		add.w	d6,d0
		blo.s	loc_EABE
		bra.s	loc_EADA
; ---------------------------------------------------------------------------

loc_EAB8:
		cmp.w	d5,d0
		bhi.s	loc_EADA

loc_EABE:
		btst	#status_secondary.lightning_shield,status_secondary(a0)				; does Sonic have a Lightning Shield?
		bne.s	Test_Ring_Collisions_AttractRing						; if yes, branch

loc_EAC6:
		move.w	#bytes_to_word(6,(CMap_Ring_Spark-CMap_Ring)/2),(a4)
		bsr.s	GiveRing
		lea	(Ring_consumption_list).w,a3

.find
		tst.w	(a3)+
		bne.s	.find
		move.w	a4,-(a3)
		addq.w	#1,(Ring_consumption_table).w

loc_EADA:
		addq.w	#4,a1
		addq.w	#2,a4
		cmpa.l	a1,a2
		bne.s	Test_Ring_Collisions_NextRing
		rts

; =============== S U B R O U T I N E =======================================

Test_Ring_Collisions_AttractRing:
		lea	(a1),a3										; save ROM address
		bsr.w	Create_New_Sprite
		bne.s	.notfree
		move.l	#Obj_Attracted_Ring,address(a1)
		move.w	(a3),x_pos(a1)									; copy xpos
		move.w	2(a3),y_pos(a1)									; copy ypos
		move.w	a4,objoff_30(a1)								; save ring RAM address
		move.w	#-1,(a4)									; set not draw flag
		rts
; ---------------------------------------------------------------------------

.notfree
		lea	(a3),a1										; return ROM address
		bra.s	loc_EAC6

; ---------------------------------------------------------------------------
; Give ring to player
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

GiveRing:
		addq.w	#1,(Ring_count).w								; add 1 to rings
		ori.b	#1,(Update_HUD_ring_count).w							; update the rings counter
		sfx	sfx_RingRight,1									; play ring sound

; ---------------------------------------------------------------------------
; Add ring to player
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

AddRings:
		add.w	d0,(Ring_count).w								; add to rings
		ori.b	#1,(Update_HUD_ring_count).w							; update the rings counter
		sfx	sfx_RingRight,1									; play ring sound

; ---------------------------------------------------------------------------
; Render rings
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Render_Rings:
		movea.l	(Ring_start_addr_ROM).w,a0
		move.l	(Ring_end_addr_ROM).w,d2
		sub.l	a0,d2										; are there any rings on-screen?
		beq.s	.return										; if not, branch
		movea.w	(Ring_start_addr_RAM).w,a4
		move.w	4(a3),d4									; Camera_Y_pos_copy
		move.w	#256-16,d5
		move.w	(Screen_Y_wrap_value).w,d3

.loop
		tst.w	(a4)+										; has this ring been consumed?
		bmi.s	.next										; if it has, branch
		move.w	2(a0),d1									; get ring ypos
		sub.w	d4,d1										; subtract camera ypos
		addq.w	#8,d1
		and.w	d3,d1
		cmp.w	d5,d1
		bhs.s	.next
		move.w	(a0),d0										; get ring xpos
		sub.w	(a3),d0										; subtract camera xpos
		move.b	-1(a4),d6
		add.w	d6,d6										; multiply by 2
		addi.w	#128-16,d1									; add ypos
		move.w	d1,(a6)+									; set ypos
		move.b	#5,(a6)										; set size of the sprite
		addq.w	#2,a6										; skip link parameter
		move.w	CMap_Ring(pc,d6.w),(a6)+							; VRAM
		addi.w	#128-8,d0									; add xpos
		move.w	d0,(a6)+									; set xpos
		subq.w	#1,d7										; subtract sprite count

.next
		addq.w	#4,a0										; next
		subq.w	#4,d2
		bne.s	.loop

.return
		rts

; ---------------------------------------------------------------------------
; Custom mappings format. Compare to Map_Ring.

; Differences include...
; No offset table (each sprite assumed to be 2 bytes)
; No 'sprite pieces per frame' value (hardcoded to 1)
; ---------------------------------------------------------------------------

CMap_Ring:

		; frame1
		dc.w make_art_tile(ArtTile_Ring,1,0)

CMap_Ring_Spark:

		; frame2
		dc.w make_art_tile(ArtTile_Ring_Sparks,1,0)

		; frame3
		dc.w flip_x+flip_y+make_art_tile(ArtTile_Ring_Sparks,1,0)

		; frame4
		dc.w flip_x+make_art_tile(ArtTile_Ring_Sparks,1,0)

		; frame5
		dc.w flip_y+make_art_tile(ArtTile_Ring_Sparks,1,0)

CMap_Ring_end

; =============== S U B R O U T I N E =======================================

Clear_SpriteRingMem:

		; objects
		lea	(Dynamic_object_RAM-next_object).w,a1						; start address for object RAM
		moveq	#bytesToXcnt(Dynamic_object_RAM_end-Dynamic_object_RAM,object_size),d1

.findos
		lea	next_object(a1),a1								; next object slot
		tst.l	address(a1)									; is object RAM slot empty?
		beq.s	.nextos										; if yes, branch
		move.w	respawn_addr(a1),d0								; get address in respawn table
		beq.s	.nextos										; if it's zero, it isn't remembered
		movea.w	d0,a2										; load address into a2
		bclr	#7,(a2)

.nextos
		dbf	d1,.findos

		; rings
		lea	(Ring_consumption_table).w,a2
		move.w	(a2)+,d1
		subq.w	#1,d1
		blo.s	.return

.find
		move.w	(a2)+,d0
		beq.s	.find
		movea.w	d0,a1
		move.w	#-1,(a1)
		clr.w	-2(a2)
		subq.w	#1,(Ring_consumption_table).w
		dbf	d1,.find

.return
		rts
