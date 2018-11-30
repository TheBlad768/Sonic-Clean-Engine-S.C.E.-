
; =============== S U B R O U T I N E =======================================

AfterBoss_Cleanup:
		moveq	#0,d0
		move.w	(Current_zone_and_act).w,d0
		lsl.b	#6,d0
		lsr.w	#5,d0
		move.w	AfterBoss_Index(pc,d0.w),d0
		jmp	AfterBoss_Index(pc,d0.w)
; ---------------------------------------------------------------------------

AfterBoss_Index: offsetTable
		offsetTableEntry.w AfterBoss_Null	; DEZ1
		offsetTableEntry.w AfterBoss_Null	; DEZ2
		offsetTableEntry.w AfterBoss_Null	; DEZ3
		offsetTableEntry.w AfterBoss_Null	; DEZ4

		zonewarning AfterBoss_Index,(2*4)

; =============== S U B R O U T I N E =======================================

AfterBoss_Null:
		rts