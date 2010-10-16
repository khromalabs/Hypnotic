;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±                        RUTINA ESTRELLITAS RUTILANTES                      ±
;±-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-±
;±                       1995 Khroma (A.K.A Rub‚n G¢mez)                     ±
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

    public INITSTARSDATA
    public MAKESTARS

    extrn WAITRETRACE:near, screen:ScreenINFO, timer:TimerINFO
    extrn SETPAL:near, TheWorld:dword, SETMAT:near, Rtype:word


; Macro para rotar las estrellas
    @ROTATE_STAR MACRO
	mov  eax, vector.x
	imul vector.y
	shrd eax, edx, 16
	mov  ebp, eax
	mov  ebx, vector.y

	mov  eax, s_mat.x0	; Px = [(a+y)*(b+x)] + (c*z) - (x*y) - (a*b)
	add  eax, ebx
	mov  edi, eax
	mov  eax, s_mat.y0
	add  eax, vector.x
	imul edi
	shrd eax, edx, 16
	mov  edi, eax
	mov  eax, vector.z
	imul s_mat.z0
	shrd eax, edx, 16
	add  eax, edi
	sub  eax, ebp
	sub  eax, s_mat.xy0
	push eax


	mov  eax, s_mat.x1	; Py = [(d+y)*(e+x)] + (f*z) - (x*y) - (d*e)
	add  eax, ebx
	mov  edi, eax
	mov  eax, s_mat.y1
	add  eax, vector.x
	imul edi
	shrd eax, edx, 16
	mov  edi, eax
	mov  eax, vector.z
	imul s_mat.z1
	shrd eax, edx, 16
	add  eax, edi
	sub  eax, ebp
	sub  eax, s_mat.xy1
	push eax


	mov  eax, s_mat.x2	; Pz = [(g+y)*(h+x)] + (i*z) - (x*y) - (f*g)
	add  eax, ebx
	mov  edi, eax
	mov  eax, s_mat.y2
	add  eax, vector.x
	imul edi
	shrd eax, edx, 16
	mov  edi, eax
	mov  eax, vector.z
	imul s_mat.z2
	shrd eax, edx, 16
	add  eax, edi
	sub  eax, ebp
	sub  eax, s_mat.xy2
	mov  vector.z, eax

	pop  vector.y
	pop  vector.x

  ENDM


; Valor de centro
 SXC  = 160*65536
 SYC  = 120*65536

; Valor absoluto
 @abs MACRO reg
 	cmp &reg, 0
 	jge short $+4
 	neg &reg
 ENDM

; Definiciones para las estrellas
  numstars     = 1500             ; Direcci¢n I/O del Sequence Controler
  SEQU_ADDR    = 3C4h
  COLBASE      = 7*32*256

code32  segment para public use32
	assume cs:code32, ds:code32

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  D a t o s
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	align 4
	starsbuf	dd	0
	star_x		dw	?
	star_y		dw	?
	seed            dw      7264h 
	bptable		db	0001b, 0010b, 0100b, 1000b
	camera_var	dd	?
	s_mat		matriz	?
	vector		dot3d	?

	align 4
	bptot		dd	0, 19200, 38400, 57600

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  C ¢ d i g o
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; PROCEDIMIENTO:³ MAKESTARS
;---------------³-------------------------------------------------------------
; FUNCION:      ³ Crea las estrellas en la pantalla
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
 align 16
 MAKESTARS PROC

        mov   cx, numstars
	mov   esi, starsbuf 

	mov   ebx, offset s_mat
	mov   edi, camera_var
	add   edi, size dot3d
	cmp   al, 1
	je    short inidot
	pushad
	call  SETMAT
	popad


inidot:
; Copia los datos del vector
	mov  edi, camera_var
	mov  eax, [esi].s_pos.x
	mov  ebx, [esi].s_pos.y
	mov  edx, [esi].s_pos.z

	sub  eax, [edi].x
	mov  vector.x, eax
	sub  ebx, [edi].y
	mov  vector.y, ebx
	sub  edx, [edi].z
	mov  vector.z, edx

; Lo rota
	@ROTATE_STAR

; Comprueba la Z
	mov  ebx, vector.z
	cmp  ebx, 65536
	jl   nexdot


; Traslada la coordenada X
	mov  eax, vector.x   ; Punto_x = ((V.x * 256) / V.z) + x_centro
	sub  eax, camera.x
	mov  edx, eax
	sar  edx, 16
	shl  eax, 16
	idiv ebx
	shl  eax, 8
	add  eax, SXC
	shr  eax, 16
	mov  star_x, ax
	cmp  ax, screen.xmax
	jg   nexdot
	cmp  ax, 0
	jl   nexdot

; Traslada la coordenada Y
	mov  eax, vector.y   ; Punto_y = ((V.y * -256) / V.z) + y_centro
	sub  eax, camera.y
	mov  edx, eax
	sar  edx, 16
	shl  eax, 16
	idiv ebx
	shl  eax, 8
	add  eax, SYC
	shr  eax, 16
	mov  star_y, ax
	cmp  ax, screen.ymax
	jg   nexdot
	cmp  ax, 0
	jl   nexdot

; Dibuja la estrella
	test Rtype, BLUR OR TRANS OR RAW
	jnz  short invirtual

	xor  edi, edi		; Direcci¢n en memoria de v¡deo
	mov  di, star_y
	lea  edi, [edi+edi*4]	; EDI = EDI * (16*5) = EDI * 80
	shl  edi, 4
	xor  eax, eax
	mov  ax, star_x
	shr  eax, 2
	add  edi, eax
	add  edi, screen.acceso

	mov  dx, SEQU_ADDR	; Seleccionamos en la VGA el Bit-plane
	mov  al, 2		; adecuado
	out  dx, al
	mov  al, byte ptr star_x
	and  eax, 3
	inc  dx
	mov  al, bptable[eax]
	out  dx, al		; Lo escribimos en el Map-Register

	mov  ax, [esi].s_col
	mov  bl, ah
	mov  [edi], bl

	jmp  ccomp

invirtual:
	xor  eax, eax
	mov  edi, eax		; Direcci¢n en memoria de v¡deo
	mov  di, star_y
	lea  edi, [edi+edi*4]	; EDI = EDI * (16*5) = EDI * 80
	shl  edi, 4
	mov  ax, star_x
	shr  eax, 2
	add  edi, eax

	mov  ax, star_x
	and  eax, 3
	add  edi, bptot[eax*4]
	add  edi, screen.vscreen

	mov   ax, [esi].s_col
	mov   bl, byte ptr [edi]
	test  bl, bl
	jnz   short ccomp
	mov   [edi], ah

ccomp:
; Compara el valor del color
	mov  bp, [esi].s_speed
	imul bp, timer.rcount
	
	cmp  [esi].s_dir, 0
	jne  short ms@testmin

ms@testmax:
	add  ax, bp
	cmp  ax, [esi].s_col2
	jle  short setcol
	mov  ax, [esi].s_col2
	mov  [esi].s_dir, 1
	jmp  short setcol


ms@testmin:
	sub  ax, bp
	cmp  ax, [esi].s_col1
	jge  short setcol
	mov  ax, [esi].s_col1
	mov  [esi].s_dir, 0 

setcol:
 	mov  [esi].s_col, ax
; Loop
nexdot:
	add  esi, size star
	dec  cx
	jnz  inidot

	ret               ; s'acab¢.
 ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; PROCEDIMIENTO:³ INITSTARS
;---------------³-------------------------------------------------------------
; FUNCION:      ³ Inicia las estrellas (randomiza los valores)
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
 align 16
 INITSTARS PROC

; Inicia las posiciones
	mov  cx, numstars
	mov  edi, starsbuf


; Inicia los datos de cada estrella (siempre aleatorios)
is@loop1:
	call  ALEAT
	shl   eax, 15
	mov   edx, eax
	@abs  edx
	mov   ebx, edx
	mov   [edi].s_pos.x, eax
	
is@y1:	call  ALEAT
	shl   eax, 15
	mov   edx, eax
	@abs  edx
	add   ebx, edx
	mov   [edi].s_pos.y, eax
	
is@z1:	call  ALEAT
	shl   eax, 15
	mov   edx, eax
	@abs  edx
	add   ebx, edx
	mov   [edi].s_pos.z, eax

	cmp   ebx, 3000*3*UNO
	jb    short is@loop1

	call  ALEATU
	and   ax, 11111111b
	mov   [edi].s_speed, ax

is@col1:
	call  ALEATU
	and   ax, 00001111b*256
	add   ax, COLBASE
	mov   [edi].s_col1, ax

is@col2:
	call  ALEATU
	and   ax, 00011111b*256	; 1111b para rango 1-16
	jz    short is@col2
	add   ax, COLBASE
	cmp   ax, [edi].s_col1
	je    short is@col2
	mov   [edi].s_col2, ax


; Averigua la direcci¢n
; El color 2 debe ser siempre el mayor
	mov   ax, [edi].s_col1
	cmp   [edi].s_col2, ax
 	jb    short it@sub

; Si col2 es mayor...
      	mov   [edi].s_dir, 0
	mov   [edi].s_col, ax
	jmp   short it@color

; y si no, SWAP!
it@sub:
	mov   bx, [edi].s_col2
	mov   [edi].s_dir, 1
	mov   [edi].s_col2, ax 
	mov   [edi].s_col1, bx
	mov   [edi].s_col, bx 

it@color:
	add   edi, size star
	dec   cx
	jnz   is@loop1

	ret

 ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; PROCEDIMIENTO:³ INITSTARSDATA
;---------------³-------------------------------------------------------------
; FUNCION:      ³ Inicia los datos necesarios para las estrellas
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
 align 16
 INITSTARSDATA PROC
	pushad

; Tabla de divisiones
	mov  eax, (size star) * numstars
	add  eax, 4
	call _gethimem
	and  al, 11111100b
	mov  starsbuf, eax

; Inicia la tabla de divisiones y offsets circulares
	call INITSTARS

; Inicia la camara
	mov   edi, TheWorld
	lea   eax, [edi].camera
	mov   camera_var, eax
	
	popad

	ret

 ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±----------------³----------------------------------------------------------±
;± PROCEDIMIENTO: Å ALEATORIO                                                ±
;±----------------³----------------------------------------------------------±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
align 16                                
ALEAT PROC

	push dx

	mov  ax, seed
	mov  dx,5d45h	;31415621 and 0ffffh
	inc  ax
	mul  dx
	rol  ax, 2
	mov  seed,ax

	sub  ax, 32768

	movsx eax, ax

	pop dx

	ret

ENDP

ALEATU PROC ;Unsigned!

	push dx
	xor  eax, eax

	mov  ax, seed
	mov  dx,5d45h	;31415621 and 0ffffh
	inc  ax
	mul  dx
	rol  ax, 2
	mov  seed,ax

	sub  ax, 32768
	pop dx 

	ret
ENDP
ends
end

