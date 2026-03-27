; ---------------------------------------------------------------------------
; Enemy score (Object)
; ---------------------------------------------------------------------------

; dynamic object variables

; =============== S U B R O U T I N E =======================================

Obj_EnemyScore:

		; init
		movem.l	ObjDat_EnemyScore(pc),d0-d3					; copy data to d0-d3
		movem.l	d0-d3,address(a0)						; set data from d0-d3 to current object
		move.w	#-$300,y_vel(a0)

.main
		MoveSprite2YOnly
		addi.w	#$18,y_vel(a0)
		bpl.s	.delete
		jmp	(Draw_Sprite).w
; ---------------------------------------------------------------------------

.delete
		jmp	(Delete_Current_Object).w

; =============== S U B R O U T I N E =======================================

; init
ObjDat_EnemyScore:			subObjMainData Obj_EnemyScore.main, setBit(render_flags.level), 0, 8, 32, 1, ArtTile_StarPost, 0, TRUE, Map_EnemyScore

Child6_EnemyScore:
		dc.w 1-1
		dc.l Obj_EnemyScore
; ---------------------------------------------------------------------------

		; mappings
		include "Objects/Main/Enemy Score/Object Data/Map - Enemy Score.asm"
