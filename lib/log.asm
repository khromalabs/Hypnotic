_TEXT	segment byte use16 public 'CODE'	;size is 119
_TEXT	ends
_DATA	segment word use16 public 'DATA'	;size is 12
_DATA	ends
_BSS	segment word use16 public 'BSS'	;size is 0
_BSS	ends
DGROUP	group	_BSS,_DATA
	extrn	FIDRQQ
	extrn	FIWRQQ
	extrn	__turboFloat
	extrn	__matherr
	extrn	__huge_dble

	public	_log
_TEXT	segment
	assume	CS:_TEXT
_log:
		push	BP
		mov	BP,SP
		sub	SP,8
		push	SI
		fld	qword ptr 4[BP]
		mov	AX,0Ah[BP]
		shl	AX,1
		je	L1F
		jb	L42
		cmp	AX,0FFE0h
		je	L32
		int	03Eh
		hlt
		nop
		jmp short	L72
L1F:		mov	SI,2
		fld	qword ptr __huge_dble
		fchs
		fstp	qword ptr -8[BP]
		nop
		wait
		jmp short	L50
L32:		mov	SI,3
		fld	qword ptr __huge_dble
		fstp	qword ptr -8[BP]
		nop
		wait
		jmp short	L50
L42:		mov	SI,1
		fld	qword ptr DGROUP:_DATA[00h]
		fstp	qword ptr -8[BP]
		nop
		wait
L50:		fstp	ST
		fld	qword ptr -8[BP]
		sub	SP,8
		fstp	qword ptr -012h[BP]
		xor	AX,AX
		push	AX
		nop
		wait
		lea	AX,4[BP]
		push	AX
		mov	AX,offset DGROUP:_DATA[8]
		push	AX
		push	SI
		call	near ptr __matherr
		add	SP,010h
L72:		pop	SI
		mov	SP,BP
		pop	BP
		ret
_TEXT	ends
_DATA	segment
	db	000h,000h,000h,000h,080h,004h,0f8h,0ffh
D8	db	06ch,06fh,067h,000h
_DATA	ends
_BSS	segment
_BSS	ends
	end
