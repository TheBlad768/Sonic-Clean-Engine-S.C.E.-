
; =============== S U B R O U T I N E =======================================

CreateChild1_Normal:
		moveq	#0,d2						; Includes positional offset data
		move.w	(a2)+,d6

.loop
		bsr.w	Create_New_Sprite3
		bne.s	.notfree
		move.w	a0,parent3(a1)				; Parent RAM address into $46
		move.l	mappings(a0),mappings(a1)
		move.w	art_tile(a0),art_tile(a1)		; Mappings and VRAM offset copied from parent object
		move.l	(a2)+,address(a1)				; Object address
		move.b	d2,subtype(a1)				; Index of child object (done sequentially for each object)
		move.w	x_pos(a0),d0
		move.b	(a2)+,d1						; X Positional offset
		move.b	d1,child_dx(a1)				; $42 has the X offset
		ext.w	d1
		add.w	d1,d0
		move.w	d0,x_pos(a1)					; Apply offset to new position
		move.w	y_pos(a0),d0
		move.b	(a2)+,d1						; Same as above for Y
		move.b	d1,child_dy(a1)				; $43 has the Y offset
		ext.w	d1
		add.w	d1,d0
		move.w	d0,y_pos(a1)					; Apply offset
		addq.w	#2,d2						; Add 2 to index
		dbf	d6,.loop
		moveq	#0,d0

.notfree
		rts

; =============== S U B R O U T I N E =======================================

CreateChild2_Complex:
		moveq	#0,d2						; Includes positional offset data and velocity and CHECKLATER
		move.w	(a2)+,d6

.loop
		bsr.w	Create_New_Sprite3
		bne.s	.notfree
		move.w	a0,parent3(a1)				; Parent RAM address into $46
		move.l	mappings(a0),mappings(a1)
		move.w	art_tile(a0),art_tile(a1)		; Mappings and VRAM offset copied from parent object
		move.l	(a2)+,address(a1)
		move.l	(a2)+,$3E(a1)
		move.l	(a2)+,$30(a1)
		move.l	(a2)+,$34(a1)
		move.b	d2,subtype(a1)
		move.w	x_pos(a0),d0
		move.b	(a2)+,d1
		move.b	d1,child_dx(a1)				; See offset information above
		ext.w	d1
		add.w	d1,d0
		move.w	d0,x_pos(a1)
		move.w	y_pos(a0),d0
		move.b	(a2)+,d1
		move.b	d1,child_dy(a1)				; See offset information above
		ext.w	d1
		add.w	d1,d0
		move.w	d0,y_pos(a1)
		move.l	(a2)+,x_vel(a1)				; XY Velocity
		addq.w	#2,d2
		dbf	d6,.loop
		moveq	#0,d0

.notfree
		rts

; =============== S U B R O U T I N E =======================================

CreateChild3_NormalRepeated:
		moveq	#0,d2						; Same as Child creation routine 1, except it repeats one object several times rather than different objects sequentially
		move.w	(a2)+,d6

.loop
		movea.l	a2,a3						; Save ROM address
		bsr.w	Create_New_Sprite3
		bne.s	.notfree
		move.w	a0,parent3(a1)
		move.l	mappings(a0),mappings(a1)
		move.w	art_tile(a0),art_tile(a1)
		move.l	(a3)+,address(a1)
		move.b	d2,subtype(a1)
		move.w	x_pos(a0),d0
		move.b	(a3)+,d1
		move.b	d1,child_dx(a1)
		ext.w	d1
		add.w	d1,d0
		move.w	d0,x_pos(a1)
		move.w	y_pos(a0),d0
		move.b	(a3)+,d1
		move.b	d1,child_dy(a1)
		ext.w	d1
		add.w	d1,d0
		move.w	d0,y_pos(a1)
		addq.w	#2,d2
		dbf	d6,.loop
		moveq	#0,d0

.notfree
		rts

; =============== S U B R O U T I N E =======================================

CreateChild4_LinkListRepeated:
		movea.w	a0,a3						; Creates a linked object list. Previous object address is in $46, while next object in list is at $44
		moveq	#0,d2
		move.w	(a2)+,d6

.loop
		bsr.w	Create_New_Sprite3
		bne.s	.notfree
		move.w	a3,parent3(a1)
		move.w	a1,$44(a3)
		movea.w	a1,a3
		move.l	mappings(a0),mappings(a1)
		move.w	art_tile(a0),art_tile(a1)
		move.l	(a2),address(a1)
		move.b	d2,subtype(a1)
		move.w	x_pos(a0),x_pos(a1)
		move.w	y_pos(a0),y_pos(a1)
		addq.w	#2,d2
		dbf	d6,.loop
		moveq	#0,d0

.notfree
		rts

; =============== S U B R O U T I N E =======================================

CreateChild5_ComplexAdjusted:
		moveq	#0,d2						; Same as child routine 2, but adjusts both X position and X velocity based on parent object's orientation
		move.w	(a2)+,d6

.loop
		bsr.w	Create_New_Sprite3
		bne.s	.notfree
		move.w	a0,parent3(a1)
		move.l	mappings(a0),mappings(a1)
		move.w	art_tile(a0),art_tile(a1)
		move.l	(a2)+,address(a1)
		move.l	(a2)+,$3E(a1)
		move.l	(a2)+,$30(a1)
		move.l	(a2)+,$34(a1)
		move.b	d2,subtype(a1)
		move.w	x_pos(a0),d0
		move.b	(a2)+,d1
		move.b	d1,child_dx(a1)
		ext.w	d1
		btst	#0,render_flags(a0)
		beq.s	.notflipxpos
		neg.w	d1

.notflipxpos
		add.w	d1,d0
		move.w	d0,x_pos(a1)
		move.w	y_pos(a0),d0
		move.b	(a2)+,d1
		move.b	d1,child_dy(a1)
		ext.w	d1
		add.w	d1,d0
		move.w	d0,y_pos(a1)
		move.w	(a2)+,d1
		btst	#0,render_flags(a0)
		beq.s	.notflipxvel
		neg.w	d1

.notflipxvel
		move.w	d1,x_vel(a1)
		move.w	(a2)+,y_vel(a1)
		addq.w	#2,d2
		dbf	d6,.loop
		moveq	#0,d0

.notfree
		rts

; =============== S U B R O U T I N E =======================================

CreateChild6_Simple:
		moveq	#0,d2						; Simple child creation routine, merely creates x number of the same object at the parent's position
		move.w	(a2)+,d6

.loop
		bsr.w	Create_New_Sprite3
		bne.s	.notfree
		move.w	a0,parent3(a1)
		move.l	mappings(a0),mappings(a1)
		move.w	art_tile(a0),art_tile(a1)
		move.l	(a2),address(a1)
		move.b	d2,subtype(a1)
		move.w	x_pos(a0),x_pos(a1)
		move.w	y_pos(a0),y_pos(a1)
		addq.w	#2,d2
		dbf	d6,.loop
		moveq	#0,d0

.notfree
		rts

; =============== S U B R O U T I N E =======================================

CreateChild7_Normal2:
		moveq	#0,d2						; Same as child routine 1, but does not limit children to object slots after the parent
		move.w	(a2)+,d6

.loop
		bsr.w	Create_New_Sprite
		bne.s	.notfree
		move.w	a0,parent3(a1)
		move.l	mappings(a0),mappings(a1)
		move.w	art_tile(a0),art_tile(a1)
		move.l	(a2)+,address(a1)
		move.b	d2,subtype(a1)
		move.w	x_pos(a0),d0
		move.b	(a2)+,d1
		move.b	d1,child_dx(a1)
		ext.w	d1
		add.w	d1,d0
		move.w	d0,x_pos(a1)
		move.w	y_pos(a0),d0
		move.b	(a2)+,d1
		move.b	d1,child_dy(a1)
		ext.w	d1
		add.w	d1,d0
		move.w	d0,y_pos(a1)
		addq.w	#2,d2
		dbf	d6,.loop
		moveq	#0,d0

.notfree
		rts

; =============== S U B R O U T I N E =======================================

CreateChild8_TreeListRepeated:
		movea.w	a0,a3						; Creates a linked object list like routine 4, but they only chain themselves one way. All maintain the calling object as their parent
		moveq	#0,d2
		move.w	(a2)+,d6

.loop
		bsr.w	Create_New_Sprite3
		bne.s	.notfree
		move.w	a3,parent3(a1)
		move.w	a0,$44(a1)
		movea.w	a1,a3
		move.l	mappings(a0),mappings(a1)
		move.w	art_tile(a0),art_tile(a1)
		move.l	(a2),address(a1)
		move.b	d2,subtype(a1)
		move.w	x_pos(a0),x_pos(a1)
		move.w	y_pos(a0),y_pos(a1)
		addq.w	#2,d2
		dbf	d6,.loop
		moveq	#0,d0

.notfree
		rts

; =============== S U B R O U T I N E =======================================

CreateChild9_TreeList:
		movea.w	a0,a3						; Same as routine 8, but creates seperate objects in a list rather than repeating the same object
		moveq	#0,d2
		move.w	(a2)+,d6

.loop
		bsr.w	Create_New_Sprite3
		bne.s	.notfree
		move.w	a3,parent3(a1)
		move.w	a0,$44(a1)
		movea.w	a1,a3
		move.l	mappings(a0),mappings(a1)
		move.w	art_tile(a0),art_tile(a1)
		move.l	(a2)+,address(a1)
		move.b	d2,subtype(a1)
		move.w	x_pos(a0),x_pos(a1)
		move.w	y_pos(a0),y_pos(a1)
		addq.w	#2,d2
		dbf	d6,.loop
		moveq	#0,d0

.notfree
		rts

; =============== S U B R O U T I N E =======================================

CreateChild10_NormalAdjusted:
		moveq	#0,d2						; Same as child routine 1, but adjusts X position based on parent object's orientation
		move.w	(a2)+,d6

.loop
		bsr.w	Create_New_Sprite3
		bne.s	.notfree
		move.w	a0,parent3(a1)
		move.l	mappings(a0),mappings(a1)
		move.w	art_tile(a0),art_tile(a1)
		move.l	(a2)+,address(a1)
		move.b	d2,subtype(a1)
		move.w	x_pos(a0),d0
		move.b	(a2)+,d1
		btst	#0,render_flags(a0)
		beq.s	.notflipx
		bset	#0,render_flags(a1)
		neg.b	d1

.notflipx
		move.b	d1,child_dx(a1)
		ext.w	d1
		add.w	d1,d0
		move.w	d0,x_pos(a1)
		move.w	y_pos(a0),d0
		move.b	(a2)+,d1
		move.b	d1,child_dy(a1)
		ext.w	d1
		add.w	d1,d0
		move.w	d0,y_pos(a1)
		addq.w	#2,d2
		dbf	d6,.loop
		moveq	#0,d0

.notfree
		rts
