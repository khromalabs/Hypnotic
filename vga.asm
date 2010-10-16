;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;                       FUNCIONES PARA LA VGA MODO X
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;                      1995 Khroma (A.K.A. Rub‚n G¢mez)
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  D e f i n i c i o n e s
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  .386p
  jumps

  SEQU_ADDR    = 3C4h             ; Direcci¢n I/O del Sequence Controler
  DAC_READ     = 3C7h             ; Direcci¢n DAC-Read
  DAC_WRITE    = 3C8h             ; Direcci¢n DAC-Write
  DAC_DATA     = 3C9h             ; Registro de datos DAC
  CRTC_ADDR    = 3D4h             ; Direcci¢n I/O del CRT
  VERT_RETRACE = 3DAh             ; Direcci¢n Input Register #1
  GC_INDEX     = 3CEh		  ; Reg. Graphics Controler
  VIDEO_SEG    = 0A0000h          ; Memoria de v¡deo (linear)

  include pmode.inc
  include debug.inc
  include structs.inc

  public TESTVGA
  public SET320200
  public SET320240
  public SET320400
  public SETTEXT
  public SETPIXEL
  public CLS
  public CLSIMG
  public CLSBLUR
  public IMAGEN
  public GETPAL
  public SETPAL
  public FADEOUT
  public FADEIN
  public FADEOUTW
  public FADEINW
  public WAITRETRACE
  public WAITRETRACE2
  public SCREENON
  public SCREENOFF
  public REFRESH
  public screen
  public darkness
  
  extrn  timer:TimerINFO, image:byte, fadetab:dword


  
code32  segment para public use32
	assume cs:code32, ds:code32

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  D a t o s
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  align 4
  screen	ScreenINFO	?
  darkness	dd		?

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  C ¢ d i g o
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDIMIENTO: ³ TestVga                                                 ±
;±  FUNCION:       ³ Comprueba si hay una VGA instalada en el ordenador      ±
;±-----------------³---------------------------------------------------------±
;±  SALIDA:        ³ CF: 1 -> No hay tarjeta de video VGA                    ±
;±                 ³ CF: 0 -> S¡ la hay                                      ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 TESTVGA PROC
	mov v86r_ax, 1A00h      ; Esta funci¢n s¢lo existe en la BIOS VGA
	mov ax, 10h     
	int 33h
	cmp v86r_al, 1Ah
	clc
	je @tv@end              ; AL = 1Ah -> Hay una VGA
	stc                     ; No -> establecer CF en 1
@tv@end:ret
 ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ SET320200                                                ± 
;±----------------³----------------------------------------------------------±
;± MISION:        ³ Inicia el modo 320x200x256 colores pero con 4 p ginas    ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 SET320200 proc
	cld


	@rlp edi, VIDEO_SEG     ; Limpiamos la memoria RAM de v¡deo
	mov ecx, 4000h
	xor eax, eax    
	rep stosd
	
	mov v86r_ax, 0f00h      ; Averigua el actual modo de v¡deo
	mov ax, 10h
	int 33h
	mov al, v86r_al
	mov screen.oldvideo, al

	mov v86r_ax, 0013h     ; Iniciamos primero el modo normal
	mov ax, 10h            ; 320x200
	int 33h
	
	mov dx, SEQU_ADDR      ; Desconectamos la divisi¢n de direcciones
	mov ax, 0604h          ; de memoria
	out dx, ax
	
	mov dx, SEQU_ADDR      ; Permitimos el acceso a los 4 bit-planes
	mov ax, 0F02h          ; simult neamente para borrar de una vez
	out dx, ax             ; la memoria DRAM de la tarjeta
	
	@rlp edi, VIDEO_SEG    ; Limpiamos la memoria RAM de v¡deo
	mov ecx, 4000h         ; (otra vesss)
	xor eax, eax    
	rep stosd
	
	mov dx, CRTC_ADDR      ; Pasamos del modo de direccionamiento
	mov ax, 0E317h         ; Word al Byte
	out dx, ax
	
	mov dx, CRTC_ADDR      ; Pasamos del modo de direccionamiento
	mov ax, 0014h          ; Desactivamos el modo DoubleWord
	out dx, ax


	mov screen.xtot, 320   ; Inicio las variables
	mov screen.ytot, 200
	mov screen.xmax, 319
	mov screen.ymax, 199
	mov screen.xbpn, 80
	mov screen.pagina, 0
	mov screen.clscolval, 0

;       call IMAGEN
	ret
 
 SET320200 endp

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ SET320240                                                ±
;±----------------³----------------------------------------------------------±
;± MISION:        ³ Inicia el modo X 320x240x256 colores (3 p ginas)         ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 SET320240 proc
   call SET320200               ; Iniciamos primero el modo 320x200

   mov al, 0E3h                 ; Ahora modificamos los reg. necesarios
   mov dx, 3C2h
   out dx, al
   mov dx, 3D4h
   mov ax, 2C11h                ; Quitamos la protecci¢n contra escritura
   out dx, ax
   mov ax, 0D06h                ; Redefinimos la altura
   out dx, ax
   mov ax, 3E07h                ; Registro de desbordamiento
   out dx, ax
   mov ax, 0EA10h               ; Inicio del retrazado
   out dx, ax
   mov ax, 0AC11h               ; Final del retrazado y protecci¢n contra
   out dx, ax                   ; escritura
   mov ax, 0DF12h
   out dx, ax
   mov ax, 0E715h
   out dx, ax
   mov ax, 0616h
   out dx, ax
	
   mov screen.ytot, 240
   mov screen.ymax, 239
   mov screen.ytot, 240
   mov screen.ymax, 239

   call IMAGEN			; Pone a punto la imagen con la que se
				; trabajar , y nos piramos
   ret
 SET320240 endp

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ SET320400                                                ±
;±----------------³----------------------------------------------------------±
;± MISION:        ³ Inicia el modo X 320x400x256 colores (2 p ginas)         ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 SET320400 proc
   call SET320200               ; Iniciamos primero el modo 320x200

   mov dx, CRTC_ADDR            ; Desconectamos la duplicaci¢n de l¡neas
   mov al, 9
   out dx, al
   inc dx
   in  al, dx
   and al, 01110000b
   out dx, al
   
   mov screen.ytot, 400
   mov screen.ymax, 399
	
   call IMAGEN            ; Ponemos a punto la imagen con la que se
			  ; trabajar , y nos piramos
   ret
 SET320400 endp


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDIMIENTO: ³ imagen                                                  ±
;±-----------------³---------------------------------------------------------±
;±  FUNCION:       ³ Muestra la imagen oculta y conmuta la activa            ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 IMAGEN proc
   
   xor eax, eax
   mov al, screen.pagina      ; Ense¤amos la p gina oculta
   call showpage
   xor al, 1                  ; Conmutamos el valor

   mov screen.pagina, al      ; Y por £ltimo lo establecemos como p gina
   call setpage               ; de trabajo
 
   mov timer.wrt, 1	      ; Activa el flag de espera a el retrazado
			      ; (Mientras que el monitor no refresque la 
   ret			      ;  nueva imagen, no se puede escribir en la
 IMAGEN endp		      ;	 VGA, o se ver n parpadeos).


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDIMIENTO: ³ settext                                                 ±
;±-----------------³---------------------------------------------------------±
;±  FUNCION:       ³ Inicia el modo de texto                                 ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 SETTEXT proc
   xor ah, ah
   mov al, screen.oldvideo
   mov v86r_ax, ax
   mov ax, 10h
   int 33h

   ret
 SETTEXT endp


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ Refresh                                                  ±
;±----------------³----------------------------------------------------------±
;± MISION:        ³ Refresca la memoria de v¡deo con la p gina virtual       ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 align 16
 REFRESH PROC
	push  esi edi

	mov   dx, SEQU_ADDR
	mov   ax, 0102h
	mov   esi, screen.vscreen

r@loopbp:
	out   dx, ax
	mov   edi, screen.acceso
	mov   ecx, 19200/(4*32)               ;   !!!!!!!

	push  ecx ax

; --- Unrolled loop -------------------------
	I = 0
	align 16
r@inner:
	REPT  32
	mov   eax, [esi+I]
	mov   [edi+I], eax
	I = I + 4
	ENDM
	add   esi, 32*4
	add   edi, 32*4

	dec   cx
	jnz   r@inner
; --- Unrolled loop -------------------------

	pop   ax ecx

	shl   ah, 1
	cmp   ah, 16
	jne   r@loopbp

	pop   edi esi 
	ret
		
 ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ cls                                                      ±
;±----------------³----------------------------------------------------------±
;± MISION:        ³ Borra la p gina seleccionada                             ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 CLS proc
   push  edi
	 
   mov   dx, SEQU_ADDR            ; Permitimos el acceso a los 4 bit-planes
   mov   ax, 0F02h                ; simult neamente para borrar de una vez
   out   dx, ax                   ; la pantalla

   mov   ax, screen.xbpn          ; El tama¤o de la pantalla en memoria es
   mul   screen.ytot              ; ancho_bit_plane * altura
   shr   ax, 2                    ; Dividimos entre cuatro el contador(es DWORD)
   movzx ecx, ax                  ; REP DECREMENTA Y COMPARA ECX, NO CX!!!
   mov   edi, screen.acceso       ; Situamos EDI en memoria de v¡deo
   mov   al, screen.clscolval
   mov   ah, al
   mov   bx, ax
   shl   eax, 16
   mov   ax, bx

; ---- Loop desenrollado -------------------------------------------------
  I = 0
  shr    ecx, 5

cls@loop:
   REPT 32
     mov  [edi+I], eax
     I = I + 4
   ENDM
   add  edi, 32*4
   dec  cx
   jnz  short cls@loop
; ---- Loop desenrollado -------------------------------------------------

   pop   edi
   ret                            ; De vuelta a casa
 ENDP


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ clsblur                                                  ±
;±----------------³----------------------------------------------------------±
;± PARAMETROS:    ³ BX: N£mero de retrazados producidos...                   ±
;±----------------³----------------------------------------------------------±
;± MISION:        ³ Borra la p gina seleccionada con efecto blur             ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 align 16
 CLSBLUR proc
	pushad

; Computes darkness factor by raster-count and store it in ebp...
	xor   ebp, ebp
	mov   bp, bx
	imul  ebp, darkness

;ÄÄÄÄ Initializes fade table (0-31) ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	mov   cx, 32
	mov   edi, fadetab
	xor   eax, eax

cb@ift:	mov   ebx, eax
	sub   ebx, ebp
	jg    short cb@colorok
	xor   ebx, ebx
cb@colorok:
	shr   ebx, 16
	mov   [edi], bl

	add   eax, UNO
	inc   edi
	dec   cx
	jnz   short cb@ift

;ÄÄÄÄ Initializes fade table (32-64) ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	mov   cx, 32
	mov   eax, 32*UNO

cb@ift2:mov   ebx, eax
	sub   ebx, ebp
	cmp   ebx, 32*UNO
	jg    short cb@colorok2
	mov   ebx, 32*UNO
cb@colorok2:
	shr   ebx, 16
	mov   [edi], bl

	add   eax, UNO
	inc   edi
	dec   cx
	jnz   short cb@ift2


;ÄÄÄÄ Decrement loop ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	mov   ebp, fadetab
	mov   esi, screen.vscreen
	mov   cx, 2400
	xor   ebx, ebx
	xor   edx, edx
	I = 0

; Main loop (Repeted) ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
align 16
cb@loop:
	REPT  16
	mov   bl, [esi+I]
	mov   dl, [esi+I+1]
	mov   al, [ebp+ebx]
	mov   ah, [ebp+edx]
	mov   [esi+I], al
	mov   [esi+I+1], ah
	I = I + 2
	ENDM

	add   esi, 16*2
	dec   cx
	jnz   cb@loop

; Exit
cb@end:	popad
	ret
 ENDP


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ clsimg                                                   ±
;±----------------³----------------------------------------------------------±
;± FUNCION:       ³ Borra la p gina seleccionada con la imagen en la 3¦ p g. ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 align 4
 offset_im      dd	?
 length_im	dd	?
 init_im	dd	?

 align 16
 CLSIMG PROC
 	push  edi
	
; Is this page initialized?
	xor   eax, eax
	mov   al, screen.pagina
	push  eax
	
	cmp   screen.bgok[eax], 0
	jne   short ci@testxy

	mov   screen.bgok[eax], 1
	xor   bx, bx
	mov   ax, screen.ytot
	jmp   short ci@noch
	
; Yes, test values to make sure that are on screen
ci@testxy:
	mov   bx, word ptr screen.miny[eax*4]+2
	cmp   bx, 0
	jge   short ci@nc1
	xor   bx, bx

ci@nc1:	mov   ax, word ptr screen.maxy[eax*4]+2
	inc   ax
	cmp   ax, screen.ytot
	jle   short ci@noch
	mov   ax, screen.ytot

; Copy buffer to page [0/1]
ci@noch:sub   ax, bx
	mul   screen.xbpn
	shr   ax, 4
	mov   cx, ax

	mov   ax, bx
	imul  ax, screen.xbpn
	cwde
	mov   init_im, eax

	movzx eax, screen.xbpn
	movzx ebx, screen.ytot
	imul  eax, ebx
	mov   length_im, eax

	mov   esi, screen.bgptr
	add   esi, init_im
	mov   eax, length_im
	mov   offset_im, eax
	
	mov   dx, SEQU_ADDR
	mov   ax, 0102h

ci@loopbp:
	out   dx, ax
	mov   edi, screen.acceso
	add   edi, init_im

	push  cx ax

ci@inner:
	mov  eax,  [esi]
	mov   [edi], eax
	mov  eax,  [esi+4]
	mov  [edi+4], eax
	mov  eax,  [esi+8]
	mov  [edi+8], eax
	mov  eax,  [esi+12]
	mov  [edi+12], eax

	add   esi, 16
	add   edi, 16
	dec   cx
	jnz   short ci@inner

	pop   ax cx

	mov   esi, screen.bgptr
	add   esi, offset_im
	add   esi, init_im

	mov   ebx, length_im
	add   offset_im, ebx

	shl   ah, 1
	cmp   ah, 16
	jne   short ci@loopbp

; Actualize CLS info
	pop   ebx
	mov   eax, screen.cls
	mov   screen.miny[ebx*4], eax
	mov   eax, screen.cls+4
	mov   screen.maxy[ebx*4], eax

	pop   edi
	ret
 ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ setpixel                                                 ±
;±----------------³----------------------------------------------------------±
;± MISION:        ³ Enciende un pixel en pantalla (AVISO! Leeento)           ±
;±----------------³----------------------------------------------------------±
;± PARAMETROS:    ³ STACK 0: Posici¢n X                                      ±
;± (PILA)         ³ STACK 1: Posici¢n Y                                      ±
;±                ³ EBP:     COLOR                                           ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 align 16
 SETPIXEL proc
  
  PCT   = 4
  XP    = [esp+PCT+04h]
  YP    = [esp+PCT+00h]

	xor  edi, edi
	mov  dx, SEQU_ADDR      ; Indicamos al Sequence Controler que vamos
	mov  al, 2              ; a escribir en ‚l
	out  dx, al

	inc  dx                 ; Ahora indicamos en el reg. de datos el
	mov  al, 1              ; Bit-plane en el que vamos a escribir
	mov  cx, XP
	mov  di, cx             ; Nos llevamos el valor para futuros usos
	and  cl, 3
	shl  al, cl
	out  dx, al

	mov  ax, screen.xbpn   ; Calculamos el offset en memoria de v¡deo,
	mul  word ptr YP       ; de manera que:
	shr  di, 2             ;   offset = (Y * (ANCHURA_BPLN)) + (X / 4)
	add  di, ax
	add  edi, screen.acceso
	mov  ax, bp
	mov  [edi], al 

	ret  8
 SETPIXEL endp

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDIMIENTO: ³ GETPAL                                                  ±
;±  FUNCION:       ³ Lee los registros indicados de la paleta a un buffer    ±
;±----------------Ä³---------------------------------------------------------±
;±  PARAMETROS:    ³ EDI = Buffer: Buffer donde se guardar n los colores     ±
;±                 ³ AL  = Inicio: Valor inicial en la paleta de los reg.    ±
;±                 ³ CX  = Total:  N£mero de colores                         ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 GETPAL proc
comment ‡
	push edi edx ecx
	mov  dx, DAC_READ
	call WAITRETRACE2
	out  dx, al
	mov  dx, DAC_DATA

@gp@01: in   al, dx
	mov  [edi], al
	in   al, dx
	mov  [edi+1], al
	in   al, dx
	mov  [edi+2], al
	add  edi, 3
	dec  cx
	jnz  short @gp@01

	pop  ecx edx edi
‡
	ret

 ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDIMIENTO: ³ SETPAL                                                  ±
;±  FUNCION:       ³ Escribe los registros indicados de un buffer a la paleta±
;±-----------------³---------------------------------------------------------±
;±  PARAMETROS:    ³ CX: N£mero de registros a cargar                        ±
;±                 ³ AL: Valor inicial en la paleta de los registros         ±
;±                 ³ EDI: Buffer donde est‚n los colores                     ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 SETPAL PROC
	pushad

	cmp  cx, 256
	jbe  short sp@cont
	mov  cx, 256

; Multiplica por 3 el valor inicial
sp@cont:push eax
	movzx eax, al
	lea  eax, [eax*2+eax]
	add  edi, eax
	pop  eax

	mov  timer.wfwpal, 1
	mov  timer.wpncol, cx
	mov  timer.wpnini, ax
	mov  timer.wpadd, edi

	
comment ‡
	mov  dx, DAC_WRITE
	call WAITRETRACE2
	out  dx, al
	mov  dx, DAC_DATA

@sp@01: mov  al, [edi]
	out  dx, al
	mov  al, [edi+1]
	out  dx, al
	mov  al, [edi+2]
	out  dx, al
	add  edi, 3
	dec  cx
	jnz  short @sp@01
‡	

	popad
	ret
  ENDP


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDIMIENTO: ³ FadeOut                                                 ±
;±  FUNCION:       ³ Realiza un fundido hasta el negro                       ±
;±----------------Ä³---------------------------------------------------------±
;±  PARAMETROS:    ³  EDI: Direcci¢n del buffer donde est  la paleta         ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 FADEOUT PROC
	push edi
	
	mov ebx, edi
	xor  cx, cx
	xor  ax, ax
@fo@np: mov  dx, DAC_WRITE
	xor  al, al
	out  dx, al
	call WAITRETRACE2
	mov  dx, DAC_DATA
	mov  edi, ebx
@fo@nd: mov  al, [edi]
	sub  al, ch
	jge  @fo@0R
	mov  al, ah
@fo@0R: out  dx, al
	mov  al, [edi+1]
	sub  al, ch
	jge  @fo@0G
	mov  al, ah
@fo@0G: out  dx, al
	mov  al, [edi+2]
	sub  al, ch
	jge  @fo@0B
	mov  al, ah
@fo@0B: out  dx, al
	add  edi, 3
	inc  cl
	jnz  @fo@nd
	inc  ch
	cmp  ch, 00111111b
	jl   @fo@np
	
	pop edi
	ret
  ENDP


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDIMIENTO: ³ _FadeIn                                                 ±
;±  FUNCION:       ³ Realiza un fundido del negro hasta los colores indicados±
;±----------------Ä³---------------------------------------------------------±
;±  PARAMETROS:    ³  EDI: Buffer en donde est‚n los colores                 ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 FADEIN PROC
	push edi
	mov ebx, edi
	
	mov  ch, 00111111b
	mov  cl, 0
@fi@np: mov  dx, DAC_WRITE
	xor  al, al
	out  dx, al
	call WAITRETRACE2
	mov  dx, DAC_DATA
	mov  edi, ebx
@fi@nd: mov  al, [edi]
	sub  al, ch
	jge  @fi@0R
	mov  al, 0
@fi@0R: out  dx, al
	mov  al, [edi+1]
	sub  al, ch
	jge  @fi@0G
	mov  al, 0
@fi@0G: out  dx, al
	mov  al, [edi+2]
	sub  al, ch
	jge  @fi@0B
	mov  al, 0
@fi@0B: out  dx, al
	add  edi, 3
	inc  cl
	jnz  @fi@nd
	cmp  ch, 00000000b
	jz   @fi@ed
	dec  ch
	jmp  @fi@np
	
@fi@ed: pop edi
	ret
  ENDP




;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDIMIENTO: ³ FadeOutw                                                ±
;±  FUNCION:       ³ Realiza un fundido hasta el blanco                      ±
;±----------------Ä³---------------------------------------------------------±
;±  PARAMETROS:    ³  EDI: Direcci¢n del buffer donde est  la paleta         ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 FADEOUTW PROC
	push edi
	
	mov ebx, edi
	xor  cx, cx
@fw@np: mov  dx, DAC_WRITE
	xor  al, al
	out  dx, al
	call WAITRETRACE2
	mov  dx, DAC_DATA
	mov  edi, ebx
@fw@nd: mov  al, [edi]
	add  al, ch
	cmp  al, 63
	jle  short @fw@0R
	mov  al, 63
@fw@0R: out  dx, al
	mov  al, [edi+1]
	add  al, ch
	cmp  al, 63
	jle  short @fw@0G
	mov  al, 63
@fw@0G: out  dx, al
	mov  al, [edi+2]
	add  al, ch
	cmp  al, 63
	jle  short @fw@0B
	mov  al, 63
@fw@0B: out  dx, al
	add  edi, 3
	inc  cl
	jnz  short @fw@nd
	inc  ch
	cmp  ch, 00111111b
	jl   short @fw@np
	
	pop edi
	ret
  ENDP


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDIMIENTO: ³ FadeInw                                                 ±
;±  FUNCION:       ³ Realiza un fundido hasta el blanco                      ±
;±----------------Ä³---------------------------------------------------------±
;±  PARAMETROS:    ³  EDI: Direcci¢n del buffer donde est  la paleta         ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 FADEINW PROC
	push edi
	mov ebx, edi
	
	mov  ch, 00111111b
	mov  cl, 0
@fiw@np:mov  dx, DAC_WRITE
	xor  al, al
	out  dx, al
	call WAITRETRACE2
	mov  dx, DAC_DATA
	mov  edi, ebx
@fiw@nd:mov  al, [edi]
	add  al, ch
	cmp  al, 63
	jle  short @fiw@0R
	mov  al, 63
@fiw@0R:out  dx, al
	mov  al, [edi+1]
	add  al, ch
	cmp  al, 63
	jle  short @fiw@0G
	mov  al, 63
@fiw@0G:out  dx, al
	mov  al, [edi+2]
	add  al, ch
	cmp  al, 63
	jle  short @fiw@0B
	mov  al, 63
@fiw@0B:out  dx, al
	add  edi, 3
	inc  cl
	jnz  @fiw@nd
	cmp  ch, 00000000b
	jz   @fiw@ed
	dec  ch
	jmp  @fiw@np
	
@fiw@ed: pop edi
	ret
  ENDP


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDIMIENTO: ³ SCREENOFF                                               ±
;±  FUNCION:       ³ Apaga la pantalla                                       ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 SCREENOFF PROC
   mov dx, 3c4h
   mov al, 1
   out dx, al
   inc dx
   in al, dx
   or al, 00100000b
   out dx, al
   ret
 ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDIMIENTO: ³ SCREENON                                                ±
;±  FUNCION:       ³ La vuelve a encender                                    ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 SCREENON PROC
  mov dx, 3c4h
  mov al, 1
  out dx, al
  inc dx
  in al, dx
  and al, 11011111b
  out dx, al
  ret
 ENDP

;ÍÍÍ Funciones de uso interno ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDIMIENTO: ³ WAITRETRACE                                             ±
;±-----------------³---------------------------------------------------------±
;±  FUNCION:       ³ Espera a que la pantalla est‚ terminada                 ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 align 16
 WAITRETRACE proc
	push ax dx

	cli
	mov  dx, VERT_RETRACE
@wre1: 	in  al, dx
	test al, 00001000b
	jnz  short @wre1
 @wre2: in  al, dx
	test al, 00001000b
	jz   short  @wre2
	sti


	pop dx ax
	ret

 WAITRETRACE endp

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDIMIENTO: ³ WAITRETRACE2                                            ±
;±-----------------³---------------------------------------------------------±
;±  FUNCION:       ³ Espera a que la pantalla est‚ terminada                 ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 align 16
 WAITRETRACE2 proc
	push ax dx

	mov   timer.wrt, 1
wr2@loop:
	cmp   timer.wrt, 1
	je    short wr2@loop

	pop  dx ax

	ret

 WAITRETRACE2 endp

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ SetPage                                                  ±
;±----------------³----------------------------------------------------------±
;± MISION:        ³ Seleciona la p gina en la que se escribir                ±
;±----------------³----------------------------------------------------------±
;± PARAMETROS:    ³ AX = N§ de p gina a seleccionar                          ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 setpage proc
   
   mul  screen.xbpn                 ; Multiplicamos ax por la anchura / 4
   mul  screen.ytot                 ; Multiplicamos por la altura total
   @rlp ebx, VIDEO_SEG
   add  eax, ebx
   mov  screen.acceso, eax          ; Guardamos la direcci¢n en inicio
   
   ret                              ; Volvemos al invocador

 setpage endp

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ ShowPage                                                 ±
;±----------------³----------------------------------------------------------±
;± MISION:        ³ Selecciona la p gina visible en pantalla                 ±
;±----------------³----------------------------------------------------------±
;± PARAMETROS:    ³ AX: N§ de p gina a visualizar                            ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 showpage proc
   push eax

   mul screen.xbpn              ; Multiplicamos ax por la anchura / 4
   mul screen.ytot              ; Multiplicamos por la altura total
   mov bx, ax                   ; Guardamos en BX para usarlo ahora

   mov dx, CRTC_ADDR            ; Avisamos al CRT que vamos a mandar un
   mov al, 0Ch                  ; dato al registro que indica que offset
   out dx, al                   ; de la memoria se toma como inicio
   mov al, bh
   inc dx                       ; Y ahora enviamos al contolador CRT el
   out dx, al                   ; byte alto del desplazamiento

   dec dx                       ; Ahora lo mismo, pero mandando el
   mov al, 0Dh                  ; byte bajo al siguiente puerto
   out dx, al
   inc dx
   mov al, bl                   ; Cogemos el byte bajo
   out dx, al

   pop eax
   ret
 showpage endp

 ends
end

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ clsimg                                                   ±
;±----------------³----------------------------------------------------------±
;± MISION:        ³ Borra la p gina seleccionada con la imagen en la 3¦ p g. ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 align 16
 CLSIMG PROC
 	push  edi
	
; Is this page initialized?
	xor   eax, eax
	mov   al, screen.pagina
	xor   al, 1
	cmp   screen.bgok[eax], 0
	jne   short ci@testxy

	mov   screen.bgok[eax], 1
	xor   bx, bx
	mov   ax, screen.ytot
	jmp   short ci@noch
	
; Yes, test values to make sure that are on screen
ci@testxy:
	mov   bx, word ptr screen.miny[eax*4]+2
	cmp   bx, 0
	jge   short ci@nc1
	xor   bx, bx

ci@nc1:	mov   ax, word ptr screen.maxy[eax*4]+2
	inc   ax
	cmp   ax, screen.ytot
	jle   short ci@noch
	mov   ax, screen.ytot

; Copy 2nd page to page 0 or 1
ci@noch:sub   ax, bx
	imul  ax, screen.xbpn
	movzx ecx, ax

	mov   ax, bx
	imul  ax, screen.xbpn
	cwde

	mov   edi, screen.acceso
	add   edi, eax

	add   eax, VIDEO_SEG+38400
	@rlp  esi, eax

	mov   dx, GC_INDEX
	mov   al, 5
	out   dx, al
	inc   dx
	in    al, dx
	push  ax
	and   al, 11111100b
	or    al, 1
	out   dx, al

	mov   dx, SEQU_ADDR
	mov   ax, 0F02h
	out   dx, ax

	cld
	rep   movsb
	pop   ax

	mov   dx, GC_INDEX
	mov   ah, al
	mov   al, 5
	out   dx, ax

	pop   edi
	ret                            ; De vuelta a casa
 ENDP
