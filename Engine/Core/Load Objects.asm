; ---------------------------------------------------------------------------
; Load level objects
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Load_Objects:
		movea.l	(Object_load_addr_RAM).w,a0
		jmp	(a0)

; =============== S U B R O U T I N E =======================================

Load_Objects_Init:
		movea.l	(Level_data_addr_RAM.ObjectsRAM).w,a0
		move.l	a0,(Object_load_addr_front).w
		move.l	a0,(Object_load_addr_back).w

Load_Objects_Init2:
		move.l	#Load_Objects_Main,(Object_load_addr_RAM).w
		move.l	#Obj_Index,(Object_index_addr).w
		tst.b	(Respawn_table_keep).w
		bne.s	.skip
		clearRAM Object_respawn_table, Object_respawn_table_end

.skip
		lea	(Object_respawn_table).w,a3
		move.w	(Camera_X_pos).w,d6
		subi.w	#$80,d6
		bhs.s	loc_1B79A
		moveq	#0,d6

loc_1B79A:
		andi.w	#$FF80,d6
		movea.l	(Object_load_addr_front).w,a0

loc_1B7A2:
		cmp.w	(a0),d6
		bls.s	loc_1B7AC
		addq.w	#6,a0
		addq.w	#1,a3
		bra.s	loc_1B7A2
; ---------------------------------------------------------------------------

loc_1B7AC:
		move.l	a0,(Object_load_addr_front).w
		move.w	a3,(Object_respawn_index_front).w
		lea	(Object_respawn_table).w,a3
		movea.l	(Object_load_addr_back).w,a0
		subi.w	#$80,d6
		blo.s	loc_1B7D8

loc_1B7CE:
		cmp.w	(a0),d6
		bls.s	loc_1B7D8
		addq.w	#6,a0
		addq.w	#1,a3
		bra.s	loc_1B7CE
; ---------------------------------------------------------------------------

loc_1B7D8:
		move.l	a0,(Object_load_addr_back).w
		move.w	a3,(Object_respawn_index_back).w
		move.w	#-1,(Camera_X_pos_coarse).w
		moveq	#-$80,d0
		and.w	(Camera_Y_pos).w,d0
		move.w	d0,(Camera_Y_pos_coarse).w

Load_Objects_Main:
		moveq	#-$80,d0
		move.w	(Camera_Y_pos).w,d1
		add.w	d0,d1										; subtract $80
		and.w	d0,d1
		move.w	d1,(Camera_Y_pos_coarse_back).w
		move.w	(Camera_X_pos).w,d1
		add.w	d0,d1										; subtract $80
		and.w	d0,d1
		move.w	d1,(Camera_X_pos_coarse_back).w
		movea.l	(Object_index_addr).w,a4
		tst.w	(Camera_min_Y_pos).w
		bpl.s	loc_1B84A
		lea	loc_1BA40(pc),a6
		moveq	#-$80,d3
		and.w	(Camera_Y_pos).w,d3
		move.w	d3,d4
		addi.w	#$200,d4
		subi.w	#$80,d3
		bpl.s	loc_1B83A
		and.w	(Screen_Y_wrap_value).w,d3
		bra.s	loc_1B864
; ---------------------------------------------------------------------------

loc_1B83A:
		move.w	(Screen_Y_wrap_value).w,d0
		addq.w	#1,d0
		cmp.w	d0,d4
		bls.s	loc_1B860
		and.w	(Screen_Y_wrap_value).w,d4
		bra.s	loc_1B864
; ---------------------------------------------------------------------------

loc_1B84A:
		moveq	#-$80,d3
		and.w	(Camera_Y_pos).w,d3
		move.w	d3,d4
		addi.w	#$200,d4
		subi.w	#$80,d3
		bpl.s	loc_1B860
		moveq	#0,d3

loc_1B860:
		lea	loc_1BA92(pc),a6

loc_1B864:
		move.w	#$FFF,d5
		moveq	#-$80,d6
		and.w	(Camera_X_pos).w,d6
		cmp.w	(Camera_X_pos_coarse).w,d6
		beq.w	loc_1B91A
		bge.s	loc_1B8D2
		move.w	d6,(Camera_X_pos_coarse).w
		movea.l	(Object_load_addr_back).w,a0
		movea.w	(Object_respawn_index_back).w,a3
		subi.w	#$80,d6
		blo.s	loc_1B8A8
		bsr.w	Create_New_Sprite
		bne.s	loc_1B8A8

loc_1B892:
		cmp.w	-6(a0),d6
		bge.s	loc_1B8A8
		subq.w	#6,a0
		subq.w	#1,a3
		jsr	(a6)
		bne.s	loc_1B8A4
		subq.w	#6,a0
		bra.s	loc_1B892
; ---------------------------------------------------------------------------

loc_1B8A4:
		addq.w	#6,a0
		addq.w	#1,a3

loc_1B8A8:
		move.l	a0,(Object_load_addr_back).w
		move.w	a3,(Object_respawn_index_back).w
		movea.l	(Object_load_addr_front).w,a0
		movea.w	(Object_respawn_index_front).w,a3
		addi.w	#$300,d6

loc_1B8BC:
		cmp.w	-6(a0),d6
		bgt.s	loc_1B8C8
		subq.w	#6,a0
		subq.w	#1,a3
		bra.s	loc_1B8BC
; ---------------------------------------------------------------------------

loc_1B8C8:
		move.l	a0,(Object_load_addr_front).w
		move.w	a3,(Object_respawn_index_front).w
		bra.s	loc_1B91A
; ---------------------------------------------------------------------------

loc_1B8D2:
		move.w	d6,(Camera_X_pos_coarse).w
		movea.l	(Object_load_addr_front).w,a0
		movea.w	(Object_respawn_index_front).w,a3
		addi.w	#$280,d6
		bsr.w	Create_New_Sprite
		bne.s	loc_1B8F2

loc_1B8E8:
		cmp.w	(a0),d6
		bls.s	loc_1B8F2
		jsr	(a6)
		addq.w	#1,a3
		beq.s	loc_1B8E8

loc_1B8F2:
		move.l	a0,(Object_load_addr_front).w
		move.w	a3,(Object_respawn_index_front).w

	ifdef __DEBUG__	; RaiseError is only available in DEBUG builds
		jsr	(Load_Objects_RaiseError).l							; raise an error if there is ring status table overflow
	endif

		movea.l	(Object_load_addr_back).w,a0
		movea.w	(Object_respawn_index_back).w,a3
		subi.w	#$300,d6
		blo.s	loc_1B912

loc_1B908:
		cmp.w	(a0),d6
		bls.s	loc_1B912
		addq.w	#6,a0
		addq.w	#1,a3
		bra.s	loc_1B908
; ---------------------------------------------------------------------------

loc_1B912:
		move.l	a0,(Object_load_addr_back).w
		move.w	a3,(Object_respawn_index_back).w

loc_1B91A:
		moveq	#-$80,d6
		and.w	(Camera_Y_pos).w,d6
		move.w	d6,d3
		cmp.w	(Camera_Y_pos_coarse).w,d6
		beq.w	loc_1B9FA
		bge.s	loc_1B956
		tst.w	(Camera_min_Y_pos).w
		bpl.s	loc_1B94C
		tst.w	d6
		bne.s	loc_1B940
		cmpi.w	#$80,(Camera_Y_pos_coarse).w
		bne.s	loc_1B968

loc_1B940:
		subi.w	#$80,d3
		bpl.s	loc_1B982
		and.w	(Screen_Y_wrap_value).w,d3
		bra.s	loc_1B982
; ---------------------------------------------------------------------------

loc_1B94C:
		subi.w	#$80,d3
		bmi.w	loc_1B9FA
		bra.s	loc_1B982
; ---------------------------------------------------------------------------

loc_1B956:
		tst.w	(Camera_min_Y_pos).w
		bpl.s	loc_1B978
		tst.w	(Camera_Y_pos_coarse).w
		bne.s	loc_1B968
		cmpi.w	#$80,d6
		bne.s	loc_1B940

loc_1B968:
		addi.w	#$180,d3
		cmp.w	(Screen_Y_wrap_value).w,d3
		blo.s	loc_1B982
		and.w	(Screen_Y_wrap_value).w,d3
		bra.s	loc_1B982
; ---------------------------------------------------------------------------

loc_1B978:
		addi.w	#$180,d3
		cmp.w	(Screen_Y_wrap_value).w,d3
		bhi.w	loc_1B9FA

loc_1B982:
		bsr.w	Create_New_Sprite
		bne.s	loc_1B9FA
		move.w	d3,d4
		addi.w	#$80,d4
		move.w	#$FFF,d5
		movea.l	(Object_load_addr_back).w,a0
		movea.w	(Object_respawn_index_back).w,a3
		move.l	(Object_load_addr_front).w,d7
		sub.l	a0,d7
		beq.s	loc_1B9FA
		addq.w	#2,a0

loc_1B9A4:
		tst.b	(a3)
		bmi.s	loc_1B9F2
		move.w	(a0),d1
		and.w	d5,d1
		cmp.w	d3,d1
		blo.s	loc_1B9F2
		cmp.w	d4,d1
		bhi.s	loc_1B9F2
		bset	#7,(a3)
		move.w	-2(a0),x_pos(a1)
		move.w	(a0),d1
		move.w	d1,d2
		and.w	d5,d1
		move.w	d1,y_pos(a1)
		rol.w	#3,d2

		andi.w	#( \
			setBit(render_flags.x_flip) | \
			setBit(render_flags.y_flip) \
		),d2

		move.b	d2,render_flags(a1)
		move.b	d2,status(a1)
		move.b	2(a0),d2
		add.w	d2,d2
		add.w	d2,d2
		move.l	(a4,d2.w),address(a1)
		move.b	3(a0),subtype(a1)
		move.w	a3,respawn_addr(a1)

		; Create_New_Sprite4
		subq.w	#1,d0
		bmi.s	loc_1B9FA

.find
		lea	next_object(a1),a1								; goto next object RAM slot
		tst.l	address(a1)									; is object RAM slot empty?
		dbeq	d0,.find									; if not, branch
		bne.s	loc_1B9FA

loc_1B9F2:
		addq.w	#6,a0
		addq.w	#1,a3
		subq.w	#6,d7
		bne.s	loc_1B9A4

loc_1B9FA:
		move.w	d6,(Camera_Y_pos_coarse).w
		rts
; ---------------------------------------------------------------------------

loc_1BA40:
		tst.b	(a3)
		bpl.s	loc_1BA4A
		addq.w	#6,a0
		moveq	#0,d1
		rts
; ---------------------------------------------------------------------------

loc_1BA4A:
		move.w	(a0)+,d7
		move.w	(a0)+,d1
		move.w	d1,d2
		bmi.s	loc_1BA62
		and.w	d5,d1
		cmp.w	d3,d1
		bhs.s	loc_1BA64
		cmp.w	d4,d1
		bls.s	loc_1BA64
		addq.w	#2,a0
		moveq	#0,d1
		rts
; ---------------------------------------------------------------------------

loc_1BA62:
		and.w	d5,d1

loc_1BA64:
		bset	#7,(a3)
		move.w	d7,x_pos(a1)
		move.w	d1,y_pos(a1)
		rol.w	#3,d2

		andi.w	#( \
			setBit(render_flags.x_flip) | \
			setBit(render_flags.y_flip) \
		),d2

		move.b	d2,render_flags(a1)
		move.b	d2,status(a1)
		move.b	(a0)+,d2
		add.w	d2,d2
		add.w	d2,d2
		move.l	(a4,d2.w),address(a1)
		move.b	(a0)+,subtype(a1)
		move.w	a3,respawn_addr(a1)

		; Create_New_Sprite4
		subq.w	#1,d0
		bmi.s	.return

.find
		lea	next_object(a1),a1								; goto next object RAM slot
		tst.l	address(a1)									; is object RAM slot empty?
		dbeq	d0,.find									; if not, branch

.return
		rts
; ---------------------------------------------------------------------------

loc_1BA92:
		tst.b	(a3)
		bpl.s	loc_1BA9C
		addq.w	#6,a0
		moveq	#0,d1
		rts
; ---------------------------------------------------------------------------

loc_1BA9C:
		move.w	(a0)+,d7
		move.w	(a0)+,d1
		move.w	d1,d2
		bmi.s	loc_1BAB4
		and.w	d5,d1
		cmp.w	d3,d1
		blo.s	loc_1BAAE
		cmp.w	d4,d1
		bls.s	loc_1BAB6

loc_1BAAE:
		addq.w	#2,a0
		moveq	#0,d1
		rts
; ---------------------------------------------------------------------------

loc_1BAB4:
		and.w	d5,d1

loc_1BAB6:
		bset	#7,(a3)
		move.w	d7,x_pos(a1)
		move.w	d1,y_pos(a1)
		rol.w	#3,d2

		andi.w	#( \
			setBit(render_flags.x_flip) | \
			setBit(render_flags.y_flip) \
		),d2

		move.b	d2,render_flags(a1)
		move.b	d2,status(a1)
		move.b	(a0)+,d2
		add.w	d2,d2
		add.w	d2,d2
		move.l	(a4,d2.w),address(a1)
		move.b	(a0)+,subtype(a1)
		move.w	a3,respawn_addr(a1)

Create_New_Sprite4:
		subq.w	#1,d0
		bmi.s	.notfree

.find
		lea	next_object(a1),a1								; goto next object RAM slot
		tst.l	address(a1)									; is object RAM slot empty?
		dbeq	d0,.find									; if not, branch

.notfree
		rts

; ---------------------------------------------------------------------------
; Changes the coarse back- and forward-camera edges to match new Camera_X value.
; Also seeks to appropriate object locations in the level's object layout, so
; that Load_Objects will correctly load the objects again.
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Seek_Object_Manager:
		move.w	(Camera_X_pos).w,d6
		addi.w	#$400,d6
		andi.w	#$FF80,d6
		cmp.w	(Camera_X_pos_coarse).w,d6
		beq.w	locret_1BC5E
		bge.s	loc_1BC1C
		move.w	d6,(Camera_X_pos_coarse).w
		movea.l	(Object_load_addr_back).w,a1
		movea.w	(Object_respawn_index_back).w,a3
		subi.w	#$80,d6
		blo.s	loc_1BBF2

loc_1BBE6:
		cmp.w	-6(a1),d6
		bge.s	loc_1BBF2
		subq.w	#6,a1
		subq.w	#1,a3
		bra.s	loc_1BBE6
; ---------------------------------------------------------------------------

loc_1BBF2:
		move.l	a1,(Object_load_addr_back).w
		move.w	a3,(Object_respawn_index_back).w
		movea.l	(Object_load_addr_front).w,a1
		movea.w	(Object_respawn_index_front).w,a3
		addi.w	#$300,d6

loc_1BC06:
		cmp.w	-6(a1),d6
		bgt.s	loc_1BC12
		subq.w	#6,a1
		subq.w	#1,a3
		bra.s	loc_1BC06
; ---------------------------------------------------------------------------

loc_1BC12:
		move.l	a1,(Object_load_addr_front).w
		move.w	a3,(Object_respawn_index_front).w
		rts
; ---------------------------------------------------------------------------

loc_1BC1C:
		move.w	d6,(Camera_X_pos_coarse).w
		movea.l	(Object_load_addr_front).w,a1
		movea.w	(Object_respawn_index_front).w,a3
		addi.w	#$280,d6

loc_1BC2C:
		cmp.w	(a1),d6
		bls.s	loc_1BC36
		addq.w	#6,a1
		addq.w	#1,a3
		bra.s	loc_1BC2C
; ---------------------------------------------------------------------------

loc_1BC36:
		move.l	a1,(Object_load_addr_front).w
		move.w	a3,(Object_respawn_index_front).w
		movea.l	(Object_load_addr_back).w,a1
		movea.w	(Object_respawn_index_back).w,a3
		subi.w	#$300,d6
		blo.s	loc_1BC56

loc_1BC4C:
		cmp.w	(a1),d6
		bls.s	loc_1BC56
		addq.w	#6,a1
		addq.w	#1,a3
		bra.s	loc_1BC4C
; ---------------------------------------------------------------------------

loc_1BC56:
		move.l	a1,(Object_load_addr_back).w
		move.w	a3,(Object_respawn_index_back).w

locret_1BC5E:
		rts
