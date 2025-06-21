
; ===============================================================
; ---------------------------------------------------------------
; MD Debugger and Error Handler v.2.6
;
;
; Documentation, references and source code are available at:
; - https://github.com/vladikcomper/md-modules
;
; (c) 2016-2024, Vladikcomper
; ---------------------------------------------------------------
; Debugger definitions
; ---------------------------------------------------------------

; ---------------------------------------------------------------
; Debugger customization
; ---------------------------------------------------------------

; Enable debugger extensions
; Pressing A/B/C on the exception screen can open other debuggers
; Pressing Start or unmapped button returns to the exception
DEBUGGER__EXTENSIONS__ENABLE:			equ		1		; 0 = OFF, 1 = ON (default)

; Whether to show SR and USP registers in exception handler
DEBUGGER__SHOW_SR_USP:					equ		0		; 0 = OFF (default), 1 = ON

; Debuggers mapped to pressing A/B/C on the exception screen
; Use 0 to disable button, use debugger's entry point otherwise.
DEBUGGER__EXTENSIONS__BTN_A_DEBUGGER:	equ		MDDBG__Debugger_AddressRegisters	; display address register symbols
DEBUGGER__EXTENSIONS__BTN_B_DEBUGGER:	equ		MDDBG__Debugger_Backtrace			; display exception backtrace
DEBUGGER__EXTENSIONS__BTN_C_DEBUGGER:	equ		0		; disabled

; Selects between 24-bit (compact) and 32-bit (full) offset format.
; This affects offset format next to the symbols in the exception screen header.
; M68K bus is limited to 24 bits anyways, so not displaying unused bits saves screen space.
; Possible values:
; - MDDBG__Str_OffsetLocation_24bit (example: 001C04 SomeLoc+4)
; - MDDBG__Str_OffsetLocation_32bit (example: 00001C04 SomeLoc+4)
DEBUGGER__STR_OFFSET_SELECTOR:			equ		MDDBG__Str_OffsetLocation_24bit



; ===============================================================
; ---------------------------------------------------------------
; Constants
; ---------------------------------------------------------------

; ----------------------------
; Arguments formatting flags
; ----------------------------

; General arguments format flags
hex		equ		$80				; flag to display as hexadecimal number
dec		equ		$90				; flag to display as decimal number
bin		equ		$A0				; flag to display as binary number
sym		equ		$B0				; flag to display as symbol (treat as offset, decode into symbol +displacement, if present)
symdisp	equ		$C0				; flag to display as symbol's displacement alone (DO NOT USE, unless complex formatting is required, see notes below)
str		equ		$D0				; flag to display as string (treat as offset, insert string from that offset)

; NOTES:
;	* By default, the "sym" flag displays both symbol and displacement (e.g.: "Map_Sonic+$2E")
;		In case, you need a different formatting for the displacement part (different text color and such),
;		use "sym|split", so the displacement won't be displayed until symdisp is met
;	* The "symdisp" can only be used after the "sym|split" instance, which decodes offset, otherwise, it'll
;		display a garbage offset.
;	* No other argument format flags (hex, dec, bin, str) are allowed between "sym|split" and "symdisp",
;		otherwise, the "symdisp" results are undefined.
;	* When using "str" flag, the argument should point to string offset that will be inserted.
;		Arguments format flags CAN NOT be used in the string (as no arguments are meant to be here),
;		only console control flags (see below).


; Additional flags ...
; ... for number formatters (hex, dec, bin)
signed	equ		8				; treat number as signed (display + or - before the number depending on sign)

; ... for symbol formatter (sym)
split	equ		8				; DO NOT write displacement (if present), skip and wait for "symdisp" flag to write it later (optional)
forced	equ		4				; display "<unknown>" if symbol was not found, otherwise, plain offset is displayed by the displacement formatter

; ... for symbol displacement formatter (symdisp)
weak	equ		8				; DO NOT write plain offset if symbol is displayed as "<unknown>"

; Argument type flags:
; - DO NOT USE in formatted strings processed by macros, as these are included automatically
; - ONLY USE when writting down strings manually with DC.B
byte	equ		0
word	equ		1
long	equ		3

; -----------------------
; Console control flags
; -----------------------

; Plain control flags: no arguments following
endl	equ		$E0				; "End of line": flag for line break
cr		equ		$E6				; "Carriage return": jump to the beginning of the line
pal0	equ		$E8				; use palette line #0
pal1	equ		$EA				; use palette line #1
pal2	equ		$EC				; use palette line #2
pal3	equ		$EE				; use palette line #3

; Parametrized control flags: followed by 1-byte argument
setw	equ		$F0				; set line width: number of characters before automatic line break
setoff	equ		$F4				; set tile offset: lower byte of base pattern, which points to tile index of ASCII character 00
setpat	equ		$F8				; set tile pattern: high byte of base pattern, which determines palette flags and $100-tile section id
setx	equ		$FA				; set x-position

; -----------------------------
; Error handler control flags
; -----------------------------

; Screen appearence flags
_eh_address_error	equ	$01		; use for address and bus errors only (tells error handler to display additional "Address" field)
_eh_show_sr_usp		equ	$02		; displays SR and USP registers content on error screen
_eh_hide_caller		equ	$04		; don't guess and print caller in the header (in SGDK and C/C++ projects naive caller detection isn't reliable)

; Advanced execution flags
; WARNING! For experts only, DO NOT USE them unless you know what you're doing
_eh_return			equ	$20
_eh_enter_console	equ	$40
_eh_align_offset	equ	$80



; ===============================================================
; ---------------------------------------------------------------
; Macros
; ---------------------------------------------------------------


; ---------------------------------------------------------------
; WARNING! This disables automatic padding in order to combine DC.B's correctly
;	Make sure your code doesn't rely on padding (enabled by default)!
; ---------------------------------------------------------------

	padding off
	supmode on				; bypass warnings on privileged instructions

; ---------------------------------------------------------------
; Creates assertions for debugging
; ---------------------------------------------------------------
; EXAMPLES:
;	assert.b	d0, eq, #1		; d0 must be $01, or else crash
;	assert.w	d5, pl			; d5 must be positive
;	assert.l	a1, hi, a0		; assert a1 > a0, or else crash
;	assert.b	(MemFlag).w, ne	; MemFlag must be set (non-zero)
;	assert.l	a0, eq, #Obj_Player, MyObjectsDebugger
;
; NOTICE:
;	All "assert" saves and restores CCR so it's fully safe
;	to use in-between any instructions.
;	Use "_assert" instead if you deliberatly want to disbale
;	this behavior and safe a few cycles.
; ---------------------------------------------------------------

assert:	macro	src, cond, dest, consoleprogram
	ifdef __DEBUG__	; Assertions only work in DEBUG builds
		move.w	sr, -(sp)
		_assert.ATTRIBUTE	src, cond, dest, consoleprogram
		move.w	(sp)+, sr
	endif
		endm

; Same as "assert", but doesn't save/restore CCR (can be used to save a few cycles)
_assert:	macro	src, cond, dest, consoleprogram
	ifdef __DEBUG__	; Assertions only work in DEBUG builds
		if "dest"<>""
			cmp.ATTRIBUTE	dest, src
		else
			tst.ATTRIBUTE	src
		endif

		switch lowstring("cond")
		case "eq"
			beq.w	.skip
		case "ne"
			bne.w	.skip
		case "cs"
			bcs.w	.skip
		case "cc"
			bcc.w	.skip
		case "pl"
			bpl.w	.skip
		case "mi"
			bmi.w	.skip
		case "hi"
			bhi.w	.skip
		case "hs"
			bhs.w	.skip
		case "ls"
			bls.w	.skip
		case "lo"
			blo.w	.skip
		case "gt"
			bgt.w	.skip
		case "ge"
			bge.w	.skip
		case "le"
			ble.w	.skip
		case "lt"
			blt.w	.skip
		case "vs"
			bvs.w	.skip
		case "vc"
			bvc.w	.skip
		elsecase
			!error "Unknown condition cond"
		endcase

	if "dest"<>""
		RaiseError	"Assertion failed:%<endl>%<pal2>> assert.ATTRIBUTE %<pal0>src,%<pal2>cond%<pal0>,dest%<endl>%<pal1>Got: %<.ATTRIBUTE src>", consoleprogram
	else
		RaiseError	"Assertion failed:%<endl>%<pal2>> assert.ATTRIBUTE %<pal0>src,%<pal2>cond%<endl>%<pal1>Got: %<.ATTRIBUTE src>", consoleprogram
	endif

	.skip:
	endif
    endm

; ---------------------------------------------------------------
; Raises an error with the given message
; ---------------------------------------------------------------
; EXAMPLES:
;	RaiseError	"Something is wrong"
;	RaiseError	"Your D0 value is BAD: %<.w d0>"
;	RaiseError	"Module crashed! Extra info:", YourMod_Debugger
; ---------------------------------------------------------------

RaiseError:	macro	string, consoleprogram, opts
	pea		*(pc)
	move.w	sr, -(sp)
	__FSTRING_GenerateArgumentsCode string
	jsr		(MDDBG__ErrorHandler).l
	__FSTRING_GenerateDecodedString string, 0 ; 0 = no automatic newline
	if ("consoleprogram"<>"")			; if console program offset is specified ...
		.__align_flag:	set	((((*)&1)!1)*_eh_align_offset)
		if "opts"<>""
			dc.b	opts+_eh_enter_console|.__align_flag					; add flag "_eh_align_offset" if the next byte is at odd offset ...
		else
			dc.b	_eh_enter_console|.__align_flag						; ''
		endif
		!align	2													; ... to tell Error handler to skip this byte, so it'll jump to ...
		if DEBUGGER__EXTENSIONS__ENABLE
			jsr		(consoleprogram).l										; ... an aligned "jsr" instruction that calls console program itself
			jmp		(MDDBG__ErrorHandler_PagesController).l
		else
			jmp		(consoleprogram).l										; ... an aligned "jmp" instruction that calls console program itself
		endif
	else
		if DEBUGGER__EXTENSIONS__ENABLE
			.__align_flag:	set	((((*)&1)!1)*_eh_align_offset)
			if "opts"<>""
				dc.b	opts+_eh_return|.__align_flag					; add flag "_eh_align_offset" if the next byte is at odd offset ...
			else
				dc.b	_eh_return|.__align_flag							; add flag "_eh_align_offset" if the next byte is at odd offset ...
			endif
			!align	2													; ... to tell Error handler to skip this byte, so it'll jump to ...
			jmp		(MDDBG__ErrorHandler_PagesController).l
		else
			dc.b	opts+0						; otherwise, just specify \opts for error handler, +0 will generate dc.b 0 ...
			!align	2							; ... in case \opts argument is empty or skipped
		endif
	endif
	!align	2
	endm


; ---------------------------------------------------------------
; Console interface
; ---------------------------------------------------------------
; EXAMPLES:
;	Console.Run	YourConsoleProgram
;	Console.Write "Hello "
;	Console.WriteLine "...world!"
;	Console.WriteLine "Your data is %<.b d0>"
;	Console.WriteLine "%<pal0>Your code pointer: %<.l a0 sym>"
;	Console.SetXY #1, #4
;	Console.SetXY d0, d1
;	Console.Sleep #60 ; sleep for 1 second
;	Console.Pause
;
; NOTICE:
;	All "Console.*" calls save and restore CCR so they are fully
;	safe to use in-between any instructions.
;	Use "_Console.*" instead if you deliberatly want to disbale
;	this behavior and safe a few cycles.
; ---------------------------------------------------------------

Console:	macro	argument1, argument2
	switch lowstring("ATTRIBUTE")
	; "Console.Run" doesn't have to save/restore CCR, because it's a no-return
	case "run"
		_Console.ATTRIBUTE	argument1, argument2

	; Other Console calls do save/restore CCR
	elsecase
		move.w	sr, -(sp)
		_Console.ATTRIBUTE	argument1, argument2
		move.w	(sp)+, sr
	endcase
	endm

; Same as "Console", but doesn't save/restore CCR (can be used to save a few cycles)
_Console:	macro	argument1, argument2
	switch lowstring("ATTRIBUTE")
	case "write"
		__FSTRING_GenerateArgumentsCode argument1

		; If we have any arguments in string, use formatted string function ...
		if (.__sp>0)
			movem.l	a0-a2/d7, -(sp)
			lea		4*4(sp), a2
			lea		.__data(pc), a1
			jsr		(MDDBG__Console_Write_Formatted).l
			movem.l	(sp)+, a0-a2/d7
			if (.__sp>8)
				lea		.__sp(sp), sp
			elseif (.__sp>0)
				addq.w	#.__sp, sp
			endif

		; ... Otherwise, use direct write as an optimization
		else
			move.l	a0, -(sp)
			lea		.__data(pc), a0
			jsr		(MDDBG__Console_Write).l
			move.l	(sp)+, a0
		endif

		bra.w	.__leave
	.__data:
		__FSTRING_GenerateDecodedString argument1, 0 ; 0 = no automatic newline
		!align	2
	.__leave:

	case "writeline"
		__FSTRING_GenerateArgumentsCode argument1

		; If we have any arguments in string, use formatted string function ...
		if (.__sp>0)
			movem.l	a0-a2/d7, -(sp)
			lea		4*4(sp), a2
			lea		.__data(pc), a1
			jsr		(MDDBG__Console_Write_Formatted).l
			movem.l	(sp)+, a0-a2/d7
			if (.__sp>8)
				lea		.__sp(sp), sp
			elseif (.__sp>0)
				addq.w	#.__sp, sp
			endif
		; ... Otherwise, use direct write as an optimization
		else
			move.l	a0, -(sp)
			lea		.__data(pc), a0
			jsr		(MDDBG__Console_Write).l
			move.l	(sp)+, a0
		endif
		bra.w	.__leave
	.__data:
		__FSTRING_GenerateDecodedString argument1, 1 ; 1 = automatic newline at the end
		!align	2
	.__leave:

	case "run"
		jsr		(MDDBG__ErrorHandler_ConsoleOnly).l
		jsr		(argument1).l
		bra.s	*

	case "clear"
		jsr		(MDDBG__ErrorHandler_ClearConsole).l

	case "pause"
		jsr		(MDDBG__ErrorHandler_PauseConsole).l

	case "sleep"
		move.w	d0, -(sp)
		move.l	a0, -(sp)
		move.w	argument1, d0
		subq.w	#1, d0
		bcs.s	.__sleep_done
		.__sleep_loop:
			jsr		(MDDBG__VSync).l
			dbf		d0, .__sleep_loop

	.__sleep_done:
		move.l	(sp)+, a0
		move.w	(sp)+, d0

	case "setxy"
		movem.l	d0-d1, -(sp)
		move.w	argument2, -(sp)
		move.w	argument1, -(sp)
		jsr		(MDDBG__Console_SetPosAsXY_Stack).l
		addq.w	#4, sp
		movem.l	(sp)+, d0-d1

	case "breakline"
		jsr		(MDDBG__Console_StartNewLine).l

	elsecase
		!error	"ATTRIBUTE isn't a member of Console"

	endcase
	endm

; ---------------------------------------------------------------
; KDebug integration interface
; ---------------------------------------------------------------
; EXAMPLES:
;	KDebug.WriteLine "Look in your debug console!"
;	KDebug.WriteLine "Your D0 is %<.w d0>"
;	KDebug.BreakPoint
;	KDebug.StartTimer
;	KDebug.EndTimer
;
; NOTICE:
;	All "KDebug.*" calls save and restore CCR so they are fully
;	safe to use in-between any instructions.
;	Use "_KDebug.*" instead if you deliberatly want to disbale
;	this behavior and safe a few cycles.
; ---------------------------------------------------------------

KDebug:	macro	argument1
	ifdef __DEBUG__	; KDebug interface is only available in DEBUG builds
		move.w	sr, -(sp)
		_KDebug.ATTRIBUTE	argument1
		move.w	(sp)+, sr
	endif
	endm

; Same as "KDebug", but doesn't save/restore CCR (can be used to save a few cycles)
_KDebug	macro	argument1
	ifdef __DEBUG__	; KDebug interface is only available in DEBUG builds
	switch lowstring("ATTRIBUTE")
	case "write"
		__FSTRING_GenerateArgumentsCode argument1

		; If we have any arguments in string, use formatted string function ...
		if (.__sp>0)
			movem.l	a0-a2/d7, -(sp)
			lea		4*4(sp), a2
			lea		.__data(pc), a1
			jsr		(MDDBG__KDebug_Write_Formatted).l
			movem.l	(sp)+, a0-a2/d7
			if (.__sp>8)
				lea		.__sp(sp), sp
			elseif (.__sp>0)
				addq.w	#.__sp, sp
			endif

		; ... Otherwise, use direct write as an optimization
		else
			move.l	a0, -(sp)
			lea		.__data(pc), a0
			jsr		(MDDBG__KDebug_Write).l
			move.l	(sp)+, a0
		endif

		bra.w	.__leave
	.__data:
		__FSTRING_GenerateDecodedString argument1, 0 ; 0 = no automatic newline
		!align	2
	.__leave:

	case "writeline"
		__FSTRING_GenerateArgumentsCode argument1

		; If we have any arguments in string, use formatted string function ...
		if (.__sp>0)
			movem.l	a0-a2/d7, -(sp)
			lea		4*4(sp), a2
			lea		.__data(pc), a1
			jsr		(MDDBG__KDebug_WriteLine_Formatted).l
			movem.l	(sp)+, a0-a2/d7
			if (.__sp>8)
				lea		.__sp(sp), sp
			elseif (.__sp>0)
				addq.w	#.__sp, sp
			endif

		; ... Otherwise, use direct write as an optimization
		else
			move.l	a0, -(sp)
			lea		.__data(pc), a0
			jsr		(MDDBG__KDebug_WriteLine).l
			move.l	(sp)+, a0
		endif

		bra.w	.__leave
	.__data:
		__FSTRING_GenerateDecodedString argument1, 0 ; 0 = no automatic newline
		!align	2
	.__leave:

	case "breakline"
		move.w	#$9E00, ($C00004).l

	case "starttimer"
		move.w	#$9FC0, ($C00004).l

	case "endtimer"
		move.w	#$9F00, ($C00004).l

	case "breakpoint"
		move.w	#$9D00, ($C00004).l

	elsecase
		!error	"ATTRIBUTE isn't a member of KDebug"

	endcase
	endif
	endm

; ---------------------------------------------------------------
__ErrorMessage:	macro string, opts
		__FSTRING_GenerateArgumentsCode string
		jsr		(MDDBG__ErrorHandler).l
		__FSTRING_GenerateDecodedString string, 0 ; 0 = no automatic newline

		if DEBUGGER__EXTENSIONS__ENABLE
		.__align_flag: set (((*)&1)!1)*_eh_align_offset
			dc.b	(opts)+_eh_return|.__align_flag	; add flag "_eh_align_offset" if the next byte is at odd offset ...
			!align	2												; ... to tell Error handler to skip this byte, so it'll jump to ...
			jmp		(MDDBG__ErrorHandler_PagesController).l	; ... extensions controller
		else
			dc.b	(opts)+0
			!align	2
		endif
	endm

; ---------------------------------------------------------------
; WARNING: Since AS cannot compile instructions out of strings
;	we have to do lots of switch-case bullshit down here..

__FSTRING_PushArgument: macro OPERAND,DEST

	.__operand:		set	OPERAND
	.__dval:		set	0

	; If OPERAND starts with "#", simulate "#immediate" mode by splitting OPERAND string
	if (substr(OPERAND, 0, 1)="#")
		.__dval:	set	VAL(substr(OPERAND, 1, 0))
		.__operand:	set	"#"

	; If OPERAND ends with ".w", simulate "XXX.w" mode
	elseif (substr(OPERAND, strlen(OPERAND)-2, 2)=".w")
		.__dval:	set VAL(substr(OPERAND, 0, strlen(OPERAND)-2))
		.__operand:	set	"x.w"

	; If OPERAND ends with ".l", simulate "XXX.l" mode
	elseif (substr(OPERAND, strlen(OPERAND)-2, 2)=".l")
		.__dval:	set VAL(substr(OPERAND, 0, strlen(OPERAND)-2))
		.__operand:	set	"x.l"

	; If OPERAND ends with "(pc)", simulate "d16(pc)" mode by splitting OPERAND string
	elseif (strlen(OPERAND)>4)&&(substr(OPERAND, strlen(OPERAND)-4, 4)="(pc)")
		.__dval:	set	VAL(substr(OPERAND, 0, strlen(OPERAND)-4))
		.__operand:	set substr(OPERAND, strlen(OPERAND)-4, 0)

	; If OPERAND ends with "(an)", simulate "d16(an)" mode by splitting OPERAND string
	elseif (strlen(OPERAND)>4)&&(substr(OPERAND, strlen(OPERAND)-4, 2)="(a")&&(substr(OPERAND, strlen(OPERAND)-1, 1)=")")
		.__dval:	set	VAL(substr(OPERAND, 0, strlen(OPERAND)-4))
		.__operand:	set substr(OPERAND, strlen(OPERAND)-4, 0)

	endif

	switch lowstring(.__operand)
	case "d0"
		move.ATTRIBUTE	d0,DEST
	case "d1"
		move.ATTRIBUTE	d1,DEST
	case "d2"
		move.ATTRIBUTE	d2,DEST
	case "d3"
		move.ATTRIBUTE	d3,DEST
	case "d4"
		move.ATTRIBUTE	d4,DEST
	case "d5"
		move.ATTRIBUTE	d5,DEST
	case "d6"
		move.ATTRIBUTE	d6,DEST
	case "d7"
		move.ATTRIBUTE	d7,DEST
	
	case "a0"
		move.ATTRIBUTE	a0,DEST
	case "a1"
		move.ATTRIBUTE	a1,DEST
	case "a2"
		move.ATTRIBUTE	a2,DEST
	case "a3"
		move.ATTRIBUTE	a3,DEST
	case "a4"
		move.ATTRIBUTE	a4,DEST
	case "a5"
		move.ATTRIBUTE	a5,DEST
	case "a6"
		move.ATTRIBUTE	a6,DEST

	case "(a0)"
		move.ATTRIBUTE	.__dval(a0),DEST
	case "(a1)"
		move.ATTRIBUTE	.__dval(a1),DEST
	case "(a2)"
		move.ATTRIBUTE	.__dval(a2),DEST
	case "(a3)"
		move.ATTRIBUTE	.__dval(a3),DEST
	case "(a4)"
		move.ATTRIBUTE	.__dval(a4),DEST
	case "(a5)"
		move.ATTRIBUTE	.__dval(a5),DEST
	case "(a6)"
		move.ATTRIBUTE	.__dval(a6),DEST

	case "x.w"
		move.ATTRIBUTE	(.__dval).w,DEST

	case "x.l"
		move.ATTRIBUTE	(.__dval).l,DEST

	case "(pc)"
		move.ATTRIBUTE	.__dval(pc),DEST

	case "#"
		move.ATTRIBUTE	#.__dval,DEST

	elsecase
	.__evaluated_operand: set VAL(OPERAND)
		move.ATTRIBUTE	.__evaluated_operand,DEST

	endcase
	endm

; ---------------------------------------------------------------
; WARNING! Incomplete!
__FSTRING_GenerateArgumentsCode: macro string

	.__pos:	set 	strstr(string,"%<")		; token position
	.__sp:	set		0						; stack displacement
	.__str:	set		string

	; Parse string itself
	while (.__pos>=0)

    	; Find the last occurance "%<" in the string
    	while ( strstr(substr(.__str,.__pos+2,0),"%<")>=0 )
			.__pos: 	set		strstr(substr(.__str,.__pos+2,0),"%<")+.__pos+2
		endm
		.__substr:	set		substr(.__str,.__pos,0)

		; Retrive expression in brackets following % char
    	.__endpos:	set		strstr(.__substr,">")
		if (.__endpos<0) ; Fix bizzare AS bug as stsstr() fails to check the last character of string
			.__endpos:	set		strlen(.__substr)-1
		endif
    	.__midpos:	set		strstr(substr(.__substr,5,0)," ")
    	if ((.__midpos<0)||(.__midpos+5>.__endpos))
			.__midpos:	set		.__endpos
		else
			.__midpos:	set		.__midpos+5
    	endif
		.__type:		set		substr(.__substr,2,2)	; .type

		; Expression is an effective address (e.g. %(.w d0 hex) )
		if ((strlen(.__type)==2)&&(substr(.__type,0,1)=="."))
			.__operand:	set		substr(.__substr,5,.__midpos-5)						; ea
			.__param:	set		substr(.__substr,.__midpos+1,.__endpos-.__midpos-1)		; param

			if (.__type==".b")
				subq.w	#2, sp
				__FSTRING_PushArgument.b	.__operand,1(sp)
				.__sp:	set		.__sp+2

			elseif (.__type==".w")
				__FSTRING_PushArgument.w	.__operand,-(sp)
				.__sp:	set		.__sp+2

			elseif (.__type==".l")
				__FSTRING_PushArgument.l	.__operand,-(sp)
				.__sp:	set		.__sp+4

			else
				error "Unrecognized type in string operand: \{.__type}"
			endif

		endif

		; Cut string
		if (.__pos>0)
			.__str:	set		substr(.__str, 0, .__pos)
			.__pos:	set		strstr(.__str,"%<")
		else
			.__pos:	set		-1
		endif

	endm

	endm

; ---------------------------------------------------------------
__FSTRING_GenerateDecodedString:	macro string, addnewline

	.__lpos:	set		0		; start position
	.__pos:	set		strstr(string, "%<")

	while (.__pos>=0)

		; Write part of string before % token
		if (.__pos-.__lpos>0)
			dc.b	substr(string, .__lpos, .__pos-.__lpos)
		endif

		; Retrive expression in brakets following % char
    	.__endpos:	set		strstr(substr(string,.__pos+1,0),">")+.__pos+1 
		if (.__endpos<=.__pos) ; Fix bizzare AS bug as stsstr() fails to check the last character of string
			.__endpos:	set		strlen(string)-1
		endif
    	.__midpos:	set		strstr(substr(string,.__pos+5,0)," ")+.__pos+5
    	if ((.__midpos<.__pos+5)||(.__midpos>.__endpos))
			.__midpos:	set		.__endpos
    	endif
		.__type:		set		substr(string,.__pos+1+1,2)		; .type

		; Expression is an effective address (e.g. %<.w d0 hex> )
		if ((strlen(.__type)==2)&&(substr(.__type,0,1)=="."))
			.__param:	set		substr(string,.__midpos+1,.__endpos-.__midpos-1)	; param

			; Validate format setting ("param")
			if (strlen(.__param)<1)
				.__param: 	set		"hex"			; if param is ommited, set it to "hex"
			elseif (.__param=="signed")
				.__param:	set		"hex+signed"	; if param is "signed", correct it to "hex+signed"
			endif

			if (val(.__param) < $80)
				!error "Illegal operand format setting: \{.__param}. Expected hex, dec, bin, sym, str or their derivatives."
			endif

			if (.__type==".b")
				dc.b	val(.__param)
			elseif (.__type==".w")
				dc.b	val(.__param)|1
			else
				dc.b	val(.__param)|3
			endif

		; Expression is an inline constant (e.g. %<endl> )
		else
			dc.b	val(substr(string,.__pos+1+1,.__endpos-.__pos-2))
		endif

		.__lpos:	set		.__endpos+1
		if (strstr(substr(string,.__pos+1,0),"%<")>=0)
			.__pos:	set		strstr(substr(string,.__pos+1,0), "%<")+.__pos+1
		else
			.__pos:	set		-1
		endif

	endm

	; Write part of string before the end
	dc.b	substr(string, .__lpos, 0)
	if addnewline
		dc.b	endl
	endif
	dc.b	0

	endm

; ---------------------------------------------------------------
; MIT License
; 
; Copyright (c) 2016-2024 Vladikcomper
; 
; Permission is hereby granted, free of charge, to any person
; obtaining a copy ; of this software and associated
; documentation files (the "Software"), to deal in the Software 
; without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense,
; and/or sell copies of the Software, and to permit persons to
; whom the Software is furnished to do so, subject to the
; following conditions:
; 
; The above copyright notice and this permission notice shall be
; included in all copies or substantial portions of the Software.
; 
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
; OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
; HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
; WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
; FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
; OTHER DEALINGS IN THE SOFTWARE.
; ---------------------------------------------------------------
