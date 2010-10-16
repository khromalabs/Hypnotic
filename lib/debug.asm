;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;  DEBUG rutines under PMODE
;  By Khroma/îxobit
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
; Some rutines adapted from Tran's code... O:-)
; Always thanx, guy...

	.386p			; I like it...
	jumps			; What shit is this?

 public _dosputmsg
 public _dosputhex
 public _dosputdec
 public	_videoputmsg

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; The Dirty Stuff
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
code32  segment para public use32
        assume cs:code32, ds:code32

include pmode.inc

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ _dosputmsg                                             ±
;±  FUNCTION:      ³ Prints a string on the screen via DOS realmode int     ±
;±  ASSUME:        ³ - EDX is the ASCIIZ text address                       ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
_dosputmsg:
	push edx
	push eax

	add edx,_code32a                ; Print message using INT 21h AH=9
	shld eax, edx, 28
	and edx, 0fh
	mov v86r_ds,ax
	mov v86r_dx,dx
	mov v86r_ah, 9
	mov al, 21h
	int 33h

	pop eax
	pop edx
	ret

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ _dosputhex                                             ±
;±  FUNCTION:      ³ Prints hex numbers on screen                           ±
;±  ASSUME:        ³ - EAX is the value to print                            ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 numchar  db  "0123456789ABCDEF"
 string	  db  "!!!!!!!!$"
_dosputhex:
	pushad
	mov edx, eax
	mov edi, offset string
	xor ebx, ebx
	mov cx, 8

@gethex:rol edx, 4
	mov bl, dl
	and bl, 0fh
	mov al, numchar[ebx]
	mov [edi], al
	inc edi
	dec cx
	jnz short @gethex

	mov edx, offset string
	call _dosputmsg
	popad
	ret

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ _dosputdec                                             ±
;±  FUNCTION:      ³ Prints dec numbers on screen                           ±
;±  ASSUME:        ³ - EAX is the value to print                            ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 stringd  db  "!!!!!!!!!!$"
_dosputdec:
	pushad
	mov ebx, eax
	mov edi, offset stringd+9
	mov cx, 10
	mov ebp, 1
	mov esi, 10

@getdec:mov eax, ebx
	xor edx, edx
	div ebp
	xor edx, edx
	div esi
	mov al, numchar[edx] 
	mov [edi], al
	dec edi
	mov eax, 10
	mul ebp
	mov ebp, eax
	dec cx
	jnz short @getdec

	mov edx, offset stringd
	call _dosputmsg
	popad
	ret


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ _videoputmsg                                           ±
;±  FUNCTION:      ³ Print a text string (direct video mem write)           ±
;±  ASSUME:        ³ - EDX is the pointer to the string, finished with a 0  ±
;±                 ³ - BL is the X (column)                                 ±
;±                 ³ - BH is the Y (row)                                    ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
; Note: Not working yet!!!
_videoputmsg:
	push esi edi

	movzx edi, bh
	movzx esi, bl

	lea  edi, [edi+edi*4]	              ; Equal to mul by 160, but
	shl  edi, 5          		      ; much faster ;)

	mov  ah, 7
	lea  edi, [edi+esi*2+0b8000h]
	sub  edi, _code32a
	mov  esi, edx

@@PutChar:
	mov  al, [esi]
	inc  esi
	test al,al
	jz   short @@VPMend
	mov  [edi], al
	inc  edi
	jmp  short @@PutChar

@@VPMend:
	pop edi esi
	ret

code32  ends
        end
