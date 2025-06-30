; ---------------------------------------------------------------------------
; ROM Header
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

StartOfROM:

	if * <> 0
		fatal "StartOfROM was $\{*} but it should be 0"
	endif

Vectors:
		dc.l System_stack		; initial stack pointer value
		dc.l EntryPoint			; start of program
		dc.l BusError			; bus error
		dc.l AddressError		; address error (4)
		dc.l IllegalInstr		; illegal instruction
		dc.l ZeroDivide			; division by zero
		dc.l ChkInstr			; chk exception
		dc.l TrapvInstr			; trapv exception (8)
		dc.l PrivilegeViol		; privilege violation
		dc.l Trace			; trace exception
		dc.l Line1010Emu		; line-a emulator
		dc.l Line1111Emu		; line-f emulator (12)
		dc.l ErrorExcept		; unused (reserved)
		dc.l ErrorExcept		; unused (reserved)
		dc.l ErrorExcept		; unused (reserved)
		dc.l ErrorExcept		; unused (reserved) (16)
		dc.l ErrorExcept		; unused (reserved)
		dc.l ErrorExcept		; unused (reserved)
		dc.l ErrorExcept		; unused (reserved)
		dc.l ErrorExcept		; unused (reserved) (20)
		dc.l ErrorExcept		; unused (reserved)
		dc.l ErrorExcept		; unused (reserved)
		dc.l ErrorExcept		; unused (reserved)
		dc.l ErrorExcept		; unused (reserved) (24)
		dc.l ErrorExcept		; spurious exception
		dc.l ErrorTrap			; irq level 1
		dc.l ErrorTrap			; irq level 2
		dc.l ErrorTrap			; irq level 3 (28)
		dc.l H_int_jump			; irq level 4 (horizontal retrace interrupt)
		dc.l ErrorTrap			; irq level 5
		dc.l V_int_jump			; irq level 6 (vertical retrace interrupt)
		dc.l ErrorTrap			; irq level 7 (32)
		dc.l ErrorTrap			; trap #00 exception
		dc.l ErrorTrap			; trap #01 exception
		dc.l ErrorTrap			; trap #02 exception
		dc.l ErrorTrap			; trap #03 exception (36)
		dc.l ErrorTrap			; trap #04 exception
		dc.l ErrorTrap			; trap #05 exception
		dc.l ErrorTrap			; trap #06 exception
		dc.l ErrorTrap			; trap #07 exception (40)
		dc.l ErrorTrap			; trap #08 exception
		dc.l ErrorTrap			; trap #09 exception
		dc.l ErrorTrap			; trap #10 exception
		dc.l ErrorTrap			; trap #11 exception (44)
		dc.l ErrorTrap			; trap #12 exception
		dc.l ErrorTrap			; trap #13 exception
		dc.l ErrorTrap			; trap #14 exception
		dc.l ErrorTrap			; trap #15 exception (48)
		dc.l ErrorTrap			; unused (reserved)
		dc.l ErrorTrap			; unused (reserved)
		dc.l ErrorTrap			; unused (reserved)
		dc.l ErrorTrap			; unused (reserved) (52)
		dc.l ErrorTrap			; unused (reserved)
		dc.l ErrorTrap			; unused (reserved)
		dc.l ErrorTrap			; unused (reserved)
		dc.l ErrorTrap			; unused (reserved) (56)
		dc.l ErrorTrap			; unused (reserved)
		dc.l ErrorTrap			; unused (reserved)
		dc.l ErrorTrap			; unused (reserved)
		dc.l ErrorTrap			; unused (reserved) (60)
		dc.l ErrorTrap			; unused (reserved)
		dc.l ErrorTrap			; unused (reserved)
		dc.l ErrorTrap			; unused (reserved)
		dc.l ErrorTrap			; unused (reserved) (64)

Header:			dc.b "SEGA GENESIS    "
Copyright:		dc.b "(C)SEGA XXXX.XXX"
Domestic_Name:		dc.b "SONIC THE               HEDGEHOG                "
Overseas_Name:		dc.b "SONIC THE               HEDGEHOG                "
Serial_Number:		dc.b "GM MK-0000 -00"
Checksum:		dc.w 0
Input:			dc.b "J               "
ROMStartLoc:		dc.l StartOfROM
ROMEndLoc:		dc.l EndOfROM-1
RAMStartLoc:		dc.l (RAM_start&$FFFFFF)
RAMEndLoc:		dc.l (RAM_start&$FFFFFF)+$FFFF
SRAMSupport:

	if EnableSRAM
CartRAM_Info:		dc.b "RA"
CartRAM_Type:		dc.b $A0+(BackupSRAM<<6)+(AddressSRAM<<3), $20
CartRAMStartLoc:	dc.l SRAM_Start			; SRAM start ($200000)
CartRAMEndLoc:		dc.l SRAM_Start+SRAM_End	; SRAM end ($20xxxx)
	else
CartRAM_Info:		dc.b "  "
CartRAM_Type:		dc.w %10000000100000
CartRAMStartLoc:	dc.b "    "			; SRAM start ($200000)
CartRAMEndLoc:		dc.b "    "			; SRAM end ($20xxxx)
	endif

Modem_Info:		dc.b "                                                    "
Country_Code:		dc.b "JUE             "
EndOfHeader
