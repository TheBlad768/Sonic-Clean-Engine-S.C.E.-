; ---------------------------------------------------------------------------
; Adds a Kosinski Moduled archive to the module queue
; Inputs:
; a1 = address of the archive
; d2 = destination in VRAM
; See http://segaretro.org/Kosinski_compression#Kosinski_Moduled_compression for format description
; Optimized by Flamewing
; See https://github.com/flamewing/mdcomp
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Queue_Kos_Module:
		lea	(Kos_module_queue).w,a2
		tst.l	(a2)	; is the first slot free?
		beq.s	Process_Kos_Module_Queue_Init	; if it is, branch

.findFreeSlot:
		addq.w	#6,a2	; otherwise, check next slot
		tst.l	(a2)
		bne.s	.findFreeSlot
		move.l	a1,(a2)+	; store source address
		move.w	d2,(a2)+	; store destination VRAM address
		rts

; ---------------------------------------------------------------------------
; Adds pattern load requests to the Kosinski Module decompression queue
; Input: d0 = ID of the PLC to load
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

LoadPLC_KosM:
		move.w	(Current_zone_and_act).w,d0
		ror.b	#2,d0
		lsr.w	#4,d0
		lea	(Offs_PLC).l,a5
		adda.w	(a5,d0.w),a5
		bra.s	LoadPLC_Raw_KosM

; ---------------------------------------------------------------------------
; Adds pattern load requests to the Kosinski Module decompression queue
; Input: d0 = ID of the PLC to load
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

LoadPLC2_KosM:
		move.w	(Current_zone_and_act).w,d0
		ror.b	#2,d0
		lsr.w	#4,d0
		lea	(Offs_PLC).l,a5
		adda.w	2(a5,d0.w),a5

LoadPLC_Raw_KosM:
		move.w	(a5)+,d6
		bmi.s	.done

.queuePieces:
		movea.l	(a5)+,a1	; store source address
		move.w	(a5)+,d2	; store destination VRAM address
		bsr.s	Queue_Kos_Module
		dbf	d6,.queuePieces

.done:
		rts

; ---------------------------------------------------------------------------
; Initializes processing of the first module on the queue
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Process_Kos_Module_Queue_Init:
		move.w	(a1)+,d3					; get uncompressed size
		cmpi.w	#$A000,d3
		bne.s	.Gotsize
		move.w	#$8000,d3				; $A000 means $8000 for some reason

.Gotsize:
		lsr.w	#1,d3
		move.w	d3,d0
		rol.w	#5,d0
		andi.w	#$1F,d0					; get number of complete modules
		move.w	d0,(Kos_modules_left).w
		andi.w	#$7FF,d3				; get size of last module in words
		bne.s	.Gotleftover				; branch if it's non-zero
		subq.w	#1,(Kos_modules_left).w	; otherwise decrement the number of modules
		move.w	#$800,d3				; and take the size of the last module to be $800 words

.Gotleftover:
		move.w	d3,(Kos_last_module_size).w
		move.w	d2,(Kos_module_destination).w
		move.l	a1,(Kos_module_queue).w
		addq.w	#1,(Kos_modules_left).w	; store total number of modules
		rts

; ---------------------------------------------------------------------------
; Clears the Kosinski Module decompression queue and its associated variables
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Clear_Kos_Module_Queue:
		clearRAM Kos_decomp_queue_count, Kos_module_queue_end	; Clear the KosM bytes
		rts

; ---------------------------------------------------------------------------
; Processes the first module on the queue
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Process_Kos_Module_Queue:
		tst.w	(Kos_modules_left).w
		beq.s	.Done
		bmi.s	.DecompressionStarted
		cmpi.w	#(Kos_decomp_queue_end-Kos_decomp_queue)/8,(Kos_decomp_queue_count).w
		bhs.s	.Done						; branch if the Kosinski decompression queue is full
		movea.l	(Kos_module_queue).w,a1
		lea	(Kos_decomp_buffer).w,a2
		bsr.w	Queue_Kos					; add current module to decompression queue
		ori.w	#$8000,(Kos_modules_left).w	; and set bit to signify decompression in progress

.Done:
		rts
; ---------------------------------------------------------------------------

.DecompressionStarted:
		tst.w	(Kos_decomp_queue_count).w
		bne.s	.Done					; branch if the decompression isn't complete

		; otherwise, DMA the decompressed data to VRAM
		andi.w	#$7F,(Kos_modules_left).w
		move.w	#$1000/2,d3
		subq.w	#1,(Kos_modules_left).w
		bne.s	.Skip	; branch if it isn't the last module
		move.w	(Kos_last_module_size).w,d3

.Skip:
		move.w	(Kos_module_destination).w,d2
		move.w	d2,d0
		add.w	d3,d0
		add.w	d3,d0
		move.w	d0,(Kos_module_destination).w	; set new destination
		move.l	(Kos_module_queue).w,d0
		move.l	(Kos_decomp_queue).w,d1
		sub.l	d1,d0
		andi.l	#$F,d0
		add.l	d0,d1						; round to the nearest $10 boundary
		move.l	d1,(Kos_module_queue).w		; and set new source
		move.l	#Kos_decomp_buffer>>1,d1
		disableIntsSave
		bsr.w	Add_To_DMA_Queue
		enableIntsSave
		tst.w	(Kos_modules_left).w
		bne.s	.Done						; return if this wasn't the last module
		lea	(Kos_module_queue).w,a0
		lea	(Kos_module_queue+6).w,a1
	rept bytesToXcnt(Kos_module_queue_end-Kos_module_queue,8)
		move.l	(a1)+,(a0)+					; otherwise, shift all entries up
		move.l	(a1)+,(a0)+
	endr
		moveq	#0,d0
		move.l	d0,(a0)+						; and mark the last slot as free
		move.l	d0,(a0)+
		move.l	(Kos_module_queue).w,d0
		beq.s	Queue_Kos.Done				; return if the queue is now empty
		movea.l	d0,a1
		move.w	(Kos_module_destination).w,d2
		bra.w	Process_Kos_Module_Queue_Init

; ---------------------------------------------------------------------------
; Adds Kosinski-compressed data to the decompression queue
; Inputs:
; a1 = compressed data address
; a2 = decompression destination in RAM
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Queue_Kos:
		move.w	(Kos_decomp_queue_count).w,d0
		lsl.w	#3,d0
		lea	(Kos_decomp_queue).w,a3
		move.l	a1,(a3,d0.w)			; store source
		move.l	a2,4(a3,d0.w)			; store destination
		addq.w	#1,(Kos_decomp_queue_count).w

.Done:
		rts

; ---------------------------------------------------------------------------
; Checks if V-int occured in the middle of Kosinski queue processing
; and stores the location from which processing is to resume if it did
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Set_Kos_Bookmark:
		tst.w	(Kos_decomp_queue_count).w
		bpl.s	.Done							; branch if a decompression wasn't in progress
		move.l	$42(sp),d0						; check address V-int is supposed to rte to
		cmpi.l	#Process_Kos_Queue.Main,d0
		blo.s		.Done
		cmpi.l	#Process_Kos_Queue.Done,d0
		bhs.s	.Done
		move.l	d0,(Kos_decomp_bookmark).w
		move.l	#Backup_Kos_Registers,$42(sp)	; force V-int to rte here instead if needed

.Done:
		rts

; ---------------------------------------------------------------------------
; Processes the first entry in the Kosinski decompression queue
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Process_Kos_Queue:
		tst.w	(Kos_decomp_queue_count).w
		beq.s	Set_Kos_Bookmark.Done
		bpl.s	.Main	; branch if a decompression was interrupted by V-int
		movem.w	(Kos_decomp_stored_registers).w,d0-d6
		movem.l	(Kos_decomp_stored_registers+2*7).w,a0-a1/a5
		move.l	(Kos_decomp_bookmark).w,-(sp)
		move.w	(Kos_decomp_stored_SR).w,-(sp)
		moveq	#(1<<_Kos_LoopUnroll)-1,d7
	if _Kos_UseLUT==1
		lea	KosDec_ByteMap(pc),a4		; Load LUT pointer.
	endif
		rte
; ---------------------------------------------------------------------------

.Main:
		ori.w	#$8000,(Kos_decomp_queue_count).w	; set sign bit to signify decompression in progress
		movea.l	(Kos_decomp_queue).w,a0
		movea.l	(Kos_decomp_destination).w,a1
		include "Data/Decompression/Kosinski Internal.asm"
		move.l	a0,(Kos_decomp_queue).w
		move.l	a1,(Kos_decomp_destination).w
		andi.w	#$7FFF,(Kos_decomp_queue_count).w	; clear decompression in progress bit
		subq.w	#1,(Kos_decomp_queue_count).w
		beq.s	.Done								; branch if there aren't any entries remaining in the queue
		lea	(Kos_decomp_queue).w,a0
		lea	(Kos_decomp_queue+8).w,a1				; otherwise, shift all entries up
	rept bytesToXcnt(Kos_decomp_queue_end-Kos_decomp_queue,8)
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
	endr

.Done:
		rts
; ---------------------------------------------------------------------------

Backup_Kos_Registers:
		move	sr,(Kos_decomp_stored_SR).w
		movem.w	d0-d6,(Kos_decomp_stored_registers).w
		movem.l	a0-a1/a5,(Kos_decomp_stored_registers+2*7).w
		rts
