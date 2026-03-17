; ---------------------------------------------------------------------------
; Simple horizontal deformation
; Inputs:
; a2 = config: buffer, initial pixel, velocity, deformation size
; a3 = deformation table
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

HScroll_Deform:
		lea	(H_scroll_table).w,a3						; load scroll table

.main
		move.w	(a2)+,d6							; get list of deformation

.next
		movem.w	(a2)+,d2/d5/a1							; get velocity parameter, deformation size, deformation buffer
		asl.l	#8,d2								; shift velocity to line up with the middle 16 bits of the 32-bit position

.loop
		add.l	d2,(a3)								; add velocity to deformation table
		move.w	(a3),(a1)							; set velocity from deformation table to deformation buffer
		addq.w	#4,a1								; next deformation line
		addq.w	#4,a3								; next deformation table
		dbf	d5,.loop
		dbf	d6,.next
		rts

; ---------------------------------------------------------------------------
; Simple vertical deformation
; Inputs:
; a1 = deformation table
; a2 = config: velocity
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

VScroll_Deform:
		disableIntsSave
		lea	(VDP_data_port).l,a6						; load VDP data address to a6
		lea	VDP_control_port-VDP_data_port(a6),a5				; load VDP control address to a5
		move.l	#vdpComm(0,VSRAM,WRITE),VDP_control_port-VDP_control_port(a5)
		moveq	#bytesToXcnt((320*2),16),d6

.loop
		move.w	(a2)+,d2							; get velocity parameter
		ext.l	d2
		asl.l	#8,d2								; shift velocity to line up with the middle 16 bits of the 32-bit position
		add.l	d2,(a1)								; add velocity to deformation table
		move.w	(a1),VDP_data_port-VDP_data_port(a6)				; set velocity from deformation table to deformation buffer
		addq.w	#4,a1
		dbf	d6,.loop

		; exit
		enableIntsSave
		rts

; ---------------------------------------------------------------------------
; Plain horizontal deformation
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

PlainDeformation:
		lea	(H_scroll_buffer).w,a1
		move.w	(Camera_X_pos_copy).w,d0					; get horizontal foreground values to d0
		neg.w	d0								; set foreground values to negative
		swap	d0								; word to long
		move.w	(Camera_X_pos_BG_copy).w,d0					; get horizontal background values to d0
		neg.w	d0								; set background values to negative
		moveq	#bytesToXcnt(screen_height,8),d1

.loop

	rept 8
		move.l	d0,(a1)+
	endr

		dbf	d1,.loop
		rts

; ---------------------------------------------------------------------------
; Plain horizontal deformation (flipped)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

PlainDeformation_Flipped:
		lea	(H_scroll_buffer).w,a1
		move.w	(Camera_X_pos_BG_copy).w,d0					; get horizontal background values to d0
		neg.w	d0								; set background values to negative
		swap	d0								; word to long
		move.w	(Camera_X_pos_copy).w,d0					; get horizontal foreground values to d0
		neg.w	d0								; set foreground values to negative
		moveq	#bytesToXcnt(screen_height,8),d1

.loop

	rept 8
		move.l	d0,(a1)+
	endr

		dbf	d1,.loop
		rts

; ---------------------------------------------------------------------------
; Foreground horizontal loop scrolling
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

FGScroll_Deformation:
		lea	(Camera_H_scroll_shift).w,a1

.main
		move.w	(a1)+,d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,(a1)

.scroll
		move.w	(a1),d0
		neg.w	d0
		lea	(H_scroll_buffer).w,a1
		moveq	#bytesToXcnt(screen_height,8),d1

.loop

	rept 8
		move.w	(a1),d2
		add.w	d0,d2
		move.w	d2,(a1)
		addq.w	#4,a1								; skip foreground and background
	endr

		dbf	d1,.loop
		rts

; ---------------------------------------------------------------------------
; Background horizontal deformation with foreground fix for move camera
; ---------------------------------------------------------------------------
;
; Input:
; a4 = deform array table
; a5 = horizontal background scroll table buffer

; =============== S U B R O U T I N E =======================================

ApplyDeformation:
		move.w	#screen_height-1,d1

ApplyDeformation3:
		lea	(H_scroll_buffer).w,a1
		move.w	(Camera_Y_pos_BG_copy).w,d0
		move.w	(Camera_X_pos_copy).w,d3

ApplyDeformation2:

.process_block

		; get
		move.w	(a4)+,d2
		smi	d4								; if minus, set flag (linear)
		andi.w	#$7FFF,d2							; clear linear flag bit

		; check
		sub.w	d2,d0
		bmi.s	.block_visible
		addq.w	#2,a5								; next table buffer

		; check linear flag
		tst.b	d4								; is linear flag set?
		beq.s	.process_block							; if not, branch
		subq.w	#2,a5								; prev table buffer
		add.w	d2,d2								; multiply by 2
		adda.w	d2,a5
		bra.s	.process_block
; ---------------------------------------------------------------------------

.block_visible

		; check linear flag
		tst.b	d4								; is linear flag set?
		beq.s	.calc_height							; if not, branch
		add.w	d0,d2
		add.w	d2,d2								; multiply by 2
		adda.w	d2,a5

.calc_height
		neg.w	d0
		move.w	d1,d2
		sub.w	d0,d2
		bhs.s	.set_fg
		move.w	d1,d0
		addq.w	#1,d0

.set_fg
		neg.w	d3								; set foreground values to negative
		swap	d3								; word to long

.set_dbf
		subq.w	#1,d0								; fix dbf

.check_mode

		; check linear flag
		tst.b	d4								; is linear flag set?
		beq.s	.get_normal							; if not, branch

		; check even
		lsr.w	d0								; division by 2
		bhs.s	.linear_skip							; branch, if the value is even

		; odd value

.linear_loop
		move.w	(a5)+,d3							; get horizontal background scroll table buffer
		neg.w	d3								; set background values to negative
		move.l	d3,(a1)+

.linear_skip
		move.w	(a5)+,d3							; get horizontal background scroll table buffer
		neg.w	d3								; set background values to negative
		move.l	d3,(a1)+
		dbf	d0,.linear_loop

		; next
		bra.s	.next_check
; ---------------------------------------------------------------------------

.get_normal
		move.w	(a5)+,d3							; get horizontal background scroll table buffer once
		neg.w	d3								; set background values to negative

		; check even
		lsr.w	d0								; division by 2
		bhs.s	.normal_skip							; branch, if the value is even

		; odd value

.normal_loop
		move.l	d3,(a1)+

.normal_skip
		move.l	d3,(a1)+
		dbf	d0,.normal_loop

.next_check
		tst.w	d2
		bmi.s	.return

		; get
		move.w	(a4)+,d0
		smi	d4								; if minus, set flag (linear)
		andi.w	#$7FFF,d0							; clear linear flag bit

		; check
		move.w	d2,d3
		sub.w	d0,d2
		bpl.s	.set_dbf
		move.w	d3,d0
		bra.s	.check_mode
; ---------------------------------------------------------------------------

.return
		rts

; ---------------------------------------------------------------------------
; Background horizontal deformation without foreground fix for move camera
; ---------------------------------------------------------------------------
;
; Input:
; a4 = deform array table
; a5 = horizontal background scroll table buffer

; =============== S U B R O U T I N E =======================================

ApplyBGDeformation:
		move.w	#screen_height-1,d1

ApplyBGDeformation3:
		lea	(H_scroll_buffer).w,a1
		move.w	(Camera_Y_pos_BG_copy).w,d0
		move.w	(Camera_X_pos_copy).w,d3

ApplyBGDeformation2:

.process_block

		; get
		move.w	(a4)+,d2
		smi	d4								; if minus, set flag (linear)
		andi.w	#$7FFF,d2							; clear linear flag bit

		; check
		sub.w	d2,d0
		bmi.s	.block_visible
		addq.w	#2,a5								; next table buffer

		; check linear flag
		tst.b	d4								; is linear flag set?
		beq.s	.process_block							; if not, branch
		subq.w	#2,a5								; prev table buffer
		add.w	d2,d2								; multiply by 2
		adda.w	d2,a5
		bra.s	.process_block
; ---------------------------------------------------------------------------

.block_visible

		; check linear flag
		tst.b	d4								; is linear flag set?
		beq.s	.calc_height							; if not, branch
		add.w	d0,d2
		add.w	d2,d2								; multiply by 2
		adda.w	d2,a5

.calc_height
		neg.w	d0
		move.w	d1,d2
		sub.w	d0,d2
		bhs.s	.set_fg
		move.w	d1,d0
		addq.w	#1,d0

.set_fg
		neg.w	d3								; set foreground values to negative
		swap	d3								; word to long

.set_dbf
		subq.w	#1,d0								; fix dbf

.check_mode

		; check linear flag
		tst.b	d4								; is linear flag set?
		beq.s	.get_normal							; if not, branch

		; check even
		lsr.w	d0								; division by 2
		bhs.s	.linear_skip							; branch, if the value is even

		; odd value

.linear_loop
		move.w	(a5)+,d3							; get horizontal background scroll table buffer
		neg.w	d3								; set background values to negative
		addq.w	#2,a1								; skip foreground
		move.w	d3,(a1)+

.linear_skip
		move.w	(a5)+,d3							; get horizontal background scroll table buffer
		neg.w	d3								; set background values to negative
		addq.w	#2,a1								; skip foreground
		move.w	d3,(a1)+
		dbf	d0,.linear_loop

		; next
		bra.s	.next_check
; ---------------------------------------------------------------------------

.get_normal
		move.w	(a5)+,d3							; get horizontal background scroll table buffer once
		neg.w	d3								; set background values to negative

		; check even
		lsr.w	d0								; division by 2
		bhs.s	.normal_skip							; branch, if the value is even

		; odd value

.normal_loop
		addq.w	#2,a1								; skip foreground
		move.w	d3,(a1)+

.normal_skip
		addq.w	#2,a1								; skip foreground
		move.w	d3,(a1)+
		dbf	d0,.normal_loop

.next_check
		tst.w	d2
		bmi.s	.return

		; get
		move.w	(a4)+,d0
		smi	d4								; if minus, set flag (linear)
		andi.w	#$7FFF,d0							; clear linear flag bit

		; check
		move.w	d2,d3
		sub.w	d0,d2
		bpl.s	.set_dbf
		move.w	d3,d0
		bra.s	.check_mode
; ---------------------------------------------------------------------------

.return
		rts

; ---------------------------------------------------------------------------
; Foreground horizontal deformation with background fix for move camera
; ---------------------------------------------------------------------------
;
; Input:
; a4 = deform array table
; a5 = horizontal foreground scroll table buffer

; =============== S U B R O U T I N E =======================================

ApplyFGDeformation:
		move.w	#screen_height-1,d1

ApplyFGDeformation3:
		lea	(H_scroll_buffer).w,a1
		move.w	(Camera_Y_pos_copy).w,d0
		move.w	(Camera_X_pos_BG_copy).w,d3

ApplyFGDeformation2:

.process_block

		; get
		move.w	(a4)+,d2
		smi	d4								; if minus, set flag (linear)
		andi.w	#$7FFF,d2							; clear linear flag bit

		; check
		sub.w	d2,d0
		bmi.s	.block_visible
		addq.w	#2,a5								; next table buffer

		; check linear flag
		tst.b	d4								; is linear flag set?
		beq.s	.process_block							; if not, branch
		subq.w	#2,a5								; prev table buffer
		add.w	d2,d2								; multiply by 2
		adda.w	d2,a5
		bra.s	.process_block
; ---------------------------------------------------------------------------

.block_visible

		; check linear flag
		tst.b	d4								; is linear flag set?
		beq.s	.calc_height							; if not, branch
		add.w	d0,d2
		add.w	d2,d2								; multiply by 2
		adda.w	d2,a5

.calc_height
		neg.w	d0
		move.w	d1,d2
		sub.w	d0,d2
		bhs.s	.set_bg
		move.w	d1,d0
		addq.w	#1,d0

.set_bg
		neg.w	d3								; set background values to negative

.set_dbf
		subq.w	#1,d0								; fix dbf

.check_mode

		; check linear flag
		tst.b	d4								; is linear flag set?
		beq.s	.get_normal							; if not, branch

		; check even
		lsr.w	d0								; division by 2
		bhs.s	.linear_skip							; branch, if the value is even

		; odd value

.linear_loop
		swap	d3
		move.w	(a5)+,d3							; get horizontal foreground scroll table buffer
		neg.w	d3								; set foreground values to negative
		swap	d3
		move.l	d3,(a1)+

.linear_skip
		swap	d3
		move.w	(a5)+,d3							; get horizontal foreground scroll table buffer
		neg.w	d3								; set foreground values to negative
		swap	d3
		move.l	d3,(a1)+
		dbf	d0,.linear_loop

		; next
		bra.s	.next_check
; ---------------------------------------------------------------------------

.get_normal
		swap	d3
		move.w	(a5)+,d3							; get horizontal foreground scroll table buffer once
		neg.w	d3								; set foreground values to negative
		swap	d3

		; check even
		lsr.w	d0								; division by 2
		bhs.s	.normal_skip							; branch, if the value is even

		; odd value

.normal_loop
		move.l	d3,(a1)+

.normal_skip
		move.l	d3,(a1)+
		dbf	d0,.normal_loop

.next_check
		tst.w	d2
		bmi.s	.return

		; get
		move.w	(a4)+,d0
		smi	d4								; if minus, set flag (linear)
		andi.w	#$7FFF,d0							; clear linear flag bit

		; check
		move.w	d2,d1
		sub.w	d0,d2
		bpl.s	.set_dbf
		move.w	d1,d0
		bra.s	.check_mode
; ---------------------------------------------------------------------------

.return
		rts

; ---------------------------------------------------------------------------
; Foreground and background horizontal linear deformation
; ---------------------------------------------------------------------------
;
; Input:
; a2 = horizontal foreground scroll table buffer (MakeFGDeformArray)
; a4 = deform array table
; a5 = horizontal background scroll table buffer
; a6 = deform delta data

; =============== S U B R O U T I N E =======================================

ApplyFGandBGDeformation3:
		lea	(H_scroll_buffer).w,a1

ApplyFGandBGDeformation:
		swap	d7								; swap data to avoid losing plane base address

ApplyFGandBGDeformation2:

.process_block

		; get
		move.w	(a4)+,d3
		smi	d7								; if minus, set flag (multi)
		andi.w	#$7FFF,d3							; clear multi flag bit

		; check
		sub.w	d3,d0
		bmi.s	.block_visible
		addq.w	#2,a5								; next table buffer

		; check multi flag
		tst.b	d7								; is multi flag set?
		beq.s	.process_block							; if not, branch
		subq.w	#2,a5								; prev table buffer
		add.w	d3,d3								; multiply by 2
		adda.w	d3,a5
		bra.s	.process_block
; ---------------------------------------------------------------------------

.block_visible

		; check multi flag
		tst.b	d7								; is multi flag set?
		beq.s	.calc_height							; if not, branch
		add.w	d0,d3
		add.w	d3,d3								; multiply by 2
		adda.w	d3,a5

.calc_height
		neg.w	d0
		move.w	d1,d4
		sub.w	d0,d4
		bhs.s	.set_dbf
		move.w	d1,d0
		addq.w	#1,d0

.set_dbf
		subq.w	#1,d0								; fix dbf

.check_mode

		; check multi flag
		tst.b	d7								; is multi flag set?
		beq.s	.get_linear_normal						; if not, branch

		; check even
		lsr.w	d0								; division by 2
		bhs.s	.linear_multi_skip						; branch, if the value is even

		; odd value

.linear_multi_loop
		move.w	(a2)+,d6							; get horizontal foreground scroll table buffer
		swap	d6
		move.w	(a5)+,d6							; get horizontal background scroll table buffer
		neg.w	d6								; set background values to negative
		add.w	(a6)+,d6							; add deform delta data
		move.l	d6,(a1)+

.linear_multi_skip
		move.w	(a2)+,d6							; get horizontal foreground scroll table buffer
		swap	d6
		move.w	(a5)+,d6							; get horizontal background scroll table buffer
		neg.w	d6								; set background values to negative
		add.w	(a6)+,d6							; add deform delta data
		move.l	d6,(a1)+
		dbf	d0,.linear_multi_loop

		; next
		bra.s	.next_check
; ---------------------------------------------------------------------------

.get_linear_normal
		move.w	(a5)+,d5							; get horizontal background scroll table buffer once
		neg.w	d5								; set background values to negative

		; check even
		lsr.w	d0								; division by 2
		bhs.s	.linear_normal_skip						; branch, if the value is even

		; odd value

.linear_normal_loop
		move.w	(a2)+,d6							; get horizontal foreground scroll table buffer
		swap	d6
		move.w	(a6)+,d6							; get deform delta data
		add.w	d5,d6								; add horizontal background scroll table buffer
		move.l	d6,(a1)+

.linear_normal_skip
		move.w	(a2)+,d6							; get horizontal foreground scroll table buffer
		swap	d6
		move.w	(a6)+,d6							; get deform delta data
		add.w	d5,d6								; add horizontal background scroll table buffer
		move.l	d6,(a1)+
		dbf	d0,.linear_normal_loop

.next_check
		tst.w	d4
		bmi.s	.exit

		; get
		move.w	(a4)+,d0
		smi	d7								; if minus, set flag (multi)
		andi.w	#$7FFF,d0							; clear multi flag bit

		; check
		move.w	d4,d5
		sub.w	d0,d4
		bpl.s	.set_dbf
		move.w	d5,d0
		bra.s	.check_mode
; ---------------------------------------------------------------------------

.exit
		swap	d7								; swap data back to return plane base address
		rts

; ---------------------------------------------------------------------------
; Make foreground linear deformation
; ---------------------------------------------------------------------------
;
; Input:
; a1 = horizontal foreground scroll table buffer
; a6 = deform delta data
; d1 = screen height - 1
; d6 = camera x pos copy

; =============== S U B R O U T I N E =======================================

MakeFGDeformArray:
		move.w	d1,d0								; copy screen height to d0

		; check even
		lsr.w	d0								; division by 2
		bhs.s	.linear_skip							; branch, if the value is even

		; odd value

.linear_loop
		move.w	(a6)+,d5							; get deform delta
		add.w	d6,d5								; add camera x pos copy
		move.w	d5,(a1)+							; save to scroll table buffer

.linear_skip
		move.w	(a6)+,d5							; get deform delta
		add.w	d6,d5								; add camera x pos copy
		move.w	d5,(a1)+							; save to scroll table buffer
		dbf	d0,.linear_loop
		rts

; ---------------------------------------------------------------------------
; Foreground vertical deformation
; ---------------------------------------------------------------------------
;
; Input:
; a4 = deform array table
; a5 = vertical foreground scroll table buffer

; =============== S U B R O U T I N E =======================================

Apply_FGVScroll:
		lea	(V_scroll_buffer).w,a1

Apply_FGVScroll2:
		move.w	(Camera_Y_pos_BG_copy).w,d1
		move.w	(Camera_X_pos_copy).w,d0
		move.w	d0,d2
		andi.w	#16-1,d2
		beq.s	.check_column
		addi.w	#16,d0

.check_column
		lsr.w	#4,d0								; divide by $10

.find_column
		addq.w	#2,a5								; next
		move.w	(a4)+,d2
		lsr.w	#4,d2								; divide by $10

		; check
		sub.w	d2,d0
		bpl.s	.find_column
		neg.w	d0
		moveq	#(screen_width-16)/16,d2
		sub.w	d0,d2
		bhs.s	.set_dbf
		moveq	#screen_width/16,d0

.set_dbf
		subq.w	#1,d0								; fix dbf

.get_normal
		move.w	(a5)+,d3							; get vertical foreground scroll table buffer

.normal_loop
		move.w	d3,(a1)+							; set to foreground
		move.w	d1,(a1)+							; set to background
		dbf	d0,.normal_loop

		; next check
		tst.w	d2
		bmi.s	.return

		; get
		move.w	(a4)+,d0
		lsr.w	#4,d0								; divide by $10
		move.w	d2,d3

		; check
		sub.w	d0,d2
		bpl.s	.set_dbf
		move.w	d3,d0
		bra.s	.get_normal
; ---------------------------------------------------------------------------

.return
		rts

; ---------------------------------------------------------------------------
; Background vertical deformation
; ---------------------------------------------------------------------------
;
; Input:
; a4 = deform array table
; a5 = vertical background scroll table buffer

; =============== S U B R O U T I N E =======================================

Apply_BGVScroll:
		lea	(V_scroll_buffer).w,a1

Apply_BGVScroll2:
		move.w	(Camera_Y_pos_copy).w,d1
		move.w	(Camera_X_pos_BG_copy).w,d0
		move.w	d0,d2
		andi.w	#16-1,d2
		beq.s	.check_column
		addi.w	#16,d0

.check_column
		lsr.w	#4,d0								; divide by $10

.find_column
		addq.w	#2,a5								; next
		move.w	(a4)+,d2
		lsr.w	#4,d2								; divide by $10

		; check
		sub.w	d2,d0
		bpl.s	.find_column
		neg.w	d0
		moveq	#(screen_width-16)/16,d2
		sub.w	d0,d2
		bhs.s	.set_dbf
		moveq	#screen_width/16,d0

.set_dbf
		subq.w	#1,d0								; fix dbf

.get_normal
		move.w	(a5)+,d3							; get vertical background scroll table buffer

.normal_loop
		move.w	d1,(a1)+							; set to foreground
		move.w	d3,(a1)+							; set to background
		dbf	d0,.normal_loop

		; next check
		tst.w	d2
		bmi.s	.return

		; get
		move.w	(a4)+,d0
		lsr.w	#4,d0								; divide by $10
		move.w	d2,d3

		; check
		sub.w	d0,d2
		bpl.s	.set_dbf
		move.w	d3,d0
		bra.s	.get_normal
; ---------------------------------------------------------------------------

.return
		rts
