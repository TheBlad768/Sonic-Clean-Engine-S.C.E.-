; ---------------------------------------------------------------------------
; Increase screen right boundary (Object)
; ---------------------------------------------------------------------------

; dynamic object variables

; =============== S U B R O U T I N E =======================================

Obj_IncLevEndXGradual:
		move.w	(Camera_max_X_pos).w,d0
		move.l	objoff_30(a0),d1
		addi.l	#$4000,d1
		move.l	d1,objoff_30(a0)
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

; =============== S U B R O U T I N E =======================================

Obj_DecLevStartXGradual:
		move.w	(Camera_min_X_pos).w,d0
		move.l	objoff_30(a0),d1
		addi.l	#$4000,d1
		move.l	d1,objoff_30(a0)
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

; =============== S U B R O U T I N E =======================================

Obj_IncLevEndYGradual:
		move.w	(Camera_max_Y_pos).w,d0
		move.l	objoff_30(a0),d1
		addi.l	#$8000,d1
		move.l	d1,objoff_30(a0)
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

; =============== S U B R O U T I N E =======================================

Obj_DecLevStartYGradual:
		move.w	(Camera_min_Y_pos).w,d0
		move.l	objoff_30(a0),d1
		addi.l	#$4000,d1
		move.l	d1,objoff_30(a0)
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
