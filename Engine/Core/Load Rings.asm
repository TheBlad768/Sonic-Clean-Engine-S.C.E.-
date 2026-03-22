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
		moveq	#1,d4								; no zero or negative values allowed
		bra.s	.check
; ---------------------------------------------------------------------------

.next
		addq.w	#4,a1								; load next ring xy pos
		addq.w	#1,a2								; load next ring status

.check
		cmp.w	(a1),d4								; is the X pos of the ring < camera X pos?
		bhi.s	.next								; if it is, check next ring
		move.l	a1,(Ring_start_addr_ROM).w					; set start addresses
		move.w	a2,(Ring_start_addr_RAM).w

		; RaiseError is only available in DEBUG builds
		ifdebug	jsr	(Load_Rings_RaiseError).l				; raise an error if there is ring status table overflow

		addi.w	#screen_width+block_width,d4					; advance by a screen
		bra.s	.check2
; ---------------------------------------------------------------------------

.next2
		addq.w	#4,a1								; load next ring xy pos

.check2
		cmp.w	(a1),d4								; is the X pos of the ring < camera X + 336?
		bhi.s	.next2								; if it is, check next ring
		move.l	a1,(Ring_end_addr_ROM).w					; set end addresses
		rts
; ---------------------------------------------------------------------------

Load_Rings_Main:
		bsr.s	Consumption_Rings

		; update ring start and end addresses
		movea.l	(Ring_start_addr_ROM).w,a1
		movea.w	(Ring_start_addr_RAM).w,a2
		move.w	(Camera_X_pos).w,d4
		subq.w	#8,d4
		bhi.s	.check
		moveq	#1,d4								; no zero or negative values allowed
		bra.s	.check
; ---------------------------------------------------------------------------

.next
		addq.w	#4,a1								; load next ring xy pos
		addq.w	#1,a2								; load next ring status

.check
		cmp.w	(a1),d4
		bhi.s	.next
		bra.s	.check2
; ---------------------------------------------------------------------------

.prev
		subq.w	#4,a1								; load previous ring xy pos
		subq.w	#1,a2								; load previous ring status

.check2
		cmp.w	-4(a1),d4
		bls.s	.prev
		move.l	a1,(Ring_start_addr_ROM).w
		move.w	a2,(Ring_start_addr_RAM).w

		; RaiseError is only available in DEBUG builds
		ifdebug	jsr	(Load_Rings_RaiseError).l				; raise an error if there is ring status table overflow

		movea.l	(Ring_end_addr_ROM).w,a2
		addi.w	#screen_width+block_width,d4					; advance by a screen
		bra.s	.check3
; ---------------------------------------------------------------------------

.next2
		addq.w	#4,a2								; load next ring xy pos

.check3
		cmp.w	(a2),d4
		bhi.s	.next2
		bra.s	.check4
; ---------------------------------------------------------------------------

.prev2
		subq.w	#4,a2								; load previous ring xy pos

.check4
		cmp.w	-4(a2),d4
		bls.s	.prev2
		move.l	a2,(Ring_end_addr_ROM).w
		rts

; ---------------------------------------------------------------------------
; Subroutine to consumption ring
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Consumption_Rings:
		lea	(Ring_consumption_table).w,a2
		move.w	(a2)+,d1
		subq.w	#1,d1								; are any rings currently being consumed?
		blo.s	.return								; if not, branch

.find
		move.w	(a2)+,d0							; is there a ring in this slot?
		beq.s	.find								; if not, branch
		movea.w	d0,a1								; load ring address

		; wait
		subi.b	#nibbles_to_byte(1,0),(a1)					; decrement timer
		bhs.s	.next								; if time remains, branch
		addi.b	#nibbles_to_byte(6,0),(a1)					; reset timer to 6 frames

		; frame
		addq.b	#nibbles_to_byte(0,1),(a1)					; increment frame
		moveq	#nibbles_to_byte(0,$F),d0					; maximum 15 frames
		and.b	(a1),d0
		cmpi.b	#nibbles_to_byte(0,(CMap_Ring_end-CMap_Ring)/2),d0		; is it destruction time yet?
		bne.s	.next								; if not, branch

		; clear slot
		st	(a1)								; destroy ring
		clr.w	-2(a2)								; clear ring entry
		subq.w	#1,(Ring_consumption_table).w					; subtract count

.next
		dbf	d1,.find							; repeat for all rings in table

.return
		rts

; ---------------------------------------------------------------------------
; Subroutine to react to ring collision
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

RingTouchResponse:

		; check the character's invulnerability_timer
		cmpi.b	#(1*60)+30,invulnerability_timer(a0)				; is there more than 90 frames on the timer remaining?
		bhs.s	Consumption_Rings.return					; if so, branch

		; set
		movem.l	(Ring_start_addr_ROM).w,a2-a3					; get Ring_start_addr_ROM and Ring_end_addr_ROM

		; check
		cmpa.l	a2,a3								; is that the end of the list of rings?
		beq.s	Consumption_Rings.return					; if yes, branch
		movea.w	(Ring_start_addr_RAM).w,a4

		; check Lightning Shield
		btst	#status_secondary.lightning_shield,status_secondary(a0)		; does Sonic have a Lightning Shield?
		beq.s	.noattraction							; if not, branch

		; lightning shield
		moveq	#-(128/2),d2
		add.w	x_pos(a0),d2
		moveq	#-(128/2),d3
		add.w	y_pos(a0),d3
		moveq	#12/2,d1							; set ring's height and width
		moveq	#24/2,d6							; set ring's height and width * 2
		move.w	#256/2,d4							; player's width
		move.w	#256/2,d5							; player's height
		bra.s	.nextring
; ---------------------------------------------------------------------------

.noattraction

		; normal
		move.w	x_pos(a0),d2							; get player's x_pos
		move.w	y_pos(a0),d3							; get player's y_pos
		subq.w	#16/2,d2
		moveq	#0,d5
		move.b	y_radius(a0),d5							; load player's height
		subq.b	#6/2,d5
		sub.w	d5,d3

		; check ducking
		cmpi.b	#AniIDSonAni_Duck,anim(a0)					; is player ducking?
		bne.s	.notduck							; if not, branch
		addi.w	#24/2,d3							; fix player's y_pos
		moveq	#20/2,d5							; set player's height

.notduck
		moveq	#12/2,d1							; set ring's height and width
		moveq	#24/2,d6							; set ring's height and width * 2
		moveq	#32/2,d4							; player's collision width
		add.w	d5,d5								; double player's height value

.nextring
		tst.b	(a4)								; has this ring been consumed?
		bne.s	.next								; if it has, branch

		; RaiseError is only available in DEBUG builds
		ifdebug	jsr	(RingTouchResponse_RaiseError).l			; raise an error if there is ring is corrupted

		; check
		move.w	(a2),d0								; get ring's x_pos
		sub.w	d1,d0								; subtract ring's width
		sub.w	d2,d0								; subtract player's left collision boundary
		bhs.s	.checkrightside							; if player's left side is to the left of the ring, branch
		add.w	d6,d0								; add ring's width*2 (now at right of ring)
		blo.s	.checkheight							; if carry, branch (player is within the right's boundaries)
		bra.s	.next								; if not, loop and check next right
; ---------------------------------------------------------------------------

.checkrightside
		cmp.w	d4,d0								; is player's right side to the left of the ring?
		bhi.s	.next								; if so, loop and check next ring

.checkheight
		move.w	2(a2),d0							; get ring's y_pos
		sub.w	d1,d0								; subtract ring's height
		sub.w	d3,d0								; subtract player's bottom collision boundary
		bhs.s	.checktop							; if bottom of player is under the ring, branch
		add.w	d6,d0								; add ring's height*2 (now at top of ring)
		blo.s	.check								; if carry, branch (player is within the ring's boundaries)
		bra.s	.next								; if not, loop and check next ring
; ---------------------------------------------------------------------------

.checktop
		cmp.w	d5,d0								; is top of player under the ring?
		bhi.s	.next								; if so, loop and check next ring

.check

		; check Lightning Shield
		btst	#status_secondary.lightning_shield,status_secondary(a0)		; does Sonic have a Lightning Shield?
		bne.s	.attractring							; if yes, branch

.consume
		move.b	#nibbles_to_byte(5,(CMap_Ring_Spark-CMap_Ring)/2),(a4)		; set timer to 6 frames and set mapping frame
		bsr.s	GiveRing
		lea	(Ring_consumption_list).w,a1

.find

		; RaiseError is only available in DEBUG builds
		ifdebug	jsr	(RingTouchResponse_Consume_RaiseError).l		; raise an error if there is ring consumption list overflow

		tst.w	(a1)+
		bne.s	.find
		move.w	a4,-(a1)
		addq.w	#1,(Ring_consumption_table).w

.next
		addq.w	#4,a2								; load next ring xy pos
		addq.w	#1,a4								; load next ring status
		cmpa.l	a2,a3								; is that the end of the list of rings?
		bne.s	.nextring							; if not, branch
		rts
; ---------------------------------------------------------------------------

.attractring
		bsr.w	Create_New_Object
		bne.s	.consume
		move.l	#Obj_Attracted_Ring,address(a1)
		move.w	(a2),x_pos(a1)							; copy xpos
		move.w	2(a2),y_pos(a1)							; copy ypos
		move.w	a4,parent(a1)							; save ring status RAM address
		st	(a4)								; destroy ring
		rts

; ---------------------------------------------------------------------------
; Give ring to player
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

GiveRing:
		moveq	#1,d0								; add 1 ring

; ---------------------------------------------------------------------------
; Add ring to player
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

AddRings:

		; RingTouchResponse uses registers d1-d6
		; Don't overwrite these registers!

		; check max rings
		cmpi.w	#999,(Ring_count).w						; does the player 1 have 999 or less rings?
		bhs.s	.sfx								; if yes, branch

		; set
		add.w	d0,(Ring_count).w						; add to rings
		ori.b	#1,(Update_HUD_ring_count).w					; update the rings counter

.sfx
		sfx	sfx_RingRight,1							; play ring sound

; ---------------------------------------------------------------------------
; Render rings
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Render_Rings:
		movea.l	(Ring_start_addr_ROM).w,a0
		move.l	(Ring_end_addr_ROM).w,d2

		; check rings
		sub.l	a0,d2								; are there any rings on-screen?
		beq.s	.return								; if not, branch

		; load
		move.w	(a3),d0								; Camera_X_pos_copy
		move.w	4(a3),d4							; Camera_Y_pos_copy
		movea.w	(Ring_start_addr_RAM).w,a4
		move.w	#gameplay_plane_height-block_height,d5
		move.w	(Screen_Y_wrap_value).w,d3

.nextring
		cmpi.b	#-1,(a4)+							; has this ring been consumed?
		beq.s	.next								; if it has, branch
		move.w	2(a0),d1							; get ring ypos
		sub.w	d4,d1								; subtract camera ypos
		addq.w	#8,d1
		and.w	d3,d1
		cmp.w	d5,d1
		bhs.s	.next

		; set mapping
		addi.w	#128-16,d1							; add ypos
		move.w	d1,(a6)+							; set ypos
		move.w	(a0),d1								; get ring xpos
		sub.w	d0,d1								; subtract camera xpos
		move.b	#5,(a6)								; set size of the sprite tile
		addq.w	#2,a6								; skip link parameter
		subq.w	#1,d7								; subtract sprite count
		moveq	#nibbles_to_byte(0,$F),d6					; maximum 15 frames
		and.b	-1(a4),d6
		add.w	d6,d6								; multiply by 2
		move.w	CMap_Ring(pc,d6.w),(a6)+					; VRAM
		addi.w	#128-8,d1							; add xpos
		move.w	d1,(a6)+							; set xpos

.next
		addq.w	#4,a0								; load next ring xy pos
		subq.w	#4,d2								; is that the end of the list of rings?
		bne.s	.nextring							; if not, branch

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
		dc.w make_art_tile(ArtTile_Ring,1,FALSE)

CMap_Ring_Spark:

		; frame2
		dc.w make_art_tile(ArtTile_Ring_Sparks,1,FALSE)

		; frame3
		dc.w flip_x+flip_y+make_art_tile(ArtTile_Ring_Sparks,1,FALSE)

		; frame4
		dc.w flip_x+make_art_tile(ArtTile_Ring_Sparks,1,FALSE)

		; frame5
		dc.w flip_y+make_art_tile(ArtTile_Ring_Sparks,1,FALSE)

CMap_Ring_end

; =============== S U B R O U T I N E =======================================

Clear_SpriteRingMem:

		; objects
		lea	(Dynamic_object_RAM-next_object).w,a1				; start address for object RAM
		moveq	#bytesToXcnt(Dynamic_object_RAM_end-Dynamic_object_RAM,object_size),d1

.findos
		lea	next_object(a1),a1						; next object slot
		tst.l	address(a1)							; is object RAM slot empty?
		beq.s	.nextos								; if yes, branch
		move.w	respawn_addr(a1),d0						; get address in respawn table
		beq.s	.nextos								; if it's zero, it isn't remembered
		movea.w	d0,a2								; load address into a2
		bclr	#respawn_addr.state,(a2)					; turn on the slot

.nextos
		dbf	d1,.findos

		; rings
		lea	(Ring_consumption_table).w,a2
		move.w	(a2)+,d1
		subq.w	#1,d1								; are any rings currently being consumed?
		blo.s	.return								; if not, branch

.find
		move.w	(a2)+,d0							; is there a ring in this slot?
		beq.s	.find								; if not, branch
		movea.w	d0,a1								; load ring status RAM address

		; clear slot
		st	(a1)								; destroy ring
		clr.w	-2(a2)								; clear ring entry
		subq.w	#1,(Ring_consumption_table).w					; subtract count

		; next
		dbf	d1,.find							; repeat for all rings in table

.return
		rts
