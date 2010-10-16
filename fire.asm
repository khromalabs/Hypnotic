;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;                           RUTINA ESTRELLA DE FUEGO
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;                        1995 Khroma (A.K.A Rub‚n G¢mez)
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

  .386p
  jumps

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  D e f i n i c i o n e s
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    include pmode.inc
    include structs.inc
    include kb.inc
    include debug.inc

    public FIREBALL
    public direct 

    extrn screen:ScreenINFO, timer:TimerINFO, firepal:byte
    extrn SETPAL:near, tm@dirflag:byte, spinflag:byte


; Definiciones para el fuego
    Screen_X	=  128
    Screen_Y	=  128

    Star_X	=  128
    Star_Y	=  128

    Star_Radio1	=  53  ;40  
    Star_Radio2	=  25  ;40
    Fire_X	=  600 ;
    Fire_Y	=  Star_Radio1 - Star_Radio2

    Fire_dec    =  12  ;9
    Fire_maxcol =  180 ;195
    square      =  64  ;28

code32  segment para public use32
	assume cs:code32, ds:code32

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  D a t o s
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	align 4

	firebuf		dd	?
	circlebuf	dd	?

	circletab	dd	?
	divtab		dd	?
	cirtab		dd	?
	coltab		dd	?
	fseed		dd	723B61C9h
	fwidth_by2	dd	Fire_X / 2
	incr		dd	?
	r		dw	Star_Radio1
	result		dw	?
	incfact		dw	?
	spiral		dw	2
	fdata		db	0
	direct		db	0
	olddirect	db	?

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  C ¢ d i g o
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; PROCEDIMIENTO:³ FIREBALL
;---------------³-------------------------------------------------------------
; FUNCION:      ³ Efecto de estrella de fuego
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
 align 16
 FIREBALL PROC

	cmp  fdata, 1
	je   short fb@init
	call INITFIREDATA
	mov  fdata, 1


fb@init:
	cmp  spinflag, 0
	je   short nospiral

	jmp  short @inicio

nospiral:
	mov   spiral, 0
	mov   direct, 3

@inicio:
	mov  ax, spiral
	call LINEUP
	call MAKESTAR

; Spiral code
	mov al, direct
	cmp al, tm@dirflag
	je  short startstar

	mov al, tm@dirflag
	mov direct, al



startstar:
	cmp tm@dirflag, 0
	je  short fb@incsp
	cmp tm@dirflag, 1
	je  short fb@decsp
	jmp fb@testkb
	
fb@incsp:
	add spiral, 1
	cmp spiral, 3
	jb  short fb@testkb
	mov spiral, 2
	jmp fb@testkb

fb@decsp:
	sub spiral, 1
	cmp spiral, -3
	jg  short fb@testkb
	mov spiral, -2

fb@testkb:
	ret               ; s'acab¢.
 ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; PROCEDIMIENTO:³ INITTABS
;---------------³-------------------------------------------------------------
; FUNCION:      ³ Inicia la tabla de divisiones y la de corresp. circulares
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
 align 16
 INITTABS PROC

;----------------------------------------------------
; Inicia la tabla de colores
	xor cx, cx
	mov edi, coltab

idt@cltab1:
	mov ax, cx
	cmp ax, 63
	jb  short idt@color_ok2
	mov ax, 63

idt@color_ok2:
	mov [edi], al
	inc edi
	inc cx
	cmp cx, 256
	jb  short idt@cltab1


;----------------------------------------------------
; Inicia la tabla de divisiones
	xor ecx, ecx
	mov edi, divtab

idt@loop1:
	mov ax, cx
	sub ax, Fire_dec
	
	sar ax, 2
	jns short idt@color_ok
	xor ax, ax

idt@color_ok:
	mov [edi], al
	inc edi
	inc cx
	cmp cx, 256*4
	jb  short idt@loop1


;----------------------------------------------------
; Inicia la tabla de valores circulares

	mov  edi, circletab
	mov  ebp, circlebuf	; EBP en el buffer de la strella

	finit
	fldpi
	fild fwidth_by2
	fdivp st(1),st

	fstp incr		; Incrementa (PI / (BASE/2))
	fldz			; 

loopradio:
	mov  cx, Fire_X

loopcircle:
	fld  st			; Carga el incremento actual
	fsin			; Halla el seno
	fimul r			; Lo multiplica por el radio
	fistp result

;	mov  eax, Star_X	; Lo multiplica por la X = Offset Y
	mov  eax, Star_X*2	; Lo multiplica por la X = Offset Y
	mul  result

	fld  st			; Carga el incremento actual
	fcos			; Halla el coseno
	fimul r			; Lo multiplica por el radio
	fistp result		; result = offset X
	
	add  ax, result		; Le suma a ax el resultado
	
	add  ax, ((Star_X*2)*(Star_Y/2)) + (Star_X/2)
	add  eax, ebp		; Lo pone en mitad de la pantalla y le suma
				; la memoria de v¡deo

	fadd incr		; Incrementa los radianes

	mov  [edi], eax
	add  edi, 4

	dec  cx
	jnz  short loopcircle

	dec  r
	cmp  r, Star_Radio2
	jg   short loopradio

;----------------------------------------------------

	ret
 ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; PROCEDIMIENTO:³ INITFIREDATA
;---------------³-------------------------------------------------------------
; FUNCION:      ³ Inicia los datos necesarios para el fuego
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
 align 16
 INITFIREDATA PROC
	pushad

; Tabla de divisiones
	mov  eax, 256*4
	add  eax, 4
	call _gethimem
	jc   if@exit
	and  al, 11111100b
	mov  divtab, eax

; Buffer para el fuego (normal) Fire_X*Fire_Y
	mov  eax, Fire_X*Fire_Y
	mov  ecx, eax
	add  eax, 4
	call _gethimem
	jc   if@exit
	and  al, 11111100b
	mov  firebuf, eax
	mov  edi,eax
	xor  eax, eax
	shr  ecx, 2
	rep  stosd


; Buffer para el c¡rculo
	extrn Tflareptr:dword
	mov  eax, Tflareptr
	mov  circlebuf, eax
	mov  edi, eax
	mov  ecx, Star_X*Star_Y*2
	shr  ecx, 2
	xor  eax, eax
	rep  stosd


; Tabla de offsets para generar el fuego circular
	mov  eax, Fire_X*Fire_Y*4
	add  eax, 4
	call _gethimem
	jc   if@exit
	and  al, 11111100b
	mov  circletab, eax
	mov  edi, eax
	mov  ecx, Fire_X*Fire_Y*4
	shr  ecx, 2
	xor  eax, eax
	rep  stosd


; Tabla para los colores
	mov  eax, 256
	add  eax, 4
	call _gethimem
	jc   if@exit
	and  al, 11111100b
	mov  coltab, eax


; Inicia la tabla de divisiones y offsets circulares
	call INITTABS

if@exit:
	popad
	ret
 ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; PROCEDIMIENTO:³ LINEUP
;---------------³-------------------------------------------------------------
; FUNCION:      ³ Traza la animaci¢n del fuego
;---------------³-------------------------------------------------------------
; PARAMETROS:   ³ AX: Factor de espiral
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
 align 16
 LINEUP PROC

	mov  incfact, ax
	mov  cx, Fire_X/4
	mov  edi, firebuf
	add  edi, Fire_X * (Fire_Y-1)

	mov  ebp, fseed

; Randomiza la l¡nea inferior horizontal
@bucrnd:

	mov  eax, ebp
	add  eax, eax
	jnc  short aleat_1
	xor  eax, 22932293h
aleat_1:mov  ebp, eax

 	and  eax, (((Fire_maxcol*256)+Fire_maxcol)*65536)+(Fire_maxcol*256)+Fire_maxcol
	mov  [edi], eax
	add  edi, 4

	dec  cx
	jnz  short @bucrnd

	mov  fseed, ebp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Bucle que genera el fuego
; Se va de m s a menos..

	movsx ebp, incfact
	mov  esi, divtab
	mov  edi, firebuf 
	add  edi, (Fire_X * (Fire_Y-2)) + (Fire_X-1)
	mov  ecx, Fire_X * (Fire_Y-1)
	xor  eax, eax
	xor  edx, edx
	mov  dl,[edi+Fire_X-1+ebp]

@bucle:	mov ax, dx
	mov dl,[edi+Fire_X+ebp]
	add ax,dx
	mov dl,[edi]
	add ax,dx
	mov dl,[edi+Fire_X+1+ebp]
	add ax,dx
	mov dl,[edi+Fire_X-1+ebp]  		; Evita la espera

; Se usa una tabla para decrementar el fuego
	mov  al, [esi+eax]
	mov  [edi], al
	dec  edi
	dec  cx
	jnz  short @bucle
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	ret
 ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; PROCEDIMIENTO:³ MAKESTAR
;---------------³-------------------------------------------------------------
; FUNCION:      ³ Muestra el buffer usado en el efecto estrella
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
 align 16
 MAKESTAR PROC

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; C¢digo kutre de relleno
	mov  edi, circlebuf
;	mov  ebx, (((Star_X*(Star_Y/2))-((square/2)*Star_X)))+((Star_X/2)-(square/2))

	mov  ebx, (Star_X*2)*(Star_Y/2)
	sub  ebx, (square/2)*(Star_X*2)
	add  ebx, (Star_X/2)-(square/2)
	add  edi, ebx


	mov  cx, square / 4
	mov  bp, square
	mov  eax, (63*65536*256)+(63*65536)+(63*256)+63

sb@loop1:
	mov  [edi], eax
	add  edi, 4
	dec  cx
	jnz  short sb@loop1

	mov  cx, square	/ 4
	add  edi, (Star_X*2) - square
	dec  bp
	jnz  short sb@loop1


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Loop que genera la estrella   
        mov  esi, firebuf
	mov  ebx, circletab
	mov  cx, Fire_X*(Fire_Y-2)
	mov  ebp, coltab
	xor  eax, eax

sb@inner:
	mov  al,[esi]		; get colour from fire buffer
	mov  edi, [ebx]		; get circular offset
	mov  dl, [ebp+eax]
	add  esi, 1
	add  ebx, 4
	mov  [edi], dl		; put the colour on screen
	dec  cx
	jnz  short sb@inner

	ret

 ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; PROCEDIMIENTO:³ SHOWSTAR
;---------------³-------------------------------------------------------------
; FUNCION:      ³ Muestra la estrella antializada en la textura
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; x1
;y1ÚÄÄÄÄÄÄÄÄÄ¿
;  ³         ³
;  ³         ³
;  ³         ³
;  ³         ³
;  ÀÄÄÄÄÄÄÄÄÄÙy2
;           x2
 S_x1	dw	?
 S_y1	dw	?
 valadd dd	?
;-----------------------------------------------------------------------------
 align 16
 SHOWSTAR PROC

	mov  cx, Star_X
	mov  bp, Star_Y
	mov  esi, circlebuf
	@rlp edi, 0a0000h+(160-100)

; Calcula el valor de suma
	mov  eax, Screen_X+(Screen_X-(Star_X*2))
	mov  valadd, eax
	xor  bx, bx
	xor  dx, dx

ss@loop:
	mov  ax, [esi]
	mov  bl, al
	mov  dl, ah
	add  bx, dx
	shr  bx, 1
	mov  ah, bl
	mov  [edi], ax
   	mov  [edi+Screen_X], ax
	add  esi, 1
	add  edi, 2
	dec  cx
	jnz  short ss@loop
	mov  cx, Star_X
	add  edi, valadd
	dec  bp
	jnz  short ss@loop

	ret
 ENDP
ends
end
