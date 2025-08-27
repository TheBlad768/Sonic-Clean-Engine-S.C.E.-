; ---------------------------------------------------------------------------
; Level Results (Object)
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Obj_LevelResults:
		music	mus_FadeOut							; fade out music

		; load general art
		QueueKosPlusModule	ArtKosPM_ResultsGeneral, $500

		; load act number art
		moveq	#0,d0
		lea	TitleCardAct_Index(pc),a1
		move.b	(Current_act).w,d0
		add.w	d0,d0								; multiply by 4
		add.w	d0,d0
		movea.l	(a1,d0.w),a1
		move.w	#tiles_to_bytes($566),d2
		jsr	(Queue_KosPlus_Module).w

		; load character name art
		QueueKosPlusModule	ArtKosPM_ResultsSONIC, $548			; select character name to use based on character of course

		; calc time
		moveq	#0,d0
		move.b	d0,(Update_HUD_timer).w						; ensure timer isn't being updated currently
		move.b	(Timer_minute).w,d0
		add.w	d0,d0								; multiply by 60 (1 second)
		add.w	d0,d0
		move.w	d0,d1
		lsl.w	#4,d0
		sub.w	d1,d0
		moveq	#0,d1
		move.b	(Timer_second).w,d1
		add.w	d1,d0
		cmpi.w	#9*60+59,d0
		bne.s	.nottb
		move.w	#10000,(Time_bonus_countdown).w					; if clock is at 9:59 give an automatic 100000 point time bonus
		bra.s	.setrb
; ---------------------------------------------------------------------------

.tbonus	dc.w 5000, 5000, 1000, 500, 400, 300, 100, 10					; time bonus
.tbonus_end
; ---------------------------------------------------------------------------

.nottb

		; using magic numbers is very dangerous
		; if you change the maximum timer, you will most likely have to revert
		; to the standard division by 30

		; divide time by 30
		mulu.w	#ceil(65536,30),d0						; here we will use 'magic number'
		swap	d0								; get the result

		; check
		moveq	#((.tbonus_end-.tbonus)/2)-1,d1
		cmp.w	d1,d0								; if result is above 7, make it 7
		blo.s	.gettb
		move.w	d1,d0

.gettb
		add.w	d0,d0
		move.w	.tbonus(pc,d0.w),(Time_bonus_countdown).w			; get the time bonus

.setrb
		move.w	(Ring_count).w,d0
		add.w	d0,d0								; multiply by 10
		move.w	d0,d1
		add.w	d0,d0
		add.w	d0,d0
		add.w	d1,d0
		move.w	d0,(Ring_bonus_countdown).w					; get the ring bonus
		clr.w	(Total_bonus_countup).w
		move.w	#6*60,objoff_2E(a0)						; wait 6 seconds before starting score counting sequence
		move.w	#12,objoff_30(a0)
		move.l	#.create,address(a0)
		rts
; ---------------------------------------------------------------------------

.create
		tst.w	(KosPlus_modules_left).w
		bne.s	.return								; don't load the objects until the art has been loaded
		jsr	(Create_New_Sprite3).w
		bne.s	.return
		lea	ObjArray_LevResults(pc),a2
		move.w	(a2)+,d1							; make objects

.loop
		move.l	(a2)+,address(a1)
		move.w	(a2)+,objoff_46(a1)
		move.w	(a2)+,x_pos(a1)
		spl	objoff_05(a1)
		move.w	(a2)+,y_pos(a1)
		move.b	(a2)+,mapping_frame(a1)
		move.b	(a2)+,width_pixels(a1)
		move.w	(a2)+,d2
		move.b	d2,objoff_28(a1)
		move.b	#setBit(render_flags.multi_sprite),render_flags(a1)
		move.l	#Map_Results,mappings(a1)
		move.w	#make_art_tile($500,0,0),art_tile(a1)
		move.w	a0,parent2(a1)
		jsr	(Create_New_Sprite4).w
		dbne	d1,.loop

		; next
		move.l	#.wait,address(a0)
		tst.b	(Last_act_end_flag).w
		bne.s	.return								; if this is the last act, branch
		tst.b	(NoBackground_event_flag).w
		bne.s	.return
		st	(Background_event_flag).w					; set the background event flag for the given level (presumably for transitions)

.return
		rts
; ---------------------------------------------------------------------------

.wait
		tst.w	objoff_2E(a0)
		beq.s	.countdown
		subq.w	#1,objoff_2E(a0)

		; check timer
		cmpi.w	#5*60-11,objoff_2E(a0)
		bne.s	.return2							; play after eh, a second or so
		move.b	#30,(Player_1+air_left).w					; reset air p1
		st	(Music_results_flag).w
		music	mus_GotThrough,1						; play level complete theme
; ---------------------------------------------------------------------------

.countdown
		moveq	#0,d0
		moveq	#10,d1
		tst.w	(Time_bonus_countdown).w
		beq.s	.skiptb
		add.w	d1,d0
		sub.w	d1,(Time_bonus_countdown).w					; get 100 points from the time bonus

.skiptb
		tst.w	(Ring_bonus_countdown).w
		beq.s	.skiprb
		add.w	d1,d0
		sub.w	d1,(Ring_bonus_countdown).w					; get 100 points from the ring bonus

.skiprb

		; check buttons
		moveq	#btnABC,d1							; are buttons A, B, or C being pressed?
		and.b	(Ctrl_1_pressed).w,d1
		beq.s	.skipr								; if not, branch

		; skip countdown
		add.w	(Time_bonus_countdown).w,d0
		add.w	(Ring_bonus_countdown).w,d0
		clr.l	(Time_bonus_countdown).w					; clear time and ring bonus countdown

.skipr
		add.w	d0,(Total_bonus_countup).w					; add to total score for level
		tst.w	d0
		beq.s	.finish								; branch once score has finished counting down
		jsr	(HUD_AddToScore).w						; add to actual score
		moveq	#3,d0
		and.w	(Level_frame_counter).w,d0
		bne.s	.return2
		sfx	sfx_Switch,1							; every four frames play the score countdown sound
; ---------------------------------------------------------------------------

.finish
		sfx	sfx_Register							; play the cash register sound
		move.w	#3*60,objoff_2E(a0)						; set wait amount
		move.l	#.wait2,address(a0)

.wait2
		tst.w	objoff_2E(a0)
		beq.s	.endtimer
		subq.w	#1,objoff_2E(a0)

.return2
		rts
; ---------------------------------------------------------------------------

.endtimer
		tst.w	objoff_30(a0)							; wait for title screen objects to disappear
		beq.s	.endr
		addq.w	#1,objoff_32(a0)
		rts
; ---------------------------------------------------------------------------

.endr
		clr.b	(Music_results_flag).w
		clr.b	(Level_results_flag).w
		tst.b	(Last_act_end_flag).w
		bne.s	.skiptc
		clr.b	(Last_star_post_hit).w
		move.l	#Obj_TitleCard,address(a0)					; change current object to title card
		clr.b	routine(a0)
		st	objoff_3E(a0)
		rts
; ---------------------------------------------------------------------------

.skiptc
		st	(End_of_level_flag).w						; stop level results flag and set title card finished flag
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
		moveq	#-56,d2
		add.w	x_pos(a0),d2
		move.w	y_pos(a0),d3
		moveq	#0,d4
		moveq	#7-1,d5

.loop
		move.w	d2,(a1)+							; xpos
		move.w	d3,(a1)								; ypos
		addq.w	#next_subspr-3,a1						; skip
		rol.l	#4,d1
		move.w	d1,d0
		andi.w	#$F,d0
		beq.s	.skip
		moveq	#1,d4

.skip
		add.w	d4,d0
		move.b	d0,(a1)+							; mapping frame
		addq.w	#8,d2
		dbf	d5,.loop
		rts

; =============== S U B R O U T I N E =======================================

LevelResults_MoveElement:
		movea.w	parent2(a0),a1							; a1=parent object
		move.w	objoff_32(a1),d0
		beq.s	.loc_2DE38
		tst.b	render_flags(a0)						; object visible on the screen?
		bmi.s	.loc_2DE20							; if yes, branch
		subq.w	#1,objoff_30(a1)						; if offscreen, subtract from number of elements and delete
		addq.w	#4,sp								; exit from current object
		jmp	(Delete_Current_Sprite).w
; ---------------------------------------------------------------------------

.loc_2DE20
		cmp.b	objoff_28(a0),d0						; level element moving out. Test if value of parent queue matches given queue value
		blo.s	.return
		moveq	#-32,d0								; if so, move out
		tst.b	objoff_05(a0)
		beq.s	.loc_2DE32
		neg.w	d0								; change direction depending on where it came from

.loc_2DE32
		add.w	x_pos(a0),d0
		bra.s	.loc_2DE4A
; ---------------------------------------------------------------------------

.loc_2DE38
		moveq	#16,d1								; level element moving in
		move.w	x_pos(a0),d0
		cmp.w	objoff_46(a0),d0
		beq.s	.loc_2DE4A							; if x position has reached destination, don't do anything else
		blt.s	.loc_2DE48							; see which direction it needs to go
		neg.w	d1

.loc_2DE48
		add.w	d1,d0								; add speed to X amount

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
		blo.s	.found
		subq.w	#3,a1								; back in 3 bytes
		bra.s	.next
; ---------------------------------------------------------------------------

.found
		lea	(DecimalScoreRAM2).w,a2

		; we need to clear the extend bit for abcd
		; otherwise, we will get incorrect results

		; clear x-bit of the ccr (fast)
		sub.w	d1,d1								; d1 is not used here, so we can safely clear it

		; clear x-bit of the ccr (slow)
;		andi	#~( \
;			setBit(ccr_x_bit) \
;		),ccr

	rept 3	; 3 bytes
		abcd	-(a1),-(a2)
	endr

.next
		dbf	d2,.loop
		move.l	(DecimalScoreRAM).w,d1
		rts
; ---------------------------------------------------------------------------

		; decimal (hex) data end
		tribyte $32768, $16384, $8192, $4096, $2048, $1024, $512, $256, $128, $64, $32, $16, 8, 4, 2, 1
.decdata

ObjArray_LevResults: titlecardresultsheader
	titlecardresultsobjdata	Obj_LevResultsCharName, 96, 0-(544+128), 56, $13, 144, 1	; 1
	titlecardresultsobjdata	Obj_LevResultsGeneral, 176, 0-(464+128), 56, $11, 96, 1		; 2
	titlecardresultsobjdata	Obj_LevResultsGeneral, 104, 1000, 76, $10, 224, 3		; 3
	titlecardresultsobjdata	Obj_LevResultsGeneral, 224, 1120, 60, $F, 112, 3		; 4
	titlecardresultsobjdata	Obj_LevResultsGeneral, 64, 1088, 112, $E, 64, 5			; 5 (bonus (time) HUD)
	titlecardresultsobjdata	Obj_LevResultsGeneral, 104, 1128, 112, $C, 96, 5		; 6 (time HUD)
	titlecardresultsobjdata	Obj_LevelResultsTimeBonus, 248, 1272, 112, 1, 128, 5		; 7 (time bonus)
	titlecardresultsobjdata	Obj_LevResultsGeneral, 64, 1152, 128, $D, 64, 7			; 8 (bonus (ring) HUD)
	titlecardresultsobjdata	Obj_LevResultsGeneral, 104, 1192, 128, $C, 96, 7		; 9 (ring HUD)
	titlecardresultsobjdata	Obj_LevelResultsRingBonus, 248, 1336, 128, 1, 128, 7		; 10 (ring bonus)
	titlecardresultsobjdata	Obj_LevResultsGeneral, 84, 1236, 156, $B, 96, 9			; 11 (total HUD)
	titlecardresultsobjdata	Obj_LevelResultsTotal, 248, 1400, 156, 1, 128, 9		; 12 (total number)
ObjArray_LevResults_end
; ---------------------------------------------------------------------------

		include "Objects/Main/Results/Object Data/Map - Results.asm"
