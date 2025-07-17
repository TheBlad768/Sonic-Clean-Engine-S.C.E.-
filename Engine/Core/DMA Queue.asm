; ---------------------------------------------------------------------------
; MACRO ResetDMAQueue
; Clears the DMA queue, discarding all previously-queued DMAs.
; By Flamewing
; See https://github.com/flamewing/ultra-dma-queue
; ---------------------------------------------------------------------------
; ROUTINE Process_DMA_Queue / ProcessDMAQueue
; Performs all queued DMA transfers and clears the DMA queue.
;
; Output:
;	a1,a5	trashed
; ---------------------------------------------------------------------------
; ROUTINE InitDMAQueue
; Pre-initializes the DMA queue with VDP register numbers in alternating bytes.
; Must be called before the queue is used, and the queue expects that only it
; write to this region of RAM.
;
; Output:
;	a0,d0,d1	trashed
; ---------------------------------------------------------------------------
; ROUTINE Add_To_DMA_Queue / QueueDMATransfer
; Queues a DMA with parameters given in registers.
;
; Options:
;	AssumeSourceAddressInBytes (default 1)
;	AssumeSourceAddressIsRAMSafe (default 0)
;	UseRAMSourceSafeDMA (default 1&(AssumeSourceAddressIsRAMSafe==0))
;	Use128kbSafeDMA (default 0)
;	UseVIntSafeDMA (default 0)
; Input:
;	d1	Source address (in bytes, or in words if AssumeSourceAddressInBytes is
;		set to 0)
;	d2	Destination address
;	d3	Transfer length (in words)
; Output:
;	d0,d1,d2,d3,a1	trashed
;
; With the default settings, runs in:
; * 48(11/0) cycles if queue is full (DMA discarded)
; * 184(29/9) cycles otherwise (DMA queued)
;
; With Use128kbSafeDMA = 1, runs in:
; * 48(11/0) cycles if queue is full at the start (DMA discarded)
; * 200(32/9) cycles if the DMA does not cross a 128kB boundary (DMA queued)
; * 226(38/9) cycles if the DMA crosses a 128kB boundary, and the first piece
;   fills the queue (second piece is discarded)
; * 338(56/17) cycles if the DMA crosses a 128kB boundary, and the queue has
;   space for both pieces (both pieces queued)
;
; Setting UseVIntSafeDMA to 1 adds 46(6/1) cycles to all times.
;
; Setting AssumeSourceAddressInBytes to 0 reduces all times by 10(1/0) cycles,
; but only if the DMA is not entirely discarded. However, all callers must be
; edited to make sure the adresss given is in the correct form; you can use
; the dmaSource function for that, which also sanitizes RAM addresses.
;
; Setting AssumeSourceAddressIsRAMSafe to 1, or UseRAMSourceSafeDMA to 0,
; reduces all times by 14(2/0) cycles, but only if the DMA is not entirely
; discarded. However, all callers must be edited to make sure the adresss given
; in the correct form.
; ---------------------------------------------------------------------------
; MACRO QueueStaticDMA
; Directly queues a DMA on the spot. Requires all parameters to be known at
; assembly time; that is, no registers. Gives assembly errors when the DMA
; crosses a 128kB boundary, is at an odd ROM location, or is zero length.
;
; The destination parameter can be either:
; * a VRAM address literal;
; * a register initialized with `move.l	#vdpComm(dest,VRAM,DMA)`
; * a register initialized with `vdpCommReg <reg>,VRAM,DMA`
;
; Options:
;	UseVIntSafeDMA (default 0)
; Input:
;	Source address (in bytes), transfer length (in bytes), destination address
; Output:
;	d0,a1	trashed; avoid using these for passing destination as a register
;
; With the default settings, runs in:
; * 32(7/0) cycles if queue is full (DMA discarded)
; * 122(21/8) cycles otherwise (DMA queued)
; Passing a register as destination is faster by 8(2/0) when the DMA is queued,
; but requires initializing the register elsewhere, which is probably slower.
;
; Setting UseVIntSafeDMA to 1 adds 46(6/1) cycles to both cases.
; ===========================================================================
; option: AssumeSourceAddressInBytes
;
; This option makes the function work as a drop-in replacement of the original
; functions. If you modify all callers to supply a position in words instead of
; bytes (i.e., divide source address by 2) you can set this to 0 to gain 10(1/0)
AssumeSourceAddressInBytes = 0
; ===========================================================================
; option: AssumeSourceAddressIsRAMSafe
;
; This option (which is disabled by default) makes the DMA queue assume that the
; source address is given to the function in a way that makes them safe to use
; with RAM sources. You need to edit all callers to ensure this.
; Enabling this option turns off UseRAMSourceSafeDMA, and saves 14(2/0).
AssumeSourceAddressIsRAMSafe = 0
; ===========================================================================
; option: UseRAMSourceSafeDMA
;
; This option (which is enabled by default) makes source addresses in RAM safe
; at the cost of 14(2/0). If you modify all callers so as to clear the top byte
; of source addresses (i.e., by ANDing them with $FFFFFF).
UseRAMSourceSafeDMA = 1&(AssumeSourceAddressIsRAMSafe==0)
; ===========================================================================
; option: Use128kbSafeDMA
;
; This option breaks DMA transfers that crosses a 128kB block into two. It is
; disabled by default because you can simply align the art in ROM and avoid the
; issue altogether. It is here so that you have a high-performance routine to do
; the job in situations where you can't align it in ROM.
Use128kbSafeDMA = 1
; ===========================================================================
; option UseVIntSafeDMA
;
; Option to mask interrupts while updating the DMA queue. This fixes many race
; conditions in the DMA funcion, but it costs 46(6/1) cycles. The better way to
; handle these race conditions would be to make unsafe callers (such as S3&K's
; KosPlusM decoder) prevent these by masking off interrupts before calling and then
; restore interrupts after.
UseVIntSafeDMA = 0
; ===========================================================================
; Convenience macros, for increased maintainability of the code.
	ifndef DMA
		equ	DMA,%100111
	endif
	ifndef VRAM
		equ	VRAM,%100001
	endif
	ifndef vdpCommReg_defined
; Like vdpComm, but starting from an address contained in a register
vdpCommReg_defined = 1
vdpCommReg macro reg,type,rwd,clr
	lsl.l	#2,reg											; Move high bits into (word-swapped) position, accidentally moving everything else
	set .upperbits,(type&rwd)&3
	if .upperbits<>0
		addq.w	#.upperbits,reg									; Add upper access type bits
	endif
	ror.w	#2,reg											; Put upper access type bits into place, also moving all other bits into their correct (word-swapped) places
	swap	reg											; Put all bits in proper places
	if clr <> 0
		andi.w	#3,reg										; Strip whatever junk was in upper word of reg
	endif
	set .lowerbits,(type&rwd)&$FC
	if .lowerbits==$20
		tas.b	reg										; Add in the DMA flag -- tas fails on memory, but works on registers
	elseif .lowerbits<>0
		ori.w	#(.lowerbits<<2),reg								; Add in missing access type bits
	endif
	endm
	endif
; ---------------------------------------------------------------------------
	ifndef DMAEntry_defined
DMAEntry_defined = 1
DMAEntry STRUCT DOTS
Reg94:		ds.b	1
Size:
SizeH:		ds.b	1
Reg93:		ds.b	1
Source:
SizeL:		ds.b	1
Reg97:		ds.b	1
SrcH:		ds.b	1
Reg96:		ds.b	1
SrcM:		ds.b	1
Reg95:		ds.b	1
SrcL:		ds.b	1
Command:	ds.l	1
DMAEntry	ENDSTRUCT
	endif
; ---------------------------------------------------------------------------
QueueSlotCount = (DMA_queue_slot-DMA_queue)/DMAEntry.len
; ---------------------------------------------------------------------------
	ifndef DMAfunctions_defined
		equ	DMAfunctions_defined,1
dmaSource function addr,((addr>>1)&$7FFFFF)
dmaLength function len,((len>>1)&$7FFF)
	endif
; ---------------------------------------------------------------------------
	ifndef QueueStaticDMA_defined
		equ	QueueStaticDMA_defined,1
is68kRegister function expr,symtype(expr)==8
; Expects source address and DMA length in bytes. Also, expects source, size, and dest to be known
; at assembly time. Gives errors if DMA starts at an odd address, transfers
; crosses a 128kB boundary, or has size 0.
QueueStaticDMA macro src,length,dest

.src	:= src

	if MOMPASS>1
		if ((.src)&1)<>0
			fatal "DMA queued from odd source $\{.src}!"
		endif
		if ((length)&1)<>0
			fatal "DMA an odd number of bytes $\{length}!"
		endif
		if (length)==0
			fatal "DMA transferring 0 bytes (becomes a 128kB transfer). If you really mean it, pass 128kB instead."
		endif
		if (((.src)+(length)-1)>>17)<>((.src)>>17)
			fatal "DMA crosses a 128kB boundary. You should either split the DMA manually or align the source adequately."
		endif
	endif
	if UseVIntSafeDMA==1
		move.w	sr,-(sp)									; Save current interrupt mask
		disableInts										; Mask off interrupts
	endif ; UseVIntSafeDMA==1
	movea.w	(DMA_queue_slot).w,a1
	cmpa.w	#DMA_queue_slot,a1
	beq.s	.done											; Return if there's no more room in the buffer
	move.b	#(dmaLength(length)>>8)&$FF,DMAEntry.SizeH(a1)						; Write top byte of size/2
	move.l	#((dmaLength(length)&$FF)<<24)|dmaSource(src),d0					; Set d0 to bottom byte of size/2 and the low 3 bytes of source/2
	movep.l	d0,DMAEntry.SizeL(a1)									; Write it all to the queue
	lea	DMAEntry.Command(a1),a1									; Seek to correct RAM address to store VDP DMA command
	if is68kRegister(dest)
		move.l	dest,(a1)+
	else
		move.l	#vdpComm(dest,VRAM,DMA),(a1)+							; Write VDP DMA command for destination address
	endif
	move.w	a1,(DMA_queue_slot).w									; Write next queue slot
.done
	if UseVIntSafeDMA==1
		move.w	(sp)+,sr									; Restore interrupts to previous state
	endif ;UseVIntSafeDMA==1
	endm
	endif
; ---------------------------------------------------------------------------
ResetDMAQueue macro
	move.w	#DMA_queue,(DMA_queue_slot).w
	endm

; =============== S U B R O U T I N E =======================================

Add_To_DMA_Queue:
	if UseVIntSafeDMA==1
		move.w	sr,-(sp)									; Save current interrupt mask
		disableInts										; Mask off interrupts
	endif ; UseVIntSafeDMA==1
	movea.w	(DMA_queue_slot).w,a1
	cmpa.w	#DMA_queue_slot,a1
	beq.s	.done											; Return if there's no more room in the buffer

	if AssumeSourceAddressInBytes<>0
		lsr.l	#1,d1										; Source address is in words for the VDP registers
	endif
	if UseRAMSourceSafeDMA<>0
		bclr.l	#23,d1										; Make sure bit 23 is clear (68k->VDP DMA flag)
	endif	; UseRAMSourceSafeDMA
	movep.l	d1,DMAEntry.Source(a1)									; Write source address; the useless top byte will be overwritten later
	moveq	#0,d0											; We need a zero on d0

	if Use128kbSafeDMA<>0
		; Detect if transfer crosses 128KB boundary
		; Using sub+sub instead of move+add handles the following edge cases:
		; (1) d3.w == 0 => 128kB transfer
		;   (a) d1.w == 0 => no carry, don't split the DMA
		;   (b) d1.w != 0 => carry, need to split the DMA
		; (2) d3.w != 0
		;   (a) if there is carry on d1.w + d3.w
		;     (* ) if d1.w + d3.w == 0 => transfer comes entirely from current 128kB block, don't split the DMA
		;     (**) if d1.w + d3.w != 0 => need to split the DMA
		;   (b) if there is no carry on d1.w + d3.w => don't split the DMA
		; The reason this works is that carry on d1.w + d3.w means that
		; d1.w + d3.w >= $10000, whereas carry on (-d3.w) - (d1.w) means that
		; d1.w + d3.w > $10000.
		sub.w	d3,d0										; Using sub instead of move and add allows checking edge cases
		sub.w	d1,d0										; Does the transfer cross over to the next 128kB block?
		blo.s	.doubletransfer									; Branch if yes
	endif	; Use128kbSafeDMA
	; It does not cross a 128kB boundary. So just finish writing it.
	movep.w	d3,DMAEntry.Size(a1)									; Write DMA length, overwriting useless top byte of source address

.finishxfer
	; Command to specify destination address and begin DMA
	move.w	d2,d0											; Use the fact that top word of d0 is zero to avoid clearing on vdpCommReg
	vdpCommReg d0,VRAM,DMA,0									; Convert destination address to VDP DMA command
	lea	DMAEntry.Command(a1),a1									; Seek to correct RAM address to store VDP DMA command
	move.l	d0,(a1)+										; Write VDP DMA command for destination address
	move.w	a1,(DMA_queue_slot).w									; Write next queue slot

.done
	if UseVIntSafeDMA==1
		move.w	(sp)+,sr									; Restore interrupts to previous state
	endif ;UseVIntSafeDMA==1
	rts
; ---------------------------------------------------------------------------
	if Use128kbSafeDMA<>0
.doubletransfer
		; We need to split the DMA into two parts, since it crosses a 128kB block
		add.w	d3,d0										; Set d0 to the number of words until end of current 128kB block
		movep.w	d0,DMAEntry.Size(a1)								; Write DMA length of first part, overwriting useless top byte of source addres

		cmpa.w	#DMA_queue_slot-DMAEntry.len,a1	; Does the queue have enough space for both parts?
		beq.s	.finishxfer									; Branch if not

		; Get second transfer's source, destination, and length
		sub.w	d0,d3										; Set d3 to the number of words remaining
		add.l	d0,d1										; Offset the source address of the second part by the length of the first part
		add.w	d0,d0										; Convert to number of bytes
		add.w	d2,d0										; Set d0 to the VRAM destination of the second part

		; If we know top word of d2 is clear, the following vdpCommReg can be set to not
		; clear it. There is, unfortunately, no faster way to clear it than this.
		vdpCommReg d2,VRAM,DMA,1								; Convert destination address of first part to VDP DMA command
		move.l	d2,DMAEntry.Command(a1)								; Write VDP DMA command for destination address of first part

		; Do second transfer
		movep.l	d1,DMAEntry.len+DMAEntry.Source(a1)						; Write source address of second part; useless top byte will be overwritten later
		movep.w	d3,DMAEntry.len+DMAEntry.Size(a1)						; Write DMA length of second part, overwriting useless top byte of source addres

		; Command to specify destination address and begin DMA
		vdpCommReg d0,VRAM,DMA,0								; Convert destination address to VDP DMA command; we know top half of d0 is zero
		lea	DMAEntry.len+DMAEntry.Command(a1),a1						; Seek to correct RAM address to store VDP DMA command of second part
		move.l	d0,(a1)+									; Write VDP DMA command for destination address of second part

		move.w	a1,(DMA_queue_slot).w								; Write next queue slot
		if UseVIntSafeDMA==1
			move.w	(sp)+,sr								; Restore interrupts to previous state
		endif ;UseVIntSafeDMA==1
		rts
	endif	; Use128kbSafeDMA

; ---------------------------------------------------------------------------
; Subroutine for issuing all VDP commands that were queued
; (by earlier calls to QueueDMATransfer)
; Resets the queue when it's done
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Process_DMA_Queue:
	movea.w	(DMA_queue_slot).w,a1
	jmp	.jump_table-DMA_queue(a1)
; ---------------------------------------------------------------------------
.jump_table
	rts
	rept 6
		trap	#0										; Just in case
	endr
; ---------------------------------------------------------------------------
	set	.c,1
	rept QueueSlotCount
		lea	(VDP_control_port).l,a5
		lea	(DMA_queue).w,a1
		if .c<>QueueSlotCount
			bra.w	.jump0 - .c*8
		endif
		set	.c,.c + 1
	endr
; ---------------------------------------------------------------------------
	rept QueueSlotCount
		move.l	(a1)+,(a5)									; Transfer length
		move.l	(a1)+,(a5)									; Source address high
		move.l	(a1)+,(a5)									; Source address low + destination high
		move.w	(a1)+,(a5)									; Destination low, trigger DMA
	endr

.jump0
	ResetDMAQueue
	rts
; ---------------------------------------------------------------------------
; Subroutine for initializing the DMA queue.
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Init_DMA_Queue:
	lea	(DMA_queue).w,a0
	moveq	#-$6C,d0										; fast-store $94 (sign-extended) in d0
	move.l	#$93979695,d1

	set	.c,0

	rept QueueSlotCount
		move.b	d0,.c + DMAEntry.Reg94(a0)
		movep.l	d1,.c + DMAEntry.Reg93(a0)
		set	.c,.c + DMAEntry.len
	endr

	ResetDMAQueue
	rts
