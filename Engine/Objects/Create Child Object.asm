; ---------------------------------------------------------------------------
; Create child sprite subroutine
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

CreateChild1_Normal:
		moveq	#0,d2								; includes positional offset data

.skip
		move.w	(a2)+,d6
		bmi.s	.return								; skip if no objects in list

.loop
		bsr.w	Create_New_Object_3
		bne.s	.return								; branch, if there are no free object slots here
		move.w	a0,parent3(a1)							; parent RAM address into parent3
		move.l	mappings(a0),mappings(a1)
		move.w	art_tile(a0),art_tile(a1)					; mappings and VRAM offset copied from parent object
		move.l	(a2)+,address(a1)						; object address
		move.b	d2,subtype(a1)							; index of child object (done sequentially for each object)
		move.w	x_pos(a0),d0
		move.b	(a2)+,d1							; x positional offset
		move.b	d1,child_dx(a1)							; child_dx has the X offset
		ext.w	d1
		add.w	d1,d0
		move.w	d0,x_pos(a1)							; apply offset to new position
		move.w	y_pos(a0),d0
		move.b	(a2)+,d1							; y positional offset
		move.b	d1,child_dy(a1)							; child_dy has the y offset
		ext.w	d1
		add.w	d1,d0
		move.w	d0,y_pos(a1)							; apply offset to new position
		addq.w	#2,d2								; add 2 to index
		dbf	d6,.loop
		moveq	#0,d0								; success

.return
		rts

; =============== S U B R O U T I N E =======================================

CreateChild2_Complex:
		moveq	#0,d2								; includes positional offset data, velocity, and a few pointers

.skip
		move.w	(a2)+,d6
		bmi.s	.return								; skip if no objects in list

.loop
		bsr.w	Create_New_Object_3
		bne.s	.return								; branch, if there are no free object slots here
		move.w	a0,parent3(a1)							; parent RAM address into parent3
		move.l	mappings(a0),mappings(a1)
		move.w	art_tile(a0),art_tile(a1)					; mappings and VRAM offset copied from parent object
		move.l	(a2)+,address(a1)						; object address
		move.l	(a2)+,objoff_3E(a1)						; object data (to be read by SetUp_ObjAttributes)
		move.l	(a2)+,aniraw_ptr(a1)						; raw animation pointer (used by Animate_Raw)
		move.l	(a2)+,jump_ptr(a1)						; jump to custom code (used by Obj_Wait)
		move.b	d2,subtype(a1)							; index of child object (done sequentially for each object)
		move.w	x_pos(a0),d0
		move.b	(a2)+,d1							; x positional offset
		move.b	d1,child_dx(a1)							; child_dx has the x offset
		ext.w	d1
		add.w	d1,d0
		move.w	d0,x_pos(a1)							; apply offset to new position
		move.w	y_pos(a0),d0
		move.b	(a2)+,d1							; y positional offset
		move.b	d1,child_dy(a1)							; child_dy has the y offset
		ext.w	d1
		add.w	d1,d0
		move.w	d0,y_pos(a1)							; apply offset to new position
		move.l	(a2)+,x_vel(a1)							; set xvel and yvel
		addq.w	#2,d2								; add 2 to index
		dbf	d6,.loop
		moveq	#0,d0								; success

.return
		rts

; =============== S U B R O U T I N E =======================================

CreateChild3_NormalRepeated:
		moveq	#0,d2								; same as child creation routine 1, except it repeats one object several times rather than different objects sequentially

.skip
		move.w	(a2)+,d6
		bmi.s	.return								; skip if no objects in list

.loop
		lea	(a2),a3								; save child data address to a3
		bsr.w	Create_New_Object_3
		bne.s	.return								; branch, if there are no free object slots here
		move.w	a0,parent3(a1)							; parent RAM address into parent3
		move.l	mappings(a0),mappings(a1)
		move.w	art_tile(a0),art_tile(a1)					; mappings and VRAM offset copied from parent object
		move.l	(a3)+,address(a1)						; object address
		move.b	d2,subtype(a1)							; index of child object (done sequentially for each object)
		move.w	x_pos(a0),d0
		move.b	(a3)+,d1							; x positional offset
		move.b	d1,child_dx(a1)							; child_dx has the X offset
		ext.w	d1
		add.w	d1,d0
		move.w	d0,x_pos(a1)							; apply offset to new position
		move.w	y_pos(a0),d0
		move.b	(a3)+,d1							; y positional offset
		move.b	d1,child_dy(a1)							; child_dy has the y offset
		ext.w	d1
		add.w	d1,d0
		move.w	d0,y_pos(a1)							; apply offset to new position
		addq.w	#2,d2								; add 2 to index
		dbf	d6,.loop
		moveq	#0,d0								; success

.return
		rts

; =============== S U B R O U T I N E =======================================

CreateChild4_LinkListRepeated:
		moveq	#0,d2								; creates a linked object list. previous object address is in parent3, while next object in list is at parent4

.skip
		move.w	(a2)+,d6
		bmi.s	.return								; skip if no objects in list
		movea.w	a0,a3								; parent RAM address into a3

.loop
		bsr.w	Create_New_Object_3
		bne.s	.return								; branch, if there are no free object slots here
		move.w	a3,parent3(a1)							; parent RAM address into parent3
		move.w	a1,parent4(a3)							; child RAM address into parent4
		movea.w	a1,a3								; next parent RAM address
		move.l	mappings(a0),mappings(a1)
		move.w	art_tile(a0),art_tile(a1)					; mappings and VRAM offset copied from parent object
		move.l	(a2),address(a1)						; object address
		move.b	d2,subtype(a1)							; index of child object (done sequentially for each object)
		move.w	x_pos(a0),x_pos(a1)
		move.w	y_pos(a0),y_pos(a1)
		addq.w	#2,d2								; add 2 to index
		dbf	d6,.loop
		moveq	#0,d0								; success

.return
		rts

; =============== S U B R O U T I N E =======================================

CreateChild5_ComplexAdjusted:
		moveq	#0,d2								; same as child routine 2, but adjusts both x position and x velocity based on parent object's orientation

.skip
		move.w	(a2)+,d6
		bmi.s	.return								; skip if no objects in list

.loop
		bsr.w	Create_New_Object_3
		bne.s	.return								; branch, if there are no free object slots here
		move.w	a0,parent3(a1)							; parent RAM address into parent3
		move.l	mappings(a0),mappings(a1)
		move.w	art_tile(a0),art_tile(a1)					; mappings and VRAM offset copied from parent object
		move.l	(a2)+,address(a1)						; object address
		move.l	(a2)+,objoff_3E(a1)						; object data (to be read by SetUp_ObjAttributes)
		move.l	(a2)+,aniraw_ptr(a1)						; raw animation pointer (used by Animate_Raw)
		move.l	(a2)+,jump_ptr(a1)						; jump to custom code (used by Obj_Wait)
		move.b	d2,subtype(a1)							; index of child object (done sequentially for each object)
		move.w	x_pos(a0),d0
		move.b	(a2)+,d1							; x positional offset
		move.b	d1,child_dx(a1)							; child_dx has the x offset
		ext.w	d1
		btst	#render_flags.x_flip,render_flags(a0)				; check flipx
		beq.s	.notxflip
		neg.w	d1

.notxflip
		add.w	d1,d0
		move.w	d0,x_pos(a1)							; apply offset to new position
		move.w	y_pos(a0),d0
		move.b	(a2)+,d1							; y positional offset
		move.b	d1,child_dy(a1)							; child_dy has the y offset
		ext.w	d1
		add.w	d1,d0
		move.w	d0,y_pos(a1)							; apply offset to new position
		move.l	(a2)+,x_vel(a1)							; set xy velocity
		btst	#render_flags.x_flip,render_flags(a0)				; check flipx
		beq.s	.notxflip2
		neg.w	x_vel(a1)

.notxflip2
		addq.w	#2,d2								; add 2 to index
		dbf	d6,.loop
		moveq	#0,d0								; success

.return
		rts

; =============== S U B R O U T I N E =======================================

CreateChild6_Simple:
		moveq	#0,d2								; simple child creation routine, merely creates x number of the same object at the parent's position

.skip
		move.w	(a2)+,d6
		bmi.s	.return								; skip if no objects in list

.loop
		bsr.w	Create_New_Object_3
		bne.s	.return								; branch, if there are no free object slots here
		move.w	a0,parent3(a1)							; parent RAM address into parent3
		move.l	mappings(a0),mappings(a1)
		move.w	art_tile(a0),art_tile(a1)					; mappings and VRAM offset copied from parent object
		move.l	(a2),address(a1)						; object address
		move.b	d2,subtype(a1)							; index of child object (done sequentially for each object)
		move.w	x_pos(a0),x_pos(a1)
		move.w	y_pos(a0),y_pos(a1)
		addq.w	#2,d2								; add 2 to index
		dbf	d6,.loop
		moveq	#0,d0								; success

.return
		rts

; =============== S U B R O U T I N E =======================================

CreateChild7_Normal2:
		moveq	#0,d2								; same as child routine 1, but does not limit children to object slots after the parent

.skip
		move.w	(a2)+,d6
		bmi.s	.return								; skip if no objects in list

.loop
		bsr.w	Create_New_Object
		bne.s	.return								; branch, if there are no free object slots here
		move.w	a0,parent3(a1)							; parent RAM address into parent3
		move.l	mappings(a0),mappings(a1)
		move.w	art_tile(a0),art_tile(a1)					; mappings and VRAM offset copied from parent object
		move.l	(a2)+,address(a1)						; object address
		move.b	d2,subtype(a1)							; index of child object (done sequentially for each object)
		move.w	x_pos(a0),d0
		move.b	(a2)+,d1							; x positional offset
		move.b	d1,child_dx(a1)							; child_dx has the X offset
		ext.w	d1
		add.w	d1,d0
		move.w	d0,x_pos(a1)							; apply offset to new position
		move.w	y_pos(a0),d0
		move.b	(a2)+,d1							; y positional offset
		move.b	d1,child_dy(a1)							; child_dy has the y offset
		ext.w	d1
		add.w	d1,d0
		move.w	d0,y_pos(a1)							; apply offset to new position
		addq.w	#2,d2								; add 2 to index
		dbf	d6,.loop
		moveq	#0,d0								; success

.return
		rts

; =============== S U B R O U T I N E =======================================

CreateChild8_TreeListRepeated:
		moveq	#0,d2								; creates a linked object list like routine 4, but they only chain themselves one way. all maintain the calling object as their parent

.skip
		move.w	(a2)+,d6
		bmi.s	.return								; skip if no objects in list
		movea.w	a0,a3								; parent RAM address into a3

.loop
		bsr.w	Create_New_Object_3
		bne.s	.return								; branch, if there are no free object slots here
		move.w	a3,parent3(a1)							; parent RAM address into parent3
		move.w	a0,parent4(a1)							; parent RAM address into parent4
		movea.w	a1,a3								; next parent RAM address
		move.l	mappings(a0),mappings(a1)
		move.w	art_tile(a0),art_tile(a1)					; mappings and VRAM offset copied from parent object
		move.l	(a2),address(a1)						; object address
		move.b	d2,subtype(a1)							; index of child object (done sequentially for each object)
		move.w	x_pos(a0),x_pos(a1)
		move.w	y_pos(a0),y_pos(a1)
		addq.w	#2,d2								; add 2 to index
		dbf	d6,.loop
		moveq	#0,d0								; success

.return
		rts

; =============== S U B R O U T I N E =======================================

CreateChild9_TreeList:
		moveq	#0,d2								; same as routine 8, but creates seperate objects in a list rather than repeating the same object

.skip
		move.w	(a2)+,d6
		bmi.s	.return								; skip if no objects in list
		movea.w	a0,a3								; parent RAM address into a3

.loop
		bsr.w	Create_New_Object_3
		bne.s	.return								; branch, if there are no free object slots here
		move.w	a3,parent3(a1)							; parent RAM address into parent3
		move.w	a0,parent4(a1)							; parent RAM address into parent4
		movea.w	a1,a3								; next parent RAM address
		move.l	mappings(a0),mappings(a1)
		move.w	art_tile(a0),art_tile(a1)					; mappings and VRAM offset copied from parent object
		move.l	(a2)+,address(a1)						; object address
		move.b	d2,subtype(a1)							; index of child object (done sequentially for each object)
		move.w	x_pos(a0),x_pos(a1)
		move.w	y_pos(a0),y_pos(a1)
		addq.w	#2,d2								; add 2 to index
		dbf	d6,.loop
		moveq	#0,d0								; success

.return
		rts

; =============== S U B R O U T I N E =======================================

CreateChild10_NormalAdjusted:
		moveq	#0,d2								; same as child routine 1, but adjusts x position based on parent object's orientation

.skip
		move.w	(a2)+,d6
		bmi.s	.return								; skip if no objects in list

.loop
		bsr.w	Create_New_Object_3
		bne.s	.return								; branch, if there are no free object slots here
		move.w	a0,parent3(a1)							; parent RAM address into parent3
		move.l	mappings(a0),mappings(a1)
		move.w	art_tile(a0),art_tile(a1)					; mappings and VRAM offset copied from parent object
		move.l	(a2)+,address(a1)						; object address
		move.b	d2,subtype(a1)							; index of child object (done sequentially for each object)
		move.w	x_pos(a0),d0
		move.b	(a2)+,d1							; x positional offset
		btst	#render_flags.x_flip,render_flags(a0)				; check flipx
		beq.s	.notflipx
		bset	#render_flags.x_flip,render_flags(a1)
		neg.b	d1

.notflipx
		move.b	d1,child_dx(a1)							; child_dx has the X offset
		ext.w	d1
		add.w	d1,d0
		move.w	d0,x_pos(a1)							; apply offset to new position
		move.w	y_pos(a0),d0
		move.b	(a2)+,d1							; y positional offset
		move.b	d1,child_dy(a1)							; child_dy has the y offset
		ext.w	d1
		add.w	d1,d0
		move.w	d0,y_pos(a1)							; apply offset to new position
		addq.w	#2,d2								; add 2 to index
		dbf	d6,.loop
		moveq	#0,d0								; success

.return
		rts

; =============== S U B R O U T I N E =======================================

CreateChild11_Simple:
		moveq	#0,d2								; same as child routine 6, but creates seperate objects in a list rather than repeating the same object

.skip
		move.w	(a2)+,d6
		bmi.s	.return								; skip if no objects in list

.loop
		bsr.w	Create_New_Object_3
		bne.s	.return								; branch, if there are no free object slots here
		move.w	a0,parent3(a1)							; parent RAM address into parent3
		move.l	mappings(a0),mappings(a1)
		move.w	art_tile(a0),art_tile(a1)					; mappings and VRAM offset copied from parent object
		move.l	(a2)+,address(a1)						; object address
		move.b	d2,subtype(a1)							; index of child object (done sequentially for each object)
		move.w	x_pos(a0),x_pos(a1)
		move.w	y_pos(a0),y_pos(a1)
		addq.w	#2,d2								; add 2 to index
		dbf	d6,.loop
		moveq	#0,d0								; success

.return
		rts

; =============== S U B R O U T I N E =======================================

CreateChild12_Simple:
		moveq	#0,d2								; same as child routine 6, but does not limit children to object slots after the parent

.skip
		move.w	(a2)+,d6
		bmi.s	.return								; skip if no objects in list

.loop
		bsr.w	Create_New_Object
		bne.s	.return								; branch, if there are no free object slots here
		move.w	a0,parent3(a1)							; parent RAM address into parent3
		move.l	mappings(a0),mappings(a1)
		move.w	art_tile(a0),art_tile(a1)					; mappings and VRAM offset copied from parent object
		move.l	(a2)+,address(a1)						; object address
		move.b	d2,subtype(a1)							; index of child object (done sequentially for each object)
		move.w	x_pos(a0),x_pos(a1)
		move.w	y_pos(a0),y_pos(a1)
		addq.w	#2,d2								; add 2 to index
		dbf	d6,.loop
		moveq	#0,d0								; success

.return
		rts
