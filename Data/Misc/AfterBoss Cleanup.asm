
; =============== S U B R O U T I N E =======================================

AfterBoss_Cleanup:
		movea.l	(Level_data_addr_RAM.AfterBoss).w,a1
		jmp	(a1)

; =============== S U B R O U T I N E =======================================

AfterBoss_Null:
		rts