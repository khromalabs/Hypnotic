_TEXT	segment byte use16 public 'CODE'	;size is 305
_TEXT	ends
_DATA	segment word use16 public 'DATA'	;size is 22
_DATA	ends
_BSS	segment word use16 public 'BSS'	;size is 0
_BSS	ends
DGROUP	group	_BSS,_DATA
	extrn	FIDRQQ
	extrn	FIWRQQ
	extrn	__turboFloat
	extrn	___matherrl

	public	_acosl,_asinl
_TEXT	segment
	assume	CS:_TEXT
L0:		push	BP
		mov	BP,SP
		sub	SP,4
		push	SI
		mov	DX,6[BP]
		mov	SI,8[BP]
		mov	CX,8[SI]
		and	byte ptr 9[SI],07Fh
		fld	tempreal ptr [SI]
		shl	CX,1
		rcr	DH,1
		jcxz	L91
		cmp	CX,07FFEh
		jae	L7D
		fld1
		fld	ST1
		fmul	ST,ST(0)
		fsubp	ST(1),ST
		fsqrt
		fcom	ST(1)
		fstsw	-2[BP]
		mov	AH,041h
		nop
		wait
		and	AH,-1[BP]
		je	L4B
		add	AH,AH
		js	LBE
		fxch	ST1
		not	DL
L4B:		fpatan
		or	DL,DL
		je	L67
		mov	word ptr -4[BP],0FFFFh
		fld	word ptr -4[BP]
		fldpi
		fscale
		fstp	ST(1)
		fsubrp	ST(1),ST
L67:		or	DH,DH
		jns	L7A
		fchs
		cmp	byte ptr 6[BP],0FFh
		jne	L7A
		fldpi
		faddp	ST(1),ST
L7A:		jmp	near ptr LFF
L7D:		ja	LD8
		mov	AX,6[SI]
		xor	AH,080h
		or	AX,4[SI]
		or	AX,2[SI]
		or	AX,[SI]
		jne	LD8
		jmp short	LA1
L91:		mov	DH,0
		fstp	ST
		cmp	byte ptr 6[BP],0FFh
		je	LAA
L9C:		fldz
		jmp short	L67
LA1:		fstp	ST
		cmp	byte ptr 6[BP],0FFh
		je	L9C
LAA:		mov	word ptr -4[BP],0FFFFh
		fld	word ptr -4[BP]
		fldpi
		fscale
		fstp	ST(1)
		jmp short	L67
LBE:		fstp	ST
		fstp	ST
		mov	word ptr -4[BP],0FFFEh
		fld	word ptr -4[BP]
		fldpi
		fscale
		fstp	ST(1)
		jmp short	L67
LD8:		or	9[SI],DH
		fstp	ST
		fld	tempreal ptr DGROUP:_DATA[00h]
		sub	SP,0Ah
		fstp	tempreal ptr -010h[BP]
		xor	AX,AX
		push	AX
		nop
		wait
		push	word ptr 8[BP]
		push	word ptr 4[BP]
		mov	AX,1
		push	AX
		call	near ptr ___matherrl
		add	SP,012h
LFF:		pop	SI
		mov	SP,BP
		pop	BP
		ret
_acosl:
		push	BP
		mov	BP,SP
		lea	AX,4[BP]
		push	AX
		mov	AX,0FFh
		push	AX
		mov	AX,offset DGROUP:_DATA[0Ah]
		push	AX
		call	near ptr L0
		add	SP,6
		pop	BP
		ret
_asinl:
		push	BP
		mov	BP,SP
		lea	AX,4[BP]
		push	AX
		xor	AX,AX
		push	AX
		mov	AX,offset DGROUP:_DATA[010h]
		push	AX
		call	near ptr L0
		add	SP,6
		pop	BP
		ret
_TEXT	ends
_DATA	segment
	db	000h,000h,000h,000h,000h,000h,022h,0c0h
	db	0ffh,07fh
DA	db	061h,063h,06fh,073h,06ch,000h
D10	db	061h,073h,069h,06eh,06ch,000h
_DATA	ends
_BSS	segment
_BSS	ends
	end
