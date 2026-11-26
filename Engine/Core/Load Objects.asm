; ---------------------------------------------------------------------------
; Load level objects
;
; input variables:
;  -none-
;
; writes:
;  d0 = object slot
;  d3 = upper boundary to load object
;  d4 = lower boundary to load object
;  d5 = #$FFF, used to filter out object's y position
;  d6 = camera position
;  d1, d2, d7 = misc
;
;  a0 = address in object placement list
;  a1 = address of object slot
;  a3 = address in object respawn table
;  a4 = address of object index
;  a5 = address of free objects list
;  a6 = object loading routine
;
; Optimized version by Flamewing
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Load_Objects:
		movea.l	(Object_load_addr_RAM).w,a0
		jmp	(a0)

; =============== S U B R O U T I N E =======================================

Load_Objects_Init:

		; initialize each object load address with the first object in the layout
		movea.l	(Level_data_addr_RAM.ObjectsRAM).w,a0
		move.l	a0,(Object_load_addr_front).w
		move.l	a0,(Object_load_addr_back).w

Load_Objects_Init2:
		move.l	#Load_Objects_Main,(Object_load_addr_RAM).w
		move.l	#Obj_Index,(Object_index_addr).w

		; check
		tst.b	(Respawn_table_keep).w						; are you restarting from a lamppost?
		bne.s	.skip								; if yes, branch
		clearRAM Object_respawn_table, Object_respawn_table_end			; clear data

.skip
		lea	(Object_respawn_table).w,a3

		moveq	#-$80,d1
		move.w	(Camera_X_pos).w,d6
		add.w	d1,d6								; look one chunk to the left (d1 = -$80)
		blo.s	.nocap								; if the result was negative,
		moveq	#0,d6								; cap at zero

.nocap
		and.w	d1,d6								; limit to increments of $80 (width of a chunk)
		movea.l	(Object_load_addr_front).w,a0					; get first object in layout

		; at the beginning of a level this gives respawn table entries to any object that is one chunk
		; behind the left edge of the screen that needs to remember its state (Monitors, Badniks, etc.)

.scan_right1
		cmp.w	(a0),d6								; is object's x position >= d6?
		bls.s	.found_rightmost						; if yes, branch
		addq.w	#8,a0								; next object
		addq.w	#1,a3								; respawn index of next object going right
		bra.s	.scan_right1							; continue with next object
; ---------------------------------------------------------------------------

.found_rightmost
		move.l	a0,(Object_load_addr_front).w					; remember rightmost object that has been processed, so far (we still need to look forward)
		move.w	a3,(Object_respawn_index_front).w				; and its respawn table index

	if DEBUG_LoadObjects
		; RaiseError is only available in DEBUG builds
		ifdebug	jsr	(Load_Objects_RaiseError).l				; raise an error if there is object respawn table overflow
	endif

		lea	(Object_respawn_table).w,a3					; reset a3
		movea.l	(Object_load_addr_back).w,a0					; reset a0
		add.w	d1,d6								; look even farther left (any object behind this is out of range)
		bhs.s	.found_leftmost							; branch, if camera position would be behind level's left boundary

.scan_right2:
		cmp.w	(a0),d6								; is object's x position >= d6?
		bls.s	.found_leftmost							; if yes, branch
		addq.w	#8,a0
		addq.w	#1,a3								; respawn index of next object going left
		bra.s	.scan_right2							; continue with next object
; ---------------------------------------------------------------------------

.found_leftmost:
		move.l	a0,(Object_load_addr_back).w					; remember current object from the left
		move.w	a3,(Object_respawn_index_back).w				; and its respawn table index

		move.w	#-1,(Camera_X_pos_coarse).w					; make sure Load_Objects_GoingForward is run

		and.w	(Camera_Y_pos).w,d1
		move.w	d1,(Camera_Y_pos_coarse).w					; make sure the Y check isn't run unnecessarily during initialization

		; fall throuh

Load_Objects_Main:

		; get coarse camera position
		moveq	#-$80,d1
		move.w	(Camera_Y_pos).w,d0
		add.w	d1,d0								; one chunk up (d1 = -$80)
		and.w	d1,d0
		move.w	d0,(Camera_Y_pos_coarse_back).w

		move.w	(Camera_X_pos).w,d0
		add.w	d1,d0								; one chunk up (d1 = -$80)
		and.w	d1,d0
		move.w	d0,(Camera_X_pos_coarse_back).w
		movea.l	(Object_index_addr).w,a4

		; check
		tst.w	(Camera_min_Y_pos).w						; does this level y-wrap?
		bpl.s	.NoYWrap							; if not, branch
		lea	ChkLoadObj_YWrap(pc),a6						; set object loading routine
		move.w	(Camera_Y_pos).w,d3
		and.w	d1,d3								; get coarse value
		move.w	d3,d4
		addi.w	#$200,d4							; set lower boundary
		add.w	d1,d3								; set upper boundaryy (d1 = -$80)
		bpl.s	.nowrap_top							; branch, if upper boundary > 0
		and.w	(Screen_Y_wrap_value).w,d3					; wrap value
		bra.s	Load_Objects_Main_Cont
; ---------------------------------------------------------------------------

.nowrap_top
		move.w	(Screen_Y_wrap_value).w,d0
		addq.w	#1,d0
		cmp.w	d0,d4
		bls.s	.valid_top							; branch, if lower boundary < wrap value
		and.w	(Screen_Y_wrap_value).w,d4					; wrap value
		bra.s	Load_Objects_Main_Cont
; ---------------------------------------------------------------------------

.NoYWrap
		move.w	(Camera_Y_pos).w,d3
		and.w	d1,d3								; get coarse value
		move.w	d3,d4
		addi.w	#$200,d4							; set lower boundary
		add.w	d1,d3								; set upper boundary (d1 = -$80)
		bpl.s	.valid_top
		moveq	#0,d3								; no negative values allowed

.valid_top
		lea	ChkLoadObj(pc),a6						; set object loading routine

Load_Objects_Main_Cont:
		move.w	#$FFF,d5							; this will be used later when we load objects
		move.w	(Camera_X_pos).w,d6
		and.w	d1,d6
		cmp.w	(Camera_X_pos_coarse).w,d6					; is the X range the same as last time?
		beq.w	Load_Objects_SameXRange						; if yes, branch
		bge.s	Load_Objects_GoingForward					; if new pos is greater than old pos, branch

		; if the player is moving back
		move.w	d6,(Camera_X_pos_coarse).w					; remember current position for next time

		movea.l	(Object_load_addr_back).w,a0					; get current object going left
		movea.w	(Object_respawn_index_back).w,a3				; and its respawn table index

		add.w	d1,d6								; look one chunk to the lefty (d1 = -$80)
		bhs.s	Load_Objects_GoingBack_Part2					; branch, if camera position would be behind level's left boundary

		; find an empty object slot
		bsr.w	Create_New_Object
		bne.s	Load_Objects_GoingBack_Part2

		; load all objects left of the screen that are now in range

.scan_left
		cmp.w	-8(a0),d6							; is the previous object's X pos less than d6?
		bge.s	Load_Objects_GoingBack_Part2					; if it is, branch
		subq.w	#8,a0								; get object's address
		subq.w	#1,a3								; and respawn table index
		jsr	(a6)								; load object
		bne.s	.loadfail							; branch, if SST is full
		subq.w	#8,a0
		bra.s	.scan_left							; continue with previous object
; ---------------------------------------------------------------------------

.loadfail

		; undo a few things, if the object couldn't load
		addq.w	#8,a0								; go back to last object
		addq.w	#1,a3								; since we didn't load the object, undo last change

Load_Objects_GoingBack_Part2:
		move.l	a0,(Object_load_addr_back).w					; remember current object going left
		move.w	a3,(Object_respawn_index_back).w				; and its respawn table index

		movea.l	(Object_load_addr_front).w,a0					; get next object going right
		movea.w	(Object_respawn_index_front).w,a3				; and its respawn table index
		addi.w	#$300,d6							; look two chunks beyond the right edge of the screen

		; subtract number of objects that have been moved out of range (from the right side)

.scan_left
		cmp.w	-8(a0),d6							; is the previous object's X pos less than d6?
		bgt.s	.found_prev							; if it is, branch
		subq.w	#8,a0								; get object's address
		subq.w	#1,a3								; and respawn table index
		bra.s	.scan_left							; continue with previous object
; ---------------------------------------------------------------------------

.found_prev
		move.l	a0,(Object_load_addr_front).w					; remember next object going right
		move.w	a3,(Object_respawn_index_front).w				; and its respawn table index

	if DEBUG_LoadObjects
		; RaiseError is only available in DEBUG builds
		ifdebug	jsr	(Load_Objects_RaiseError).l				; raise an error if there is object respawn table overflow
	endif

		bra.s	Load_Objects_SameXRange
; ---------------------------------------------------------------------------

Load_Objects_GoingForward:
		move.w	d6,(Camera_X_pos_coarse).w

		movea.l	(Object_load_addr_front).w,a0					; get next object from the right
		movea.w	(Object_respawn_index_front).w,a3				; and its respawn table index
		addi.w	#$280,d6							; look two chunks forward

		; find an empty object slot
		bsr.w	Create_New_Object
		bne.s	Load_Objects_GoingForward_Part2

		; load all objects right of the screen that are now in range

.scan_right
		cmp.w	(a0),d6								; is object's x position >= d6?
		bls.s	Load_Objects_GoingForward_Part2					; if yes, branch
		jsr	(a6)								; load object (and get address of next object)
		addq.w	#1,a3								; respawn index of next object to the right
		beq.s	.scan_right							; continue loading objects, if the SST isn't full

Load_Objects_GoingForward_Part2:
		move.l	a0,(Object_load_addr_front).w					; remember next object from the right
		move.w	a3,(Object_respawn_index_front).w				; and its respawn table index

	if DEBUG_LoadObjects
		; RaiseError is only available in DEBUG builds
		ifdebug	jsr	(Load_Objects_RaiseError).l				; raise an error if there is object respawn table overflow
	endif

		movea.l	(Object_load_addr_back).w,a0					; get current object from the left
		movea.w	(Object_respawn_index_back).w,a3				; and its respawn table index
		subi.w	#$300,d6							; look one chunk behind the left edge of the screen
		blo.s	Load_Objects_GoingForward_End					; branch, if camera position would be behind level's left boundary

		; subtract number of objects that have been moved out of range (from the left)

.scan_right
		cmp.w	(a0),d6								; is object's x position >= d6?
		bls.s	Load_Objects_GoingForward_End					; if yes, branch
		addq.w	#8,a0								; next object
		addq.w	#1,a3								; respawn index of next object to the left
		bra.s	.scan_right							; continue with next object
; ---------------------------------------------------------------------------

Load_Objects_GoingForward_End:
		move.l	a0,(Object_load_addr_back).w					; remember current object from the left
		move.w	a3,(Object_respawn_index_back).w				; and its respawn table index

Load_Objects_SameXRange:
		move.w	(Camera_Y_pos).w,d6
		and.w	d1,d6
		move.w	d6,d3
		cmp.w	(Camera_Y_pos_coarse).w,d6					; is the y range the same as last time?
		beq.s	Load_Objects_Done						; if yes, branch
		bge.s	Load_Objects_GoingDown						; if the player is moving down

		; if the player is moving up
		move.w	d6,(Camera_Y_pos_coarse).w
		tst.w	(Camera_min_Y_pos).w						; does the level y-wrap?
		bpl.s	Load_Objects_GoingUp_NoYWrap					; if not, branch
		tst.w	d6
		bne.s	Load_Objects_GoingUp_YWrap
		cmpi.w	#$80,(Camera_Y_pos_coarse).w
		bne.s	Load_Objects_GoingDown_YWrap

Load_Objects_GoingUp_YWrap:
		add.w	d1,d3								; look one chunk up (d1 = -$80)
		and.w	(Screen_Y_wrap_value).w,d3					; else, wrap value
		bra.s	Load_Objects_YCheck
; ---------------------------------------------------------------------------

Load_Objects_GoingUp_NoYWrap:
		add.w	d1,d3								; look one chunk up (d1 = -$80)
		bmi.s	Load_Objects_Done						; don't do anything if camera y position is < $80
		bra.s	Load_Objects_YCheck
; ---------------------------------------------------------------------------

Load_Objects_GoingDown:
		move.w	d6,(Camera_Y_pos_coarse).w
		tst.w	(Camera_min_Y_pos).w						; does the level y-wrap?
		bpl.s	Load_Objects_GoingDown_NoYWrap					; if not, branch
		tst.w	(Camera_Y_pos_coarse).w
		bne.s	Load_Objects_GoingDown_YWrap
		cmpi.w	#$80,d6
		bne.s	Load_Objects_GoingUp_YWrap

Load_Objects_GoingDown_YWrap:
		addi.w	#$180,d3							; look one chunk down
		and.w	(Screen_Y_wrap_value).w,d3					; wrap value
		bra.s	Load_Objects_YCheck
; ---------------------------------------------------------------------------

Load_Objects_Done:
		rts
; ---------------------------------------------------------------------------

Load_Objects_GoingDown_NoYWrap:
		addi.w	#$180,d3							; look one chunk down
		cmp.w	(Screen_Y_wrap_value).w,d3
		bhi.s	Load_Objects_Done						; don't do anything, if camera is too close to bottom

Load_Objects_YCheck:

		; check
		movem.l	(Object_load_addr_front).w,d7/a0				; get next object going right (d7) and left (a0)
		sub.l	a0,d7								; d7 = number of objects between the left and right boundaries * 8
		beq.s	.done								; branch if there are no objects inbetween

		; get an empty object slot
		bsr.w	Create_New_Object
		bne.s	.done

		; get
		movea.w	(Object_respawn_index_back).w,a3				; and its respawn table index
		move.w	d3,d4
		sub.w	d1,d4								; d4 += $80 (d1 = -$80)
		move.w	#$FFF,d5							; this will be used later when we load objects

.loop

		; check, if current object needs to be loaded
		tst.b	(a3)								; is object already loaded?
		bmi.s	.next								; if yes, branch
		move.w	(a0)+,d6							; get xpos
		move.w	(a0)+,d2							; get ypos
		cmp.w	d3,d2
		blo.s	.next2								; branch, if object is out of range from the top
		cmp.w	d4,d2
		bhi.s	.next2								; branch, if object is out of range from the bottom

		; load object
		or.b	d1,(a3)								; mark object as loaded (d1 = -$80)
		move.w	d2,y_pos(a1)							; set ypos
		move.w	d6,x_pos(a1)							; set xpos
		move.w	(a0)+,d2							; get object id
		move.w	d2,d6
		and.w	d5,d6								; object id mask
		add.w	d6,d6								; multiply by 4
		add.w	d6,d6
		move.l	(a4,d6.w),code_addr(a1)
		rol.w	#3,d2

		; get object's render flags and status
		andi.w	#( \
			setBit(render_flags.x_flip) | \
			setBit(render_flags.y_flip) \
		),d2

		; set
		move.b	d2,render_flags(a1)
		move.b	d2,status(a1)
		move.w	(a0)+,subtype(a1)
		move.w	a3,respawn_addr(a1)

		; find new object slot
		Create_New_Object_4.s	.done
		bne.s	.done

		; next
		addq.w	#1,a3								; and its respawn index
		subq.w	#8,d7								; subtract from size of remaining objects
		bne.s	.loop								; branch, if there are more

.done
		rts
; ---------------------------------------------------------------------------

.next
		addq.w	#8,a0								; address of next object
		addq.w	#1,a3								; and its respawn index
		subq.w	#8,d7								; subtract from size of remaining objects
		bne.s	.loop								; branch, if there are more
		rts
; ---------------------------------------------------------------------------

.next2
		addq.w	#8-4,a0								; address of next object
		addq.w	#1,a3								; and its respawn index
		subq.w	#8,d7								; subtract from size of remaining objects
		bne.s	.loop								; branch, if there are more
		rts

; ---------------------------------------------------------------------------
; Subroutines to check if an object needs to be loaded with y-wrapping.
;
; input variables:
;  d0 = object slot
;  d1 = -$80
;  d3 = upper boundary to load object
;  d4 = lower boundary to load object
;  d5 = #$FFF, used to filter out object's y position
;  d6 = camera x position
;
;  a0 = address in object placement list
;  a1 = object
;  a3 = address in object respawn table
;
; writes:
;  d2, d7
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

ChkLoadObj_YWrap:
		tst.b	(a3)								; is object already loaded?
		bpl.s	.chk_yrange							; if not, branch

		; next
		addq.w	#8,a0								; address of next object
		moveq	#0,d7								; let the objects manager know that it can keep going
		rts
; ---------------------------------------------------------------------------

.chk_yrange
		move.w	(a0)+,d7							; get xpos
		swap	d7
		move.w	(a0)+,d7							; get ypos
		move.w	(a0)+,d2							; get object id
		bmi.s	.spawn_obj
		cmp.w	d3,d7
		bhs.s	.spawn_obj
		cmp.w	d4,d7
		bls.s	.spawn_obj

		; next
		addq.w	#2,a0								; address of next object
		moveq	#0,d7								; let the objects manager know that it can keep going
		rts
; ---------------------------------------------------------------------------

.spawn_obj
		or.b	d1,(a3)								; mark object as loaded (d1 = -$80)
		move.w	d7,y_pos(a1)
		swap	d7
		move.w	d7,x_pos(a1)
		move.w	d2,d7
		and.w	d5,d7								; object id mask
		add.w	d7,d7								; multiply by 4
		add.w	d7,d7
		move.l	(a4,d7.w),code_addr(a1)
		rol.w	#3,d2

		; get object's render flags and status
		andi.w	#( \
			setBit(render_flags.x_flip) | \
			setBit(render_flags.y_flip) \
		),d2

		; set
		move.b	d2,render_flags(a1)
		move.b	d2,status(a1)
		move.w	(a0)+,subtype(a1)
		move.w	a3,respawn_addr(a1)

		; find new object slot
		Create_New_Object_4.s	, 1

; ---------------------------------------------------------------------------
; Subroutines to check if an object needs to be loaded without y-wrapping.
;
; input variables:
;  d0 = object slot
;  d1 = -$80
;  d3 = upper boundary to load object
;  d4 = lower boundary to load object
;  d5 = #$FFF, used to filter out object's y position
;  d6 = camera x position
;
;  a0 = address in object placement list
;  a1 = object
;  a3 = address in object respawn table
;
; writes:
;  d2, d7
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

ChkLoadObj:
		tst.b	(a3)								; is object already loaded?
		bpl.s	.chk_yrange							; if not, branch

		; next
		addq.w	#8,a0								; address of next object
		moveq	#0,d7								; let the objects manager know that it can keep going
		rts
; ---------------------------------------------------------------------------

.chk_yrange
		move.w	(a0)+,d7							; get xpos
		swap	d7
		move.w	(a0)+,d7							; get ypos
		move.w	(a0)+,d2							; get object id
		bmi.s	.spawn_obj
		cmp.w	d3,d7
		blo.s	.out_of_range							; branch, if object is out of range from the top
		cmp.w	d4,d7
		bls.s	.spawn_obj							; branch, if object is in range from the bottom

.out_of_range

		; next
		addq.w	#2,a0								; address of next object
		moveq	#0,d7								; let the objects manager know that it can keep going
		rts
; ---------------------------------------------------------------------------

.spawn_obj
		or.b	d1,(a3)								; mark object as loaded (d1 = -$80)
		move.w	d7,y_pos(a1)
		swap	d7
		move.w	d7,x_pos(a1)
		move.w	d2,d7
		and.w	d5,d7								; object id mask
		add.w	d7,d7								; multiply by 4
		add.w	d7,d7
		move.l	(a4,d7.w),code_addr(a1)
		rol.w	#3,d2

		; get object's render flags and status
		andi.w	#( \
			setBit(render_flags.x_flip) | \
			setBit(render_flags.y_flip) \
		),d2

		; set
		move.b	d2,render_flags(a1)
		move.b	d2,status(a1)
		move.w	(a0)+,subtype(a1)
		move.w	a3,respawn_addr(a1)

		; create
		Create_New_Object_4.s	, 1

; ---------------------------------------------------------------------------
; Changes the coarse back- and forward-camera edges to match new Camera_X value.
; Also seeks to appropriate object locations in the level's object layout, so
; that Load_Objects will correctly load the objects again.
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Seek_Object_Manager:
		moveq	#-$80,d1
		move.w	(Camera_X_pos).w,d6
		addi.w	#$400,d6
		and.w	d1,d6
		cmp.w	(Camera_X_pos_coarse).w,d6					; is the X range the same as last time?
		beq.s	Seek_Object_Manager_Done					; if yes, branch
		bge.s	Seek_Object_Manager_GoingForward				; if new pos is greater than old pos, branch

		; if the player is moving back
		move.w	d6,(Camera_X_pos_coarse).w					; remember current position for next time

		movea.l	(Object_load_addr_back).w,a1					; get current object going left
		movea.w	(Object_respawn_index_back).w,a3				; and its respawn table index

		add.w	d1,d6								; look one chunk to the lefty (d1 = -$80)
		bhs.s	Seek_Object_Manager_GoingBack_Part2				; branch, if camera position would be behind level's left boundary

		; load all objects left of the screen that are now in range

.scan_left
		cmp.w	-8(a1),d6							; is the previous object's X pos less than d6?
		bge.s	Seek_Object_Manager_GoingBack_Part2				; if it is, branch
		subq.w	#8,a1								; get object's address
		subq.w	#1,a3								; and respawn table index
		bra.s	.scan_left							; continue with previous object
; ---------------------------------------------------------------------------

Seek_Object_Manager_GoingBack_Part2:
		move.l	a1,(Object_load_addr_back).w					; remember current object going left
		move.w	a3,(Object_respawn_index_back).w				; and its respawn table index
		movea.l	(Object_load_addr_front).w,a1					; get next object going right
		movea.w	(Object_respawn_index_front).w,a3				; and its respawn table index
		addi.w	#$300,d6							; look two chunks beyond the right edge of the screen

		; subtract number of objects that have been moved out of range (from the right side)

.scan_left
		cmp.w	-8(a1),d6							; is the previous object's X pos less than d6?
		bgt.s	.found_prev							; if it is, branch
		subq.w	#8,a1								; get object's address
		subq.w	#1,a3								; and respawn table index
		bra.s	.scan_left							; continue with previous object
; ---------------------------------------------------------------------------

.found_prev:
		move.l	a1,(Object_load_addr_front).w					; remember next object going right
		move.w	a3,(Object_respawn_index_front).w				; and its respawn table index

Seek_Object_Manager_Done:
		rts
; ---------------------------------------------------------------------------

Seek_Object_Manager_GoingForward:
		move.w	d6,(Camera_X_pos_coarse).w

		movea.l	(Object_load_addr_front).w,a1					; get next object from the right
		movea.w	(Object_respawn_index_front).w,a3				; and its respawn table index
		addi.w	#$280,d6							; look two chunks forward

		; load all objects right of the screen that are now in range

.scan_right
		cmp.w	(a1),d6								; is object's x position >= d6?
		bls.s	Seek_Object_Manager_GoingForward_Part2				; if yes, branch
		addq.w	#8,a1								; get object's address
		addq.w	#1,a3								; respawn index of next object to the right
		bra.s	.scan_right							; continue loading objects, if the SST isn't full
; ---------------------------------------------------------------------------

Seek_Object_Manager_GoingForward_Part2:
		move.l	a1,(Object_load_addr_front).w					; remember next object from the right
		move.w	a3,(Object_respawn_index_front).w				; and its respawn table index

		movea.l	(Object_load_addr_back).w,a1					; get current object from the left
		movea.w	(Object_respawn_index_back).w,a3				; and its respawn table index
		subi.w	#$300,d6							; look one chunk behind the left edge of the screen
		blo.s	Seek_Object_Manager_GoingForward_End				; branch, if camera position would be behind level's left boundary

		; subtract number of objects that have been moved out of range (from the left)

.scan_right
		cmp.w	(a1),d6								; is object's x position >= d6?
		bls.s	Seek_Object_Manager_GoingForward_End				; if yes, branch
		addq.w	#8,a1								; next object
		addq.w	#1,a3								; respawn index of next object to the left
		bra.s	.scan_right							; continue with next object
; ---------------------------------------------------------------------------

Seek_Object_Manager_GoingForward_End:
		move.l	a1,(Object_load_addr_back).w					; remember current object from the left
		move.w	a3,(Object_respawn_index_back).w				; and its respawn table index
		rts
