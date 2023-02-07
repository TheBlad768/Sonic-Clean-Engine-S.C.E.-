; ---------------------------------------------------------------------------
; Level Results (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_LevelResults:
		moveq	#0,d0
		move.b	routine(a0),d0
		move.w	LevelResults_Index(pc,d0.w),d1
		jmp	LevelResults_Index(pc,d1.w)
; ---------------------------------------------------------------------------

LevelResults_Index: offsetTable
		offsetTableEntry.w Obj_LevelResultsInit			; 0
		offsetTableEntry.w Obj_LevelResultsCreate		; 2
		offsetTableEntry.w Obj_LevelResultsWait			; 4
		offsetTableEntry.w Obj_LevelResultsWait2		; 6
; ---------------------------------------------------------------------------

Obj_LevelResultsInit:
		music	mus_Fade							; fade out music
		lea	(ArtKosM_ResultsGeneral).l,a1
		move.w	#tiles_to_bytes($480),d2
		jsr	(Queue_Kos_Module).w					; General art
		moveq	#0,d0
		lea	TitleCardAct_Index(pc),a1
		move.b	(Current_act).w,d0
		lsl.w	#2,d0
		movea.l	(a1,d0.w),a1
		move.w	#tiles_to_bytes($4C8),d2
		jsr	(Queue_Kos_Module).w
		lea	(ArtKosM_ResultsSONIC).l,a1				; Select character name to use based on character of course
		move.w	#tiles_to_bytes($4D8),d2
		jsr	(Queue_Kos_Module).w					; Load character name graphics
		clr.b	(Update_HUD_timer).w					; Ensure timer isn't being updated currently
		moveq	#0,d0
		move.b	(Timer_minute).w,d0
		mulu.w	#60,d0
		moveq	#0,d1
		move.b	(Timer_second).w,d1
		add.w	d1,d0
		cmpi.w	#599,d0
		bne.s	loc_2DB90
		move.w	#10000,(Time_bonus_countdown).w		; If clock is at 9:59 give an automatic 100000 point time bonus
		bra.s	loc_2DBA8
; ---------------------------------------------------------------------------

loc_2DB90:
		divu.w	#30,d0		; Divide time by 30
		moveq	#7,d1
		cmp.w	d1,d0		; If result is above 7, make it 7
		blo.s		loc_2DB9C
		move.w	d1,d0

loc_2DB9C:
		add.w	d0,d0
		lea	TimeBonus(pc),a1
		move.w	(a1,d0.w),(Time_bonus_countdown).w	; Get the time bonus

loc_2DBA8:
		move.w	(Ring_count).w,d0
		mulu.w	#10,d0
		move.w	d0,(Ring_bonus_countdown).w			; Get the ring bonus
		clr.w	(Total_bonus_countup).w
		move.w	#6*60,$2E(a0)						; Wait 6 seconds before starting score counting sequence
		move.w	#$C,$30(a0)
		addq.b	#2,routine(a0)
		rts
; ---------------------------------------------------------------------------

Obj_LevelResultsCreate:
		tst.w	(Kos_modules_left).w
		bne.s	locret_2DC34							; Don't load the objects until the art has been loaded
		jsr	(Create_New_Sprite3).w
		bne.s	locret_2DC34
		lea	ObjArray_LevResults(pc),a2
		moveq	#12-1,d1								; Make 12 objects

-		move.l	(a2)+,address(a1)
		move.w	(a2)+,$46(a1)
		move.w	(a2)+,x_pos(a1)
		spl	5(a1)
		move.w	(a2)+,y_pos(a1)
		move.b	(a2)+,mapping_frame(a1)
		move.b	(a2)+,width_pixels(a1)
		move.w	(a2)+,d2
		move.b	d2,$28(a1)
		move.b	#$40,render_flags(a1)
		move.l	#Map_Results,mappings(a1)
		move.w	a0,parent2(a1)
		jsr	(Create_New_Sprite4).w
		dbne	d1,-
		addq.b	#2,routine(a0)
		tst.b	(LastAct_end_flag).w
		bne.s	locret_2DC34							; If this is the last act, branch
		tst.b	(NoBackground_event_flag).w
		bne.s	locret_2DC34
		st	(Background_event_flag).w					; Set the background event flag for the given level (presumably for transitions)

locret_2DC34:
		rts
; ---------------------------------------------------------------------------

Obj_LevelResultsWait:
		tst.w	$2E(a0)
		beq.s	loc_2DC5C
		subq.w	#1,$2E(a0)
		cmpi.w	#$121,$2E(a0)
		bne.s	locret_2DC9E						; Play after eh, a second or so
		move.b	#30,(Player_1+air_left).w				; Reset air
		music	mus_GotThrough,1					; Play level complete theme
; ---------------------------------------------------------------------------

loc_2DC5C:
		moveq	#0,d0
		tst.w	(Time_bonus_countdown).w
		beq.s	loc_2DC6E
		addi.w	#10,d0
		subi.w	#10,(Time_bonus_countdown).w		; Get 100 points from the time bonus

loc_2DC6E:
		tst.w	(Ring_bonus_countdown).w
		beq.s	loc_2DC7E
		addi.w	#10,d0
		subi.w	#10,(Ring_bonus_countdown).w			; Get 100 points from the ring bonus

loc_2DC7E:
		add.w	d0,(Total_bonus_countup).w			; Add to total score for level
		tst.w	d0
		beq.s	loc_2DCA0							; Branch once score has finished counting down
		jsr	(HUD_AddToScore).w						; Add to actual score
		move.w	(Level_frame_counter).w,d0
		andi.w	#3,d0
		bne.s	locret_2DC9E
		sfx	sfx_Switch,1								; Every four frames play the score countdown sound
; ---------------------------------------------------------------------------

loc_2DCA0:
		sfx	sfx_Register								; Play the cash register sound
		move.w	#3*60,$2E(a0)						; Set wait amount
		addq.b	#2,routine(a0)

Obj_LevelResultsWait2:
		tst.w	$2E(a0)
		beq.s	loc_2DCD6
		subq.w	#1,$2E(a0)

locret_2DC9E:
		rts
; ---------------------------------------------------------------------------

loc_2DCD6:
		tst.w	$30(a0)								; Wait for title screen objects to disappear
		beq.s	loc_2DCE2
		addq.w	#1,$32(a0)
		rts
; ---------------------------------------------------------------------------

loc_2DCE2:
		clr.b	(Level_end_flag).w
		tst.b	(LastAct_end_flag).w
		bne.s	+
		clr.b	(Last_star_post_hit).w
		move.l	#Obj_TitleCard,address(a0)			; Change current object to title card
		clr.b	routine(a0)
		st	$3E(a0)
		rts
; ---------------------------------------------------------------------------
+		clr.b	(TitleCard_end_flag).w						; Stop level results flag and set title card finished flag
		st	(LevResults_end_flag).w
		jmp	(Delete_Current_Sprite).w
; ---------------------------------------------------------------------------

Obj_LevResultsCharName:
		move.l	#Obj_LevResultsGeneral,address(a0)

Obj_LevResultsGeneral:
		bsr.s	LevelResults_MoveElement
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

Obj_LevelResultsTimeBonus:
		bsr.s	LevelResults_MoveElement
		move.w	(Time_bonus_countdown).w,d0
		bra.s	loc_2DDBE
; ---------------------------------------------------------------------------

Obj_LevelResultsRingBonus:
		bsr.s	LevelResults_MoveElement
		move.w	(Ring_bonus_countdown).w,d0
		bra.s	loc_2DDBE
; ---------------------------------------------------------------------------

Obj_LevelResultsTotal:
		bsr.s	LevelResults_MoveElement
		move.w	(Total_bonus_countup).w,d0

loc_2DDBE:
		bsr.s	LevResults_DisplayScore
		jmp	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

LevResults_DisplayScore:
		move.w	#7,mainspr_childsprites(a0)
		bsr.w	LevResults_GetDecimalScore
		rol.l	#4,d1
		lea	sub2_x_pos(a0),a1
		move.w	x_pos(a0),d2
		subi.w	#$38,d2
		move.w	y_pos(a0),d3
		moveq	#0,d4
		moveq	#6,d5

-		move.w	d2,(a1)+
		move.w	d3,(a1)+
		addq.w	#1,a1
		rol.l	#4,d1
		move.w	d1,d0
		andi.w	#$F,d0
		beq.s	+
		moveq	#1,d4
+		add.w	d4,d0
		move.b	d0,(a1)+
		addq.w	#8,d2
		dbf	d5,-
		rts

; =============== S U B R O U T I N E =======================================

LevelResults_MoveElement:
		movea.w	parent2(a0),a1
		move.w	$32(a1),d0
		beq.s	loc_2DE38
		tst.b	render_flags(a0)		; Object visible on the screen?
		bmi.s	loc_2DE20		; If yes, branch
		subq.w	#1,$30(a1)		; If offscreen, subtract from number of elements and delete
		addq.w	#4,sp
		jmp	(Delete_Current_Sprite).w
; ---------------------------------------------------------------------------

loc_2DE20:
		cmp.b	$28(a0),d0		; Level element moving out. Test if value of parent queue matches given queue value
		blo.s		locret_2DE4E
		move.w	#-$20,d0		; If so, move out
		tst.b	5(a0)
		beq.s	loc_2DE32
		neg.w	d0				; Change direction depending on where it came from

loc_2DE32:
		add.w	x_pos(a0),d0
		bra.s	loc_2DE4A
; ---------------------------------------------------------------------------

loc_2DE38:
		moveq	#$10,d1			; Level element moving in
		move.w	x_pos(a0),d0
		cmp.w	$46(a0),d0
		beq.s	loc_2DE4A		; If X position has reached destination, don't do anything else
		blt.s		loc_2DE48		; See which direction it needs to go
		neg.w	d1

loc_2DE48:
		add.w	d1,d0			; Add speed to X amount

loc_2DE4A:
		move.w	d0,x_pos(a0)

locret_2DE4E:
		rts

; =============== S U B R O U T I N E =======================================

LevResults_GetDecimalScore:
		clr.l	(DecimalScoreRAM).w
		lea	TimeBonus(pc),a1
		moveq	#$F,d2

loc_2DE5A:
		ror.w	#1,d0
		bcs.s	loc_2DE62
		subq.w	#3,a1
		bra.s	loc_2DE70
; ---------------------------------------------------------------------------

loc_2DE62:
		lea	(DecimalScoreRAM2).w,a2
		addi.w	#0,d0
		abcd	-(a1),-(a2)
		abcd	-(a1),-(a2)
		abcd	-(a1),-(a2)

loc_2DE70:
		dbf	d2,loc_2DE5A
		move.l	(DecimalScoreRAM).w,d1
		rts
; ---------------------------------------------------------------------------
		dc.b 3, $27, $68
		dc.b 1, $63, $84
		dc.b 0, $81, $92
		dc.b 0, $40, $96
		dc.b 0, $20, $48
		dc.b 0, $10, $24
		dc.b 0, 5, $12
		dc.b 0, 2, $56
		dc.b 0, 1, $28
		dc.b 0, 0, $64
		dc.b 0, 0, $32
		dc.b 0, 0, $16
		dc.b 0, 0, 8
		dc.b 0, 0, 4
		dc.b 0, 0, 2
		dc.b 0, 0, 1
TimeBonus:	dc.w 5000, 5000, 1000, 500, 400, 300, 100, 10
ObjArray_LevResults:
; 1
		dc.l Obj_LevResultsCharName		; Object address
		dc.w $E0						; X destination
		dc.w $FDE0						; X position
		dc.w $B8							; Y position
		dc.b $13							; Mapping frame
		dc.b $48							; Width
		dc.w 1							; Place in exit queue
; 2
		dc.l Obj_LevResultsGeneral
		dc.w $130
		dc.w $FE30
		dc.w $B8
		dc.b $11
		dc.b $30
		dc.w 1
; 3
		dc.l Obj_LevResultsGeneral
		dc.w $E8
		dc.w $468
		dc.w $CC
		dc.b $10
		dc.b $70
		dc.w 3
; 4
		dc.l Obj_LevResultsGeneral
		dc.w $160
		dc.w $4E0
		dc.w $BC
		dc.b $F
		dc.b $38
		dc.w 3
; 5
		dc.l Obj_LevResultsGeneral
		dc.w $C0						; Bonus (Time) Hud Sprite X position
		dc.w $4C0
		dc.w $F0							; Bonus (Time) Hud Sprite Y position
		dc.b $E
		dc.b $20
		dc.w 5
; 6
		dc.l Obj_LevResultsGeneral
		dc.w $E8							; Time Hud Sprite X position
		dc.w $4E8
		dc.w $F0							; Time Hud Sprite Y position
		dc.b $C
		dc.b $30
		dc.w 5
; 7
		dc.l Obj_LevelResultsTimeBonus
		dc.w $178						; Time Bonus number X position
		dc.w $578
		dc.w $F0							; Time Bonus number Y position
		dc.b 1
		dc.b $40
		dc.w 5
; 8
		dc.l Obj_LevResultsGeneral
		dc.w $C0						; Bonus (Ring) Hud Sprite X position
		dc.w $500
		dc.w $100						; Bonus (Ring) Hud Sprite Y position
		dc.b $D
		dc.b $20
		dc.w 7
; 9
		dc.l Obj_LevResultsGeneral
		dc.w $E8							; Ring Hud Sprite X position
		dc.w $528
		dc.w $100						; Ring Hud Sprite Y position
		dc.b $C
		dc.b $30
		dc.w 7
; 10
		dc.l Obj_LevelResultsRingBonus
		dc.w $178						; Ring Bonus number X position
		dc.w $5B8
		dc.w $100						; Ring Bonus number Y position
		dc.b 1
		dc.b $40
		dc.w 7
; 11
		dc.l Obj_LevResultsGeneral
		dc.w $D4						; Total Hud Sprite X position
		dc.w $554
		dc.w $11C						; Total Hud Sprite Y position
		dc.b $B
		dc.b $30
		dc.w 9
; 12
		dc.l Obj_LevelResultsTotal
		dc.w $178						; Total number X position
		dc.w $5F8
		dc.w $11C						; Total number Y position
		dc.b 1
		dc.b $40
		dc.w 9
; ---------------------------------------------------------------------------

		include "Objects/Results/Object Data/Map - Results.asm"
