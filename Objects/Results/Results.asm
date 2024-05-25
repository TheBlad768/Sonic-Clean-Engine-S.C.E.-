; ---------------------------------------------------------------------------
; Level Results (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_LevelResults:
		music	mus_FadeOut										; fade out music

		; load general art
		QueueKosModule	ArtKosM_ResultsGeneral, $500

		; load act number art
		moveq	#0,d0
		lea	TitleCardAct_Index(pc),a1
		move.b	(Current_act).w,d0
		add.w	d0,d0
		add.w	d0,d0
		movea.l	(a1,d0.w),a1
		move.w	#tiles_to_bytes($566),d2
		jsr	(Queue_Kos_Module).w

		; load character name art
		QueueKosModule	ArtKosM_ResultsSONIC, $548					; select character name to use based on character of course

		; calc time
		moveq	#0,d0
		move.b	d0,(Update_HUD_timer).w								; ensure timer isn't being updated currently
		move.b	(Timer_minute).w,d0
		add.w	d0,d0												; multiply by 60 (1 second)
		add.w	d0,d0
		move.w	d0,d1
		lsl.w	#4,d0
		sub.w	d1,d0
		moveq	#0,d1
		move.b	(Timer_second).w,d1
		add.w	d1,d0
		cmpi.w	#9*60+59,d0
		bne.s	.nottb
		move.w	#10000,(Time_bonus_countdown).w						; if clock is at 9:59 give an automatic 100000 point time bonus
		bra.s	.setrb
; ---------------------------------------------------------------------------

.nottb
		divu.w	#30,d0												; divide time by 30
		moveq	#7,d1
		cmp.w	d1,d0												; if result is above 7, make it 7
		blo.s		.gettb
		move.w	d1,d0

.gettb
		add.w	d0,d0
		lea	TimeBonus(pc),a1
		move.w	(a1,d0.w),(Time_bonus_countdown).w					; get the time bonus

.setrb
		move.w	(Ring_count).w,d0
		add.w	d0,d0												; multiply by 10
		move.w	d0,d1
		add.w	d0,d0
		add.w	d0,d0
		add.w	d1,d0
		move.w	d0,(Ring_bonus_countdown).w							; get the ring bonus
		clr.w	(Total_bonus_countup).w
		move.w	#6*60,objoff_2E(a0)									; wait 6 seconds before starting score counting sequence
		move.w	#12,objoff_30(a0)
		move.l	#.create,address(a0)
		rts
; ---------------------------------------------------------------------------

.create
		tst.w	(Kos_modules_left).w
		bne.s	.return												; don't load the objects until the art has been loaded
		jsr	(Create_New_Sprite3).w
		bne.s	.return
		lea	ObjArray_LevResults(pc),a2
		move.w	(a2)+,d1												; make objects

.loop
		move.l	(a2)+,address(a1)
		move.w	(a2)+,objoff_46(a1)
		move.w	(a2)+,x_pos(a1)
		spl	5(a1)
		move.w	(a2)+,y_pos(a1)
		move.b	(a2)+,mapping_frame(a1)
		move.b	(a2)+,width_pixels(a1)
		move.w	(a2)+,d2
		move.b	d2,objoff_28(a1)
		move.b	#rfMulti,render_flags(a1)
		move.l	#Map_Results,mappings(a1)
		move.w	#$500,art_tile(a1)
		move.w	a0,parent2(a1)
		jsr	(Create_New_Sprite4).w
		dbne	d1,.loop

		; next
		move.l	#.wait,address(a0)
		tst.b	(Last_act_end_flag).w
		bne.s	.return												; if this is the last act, branch
		tst.b	(NoBackground_event_flag).w
		bne.s	.return
		st	(Background_event_flag).w									; set the background event flag for the given level (presumably for transitions)

.return
		rts
; ---------------------------------------------------------------------------

.wait
		tst.w	objoff_2E(a0)
		beq.s	.countdown
		subq.w	#1,objoff_2E(a0)

		; check timer
		cmpi.w	#5*60-11,objoff_2E(a0)
		bne.s	.return2												; play after eh, a second or so
		move.b	#30,(Player_1+air_left).w								; reset air
		music	mus_GotThrough,1									; play level complete theme
; ---------------------------------------------------------------------------

.countdown
		moveq	#0,d0
		moveq	#10,d1
		tst.w	(Time_bonus_countdown).w
		beq.s	.skiptb
		add.w	d1,d0
		sub.w	d1,(Time_bonus_countdown).w							; get 100 points from the time bonus

.skiptb
		tst.w	(Ring_bonus_countdown).w
		beq.s	.skiprb
		add.w	d1,d0
		sub.w	d1,(Ring_bonus_countdown).w							; get 100 points from the ring bonus

.skiprb
		add.w	d0,(Total_bonus_countup).w							; add to total score for level
		tst.w	d0
		beq.s	.finish												; branch once score has finished counting down
		jsr	(HUD_AddToScore).w										; add to actual score
		moveq	#3,d0
		and.w	(Level_frame_counter).w,d0
		bne.s	.return2
		sfx	sfx_Switch,1												; every four frames play the score countdown sound
; ---------------------------------------------------------------------------

.finish
		sfx	sfx_Register												; play the cash register sound
		move.w	#3*60,objoff_2E(a0)									; set wait amount
		move.l	#.wait2,address(a0)

.wait2
		tst.w	objoff_2E(a0)
		beq.s	.endtimer
		subq.w	#1,objoff_2E(a0)

.return2
		rts
; ---------------------------------------------------------------------------

.endtimer
		tst.w	objoff_30(a0)											; wait for title screen objects to disappear
		beq.s	.endr
		addq.w	#1,objoff_32(a0)
		rts
; ---------------------------------------------------------------------------

.endr
		clr.b	(Level_end_flag).w
		tst.b	(Last_act_end_flag).w
		bne.s	.skiptc
		clr.b	(Last_star_post_hit).w
		move.l	#Obj_TitleCard,address(a0)							; change current object to title card
		clr.b	routine(a0)
		st	objoff_3E(a0)
		rts
; ---------------------------------------------------------------------------

.skiptc
		clr.b	(TitleCard_end_flag).w										; stop level results flag and set title card finished flag
		st	(Results_end_flag).w
		jmp	(Delete_Current_Sprite).w

; =============== S U B R O U T I N E =======================================

Obj_LevResultsCharName:

		; Sonic only
		move.l	#Obj_LevResultsGeneral,address(a0)

; =============== S U B R O U T I N E =======================================

Obj_LevResultsGeneral:
		pea	(Draw_Sprite).w
		bra.s	LevelResults_MoveElement

; =============== S U B R O U T I N E =======================================

Obj_LevelResultsTimeBonus:
		bsr.s	LevelResults_MoveElement
		move.w	(Time_bonus_countdown).w,d0
		bra.s	Obj_LevelResultsTotal.draw

; =============== S U B R O U T I N E =======================================

Obj_LevelResultsRingBonus:
		bsr.s	LevelResults_MoveElement
		move.w	(Ring_bonus_countdown).w,d0
		bra.s	Obj_LevelResultsTotal.draw

; =============== S U B R O U T I N E =======================================

Obj_LevelResultsTotal:
		bsr.s	LevelResults_MoveElement
		move.w	(Total_bonus_countup).w,d0

.draw
		pea	(Draw_Sprite).w

; =============== S U B R O U T I N E =======================================

LevResults_DisplayScore:
		move.w	#7,mainspr_childsprites(a0)
		bsr.s	LevResults_GetDecimalScore
		rol.l	#4,d1
		lea	sub2_x_pos(a0),a1
		move.w	x_pos(a0),d2
		subi.w	#56,d2
		move.w	y_pos(a0),d3
		moveq	#0,d4
		moveq	#7-1,d5

.loop
		move.w	d2,(a1)+												; xpos
		move.w	d3,(a1)+												; ypos
		addq.w	#1,a1												; skip byte
		rol.l	#4,d1
		move.w	d1,d0
		andi.w	#$F,d0
		beq.s	.skip
		moveq	#1,d4

.skip
		add.w	d4,d0
		move.b	d0,(a1)+												; mapping frame
		addq.w	#8,d2
		dbf	d5,.loop
		rts

; =============== S U B R O U T I N E =======================================

LevelResults_MoveElement:
		movea.w	parent2(a0),a1
		move.w	objoff_32(a1),d0
		beq.s	.loc_2DE38
		tst.b	render_flags(a0)											; object visible on the screen?
		bmi.s	.loc_2DE20											; if yes, branch
		subq.w	#1,objoff_30(a1)										; if offscreen, subtract from number of elements and delete
		addq.w	#4,sp												; exit from current object
		jmp	(Delete_Current_Sprite).w
; ---------------------------------------------------------------------------

.loc_2DE20
		cmp.b	objoff_28(a0),d0										; level element moving out. Test if value of parent queue matches given queue value
		blo.s		.return
		moveq	#-$20,d0											; if so, move out
		tst.b	5(a0)
		beq.s	.loc_2DE32
		neg.w	d0													; change direction depending on where it came from

.loc_2DE32
		add.w	x_pos(a0),d0
		bra.s	.loc_2DE4A
; ---------------------------------------------------------------------------

.loc_2DE38
		moveq	#16,d1												; level element moving in
		move.w	x_pos(a0),d0
		cmp.w	objoff_46(a0),d0
		beq.s	.loc_2DE4A											; if x position has reached destination, don't do anything else
		blt.s		.loc_2DE48											; see which direction it needs to go
		neg.w	d1

.loc_2DE48
		add.w	d1,d0												; add speed to X amount

.loc_2DE4A
		move.w	d0,x_pos(a0)

.return
		rts

; =============== S U B R O U T I N E =======================================

LevResults_GetDecimalScore:
		clr.l	(DecimalScoreRAM).w
		lea	.decdata(pc),a1
		moveq	#16-1,d2

.loop
		ror.w	d0
		blo.s		.found
		subq.w	#3,a1												; back in 3 bytes
		bra.s	.next
; ---------------------------------------------------------------------------

.found
		lea	(DecimalScoreRAM2).w,a2

		addi.w	#0,d0												; clear carry bit for extend
;		move	#0,ccr												; "

		abcd	-(a1),-(a2)
		abcd	-(a1),-(a2)
		abcd	-(a1),-(a2)

.next
		dbf	d2,.loop
		move.l	(DecimalScoreRAM).w,d1
		rts
; ---------------------------------------------------------------------------

		; decimal (hex) data end
		tribyte $32768, $16384, $8192, $4096, $2048, $1024, $512, $256, $128, $64, $32, $16, 8, 4, 2, 1
.decdata

TimeBonus:	dc.w 5000, 5000, 1000, 500, 400, 300, 100, 10

ObjArray_LevResults:
		dc.w ((ObjArray_LevResults_end-ObjArray_LevResults)/$E)-1		; count

		; 1
		dc.l Obj_LevResultsCharName									; object address
		dc.w $E0													; x destination
		dc.w $FDE0													; xpos
		dc.w $B8														; ypos
		dc.b $13														; mapping frame
		dc.b $48														; width
		dc.w 1														; place in exit queue

		; 2
		dc.l Obj_LevResultsGeneral										; object address
		dc.w $130													; x destination
		dc.w $FE30													; xpos
		dc.w $B8														; ypos
		dc.b $11														; mapping frame
		dc.b $30														; width
		dc.w 1														; place in exit queue

		; 3
		dc.l Obj_LevResultsGeneral										; object address
		dc.w $E8														; x destination
		dc.w $468													; xpos
		dc.w $CC													; ypos
		dc.b $10														; mapping frame
		dc.b $70														; width
		dc.w 3														; place in exit queue

		; 4
		dc.l Obj_LevResultsGeneral										; object address
		dc.w $160													; x destination
		dc.w $4E0													; xpos
		dc.w $BC													; ypos
		dc.b $F														; mapping frame
		dc.b $38														; width
		dc.w 3														; place in exit queue

		; 5
		dc.l Obj_LevResultsGeneral										; object address
		dc.w $C0													; bonus (time) HUD sprite x position
		dc.w $4C0
		dc.w $F0														; bonus (time) HUD sprite y position
		dc.b $E
		dc.b $20
		dc.w 5

		; 6
		dc.l Obj_LevResultsGeneral
		dc.w $E8														; time HUD sprite x position
		dc.w $4E8
		dc.w $F0														; time HUD sprite y position
		dc.b $C
		dc.b $30
		dc.w 5

		; 7
		dc.l Obj_LevelResultsTimeBonus
		dc.w $178													; time bonus number x position
		dc.w $578
		dc.w $F0														; time bonus number y position
		dc.b 1
		dc.b $40
		dc.w 5

		; 8
		dc.l Obj_LevResultsGeneral
		dc.w $C0													; bonus (ring) HUD sprite x position
		dc.w $500
		dc.w $100													; bonus (ring) HUD sprite y position
		dc.b $D
		dc.b $20
		dc.w 7

		; 9
		dc.l Obj_LevResultsGeneral
		dc.w $E8														; ring HUD sprite x position
		dc.w $528
		dc.w $100													; ring HUD sprite y position
		dc.b $C
		dc.b $30
		dc.w 7

		; 10
		dc.l Obj_LevelResultsRingBonus
		dc.w $178													; ring bonus number x position
		dc.w $5B8
		dc.w $100													; ring bonus number y position
		dc.b 1
		dc.b $40
		dc.w 7

		; 11
		dc.l Obj_LevResultsGeneral
		dc.w $D4													; total HUD sprite x position
		dc.w $554
		dc.w $11C													; total HUD sprite y position
		dc.b $B
		dc.b $30
		dc.w 9

		; 12
		dc.l Obj_LevelResultsTotal
		dc.w $178													; total number x position
		dc.w $5F8
		dc.w $11C													; total number y position
		dc.b 1
		dc.b $40
		dc.w 9

ObjArray_LevResults_end
; ---------------------------------------------------------------------------

		include "Objects/Results/Object Data/Map - Results.asm"
