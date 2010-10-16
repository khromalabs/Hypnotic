;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ SETBACKGND                                               ±
;±----------------³----------------------------------------------------------±
;± FUNCTION:      ³ Inits the the backgrnd (Image or black screen, or anyone)±
;±        	  ³ Coping 3rd page to page 0-1                              ±
;±----------------³----------------------------------------------------------±
;± PARAMETERS:    ³ AL: Sets the background type:                            ±
;±        	  ³    0: Clear with color 0 the screen                      ±
;±        	  ³    1: Store a image and use it to clear the screen       ±
;±        	  ³       EDI: Ptr to the image               	     	     ±
;±        	  ³   XX: Don't clear the screen                             ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 SETBACKGND  PROC

	pushad
   
	mov  screen.backgnd, al
	cmp  al, 1
	jne  sb@exit

; Test the resolution, cause we need _3_ pages to store the image
	cmp  screen.ytot, 240
	jg   sb@nomem

; Copies the image to the page 3
	mov  screen.backgnd, 1
	mov  screen.bgptr, edi
	mov  screen.bgok, 0
	mov  screen.bgok+1, 0

	mov   ax, screen.xbpn
	mul   screen.ytot
	mov   cx, ax
	shl   ax, 1
	movzx ebp, ax
	add   ebp, 0a0000h

	mov   dx, 3C4h
	mov   ax, 0102h
	xor   bx, bx

sb@loopbp:
	out   dx, ax
	mov   esi, screen.bgptr
	add   si, bx
	@rlp  edi, ebp                 ; Situamos EDI en memoria de v¡deo

	push  cx ax

sb@inner:
	mov  al, [esi]
	mov  [edi], al

	add  esi, 4
	inc  edi
	dec  cx
	jnz  short sb@inner

	pop  ax cx

	inc  bx
	shl  ah, 1
	cmp  ah, 16
	jne  short sb@loopbp

sb@exit:
	popad
	ret

sb@nomem:
	mov  screen.backgnd, 0
	jmp  short sb@exit

ENDP

;-----------------------------------------------------------------------------
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;-----------------------------------------------------------------------------
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;-----------------------------------------------------------------------------

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO:³ GETSHADECOL                                               ±
;±---------------³-----------------------------------------------------------±
;± FUNCION:      ³ Obtiene el sombreado correspondiente a una cara           ±
;±---------------³-----------------------------------------------------------±
;± PARAMETROS:   ³ AL:  Color                                                ±
;±               ³ EBP: Ptr al vector normal de esa cara                     ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 align 16
 GETSHADECOL  PROC

	 mov  bl, al
	 mov  eax, [ebp].z

         cmp  eax, 0FFFFh
	 jl   short min0
	 mov  eax, 0FFFFh

min0:	 cmp  eax, 0
	 jg   short gsmain
	 xor  eax, eax

gsmain:	 shr  eax, 11
	 add  al, bl

	 ret
  ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ ADJUST_FACE                                              ±
;±----------------³----------------------------------------------------------±
;± FUNCION:       ³ Comprueba si un tri ngulo est  delante, si no o bien     ±
;±                ³ no lo pinta, o lo recorta                                ±
;±----------------³----------------------------------------------------------±
;± PARAMETROS:    ³ EBP: Pol¡gono; fcount: Contador de caras                 ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 align 16
 ADJUST_FACE PROC
       pushad
       xor  bx, bx

       lea esi, [ebp].poly[edi-37]
@dot1: cmp dword ptr [esi+08], 50000h
       jl  short @dot2
       or  bl, 001b
@dot2: cmp dword ptr [esi+20], 50000h
       jl  short @dot3
       or  bl, 010b
@dot3: cmp dword ptr [esi+32], 50000h
       jl  short @t000
       or  bl, 100b

@t000: test bl, bl
       jz  endaf

@t111: inc fcount                 ; Incrementamos el contador de las caras
       cmp bl, 00000111b          ; ¨Est n todos los v‚rtices en pantalla?
       je  endaf                  ; Si, pues ya est 

@t100: cmp bl, 100b               ; No. Vamos a recortar
       jl  short @t001
       jg  short @t101
       mov edi, esi               ; EBX = Punto 2
       mov ebx, edi               ; ESI = Punto 1
       add esi, 12                ; EDI = Punto 0
       add ebx, 24
       call cut001
       jmp short endaf

; Si es menor:
@t001: cmp bl, 001b
       jne short @t010
       mov ebx, esi               ; EBX = Punto 0
       mov edi, esi               ; EDI = Punto 1
       add edi, 12                ; ESI = Punto 2
       add esi, 24
       call cut001
       jmp short endaf

@t010: cmp bl, 010b
       jne short @t011
       mov ebx, esi
       mov edi, ebx               ; ESI = Punto 0
       add ebx, 12                ; EBX = Punto 1
       add edi, 24                ; EDI = Punto 2
       call cut001
       jmp short endaf

@t011: inc fcount
       mov edi, esi               ; EBX = Punto 0
       mov ebx, edi               ; EDI = Punto 1
       add edi, 12                ; ESI = Punto 2
       add esi, 24
       call cut011
       jmp short endaf

; Estos son los casos mayores que 100b (5)
@t101: inc fcount
       cmp bl, 101b
       jne short @t110
       mov edi, esi               ; EBX = Punto 2
       mov ebx, edi               ; EDI = Punto 0
       add esi, 12                ; ESI = Punto 1
       add ebx, 24
       call cut011
       jmp short endaf

@t110: mov edi, esi               ; EBX = Punto 1
       mov ebx, edi               ; EDI = Punto 2
       add ebx, 12                ; ESI = Punto 0
       add edi, 24
       call cut011

endaf: popad
       ret
   ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDIMIENTO: ³ cut001                                                  ±
;±-----------------³---------------------------------------------------------±
;±        FUNCION: ³ Recorta un tri ngulo en el que 2 v‚rtices estan en el   ±
;±                 ³ plano negativo Z                                        ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 align 16
 cut001  PROC
; Ejemplo de tri ngulo a cortar:
;
;           ^      Punto 1
;           |         /\                   +
;          Eje z    /    \                 1
; - Eje x --|---- / ------ \ -- posici¢n z 0 ----->
;           |   /            \            -1
;   Punto 0 |  -------------- Punto 2      -
; === LINEA 0-1 =============================================================
       mov ebp, [ebx+08]
       mov ecx, ebp
       sub ecx, 50000h
       sar ecx, 16
       sub ebp, [edi+08]         ; EBP = cara[0].z - cara[1].z  (dif_z)
       sar ebp, 16               ; Ajustamos para la divisi¢n
       jz  endc1

       mov eax, [ebx]
       push eax
       sub eax, [edi]            ; EAX = cara[0].x - cara[1].x  (dif_x)
       cdq
       idiv ebp
       imul eax, ecx
       pop edx
       sub edx, eax
       mov [edi], edx            ; Copiamos en cara[1].x

       mov eax, [ebx+4]          ; EDI = cara[0].y
       push eax
       sub eax, [edi+4]          ; EAX = cara[0].y - cara[1].y  (dif_y)
       cdq
       idiv ebp
       imul eax, ecx
       pop edx
       sub edx, eax
       mov [edi+4], edx          ; Copiamos en cara[1].y

       mov [edi+08], 50000h      ; Y en la Z, el 2

; === LINEA 0-2 =============================================================
       mov ebp, [ebx+08]
       sub ebp, [esi+08]         ; EBP = cara[0].z - cara[2].z  (dif_z)
       sar ebp, 16               ; Ajustamos para la divisi¢n
       jz  endc1

       mov eax, [ebx]
       mov edi, eax
       sub eax, [esi]            ; EAX = cara[0].x - cara[2].x  (dif_x)
       cdq
       idiv ebp
       imul eax, ecx
       sub edi, eax
       mov [esi], edi            ; Copiamos en cara[2].x

       mov eax, [ebx+4]          ; EDI = cara[0].y
       mov edi, eax
       sub eax, [esi+4]          ; EAX = cara[0].y - cara[2].y  (dif_y)
       cdq
       idiv ebp
       imul eax, ecx
       sub edi, eax
       mov [esi+4], edi          ; Copiamos en cara[2].y

       mov [esi+08], 50000h      ; Y en la Z, el 2

endc1: ret
   ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDIMIENTO: ³ cut011                                                  ±
;±-----------------³---------------------------------------------------------±
;±        FUNCION: ³ Recorta un tri ngulo en el que s¢lo hay un v‚rtice no   ±
;±                 ³ visible, por lo que ha de ser subdividido               ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 align 16
 cut011  PROC
;  Ejemplo de tri ngulo a cortar:         +
;  Punto 0 *--------------------* Punto 1 ^ Eje (DI)
;  (BX)      \      1       *  /          | Z
;              \       *  2  /            |
;  -------------2\*- - - - *-2-- Eje x ---|---> +
;                 0\'    /                |
;                    \ /                  |
;                  Punto 2 (SI)

; === TRIANGULO 2 == L I N E A  1 - 2 ========================================
       mov  ebp, [edi+08]
       mov  ecx, ebp
       sub  ecx, 50000h
       sar  ecx, 16
       sub  ebp, [esi+08]
       sar  ebp, 16
       jz  endc2

       mov  eax, [edi]
       mov  [edi+37], eax

       push eax
       sub  eax, [esi]
       cdq
       idiv ebp
       imul eax, ecx
       pop  edx
       sub  edx, eax
       mov  [esi+37], edx

       mov  eax, [edi+04]
       mov  [edi+41], eax
       push eax
       sub  eax, [esi+04]
       cdq
       idiv ebp
       imul eax, ecx
       pop  edx
       sub  edx, eax
       mov  [esi+41], edx

       mov  [esi+45], 50000h

       mov  eax, [edi+8]
       mov  [edi+45], eax

; === TRIANGULO 1 === LINEA 0-2 =============================================
       mov  ebp, [ebx+08]
       mov  ecx, ebp
       sub  ecx, 50000h
       sar  ecx, 16
       sub  ebp, [esi+08]
       sar  ebp, 16
       jz  endc2

       mov  eax, [ebx]
       push eax
       sub  eax, [esi]
       cdq
       idiv ebp
       imul eax, ecx
       pop  edx
       sub  edx, eax
       mov  [esi], edx
       mov  [ebx+37], edx

       mov  eax, [ebx+04]
       push eax
       sub  eax, [esi+04]
       cdq
       idiv ebp
       imul eax, ecx
       pop  edx
       sub  edx, eax
       mov  [esi+04], edx
       mov  [ebx+41], edx

       mov  [esi+08], 50000h
       mov  [ebx+45], 50000h

endc2: ret
 cut011 ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO:³ ROTAR2                                                    ±
;±---------------³-----------------------------------------------------------±
;± FUNCION:      ³ Rota una lista de vectores con los valores de la matriz   ±
;±               ³ alterando la definici¢n original de los mismos            ±
;±---------------³-----------------------------------------------------------±
;± PARAMETROS:   ³ EDI = Vector IN; ESI = MATRIZ                             ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 align 16
 ROTAR2 PROC
; ===== Variables locales ====================================================
       VARS =  (20)
       S_VX =  [esp+00]
       S_VY =  [esp+04]
; ============================================================================

	sub  esp, VARS

	test cx, cx	       ; N§ de puntos
	jnz  short @RotL
	mov  cx, [edi]  
	add  edi, 2
	
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
	mov  S_VX, eax

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
	mov  S_VY, eax

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

	mov  [edi].z, eax       ; Valor Z
	mov  eax, S_VY		
	mov  [edi].y, eax       ; Valor Y
	mov  eax, S_VX		
	mov  [edi].x, eax       ; Valor X

	add  edi, 12
	dec  cx
	jnz  @RotL

	add  esp, VARS
	ret
 ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO:³ BFC                                                       ±
;±---------------³-----------------------------------------------------------±
;± FUNCION:      ³ Realiza el back-face culling                              ±
;±---------------³-----------------------------------------------------------±
;± PARAMETROS:   ³ EDI: Pol¡gono V0; EBP: Normal                             ±
;±---------------³-----------------------------------------------------------±
;± OUT:		 ³ EAX: ?  						     ±
;±		 ³ CF: 1 -> No visible					     ±
;±		 ³ CF: 0 -> Visible					     ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 align 16
 BFC PROC
       	mov   eax, [edi].x
	imul  [ebp].x
	shrd  eax, edx, 16
	mov   ebx, eax

	mov   eax, [edi].y
	imul  [ebp].y
	shrd  eax, edx, 16
	add   ebx, eax

	mov   eax, [edi].z
	imul  [ebp].z
	shrd  eax, edx, 16
	add   ebx, eax

	cmp   ebx, 0
	jl    short bfc@nc
	clc
	ret

bfc@nc:	stc 
	ret
  ENDP


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO:³ GENSIN (Generate Sines)                                   ±
;±---------------³-----------------------------------------------------------±
;± FUNCION:      ³ Genera una tabla del seno                                 ±
;±---------------³-----------------------------------------------------------±
;± PARAMETROS:   ³ EDI: Offset de la tabla; EDX: N§ de valores a generar     ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 SINE     = dword ptr [esp+00]
 VALUE    = dword ptr [esp+04]
 EXP      = dword ptr [esp+08]
 INCG     = dword ptr [esp+12]
 RAD      = dword ptr [esp+16]
 TEMP_EAX = dword ptr [esp+20]
 TEMP_ESI = dword ptr [esp+24]
 TEMP_EDX = dword ptr [esp+28]
 LENGHT   = dword ptr [esp+32]
 LENGHT2  = dword ptr [esp+36]
;-----------------------------------------------------------------------------
 sineval  db 	13, 10, "Seno: $"
;-----------------------------------------------------------------------------
 align 16
 GENSIN PROC

	sub  esp, 40

	shr  edx, 1
	mov  LENGHT, edx
	mov  LENGHT2, edx
	mov  ebx, edx
	mov  eax, 52698814
	xor  edx, edx
	idiv ebx
	mov  INCG, eax			; EBP = (PI / BASE)
	xor  eax, eax
	mov  RAD, eax

sineloop:
	mov  EXP, 3
	mov  eax, RAD
	mov  VALUE, eax
	xor  si, si

numberloop:
	mov  ecx, EXP
	mov  eax, RAD
	sar  eax, 8
	mov  ebx, eax

; EAX = EAX ^ ECX
@power: imul ebx
        shrd eax, edx, 16
        sar  edx,  16
 	loop @power

	mov  TEMP_EDX, edx
	mov  TEMP_EAX, eax
	mov  ebx, EXP

; EDX = EBX!
	mov  edx, 1
	mov  ecx, 1
ftloop:	mov  eax, edx
	imul eax, ecx
	add  edx, eax
	inc  ecx
	cmp  ecx, ebx
	jl   short ftloop

	mov  ebx, edx
	mov  eax, TEMP_EAX
	mov  edx, TEMP_EDX
	idiv ebx

 	shl  eax, 8
        test si, si
	jz   short subval
	add  VALUE, eax
	jmp  short gsnext
subval:	sub  VALUE, eax

gsnext:	mov  eax, VALUE
	xor  si, 1
	add  EXP, 2
	cmp  EXP, 9
	jle  short numberloop
	
	mov  eax, VALUE
	sar  eax, 8
	@printmd sineval, eax
	mov  [edi], eax
	add  edi, 4

	mov  eax, RAD
	add  eax, INCG
	mov  RAD, eax
	dec  LENGHT2
	jnz  sineloop

	mov  ecx, LENGHT
	mov  esi, edi
	sub  edi, 4

negsin:	mov  eax, [edi]
	neg  eax
	mov  [esi], eax
	add  esi, 4
	sub  edi, 4
	dec  ecx
	jnz  short negsin
	
	add  esp, 40
	ret
 ENDP

;-----------------------------------------------------------------------------
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;-----------------------------------------------------------------------------
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;-----------------------------------------------------------------------------

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ DTH                                                      ±
;±----------------³----------------------------------------------------------±
;± FUNCION:       ³ Dibuja un tri ngulo horizontal                           ±
;±----------------³----------------------------------------------------------±
;± PARAMETROS:    ³ EDI = Puntero pixels fixed                               ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 align 4
  DTH@R10_X  dd	?
  DTH@R20_X  dd	?
  DTH@R21_X  dd	?
  DTH@R10_Y  dd	?
  DTH@R20_Y  dd	?
  DTH@R21_Y  dd	?
  INC_X      dd	?
  INC_X2     dd	?
  INC2_X     dd	?
  INC2_X2    dd	?

 align 16
 DTH  PROC

	mov  dword ptr INC_X, 0    ; Inicia los incrementos
	mov  dword ptr INC_X2, 0 
	mov  dword ptr INC2_X, 0 
	mov  dword ptr INC2_X2, 0

	mov  eax, [edi+4]          ; EAX = v[0].y
	mov  ebx, [edi+12]         ; EBX = v[1].y
	mov  edx, [edi+20]         ; EDX = v[2].y

; == if(v[0].y > v[2].y) xchg(v[0], v[2]) ===================================
	cmp  eax, edx
	jle  short @@noch
	mov  esi, edi
	add  esi, 16
	@xchv
	xchg eax, edx
; == if(v[0].y > v[1].y) xchg(v[0], v[1]) ===================================
@@noch: cmp  eax, ebx
	jl   short @@noch3
	je   short @@noch2
	mov  esi, edi
	add  esi, 8
	@xchv
	xchg eax, ebx
	jmp  short @@noch3

; == if((v[0].y == v[1].y) && (v[0].x > v[1].x)) xchg(v[0], v[1]) ===========
@@noch2:mov  ecx, [edi]
	cmp  ecx, [edi+08]
	jle  short @@noch3
	mov  esi, edi
	add  esi, 8
	@xchv
	xchg eax, ebx

; == if(v[1].y > v[2].y) xchg(v[1], v[2]) ===================================
@@noch3:cmp  ebx, edx
	jl   short @@noch5
	je   short @@noch4
	mov  esi, edi
	add  edi, 8
	add  esi, 16
	@xchv
	sub  edi, 8
	xchg ebx, edx
	jmp  short @@noch5

; == if((v[1].y == v[2].y) && (v[1].x > v[2].x)) xchg(v[1], v[2])  ==========
@@noch4:mov  ecx, [edi+08]
	cmp  ecx, [edi+16]
	jle  short @@noch5
	mov  esi, edi
	add  edi, 8
	add  esi, 16
	@xchv
	sub  edi, 8

; Calculamos el valor de las restas
@@noch5:mov eax, [edi+16]               ; resta21_x = v[2].x - v[1].x
	sub eax, [edi+08]
	mov DTH@R21_X, eax
	mov eax, [edi+16]               ; resta20_x = v[2].x - v[0].x
	sub eax, [edi]
	mov DTH@R20_X, eax
	mov eax, [edi+08]               ; resta10_x = v[1].x - v[0].x
	sub eax, [edi]
	mov DTH@R10_X, eax

	mov eax, [edi+20]               ; resta21_y = (v[2].y - v[1].y) >> 16
	sub eax, [edi+12]
	mov DTH@R21_Y, eax
	mov eax, [edi+12]               ; resta10_y = (v[1].y - v[0].y) >> 16
	sub eax, [edi+04]
	mov DTH@R10_Y, eax
	mov eax, [edi+20]               ; resta20_y = (v[2].y - v[0].y) >> 16
	sub eax, [edi+04]
	mov DTH@R20_Y, eax

; Este c¢digo averigua cuales son los puntos izquierdo y derecho
	jz   short @noinc
	xor  ebx, ebx
	mov  bx, word ptr DTH@R20_Y+2
	mov  eax, DTH@R20_X
	@cdq
	idiv ebx
	mov  ecx, eax                 ; ECX = incremento de la l¡nea
	xor  ebx, ebx
	mov  bx, word ptr DTH@R10_Y+2
	imul ebx
	add  eax, [edi]               ; POS_Y = v[0].x + (resta10_y * inc)
	jmp  short @inic
@noinc: xor  ecx, ecx
	xor  ebx, ebx
        mov  eax, [edi]

; Aqu¡ se calculan los incrementos
@inic:  cmp  [edi+08], eax
	jg   short @lineizq

	cmp  dword ptr DTH@R10_Y, 0
	je   short @p1@2
	mov  bx, word ptr DTH@R10_Y+2
	mov  eax, DTH@R10_X
	@cdq
	idiv ebx
	mov  INC_X, eax
	mov  INC_X2, ecx

@p1@2:  cmp  dword ptr DTH@R21_Y, 0
	je   short @inil
	mov  bx, word ptr DTH@R21_Y+2
	mov  eax, DTH@R21_X
	@cdq
	idiv ebx
	mov  INC2_X, eax
	mov  INC2_X2, ecx

	jmp  short @inil

;------ Si el punto medio pasa de la l¡nea 0-2 los incrementos se cambian ---
@lineizq:cmp  dword ptr DTH@R10_Y, 0
	je   short @p2@2
	mov  bx, word ptr DTH@R10_Y+2
	mov  eax, DTH@R10_X
	@cdq
	idiv ebx
	mov  INC_X, ecx
	mov  INC_X2, eax

@p2@2:  cmp  dword ptr DTH@R21_Y, 0
	je   short @inil
	mov  bx, word ptr DTH@R21_Y+2
	mov  eax, DTH@R21_X
	@cdq
	idiv ebx
	mov  INC2_X, ecx
	mov  INC2_X2, eax

; === Ya tenemos los incrementos, ahora dibujamos el pol¡gono ===============
@inil:  mov  cx, [edi]               ; LCX = POS_X (Low  Word)
        mov  bx, [edi+06]            ; LBX = POS_Y (NO LOW)

        mov  si, word ptr [edi+06]
        cmp  si, word ptr [edi+14]
	je   short @draw2

	mov  ax, cx
	shl  eax, 16                 ; UAX = POS_X2 (Low  Word)
	mov  ax, [edi+02]            ; LAX = POS_X  (High Word)
	mov  dx, ax                  ; LDX = POS_X2 (High Word)

	mov  si, word ptr INC_X2
	shl  esi, 16                 ; USI = INC_X2 (Low  Word)
	mov  si, word ptr INC_X+2    ; LSI = INC_X  (High Word)

@loop1:	call _lhor
	add  cx, word ptr INC_X
	adc  eax, esi
	adc  dx, word ptr INC_X2+2
	inc  bx
	cmp  bx, [edi+14]
	jl   short @loop1
	jmp  short @chinc

@draw2:	mov  dx, [edi+10]            ; LDX = POS_X2 (High Word)
	mov  ax, [edi+08]            ; UAX = POS_X2 (Low Word)
	shl  eax, 16
	mov  ax, [edi+02]            ; LAX = POS_X (High Word)

@chinc:	mov  si, word ptr [edi+14]
	cmp  si, word ptr [edi+22]
	je   short @fin
	mov  si, word ptr INC2_X2
	shl  esi, 16		     ; USI = INC_X2 (Low Word)
 	mov  si, word ptr INC2_X+2   ; LSI = INC_X  (High Word)

@loop2:	call _lhor
	add cx, word ptr INC2_X
	adc eax, esi
	adc dx, word ptr INC2_X2+2
	inc bx
	cmp bx, [edi+22]
	jl  short @loop2

@fin:	ret
   
 ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ LHOR                                                     ±
;±----------------³----------------------------------------------------------±
;± FUNCION:       ³ Crea una l¡nea horizontal (16 pixels x loop!!)           ±
;±----------------³----------------------------------------------------------±
;± PARAMETROS:    ³ AX = X1, DX = X2, BX = Y                                 ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
align 16
_lhor PROC

	cmp bx, 0		; ¨Entra en pantalla?
	jl  fincl2
	cmp bx, screen.ymax
	jg  fintot2
	cmp dx, 0
	jl  fincl2
	cmp ax, screen.xmax
	jg  fincl2

	pushad

	cmp ax, 0		; Si hay que recortarla...
	jge short @noas
	xor ax, ax
@noas:  cmp dx, screen.xmax
	jle short @noas2
	mov dx, screen.xmax

; Calcula el offset y lo guarda en EDI
@noas2: xor  edi, edi		; Direcci¢n en memoria de v¡deo
	mov  di, bx
	lea  edi, [edi+edi*4]	; EDI = EDI * (16*5) = EDI * 80
	shl  edi, 4
	mov  si, ax
	shr  si, 2
	add  di, si
	add  edi, screen.acceso
	xor  ecx, ecx
	mov  ebx, ecx
	
; N§ total de pixels
	sub dx, ax
	jle finh
	inc dx
	mov cx, dx		; CX = N§ total de pixels
	and ax, 3		; AL = Indice en los bp a seleccionar
	
	add  dx, ax
        cmp  dx, 4
	jb   fillone

	test ax, ax
	jz   short cxcmp
	mov  bl, al

	mov  al, 2
	mov  dx, SEQU_ADDR      ; Seleccionamos en la VGA el Bit-plane
	out  dx, al		; adecuado
	mov  al, bptable[ebx*2]
	inc  dx
	out  dx, al              ; Lo escribimos en el Map-Register

	mov  al, byte ptr pcol
	mov  [edi], al
	inc  edi
	mov  bl, bptable[ebx*2+1]
	sub  cx, bx
	jle  short finh
cxcmp:  cmp  cx, 4
	jl   short last
	
x1posok:mov  al, 2
	mov  dx, SEQU_ADDR       ; Seleccionamos en la VGA el Bit-plane
	out  dx, al              ; adecuado
	mov  al, 1111b
	inc  dx
	out  dx, al              ; Lo escribimos en el Map-Register

	mov  ax, pcol
		
pix16l: sub  cx, 16
	js   short fr16
        mov  [edi], ax
        mov  [edi+02], ax
	add  edi, 4
	jmp  short pix16l

fr16:	add  cx, 16
	jle  short finh

pix4l:	sub  cx, 4
	js   short fr4
	mov  [edi], al
	inc  edi
	jmp  short pix4l
	
fr4:	add  cx, 4
	jle  short finh

last:	mov  al, 2
	mov  dx, SEQU_ADDR       ; Seleccionamos en la VGA el Bit-plane
	out  dx, al		 ; adecuado
	mov  al, bptablex[ecx]
	inc  dx
	out  dx, al              ; Lo escribimos en el Map-Register
	
        mov  al, byte ptr pcol
	mov  [edi], al	

finh:	popad
	
fincl2: ret
fintot2:add esp, 4
	jmp @fin

; S¢lo cuando la l¡nea entre dentro de un s¢lo bit-plane, y encima empiece
; o acabe donde le d‚ la gana (0-3) (HAY QUE JO... JOROBARSE!!! :-)
align 16
fillone:mov  ah, bptablex[ecx]
	mov  cl, al
	shl  ah, cl

	mov  al, 2
	mov  dx, SEQU_ADDR       ; Seleccionamos en la VGA el Bit-plane
	out  dx, al	   	 ; adecuado
	mov  al, ah
	inc  dx
	out  dx, al              ; Lo escribimos en el Map-Register

	mov  al, byte ptr pcol
	mov  [edi], al
	
	popad
	ret
 ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ DTH                                                      ±
;±----------------³----------------------------------------------------------±
;± FUNCION:       ³ Dibuja un tri ngulo con los algoritmos de Bresenham      ±
;±                ³ En contra de mis espectativas, m s lento que la divisi¢n ±
;±                ³ entera :''(                                              ±
;±----------------³----------------------------------------------------------±
;± PARAMETROS:    ³ EDI = Puntero pixels fixed                               ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 align 4
	TEMP_EDI	dd	?
	TEMP_EBX	dd	?
	nlines		dw	?

 align 16
 DTH	PROC

	mov  TEMP_EDI, edi

	mov  eax, [edi+04]         ; EAX = v[0].y
	mov  ebx, [edi+12]         ; EBX = v[1].y
	mov  edx, [edi+20]         ; EDX = v[2].y

; == if(v[0].y > v[2].y) xchg(v[0], v[2]) ===================================
	cmp  eax, edx
	jle  short @@noch
	mov  esi, edi
	add  esi, 16
	@xchv
	xchg eax, edx
; == if(v[0].y > v[1].y) xchg(v[0], v[1]) ===================================
@@noch: cmp  eax, ebx
	jl   short @@noch3
	je   short @@noch2
	mov  esi, edi
	add  esi, 8
	@xchv
	xchg eax, ebx
	jmp  short @@noch3

; == if((v[0].y == v[1].y) && (v[0].x > v[1].x)) xchg(v[0], v[1]) ===========
@@noch2:mov  ecx, [edi]
	cmp  ecx, [edi+08]
	jle  short @@noch3
	mov  esi, edi
	add  esi, 8
	@xchv
	xchg eax, ebx

; == if(v[1].y > v[2].y) xchg(v[1], v[2]) ===================================
@@noch3:cmp  ebx, edx
	jl   short @@noch5
	je   short @@noch4
	mov  esi, edi
	add  edi, 8
	add  esi, 16
	@xchv
	sub  edi, 8
	xchg ebx, edx
	jmp  short @@noch5

; == if((v[1].y == v[2].y) && (v[1].x > v[2].x)) xchg(v[1], v[2])  ==========
@@noch4:mov  ecx, [edi+08]
	cmp  ecx, [edi+16]
	jle  short @@noch5
	mov  esi, edi
	add  edi, 8
	add  esi, 16
	@xchv

@@noch5:
; Inicia las coordenadas de la l¡nea P[0-1]
	mov  esi, TEMP_EDI
	mov  edi, esi
	add  edi, 8
	mov  ebx, polycord
	add  ebx, 2
	call LINE

; Inicia las coordenadas de la l¡nea P[1-2]
	add  esi, 8
	add  edi, 8
	call LINE
	
; Inicia las coordenadas de la l¡nea P[0-2] (La m s larga)
	mov  ebx, polycord
	mov  esi, TEMP_EDI
	mov  edi, esi
	add  edi, 16
	call LINE
	mov  nlines, cx

	mov  edi, TEMP_EDI
	xor  ebx, ebx
	mov  bx, [edi+6]
	mov  TEMP_EBX, ebx
	
	mov  edi, polycord
	mov  TEMP_EDI, edi
	
@drawloop:
	mov  edi, TEMP_EDI		; EDI = Coordenada X1-X2 siguiente
	mov  ax, [edi]
	mov  dx, [edi+2]
	mov  ebx, TEMP_EBX		; EBX = Valor Y siguiente
	call _lhor
        add  TEMP_EDI, 4
	inc  TEMP_EBX
	dec  nlines
	jnz  @drawloop

@fin:	ret

 ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ LINE                                                     ±
;±----------------³----------------------------------------------------------±
;± FUNCION:       ³ Obtiene las coordenadas X de una l¡nea (Bresenham)       ±
;±----------------³----------------------------------------------------------±
;± PARAMETROS:    ³ ESI = (x1, y1); EDI = (x2, y2); EBX = Array              ±
;±----------------³----------------------------------------------------------±
;± OUT:           ³ CX = N£mero de l¡neas                                    ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 align 4
 Dinc1	dw	?
 Dinc2	dw	?

 align 16
 LINE	PROC

	mov  ax, [esi+2]	; AX = DELTA_X
	sub  ax, [edi+2]
	@abs ax
	
	mov  dx, [esi+6]	; DX = DELTA_Y
	sub  dx, [edi+6]
	@abs dx

	cmp  ax, dx
	jl   short @type2
	
;===== X es la variable independiente =======================================
	mov  cx, dx
	inc  cx
	push cx
	
	mov  cx, ax		; CX = N£mero de pixels
	inc  cx

	mov  bp, dx
	shl  bp, 1
	mov  Dinc1, bp	

	sub  bp, ax		; BP = Varible D (Decimal ?)

	sub  dx, ax
	shl  dx, 1
	mov  Dinc2, dx		; IncD2 = (delta_y - delta_x) * 2

	mov  ax, [esi+2]	; Compara la direcci¢n X de la l¡nea
	cmp  ax, [edi+2]	; No hay test de la coordenada Y
	jg   short @neg	        ; debido a que los puntos han sido 
	mov  dx, 1 		; ordenados previamente por altura
	jmp  short @doline

@neg:	mov  dx, -1

@doline:mov  ax, [esi+2]
	mov  [ebx], ax
	add  ebx, 4
	dec  cx	
	jz   short @exit
	jmp  short @loop
	
;-----------------------------
@loop2:	add  bp, Dinc2
	add  ax, dx
	mov  [ebx], ax		; Movemos al array la posici¢n X
	add  ebx, 4
	dec  cx	
	jz   short @exit

@loop:	cmp  bp, 0
	jge  short @loop2
	add  bp, Dinc1
	add  ax, dx
	dec  cx
	jnz  short @loop
;-----------------------------	
@exit:  pop  cx
	ret

;===== Y es la variable independiente =======================================
@type2:	mov  cx, dx		; CX = N£mero de pixels
	inc  cx			; AX = DELTA_X; DX = DELTA_Y
	push cx

	mov  bp, ax		; BP = Varible D (Decimal ¨? =)
	shl  bp, 1
	mov  Dinc1, bp		; IncD1 = delta_x * 2

	sub  bp, dx

	sub  ax, dx
	shl  ax, 1
	mov  Dinc2, ax		; IncD2 = (delta_x - delta_y) * 2

	mov  ax, [esi+2]	; Compara la direcci¢n X de la l¡nea
	cmp  ax, [edi+2]	; No hay test de la coordenada Y
	jg   short neg	        ; debido a que los puntos han sido 
	mov  dx, 1 		; ordenados previamente por altura
	jmp  short doline

neg:	mov  dx, -1

doline: mov  ax, [esi+2]
        mov  [ebx], ax
	add  ebx, 4
	dec  cx
	jz   short exit
	jmp  short loop
	
;-----------------------------
loop2:	add  bp, Dinc2
	add  ax, dx
        mov  [ebx], ax
	add  ebx, 4
	dec  cx
	jz   short exit

loop:	cmp  bp, 0
	jge  short loop2
	add  bp, Dinc1
	mov  [ebx], ax
	add  ebx, 4
	dec  cx
	jnz  short loop
;-----------------------------
exit:	pop  cx
	ret

 ENDP


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ LOADOBJECT                                               ±
;±----------------³----------------------------------------------------------±
;± FUNCION:       ³ Lee un objeto del disco (*.SHP)                          ±
;±----------------³----------------------------------------------------------±
;± PARAMETROS:    ³ EDX: Ptr. al nombre del fichero                          ±
;±----------------³----------------------------------------------------------±
;± SALIDA:        ³ CF: 1 -> No se puede leer el objeto                      ±
;±                ³     AX -> N§ de error                                    ±
;±                ³ CF: 0 -> Lectura en memoria OK                           ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 align 4
; normales   dd   ?
 Pixlist    dd   ?
 objptr     dd   ?
 handle     dw   ?
 lo@nfaces  dw   ?
 mapped	    db	 ?
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 align 16
 LOADOBJECT PROC

	pushad
;	push  _himembase

	cmp  initbuf, 1
	je   buffers@ok

	call initbufs
	mov  eax, 2
	jc   ldob@cf

; Lee el fichero
buffers@ok:
	call _openfile
	mov  eax, 0
	jc   ldob@cf
	mov  ax, v86r_bx
	mov  handle, ax

	lea  edx, header
	mov  ecx, 8
	call _readfile
	mov  eax, 1
	jc   ldob@cf

; Test number header...
	cmp  word ptr header+2, 3DEFh
	mov  eax, 3
	jne  ldob@cf

	cmp  word ptr header, 0
	jne  short ldob@map
	mov  mapped, 0
	jmp  short ldob@init

ldob@map:
	cmp  word ptr header, 1
	jne  ldob@cf
	mov  mapped, 1

; Se aloja la memoria necesaria para el objeto
ldob@init:
	mov  eax, (size object)+4
	call _getmem
	and  al, 11111100b
	mov  edi, eax
	mov  eax, 2
	jc   ldob@cf
	mov  objptr, edi

	mov  ax, word ptr header+04           ; N§ de vertices
	mov  [edi].lista.numdots, ax
	mov  ax, word ptr header+06           ; N§ de caras
	mov  [edi].fig.numfaces, ax

; Lee los v‚rtices
	movzx ebp, word ptr header+04
	lea  edx, [edi].lista.Vertex.Point
	mov  ax, handle
	mov  v86r_bx, ax
	mov  ecx, (size dot3d) + (size dot3d)
	cmp  mapped, 1
	jne  @loopVertex
	add  ecx, size tex2d

@loopVertex:
	call _readfile
	mov  eax, 1
	jc   ldob@cf
	add  edx, size Vertx
	dec  ebp
	jnz  short @loopVertex
	
; Se copian a tmpl para poder hallar las normales (Ufff...)
	movzx ecx, word ptr header+04
	imul ecx, size Vertx
	add  ecx, 2
	shr  ecx, 1
	lea  esi, [edi].lista
	lea  edi, [edi].tmpl
	rep  movsw

; Precalcula los punteros
	mov   edi, objptr
	mov   bx, [edi].fig.numfaces
	mov   lo@nfaces, bx
	xor   ebx, ebx
	mov   ecx, 8
	lea   ebp, [edi].fig.face
	lea   esi, [edi].tmpl.Vertex.Point
	lea   eax, [edi].pixel.Pixels
	mov   Pixlist, eax

; Obtiene la memoria necesaria para las normales
;	mov   eax, size dot3d * MAXFACES
;	call  _gethimem
;	jc    ldob@cf
;	mov   normales, eax
	   
	lea   edx, tempface

@@rdfloop:
	mov   ax, handle
	mov   v86r_bx, ax
	call  _readfile
	mov   eax, 1
	jc    ldob@cf

	movzx eax, tempface     	; Obtiene el indice al punto
	push  eax
	imul  eax, size Vertx
	add   eax, esi			; Suma la direcci¢n base
	mov   [ebp].dotinx, eax		; Mueve a [obj].fig.face[num].ptr
	pop   eax
	shl   eax, 3
	add   eax, Pixlist
	mov   [ebp].pixinx, eax

	movzx eax, tempface[2]
	push  eax
	imul  eax, size Vertx
	add   eax, esi
	mov   [ebp+04].dotinx, eax
	pop   eax
	shl   eax, 3
	add   eax, Pixlist
	mov   [ebp+04].pixinx, eax

	movzx eax, tempface[4]
	push  eax
	imul  eax, size Vertx
	add   eax, esi
	mov   [ebp+08].dotinx, eax
	pop   eax
	shl   eax, 3
	add   eax, Pixlist
	mov   [ebp+08].pixinx, eax

;	mov   eax, ebx
;-----  imul  eax, size dot3d --------
;	shl   eax, 2
;	lea   eax, [eax + eax*2]
;-------------------------------------
;	add   eax, normales
;	mov   [ebp].norptr, eax

	xor   eax, eax
	mov   ax, tempface[6]
	mov   [ebp].color, eax

	add   ebp, size polyidx
	inc   ebx
	cmp   bx, lo@nfaces
	jb    @@rdfloop

; Obtenemos la lista de normales (A los pol¡gonos)
;	mov  ebp, normales
;	mov  esi, objptr
;	mov  cx, [esi].fig.numfaces
;	lea  edi, [esi].fig.face

;GN@loop:call GETNORMAL
;	add  edi, size polyidx
;	add  ebp, size dot3d
;	dec  cx
;	jnz  short GN@loop

; Se halla la media de ‚stas por v‚rtice
;	mov  ebx, nmtable
;	mov  esi, objptr
;	mov  cx,  [esi].tmpl.numdots
;	lea  edi, [esi].tmpl.Vertex

;lo@ad: call AVERAGEDOT
;	jc   short ldob@cf
;	add  edi, size Vertx
;       dec  cx
;	jnz  short lo@ad

; Preparamos los v‚rtices para la 1¦ rotaci¢n
;	mov  edi, objptr
;	movzx ecx, [edi].tmpl.numdots
;	imul ecx, size Vertx
;       add  ecx, 2
;	shr  ecx, 1
;	lea  esi, [edi].tmpl
;	lea  edi, [edi].lista
;       rep  movsw

; Incrementa el n£mero de objetos le¡dos
	mov edi, TheWorld
	mov eax, objptr
	mov ecx, [edi].numobjs

	mov [edi].obj[ecx*4], eax
	inc [edi].numobjs

	call _closefile
;	pop  _himembase
	popad
	clc
	ret

ldob@cf:call _closefile
;	pop  _himembase
	mov  [esp+28], eax
	popad
	stc
	ret
 ENDP


