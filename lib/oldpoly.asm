;北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
;                        EXOMOTION Copyright (c) 1995                      
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;                         Khroma (A.K.A. Rub俷 Gez)                        
;北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�

  .386p
  jumps
  
;哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
;  D e c l a r a c i o n e s
;哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
  SEQU_ADDR    = 3C4h             ; Direcci I/O del Sequence Controler


;INTERFLAG = 1
  
  include pmode.inc
  include structs.inc
  
  public DTV_RAW
  public DTV_GT
  public DTV_MAP
  public DTV_BLUR
  public DTV_GOR
  public DRAWFLARE
  public goutab
  
  extrn screen:ScreenINFO
  extrn stone_map:byte
  extrn	TheWorld:dword
  extrn Rtype:word

  extrn Tflareptr:dword
  extrn light_table2:dword

 SXC  = 160*65536
 SYC  = 120*65536


code32  segment para public use32
	assume cs:code32, ds:code32

;哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
;  M a c r o s  
;哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
  @cdq MACRO
    mov edx, eax
    sar edx, 31
  ENDM

;哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
;  D a t o s  
;哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
    align 4

; Array temporal de los valores X,Y
    ppix 	dot2d   3 dup(?)
    polyptr	dd	?

; Datos para la interpolaci de texturas
    dvt		dd	?
    dut		dd	?
    dvt2	dd	?
    dut2	dd	?
    div_val_v	dd	?
    div_val_u	dd	?
    TINC_U	dd	?
    TINC_U2	dd	?
    TINC2_U	dd	?
    TINC2_U2	dd	?
    TINC_V	dd	?
    TINC_V2	dd	?
    TINC2_V	dd	?
    TINC2_V2	dd	?

; Colores de los tri爂ulos, o valores de intensidad
    dzt		dd	?
    dzt2	dd	?
    pcol0	dd	?
    pcol1	dd	?
    pcol2	dd	?

; Punteros a las estructuras de v俽tices
    p0v   	dd	?
    p1v		dd	?
    p2v    	dd	?

    DTV@T10_V	dd	?
    DTV@T20_V	dd	?
    DTV@T21_V	dd	?
    DTV@T10_U	dd	?
    DTV@T20_U	dd	?
    DTV@T21_U	dd	?

; Datos para la interpolaci de leas
    DTV@R10_X	dd	?
    DTV@R20_X	dd	?
    DTV@R21_X	dd	?
    DTV@R10_Y	dd	?
    DTV@R20_Y	dd	?
    DTV@R21_Y	dd	?

    INC_Y	dd	?
    INC_Y2	dd	?
    INC2_Y	dd	?
    INC2_Y2	dd	?

; Datos para la interpolaci de colores
    VAL1  	dd	?
    CINC_Y	dd	?
    CINC_Y2	dd	?
    CINC2_Y	dd	?
    CINC2_Y2	dd	?

; Datos de la rutina que mapea las leas
    bptable	db	0001b, 0010b, 0100b, 1000b
    L@SY	dw	?
    L@SX	dw	?
    L@DU	dd	?
    L@DV	dd	?
    L@DZ	dd	?


; Tabla para el Gouraud
   goutab	db	32 	dup(?)

; Flag que se activa cuando el incremento ya ha sido calculado una vez...
   interflag	db	?

;哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
;  C � d i g o
;哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
;北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
;� PROCEDIMIENTO: � DTV_MAP                                                  �
;�----------------�----------------------------------------------------------�
;� FUNCION:       � Dibuja un tri爊gulo vertical, mapeando una textura       �
;�----------------�----------------------------------------------------------�
;� PARAMETROS:    � EBX = Puntero a estructura de datos del polono         �
;北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
 align 16
 DTV_MAP  PROC
	ret
 ENDP

;北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
;� PROCEDIMIENTO: � DTV_RAW                                                  �
;�----------------�----------------------------------------------------------�
;� FUNCION:       � Dibuja un tri爊gulo flat                                 �
;�----------------�----------------------------------------------------------�
;� PARAMETROS:    � EBX = Puntero a estructura de datos del polono         �
;北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
 align 16
 DTV_RAW  PROC

; Dibuja el tri爊gulo
	xor   eax, eax
	mov   INC_Y, eax	  ; Inicia los incrementos
	mov   INC_Y2, eax
	mov   INC2_Y, eax
	mov   INC2_Y2, eax

	mov   esi, [ebx].dotinx
	mov   edi, [ebx+4].dotinx
	mov   ebp, [ebx+8].dotinx

	mov   eax, [esi].Pixel.x	; EAX = v[0].x
	mov   ebx, [edi].Pixel.x	; EBX = v[1].x
	mov   edx, [ebp].Pixel.x	; EDX = v[2].x


; == if(v[0].x > v[2].x) xchg(v[0], v[2]) ===================================
	cmp  eax, edx
	jle  short raw@noch

	xchg esi, ebp
	xchg eax, edx
	jmp  short raw@noch

; == if(v[0].x > v[1].x) xchg(v[0], v[1]) ===================================
raw@noch:
	cmp  eax, ebx
	jl   short raw@noch3
	je   short raw@noch2

	xchg esi, edi
	xchg eax, ebx
	jmp  short raw@noch3

; == if(v[0].x == v[1].x) && (v[0].y > v[1].y)) xchg(v[0], v[1]) ============
raw@noch2:
	mov  ecx, [esi].y
	cmp  ecx, [edi].y
	jle  short raw@noch3

	xchg esi, edi
	xchg eax, ebx

; == if(v[1].x > v[2].x) xchg(v[1], v[2]) ===================================
raw@noch3:	cmp  ebx, edx
	jl   short raw@dosubs
	je   short raw@noch4

	xchg edi, ebp
	xchg ebx, edx
	jmp  short raw@noch5

; == if(v[1].x == v[2].x) && (v[1].y > v[2].y)) xchg(v[1], v[2])  ===========
raw@noch4:
	mov  ecx, [edi].y
	mov  ecx, [ebp].y
	jle  short raw@dosubs

	xchg edi, ebp	
	xchg ebx, edx

; == if(v[0].x == v[1].x) && (v[0].y > v[1].y)) xchg(v[0], v[1]) ============
raw@noch5:
	cmp  eax, ebx
	jne  short raw@dosubs
	mov  ecx, [esi].y
	cmp  ecx, [edi].y

	jle  short raw@dosubs
	xchg esi, edi

raw@dosubs:
	mov   eax, [esi].Pixel.x
	mov   ppix.x, eax
	mov   eax, [esi].Pixel.y
	mov   ppix.y, eax

	mov   eax, [edi].Pixel.x
	mov   ppix[8].x, eax
	mov   eax, [edi].Pixel.y
	mov   ppix[8].y, eax

	mov   eax, [ebp].Pixel.x
	mov   ppix[16].x, eax
	mov   eax, [ebp].Pixel.y
	mov   ppix[16].y, eax

;----------------------------------------------------------------------------

	mov eax, [ppix+16].y		; resta21_y = v[2].y - v[1].y
	sub eax, [ppix+8].y
	mov DTV@R21_Y, eax
	mov eax, [ppix+16].y		; resta20_y = v[2].y - v[0].y
	sub eax, [ppix].y
	mov DTV@R20_Y, eax
	mov eax, [ppix+8].y		; resta10_y = v[1].y - v[0].y
	sub eax, [ppix].y
	mov DTV@R10_Y, eax

	mov eax, [ppix+16].x		; resta21_x = (v[2].x - v[1].x)
	sub eax, [ppix+8].x
	mov DTV@R21_X, eax
	mov eax, [ppix+8].x		; resta10_x = (v[1].x - v[0].x)
	sub eax, [ppix].x
	mov DTV@R10_X, eax
	mov eax, [ppix+16].x		; resta20_x = (v[2].x - v[0].x)
	sub eax, [ppix].x
	mov DTV@R20_X, eax
       

; Este cigo averigua cuales son los puntos izquierdo y derecho
	jz   short raw@noinc
	xor  ebx, ebx

	mov  bx, word ptr DTV@R20_X+2
	mov  eax, DTV@R20_Y
	@cdq
	idiv ebx
	mov  ecx, eax                   ; ECX = incremento de la lea
	xor  ebx, ebx
	mov  bx, word ptr DTV@R10_X+2
	imul ebx
	add  eax, [ppix].y		; POS_X = v[0].y + (resta10_x * inc)

	jmp  short raw@inic

raw@noinc:
	xor  ecx, ecx
	xor  ebx, ebx
        mov  eax, [ppix].y

; Aqu� se calculan los incrementos
raw@inic:
	cmp  dword ptr [ppix+8].y, eax
	jg   raw@lineizq

	cmp  word ptr DTV@R10_X+2, 0
	je   short raw@p1@2
	mov  bx, word ptr DTV@R10_X+2
	mov  eax, DTV@R10_Y
	@cdq
	idiv ebx
	mov  INC_Y, eax
	mov  INC_Y2, ecx

raw@p1@2:
	cmp  word ptr DTV@R21_X+2, 0
	je   raw@inil
	mov  bx, word ptr DTV@R21_X+2
	mov  eax, DTV@R21_Y
	@cdq
	idiv ebx
	mov  INC2_Y, eax
	mov  INC2_Y2, ecx

	jmp  raw@inil

;------ Si el punto medio pasa de la lea 0-2 los incrementos se cambian ---
raw@lineizq:
	cmp  word ptr DTV@R10_X+2, 0
	je   short raw@p2@2
	mov  bx, word ptr DTV@R10_X+2
	mov  eax, DTV@R10_Y
	@cdq
	idiv ebx
	mov  INC_Y, ecx
	mov  INC_Y2, eax

raw@p2@2:
	cmp  word ptr DTV@R21_X+2, 0
	je   short raw@inil
	mov  bx, word ptr DTV@R21_X+2
	mov  eax, DTV@R21_Y
	@cdq
	idiv ebx
	mov  INC2_Y, ecx
	mov  INC2_Y2, eax

; === Ya tenemos los incrementos, ahora dibujamos el polono ===============
raw@inil:
	xor  ecx, ecx
	mov  cx, word ptr [ppix+4]	; LCX = POS_Y (Low Word)
	mov  bx, word ptr [ppix+2]	; LBX = POS_X (NO LOW)

	mov  si, word ptr [ppix+2]
	cmp  si, word ptr [ppix+10]
	je   short raw@draw2

	mov  ax, cx
	shl  eax, 16			; UAX = POS_Y2 (Low  Word)
	mov  ax, word ptr [ppix+06]	; LAX = POS_Y  (High Word)
	mov  dx, ax			; LDX = POS_Y2 (High Word)

	mov  di, word ptr INC_Y2
	mov  word ptr VAL1+2, di	; USI = INC_Y2 (Low  Word)
	mov  di, word ptr INC_Y+2	; LSI = INC_Y  (High Word)
	mov  word ptr VAL1, di

raw@loop1:
	call _lverraw
	add  cx, word ptr INC_Y
	adc  eax, VAL1
	adc  dx, word ptr INC_Y2+2

	inc  bx
	cmp  bx, word ptr [ppix+10]

	jl   short raw@loop1
	jmp  short raw@chinc

raw@draw2:
	mov  dx, word ptr [ppix+14]	; LDX = POS_Y2 (High Word)
	mov  ax, word ptr [ppix+12]	; UAX = POS_Y2 (Low Word)
	shl  eax, 16
	mov  ax, word ptr [ppix+06]	; LAX = POS_Y (High Word)

raw@chinc:
	mov  di, word ptr [ppix+10]
	cmp  di, word ptr [ppix+18]
	je   short raw@fin
	mov  di, word ptr INC2_Y2
	mov  word ptr VAL1+2, di	; USI = INC_Y2 (Low  Word)
 	mov  di, word ptr INC2_Y+2	; LSI = INC_Y  (High Word)
	mov  word ptr VAL1, di

raw@loop2:
 	call _lverraw
	add cx, word ptr INC2_Y
	adc eax, VAL1
	adc dx, word ptr INC2_Y2+2

	inc bx
	cmp bx, word ptr [ppix+18]
	jl  short raw@loop2

raw@fin:
	ret
   
 ENDP


;北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
;� PROCEDIMIENTO: � LVER                                                     �
;�----------------�----------------------------------------------------------�
;� FUNCION:       � Crea una lea vertical RAW                              �
;�----------------�----------------------------------------------------------�
;� PARAMETROS:    � AX = Y1, DX = Y2, BX = X; BP = C1; SI = C2               �
;北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
;-----------------------------------------------------------------------------
align 16
_lverraw PROC

	cmp bx, 0               ; ‥ntra en pantalla?
	jl  lvraw@fincl
	cmp bx, screen.xmax
	jg  lvraw@fintot
	cmp dx, 0
	jl  lvraw@fincl
	cmp ax, screen.ymax
	jg  lvraw@fincl

	push eax edx ebx ecx esi

	cmp ax, 0               ; Si hay que recortarla...
	jge short lvraw@noas
	xor ax, ax
lvraw@noas:
	cmp dx, screen.ymax
	jle short lvraw@noas2
	mov dx, screen.ymax

lvraw@noas2:
 	mov L@SY, ax
	mov L@SX, bx

	mov  cx, dx		; Guardamos en CX el nero de repeticiones
	sub  cx, ax
        jz   short lvraw@finl

	xor  eax, eax
	mov  edi, eax		; Direcci en memoria de veo
	mov  di, L@SY
	lea  edi, [edi+edi*4]	; EDI = EDI * (16*5) = EDI * 80
	shl  edi, 4
	mov  ax, L@SX
	shr  eax, 2
	add  edi, eax

	mov  ax, L@SX
	and  eax, 3
	add  edi, bptot[eax*4]
	add  edi, screen.vscreen


	jmp  short lvraw@innerl
	align 16
lvraw@innerl:
	mov  byte ptr [edi], 2*32
        mov  byte ptr [edi+80], 2*32
	add  edi, 160
	sub  cx, 2
	jg   short lvraw@innerl

	jl   short lvraw@finl
	mov  byte ptr [edi], 2*32


lvraw@finl:
	pop esi ecx ebx edx eax

lvraw@fincl:
	ret

lvraw@fintot:
	add esp, 4
	ret

  ENDP


;北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
;� PROCEDIMIENTO: � DTV_GT                                                   �
;�----------------�----------------------------------------------------------�
;� FUNCION:       � Dibuja un tri爊gulo vertical                             �
;�----------------�----------------------------------------------------------�
;� PARAMETROS:    � EBX = Puntero a estructura de datos del polono         �
;北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
 align 16
 DTV_GT  PROC

; Dibuja el tri爊gulo
	mov   polyptr, ebx

; The color is used for text index...
	mov   esi, TheWorld
	movzx eax, [ebx].color
	mov   edi, [esi].text.[eax*4]

	mov   dword ptr @tex0+2, edi
	mov   dword ptr @tex1+2, edi
	mov   dword ptr @tex2+2, edi


; Inicio de los incrementos, Lea, Gouraud, y Texturas...
	mov   esi, [ebx].dotinx
	mov   edi, [ebx+4].dotinx
	mov   ebp, [ebx+8].dotinx

	mov   eax, [esi].Pixel.x	; EAX = v[0].x
	mov   ebx, [edi].Pixel.x	; EBX = v[1].x
	mov   edx, [ebp].Pixel.x	; EDX = v[2].x

; == if(v[0].x > v[2].x) xchg(v[0], v[2]) ===================================
	cmp  eax, edx
	jle  short @noch

	xchg esi, ebp
	xchg eax, edx
	jmp  short @noch

; == if(v[0].x > v[1].x) xchg(v[0], v[1]) ===================================
@noch:	cmp  eax, ebx
	jl   short @noch3
	je   short @noch2

	xchg esi, edi
	xchg eax, ebx
	jmp  short @noch3

; == if(v[0].x == v[1].x) && (v[0].y > v[1].y)) xchg(v[0], v[1]) ============
@noch2:	mov  ecx, [esi].Pixel.y
	cmp  ecx, [edi].Pixel.y
	jle  short @noch3

	xchg esi, edi
	xchg eax, ebx

; == if(v[1].x > v[2].x) xchg(v[1], v[2]) ===================================
@noch3:	cmp  ebx, edx
	jl   short @dosubs
	je   short @noch4

	xchg edi, ebp
	xchg ebx, edx
	jmp  short @noch5

; == if(v[1].x == v[2].x) && (v[1].y > v[2].y)) xchg(v[1], v[2])  ===========
@noch4:	mov  ecx, [edi].Pixel.y
	mov  ecx, [ebp].Pixel.y
	jle  short @dosubs

	xchg edi, ebp	
	xchg ebx, edx

; == if(v[0].x == v[1].x) && (v[0].y > v[1].y)) xchg(v[0], v[1]) ============
@noch5:	cmp  eax, ebx
	jne  short @dosubs
	mov  ecx, [esi].Pixel.y
	cmp  ecx, [edi].Pixel.y

	jle  short @dosubs
	xchg esi, edi

@dosubs:mov   eax, [esi].Pixel.x
	mov   ppix.x, eax
	mov   eax, [esi].Pixel.y
	mov   ppix.y, eax

	mov   eax, [edi].Pixel.x
	mov   ppix[8].x, eax
	mov   eax, [edi].Pixel.y
	mov   ppix[8].y, eax

	mov   eax, [ebp].Pixel.x
	mov   ppix[16].x, eax
	mov   eax, [ebp].Pixel.y
	mov   ppix[16].y, eax
;哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

	mov   eax, [esi].Shade
	shl   eax, 16
	mov   pcol0, eax

	mov   eax, [edi].Shade
	shl   eax, 16
	mov   pcol1, eax
	
	mov   eax, [ebp].Shade
	shl   eax, 16
	mov   pcol2, eax

; 哪哪 TEXTURE MAP ZONE ON 哪哪哪哪哪
	mov eax, [ebp].Map.u
	sub eax, [edi].Map.u
	mov DTV@T21_U, eax
	mov eax, [ebp].Map.u
	sub eax, [esi].Map.u
	mov DTV@T20_U, eax
	mov eax, [edi].Map.u
	sub eax, [esi].Map.u
	mov DTV@T10_U, eax

	mov eax, [ebp].Map.v
	sub eax, [edi].Map.v
	mov DTV@T21_V, eax
	mov eax, [edi].Map.v
	sub eax, [esi].Map.v
	mov DTV@T10_V, eax
	mov eax, [ebp].Map.v
	sub eax, [esi].Map.v
	mov DTV@T20_V, eax

	mov   p0v, esi
	mov   p1v, edi
	mov   p2v, ebp
; 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�


	mov eax, [ppix+16].y		; resta21_y = v[2].y - v[1].y
	sub eax, [ppix+8].y
	mov DTV@R21_Y, eax
	mov eax, [ppix+16].y		; resta20_y = v[2].y - v[0].y
	sub eax, [ppix].y
	mov DTV@R20_Y, eax
	mov eax, [ppix+8].y		; resta10_y = v[1].y - v[0].y
	sub eax, [ppix].y
	mov DTV@R10_Y, eax

	mov eax, [ppix+16].x		; resta21_x = (v[2].x - v[1].x)
	sub eax, [ppix+8].x
	mov DTV@R21_X, eax
	mov eax, [ppix+8].x		; resta10_x = (v[1].x - v[0].x)
	sub eax, [ppix].x
	mov DTV@R10_X, eax
	mov eax, [ppix+16].x		; resta20_x = (v[2].x - v[0].x)
	sub eax, [ppix].x
	mov DTV@R20_X, eax


; Este cigo averigua cuales son los puntos izquierdo y derecho
	jz   short @noinc

; 哪哪  GOURAUD ZONE ON 哪哪哪哪哪哪�
	mov  ebx, DTV@R20_X
	mov  eax, pcol2
	sub  eax, pcol0
	mov  edx, eax
	sar  edx, 16
	shl  eax, 16
	idiv ebx
	mov  edi, eax
; 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

; 哪哪 TEXTURE MAP ZONE ON 哪哪哪哪哪	; DV = (V2 - V1) / (end_x - start_x)
	mov  eax, DTV@T20_V  	     	; DU = (U2 - U1) / (end_x - start_x)
	mov  edx, DTV@T20_V
	sar  edx, 16
	shl  eax, 16
	idiv ebx
	mov  div_val_v, eax

	mov  eax, DTV@T20_U
	mov  edx, DTV@T20_U
	sar  edx, 16
	shl  eax, 16
	idiv ebx
	mov  div_val_u, eax
; 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

	mov  eax, DTV@R20_Y
	mov  edx, eax
	sar  edx, 16
	shl  eax, 16
	idiv ebx
	mov  ecx, eax                   ; ECX = Add per scanline
	xor  ebx, ebx
	mov  bx, word ptr DTV@R10_X+2
	imul ebx
	add  eax, [ppix].y		; POS_X = v[0].y + (resta10_x * inc)

	jmp  short @inic

@noinc:	xor  ecx, ecx
	xor  ebx, ebx
	mov  div_val_v, ebx
	mov  div_val_u, ebx
        mov  eax, [ppix].y

; Aqu� se calculan los incrementos
@inic:	cmp  dword ptr [ppix+8].y, eax
	jg   @lineizq

;赏屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯�
;悄 C A S E   1 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪亩
;韧屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯�
	cmp  DTV@R10_X, 0
	je   short @clear@1@1
	mov  ebx, DTV@R10_X
	mov  eax, DTV@R10_Y
	mov  edx, eax
	sar  edx, 16
	shl  eax, 16
	idiv ebx
	mov  INC_Y, eax
	mov  INC_Y2, ecx

; 哪哪  GOURAUD ZONE ON 哪哪哪哪哪哪�
	mov  eax, pcol1
	sub  eax, pcol0
	mov  edx, eax
	sar  edx, 16
	shl  eax, 16
	idiv ebx
	mov  CINC_Y, eax
	mov  CINC_Y2, edi
; 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
; 哪哪 TEXTURE MAP ZONE ON 哪哪哪哪哪
	mov  eax, DTV@T10_V
	mov  edx, eax
	sar  edx, 16
	shl  eax, 16
	idiv ebx
	mov  TINC_V, eax
	mov  eax, div_val_v
	mov  TINC_V2, eax

	mov  eax, DTV@T10_U
	mov  edx, eax
	sar  edx, 16
	shl  eax, 16
	idiv ebx
	mov  TINC_U, eax
	mov  eax, div_val_u
	mov  TINC_U2, eax
; 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	jmp  short @p1@2

@clear@1@1:
	mov  INC_Y, 0
	mov  INC_Y2, 0
	mov  CINC_Y, 0
	mov  CINC_Y2, 0
	mov  TINC_V, 0
	mov  TINC_V2, 0
	mov  TINC_U, 0
	mov  TINC_U2, 0

                                                                           
@p1@2:	cmp  DTV@R21_X, 0
	je   @clear@1@2
	mov  ebx, DTV@R21_X
	mov  eax, DTV@R21_Y
	mov  edx, eax
	sar  edx, 16
	shl  eax, 16
	idiv ebx
	mov  INC2_Y, eax
	mov  INC2_Y2, ecx

; 哪哪  GOURAUD ZONE ON 哪哪哪哪哪哪�
	mov  eax, pcol2
	sub  eax, pcol1
	mov  edx, eax
	sar  edx, 16
	shl  eax, 16
	idiv ebx
	mov  CINC2_Y, eax
	mov  CINC2_Y2, edi
; 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

; 哪哪 TEXTURE MAP ZONE ON 哪哪哪哪哪
	mov  eax, DTV@T21_V
	mov  edx, eax
	sar  edx, 16
	shl  eax, 16
	idiv ebx
	mov  TINC2_V, eax
	mov  eax, div_val_v
	mov  TINC2_V2, eax

	mov  eax, DTV@T21_U
	mov  edx, eax
	sar  edx, 16
	shl  eax, 16
	idiv ebx
	mov  TINC2_U, eax
	mov  eax, div_val_u
	mov  TINC2_U2, eax
; 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	jmp  @inil

@clear@1@2:
	mov  INC2_Y, 0
	mov  INC2_Y2, 0
	mov  CINC2_Y, 0
	mov  CINC2_Y2, 0
	mov  TINC2_V, 0
	mov  TINC2_V2, 0
	mov  TINC2_U, 0
	mov  TINC2_U2, 0

	jmp  @inil

;赏屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯�
;悄 C A S E   2 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪亩
;韧屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯�
@lineizq:cmp  DTV@R10_X, 0
	je   @clear@2@1
	mov  ebx, DTV@R10_X
	mov  eax, DTV@R10_Y
	mov  edx, eax
	sar  edx, 16
	shl  eax, 16
	idiv ebx
	mov  INC_Y, ecx
	mov  INC_Y2, eax

; 哪哪 TEXTURE MAP ZONE ON 哪哪哪哪哪
	mov  eax, DTV@T10_V
	mov  edx, eax
	sar  edx, 16
	shl  eax, 16
	idiv ebx
	mov  edx, div_val_v
	mov  TINC_V, edx
	mov  TINC_V2, eax

	mov  eax, DTV@T10_U
	mov  edx, eax
	sar  edx, 16
	shl  eax, 16
	idiv ebx
	mov  edx, div_val_u
	mov  TINC_U, edx
	mov  TINC_U2, eax
; 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
; 哪哪  GOURAUD ZONE ON 哪哪哪哪哪哪�
	mov  eax, pcol1
	sub  eax, pcol0
	mov  edx, eax
	sar  edx, 16
	shl  eax, 16
	idiv ebx
	mov  CINC_Y, edi
	mov  CINC_Y2, eax
; 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	jmp  short @p2@2

@clear@2@1:
	mov  INC_Y, 0
	mov  INC_Y2, 0
	mov  CINC_Y, 0
	mov  CINC_Y2, 0
	mov  TINC_V, 0
	mov  TINC_V2, 0
	mov  TINC_U, 0
	mov  TINC_U2, 0

@p2@2:	cmp  DTV@R21_X, 0
	je   @clear@2@2
	mov  ebx, DTV@R21_X
	mov  eax, DTV@R21_Y
	mov  edx, eax
	sar  edx, 16
	shl  eax, 16
	idiv ebx
	mov  INC2_Y, ecx
	mov  INC2_Y2, eax

; 哪哪�  TEXTURE MAP ZONE ON 哪哪哪哪 
	mov  eax, DTV@T21_V
	mov  edx, eax
	sar  edx, 16
	shl  eax, 16
	idiv ebx
	mov  edx, div_val_v
	mov  TINC2_V, edx
	mov  TINC2_V2, eax
		   
	mov  eax, DTV@T21_U
	mov  edx, eax
	sar  edx, 16
	shl  eax, 16
	idiv ebx
	mov  edx, div_val_u
	mov  TINC2_U, edx
	mov  TINC2_U2, eax
; 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
; 哪哪� GOURAUD ZONE ON 哪哪哪哪哪哪�
	mov  eax, pcol2
	sub  eax, pcol1
	mov  edx, eax
	sar  edx, 16
	shl  eax, 16
	idiv ebx
	mov  CINC2_Y, edi
	mov  CINC2_Y2, eax
; 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	jmp  short @inil

@clear@2@2:
	mov  INC2_Y, 0
	mov  INC2_Y2, 0
	mov  CINC2_Y, 0
	mov  CINC2_Y2, 0
	mov  TINC2_V, 0
	mov  TINC2_V2, 0
	mov  TINC2_U, 0
	mov  TINC2_U2, 0


;谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
;嘲鞍� Ya tenemos los incrementos, ahora dibujamos el polono 鞍鞍鞍鞍鞍鞍鞍�
;滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
@inil:
; Indica que se debe calcular el incremento en la lea...
	mov  interflag, 1

	xor  ecx, ecx
	mov  cx, word ptr [ppix+4]	; LCX = POS_Y (Low Word)
	mov  bx, word ptr [ppix+2]	; LBX = POS_X (NO LOW)

	mov  si, word ptr [ppix+2]
	cmp  si, word ptr [ppix+10]
	je   @draw2

	mov  ax, cx
	shl  eax, 16			; UAX = POS_Y2 (Low  Word)
	mov  ax, word ptr [ppix+06]	; LAX = POS_Y  (High Word)
	mov  dx, ax			; LDX = POS_Y2 (High Word)

	mov  di, word ptr INC_Y2
	mov  word ptr VAL1+2, di	; USI = INC_Y2 (Low  Word)
	mov  di, word ptr INC_Y+2	; LSI = INC_Y  (High Word)
	mov  word ptr VAL1, di

; 哪哪 TEXTURE MAP ZONE ON 哪哪哪哪哪
	mov  ebp, p0v
	mov  edi, [ebp].Map.v
	mov  dvt, edi
	mov  dvt2, edi
	mov  edi, [ebp].Map.u
	mov  dut, edi
	mov  dut2, edi
; 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

; 哪哪 GOURAUD ZONE ON 哪哪哪哪哪哪哪
	mov  edi, pcol0
	mov  dzt, edi
	mov  dzt2, edi
; 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	
@loop1:	call _lver_gt
	add  cx, word ptr INC_Y
	adc  eax, VAL1
	adc  dx, word ptr INC_Y2+2
; 哪哪 GOURAUD ZONE ON 哪哪哪哪哪哪哪
	mov  edi, CINC_Y
	add  dzt, edi
	mov  edi, CINC_Y2
	add  dzt2, edi
; 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
; 哪哪 TEXTURE MAP ZONE ON 哪哪哪哪哪
	mov  edi, TINC_V
	add  dvt, edi
	mov  edi, TINC_U
	add  dut, edi
	mov  edi, TINC_V2
	add  dvt2, edi
	mov  edi, TINC_U2
	add  dut2, edi
; 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	inc  bx
	cmp  bx, word ptr [ppix+10]

	jl   short @loop1
	jmp  short @chinc

@draw2:	mov  dx, word ptr [ppix+14]	; LDX = POS_Y2 (High Word)
	mov  ax, word ptr [ppix+12]	; UAX = POS_Y2 (Low Word)
	shl  eax, 16
	mov  ax, word ptr [ppix+06]	; LAX = POS_Y (High Word)

; 哪哪 TEXTURE MAP ZONE ON 哪哪哪哪哪
	mov  ebp, p0v
	mov  edi, [ebp].Map.v
	mov  dvt, edi
	mov  edi, [ebp].Map.u
	mov  dut, edi

	mov  ebp, p1v
	mov  edi, [ebp].Map.v
	mov  dvt2, edi
	mov  edi, [ebp].Map.u
	mov  dut2, edi
; 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
; 哪哪 GOURAUD ZONE ON 哪哪哪哪哪哪哪
	mov  edi, pcol0
	mov  dzt, edi
	mov  edi, pcol1
	mov  dzt2, edi
; 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

@chinc:	mov  di, word ptr [ppix+10]
	cmp  di, word ptr [ppix+18]
	je   @fin
	mov  di, word ptr INC2_Y2
	mov  word ptr VAL1+2, di	; USI = INC_Y2 (Low  Word)
 	mov  di, word ptr INC2_Y+2	; LSI = INC_Y  (High Word)
	mov  word ptr VAL1, di

@loop2: call _lver_gt
	add cx, word ptr INC2_Y
	adc eax, VAL1
	adc dx, word ptr INC2_Y2+2
; 哪哪 GOURAUD ZONE ON 哪哪哪哪哪哪哪
	mov  edi, CINC2_Y
	add  dzt, edi
	mov  edi, CINC2_Y2
	add  dzt2, edi
; 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
; 哪哪 TEXTURE MAP ZONE ON 哪哪哪哪哪
	mov  edi, TINC2_V
	add  dvt, edi
	mov  edi, TINC2_U
	add  dut, edi
	mov  edi, TINC2_V2
	add  dvt2, edi
	mov  edi, TINC2_U2
	add  dut2, edi
; 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	inc bx
	cmp bx, word ptr [ppix+18]
	jl  short @loop2

@fin:	ret
 ENDP


;北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
;� PROCEDIMIENTO: � LVER                                                     �
;�----------------�----------------------------------------------------------�
;� FUNCION:       � Crea una lea vertical Gouraud + Texture Map            �
;�----------------�----------------------------------------------------------�
;� PARAMETROS:    � AX = Y1, DX = Y2, BX = X                                 �
;北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
align 4
dut2l	dd	?
dzt2l	dd	?
tinc	dd	0

align 16
_lver_gt PROC

	cmp bx, 0               ; ‥ntra en pantalla?
	jl  @fincl
	cmp bx, screen.xmax
	jg  @fintot
	cmp dx, 0
	jl  @fincl
	cmp ax, screen.ymax
	jg  @fincl

	push eax edx ebx ecx

	cmp ax, 0               ; Si hay que recortarla...
	jge short @noas
	xor  ax, ax

@noas:	cmp  dx, screen.ymax
	jle  short @noas2

	xor  ecx, ecx
	mov  cx, dx		; Guardamos en CX el nero de repeticiones
	sub  cx, ax
	mov  tinc, ecx
	mov  dx, screen.ymax
	mov  cx, dx
	sub  cx, ax
        jz   @finl2
;	dec  cx
	jmp  short @noas3


@noas2:	xor  ecx, ecx
	mov  cx, dx		; Guardamos en CX el nero de repeticiones
	sub  cx, ax
        jz   @finl2
	mov  tinc, ecx


@noas3:	mov L@SY, ax
	mov L@SX, bx

	mov  dx, SEQU_ADDR	; Seleccionamos en la VGA el Bit-plane
	mov  al, 2		; adecuado
	out  dx, al
	mov  al, byte ptr L@SX
	and  eax, 3
	inc  dx
	mov  al, bptable[eax]
	out  dx, al		; Lo escribimos en el Map-Register

	xor  edi, edi		; Direcci en memoria de veo
	mov  di, L@SY
	lea  edi, [edi+edi*4]	; EDI = EDI * (16*5) = EDI * 80
	shl  edi, 4
	xor  eax, eax
	mov  ax, L@SX
	shr  eax, 2
	add  edi, eax
	add  edi, screen.acceso

ifdef	INTERFLAG
	cmp  interflag, 1
	jne  short lgt@initregs
endif
; 哪哪 TEXTURE MAP INTERPOLATION 哪哪
	mov  eax, dut2
	sub  eax, dut
	@cdq
	idiv tinc
	mov  L@DU, eax

	mov  eax, dvt2
	sub  eax, dvt
	@cdq
	idiv tinc
	mov  L@DV, eax
; 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

; 哪哪 GOURAUD  INTERPOLATION 哪哪哪�
	mov  eax, dzt2
	sub  eax, dzt
	@cdq
	idiv tinc
	mov  L@DZ, eax
; 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

ifdef	INTERFLAG
	mov  interflag, 0
endif

lgt@initregs:
; 哪哪哪 T E X T  M A P 哪哪哪哪哪哪�
	mov  bx, cx
	mov  eax, dvt-2			; Upper EAX = Low Pos V
	mov  ecx, L@DV-2		; Upper ECX = Low Inc V
	mov  cx, bx			; CX = Counter
	mov  ebx, dut-2			; Upper EBX = Low Pos U
	mov  ebp, L@DU-2		; Upper EBP = Low Inc U
	mov  bl, byte ptr dvt+2		; BL = High Pos V
	mov  bh, byte ptr dut+2		; BH = High Pos U
	mov  bp, word ptr L@DV+2	; BP = High Inc V
; 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

; 哪哪哪 G O U R A U D 哪哪哪哪哪哪哪
	mov  esi, dzt-2
	mov  edx, L@DZ-2
	
	mov  ah, byte ptr dzt+2
	mov  dh, byte ptr L@DZ+2
; 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

; 哪哪哪 T E X T  M A P 哪哪哪哪哪哪�
	mov  dl, byte ptr L@DU+2	; DX = High Inc U
; 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

;	add  eax, ecx
;	adc  ebx, ebp
;	adc  bh, dl

	jmp  short @innerl
	align 16
@innerl:push ebx
	and  ebx, 0111111101111111b
@tex0:	mov  bl, byte ptr @tex0[ebx]
	mov  bh, ah
	add  esi, edx
	adc  ah, dh
	and  ebx, 0ffffh
	mov  al, light_table[ebx]
	pop  ebx
	mov  [edi], al

	add  eax, ecx
	adc  ebx, ebp
	adc  bh, dl

	push ebx
	and  ebx, 0111111101111111b
@tex1:	mov  bl, byte ptr @tex1[ebx]
	mov  bh, ah
	add  esi, edx
	adc  ah, dh
	and  ebx, 0ffffh
	mov  al, light_table[ebx]
	pop  ebx
	mov  [edi+80], al

	add  eax, ecx
	adc  ebx, ebp
	adc  bh, dl

	add  edi, 160
	sub  cx, 2
	jg   short @innerl

	jl   short @finl

	and  ebx, 0111111101111111b
@tex2:	mov  bl, byte ptr @tex2[ebx]
	mov  bh, ah
	and  ebx, 0ffffh
	mov  al, light_table[ebx]
	mov  [edi], al

	
@finl:
@finl2:	pop ecx ebx edx eax

@fincl:	ret

@fintot:add esp, 4
	ret
  ENDP


;北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
;� PROCEDIMIENTO: � DTV_BLUR                                                 �
;�----------------�----------------------------------------------------------�
;� FUNCION:       � Dibuja un tri爊gulo vertical, mapeando una textura       �
;�----------------�----------------------------------------------------------�
;� PARAMETROS:    � EBX = Puntero a estructura de datos del polono         �
;北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
 align 16
 DTV_BLUR  PROC

; Dibuja el tri爊gulo
	mov   polyptr, ebx
	mov   esi, TheWorld

; The color is used for text index !
	movzx eax, [ebx].color
	mov   edi, [esi].text[eax*4]
        mov   dword ptr Btex0+2, edi
	mov   dword ptr Btex1+2, edi
 	mov   dword ptr Btex2+2, edi

; Inicio de los incrementos, Lea, Gouraud, y Texturas...
	mov   esi, [ebx].dotinx
	mov   edi, [ebx+4].dotinx
	mov   ebp, [ebx+8].dotinx

	mov   eax, [esi].Pixel.x	; EAX = v[0].x
	mov   ebx, [edi].Pixel.x	; EBX = v[1].x
	mov   edx, [ebp].Pixel.x	; EDX = v[2].x

; == if(v[0].x > v[2].x) xchg(v[0], v[2]) ===================================
	cmp  eax, edx
	jle  short Bnoch

	xchg esi, ebp
	xchg eax, edx
	jmp  short Bnoch

; == if(v[0].x > v[1].x) xchg(v[0], v[1]) ===================================
Bnoch:	cmp  eax, ebx
	jl   short Bnoch3
	je   short Bnoch2

	xchg esi, edi
	xchg eax, ebx
	jmp  short Bnoch3

; == if(v[0].x == v[1].x) && (v[0].y > v[1].y)) xchg(v[0], v[1]) ============
Bnoch2:	mov  ecx, [esi].Pixel.y
	cmp  ecx, [edi].Pixel.y
	jle  short Bnoch3

	xchg esi, edi
	xchg eax, ebx

; == if(v[1].x > v[2].x) xchg(v[1], v[2]) ===================================
Bnoch3:	cmp  ebx, edx
	jl   short Bdosubs
	je   short Bnoch4

	xchg edi, ebp
	xchg ebx, edx
	jmp  short Bnoch5

; == if(v[1].x == v[2].x) && (v[1].y > v[2].y)) xchg(v[1], v[2])  ===========
Bnoch4:	mov  ecx, [edi].Pixel.y
	mov  ecx, [ebp].Pixel.y
	jle  short Bdosubs

	xchg edi, ebp	
	xchg ebx, edx

; == if(v[0].x == v[1].x) && (v[0].y > v[1].y)) xchg(v[0], v[1]) ============
Bnoch5:	cmp  eax, ebx
	jne  short Bdosubs
	mov  ecx, [esi].Pixel.y
	cmp  ecx, [edi].Pixel.y

	jle  short Bdosubs
	xchg esi, edi

Bdosubs:mov   eax, [esi].Pixel.x
	mov   ppix.x, eax
	mov   eax, [esi].Pixel.y
	mov   ppix.y, eax

	mov   eax, [edi].Pixel.x
	mov   ppix[8].x, eax
	mov   eax, [edi].Pixel.y
	mov   ppix[8].y, eax

	mov   eax, [ebp].Pixel.x
	mov   ppix[16].x, eax
	mov   eax, [ebp].Pixel.y
	mov   ppix[16].y, eax

	mov   p0v, esi
	mov   p1v, edi
	mov   p2v, ebp
;哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	
; 哪哪 TEXTURE MAP ZONE ON 哪哪哪哪哪
	mov eax, [ebp].Map.u
	sub eax, [edi].Map.u
	mov DTV@T21_U, eax
	mov eax, [ebp].Map.u
	sub eax, [esi].Map.u
	mov DTV@T20_U, eax
	mov eax, [edi].Map.u
	sub eax, [esi].Map.u
	mov DTV@T10_U, eax

	mov eax, [ebp].Map.v
	sub eax, [edi].Map.v
	mov DTV@T21_V, eax
	mov eax, [edi].Map.v
	sub eax, [esi].Map.v
	mov DTV@T10_V, eax
	mov eax, [ebp].Map.v
	sub eax, [esi].Map.v
	mov DTV@T20_V, eax
; 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

	mov eax, [ppix+16].y		; resta21_y = v[2].y - v[1].y
	sub eax, [ppix+8].y
	mov DTV@R21_Y, eax
	mov eax, [ppix+16].y		; resta20_y = v[2].y - v[0].y
	sub eax, [ppix].y
	mov DTV@R20_Y, eax
	mov eax, [ppix+8].y		; resta10_y = v[1].y - v[0].y
	sub eax, [ppix].y
	mov DTV@R10_Y, eax

	mov eax, [ppix+16].x		; resta21_x = (v[2].x - v[1].x)
	sub eax, [ppix+8].x
	mov DTV@R21_X, eax
	mov eax, [ppix+8].x		; resta10_x = (v[1].x - v[0].x)
	sub eax, [ppix].x
	mov DTV@R10_X, eax
	mov eax, [ppix+16].x		; resta20_x = (v[2].x - v[0].x)
	sub eax, [ppix].x
	mov DTV@R20_X, eax

; Este cigo averigua cuales son los puntos izquierdo y derecho
	jz   short Bnoinc
	xor  ebx, ebx

; 哪哪 TEXTURE MAP ZONE ON 哪哪哪哪哪	; DV = (V2 - V1) / (end_x - start_x)
	mov  bx, word ptr DTV@R20_X+2	; DU = (U2 - U1) / (end_x - start_x)
	mov  eax, DTV@T20_V
	@cdq
	idiv ebx
	mov  div_val_v, eax

	mov  eax, DTV@T20_U
	@cdq
	idiv ebx
	mov  div_val_u, eax
; 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

	mov  eax, DTV@R20_Y
	@cdq
	idiv ebx
	mov  ecx, eax                   ; ECX = Add per scanline
	xor  ebx, ebx
	mov  bx, word ptr DTV@R10_X+2
	imul ebx
	add  eax, [ppix].y		; POS_X = v[0].y + (resta10_x * inc)

	jmp  short Binic

Bnoinc:	xor  ecx, ecx
	xor  ebx, ebx
	mov  div_val_v, ebx
	mov  div_val_u, ebx
        mov  eax, [ppix].y

; Aqu� se calculan los incrementos
Binic:	cmp  dword ptr [ppix+8].y, eax
	jg   Blineizq

;赏屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯�
;悄 C A S E   1 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪亩
;韧屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯�
	cmp  word ptr DTV@R10_X+2, 0
	je   short Bclear@1@1
	mov  bx, word ptr DTV@R10_X+2
	mov  eax, DTV@R10_Y
	@cdq
	idiv ebx
	mov  INC_Y, eax
	mov  INC_Y2, ecx

; 哪哪 TEXTURE MAP ZONE ON 哪哪哪哪哪
	mov  eax, DTV@T10_V
	@cdq
	idiv ebx
	mov  TINC_V, eax
	mov  eax, div_val_v
	mov  TINC_V2, eax

	mov  eax, DTV@T10_U
	@cdq
	idiv ebx
	mov  TINC_U, eax
	mov  eax, div_val_u
	mov  TINC_U2, eax
; 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	jmp  short Bp1@2

Bclear@1@1:
	mov  INC_Y, 0
	mov  INC_Y2, 0
	mov  TINC_V, 0
	mov  TINC_V2, 0
	mov  TINC_U, 0
	mov  TINC_U2, 0

Bp1@2:	cmp  word ptr DTV@R21_X+2, 0
	je   Bclear@2@2
	mov  bx, word ptr DTV@R21_X+2
	mov  eax, DTV@R21_Y
	@cdq
	idiv ebx
	mov  INC2_Y, eax
	mov  INC2_Y2, ecx

; 哪哪 TEXTURE MAP ZONE ON 哪哪哪哪哪
	mov  eax, DTV@T21_V
	@cdq
	idiv ebx
	mov  TINC2_V, eax
	mov  eax, div_val_v
	mov  TINC2_V2, eax

	mov  eax, DTV@T21_U
	@cdq
	idiv ebx
	mov  TINC2_U, eax
	mov  eax, div_val_u
	mov  TINC2_U2, eax
; 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	jmp  Binil
                                                                           
;赏屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯�
;悄 C A S E   2 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪亩
;韧屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯�
Blineizq:cmp  word ptr DTV@R10_X+2, 0                                       
	je   short Bclear@2@1
	mov  bx, word ptr DTV@R10_X+2
	mov  eax, DTV@R10_Y
	@cdq
	idiv ebx
	mov  INC_Y, ecx
	mov  INC_Y2, eax

; 哪哪 TEXTURE MAP ZONE ON 哪哪哪哪哪
	mov  eax, DTV@T10_V
	@cdq
	idiv ebx
	mov  edx, div_val_v
	mov  TINC_V, edx
	mov  TINC_V2, eax

	mov  eax, DTV@T10_U
	@cdq
	idiv ebx
	mov  edx, div_val_u
	mov  TINC_U, edx
	mov  TINC_U2, eax
; 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	jmp  short Bp2@2

Bclear@2@1:
	mov  INC_Y, 0
	mov  INC_Y2, 0
	mov  TINC_V, 0
	mov  TINC_V2, 0
	mov  TINC_U, 0
	mov  TINC_U2, 0

Bp2@2:	cmp  word ptr DTV@R21_X+2, 0
	je   short Bclear@2@2
	mov  bx, word ptr DTV@R21_X+2
	mov  eax, DTV@R21_Y
	@cdq
	idiv ebx
	mov  INC2_Y, ecx
	mov  INC2_Y2, eax

; 哪哪�  TEXTURE MAP ZONE ON 哪哪哪哪 
	mov  eax, DTV@T21_V
	@cdq
	idiv ebx
	mov  edx, div_val_v
	mov  TINC2_V, edx
	mov  TINC2_V2, eax
		   
	mov  eax, DTV@T21_U
	@cdq
	idiv ebx
	mov  edx, div_val_u
	mov  TINC2_U, edx
	mov  TINC2_U2, eax
; 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	jmp  short Binil

Bclear@2@2:
	mov  INC2_Y, 0
	mov  INC2_Y2, 0
	mov  TINC2_V, 0
        mov  TINC2_V2, 0
	mov  TINC2_U, 0
	mov  TINC2_U2, 0

;谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
;嘲鞍� Ya tenemos los incrementos, ahora dibujamos el polono 鞍鞍鞍鞍鞍鞍鞍�
;滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
Binil:
	mov  interflag, 1

	xor  ecx, ecx
	mov  edx, ecx
	mov  cx, word ptr [ppix+4]	; LCX = POS_Y (Low Word)
	mov  bx, word ptr [ppix+2]	; LBX = POS_X (NO LOW)

	mov  si, word ptr [ppix+2]
	cmp  si, word ptr [ppix+10]

	je   Bdraw2

	mov  ax, cx
	shl  eax, 16			; UAX = POS_Y2 (Low  Word)
	mov  ax, word ptr [ppix+06]	; LAX = POS_Y  (High Word)
	mov  dx, ax			; LDX = POS_Y2 (High Word)

	mov  di, word ptr INC_Y2
	mov  word ptr VAL1+2, di	; USI = INC_Y2 (Low  Word)
	mov  di, word ptr INC_Y+2	; LSI = INC_Y  (High Word)
	mov  word ptr VAL1, di

; 哪哪 TEXTURE MAP ZONE ON 哪哪哪哪哪
	mov  ebp, p0v
	mov  edi, [ebp].Map.v
	mov  dvt, edi
	mov  dvt2, edi
	mov  edi, [ebp].Map.u
	mov  dut, edi
	mov  dut2, edi
; 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

Bloop1:	add  cx, word ptr INC_Y
	adc  eax, VAL1
	adc  dx, word ptr INC_Y2+2
; 哪哪 TEXTURE MAP ZONE ON 哪哪哪哪哪
	mov  edi, TINC_V
	add  dvt, edi
	mov  edi, TINC_U
	add  dut, edi
	mov  edi, TINC_V2
	add  dvt2, edi
	mov  edi, TINC_U2
	add  dut2, edi
; 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	call _lver_blur
	
	inc  bx
	cmp  bx, word ptr [ppix+10]

	jl   short Bloop1
	jmp  short Bchinc

Bdraw2:	mov  dx, word ptr [ppix+14]	; LDX = POS_Y2 (High Word)
	mov  ax, word ptr [ppix+12]	; UAX = POS_Y2 (Low Word)
	shl  eax, 16
	mov  ax, word ptr [ppix+06]	; LAX = POS_Y (High Word)

; 哪哪 TEXTURE MAP ZONE ON 哪哪哪哪哪
	mov  ebp, p0v
	mov  edi, [ebp].Map.v
	mov  dvt, edi
	mov  edi, [ebp].Map.u
	mov  dut, edi

	mov  ebp, p1v
	mov  edi, [ebp].Map.v
	mov  dvt2, edi
	mov  edi, [ebp].Map.u
	mov  dut2, edi
; 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

Bchinc:	mov  di, word ptr [ppix+10]
	cmp  di, word ptr [ppix+18]
	je   Bfin
	mov  di, word ptr INC2_Y2
	mov  word ptr VAL1+2, di	; USI = INC_Y2 (Low  Word)
 	mov  di, word ptr INC2_Y+2	; LSI = INC_Y  (High Word)
	mov  word ptr VAL1, di

Bloop2: add cx, word ptr INC2_Y
	adc eax, VAL1
	adc dx, word ptr INC2_Y2+2
; 哪哪 TEXTURE MAP ZONE ON 哪哪哪哪哪
	mov  edi, TINC2_V
	add  dvt, edi
	mov  edi, TINC2_U
	add  dut, edi
	mov  edi, TINC2_V2
	add  dvt2, edi
	mov  edi, TINC2_U2
	add  dut2, edi
; 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	call _lver_blur

	inc bx
	cmp bx, word ptr [ppix+18]
	jl  short Bloop2

Bfin:	ret
   
 ENDP

;裳蜒蜒蜒蜒蜒蜒蜒蜒蜒蜒蜒蜒蜒眼圹圹圹毖�
;桥排排排排排排排排排排排排排袍迸排袍迸�
;桥袍圹圹迸排郾排排排郾排袍迸袍迸排袍迸�
;桥袍迸袍迸排郾排排排郾排袍迸袍迸排袍迸�
;桥袍迸袍迸排郾排排排郾排袍迸袍迸排袍迸�
;桥袍圹圹迸排郾排排排郾排袍迸袍圹圹圹圹郾
;桥袍迸袍迸排郾排排排郾排袍迸袍迸排排排郾
;桥袍圹圹迸排郾排排排郾排袍迸袍迸排排排郾
;桥排排排排排圹圹迸排郾排袍迸袍迸排排排郾
;认舷舷舷舷舷舷舷舷舷圹圹圹毕羡毕舷舷舷郾

;北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
;� PROCEDIMIENTO: � LVERBLUR                                                 �
;�----------------�----------------------------------------------------------�
;� FUNCION:       � Crea una lea vertical mapeada con efecto blur          �
;�----------------�----------------------------------------------------------�
;� PARAMETROS:    � AX = Y1, DX = Y2, BX = X; BP = C1; SI = C2               �
;北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
align 4
bptot	 dd	0, 19200, 38400, 57600

align 16
_lver_blur PROC


	cmp bx, 0               ; ‥ntra en pantalla?
	jl  bfincl
	cmp bx, screen.xmax
	jg  bfintot
	cmp dx, 1
	jl  bfincl
	cmp ax, screen.ymax
	jg  bfincl

	push eax edx ebx ecx

	cmp ax, 1               ; Si hay que recortarla...
	jge short bnoas
	mov ax, 1
bnoas:	cmp dx, screen.ymax
	jle short bnoas2
	mov dx, screen.ymax

bnoas2:	mov L@SY, ax
	mov L@SX, bx

	mov  cx, dx		; Guardamos en CX el nero de repeticiones
	sub  cx, ax
        jz   bfinl

	xor  eax, eax
	mov  edi, eax		; Direcci en memoria de veo
	mov  di, L@SY
	lea  edi, [edi+edi*4]	; EDI = EDI * (16*5) = EDI * 80
	shl  edi, 4
	mov  ax, L@SX
	shr  eax, 2
	add  edi, eax

	mov  ax, L@SX
	and  eax, 3
	add  edi, bptot[eax*4]
	add  edi, screen.vscreen

ifdef	INTERFLAGT   ;!!!!!!!!
	cmp  interflag, 1
	jne  short lbt@initregs
endif
; 哪哪 TEXTURE MAP ZONE ON 哪哪哪哪哪哪�
	mov  eax, dut2
	sub  eax, dut
	@cdq
	idiv ecx
	mov  L@DU, eax

	mov  eax, dvt2
	sub  eax, dvt
	@cdq
	idiv ecx
	mov  L@DV, eax

ifdef	INTERFLAGT
	mov  interflag, 0
endif

lbt@initregs:
	mov  bx, cx
	mov  eax, dvt-2			; Upper EAX = Low Pos V
	mov  ecx, L@DV-2		; Upper ECX = Low Inc V
	mov  cx, bx			; CX = Counter
	mov  ebx, dut-2			; Upper EBX = Low Pos U
	mov  ebp, L@DU-2		; Upper EBP = Low Inc U
	mov  bl, byte ptr dvt+2		; BL = High Pos V
	mov  bh, byte ptr dut+2		; BH = High Pos U
	mov  bp, word ptr L@DV+2	; BP = High Inc V
	mov  dx, word ptr L@DU+2	; DX = High Inc U
; 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪

	xor  esi, esi

	jmp  short binnerl
	align 16
binnerl:mov  si, bx
	add  eax, ecx
	adc  ebx, ebp
	adc  bh, dl
Btex0:	mov  al, byte ptr binnerl[esi]
;哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	add  al,al
	add  al, byte ptr [edi-80]
	add  al, byte ptr [edi+80]
	shr  al, 2
;哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	mov  [edi], al
	
	mov  si, bx
	add  eax, ecx
	adc  ebx, ebp
	adc  bh, dl
Btex1:	mov  al, byte ptr binnerl[esi]
;哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	add  al,al
	add  al, byte ptr [edi]
	add  al, byte ptr [edi+160]
	shr  al, 2
;哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	mov  [edi+80], al

	add  edi, 160
	sub  cx, 2
	jg   short binnerl

	jl   short bfinl

	mov  si, bx
Btex2:	mov  al, byte ptr binnerl[esi]
;哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	add  al,al
	add  al, byte ptr [edi-80]
 	add  al, byte ptr [edi+80]
	shr  al, 2
;哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	mov  [edi], al

bfinl:	pop ecx ebx edx eax

bfincl: ret

bfintot:add esp, 4
	ret

  ENDP


;北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
;� PROCEDIMIENTO: � DTV_GOR                                                  �
;�----------------�----------------------------------------------------------�
;� FUNCION:       � Dibuja un tri爊gulo vertical                             �
;�----------------�----------------------------------------------------------�
;� PARAMETROS:    � EBX = Puntero a estructura de datos del polono         �
;北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
 align 16
 DTV_GOR  PROC

; Dibuja el tri爊gulo
	mov   polyptr, ebx


; Inicio de los incrementos, Lea y Texturas...
	mov   esi, [ebx].dotinx
	mov   edi, [ebx+4].dotinx
	mov   ebp, [ebx+8].dotinx

	mov   eax, [esi].Pixel.x	; EAX = v[0].x
	mov   ebx, [edi].Pixel.x	; EBX = v[1].x
	mov   edx, [ebp].Pixel.x	; EDX = v[2].x

; == if(v[0].x > v[2].x) xchg(v[0], v[2]) ===================================
	cmp  eax, edx
	jle  short gor@noch

	xchg esi, ebp
	xchg eax, edx
	jmp  short gor@noch

; == if(v[0].x > v[1].x) xchg(v[0], v[1]) ===================================
gor@noch:	cmp  eax, ebx
	jl   short gor@noch3
	je   short gor@noch2

	xchg esi, edi
	xchg eax, ebx
	jmp  short gor@noch3

; == if(v[0].x == v[1].x) && (v[0].y > v[1].y)) xchg(v[0], v[1]) ============
gor@noch2:	mov  ecx, [esi].Pixel.y
	cmp  ecx, [edi].Pixel.y
	jle  short gor@noch3

	xchg esi, edi
	xchg eax, ebx

; == if(v[1].x > v[2].x) xchg(v[1], v[2]) ===================================
gor@noch3:cmp  ebx, edx
	jl   short gor@dosubs
	je   short gor@noch4

	xchg edi, ebp
	xchg ebx, edx
	jmp  short gor@noch5

; == if(v[1].x == v[2].x) && (v[1].y > v[2].y)) xchg(v[1], v[2])  ===========
gor@noch4:	mov  ecx, [edi].Pixel.y
	mov  ecx, [ebp].Pixel.y
	jle  short gor@dosubs

	xchg edi, ebp	
	xchg ebx, edx

; == if(v[0].x == v[1].x) && (v[0].y > v[1].y)) xchg(v[0], v[1]) ============
gor@noch5:	cmp  eax, ebx
	jne  short gor@dosubs
	mov  ecx, [esi].Pixel.y
	cmp  ecx, [edi].Pixel.y

	jle  short gor@dosubs
	xchg esi, edi

gor@dosubs:mov   eax, [esi].Pixel.x
	mov   ppix.x, eax
	mov   eax, [esi].Pixel.y
	mov   ppix.y, eax

	mov   eax, [edi].Pixel.x
	mov   ppix[8].x, eax
	mov   eax, [edi].Pixel.y
	mov   ppix[8].y, eax

	mov   eax, [ebp].Pixel.x
	mov   ppix[16].x, eax
	mov   eax, [ebp].Pixel.y
	mov   ppix[16].y, eax
;哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

	mov   eax, [esi].Shade
	shl   eax, 16
	mov   pcol0, eax

	mov   eax, [edi].Shade
	shl   eax, 16
	mov   pcol1, eax
	
	mov   eax, [ebp].Shade
	shl   eax, 16
	mov   pcol2, eax

	mov eax, [ppix+16].y		; resta21_y = v[2].y - v[1].y
	sub eax, [ppix+8].y
	mov DTV@R21_Y, eax
	mov eax, [ppix+16].y		; resta20_y = v[2].y - v[0].y
	sub eax, [ppix].y
	mov DTV@R20_Y, eax
	mov eax, [ppix+8].y		; resta10_y = v[1].y - v[0].y
	sub eax, [ppix].y
	mov DTV@R10_Y, eax

	mov eax, [ppix+16].x		; resta21_x = (v[2].x - v[1].x)
	sub eax, [ppix+8].x
	mov DTV@R21_X, eax
	mov eax, [ppix+8].x		; resta10_x = (v[1].x - v[0].x)
	sub eax, [ppix].x
	mov DTV@R10_X, eax
	mov eax, [ppix+16].x		; resta20_x = (v[2].x - v[0].x)
	sub eax, [ppix].x
	mov DTV@R20_X, eax

; Este cigo averigua cuales son los puntos izquierdo y derecho
	jz   short gor@noinc
; ----  GOURAUD ZONE ON -------------
	mov  ebx, DTV@R20_X
	mov  eax, pcol2
	sub  eax, pcol0
	mov  edx, eax
	shl  eax, 16
	sar  edx, 16
	idiv ebx
	mov  edi, eax
; -----------------------------------

	mov  eax, DTV@R20_Y
	mov  edx, eax
	shl  eax, 16
	sar  edx, 16
	idiv ebx
	mov  ecx, eax                   ; ECX = incremento de la lea
	xor  ebx, ebx
	mov  bx, word ptr DTV@R10_X+2
	imul ebx
	add  eax, [ppix].y		; POS_X = v[0].y + (resta10_x * inc)

	jmp  short gor@inic

gor@noinc:
	xor  ecx, ecx
        mov  eax, [ppix].y

; Aqu� se calculan los incrementos
gor@inic:
	cmp  dword ptr [ppix+8].y, eax
	jg   gor@lineizq

	cmp  DTV@R10_X, 0
	je   short gor@p1@2
	mov  ebx, DTV@R10_X
	mov  eax, DTV@R10_Y
	mov  edx, eax
	shl  eax, 16
	sar  edx, 16
	idiv ebx
	mov  INC_Y, eax
	mov  INC_Y2, ecx
; ----  GOURAUD ZONE ON -------------
	mov  eax, pcol1
        sub  eax, pcol0
	mov  edx, eax
	shl  eax, 16
	sar  edx, 16
	idiv ebx
	mov  CINC_Y, eax
	mov  CINC_Y2, edi
; -----------------------------------

gor@p1@2:cmp DTV@R21_X, 0
	je   gor@inil
	mov  ebx, DTV@R21_X
	mov  eax, DTV@R21_Y
	mov  edx, eax
	shl  eax, 16
	sar  edx, 16
	idiv ebx
	mov  INC2_Y, eax
	mov  INC2_Y2, ecx
; ----  GOURAUD ZONE ON -------------
	mov  eax, pcol2
	sub  eax, pcol1
	mov  edx, eax
	shl  eax, 16
	sar  edx, 16
	idiv ebx
	mov  CINC2_Y, eax
	mov  CINC2_Y2, edi
; -----------------------------------

	jmp  gor@inil

;------ Si el punto medio pasa de la lea 0-2 los incrementos se cambian ---
gor@lineizq:
	cmp  DTV@R10_X, 0
	je   short gor@p2@2
	mov  ebx, DTV@R10_X
	mov  eax, DTV@R10_Y
	mov  edx, eax
	shl  eax, 16
	sar  edx, 16
	idiv ebx
	mov  INC_Y, ecx
	mov  INC_Y2, eax
; ----  GOURAUD ZONE ON -------------
	mov  eax, pcol1
	sub  eax, pcol0
	mov  edx, eax
	shl  eax, 16
	sar  edx, 16
	idiv ebx
	mov  CINC_Y, edi
	mov  CINC_Y2, eax
;-----------------------------------

gor@p2@2:cmp DTV@R21_X, 0
	je   short gor@inil
	mov  ebx, DTV@R21_X
	mov  eax, DTV@R21_Y
	mov  edx, eax
	shl  eax, 16
	sar  edx, 16
	idiv ebx
	mov  INC2_Y, ecx
	mov  INC2_Y2, eax
; ----  GOURAUD ZONE ON -------------
	mov  eax, pcol2
	sub  eax, pcol1
	mov  edx, eax
	shl  eax, 16
	sar  edx, 16
	idiv ebx
	mov  CINC2_Y, edi
	mov  CINC2_Y2, eax
; -----------------------------------

; === Ya tenemos los incrementos, ahora dibujamos el polono ===============
gor@inil:
	mov  interflag, 1
	
	xor  ecx, ecx
	mov  cx, word ptr [ppix+4]	; LCX = POS_Y (Low Word)
	mov  bx, word ptr [ppix+2]	; LBX = POS_X (NO LOW)

	mov  si, word ptr [ppix+2]
	cmp  si, word ptr [ppix+10]
	je   short gor@draw2

	mov  ax, cx
	shl  eax, 16			; UAX = POS_Y2 (Low  Word)
	mov  ax, word ptr [ppix+06]	; LAX = POS_Y  (High Word)
	mov  dx, ax			; LDX = POS_Y2 (High Word)

	mov  di, word ptr INC_Y2
	mov  word ptr VAL1+2, di	; USI = INC_Y2 (Low  Word)
	mov  di, word ptr INC_Y+2	; LSI = INC_Y  (High Word)
	mov  word ptr VAL1, di

; ---- GOURAUD ZONE ON -------------
	mov  ebp, pcol0
	mov  esi, ebp
; ----------------------------------
	
gor@loop1:  call _lvergor
	add  cx, word ptr INC_Y
	adc  eax, VAL1
	adc  dx, word ptr INC_Y2+2
; ---- GOURAUD ZONE ON -------------
	add  ebp, CINC_Y
	add  esi, CINC_Y2
; ----------------------------------
	inc  bx
	cmp  bx, word ptr [ppix+10]

	jl   short gor@loop1
	jmp  short gor@chinc

gor@draw2:	mov  dx, word ptr [ppix+14]	; LDX = POS_Y2 (High Word)
	mov  ax, word ptr [ppix+12]	; UAX = POS_Y2 (Low Word)
	shl  eax, 16
	mov  ax, word ptr [ppix+06]	; LAX = POS_Y (High Word)
; ---- GOURAUD ZONE ON -------------
	mov  ebp, pcol0
	mov  esi, pcol1
; ----------------------------------

gor@chinc:	mov  di, word ptr [ppix+10]
	cmp  di, word ptr [ppix+18]
	je   short gor@fin
	mov  di, word ptr INC2_Y2
	mov  word ptr VAL1+2, di	; USI = INC_Y2 (Low  Word)
 	mov  di, word ptr INC2_Y+2	; LSI = INC_Y  (High Word)
	mov  word ptr VAL1, di

gor@loop2: 	call _lvergor
	add cx, word ptr INC2_Y
	adc eax, VAL1
	adc dx, word ptr INC2_Y2+2
; ---- GOURAUD ZONE ON -------------
	add  ebp, CINC2_Y
	add  esi, CINC2_Y2
; ----------------------------------
	inc bx
	cmp bx, word ptr [ppix+18]
	jl  short gor@loop2

gor@fin: ret
   
 ENDP


;北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
;� PROCEDIMIENTO: � LVER                                                     �
;�----------------�----------------------------------------------------------�
;� FUNCION:       � Crea una lea vertical GOURAUD                          �
;�----------------�----------------------------------------------------------�
;� PARAMETROS:    � AX = Y1, DX = Y2, BX = X; BP = C1; SI = C2               �
;北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
;-----------------------------------------------------------------------------
; Variables locales
align 16
_lvergor PROC

	cmp bx, 0               ; ‥ntra en pantalla?
	jl  gor@fincl
	cmp bx, screen.xmax
	jg  gor@fintot
	cmp dx, 0
	jl  gor@fincl
	cmp ax, screen.ymax
	jg  gor@fincl

	push eax edx ebx ecx esi ebp

	cmp ax, 0               ; Si hay que recortarla...
	jge short gor@noas
	xor ax, ax
gor@noas:
	cmp dx, screen.ymax
	jle short gor@noas2
	mov dx, screen.ymax

gor@noas2:
 	mov L@SY, ax
	mov L@SX, bx

	mov  cx, dx		; Guardamos en CX el nero de repeticiones
	sub  cx, ax
        jz   gor@finl

	mov  dx, SEQU_ADDR	; Seleccionamos en la VGA el Bit-plane
	mov  al, 2		; adecuado
	out  dx, al
	mov  al, byte ptr L@SX
	and  eax, 3
	inc  dx
	mov  al, bptable[eax]
	out  dx, al		; Lo escribimos en el Map-Register

	xor  edi, edi		; Direcci en memoria de veo
	mov  di, L@SY
	lea  edi, [edi+edi*4]	; EDI = EDI * (16*5) = EDI * 80
	shl  edi, 4
	xor  eax, eax
	mov  ax, L@SX
	shr  eax, 2
	add  edi, eax
	add  edi, screen.acceso

ifdef	INTERFLAG
	cmp  interflag, 1
	jne  short gor@initregs
endif
; ---- GOURAUD ZONE ON -------------
	mov  eax, esi
	sub  eax, ebp
	@cdq
	idiv ecx
	mov  L@DZ, eax
; ---- GOURAUD ZONE ON -------------
ifdef	INTERFLAG
	mov  interflag, 0
endif

gor@initregs:
	mov  ebx, ebp  		; BX  = High Col
	shr  ebx, 16
	xor  bh, bh

	mov  edx, L@DZ 		; DL  = High Inc
	shr  edx, 16

	mov  esi, L@DZ		; ESI = Low INC
	shl  esi, 16

	shl  ebp, 16           	; EBP = Low Col
; ----------------------------------

	jmp  short gor@innerl
	align 16
gor@innerl:
	mov  al, goutab[bx]
	mov  byte ptr [edi], al
	add  ebp, esi
	adc  bl, dl


	mov  al, goutab[bx]
	mov  byte ptr [edi+80], al
	add  ebp, esi
	adc  bl, dl

	add  edi, 160
	sub  cx, 2
	jg   short gor@innerl

	jl   short gor@finl

	mov  al, goutab[bx]
	mov  byte ptr [edi], al

gor@finl:
	pop ebp esi ecx ebx edx eax

gor@fincl:
	ret

gor@fintot:
	add esp, 4
	ret

  ENDP


;北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
;� PROCEDIMIENTO: � DRAWFLARE                                                �
;�----------------�----------------------------------------------------------�
;� FUNCION:       � Dibuja el flare en pantalla                              �
;北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
text_U = 127*UNO
text_V = 127*UNO

public size_X
public size_Y

size_X dd 185*UNO
size_Y dd 185*UNO
;哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
align 4
flared1	dot3d	?
flared2	dot3d	?
flarep1	dot2d	?
flarep2	dot2d	?
inc_u	dd	?
inc_v	dd	?
size_x	dd	?
size_y	dd	?
pos_u	dd	?
pos_v	dd	?
;哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
 align 16
 DRAWFLARE PROC

	mov  edi, light_table2
	mov  dword ptr df@i1+3, edi
	mov  dword ptr df@i2+3, edi
	mov  dword ptr df@i3+3, edi
;	mov  dword ptr dfv@i1+3, edi
;	mov  dword ptr dfv@i2+3, edi
;	mov  dword ptr dfv@i3+3, edi


	mov  esi, TheWorld
	add  esi, lightv

; Inicia los datos del punto 1
	mov  eax, [esi].x
	mov  ebx, [esi].y
	mov  edx, [esi].z
	sub  eax, size_X
	mov  flared1.x, eax
	sub  ebx, size_Y
	mov  flared1.y, ebx
	mov  flared1.z, edx

; Inicia los datos del punto 2
	mov  eax, [esi].x
	mov  ebx, [esi].y
	add  eax, size_X
	mov  flared2.x, eax
	add  ebx, size_Y
	mov  flared2.y, ebx

; Comprueba la Z
	mov  ebx, edx
	cmp  ebx, 65536*4
	jl   df@exit

	mov  edi, offset flared1
	mov  ebp, offset flarep1
	mov  cx, 2

; Proyecta la coordenada X
df@ploop:
	mov  eax, [edi].x        ; Punto_x = ((V.x * 256) / V.z) + x_centro
	mov  edx, eax
	sar  edx, 16
	shl  eax, 16
	idiv ebx
	shl  eax, 8
	add  eax, SXC
	xor  ax, ax
	mov  [ebp].x, eax

; Proyecta la coordenada Y
	mov  eax, [edi].y        ; Punto_y = ((V.y * 256) / V.z) + y_centro
	mov  edx, eax
	sar  edx, 16
	shl  eax, 16
	idiv ebx
	shl  eax, 8
	add  eax, SYC
	xor  ax, ax
	mov  [ebp].y, eax

	add  edi, size dot3d
	add  ebp, size dot2d
	dec  cx
	jnz  short df@ploop


; Halla los incrementos tanto de la X como de la Y
	mov  eax, text_U
	mov  ebx, flarep2.y
	sub  ebx, flarep1.y
	mov  size_y, ebx
	sar  ebx, 16
	@cdq
	idiv ebx
	mov  inc_u, eax

	mov  eax, text_V
	mov  ebx, flarep2.x
	sub  ebx, flarep1.x
	mov  size_x, ebx
	sar  ebx, 16
	@cdq
	idiv ebx
	mov  inc_v, eax


;哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪
;北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
; Inicia el volcado de pixels en leas VERTICALES
; EBX -> Posici X
; EAX -> Posici Y1 (y exclusiva)

	mov  ecx, size_x
	shr  ecx, 16			; ECX -> Tama...
	mov  ebx, flarep1.x
	shr  ebx, 16			; EBX -> Posici X
	mov  eax, flarep1.y
	shr  eax, 16			; EAX -> Posici Y
	mov  edx, flarep2.y
	shr  edx, 16			; EDX -> Posici Y2
	mov  pos_u, 0
	mov  pos_v, 0

;哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
df@loop1:
	test Rtype, RAW OR BLUR OR TRANS
	jz   short df@001
	jmp  DRAWLINEVIR

df@001:
	jmp  DRAWLINE
;哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

df@loop1b:
	mov  edi, inc_v
	add  pos_v, edi
	mov  pos_u, 0
	inc  ebx
	dec  cx
	jnz  short df@loop1

	jmp  df@exit

 ENDP

; 屯 Subprocedimiento -> Vuelca una lea de la textura en pantalla... 屯屯屯
;北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
DRAWLINE PROC
	cmp  bx, 0               ; ‥ntra en pantalla?
	jl   df@loop1b
	cmp  bx, screen.xmax
	jg   df@exit
	cmp  dx, 0
	jl   df@exit
	cmp  ax, screen.ymax
	jg   df@exit

	push eax ebx ecx edx

	cmp  ax, 0               ; Si hay que recortarla...
	jge  short df@t1
	cwde
	neg  eax
	mov  esi, inc_u
	imul eax, esi
	mov  pos_u, eax
	xor  eax, eax

df@t1:	cmp dx, screen.ymax
	jle short df@endt
	mov dx, screen.ymax

df@endt:
	mov L@SY, ax
	mov L@SX, bx

	mov  cx, dx		; Guardamos en CX el nero de repeticiones
	sub  cx, ax
        jz   dfl@exit

	mov  dx, SEQU_ADDR	; Seleccionamos en la VGA el Bit-plane
	mov  al, 2		; adecuado
	out  dx, al
	mov  al, byte ptr L@SX
	and  eax, 3
	inc  dx
	mov  al, bptable[eax]
	out  dx, al		; Lo escribimos en el Map-Register
   
	xor  edi, edi		; Direcci en memoria de veo
	mov  di, L@SY
	lea  edi, [edi+edi*4]	; EDI = EDI * (16*5) = EDI * 80
	shl  edi, 4
	xor  eax, eax
	mov  ax, L@SX
	shr  eax, 2
	add  edi, eax
	add  edi, screen.acceso

   	mov  ax, L@SX
	mov  dx, 3ceh
	and  al, 3
	mov  ah, 4
	xchg ah, al
	out  dx, ax

; Inicia los dos registros de incremento
; La v es CONSTANTE
; La u siempre empieza desde 0 (SALVO EN EL CASO DE RECORTE!!!!!)
	push cx
	mov  esi, Tflareptr

	xor  eax, eax

	xor  ebp, ebp
	mov  ecx, inc_u-2
	mov  dl, byte ptr inc_u+2
	mov  al, byte ptr pos_v+2	; Posici (ALTA)
	mov  ah, byte ptr pos_u+2
	mov  ebx, pos_u-2

	pop  cx


	jmp  short df@innerl
	align 16
df@innerl:
;哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	mov  bh, [esi+eax]
	mov  bl, [edi]
	mov  bp, bx
df@i1:	mov  dh, byte ptr df@innerl[ebp]
	mov  [edi], dh
	add  ebx, ecx
	adc  ah, dl

	mov  bh, [esi+eax]
	mov  bl, [edi+80]
	mov  bp, bx
df@i2:	mov  dh, byte ptr df@innerl[ebp]
	mov  [edi+80], dh
	add  ebx, ecx
	adc  ah, dl
;哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

	add  edi, 160
	sub  cx, 2
	jg   short df@innerl

	jl   short dfl@exit

;哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	mov  bh, [esi+eax]
	mov  bl, [edi]
	mov  bp, bx
df@i3:	mov  dh, byte ptr df@innerl[ebp]
	mov  [edi], dh
;哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

dfl@exit:
	pop edx ecx ebx eax
	jmp df@loop1b
; 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
df@exit:
	ret
ENDP

; 屯 Subprocedimiento -> Vuelca una lea de la textura en pantalla... 屯屯屯
;北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
DRAWLINEVIR PROC
	cmp  bx, 0               ; ‥ntra en pantalla?
	jl   df@loop1b
	cmp  bx, screen.xmax
	jg   df@exit
	cmp  dx, 0
	jl   df@exit
	cmp  ax, screen.ymax
	jg   df@exit


	push eax ebx ecx edx

	cmp  ax, 0               ; Si hay que recortarla...
	jge  short dfv@t1
	cwde
	neg  eax
	mov  esi, inc_u
	imul eax, esi
	mov  pos_u, eax
	xor  eax, eax

dfv@t1:	cmp dx, screen.ymax
	jle short dfv@endt
	mov dx, screen.ymax

dfv@endt:
	mov L@SY, ax
	mov L@SX, bx

	mov  cx, dx		; Guardamos en CX el nero de repeticiones
	sub  cx, ax
        jz   dfvir@exit

	xor  eax, eax
	mov  edi, eax		; Direcci en memoria de veo
	mov  di, L@SY
	lea  edi, [edi+edi*4]	; EDI = EDI * (16*5) = EDI * 80
	shl  edi, 4
	mov  ax, L@SX
	shr  eax, 2
	add  edi, eax

	mov  ax, L@SX
	and  eax, 3
	add  edi, bptot[eax*4]
	add  edi, screen.vscreen

; Inicia los dos registros de incremento
; La v es CONSTANTE
; La u siempre empieza desde 0 (SALVO EN EL CASO DE RECORTE!!!!!)
	push cx
	mov  esi, Tflareptr

	xor  eax, eax

	xor  ebp, ebp
	mov  ecx, inc_u-2
	mov  dl, byte ptr inc_u+2
	mov  al, byte ptr pos_v+2	; Posici (ALTA)
	mov  ah, byte ptr pos_u+2
	mov  ebx, pos_u-2

	pop  cx

	jmp  short dfv@innerl
	align 16
dfv@innerl:
;哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	mov  dh, [esi+eax]
	mov  [edi], dh
	add  ebx, ecx
	adc  ah, dl

	mov  dh, [esi+eax]
	mov  [edi+80], dh
	add  ebx, ecx
	adc  ah, dl
;哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

	add  edi, 160
	sub  cx, 2
	jg   short dfv@innerl

	jl   short dfvir@exit

;哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	mov  dh, [esi+eax]
	mov  [edi], dh
;哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�


dfvir@exit:
	pop edx ecx ebx eax
	jmp df@loop1b
; 哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
;dfvir@exit:
;	ret

 ENDP

public light_table
align 16
light_table label byte
include lt.inc

ends
end
