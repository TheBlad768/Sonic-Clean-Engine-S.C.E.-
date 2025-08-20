; ===========================================================================
; Macros setup
; ===========================================================================

	padding off		; we don't want AS padding out dc.b instructions
	listing purecode	; want listing file, but only the final code in expanded macros
	supmode on		; we don't need warnings about privileged instructions
	page 0			; don't want form feeds

notZ80 function cpu,(cpu<>128)&&(cpu<>32988)

; make org safer (impossible to overwrite previously assembled bytes)
org macro address
	if notZ80(MOMCPU)
.diff := address - *
		if .diff < 0
			error "too much stuff before org $\{address} ($\{(-.diff)} bytes)"
		else
			while .diff > 1024
				; AS can only generate 1 kb of code on a single line
				dc.b [1024]$FF
.diff := .diff - 1024
			endm
			dc.b [.diff]$FF
		endif
	else
		if address < $
			error "too much stuff before org 0\{address}h (0\{($-address)}h bytes)"
		else
			while address > $
				db 0
			endm
		endif
	endif
    endm

; define an alternate org that fills the extra space with 0s instead of FFs
org0 macro address
.diff := address - *
	if .diff < 0
		error "too much stuff before org0 $\{address} ($\{(-.diff)} bytes)"
	else
		while .diff > 1024
			; AS can only generate 1 kb of code on a single line
			dc.b [1024]0
.diff := .diff - 1024
		endm
		dc.b [.diff]0
	endif
    endm

; define the cnop pseudo-instruction
cnop macro offset,alignment
	if notZ80(MOMCPU)
		org (*-1+(alignment)-((*-1+(-(offset)))#(alignment)))
	else
		org ($-1+(alignment)-(($-1+(-(offset)))#(alignment)))
	endif
    endm

; define an alternate cnop that fills the extra space with 0s instead of FFs
cnop0 macro offset,alignment
	org0 (*-1+(alignment)-((*-1+(-(offset)))#(alignment)))
    endm

; redefine align in terms of cnop, because the built-in align can be stupid sometimes
align macro alignment
	cnop 0,alignment
    endm

; define an alternate align that fills the extra space with 0s instead of FFs
align0 macro alignment
	cnop0 0,alignment
    endm

; define the even pseudo-instruction
even macro
	align0 2
    endm

evenRAM macro
      if (*)&1
		ds.b 1
      endif
    endm

; define a trace macro
; lets you easily check what address a location in this disassembly assembles to
trace macro optionalMessageWithoutQuotes
	if MOMPASS=1
		ifnb ALLARGS
			message "#\{tracenum/1.0}: line=\{MOMLINE/1.0} PC=$\{(*)&$FFFFFFFF} msg=ALLARGS"
		else
			message "#\{tracenum/1.0}: line=\{MOMLINE/1.0} PC=$\{(*)&$FFFFFFFF}"
		endif
tracenum := (tracenum+1)
	endif
   endm
tracenum := 0

bit function nBits,1<<(nBits-1)
setBit function nBits,1<<(nBits)
signmask function val,nBits,-((-(val&bit(nBits)))&bit(nBits))
signextend function val,nBits,(val+signmask(val,nBits))!signmask(val,nBits)
signextendB function val,signextend(val,8)
roundFloatToInteger function float,INT(float+0.5)
min function a,b,b!((a!b)&(-(a<b)))
max function a,b,a!((a!b)&(-(a<b)))
chkop function op,ref,(substr(lowstring(op),0,strlen(ref))<>ref)
floor function a,b,a/b
ceil function a,b,(a+b-1)/b

; push registers to the stack
pushr macro op
	if ((strstr("op", "-") > 0) && (strstr("op", "(") < 0)) || ((strstr("op", "/") > 0) && (strstr("op", "(") < 0))
		movem.ATTRIBUTE	op,-(sp)
	else
		move.ATTRIBUTE	op,-(sp)
	endif
    endm

; pop registers from the stack
popr macro op
	if ((strstr("op", "-") > 0) && (strstr("op", "(") < 0)) || ((strstr("op", "/") > 0) && (strstr("op", "(") < 0))
		movem.ATTRIBUTE	(sp)+,op
	else
		move.ATTRIBUTE	(sp)+,op
	endif
    endm

; nop rept
nop macro fill
      if ("fill"="0") || ("fill"="")
		!nop
      else
	rept fill
		!nop
	endr
      endif
    endm

; alias ds as rs from asm68k compiler
rs macro
	ds.ATTRIBUTE ALLARGS
    endm

; alias binclude as incbin from asm68k compiler
incbin macro
	binclude ALLARGS
    endm

; dcb from asm68k compiler
dcb macro fill,byte
	dc.ATTRIBUTE [fill]byte
    endm
