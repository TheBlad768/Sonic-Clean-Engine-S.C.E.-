; ---------------------------------------------------------------------------
; Adds pattern load requests to the Nemesis decompression queue
; Input: d0 = ID of the PLC to load
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

LoadPLC_Nem:
		move.w	(Current_zone_and_act).w,d0
		ror.b	#2,d0
		lsr.w	#4,d0
		lea	(Offs_PLC).l,a1
		adda.w	(a1,d0.w),a1

LoadPLC_Raw_Nem:
		lea	(Nem_decomp_queue-6).w,a2

.findFreeSlot:
		addq.w	#6,a2			; otherwise check the next slot
		tst.l	(a2)					; is the current slot in the queue free?
		bne.s	.findFreeSlot		; if it is, branch
		move.w	(a1)+,d6
		bmi.s	.done

.queuePieces:
		move.l	(a1)+,(a2)+		; store compressed data location
		move.w	(a1)+,(a2)+		; store destination in VRAM
		dbf	d6,.queuePieces

.done:
		rts
; End of function LoadPLC_Nem

; =============== S U B R O U T I N E =======================================

Queue_Nem:
		lea	(Nem_decomp_queue).w,a2
		tst.l	(a2)					; is the current slot in the queue free?
		bne.s	.done			; if not, branch

.findFreeSlot:
		tst.l	(a2)					; is the current slot in the queue free?
		beq.s	.queuePieces		; if it is, branch
		addq.w	#6,a2			; otherwise check the next slot
		bra.s	.findFreeSlot
; ---------------------------------------------------------------------------

.queuePieces:
		move.l	a1,(a2)+			; store source address
		move.w	d2,(a2)+			; store destination VRAM address

.done:
		rts
; End of function Queue_Nem
; ---------------------------------------------------------------------------
; Clears the Nemesis decompression queue and its associated variables
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Clear_Nem_Queue:
		clearRAM Nem_decomp_queue, Nem_decomp_queue_End	; clear till the end of Nem_decomp_vars
		rts
; End of function Clear_Nem_Queue
; ---------------------------------------------------------------------------
; Loads a raw PLC from the ROM and decompresses it immediately
; Input: a1 = the address of the PLC
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Load_PLC_Nem_Immediate:
		move.w	(a1)+,d1

.decompPieces:
		movea.l	(a1)+,a0			; get source address
		moveq	#0,d0
		move.w	(a1)+,d0			; get destination VRAM address
		bsr.s	CalcVRAM2		; d0 = VDP command to write to destination
		move.l	d0,(VDP_control_port).l
		bsr.w	Nem_Decomp
		dbf	d1,.decompPieces
		rts
; End of function Load_PLC_Nem_Immediate
; ---------------------------------------------------------------------------
; Initializes Nemesis decompression queue processing
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Process_Nem_Queue_Init:
		tst.l	(Nem_decomp_queue).w
		beq.s	Process_Nem_Queue_Return	; return if the queue is empty
		tst.w	(Nem_patterns_left).w
		bne.s	Process_Nem_Queue_Return	; return if processing of a previous piece is still going on
		movea.l	(Nem_decomp_queue).w,a0
		lea	Nem_PCD_WriteRowToVDP(pc),a3
		nop
		lea	(Nem_code_table).w,a1		; load Nemesis decompression buffer
		move.w	(a0)+,d2					; get number of patterns
		bpl.s	+						; are we in Mode 0?
		lea	Nem_PCD_WriteRowToVDP_XOR-Nem_PCD_WriteRowToVDP(a3),a3	; if not, use Mode 1
+		andi.w	#$7FFF,d2
		bsr.w	Nem_Build_Code_Table
		move.b	(a0)+,d5
		asl.w	#8,d5
		move.b	(a0)+,d5
		moveq	#$10,d6
		moveq	#0,d0
		move.l	a0,(Nem_decomp_queue).w
		move.l	a3,(Nem_decomp_vars).w
		move.l	d0,(Nem_repeat_count).w
		move.l	d0,(Nem_palette_index).w
		move.l	d0,(Nem_previous_row).w
		move.l	d5,(Nem_data_word).w
		move.l	d6,(Nem_shift_value).w
		move.w	d2,(Nem_patterns_left).w

Process_Nem_Queue_Return:
		rts
; End of function Process_Nem_Queue_Init
; ---------------------------------------------------------------------------
; Processes the first piece on the Nemesis decompression queue
; Decompresses 6 patterns per frame
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Process_Nem_Queue:
		tst.w	(Nem_patterns_left).w
		beq.s	Process_Nem_Queue_Return
		move.w	#6,(Nem_frame_patterns_left).w		; decompress 6 patterns per frame
		moveq	#0,d0
		move.w	(Nem_decomp_destination).w,d0
		addi.w	#6*$20,(Nem_decomp_destination).w	; increment by 6 patterns' worth of data
		bra.s	Process_Nem_Queue_Main
; End of function Process_Nem_Queue
; ---------------------------------------------------------------------------
; Processes the first piece on the Nemesis decompression queue
; Decompresses 3 patterns per frame
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Process_Nem_Queue_2:
		tst.w	(Nem_patterns_left).w
		beq.s	Process_Nem_Queue_Return
		move.w	#3,(Nem_frame_patterns_left).w		; decompress 3 patterns per frame
		moveq	#0,d0
		move.w	(Nem_decomp_destination).w,d0
		addi.w	#3*$20,(Nem_decomp_destination).w	; increment by 3 patterns' worth of data
; End of function Process_Nem_Queue_2
; ---------------------------------------------------------------------------
; Main Nemesis decompression queue processor
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Process_Nem_Queue_Main:
		lea	(VDP_control_port).l,a4
		bsr.w	CalcVRAM2							; d0 = VDP command word to write to VRAM destination
		move.l	d0,(a4)
		subq.w	#VDP_control_port-VDP_data_port,a4	; a4 = VDP_data_port
		movea.l	(Nem_decomp_queue).w,a0
		movea.l	(Nem_decomp_vars).w,a3
		move.l	(Nem_repeat_count).w,d0
		move.l	(Nem_palette_index).w,d1
		move.l	(Nem_previous_row).w,d2
		move.l	(Nem_data_word).w,d5
		move.l	(Nem_shift_value).w,d6
		lea	(Nem_code_table).w,a1

Process_Nem_Queue_Loop:
		movea.w	#8,a5								; decompress all 8 rows in a pattern
		bsr.w	Nem_PCD_NewRow
		subq.w	#1,(Nem_patterns_left).w				; have all the patterns been decompressed?
		beq.s	Process_Nem_Queue_ShiftUp			; if yes, shift all other queue entries up
		subq.w	#1,(Nem_frame_patterns_left).w		; has the current frame's worth of patterns been decompressed?
		bne.s	Process_Nem_Queue_Loop	; if not, loop
		move.l	a0,(Nem_decomp_queue).w
		move.l	a3,(Nem_decomp_vars).w
		move.l	d0,(Nem_repeat_count).w
		move.l	d1,(Nem_palette_index).w
		move.l	d2,(Nem_previous_row).w
		move.l	d5,(Nem_data_word).w
		move.l	d6,(Nem_shift_value).w

Process_Nem_Queue_Done:
		rts
; ---------------------------------------------------------------------------
; ShiftUp Nemesis decompression queue processor
; ---------------------------------------------------------------------------

Process_Nem_Queue_ShiftUp:
		lea	(Nem_decomp_queue).w,a0
		lea	6(a0),a1
		moveq	#PLCNem_Count-2,d0

-		move.l	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		dbf	d0,-

		moveq	#0,d0
		move.l	d0,(a0)+
		move.w	d0,(a0)+
		rts
; End of function Process_Nem_Queue_Main
; ---------------------------------------------------------------------------
; Nemesis decompression subroutine, decompresses art directly to VRAM
; Inputs:
; a0 = art address
; a VDP command to write to the destination VRAM address must be issued
; before calling this routine
; See http://www.segaretro.org/Nemesis_compression for format description
; Optimized by Vladikcomper
; See https://github.com/flamewing/mdcomp
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

NemDec_RAM:
Nem_Decomp_To_RAM:
		movem.l	d0-a1/a3-a6,-(sp)
		lea	Nem_PCD_WriteRowToRAM(pc),a3
		bra.s	Nem_Decomp_Main
; End of function Nem_Decomp_To_RAM
; ------------------------------------------------------------------------------

NemDec:
Nem_Decomp:
		movem.l	d0-a1/a3-a6,-(sp)
		lea	(VDP_data_port).l,a4			; write all rows to the VDP data port
		lea	Nem_PCD_WriteRowToVDP(pc),a3

Nem_Decomp_Main:
		lea	(Nem_code_table).w,a1		; load Nemesis decompression buffer
		move.w	(a0)+,d2					; get number of patterns
		bpl.s	+						; are we in Mode 0?
		lea	Nem_PCD_WriteRowToVDP_XOR-Nem_PCD_WriteRowToVDP(a3),a3	; if not, use Mode 1
+		lsl.w	#3,d2
		movea.w	d2,a5
		moveq	#7,d3
		moveq	#0,d2
		moveq	#0,d4
		bsr.w	Nem_Build_Code_Table
		move.b	(a0)+,d5					; get first byte of compressed data
		asl.w	#8,d5					; shift up by a byte
		move.b	(a0)+,d5					; get second byte of compressed data
		move.w	#$10,d6					; set initial shift value
		bsr.s	Nem_Process_Compressed_Data
		movem.l	(sp)+,d0-a1/a3-a6
		rts
; ---------------------------------------------------------------------------
; Part of the Nemesis decompressor, processes the actual compressed data
; ---------------------------------------------------------------------------

Nem_Process_Compressed_Data:
		move.w	d6,d7
		subq.w	#8,d7					; get shift value
		move.w	d5,d1
		lsr.w	d7,d1					; shift so that high bit of the code is in bit position 7
		cmpi.b	#%11111100,d1			; are the high 6 bits set?
		bcc.s	NemDec_InlineData		; if they are, it signifies inline data
		andi.w	#$FF,d1
		add.w	d1,d1
		sub.b	(a1,d1.w),d6				; ~~ subtract from shift value so that the next code is read next time around
		cmpi.w	#9,d6					; does a new byte need to be read?
		bcc.s	+						; if not, branch
		addq.w	#8,d6
		asl.w	#8,d5
		move.b	(a0)+,d5					; read next byte
+		move.b	1(a1,d1.w),d1
		move.w	d1,d0
		andi.w	#$F,d1					; get palette index for pixel
		andi.w	#$F0,d0

NemDec_GetRepeatCount:
		lsr.w	#4,d0					; get repeat count

Nem_PCD_WritePixel:
		lsl.l	#4,d4						; shift up by a nybble
		or.b	d1,d4						; write pixel
		dbf	d3,Nem_PCD_WritePixelLoop	; ~~
		jmp	(a3)							; otherwise, write the row to its destination
; ---------------------------------------------------------------------------

Nem_PCD_NewRow:
		moveq	#0,d4					; reset row
		moveq	#7,d3					; reset nybble counter

Nem_PCD_WritePixelLoop:
		dbf	d0,Nem_PCD_WritePixel
		bra.s	Nem_Process_Compressed_Data
; ---------------------------------------------------------------------------

NemDec_InlineData:
		subq.w	#6,d6					; 6 bits needed to signal inline data
		cmpi.w	#9,d6
		bcc.s	+
		addq.w	#8,d6
		asl.w	#8,d5
		move.b	(a0)+,d5
+		subq.w	#7,d6					; and 7 bits needed for the inline data itself
		move.w	d5,d1
		lsr.w	d6,d1					; shift so that low bit of the code is in bit position 0
		move.w	d1,d0
		andi.w	#$F,d1					; get palette index for pixel
		andi.w	#$70,d0					; high nybble is repeat count for pixel
		cmpi.w	#9,d6
		bcc.s	NemDec_GetRepeatCount
		addq.w	#8,d6
		asl.w	#8,d5
		move.b	(a0)+,d5
		bra.s	NemDec_GetRepeatCount
; ---------------------------------------------------------------------------
; Subroutines to output decompressed entry
; Selected depending on current decompression mode
; ---------------------------------------------------------------------------

Nem_PCD_WriteRowToVDP:
		move.l	d4,(a4)					; write 8-pixel row
		subq.w	#1,a5
		move.w	a5,d4					; have all the 8-pixel rows been written?
		bne.s	Nem_PCD_NewRow		; if not, branch
		rts
; ---------------------------------------------------------------------------

Nem_PCD_WriteRowToVDP_XOR:
		eor.l	d4,d2						; XOR the previous row by the current row
		move.l	d2,(a4)					; and write the result
		subq.w	#1,a5
		move.w	a5,d4
		bne.s	Nem_PCD_NewRow
		rts
; ---------------------------------------------------------------------------

Nem_PCD_WriteRowToRAM:
		move.l	d4,(a4)+					; write 8-pixel row
		subq.w	#1,a5
		move.w	a5,d4					; have all the 8-pixel rows been written?
		bne.s	Nem_PCD_NewRow		; if not, branch
		rts
; ---------------------------------------------------------------------------

Nem_PCD_WriteRowToRAM_XOR:
		eor.l	d4,d2						; XOR the previous row by the current row
		move.l	d2,(a4)+					; and write the result
		subq.w	#1,a5
		move.w	a5,d4
		bne.s	Nem_PCD_NewRow
		rts
; ---------------------------------------------------------------------------
; Part of the Nemesis decompressor, builds the code table (in RAM)
; ---------------------------------------------------------------------------

Nem_Build_Code_Table:
		move.b	(a0)+,d0					; read first byte
-		cmpi.b	#-1,d0					; has the end of the code table description been reached?
		bne.s	+						; if not, branch
		rts
; ---------------------------------------------------------------------------
+		move.w	d0,d7
-		move.b	(a0)+,d0					; read next byte
		bmi.s	--						; ~~
		move.b	d0,d1
		andi.w	#$F,d7					; get palette index
		andi.w	#$70,d1				 	; get repeat count for palette index
		or.w	d1,d7						; combine the two
		andi.w	#$F,d0					; get the length of the code in bits
		move.b	d0,d1
		lsl.w	#8,d1
		or.w	d1,d7						; combine with palette index and repeat count to form code table entry
		moveq	#8,d1
		sub.w	d0,d1					; is the code 8 bits long?
		bne.s	+						; if not, a bit of extra processing is needed
		move.b	(a0)+,d0					; get code
		add.w	d0,d0					; each code gets a word-sized entry in the table
		move.w	d7,(a1,d0.w)				; store the entry for the code
		bra.s	-						; repeat
; ---------------------------------------------------------------------------
+		move.b	(a0)+,d0					; get code
		lsl.w	d1,d0						; shift so that high bit is in bit position 7
		add.w	d0,d0					; get index into code table
		moveq	#1,d5
		lsl.w	d1,d5
		subq.w	#1,d5					; d5 = 2^d1 - 1
		lea	(a1,d0.w),a6					; ~~
-		move.w	d7,(a6)+					; ~~ store entry
		dbf	d5,-							; repeat for required number of entries
		bra.s	--
; End of function Nem_Build_Code_Table
