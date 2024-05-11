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
		movea.l	(Level_data_addr_RAM.Rings).w,a1
		move.l	a1,(Ring_start_addr_ROM).w
		lea	(Ring_status_table).w,a2
		move.w	(Camera_X_pos).w,d4
		subq.w	#8,d4
		bhi.s	+
		moveq	#1,d4
		bra.s	+
-		addq.w	#4,a1
		addq.w	#2,a2
+		cmp.w	(a1),d4
		bhi.s	-
		move.l	a1,(Ring_start_addr_ROM).w
		move.w	a2,(Ring_start_addr_RAM).w
		addi.w	#$150,d4
		bra.s	+
-		addq.w	#4,a1
+		cmp.w	(a1),d4
		bhi.s	-
		move.l	a1,(Ring_end_addr_ROM).w
		rts
; ---------------------------------------------------------------------------

Load_Rings_Main:
		bsr.s	sub_E994
		movea.l	(Ring_start_addr_ROM).w,a1
		movea.w	(Ring_start_addr_RAM).w,a2
		move.w	(Camera_X_pos).w,d4
		subq.w	#8,d4
		bhi.s	+
		moveq	#1,d4
		bra.s	+
-		addq.w	#4,a1
		addq.w	#2,a2
+		cmp.w	(a1),d4
		bhi.s	-
		bra.s	+
-		subq.w	#4,a1
		subq.w	#2,a2
+		cmp.w	-4(a1),d4
		bls.s		-
		move.l	a1,(Ring_start_addr_ROM).w
		move.w	a2,(Ring_start_addr_RAM).w
		movea.l	(Ring_end_addr_ROM).w,a2
		addi.w	#$150,d4
		bra.s	+
-		addq.w	#4,a2
+		cmp.w	(a2),d4
		bhi.s	-
		bra.s	+
-		subq.w	#4,a2
+		cmp.w	-4(a2),d4
		bls.s		-
		move.l	a2,(Ring_end_addr_ROM).w
		rts

; =============== S U B R O U T I N E =======================================

sub_E994:
		lea	(Ring_consumption_table).w,a2
		move.w	(a2)+,d1
		subq.w	#1,d1
		blo.s		.return

.find
		move.w	(a2)+,d0
		beq.s	.find
		movea.w	d0,a1

		; wait
		subq.b	#1,(a1)
		bne.s	.next
		addq.b	#6,(a1)

		; frame
		addq.b	#1,1(a1)
		cmpi.b	#(CMap_Ring_End-CMap_Ring)/2,1(a1)		; 5 frames
		bne.s	.next
		move.w	#-1,(a1)

		clr.w	-2(a2)
		subq.w	#1,(Ring_consumption_table).w

.next
		dbf	d1,.find

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
		btst	#Status_LtngShield,status_secondary(a0)
		beq.s	Test_Ring_Collisions_NoAttraction
		move.w	x_pos(a0),d2
		move.w	y_pos(a0),d3
		subi.w	#$40,d2
		subi.w	#$40,d3
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
		cmpi.b	#id_Duck,anim(a0)						; is player ducking?
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
		blo.s		loc_EAA6
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
		blo.s		loc_EABE
		bra.s	loc_EADA
; ---------------------------------------------------------------------------

loc_EAB8:
		cmp.w	d5,d0
		bhi.s	loc_EADA

loc_EABE:
		btst	#Status_LtngShield,status_secondary(a0)
		bne.s	Test_Ring_Collisions_AttractRing

loc_EAC6:
		move.w	#bytes_to_word(6,(CMap_Ring_Spark-CMap_Ring)/2),(a4)
		jsr	(GiveRing).w
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
		movea.l	a1,a3								; save ROM address
		bsr.w	Create_New_Sprite
		bne.s	.notfree
		move.l	#Obj_Attracted_Ring,address(a1)
		move.w	(a3),x_pos(a1)						; copy xpos
		move.w	2(a3),y_pos(a1)						; copy ypos
		move.w	a4,objoff_30(a1)						; save ring RAM address
		move.w	#-1,(a4)								; set not draw flag
		rts
; ---------------------------------------------------------------------------

.notfree
		movea.l	a3,a1								; return ROM address
		bra.s	loc_EAC6

; =============== S U B R O U T I N E =======================================

Render_Rings:
		movea.l	(Ring_start_addr_ROM).w,a0
		move.l	(Ring_end_addr_ROM).w,d2
		sub.l	a0,d2
		beq.s	locret_EBEC
		movea.w	(Ring_start_addr_RAM).w,a4
		lea	CMap_Ring(pc),a1
		move.w	4(a3),d4								; Camera_Y_pos_copy
		move.w	#$F0,d5
		move.w	(Screen_Y_wrap_value).w,d3

loc_EBA6:
		tst.w	(a4)+
		bmi.s	loc_EBE6
		move.w	2(a0),d1
		sub.w	d4,d1
		addq.w	#8,d1
		and.w	d3,d1
		cmp.w	d5,d1
		bhs.s	loc_EBE6
		move.w	(a0),d0
		sub.w	(a3),d0								; Camera_X_pos_copy
		move.b	-1(a4),d6
		add.w	d6,d6								; 2 bytes
		addi.w	#$70,d1								; add ypos
		move.w	d1,(a6)+								; set ypos
		move.b	#5,(a6)								; set size of the sprite
		addq.w	#2,a6								; skip link parameter
		move.w	(a1,d6.w),(a6)+						; VRAM
		addi.w	#$78,d0								; add xpos
		move.w	d0,(a6)+								; set xpos
		subq.w	#1,d7

loc_EBE6:
		addq.w	#4,a0
		subq.w	#4,d2
		bne.s	loc_EBA6

locret_EBEC:
		rts
; ---------------------------------------------------------------------------
; Custom mappings format. Compare to Map_Ring.

; Differences include...
; No offset table (each sprite assumed to be 2 bytes)
; No 'sprite pieces per frame' value (hardcoded to 1)
; ---------------------------------------------------------------------------

CMap_Ring:

; frame1
	dc.w $0000+make_art_tile(ArtTile_Ring,1,0)

; frame2
CMap_Ring_Spark:
	dc.w $0000+make_art_tile(ArtTile_Ring_Sparks,1,0)

; frame3
	dc.w $1800+make_art_tile(ArtTile_Ring_Sparks,1,0)

; frame4
	dc.w $0800+make_art_tile(ArtTile_Ring_Sparks,1,0)

; frame5
	dc.w $1000+make_art_tile(ArtTile_Ring_Sparks,1,0)

CMap_Ring_End

; =============== S U B R O U T I N E =======================================

AddRings:
		add.w	d0,(Ring_count).w
		ori.b	#1,(Update_HUD_ring_count).w		; update ring counter
		rts

; =============== S U B R O U T I N E =======================================

GiveRing:
CollectRing:
		addq.w	#1,(Ring_count).w						; add 1 to rings
		ori.b	#1,(Update_HUD_ring_count).w		; update the rings counter
		sfx	sfx_RingRight,1							; play ring sound

; =============== S U B R O U T I N E =======================================

Clear_SpriteRingMem:

		; objects
		lea	(Dynamic_object_RAM).w,a1
		moveq	#((Dynamic_object_RAM_end-Dynamic_object_RAM)/object_size)-1,d1

.findos
		lea	next_object(a1),a1							; next object slot
		tst.l	address(a1)
		beq.s	.nextos
		move.w	respawn_addr(a1),d0					; get address in respawn table
		beq.s	.nextos								; if it's zero, it isn't remembered
		movea.w	d0,a2								; load address into a2
		bclr	#7,(a2)

.nextos
		dbf	d1,.findos

		; rings
		lea	(Ring_consumption_table).w,a2
		move.w	(a2)+,d1
		subq.w	#1,d1
		blo.s		.return

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
