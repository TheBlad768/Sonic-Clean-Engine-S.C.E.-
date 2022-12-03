
; ===============================================================
; ---------------------------------------------------------------
; Error handling and debugging modules
; 2016-2017, Vladikcomper
; See https://github.com/vladikcomper/md-modules
; ---------------------------------------------------------------
; Debugging macros definitions file
; ---------------------------------------------------------------


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


; ---------------------------------------------------------------
; Import error handler global functions
; ---------------------------------------------------------------

ErrorHandler___global__error_initconsole: label ErrorHandler+$146
ErrorHandler___global__errorhandler_setupvdp: label ErrorHandler+$234
ErrorHandler___global__art1bpp_font: label ErrorHandler+$332
ErrorHandler___global__formatstring: label ErrorHandler+$8F4
ErrorHandler___global__console_loadpalette: label ErrorHandler+$A0E
ErrorHandler___global__console_setposasxy_stack: label ErrorHandler+$A4A
ErrorHandler___global__console_setposasxy: label ErrorHandler+$A50
ErrorHandler___global__console_getposasxy: label ErrorHandler+$A7C
ErrorHandler___global__console_startnewline: label ErrorHandler+$A9E
ErrorHandler___global__console_setbasepattern: label ErrorHandler+$AC6
ErrorHandler___global__console_setwidth: label ErrorHandler+$ADA
ErrorHandler___global__console_writeline_withpattern: label ErrorHandler+$AF0
ErrorHandler___global__console_writeline: label ErrorHandler+$AF2
ErrorHandler___global__console_write: label ErrorHandler+$AF6
ErrorHandler___global__console_writeline_formatted: label ErrorHandler+$BA2
ErrorHandler___global__console_write_formatted: label ErrorHandler+$BA6
ErrorHandler___global__decomp1bpp: label ErrorHandler+$BD6

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
RaiseError	macro	string, consoleprogram, opts

	pea		*(pc)
	move.w	sr, -(sp)
	__FSTRING_GenerateArgumentsCode string
	jsr		ErrorHandler
	__FSTRING_GenerateDecodedString string
	if ("consoleprogram"<>"")			; if console program offset is specified ...
		if "opts"<>""
			dc.b	opts+_eh_enter_console|((((*)&1)!1)*_eh_align_offset)		; add flag "_eh_align_offset" if the next byte is at odd offset ...
		else
			dc.b	_eh_enter_console|((((*)&1)!1)*_eh_align_offset)	; ''
		endif
		align	2															; ... to tell Error handler to skip this byte, so it'll jump to ...
		jmp		consoleprogram										; ... an aligned "jmp" instruction that calls console program itself
	else
		dc.b	opts+0						; otherwise, just specify \opts for error handler, +0 will generate dc.b 0 ...
		align	2							; ... in case \opts argument is empty or skipped
	endif
	align	2

	endm

; ---------------------------------------------------------------
Console	macro	argument1, argument2

	switch lowstring("ATTRIBUTE")
	case "write"
		move.w	sr, -(sp)
		__FSTRING_GenerateArgumentsCode argument1
		movem.l	a0-a2/d7, -(sp)
		lea		4*4(sp), a2
		lea		__data(pc), a1
		jsr		ErrorHandler___global__console_write_formatted
		movem.l	(sp)+, a0-a2/d7
		if (__sp>8)
			lea		__sp(sp), sp
		elseif (__sp>0)
			addq.w	#__sp, sp
		endif
		move.w	(sp)+, sr
		bra.w	__leave
	__data:
		__FSTRING_GenerateDecodedString argument1
		align	2
	__leave:

	case "writeline"
		move.w	sr, -(sp)
		__FSTRING_GenerateArgumentsCode argument1
		movem.l	a0-a2/d7, -(sp)
		lea		4*4(sp), a2
		lea		__data(pc), a1
		jsr		ErrorHandler___global__console_writeline_formatted
		movem.l	(sp)+, a0-a2/d7
		if (__sp>8)
			lea		__sp(sp), sp
		elseif (__sp>0)
			addq.w	#__sp, sp
		endif
		move.w	(sp)+, sr
		bra.w	__leave
	__data:
		__FSTRING_GenerateDecodedString argument1
		align	2
	__leave:

	case "run"
		jsr		ErrorHandler___extern__console_only
		jsr		argument1
		bra.s	*

	case "setxy"
		move.w	sr, -(sp)
		movem.l	d0-d1, -(sp)
		move.w	argument2, -(sp)
		move.w	argument1, -(sp)
		jsr		ErrorHandler___global__console_setposasxy_stack
		addq.w	#4, sp
		movem.l	(sp)+, d0-d1
		move.w	(sp)+, sr

	case "breakline"
		move.w	sr, -(sp)
		jsr		ErrorHandler___global__console_startnewline
		move.w	(sp)+, sr

	elsecase
		!error	"ATTRIBUTE isn't a member of Console"

	endcase
	endm

; ---------------------------------------------------------------
__ErrorMessage  macro string, opts
		__FSTRING_GenerateArgumentsCode string
		jsr		ErrorHandler
		__FSTRING_GenerateDecodedString string
		dc.b	opts+0
		align	2

	endm

; ---------------------------------------------------------------
; WARNING: Since AS cannot compile instructions out of strings
;	we have to do lots of switch-case bullshit down here..

__FSTRING_PushArgument macro OPERAND,DEST

	switch OPERAND
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
		move.ATTRIBUTE	(a0),DEST
	case "(a1)"
		move.ATTRIBUTE	(a1),DEST
	case "(a2)"
		move.ATTRIBUTE	(a2),DEST
	case "(a3)"
		move.ATTRIBUTE	(a3),DEST
	case "(a4)"
		move.ATTRIBUTE	(a4),DEST
	case "(a5)"
		move.ATTRIBUTE	(a5),DEST
	case "(a6)"
		move.ATTRIBUTE	(a6),DEST

	elsecase
		move.ATTRIBUTE	{OPERAND},DEST

	endcase
	endm

; ---------------------------------------------------------------
; WARNING! Incomplete!
__FSTRING_GenerateArgumentsCode macro string

	__pos:	set 	strstr(string,"%<")		; token position
	__sp:	set		0						; stack displacement
	__str:	set		string

	; Parse string itself
	while (__pos>=0)

    	; Find the last occurance "%<" in the string
    	while ( strstr(substr(__str,__pos+2,0),"%<")>=0 )
			__pos: 	set		strstr(substr(__str,__pos+2,0),"%<")+__pos+2
		endm
		__substr:	set		substr(__str,__pos,0)

		; Retrive expression in brackets following % char
    	__endpos:	set		strstr(__substr,">")
		if (__endpos<0) ; Fix bizzare AS bug as stsstr() fails to check the last character of string
			__endpos:	set		strlen(__substr)-1
		endif
    	__midpos:	set		strstr(substr(__substr,5,0)," ")
    	if ((__midpos<0)||(__midpos+5>__endpos))
			__midpos:	set		__endpos
		else
			__midpos:	set		__midpos+5
    	endif
		__type:		set		substr(__substr,2,2)	; .type

		; Expression is an effective address (e.g. %(.w d0 hex) )
		if ((strlen(__type)==2)&&(substr(__type,0,1)=="."))
			__operand:	set		substr(__substr,5,__midpos-5)						; ea
			__param:	set		substr(__substr,__midpos+1,__endpos-__midpos-1)		; param

			if (__type==".b")
				subq.w	#2, sp
				__FSTRING_PushArgument.b	__operand,1(sp)
				__sp:	set		__sp+2

			elseif (__type==".w")
				__FSTRING_PushArgument.w	__operand,-(sp)
				__sp:	set		__sp+2

			elseif (__type==".l")
				__FSTRING_PushArgument.l	__operand,-(sp)
				__sp:	set		__sp+4

			else
				error "Unrecognized type in string operand: \{__type}"
			endif

		endif

		; Cut string
		if (__pos>0)
			__str:	set		substr(__str, 0, __pos)
			__pos:	set		strstr(__str,"%<")
		else
			__pos:	set		-1
		endif

	endm

	endm

; ---------------------------------------------------------------
__FSTRING_GenerateDecodedString macro string

	__lpos:	set		0		; start position
	__pos:	set		strstr(string, "%<")

	while (__pos>=0)

		; Write part of string before % token
		if (__pos-__lpos>0)
			dc.b	substr(string, __lpos, __pos-__lpos)
		endif

		; Retrive expression in brakets following % char
    	__endpos:	set		strstr(substr(string,__pos+1,0),">")+__pos+1 
		if (__endpos<=__pos) ; Fix bizzare AS bug as stsstr() fails to check the last character of string
			__endpos:	set		strlen(string)-1
		endif
    	__midpos:	set		strstr(substr(string,__pos+5,0)," ")+__pos+5
    	if ((__midpos<__pos+5)||(__midpos>__endpos))
			__midpos:	set		__endpos
    	endif
		__type:		set		substr(string,__pos+1+1,2)		; .type

		; Expression is an effective address (e.g. %<.w d0 hex> )
		if ((strlen(__type)==2)&&(substr(__type,0,1)=="."))
			__param:	set		substr(string,__midpos+1,__endpos-__midpos-1)	; param

			; Validate format setting ("param")
			if (strlen(__param)<1)
				__param: 	set		"hex"			; if param is ommited, set it to "hex"
			elseif (__param=="signed")
				__param:	set		"hex+signed"	; if param is "signed", correct it to "hex+signed"
			endif

			if (val(__param) < $80)
				!error "Illegal operand format setting: \{__param}. Expected hex, dec, bin, sym, str or their derivatives."
			endif

			if (__type==".b")
				dc.b	val(__param)
			elseif (__type==".w")
				dc.b	val(__param)|1
			else
				dc.b	val(__param)|3
			endif

		; Expression is an inline constant (e.g. %<endl> )
		else
			dc.b	val(substr(string,__pos+1+1,__endpos-__pos-2))
		endif

		__lpos:	set		__endpos+1
		if (strstr(substr(string,__pos+1,0),"%<")>=0)
			__pos:	set		strstr(substr(string,__pos+1,0), "%<")+__pos+1
		else
			__pos:	set		-1
		endif

	endm

	; Write part of string before the end
	dc.b	substr(string, __lpos, 0), 0

	endm
