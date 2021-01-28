
; ===============================================================
; ---------------------------------------------------------------
; Error handling and debugging modules
; 2016-2017, Vladikcomper
; ---------------------------------------------------------------
; Error handler functions and calls
; ---------------------------------------------------------------

; ---------------------------------------------------------------
; Error handler control flags
; ---------------------------------------------------------------

; Screen appearence flags
_eh_address_error	equ	$01		; use for address and bus errors only (tells error handler to display additional "Address" field)
_eh_show_sr_usp		equ	$02		; displays SR and USP registers content on error screen
_eh_disassemble		equ	$10		; disassembles the instruction where the error happened + vint and hint handlers

; Advanced execution flags
; WARNING! For experts only, DO NOT USES them unless you know what you're doing
_eh_return		equ	$20
_eh_enter_console	equ	$40
_eh_align_offset	equ	$80

; ---------------------------------------------------------------
; Errors vector table
; ---------------------------------------------------------------

; Default screen configuration
_eh_default			equ	0 ;_eh_show_sr_usp

; ---------------------------------------------------------------

BusError:
	__ErrorMessage "BUS ERROR", _eh_default|_eh_address_error|_eh_disassemble

AddressError:
	__ErrorMessage "ADDRESS ERROR", _eh_default|_eh_address_error|_eh_disassemble

IllegalInstr:
	__ErrorMessage "ILLEGAL INSTRUCTION", _eh_default|_eh_disassemble

ZeroDivide:
	__ErrorMessage "ZERO DIVIDE", _eh_default|_eh_disassemble

ChkInstr:
	__ErrorMessage "CHK INSTRUCTION", _eh_default|_eh_disassemble

TrapvInstr:
	__ErrorMessage "TRAPV INSTRUCTION", _eh_default|_eh_disassemble

PrivilegeViol:
	__ErrorMessage "PRIVILEGE VIOLATION", _eh_default|_eh_disassemble

Trace:
	__ErrorMessage "TRACE", _eh_default|_eh_disassemble

Line1010Emu:
	__ErrorMessage "LINE A EMULATOR", _eh_default|_eh_disassemble

Line1111Emu:
	__ErrorMessage "LINE F EMULATOR", _eh_default|_eh_disassemble

ErrorExcept:
	__ErrorMessage "ERROR EXCEPTION", _eh_default|_eh_disassemble

ErrorTrap:
	__ErrorMessage "ERROR TRAP", _eh_default|_eh_disassemble



; ---------------------------------------------------------------
; Error handler external functions (compiled only when used)
; ---------------------------------------------------------------


; WARNING! This blocks are intended to compile if referenced anywhere in the code.
;	However, as of AS version 1.42 [Bld 55], "IFUSED" directive doesn't work properly.

; --------------------------------------------------------------
;	ifused ErrorHandler___extern_scrollconsole
ErrorHandler___extern__scrollconsole:

;	endif

; --------------------------------------------------------------
;	ifused ErrorHandler___extern__console_only
ErrorHandler___extern__console_only:
	dc.l	$46FC2700, $4FEFFFF2, $48E7FFFE, $47EF003C
	jsr	ErrorHandler___global__errorhandler_setupvdp(pc)
	jsr	ErrorHandler___global__error_initconsole(pc)
	dc.l	$4CDF7FFF, $487A0008, $2F2F0012, $4E7560FE
;	endif

; --------------------------------------------------------------
;	ifused ErrorHandler___extern__vsync
ErrorHandler___extern__vsync:
	dc.l	$41F900C0, $000444D0, $6BFC44D0, $6AFC4E75
;	endif

; ---------------------------------------------------------------
; Include error handler binary module
; ---------------------------------------------------------------

ErrorHandler:
	binclude "Misc Data/Debugger/ErrorHandler/ErrorHandler.bin"

; ---------------------------------------------------------------
; WARNING!
;	DO NOT put any data from now on! DO NOT use ROM padding!
;	Symbol data should be appended here after ROM is compiled
;	by ConvSym utility, otherwise debugger modules won't be able
;	to resolve symbol names.
; ---------------------------------------------------------------
