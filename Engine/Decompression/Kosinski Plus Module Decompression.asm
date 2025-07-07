; ---------------------------------------------------------------------------
; Adds Kosinski Plus-compressed data to the decompression queue
;
; Inputs:
; a1 = compressed data address
; a2 = decompression destination in RAM
; See https://segaretro.org/Kosinski_compression for format description
; Optimized by Flamewing
; See https://github.com/flamewing/mdcomp
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Queue_KosPlus:
		move.w	(KosPlus_decomp_queue_count).w,d0
		lsl.w	#3,d0											; multiply by 8
		lea	(KosPlus_decomp_queue).w,a3
		move.l	a1,(a3,d0.w)										; store source
		move.l	a2,4(a3,d0.w)										; store destination
		addq.w	#1,(KosPlus_decomp_queue_count).w
		rts

; ---------------------------------------------------------------------------
; Adds pattern load requests to the Kosinski Plus decompression queue
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

LoadPLC_Raw_KosPlus:
		move.w	(a5)+,d6
		bmi.s	.Done

.queuePieces
		movea.l	(a5)+,a1										; store source address
		movea.l	(a5)+,a2										; store destination RAM address
		bsr.s	Queue_KosPlus
		dbf	d6,.queuePieces

.Done
		rts

; ---------------------------------------------------------------------------
; Processes the first module on the queue
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Process_KosPlus_Module_Queue:
		tst.w	(KosPlus_modules_left).w
		beq.s	.Done
		bmi.s	.DecompressionStarted
		cmpi.w	#(KosPlus_decomp_queue_end-KosPlus_decomp_queue)/8,(KosPlus_decomp_queue_count).w
		bhs.s	.Done											; branch if the Kosinski Plus decompression queue is full
		movea.l	(KosPlus_module_queue).w,a1
		lea	(KosPlus_decomp_buffer).w,a2
		bsr.s	Queue_KosPlus										; add current module to decompression queue
		ori.w	#$8000,(KosPlus_modules_left).w								; and set bit to signify decompression in progress

.Done
		rts
; ---------------------------------------------------------------------------

.DecompressionStarted
		tst.w	(KosPlus_decomp_queue_count).w
		bne.s	.Done											; branch if the decompression isn't complete

		; otherwise, DMA the decompressed data to VRAM
		andi.w	#$7F,(KosPlus_modules_left).w
		move.w	#$1000/2,d3
		subq.w	#1,(KosPlus_modules_left).w
		bne.s	.Skip											; branch if it isn't the last module
		move.w	(KosPlus_last_module_size).w,d3

.Skip
		move.w	(KosPlus_module_destination).w,d2
		move.w	d2,d0
		add.w	d3,d0
		add.w	d3,d0
		move.w	d0,(KosPlus_module_destination).w							; set new destination
		move.l	(KosPlus_module_queue).w,d0
		move.l	(KosPlus_decomp_queue).w,(KosPlus_module_queue).w					; set new source
		move.l	#dmaSource(KosPlus_decomp_buffer),d1
		disableIntsSave
		bsr.w	Add_To_DMA_Queue
		enableIntsSave
		tst.w	(KosPlus_modules_left).w
		bne.s	.Done											; return if this wasn't the last module
		lea	(KosPlus_module_queue).w,a0
		lea	(KosPlus_module_queue+6).w,a1

	rept bytesToXcnt(KosPlus_module_queue_end-KosPlus_module_queue,8)
		move.l	(a1)+,(a0)+										; otherwise, shift all entries up
		move.l	(a1)+,(a0)+
	endr

	if bytesToXcnt(KosPlus_module_queue_end-KosPlus_module_queue,8)&2
		move.w	(a1)+,(a0)+
	endif

		; clear last slot
		moveq	#0,d0
		move.l	d0,(a0)+										; and mark the last slot as free
		move.w	d0,(a0)+
		move.l	(KosPlus_module_queue).w,d0
		beq.s	LoadPLC_Raw_KosPlusM.Done								; return if the queue is now empty
		movea.l	d0,a1
		move.w	(KosPlus_module_destination).w,d2
		bra.s	Process_KosPlus_Module_Queue_Init

; ---------------------------------------------------------------------------
; Adds pattern load requests to the Kosinski Plus Module decompression queue
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

LoadPLC_Raw_KosPlusM:
		move.w	(a5)+,d6
		bmi.s	.Done

.queuePieces
		movea.l	(a5)+,a1										; store source address
		move.w	(a5)+,d2										; store destination VRAM address
		bsr.s	Queue_KosPlus_Module
		dbf	d6,.queuePieces

.Done
		rts

; ---------------------------------------------------------------------------
; Adds a Kosinski Plus Moduled archive to the module queue
;
; Inputs:
; a1 = address of the archive
; d2 = destination in VRAM
; See https://segaretro.org/Kosinski_compression#Kosinski_Moduled_compression for format description
; Optimized by Flamewing
; See https://github.com/flamewing/mdcomp
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Queue_KosPlus_Module:
		lea	(KosPlus_module_queue).w,a2
		tst.l	(a2)											; is the first slot free?
		beq.s	Process_KosPlus_Module_Queue_Init							; if it is, branch

.findFreeSlot
		addq.w	#6,a2											; otherwise, check next slot
		tst.l	(a2)
		bne.s	.findFreeSlot
		move.l	a1,(a2)+										; store source address
		move.w	d2,(a2)+										; store destination VRAM address
		rts

; ---------------------------------------------------------------------------
; Initializes processing of the first module on the queue
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Process_KosPlus_Module_Queue_Init:
		move.w	(a1)+,d3										; get uncompressed size
		cmpi.w	#$A000,d3
		bne.s	.Gotsize
		move.w	#$8000,d3										; $A000 means $8000 for some reason

.Gotsize
		lsr.w	d3
		move.w	d3,d0
		rol.w	#5,d0
		andi.w	#$1F,d0											; get number of complete modules
		move.w	d0,(KosPlus_modules_left).w
		andi.w	#$7FF,d3										; get size of last module in words
		bne.s	.Gotleftover										; branch if it's non-zero
		subq.w	#1,(KosPlus_modules_left).w								; otherwise decrement the number of modules
		move.w	#$1000/2,d3										; and take the size of the last module to be $800 words

.Gotleftover
		move.w	d3,(KosPlus_last_module_size).w
		move.w	d2,(KosPlus_module_destination).w
		move.l	a1,(KosPlus_module_queue).w
		addq.w	#1,(KosPlus_modules_left).w								; store total number of modules
		rts

; ---------------------------------------------------------------------------
; Checks if V-int occured in the middle of Kosinski Plus queue processing
; and stores the location from which processing is to resume if it did
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Set_KosPlus_Bookmark:
		tst.w	(KosPlus_decomp_queue_count).w
		bpl.s	.Done											; branch if a decompression wasn't in progress
		move.l	$42(sp),d0										; check address V-int is supposed to rte to
		cmpi.l	#Process_KosPlus_Queue.Main,d0
		blo.s	.Done
		cmpi.l	#Process_KosPlus_Queue.Done,d0
		bhs.s	.Done
		move.l	d0,(KosPlus_decomp_bookmark).w
		move.l	#Backup_KosPlus_Registers,$42(sp)							; force V-int to rte here instead if needed

.Done
		rts

; ---------------------------------------------------------------------------
; Processes the first entry in the Kosinski Plus decompression queue
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Process_KosPlus_Queue:
		tst.w	(KosPlus_decomp_queue_count).w
		beq.s	Set_KosPlus_Bookmark.Done
		bpl.s	.Main											; branch if a decompression was interrupted by V-int
		movem.w	(KosPlus_decomp_stored_registers).w,d0/d2/d4-d7
		movem.l	(KosPlus_decomp_stored_registers+(2*6)).w,a0-a1/a5
		move.l	(KosPlus_decomp_bookmark).w,-(sp)
		move.w	(KosPlus_decomp_stored_SR).w,-(sp)
		rte
; ---------------------------------------------------------------------------

.Main
		ori.w	#$8000,(KosPlus_decomp_queue_count).w							; set sign bit to signify decompression in progress
		movea.l	(KosPlus_decomp_queue).w,a0
		movea.l	(KosPlus_decomp_destination).w,a1
		include "Engine/Decompression/Kosinski Plus Internal.asm"
		move.l	a0,(KosPlus_decomp_queue).w
		move.l	a1,(KosPlus_decomp_destination).w
		andi.w	#$7FFF,(KosPlus_decomp_queue_count).w							; clear decompression in progress bit
		subq.w	#1,(KosPlus_decomp_queue_count).w
		beq.s	.Done											; branch if there aren't any entries remaining in the queue
		lea	(KosPlus_decomp_queue).w,a0
		lea	(KosPlus_decomp_queue+8).w,a1

	rept bytesToXcnt(KosPlus_decomp_queue_end-KosPlus_decomp_queue,8)
		move.l	(a1)+,(a0)+										; otherwise, shift all entries up
		move.l	(a1)+,(a0)+
	endr

.Done
		rts
; ---------------------------------------------------------------------------

Backup_KosPlus_Registers:
		move	sr,(KosPlus_decomp_stored_SR).w
		movem.w	d0/d2/d4-d7,(KosPlus_decomp_stored_registers).w
		movem.l	a0-a1/a5,(KosPlus_decomp_stored_registers+(2*6)).w
		rts

; ---------------------------------------------------------------------------
; Clears the Kosinski Plus Module decompression queue and its associated variables
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Clear_KosPlus_Module_Queue:
		clearRAM KosPlus_decomp_queue_count, KosPlus_module_queue_end					; clear the KosPlusM bytes
		rts
