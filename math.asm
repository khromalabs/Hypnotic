;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;                        EXOMOTION Copyright (c) 1995
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;                         Khroma (A.K.A. Rub‚n G¢mez)
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

  .386p
  jumps

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  D e f i n i c i o n e s
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 include kb.inc
 include debug.inc
 include pmode.inc
 include structs.inc

 public SETMAT
 public ROTAR
 public ROTAR2
 public SITUAR
 public SITUAR2
 public PROYECTAR
 public ON_SCREEN
 public RADIXSORT
 public GETSHADECOL
 public GENSIN
 public NORMALIZE
 public CLOCK_OK
 public GETTEXTCOORDS 
 public TESTROT
; public AVERAGEDOT

; Devuelve el seno y el coseno de un valor
 sincos MACRO                  ;; eax = sin(bx) * 65536
	mov ebp, sintab        ;; edx = cos(bx) * 65536
	mov si, bx       
	add si, (192*32)
	and ebx, (256*32)-1
	and esi, (256*32)-1
	mov eax, [ebp][ebx*4]
	mov edx, [ebp][esi*4]
 ENDM

; Valor absoluto
 @abs MACRO reg
 	cmp &reg, 0
 	jge short $+4
 	neg &reg
 ENDM

 SXC  = 160*65536
 SYC  = 120*65536

code32  segment para public use32
	assume cs:code32, ds:code32

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  C ¢ d i g o
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO:³ GENSIN (Generate Sines)                                   ±
;±---------------³-----------------------------------------------------------±
;± FUNCION:      ³ Genera una tabla de seno                                  ±
;±---------------³-----------------------------------------------------------±
;± PARAMETROS:   ³ EDI: Offset de la tabla                                   ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 base	  dd    4096.0
 fixed	  dd    65536.0
 INCR	  equ   dword ptr [esp+4]
 VAL_RAD  equ   dword ptr [esp+8]
;-----------------------------------------------------------------------------
 align 16
 GENSIN PROC

	sub   esp, 12

	finit
	fldpi
	fdiv  base
	fstp  INCR

	mov   ecx, 256*32
	xor   eax, eax
	mov   VAL_RAD, eax


@gensin@next:
	fld   VAL_RAD
	fsin
	fmul  fixed	
	fistp dword ptr [esp]
	mov   eax, [esp]

	stosd
	fld   VAL_RAD
	fadd  INCR
	fstp  VAL_RAD

	loop  @gensin@next  

	add   esp, 12
	ret	      
 ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO:³ SETMAT (Set Matrix)                                       ±
;±---------------³-----------------------------------------------------------±
;± FUNCION:      ³ Crea la una matriz de giro para una lista de vectores     ±
;±---------------³-----------------------------------------------------------±
;± PARAMETROS:   ³ EBX = MATRIZ, EDI = Vector Rotaci¢n                       ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 align 16
 SETMAT PROC
	push ebx

	
	mov bx, word ptr [edi+2].x
	sincos
	mov KXSin, eax
	mov KXCos, edx

	mov bx, word ptr [edi+2].y
	sincos
	mov KYSin, eax
	mov KYCos, edx

	mov bx, word ptr [edi+2].z
	sincos
	mov KZSin, eax
	mov KZCos, edx

	pop edi

	mov  eax, KZCos          ; MATRIZ[0][0] = CY*CZ + SX*SY*SZ
	imul KYCos
	shrd eax, edx, 16
	mov  ebx, eax
	mov  eax, KZSin
	imul KXSin
	shrd eax, edx, 16
	mov  edx, eax
	mov  eax, KYSin
	imul edx
	shrd eax, edx, 16
	add  eax, ebx
	mov  [edi].x0, eax

	mov  eax, KZSin          ; MATRIZ[1][0] = -SZ*CY + SX*SY*CZ
	neg  eax
	imul KYCos
	shrd eax, edx, 16
	mov  ebx, eax
	mov  eax, KZCos
	imul KXSin
	shrd eax, edx, 16
	mov  edx, eax
	mov  eax, KYSin
	imul edx
	shrd eax, edx, 16
	add  eax, ebx
	mov  [edi].y0, eax

	mov  eax, KXCos          ; MATRIZ[2][0] = SY*CX
	imul KYSin
	shrd eax, edx, 16
	mov  [edi].z0, eax

	mov  eax, KZSin          ; MATRIZ[0][1] = SZ*CX
	imul KXCos
	shrd eax, edx, 16
	mov  [edi].x1, eax

	mov  eax, KZCos          ; MATRIZ[1][1] = CZ*CX
	imul KXCos
	shrd eax, edx, 16
	mov  [edi].y1, eax

	mov  eax, KXSin          ; MATRIZ[2][1] = -SX
	neg  eax
	mov  [edi].z1, eax

	mov  eax, KZCos          ; MATRIZ[0][2] = -CZ*SY + SX*SZ*CY
	neg  eax
	imul KYSin
	shrd eax, edx, 16
	mov  ebx, eax
	mov  eax, KZSin
	imul KXSin
	shrd eax, edx, 16
	mov  edx, eax
	mov  eax, KYCos
	imul edx
	shrd eax, edx, 16
	add  eax, ebx
	mov  [edi].x2, eax


	mov  eax, KZSin          ; MATRIZ[1][2] = SY*SZ + SX*CY*CZ
	imul KYSin
	shrd eax, edx, 16
	mov  ebx, eax
	mov  eax, KZCos
	imul KXSin
	shrd eax, edx, 16
	mov  edx, eax
	mov  eax, KYCos
	imul edx
	shrd eax, edx, 16
	add  eax, ebx
	mov  [edi].y2, eax

	mov  eax, KXCos          ; MATRIZ[2][2] = CX*CY
	imul KYCos
	shrd eax, edx, 16
	mov  [edi].z2, eax

	push cx
	lea  esi, [edi].xy0
	mov  cx, 3

@@pcab:	mov  eax, [edi].x0
	imul [edi].y0
	shrd eax, edx, 16
	mov  [esi], eax
	
	add  edi, 4
	add  esi, 4
	dec  cx
	jnz  short @@pcab

	pop cx
	ret
 ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO:³ ROTAR                                                     ±
;±---------------³-----------------------------------------------------------±
;± FUNCION:      ³ Rota una lista de vectores con los valores de la matriz   ±
;±               ³ alterando la definici¢n original de los mismos            ±
;±---------------³-----------------------------------------------------------±
;± PARAMETROS:   ³ EDI: Vector IN; EBP: Vector OUT; ESI: MATRIZ              ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 align 16
 ROTAR PROC


	test cx, cx	       ; N§ de puntos
	jnz  short RotL
	mov  cx, [edi]
	mov  [ebp], cx
	add  edi, size numdots
	add  ebp, size numdots

	
RotL:	mov  eax, [edi].x
	imul [edi].y
	shrd eax, edx, 16
	mov  ebp, eax

	mov  eax, [esi].x0	; Px = [(a+y)*(b+x)] + (c*z) - (x*y) - (a*b)
	add  eax, [edi].y
	mov  ebx, eax
	mov  eax, [esi].y0
	add  eax, [edi].x
	imul ebx
	shrd eax, edx, 16
	mov  ebx, eax
	mov  eax, [edi].z
	imul [esi].z0
	shrd eax, edx, 16
	add  eax, ebx
	sub  eax, ebp
	sub  eax, [esi].xy0
	mov  [edi].Point2.x, eax


	mov  eax, [esi].x1	; Py = [(d+y)*(e+x)] + (f*z) - (x*y) - (d*e)
	add  eax, [edi].y
	mov  ebx, eax
	mov  eax, [esi].y1
	add  eax, [edi].x
	imul ebx
	shrd eax, edx, 16
	mov  ebx, eax
	mov  eax, [edi].z
	imul [esi].z1
	shrd eax, edx, 16
	add  eax, ebx
	sub  eax, ebp
	sub  eax, [esi].xy1
	mov  [edi].Point2.y, eax


	mov  eax, [esi].x2	; Pz = [(g+y)*(h+x)] + (i*z) - (x*y) - (f*g)
	add  eax, [edi].y
	mov  ebx, eax
	mov  eax, [esi].y2
	add  eax, [edi].x
	imul ebx
	shrd eax, edx, 16
	mov  ebx, eax
	mov  eax, [edi].z
	imul [esi].z2
	shrd eax, edx, 16
	add  eax, ebx
	sub  eax, ebp
	sub  eax, [esi].xy2
	mov  [edi].Point2.z, eax

	add  edi, size Vertx

	dec  cx
	jnz  RotL
	ret
 ENDP


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO:³ ROTAR2                                                    ±
;±---------------³-----------------------------------------------------------±
;± FUNCION:      ³ Rota una lista de vectores con los valores de la matriz   ±
;±               ³ alterando la definici¢n original de los mismos            ±
;±---------------³-----------------------------------------------------------±
;± PARAMETROS:   ³ EDI: Vector IN; EBP: Vector OUT; ESI: MATRIZ              ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 align 16
 ROTAR2 PROC


	
	test cx, cx	       ; N§ de puntos
	jnz  short @RotL
	mov  cx, [edi]
	mov  [ebp], cx
	add  edi, size numdots
	add  ebp, size numdots

	
@RotL:	mov  eax, [edi].x
	imul [edi].y
	shrd eax, edx, 16
	mov  ebp, eax


	mov  eax, [esi].x0	; Px = [(a+y)*(b+x)] + (c*z) - (x*y) - (a*b)
	add  eax, [edi].y
	mov  ebx, eax
	mov  eax, [esi].y0
	add  eax, [edi].x
	imul ebx
	shrd eax, edx, 16
	mov  ebx, eax
	mov  eax, [edi].z
	imul [esi].z0
        shrd eax, edx, 16
	add  eax, ebx
	sub  eax, ebp
	sub  eax, [esi].xy0
	push eax


	mov  eax, [esi].x1	; Py = [(d+y)*(e+x)] + (f*z) - (x*y) - (d*e)
	add  eax, [edi].y
	mov  ebx, eax
	mov  eax, [esi].y1
	add  eax, [edi].x
	imul ebx
	shrd eax, edx, 16
	mov  ebx, eax
	mov  eax, [edi].z
	imul [esi].z1
	shrd eax, edx, 16
	add  eax, ebx
	sub  eax, ebp
	sub  eax, [esi].xy1
	push eax


	mov  eax, [esi].x2	; Pz = [(g+y)*(h+x)] + (i*z) - (x*y) - (f*g)
	add  eax, [edi].y
	mov  ebx, eax
	mov  eax, [esi].y2
	add  eax, [edi].x
	imul ebx
	shrd eax, edx, 16
	mov  ebx, eax
	mov  eax, [edi].z
	imul [esi].z2
	shrd eax, edx, 16
	add  eax, ebx
	sub  eax, ebp
	sub  eax, [esi].xy2
	mov  [edi].z, eax

	pop  [edi].y

	pop  [edi].x

	add  edi, size Vertx

	dec  cx
	jnz  @RotL
	
	ret
 ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO:³ SITUAR                                                    ±
;±---------------³-----------------------------------------------------------±
;± FUNCION:      ³ Obtiene el vector posici¢n (Camara-Posicion)              ±
;±---------------³-----------------------------------------------------------±
;± PARAMETROS:   ³ ESI: V Pos; EDI: V C mara; EBX: Matriz                    ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 align 16
 SITUAR  PROC

	mov eax, [esi].x          ; EBX = Transformaci¢n eje X
	sub eax, [edi].x
	sub [ebx].xy0, eax

	mov eax, [esi].y          ; EDX = Transformaci¢n eje Y
	sub eax, [edi].y
	sub [ebx].xy1, eax

	mov eax, [esi].z          ; EBP = Transformaci¢n eje Z
	sub eax, [edi].z
	sub [ebx].xy2, eax

	ret
 ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO:³ TESTROT                                                   ±
;±---------------³-----------------------------------------------------------±
;± FUNCION:      ³ Comprueba si un objeto debe ser rotado...                 ±
;±---------------³-----------------------------------------------------------±
;± PARAMETROS:   ³ EDI: Vector de rotaci¢n del objeto...                     ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 align 16
 TESTROT  PROC

	cmp word ptr [edi+2].x, 0
	jne short exit@cf
	cmp word ptr [edi+2].y, 0
	jne short exit@cf
	cmp word ptr [edi+2].z, 0
	jne short exit@cf

	clc
	ret

exit@cf:
	stc
	ret

 ENDP


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO:³ SITUAR2                                                   ±
;±---------------³-----------------------------------------------------------±
;± FUNCION:      ³ Situa un objeto en su posici¢n                            ±
;±---------------³-----------------------------------------------------------±
;± PARAMETROS:   ³ ESI: V Pos; EBP: V C mara; EDI: Objeto; CX:N de vectores  ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 align 4
 desprel	dot3d	?
 align 16
 SITUAR2  PROC


; Precalcula las transformaciones (Posici¢n objeto-posici¢n c mara)
	mov  eax, [esi].pos.x
	sub  eax, [ebp].pos.x
        mov  desprel.x, eax
	mov  eax, [esi].pos.y
	sub  eax, [ebp].pos.y
        mov  desprel.y, eax
	mov  eax, [esi].pos.z
	sub  eax, [ebp].pos.z
        mov  desprel.z, eax

st2@innerloop:
; Transforma el vector...
	mov  eax, [edi].Point.x   
	mov  ebx, [edi].Point.y   
	mov  edx, [edi].Point.z   
	add  eax, desprel.x
	add  ebx, desprel.y
	add  edx, desprel.z
	mov  [edi].Point2.x, eax
	mov  [edi].Point2.y, ebx
	mov  [edi].Point2.z, edx

;comment ‡
	mov  eax, [edi].Normal.x
	mov  ebx, [edi].Normal.y
	mov  edx, [edi].Normal.z
	mov  [edi].Normal2.x, eax
	mov  [edi].Normal2.y, ebx
	mov  [edi].Normal2.z, edx
;‡

	add  edi, size Vertx
	dec  cx
	jnz  short st2@innerloop

	ret
 ENDP


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO:³ PROYECTAR                                                 ±
;±---------------³-----------------------------------------------------------±
;± FUNCION:      ³ Transforma los vectores en pixels                         ±
;±---------------³-----------------------------------------------------------±
;± PARAMETROS:   ³ ESI: VECTOR                                               ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 align 16
 PROYECTAR PROC

	mov   screen.miny, 0
	mov   screen.miny+4, 0
	mov   screen.maxy, 239*UNO
	mov   screen.maxy+4, 239*UNO

        mov   cx, [esi]
	add   esi, size numdots
	
inidot:	mov  ebx, [esi].Point2.z
	@abs ebx
	cmp  ebx, 65536
	jl   short nexdot
	mov  ebx, [esi].Point2.z


	mov  eax, [esi].Point2.x   ; Punto_x = ((V.x * 256) / V.z) + x_centro
	mov  edx, eax
	sar  edx, 16
	shl  eax, 16
	idiv ebx
	shl  eax, 8
	add  eax, SXC
	xor  ax, ax
	mov  [esi].Pixel.x, eax

	mov  eax, [esi].Point2.y   ; Punto_y = ((V.y * -256) / V.z) + y_centro
	mov  edx, eax
	sar  edx, 16
	shl  eax, 16
	idiv ebx
	shl  eax, 8
	add  eax, SYC
	xor  ax, ax
	mov  [esi].Pixel.y, eax

nexdot: add esi, size Vertx
	dec cx
	jnz short inidot

@p@end: ret

  ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO:³ GETTEXTCOORDS                                             ±
;±---------------³-----------------------------------------------------------±
;± FUNCION:      ³ Obtiene las coordenadas de la textura (enviroment-mapping)±
;±---------------³-----------------------------------------------------------±
;± PARAMETROS:   ³ ESI: VECTOR LIST                                          ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 align 16
 GETTEXTCOORDS PROC
 	pushad

	mov  cx, [esi].numdots
	add  esi, 2

inimap:	mov  ebx, [esi].Normal2.z
	@abs ebx

     	cmp  ebx, 65536*4
	jge  short noshift_x
	mov  ebx, 65536*4

noshift_x:
	mov  eax, [esi].Normal2.x   ; Punto_x = ((V.x * 256) / V.z) + x_centro
	mov  edx, eax
	sar  edx, 16
	shl  eax, 16
	idiv ebx
	neg  eax
	shl  eax, 8
	add  eax, 128*65536
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	cmp  eax, 256*65536
	jl   short noz
	mov  eax, 255*65536  
	jmp  short @noz
noz:	cmp  eax, 0
	jg   short @noz
	mov  eax, 0
@noz:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	mov  [esi].Map.v, eax

	mov  eax, [esi].Normal2.y   ; Punto_y = ((V.y * -256) / V.z) + y_centro
	mov  edx, eax
	sar  edx, 16
	shl  eax, 16
	idiv ebx
	neg  eax
	shl  eax, 8
	add  eax, 128*65536
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	cmp  eax, 256*65536
	jl   short noz2
	mov  eax, 255*65536
	jmp  short @noz2
noz2:	cmp  eax, 0
	jg   short @noz2
	mov  eax, 0
@noz2:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	mov  [esi].Map.u, eax

nexmap: add esi, size Vertx
	dec cx
	jnz inimap

 	popad
	ret

  ENDP


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO:³ ON_SCREEN                                                 ±
;±---------------³-----------------------------------------------------------±
;± FUNCION:      ³ Realiza el trivial-rejection                              ±
;±---------------³-----------------------------------------------------------±
;± PARAMETROS:   ³ EDI: Pol¡gono 3D                                          ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 align 16
 ON_SCREEN PROC
	pushad
	xor  bx, bx

comment ³
;TEST 1: Comprueba que la coordenada Z > 4 && < 5000
@dot1:  mov  eax, [edi].poly.dot.z
	cmp  eax, 4*UNO
	jle  short @dot2
	cmp  eax, 5000*UNO
	jge  short @dot2
	or   bl, 001b

@dot2:	mov  eax, [edi+12].poly.dot.z
	cmp  eax, 4*UNO
	jle  short @dot3
	cmp  eax, 5000*UNO
	jge  short @dot3
	or   bl, 010b

@dot3:	mov  eax, [edi+24].poly.dot.z
	cmp  eax, 4*UNO
	jle  short @t000
	cmp  eax, 5000*UNO
	jge  short @t000
	or   bl, 100b

@t000:	cmp  bl, 111b
	jne  short @os@nv

;TEST 2: Comprueba que  X < Z && Y < Z 
	mov  bh, 1
	xor  bl, bl
	mov  cx, 3

@txz:	mov  edx, [edi].poly.dot.z
	mov  eax, [edi].poly.dot.x
	@abs eax
	lea  eax, [eax*2+eax]
       	cmp  eax, edx
	jge  short @os@nextdot
@txy:	mov  eax, [edi].poly.dot.y
	@abs eax
       	cmp  eax, edx
	jge  short @os@nextdot
	
	or   bl, bh

@os@nextdot:
	shl  bh, 1
	add  edi, 12
	dec  cx
	jnz  short @txz

        cmp  bl, 000b
	je   short @os@nv

	popad
	clc
	ret
³
@os@nv:	popad
	stc
	ret
  ENDP


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ RADIXSORT                                                ±
;±----------------³----------------------------------------------------------±
;± FUNCION:       ³ Ordena los pol¡gonos con el algoritmo RADIX (FAAAST! ;)  ±
;±----------------³----------------------------------------------------------±
;± PARAMETROS:    ³ ESI: Ptr a la lista de pol¡gonos                         ±
;±                ³ EDI: Ptr al array resevado para el ZBUFFER               ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 align 4
 ZBUFFER        dd      ?
 NPOLS		dd	?
 stkC		dw	16 dup(?)
 shifter	db	?

 align 16
 RADIXSORT PROC

	xor  ecx, ecx
	mov  cx, word ptr [esi]
	add  esi, 2
	mov  NPOLS, ecx
	mov  ZBUFFER, edi
	xor  ebx, ebx
	inc  cx
	
	cmp NPOLS, 0
	je  @rx@exit

	mov shifter, 0
@rx@radixshort:
; Inicia los 16 contadores de las pilas de 2 en 2
	xor eax, eax
	mov dword ptr [stkC], eax
	mov dword ptr [stkC+04], eax
	mov dword ptr [stkC+08], eax
	mov dword ptr [stkC+12], eax
	mov dword ptr [stkC+16], eax
	mov dword ptr [stkC+20], eax
	mov dword ptr [stkC+24], eax
	mov dword ptr [stkC+28], eax

	xor ebp, ebp
	mov esi, stackbase
	mov edi, ZBUFFER		; EDI = Ptr al Zbuffer
	mov edx, NPOLS			; EDX = N§ de pol¡gonos (Contador)
	mov cl,  shifter

; Introduce cada n£mero en su pila adecuada por su d¡gito
@rx@loop1:
	mov bp, [edi+02]		; BP = Valor Z medio
	shr bp, cl
	and ebp, 1111b			; BP contiene un valor de 0 a 15
	mov ebx, ebp
;-------------------
	shl ebx, 14			; BX = Direcci¢n de la pila
;-------------------
	xor eax, eax
	mov ax, stkC[ebp*2]
	shl eax, 2			; Multiplica por 4
	add ebx, eax			; Sumamos el contador de offset
	inc stkC[ebp*2]			; Incrementamos dicho contador (wp ?)

	add ebx, esi      		; Sumamos la direcci¢n en memoria
	mov eax, [edi]			; base de las pilas
	mov [ebx], eax			; Guardamos el n£mero en la pila

	add edi, 4
	dec dx
	jnz short @rx@loop1

; Reordena las 15 pilas en el array inicial
	mov edi, ZBUFFER
	mov edx, 15
	mov ebx, (4096*4*16) - (4096*4)

@rx@loop2:
	mov  cx, stkC[edx*2]
	test cx, cx
	jz   short @rx@nextstk
	mov  esi, stackbase

@rx@loop2@inner:
	mov eax, [esi+ebx]
	mov [edi], eax
	add esi, 4
	add edi, 4
	dec cx
	jnz short @rx@loop2@inner

@rx@nextstk:
	sub ebx, 4096*4
	dec edx
	jns short @rx@loop2

	add shifter, 4
	cmp shifter, 16
	jb  @rx@radixshort

@rx@exit:
	ret
  ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO:³ GETSHADECOL                                               ±
;±---------------³-----------------------------------------------------------±
;± FUNCION:      ³ Obtiene el sombreado correspondiente a un vector          ±
;±---------------³-----------------------------------------------------------±
;± PARAMETROS:   ³ EBP: Ptr al vector                                        ±
;±               ³ EDI: Ptr a la fuente de luz                               ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
; extrn ACtableptr:dword
 align 4
 ; Tabla de arccosenos invertida y ajusta a iluminaci¢n en 32 niveles
 GSC_Arctab db 0,1,2,2,3,4,4,5,6,6,7,8,8,9,10,10,11,12,13,14,14,15,16,17,18
	    db 19,20,21,23,24,26,31

 align 16
 GETSHADECOL  PROC

comment ‡
	mov  eax, [ebp].Normal2.x
	imul [edi].x
	shrd eax, edx, 16
	mov  ebx, eax

	mov  eax, [ebp].Normal2.y
	imul [edi].y
	shrd eax, edx, 16
	add  ebx, eax

	mov  eax, [ebp].Normal2.z
	imul [edi].z
	shrd eax, edx, 16
	add  eax, ebx

	 
	cmp  eax, 0
	jge  short @ndaz
	xor  eax, eax
@ndaz:	cmp  eax, 0ffffh
	jle  short @ndaz2
	mov  eax, 0ffffh

@ndaz2:

	push ebx
	push ebp
	mov  ebp, ACtableptr
	shr  eax, 2  ;2
	movzx ebx, word ptr [ebp+eax*2]
 	shr  ebx, 11+8+3-16+1 ;+4
	mov  eax, ebx
	pop  ebp
	pop  ebx

	ret
‡

	mov  eax, [ebp].Normal2.x
	imul [edi].x
	shrd eax, edx, 16
	mov  ebx, eax

	mov  eax, [ebp].Normal2.y
	imul [edi].y
	shrd eax, edx, 16
	add  ebx, eax

	mov  eax, [ebp].Normal2.z
	imul [edi].z
	shrd eax, edx, 16
	add  eax, ebx


 	sar  eax, 11
 
 	cmp  eax, 31
	jle  short @ndaz
	mov  eax, 31 
@ndaz:	cmp  eax, 0
	jge  short @ndaz2
	mov  eax, 0 
@ndaz2:

	movzx  eax, GSC_Arctab[eax]

	ret


  ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ CROSSPROD                                                ±
;±----------------³----------------------------------------------------------±
;± FUNCION:       ³ Calcula el producto vectorial entre 2 vectores           ±
;±----------------³----------------------------------------------------------±
;± PARAMETROS:    ³ ESI: Ptr a Vector 1                                      ±
;±                ³ EDI: Ptr a Vector 2                                      ±
;±                ³ EBP: Ptr a Vector Normal                                 ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 align 16
 CROSSPROD PROC

	mov  eax, [esi].y            ; Normal.x = (Va.y*Vb.z - Va.z*Vb.y)
	imul [edi].z
	shrd eax, edx, 16
	mov  ebx, eax
	mov  eax, [esi].z
	imul [edi].y
	shrd eax, edx, 16
	sub  ebx, eax
	mov  [ebp].x, ebx

	mov  eax, [esi].z            ; Normal.y = (Va.z*Vb.x - Va.x*Vb.z)
	imul [edi].x
	shrd eax, edx, 16
	mov  ebx, eax
	mov  eax, [esi].x
	imul [edi].z
	shrd eax, edx, 16
	sub  ebx, eax
	mov  [ebp].y, ebx

	mov  eax, [esi].x            ; Normal.z = (Va.x*Vb.y - Va.y*Vb.x)
	imul [edi].y
	shrd eax, edx, 16
	mov  ebx, eax
	mov  eax, [esi].y
	imul [edi].x
	shrd eax, edx, 16
	sub  ebx, eax
	mov  [ebp].z, ebx

	ret

   ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ NORMALIZE                                                ±
;±----------------³----------------------------------------------------------±
;± FUNCION:       ³ Normaliza el valor de un vector (Lo divide entre su mag) ±
;±----------------³----------------------------------------------------------±
;± PARAMETROS:    ³ EBP: Ptr a vector  a normalizar                          ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 align  4
 Tnormal	dot3d	<?,?,?>
 sedx		db	?  ;26, 28, 30, 32
 seax		db	?  ; 6,  4,  2,  0
 ssqrt		db	?  ; 3,  2,  1,  0
;-----------------------------------------------------------------------------
 align 16
 NORMALIZE PROC

	mov   sedx, 26
	mov   seax,  6
	mov   ssqrt, 3

	mov   eax, [ebp].x
	mov   Tnormal.x, eax
	mov   eax, [ebp].y
	mov   Tnormal.y, eax
	mov   eax, [ebp].z
	mov   Tnormal.z, eax
	
; Calcula los valores absolutos
	xor   eax, eax
 	cmp   Tnormal.x, eax
 	jge   short @test_y
 	neg   Tnormal.x

@test_y:cmp   Tnormal.y, eax
	jge   short @test_z
 	neg   Tnormal.y

@test_z:cmp   Tnormal.z, eax
 	jge   short @nm@magnitude
 	neg   Tnormal.z

; Calculamos la magnitud del vector
@nm@magnitude:
	mov   cl, sedx
	mov   eax, Tnormal.x
	mul   eax
	shrd  eax, edx, cl
	mov   ebx, eax

	mov   eax, Tnormal.y
	mul   eax
	shrd  eax, edx, cl
	add   ebx, eax

	mov   eax, Tnormal.z
	mul   eax
	shrd  eax, edx, cl
	add   eax, ebx
	jo    @floatpoint
	jc    @floatpoint

        call  SQRT

	mov   ebx, eax                    ; EBX = û(X^2 + Y^2 + Z^2)
	test  ebx, ebx
	jz    @floatpoint

	movzx edx, ssqrt
	
	mov   cl, ssqrt
	test  cl, cl
	je    @div2
	shl   ebx, cl

; Dividimos los 3 scalars del vector entre la magnitud
	mov   eax, [ebp].x
	mov   edx, eax
	mov   cl, sedx
        sar   edx, cl
	mov   cl, seax
	shl   eax, cl
	idiv  ebx
	mov   [ebp].x, eax

	mov   eax, [ebp].y
	mov   edx, eax
	mov   cl, sedx
        sar   edx, cl
	mov   cl, seax
	shl   eax, cl
	idiv  ebx
	mov   [ebp].y, eax

	mov   eax, [ebp].z
	mov   edx, eax
	mov   cl, sedx
        sar   edx, cl
	mov   cl, seax
	shl   eax, cl
	idiv  ebx
	mov   [ebp].z, eax
	
	ret
	
@div2:	mov   eax, [ebp].x
	mov   edx, eax
	sar   edx, 31
	idiv  ebx
	mov   [ebp].x, eax

	mov   eax, [ebp].y
	mov   edx, eax
	sar   edx, 31
	idiv  ebx
	mov   [ebp].y, eax

	mov   eax, [ebp].z
	mov   edx, eax
	sar   edx, 31
	idiv  ebx
	mov   [ebp].z, eax
 	
	ret

@floatpoint:
	add   sedx, 2
        sub   seax, 2
	dec   ssqrt
	cmp   ssqrt, 0
	jge   @nm@magnitude
	mov   [ebp].x, 37837
	mov   [ebp].y, 37837
	mov   [ebp].z, 37837
	ret
	
   ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO:  ³ SQRT                                                    ±
;±-----------------³---------------------------------------------------------±
;± FUNCION:        ³ Halla la ra¡z cuadrada de un entero                     ±
;±-----------------³---------------------------------------------------------±
;± PARAMETROS:     ³ EAX: N£mero a hallar la ra¡z                            ±
;±-----------------³---------------------------------------------------------±
;± SALIDA:         ³ EAX: Ra¡z                                               ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 align 16
 SQRT PROC
	push ebp

	mov ebp, 16		; EBP es el contador (Hay 15 iteraciones)
	mov ebx, eax 		; EBX: Resto
	xor esi, esi		; ESI: Resultado
	mov ecx, esi

@sqrt@loop:
	dec bp
	jz  short sqrt@done

	mov edi, esi
	mov cx, bp
	inc cx
	shl edi, cl			; EDI = (answer << iteration+1)

	dec cx
	add edi, shtable[ecx*8]		; EAX = (1 << iteration * 2)

	cmp ebx, edi
	jl  short @sqrt@loop

	sub ebx, edi
	mov cx, bp
	add esi, shtable[ecx*4]		; ESI = ESI + 1 << iteration
	jmp short @sqrt@loop

sqrt@done:
	mov eax, esi
 	pop ebp
	ret
  ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO:³ CLOCK_OK                                                  ±
;±---------------³-----------------------------------------------------------±
;± FUNCION:      ³ Comprueba si un tri ngulo projectado contin£a en el       ±
;±               ³ sentido de las agujas del reloj (Sentido de la normal)    ±
;±---------------³-----------------------------------------------------------±
;± PARAMETROS:   ³ EDI: PIXEL                                                ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 align 16
 CLOCK_OK PROC

	mov eax, [esi].Pixel.x   ; EAX = Centro.x
	mov ecx, eax             ; ECX = pix[0].x
	add eax, [edi].Pixel.x
	sar eax, 1
	mov ebx, [esi].Pixel.y   ; EBX = Centro.y
	mov edx, ebx             ; EDX = pix[0].y
	add ebx, [edi].Pixel.y
	sar ebx, 1

	sub ecx, eax             ; ECX = pix[0].x
	sub edx, ebx             ; EDX = pix[0].y

	mov edi, edx             ; EBP = pix[0].y + Cen.x
	mov esi, ecx             ; ESI = pix[0].x + Cen.y
	add edi, eax
	add esi, ebx
	mov N1_x, edi
	mov N2_y, esi

	neg ecx
	neg edx
	add edx, eax            ; EDX = -pix[0].y + Cen.x
	add ecx, ebx            ; ECX = -pix[0].x + Cen.y

	mov edi, [ebp].Pixel.x	; EBP =  pix[2].x
	mov esi, [ebp].Pixel.y	; ESI =  pix[2].y
	mov eax, edi
	mov ebx, esi

	mov ebp, sqtable
	sub eax, N1_x
	sar eax, 16              ; EAX = pix[2].x - N1.x >> 16
	sub ebx, ecx
	sar ebx, 16              ; EBX = pix[2].y - N1.y >> 16
	sub edi, edx
	sar edi, 16              ; EBP = pix[2].x - N2.x >> 16
	sub esi, N2_y
	sar esi, 16              ; EDI = pix[2].y - N2.y >> 16

	mov eax, [ebp][eax*4]	 ; imul eax, eax
	mov ebx, [ebp][ebx*4]	 ; imul ebx, ebx
	mov edi, [ebp][edi*4]	 ; imul edi, edi
	add esi, [ebp][esi*4]	 ; imul esi, esi

	add eax, ebx
	add edi, esi
	
	cmp eax, edi
	jg  short vis

	stc
	ret
vis:	clc
	ret
  ENDP

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  D a t o s
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 align 4
 shtable  dd	1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192
 	  dd	16384, 32768, 65536, 65536*2, 65536*4, 65536*8, 65536*16
 	  dd    65536*32, 65536*64, 65536*128, 65536*256, 65536*512,65536*1024
 	  dd	65536*2048, 65536*4096, 65536*8192, 65536*16384, 65536*32728

 sintab   dd	?
 KXSin	  dd	?               ; Coeficientes donde se almacenan
 KXCos	  dd	?               ; los valores extraidos de la
 KYSin	  dd	?               ; tabla del seno y coseno,
 KYCos	  dd	?               ; ejes de rotaci¢n X, Y, Z
 KZSin	  dd	?
 KZCos	  dd	?

 N1_x	  dd 	?               ; Normales bidimensionales
 N2_y	  dd	?               ; que no se pueden meter en registros

 public sintab
 extrn  stackbase:dword, fcount:dword
 extrn  screen:ScreenINFO, TheWorld:dword
 extrn  sqtable:dword ;, nmtable:dword

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  F i n   d e l   c ¢ d i g o
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ends
end

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ GETNORMAL                                                ±
;±----------------³----------------------------------------------------------±
;± FUNCION:       ³ Calcula el vector normal a un pol¡gono                   ±
;±----------------³----------------------------------------------------------±
;± PARAMETROS:    ³ EDI: Ptr al actual vector (¡ndices)                      ±
;±                ³ EBP: Ptr al vector normal                                ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 align 16
 Vra     dot3d     ?
 Vrb     dot3d     ?
 Pd1     dot3d     ?
 Pd2     dot3d     ?
 Pd3     dot3d     ?
;-----------------------------------------------------------------------------
 GETNORMAL      PROC

	pushad

; Iniciamos los 3 puntos
	mov   ebx, [edi]
	mov   eax, [ebx].x
	mov   Pd1.x, eax
	mov   eax, [ebx].y
	mov   Pd1.y, eax
	mov   eax, [ebx].z
	mov   Pd1.z, eax

	mov   ebx, [edi+04]
	mov   eax, [ebx].x
	mov   Pd2.x, eax
	mov   eax, [ebx].y
	mov   Pd2.y, eax 
	mov   eax, [ebx].z
	mov   Pd2.z, eax

	mov   ebx, [edi+08]
	mov   eax, [ebx].x
	mov   Pd3.x, eax
	mov   eax, [ebx].y
	mov   Pd3.y, eax
	mov   eax, [ebx].z
	mov   Pd3.z, eax


; Seguimos inicializando...
	push ebp

	mov  ebx, Pd2.x
	mov  edx, Pd2.y
	mov  ebp, Pd2.z

; Vra inicio
	mov  eax, Pd1.x			    ; Vra = v[1] - v[2]
	sub  eax, ebx
	mov  Vra.x, eax
	mov  eax, Pd1.y
	sub  eax, edx
	mov  Vra.y, eax
	mov  eax, Pd1.z
	sub  eax, ebp
	mov  Vra.z, eax

; Vrb inicio
	mov  eax, Pd3.x			    ; Vrb = v[3] - v[2]
	sub  eax, ebx
	mov  Vrb.x, eax
	mov  eax, Pd3.y
	sub  eax, edx
	mov  Vrb.y, eax
	mov  eax, Pd3.z
	sub  eax, ebp
	mov  Vrb.z, eax

	pop  ebp
	lea  esi, Vra
	lea  edi, Vrb
	call CROSSPROD
	;call NORMALIZE

	popad
	ret

   ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO:³ AVERAGEDOT                                                ±
;±---------------³-----------------------------------------------------------±
;± FUNCION:      ³ Halla la media de todas las normales compartidas por un   ±
;±               ³ un v‚rtice de el objeto (Normal al v‚rtice)               ±
;±---------------³-----------------------------------------------------------±
;± PARAMETROS:   ³ ESI: Objeto; EDI: Ptr al v‚rtice; EBX: Array de ptr       ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 align 4
 nnor	dw	?

 align 16
 AVERAGEDOT PROC
	pushad
	
	mov   nnor, 0
	push  ebx
	movzx edx, [esi].fig.numfaces
	imul  edx, size polyidx
	xor   ecx, ecx

@av@loop:
	cmp  edi, [esi].fig.face[ecx].dotinx
	je   short @av@putinlist
	cmp  edi, [esi].fig.face[ecx+4].dotinx
	je   short @av@putinlist     
	cmp  edi, [esi].fig.face[ecx+8].dotinx
	je   short @av@putinlist
	add  ecx, size polyidx
	cmp  ecx, edx
	jb   short @av@loop
	jmp  short ad@id
	
@av@putinlist:
	inc  nnor
	mov  eax, [esi].fig.face[ecx].norptr
	mov  [ebx], eax
	add  ebx, 4
	add  ecx, size polyidx
	cmp  ecx, edx
	jb   short @av@loop
	
ad@id:	pop  ebx

	movzx ecx, nnor
	test  ecx, ecx
	jnz   short ad@ir
	mov   eax, 7
;	stc
	jmp   ad@end

ad@ir:	xor  eax, eax		; EAX = Coord X
	mov  edx, eax	 	; EDX = Coord Y
	mov  esi, eax		; ESI = Coord Z

; Halla la media de las normales, y lo almacena como la normal al v‚rtice
@ad@average:
	mov  ebp, [ebx]
	add  eax, [ebp].x
	add  edx, [ebp].y
	add  esi, [ebp].z
	add  ebx, 4
	dec  cx
	jnz  short @ad@average

	movzx ecx, nnor

	push edx
	cdq
	idiv ecx
	mov  [edi].Normal.x, eax

	pop  eax
	cdq
	idiv ecx
	mov  [edi].Normal.y, eax

	mov  eax, esi
	cdq
	idiv ecx
	mov  [edi].Normal.z, eax

	lea  ebp, [edi].Normal
;	call NORMALIZE

	clc
ad@end:	popad
	ret
  ENDP
