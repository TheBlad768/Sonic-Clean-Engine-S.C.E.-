; ---------------------------------------------------------------------------
; Increase screen right boundary (Object)
; ---------------------------------------------------------------------------

; dynamic object variables

	dsset animations_addr								; pretend we're in the RAM

levelsize.maxX				ds.l 1						; maximum x-axis position (4 bytes)

	dsreset										; stop pretending and reset the program counter

; =============== S U B R O U T I N E =======================================

Obj_IncLevEndXGradual:
		move.w	(Camera_max_X_pos).w,d0
		move.l	levelsize.maxX(a0),d1
		addi.l	#$4000,d1							; increase speed
		move.l	d1,levelsize.maxX(a0)
		swap	d1
		add.w	d1,d0
		cmp.w	(Camera_stored_max_X_pos).w,d0
		bhs.s	.done
		move.w	d0,(Camera_max_X_pos).w
		rts
; ---------------------------------------------------------------------------

.done
		move.w	(Camera_stored_max_X_pos).w,(Camera_max_X_pos).w
		jmp	(Delete_Current_Object).w

; ---------------------------------------------------------------------------
; Decrease screen left boundary (Object)
; ---------------------------------------------------------------------------

; dynamic object variables

	dsset animations_addr								; pretend we're in the RAM

levelsize.minX				ds.l 1						; minimum x-axis position (4 bytes)

	dsreset										; stop pretending and reset the program counter

; =============== S U B R O U T I N E =======================================

Obj_DecLevStartXGradual:
		move.w	(Camera_min_X_pos).w,d0
		move.l	levelsize.minX(a0),d1
		addi.l	#$4000,d1							; decrease speed
		move.l	d1,levelsize.minX(a0)
		swap	d1
		sub.w	d1,d0
		cmp.w	(Camera_stored_min_X_pos).w,d0
		ble.s	.done
		move.w	d0,(Camera_min_X_pos).w
		rts
; ---------------------------------------------------------------------------

.done
		move.w	(Camera_stored_min_X_pos).w,(Camera_min_X_pos).w
		jmp	(Delete_Current_Object).w

; ---------------------------------------------------------------------------
; Increase screen bottom boundary (Object)
; ---------------------------------------------------------------------------

; dynamic object variables

	dsset animations_addr								; pretend we're in the RAM

levelsize.maxY				ds.l 1						; maximum y-axis position (4 bytes)

	dsreset										; stop pretending and reset the program counter

; =============== S U B R O U T I N E =======================================

Obj_IncLevEndYGradual:
		move.w	(Camera_max_Y_pos).w,d0
		move.l	levelsize.maxY(a0),d1
		addi.l	#$8000,d1							; increase speed
		move.l	d1,levelsize.maxY(a0)
		swap	d1
		add.w	d1,d0
		cmp.w	(Camera_stored_max_Y_pos).w,d0
		bgt.s	.done
		move.w	d0,(Camera_max_Y_pos).w
		rts
; ---------------------------------------------------------------------------

.done
		move.w	(Camera_stored_max_Y_pos).w,(Camera_max_Y_pos).w
		jmp	(Delete_Current_Object).w

; ---------------------------------------------------------------------------
; Decrease screen top boundary (Object)
; ---------------------------------------------------------------------------

; dynamic object variables

	dsset animations_addr								; pretend we're in the RAM

levelsize.minY				ds.l 1						; minimum y-axis position (4 bytes)

	dsreset										; stop pretending and reset the program counter

; =============== S U B R O U T I N E =======================================

Obj_DecLevStartYGradual:
		move.w	(Camera_min_Y_pos).w,d0
		move.l	levelsize.minY(a0),d1
		addi.l	#$4000,d1							; decrease speed
		move.l	d1,levelsize.minY(a0)
		swap	d1
		sub.w	d1,d0
		cmp.w	(Camera_stored_min_Y_pos).w,d0
		ble.s	.done
		move.w	d0,(Camera_min_Y_pos).w
		rts
; ---------------------------------------------------------------------------

.done
		move.w	(Camera_stored_min_Y_pos).w,(Camera_min_Y_pos).w
		jmp	(Delete_Current_Object).w

; =============== S U B R O U T I N E =======================================

Child6_IncLevX:
		dc.w 1-1
		dc.l Obj_IncLevEndXGradual
Child6_DecLevX:
		dc.w 1-1
		dc.l Obj_DecLevStartXGradual
Child6_IncLevY:
		dc.w 1-1
		dc.l Obj_IncLevEndYGradual
Child6_DecLevY:
		dc.w 1-1
		dc.l Obj_DecLevStartYGradual
Child6_DecIncLevX:
		dc.w 2-1
		dc.l Obj_DecLevStartXGradual
		dc.b 0, 0
		dc.l Obj_IncLevEndXGradual
		dc.b 0, 0
Child1_ActLevelSize:
		dc.w 3-1
		dc.l Obj_IncLevEndXGradual
		dc.b 0, 0
		dc.l Obj_DecLevStartYGradual
		dc.b 0, 0
		dc.l Obj_IncLevEndYGradual
		dc.b 0, 0
Child7_ChangeLevSize:
		dc.w 4-1
		dc.l Obj_DecLevStartYGradual
		dc.b 0, 0
		dc.l Obj_IncLevEndYGradual
		dc.b 0, 0
		dc.l Obj_DecLevStartXGradual
		dc.b 0, 0
		dc.l Obj_IncLevEndXGradual
		dc.b 0, 0
