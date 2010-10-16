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
    include pmode.inc
    include structs.inc
    include file.inc
    include debug.inc
    
    public RENDER
    public LOADOBJECT
    public LOADPICTURE
    public INITPATH
    public TRACEPATH
    public SETBACKGND
    public INITMAP
    public INITTEXT
    public INITMORPH
    public TRACEMORPH
    public SETRFLAG
    public WAITTIME
    public TESTCOPRO
    public NEWLIGHTTABLE
    public FADETRACE
    public FADEINIT
    public LOOKAT
    public LOOKAT_X
    public LOOKAT_Y
    public PUTPIXTRANS
    public TheWorld
    public stackbase
    public sqtable
    public handle
    public light_table2
    public fadetab
    public Rtype
    public initbuf
    public tm@dirflag
    public coltab
    public inccoltab


    extrn ROTAR:near, SETMAT:near, ON_SCREEN:near, ADJUST_FACE:near
    extrn PROYECTAR:near, WAITRETRACE:near, CLS:near, CLSBLUR:near
    extrn RADIXSORT:near, CLOCK_OK:near, SITUAR:near, GETSHADECOL:near
    extrn BFC:near, GETNORMAL:near, ADJUST_FACE:near, CLSIMG:near
    extrn GENSIN:near, NORMALIZE:near, ROTARNORMAL:near, AVERAGEDOT:near
    extrn DTV_GT:near, DTV_MAP:near, DTV_BLUR:near, REFRESH:near, TESTROT:near
    extrn GETTEXTCOORDS:near, MAKESTARS:near, ROTAR2:near, DRAWFLARE:near
    extrn ROTAR3:near, FIREBALL:near, DTV_RAW:near, SITUAR2:near, DTV_GOR:near

    extrn Teyepixptr:dword, EYE_path:dword ; Variable puntero al dibujo del ojo...
    extrn WAITRETRACE2:near

    extrn sintab:dword, timer:TimerINFO, screen:ScreenINFO

    extrn goutab:byte


  DAC_WRITE    = 3C8h             ; Direcci¢n DAC-Write
  DAC_DATA     = 3C9h             ; Registro de datos DAC

 @abs MACRO reg
 	cmp &reg, 0
 	jge short $+4
 	neg &reg
 ENDM

code32  segment para public use32
	assume cs:code32, ds:code32

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  D a t o s
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   align 4
   TheWorld	dd	?               ; Lista de punteros a los objetos
   trvec	dd	?               ; Array poly. transformados
   zbuffer	dd	?               ; Array coors. Z de los polygonos
   stackbase	dd	?               ; Structura de pilas para el sort
   sqtable	dd	?		; Tabla de cuadrados
   light_table2	dd	?		; Tabla de luces para el flare
   inccoltab	dd	?
   coltab	dd	?
   fadetab	dd	?
   Rtype	dw	?		; Tipo de render

   header	db	8 dup(?)	; Cabecera del fichero SHP
   initbuf	db	0               ; Flag de inicio de los arrays
   camflag	db	?		; Flag de la c mara
   flareflag	db	?		; Flag del flare (si lo hay)
   sort		db	?		; Flag que indica si hay que ordenar
   r@time       dw	?

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  C ¢ d i g o
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ RENDER                                                   ±
;±----------------³----------------------------------------------------------±
;± FUNCION:       ³ Mmmm, I don't really know... :-)                         ±
;±----------------³----------------------------------------------------------±
;± PARAMETROS:    ³  AX: Render type                                         ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 align 4
 camera_var	dd      ?
 nface		dw      ?
 eye		db	?
;----------------------------------------------------------------------------
 align 16
 RENDER PROC

	pushad

	mov  r@time, bx

	mov  eye, 0
	test ax, EYE
	je   short r@initcam
	mov  eye, 1

; Ä Inicia la c mara la luz y el tipo de render GRAFICO ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
r@initcam:
	mov  Rtype, ax
	and  Rtype, 1111111b
	mov  esi, TheWorld
	lea  esi, [esi].camera
	mov  camera_var, esi

; Inicia el n£mero de objetos
	mov  edi, trvec
	mov  [edi].numpols, 0


; Comprueba la bandera de sort
r@testsortflag:

	test ax, NOSORT
	jz   short r@sort
	mov  sort, 0
	jmp  short r@testflareflag

r@sort:
	mov  sort, 1

r@testflareflag:
; Comprueba si hay un flare
	test ax, FLARE
	jz   short r@noflare
	mov  flareflag, 1
	jmp  short r@testrotcam

r@noflare:
	mov  flareflag, 0

; Comprueba si hay o no rotaci¢n de c mara
r@testrotcam:
	test ax, CAMROT
	jz   short r@nocam
	mov  camflag, 1

	push eax esi
	lea  ebx, [esi].mg
	lea  edi, [esi].vd
	call SETMAT
	pop  esi eax

	jmp  short r@getlight

r@nocam:mov  camflag, 0
; Obtiene el vector de luz final
r@getlight:
; Comprueba si hay un flare o gouraud, caso en el cual inicia la luz
	cmp  flareflag, 1
	je   r@getlightok
	test Rtype, GOURAUD
	jz   r@loadobjs


r@getlightok:
	mov  edi, TheWorld
	lea  ebp, [edi].lightn
	lea  ebx, [edi].lightv
	lea  edi, [edi].light

; Inicializa la posici¢n de la luz... (Pal flare) :)
	mov  esi, camera_var

	mov  eax, [edi].pos.x
	mov  [ebp].x, eax
	sub  eax, [esi].pos.x
	mov  [ebx].x, eax

	mov  eax, [edi].pos.y
	mov  [ebp].y, eax
	sub  eax, [esi].pos.y
	mov  [ebx].y, eax

	mov  eax, [edi].pos.z
	mov  [ebp].z, eax
	sub  eax, [esi].pos.z
	mov  [ebx].z, eax

; Rota la luz si hay rotaci¢n de c mara
r@tflare:
	test flareflag, 1
	jz   short r@loadobjs
	test camflag, 1
	jz   short r@includeflare
 

	pushad
	mov  esi, camera_var
	lea  esi, [esi].mg
	mov  edi, ebx			; EBP -> Ptr al vector de luz
	mov  cx, 1
	call ROTAR2
	popad


; Si hay un flare lo incluye en la lista de zbuffer (sort)
r@includeflare:
	pushad
	mov  esi, TheWorld
	mov  edi, trvec
	inc  [edi].numpols
	lea  eax, [esi].flare
	mov  [edi].poly[0], eax
	mov  [eax].pflag, FLARE

	mov  edx, zbuffer
	mov  ebx, [ebx].z		; Se prepara el valor Z por si hay
	shr  ebx, 16			; un flare
	mov  ax, bx
	add  bx, bx
	add  bx, ax
	mov  [edx+2], bx		; Z Value
	xor  bx, bx
	mov  [edx], bx			; Index
	popad

; Ä Inicio de la extracci¢n de los objetos ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
r@loadobjs:
	mov  esi, TheWorld
	xor  ecx, ecx
	mov  ebp, [esi].numobjs

; Extrae los pol¡gonos
r@el:	mov  ebx, [esi].obj[ecx*4]
	cmp  [ebx].rflag, 0
	je   short r@nextobj
	call TAKECOORDS

r@nextobj:
	inc  ecx
	cmp  ecx, ebp
	jb   short r@el

; Los ordena
	cmp  sort, 0
	je   short r@twaitret
	mov  esi, trvec
	mov  edi, zbuffer
	call RADIXSORT
 
; Waits the retrace
r@twaitret:
	test Rtype, TRANS OR BLUR OR RAW
	jnz  r@clscode

r@wr:	cmp  timer.wrt, 1
	je   short r@wr

r@clscode:
; ÄÄÄ Clear screen code ÄÄÄÄÄÄÄÄÄ
	cmp  screen.backgnd, 1
	jne  r@tcls

	test Rtype, TRANS
	jz   r@clsim2

	mov  edi, screen.vscreen
	mov  esi, screen.bgptr
	mov  ecx, (4800*4) / 32

;----- Unrolled loop -------------------------
	I = 0
	align 16
r@clsimg:
	REPT 32
	mov  eax, [esi+I]
	mov  [edi+I], eax
	I = I + 4
	ENDM	
	add  esi, 32*4
	add  edi, 32*4
	dec  cx
	jnz  r@clsimg
;----- Unrolled loop -------------------------

	jmp  r@startdraw


r@clsim2:
	call CLSIMG
	jmp  r@startdraw
;ÄÄÄÄÄÄÄÄÄ End of image-clsing code ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ


r@tcls:	cmp  screen.backgnd, 0
	jne  r@t3cls
	test  Rtype, BLUR 
	jz   short r@clsRAW
	mov  bx, r@time
	call CLSBLUR
	jmp  r@startdraw

r@clsRAW:
	test Rtype, RAW
	jz   r@t2cls

;----- Unrolled loop -------------------------
	I = 0
	mov  edi, screen.vscreen
	mov  ecx, (4800*4) / 32
	xor  eax, eax

	I = 0
	align 16
r@clsRAWloop:
	REPT 32
	mov  [edi+I], eax
	I = I + 4
	ENDM	
	add  edi, 32*4
	dec  cx
	jnz  r@clsRAWloop
;----- Unrolled loop -------------------------

	call FIREBALL
	jmp  r@startdraw

r@t2cls:call CLS
	jmp  short r@startdraw

r@t3cls:cmp  screen.backgnd, 3
	jne  short r@startdraw
	mov  screen.clscolval, 7*32
 	call CLS
	mov  al, 0
	call MAKESTARS
	jmp  short r@startdraw  


;Ä Loop que dibuja los tri ngulos ÄÄÄÄÄÄÄÄÄÄÄÄ
r@startdraw:

	mov   nface, 0FFFFh

r@pl:	inc   nface
	mov   edi, trvec
	mov   edx, zbuffer
	xor   ebx, ebx
	mov   ebp, ebx

	mov   bx, nface
	cmp   bx, [edi]
	jge   short exit
	mov   bp, [edx][ebx*4]
	mov   ebx, [edi].poly.[ebp*4]

	cmp   [ebx].pflag, FLARE
	jne   short r@testgouraud
	call  DRAWFLARE
	jmp   short r@pl

;ÄÄÄÄChapuza para que la t¡a tenga GouraudÄÄÄÄÄÄÄÄÄÄ
r@testgouraud:
	cmp   [ebx].pflag, GOURAUD
	jne   short r@mappolygon
	test  Rtype, RAW
	jnz   short  r@t2
	call  DTV_GOR
	jmp   short r@pl
;ÄÄÄÄChapuza para que la t¡a tenga GouraudÄÄÄÄÄÄÄÄÄÄ

r@mappolygon:
	mov   ax, Rtype
	cmp   al, GOURAUD OR TEXTMAP
	jne   short r@t1
	call  DTV_GT
	jmp   short r@pl
	      
r@t1:	test  al, BLUR OR TRANS
	jz    short r@t2
	call  DTV_BLUR
	jmp   short r@pl

r@t2:	call  DTV_RAW
	jmp   short r@pl
;---------------------------------------------


exit:  	test  Rtype, BLUR OR TRANS OR RAW
	jz    r@nobuf

; Si el render es RAW, metemos las estrellitas...
	test  Rtype, RAW
	jz    short r@wr2
	mov  al, 1
	call MAKESTARS

r@wr2:
	test  eye, 1
	jz    short r@wr3

; ÄÄ Chapuza efecto de £ltima hora... ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Aqu¡ hay que salvar el contenido del recuadro del ojo...
	xor   ebx, ebx
	mov   esi, screen.vscreen
	mov   edi, zbuffer
	mov   cl, 5
	mov   ch, 80
	mov   dl, 4

re@loop0:
	push  esi
	add   esi, ((320*70)+100)/4
re@loop1:
	mov   eax, [esi]
	mov   [edi], eax

	add   edi, 4
	add   esi, 4
	dec   cl
	jnz   short re@loop1

	add   esi, (240)/4
	mov   cl, 5
	dec   ch
	jnz   short re@loop1

	mov   ch, 80
        pop   esi
	add   esi, 19200
	dec   dl
	jnz   short re@loop0
; ÄÄ Chapuza efecto de £ltima hora... ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	mov   esi, EYE_path
	mov   edi, Teyepixptr
	mov   ecx, 80*80
	call  PUTPIXTRANS

r@wr3:
	cmp   timer.wrt, 1
	je    short r@wr3
	call  REFRESH

	test  Rtype, EYE
	jz    short r@nobuf

; Aqu¡ hay que restaurarlo...!!!!!	
; ÄÄ Chapuza efecto de £ltima hora... v2.0 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Aqu¡ hay que salvar el contenido del recuadro del ojo...
	xor   ebx, ebx
	mov   esi, screen.vscreen
	mov   edi, zbuffer
	mov   cl, 5
	mov   ch, 80
	mov   dl, 4

re@loop3:
	push  esi
	add   esi, ((320*70)+100)/4
re@loop4:
	mov   eax, [edi]
	mov   [esi], eax

	add   edi, 4
	add   esi, 4
	dec   cl
	jnz   short re@loop4

	add   esi, (240)/4
	mov   cl, 5
	dec   ch
	jnz   short re@loop3

	mov   ch, 80
        pop   esi
	add   esi, 19200
	dec   dl
	jnz   short re@loop3
; ÄÄ Chapuza efecto de £ltima hora... ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

r@nobuf:inc   screen.fctr
	popad
	ret

   ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ TAKECOORDS                                               ±
;±----------------³----------------------------------------------------------±
;± FUNCION:       ³ Extract the object coordinates                           ±
;±----------------³----------------------------------------------------------±
;± PARAMETROS:    ³ EBX: Ptr to the OBJECT                                   ±
;±                ³ 'Camera': Camera vector                                  ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 align 4
 light_obj dot3d	?		       ; Luz referente al objeto
 polby16   dd		?
 fcount    dw		?                      ; Contador de caras (reales)
 npolysB   dw		?
 vcount    db		?                      ; Contador de v‚rtices
;-----------------------------------------------------------------------------
 align 16
 TAKECOORDS PROC
	pushad

	mov  objptr, ebx

	mov  esi, ebx
	lea  edi, [esi].vd
	lea  ebx, [esi].mg

; Comprueba si el objeto debe ser rotado...
	call TESTROT
	jc   tk@rotate

tk@norot:
	mov   esi, objptr
	mov   edi, [esi].lista
	movzx ecx, [edi].numdots
	lea   edi, [edi].Vertex.Point
	mov   ebp, TheWorld
	lea   ebp, [ebp].camera
	call  SITUAR2
	jmp   tk@gtcoords

; Inicia la matriz y rota las normales...
tk@rotate:
	call SETMAT
	mov  esi, objptr
	mov  ebp, [esi].lista
	xor  ecx, ecx
	mov  cx,  [ebp].numdots
	lea  edi, [ebp].Vertex.Normal
	lea  esi, [esi].mg
	call ROTAR

; Situa el objeto con respecto a su posici¢n y la de la c mara y lo rota...
tk@situar:
	mov  esi, objptr
	mov  edi, camera_var
	lea  ebx, [esi].mg
	call SITUAR

	xor  ecx, ecx
	mov  edi, [esi].lista
	mov  cx,  [edi].numdots
	lea  edi, [edi].Vertex.Point
	mov  esi, ebx
	call ROTAR


; Si hay enviroment mapping, proyecta las normales...
tk@gtcoords:
	test Rtype, ENVMAP
	jz   short tk@tgrd
	mov  ebx, objptr
	mov  esi, [ebx].lista
	call GETTEXTCOORDS


; Si hay gouraud, obtiene las intensidades de luz en los v‚rtices
tk@tgrd:test Rtype, GOURAUD
	jz   short tk@tcamera
	mov  edi, TheWorld
	add  edi, lightn

	push esi ebp
	mov  esi, objptr
	mov  eax, [esi].pos.x
	sub  eax, [edi].x
	mov  light_obj.x, eax
	mov  eax, [esi].pos.y
	sub  eax, [edi].y
	mov  light_obj.y, eax
	mov  eax, [esi].pos.z
	sub  eax, [edi].z
	mov  light_obj.z, eax
	mov  ebp, offset light_obj
	call NORMALIZE
	pop  ebp esi

	mov  edi, offset light_obj
	mov  ebp, objptr
	mov  ebp, [ebp].lista
	mov  cx, [ebp].numdots
	add  ebp, size numdots

@tk@gs:	call GETSHADECOL
	mov  [ebp].Shade, eax
	add  ebp, size Vertx
	dec  cx
	jnz  short @tk@gs

; Inicia las rotaciones de c mara, si las hay...
tk@tcamera:
	test camflag, 1
	jz   short tk@proy

	pushad
	mov  esi, TheWorld
	add  esi, camera
	lea  ebx, [esi].mg
	mov  esi, objptr
	mov  edi, [esi].lista
	mov  cx,  [edi].numdots
	lea  edi, [edi].Vertex.Point2
	mov  esi, ebx
	call ROTAR2
	popad

tk@proy:mov  ebx, objptr
	mov  esi, [ebx].lista
	call PROYECTAR

; Comprueba las caras visibles...
tk@testfaces:
	xor  eax, eax
	mov  ebx, eax
	mov  ecx, eax
	mov  edx, eax
	mov  ebp, eax

	mov  edi, trvec
	mov  ax, [edi].numpols
	mov  npolysB, ax
	lea  edi, [edi].poly[eax*4]
	mov  edx, zbuffer
	lea  edx, [edx+eax*4]

	mov   esi, objptr
	mov   esi, [esi].fig
	movzx eax, [esi].numfaces
	imul  eax, size polyidx
	mov   polby16, eax

@polyloop:
; Descarta los pol¡gonos no vis¡bles
	push edi ebx ecx edx esi
	mov  ebp, [esi].face[ecx+8].dotinx
	mov  edi, [esi].face[ecx+4].dotinx
	mov  esi, [esi].face[ecx].dotinx
	call CLOCK_OK
	pop  esi edx ecx ebx edi

	jc   short next

; Si es visible, lo a¤ade a la lista para el sort...
	mov  ebp, [esi].face[ecx].dotinx
	mov  ax, word ptr [ebp+2].Point2.z

	mov  ebp, [esi].face[ecx+4].dotinx
	add  ax, word ptr [ebp+2].Point2.z

	mov  ebp, [esi].face[ecx+8].dotinx
	add  ax, word ptr [ebp+2].Point2.z

	mov  [edx+2][ebx*4], ax		; Z Value

	mov  ax, npolysB
	add  ax, bx
	mov  [edx][ebx*4], ax		; Index

	lea  eax, [esi].face[ecx]
	mov  [edi][ebx*4], eax

	inc  ebx

next:	add  ecx, size polyidx
	cmp  ecx, polby16
	jb   short @polyloop

tk@exit:
	mov  edi, trvec
	add  [edi].numpols, bx

skipzbuf:
	popad

	ret

   ENDP


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ LOADOBJECT                                               ±
;±----------------³----------------------------------------------------------±
;± FUNCION:       ³ Lee un objeto del disco (*.SHP)                          ±
;±----------------³----------------------------------------------------------±
;± PARAMETROS:    ³ EDX: Ptr. al nombre del fichero                          ±
;±                ³ ECX: N§ de bytes a leer                                  ±
;±                ³ AL: Gouraud Flag                                         ±
;±----------------³----------------------------------------------------------±
;± SALIDA:        ³ CF: 1 -> No se puede leer el objeto                      ±
;±                ³     AX -> N§ de error                                    ±
;±                ³ CF: 0 -> Lectura en memoria OK                           ±
;±                ³     AX -> N§ de objeto                                   ±
;±                ³     BX -> N§ de morph, si lo hay                         ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 align 4
 bytes      dd	?
 objptr     dd	?
 mphptr     dd	?
 sVertex    dd	?
 handle     dw	?
 lo@nfaces  dw	?
 mapped	    db	?
 gouraud    db	?
 objnumber  db	?
 mphnumber  db	?
 morphf     db	?
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 align 16
 LOADOBJECT PROC

	pushad


	mov  gouraud, al
	mov  bytes, ecx

; Lee el fichero
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; 	call _openfile
;	mov  eax, 0
;	jc   ldob@cf
;	mov  ax, v86r_bx
;	mov  handle, ax
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
	mov  ax, handle
	mov  v86r_bx, ax

	lea  edx, header
	mov  ecx, 8
	call _readfile
	mov  eax, 1
	jc   ldob@cf

; Test number header...
	cmp  word ptr header, 3DEFh
	mov  eax, 3
	jne  ldob@cf

	mov  al, byte ptr header+2

;ÍÍ MORPH STUFF ÍÍÍÍÍÍÍÍÍ
; Test if it's a morph file
	test al, 0010b
	jz   short ldob@nm
	mov  morphf, 1
	jmp  short ldob@tmf
ldob@nm:
	mov  morphf, 0
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ	


; Test the mapping flag
ldob@tmf:
	test al, 1
	jnz  short ldob@map
	mov  mapped, 0
	jmp  short ldob@init

ldob@map:
	mov  mapped, 1

;ÄÄÄ Se aloja la memoria necesaria para el objeto ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ldob@init:
	cmp  initbuf, 1
	je   ldob@bufok

	call initbufs
	jc   ldob@cf

; First initializes the struct...
ldob@bufok:
	mov  eax, (size object)+4
	call _gethimem
	jc   ldob@cf
	and  al, 11111100b

	mov  edi, TheWorld
	mov  ecx, [edi].numobjs

	mov  [edi].obj[ecx*4], eax
	inc  [edi].numobjs
	mov  objnumber, cl
	mov  edi, eax
	mov  objptr, eax

; Now it's time to setup the vector...
	mov   eax, size Vertx
	movzx ecx, word ptr header+04
	imul  eax, ecx
	add   eax, size numdots
	add   eax, 4
	call _gethimem
	jc   ldob@cf
	and  al, 11111100b
	mov  [edi].lista, eax


; ...and face buffers
	mov   eax, size polyidx
	movzx ecx, word ptr header+06
	imul  eax, ecx
	add   eax, size numpols
	add   eax, 4
	call _gethimem
	jc   ldob@cf
	and  al, 11111100b
	mov  [edi].fig, eax


; ...If a morph has been detected, initialices the morph structure too
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;ÍÍ MORPH STUFF ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
	cmp  morphf, 0
	je   ldob@rd

	mov  eax, (size SMorph)+4
	call _gethimem
	jc   ldob@cf
	and  al, 11111100b

	mov  edi, TheWorld
	mov  ecx, [edi].nummorphs

	mov  [edi].morph[ecx*4], eax
	inc  [edi].nummorphs
	mov  mphnumber, cl
	mov  edi, eax
	mov  mphptr, eax


; Comprueba si hay gouraud en el morph
	cmp  gouraud, 0
	je  short ldob@nogour

	mov  [edi].Mntype, GOURAUD
	jmp  ldob@setvertx

ldob@nogour:
	mov  [edi].Mntype, 0

ldob@setvertx:
; For every step, setup the Morph Vertex buffer
	xor   ecx, ecx
	movzx ax, byte ptr header+03
	mov   [edi].numsteps, ax
	mov   eax, objptr
	mov   [edi].objdest, eax

	mov   eax, size Vmorph
	movzx ebx, word ptr header+04
	imul  eax, ebx
	add   eax, 4
	mov   ebx, eax

ldob@getmemloop:
	call _gethimem
	jc   ldob@cf
	and  al, 11111100b
	mov  [edi].Sptr[ecx*4], eax
	mov  eax, ebx
	inc  cx
	cmp  cl, byte ptr header+03
	jne  short ldob@getmemloop
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
ldob@rd:
	mov  edi, objptr
	mov  esi, [edi].lista
	mov  ax, word ptr header+04           ; N§ de vertices
	mov  [esi].numdots, ax

	mov  esi, [edi].fig
	mov  ax, word ptr header+06           ; N§ de caras
	mov  [esi].numfaces, ax

; Initializes the render flag with _ZERO_
	mov  [edi].rflag, 0

; Se lee el shape a un buffer...
ldob@fs:

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;	call _filesize
;	jc  ldob@cf
;	sub eax, 8
;	mov ecx, eax
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	mov  eax, bytes
	sub  eax, 8
	mov  ecx, eax

	push _himembase
	call _gethimem
	jc   ldob@cf
	pop  _himembase
	mov  edx, eax
	mov  eax, 2

	mov  ax, handle
	mov  v86r_bx, ax
	call _readfile
	mov  eax, 1
	jc   ldob@cf

	mov  ecx, (size dot3d*2)
	cmp  mapped, 1
	jne  short @initVertex
	add  ecx, size tex2d

@initVertex:
	mov  sVertex, ecx
	shr  ecx, 2
	mov  esi, edx
	mov  edi, objptr
	mov  edi, [edi].lista
	mov  bp, [edi].numdots
	add  edi, 2

@loopVertex:
	push ecx edi
	rep  movsd
	pop  edi ecx

	add  edi, size Vertx
	dec  bp
	jnz  short @loopVertex

	cmp  gouraud, 1
	jne  short ldob@tfv

;ÄÄ Normalize vector loop ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	pushad
	mov  edi, objptr
	mov  edi, [edi].lista
	mov  cx,  [edi].numdots
	lea  ebp, [edi].Vertex.Normal

ldob@lpnm:
	push cx
	call NORMALIZE
	pop  cx
	add  ebp, size Vertx
	dec  cx
	jnz  short ldob@lpnm
	popad
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

; Test for others Vertex descriptions...
; In this case, the rutine should copy this vertxs to the morphing buffers
;ÍÍ MORPH STUFF ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
ldob@tfv:
	cmp  morphf, 1
	jne  short copytmpl                                                  

	push  esi

; Copy first the object data...                                              
	mov   ebx, mphptr
	mov   edi, [ebx].Sptr[0]
	mov   ecx, 6 ;12*2/4
   	mov   esi, objptr
	mov   esi, [esi].lista
	mov   bp,  [esi].numdots
	add   esi, size numdots

ldob@fd:
	push  edi esi ecx
	rep   movsd
	pop   ecx esi edi


	add   esi, size Vertx
	add   edi, (size dot3d)*4

	dec   bp
	jnz   short ldob@fd

; Now copies the others, normalizing if necesary!... 
   	pop   esi	; Ptr to the file in memory

	mov   edx, 1
	mov   ecx, 6 ;12*2/4


ldob@sloop:
	mov   edi, [ebx].Sptr[edx*4]
	mov   bp,  word ptr header+04		; N vertx

ldob@od:
	push  esi ecx edi
	rep   movsd
	pop   edi ecx esi

	cmp   gouraud, 0
	je    short ldob@odnogor
	pushad
	lea   ebp, [edi].vmNormal
	call  NORMALIZE
	popad

ldob@odnogor:
	add   esi, sVertex
	add   edi, (size dot3d)*4

	dec   bp
	jnz   short ldob@od

	inc   dx
	cmp   dx,  [ebx].numsteps
	jne   short ldob@sloop

	dec   [ebx].numsteps
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ

; Se copian a tmpl
copytmpl:
; Precalcula los punteros
	mov   edi, objptr
	mov   edi, [edi].fig
	mov   bx, [edi].numfaces
	mov   lo@nfaces, bx
	xor   ebx, ebx
	lea   ebp, [edi].face

	mov   edx, esi			;Salvar la direcci¢n del buffer (face)
	mov   edi, objptr
	mov   edi, [edi].lista
	lea   esi, [edi].Vertex.Point

@@rdfloop:				
;Ä V‚rtxxx 1 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ,|
	movzx eax, word ptr [edx]     	;||  Obtiene el indice al punto
        imul  eax, size Vertx		;||| 
	add   eax, esi			;|||> Suma la direcci¢n base
	mov   [ebp].dotinx, eax		;|||  Mueve a [obj].face[num].ptr
					;||
;Ä V‚rtxxx 2 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'|
	movzx eax, word ptr [edx+2]
        imul  eax, size Vertx
	add   eax, esi
	mov   [ebp+04].dotinx, eax

;Ä V‚rtxxx 3 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	movzx eax, word ptr [edx+4]
        imul  eax, size Vertx
	add   eax, esi
	mov   [ebp+08].dotinx, eax

;Ä Color ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	mov   ax,  word ptr [edx+6]
	mov   [ebp].color, ax
	mov   [ebp].pflag, 0


;ÄÄÄÄChapuza para que la t¡a tenga GouraudÄÄÄÄÄÄÄÄÄÄ
	cmp   [ebp].color, 250
	jne   short lo@color
	mov   [ebp].pflag, GOURAUD

lo@color:
;ÄÄÄÄChapuza para que la t¡a tenga GouraudÄÄÄÄÄÄÄÄÄÄ

	add   ebp, size polyidx
	add   edx, 4*2
	inc   bx
	cmp   bx, lo@nfaces
	jb    short @@rdfloop


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;	call _closefile
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	popad
	mov  al, objnumber
	mov  bl, mphnumber
	clc
	ret

ldob@cf:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;	call _closefile
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	mov  [esp+28], eax
	popad
	stc
	ret
 ENDP


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ INITBUF                                                  ±
;±----------------³----------------------------------------------------------±
;± FUNCION:       ³ Inicia los buffers de EXOMOTION                          ±
;±----------------³----------------------------------------------------------±
;± SALIDA:        ³ CF: 1 -> No hay suficiente memoria                       ±
;±                ³ CF: 0 -> Buffers iniciados OK                            ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 ib@temp	dw	?	
 PROC initbufs

; Inits sine table
	push edx
	mov  eax, (256*4*32)+4
	add  eax, 4
	call _getmem
	jc   ib@exit
        and  al, 11111100b
	mov  sintab, eax
	mov  edi, eax
	call GENSIN
	pop  edx

; Inits the square table
	mov  eax, (2024*4)+4
	add  eax, 4
	call _getmem
	jc   ib@exit
        and  al, 11111100b
	pushad
	mov  edi, eax
	mov  ecx, 2024
	mov  edx, -1024
squar:	mov  eax, edx
	imul eax, eax
	mov  [edi], eax
	add  edi, 4
	inc  edx
	loop squar
	popad
	add  eax, 1024*4
	mov  sqtable, eax

; Inits World
	mov  eax, (size world)+4
	add  eax, 4
	call _getmem
	jc   ib@exit
	and  al, 11111100b
	mov  TheWorld, eax
	mov  [eax].numobjs, 0
	mov  [eax].nummorphs, 0

; Ptrs to transform polygons
	mov  eax, size trpols+4
	add  eax, 4
	call _getmem
	jc   ib@exit
	and  al, 11111100b
	mov  trvec, eax

; Z Buffer to the sort
	mov  eax, (TOTFACES*4)+4      ; 2 bytes for the index, 2 for the Z
	add  eax, 4
	call _getmem
	jc   ib@exit
	and  al, 11111100b
	mov  zbuffer, eax

; Light table for the flare
	mov  eax, 64*256
	add  eax, 4
	call _getmem
	jc   ib@exit
	and  al, 11111100b
	mov  light_table2, eax

; Convierte el valor inicial en un fixed
	pushad

	mov  edi, eax
	xor  eax, eax
	mov  ebp, 70000

; Inicia: Cl -> Valor del color
	xor  cx, cx

ib@lt0:
	xor  bx, bx

ib@lt1:	mov  dx, bx
	mov  si, bx
	and  si, 11100000b
	shl  edx, 16
	and  edx, 000111111111111111111111b
	add  edx, eax
	cmp  edx, 000111111111111111111111b
	jbe  short ib@ltt2
	mov  edx, 000111111111111111111111b
ib@ltt2:shr  edx, 16
	add  dx, si

	mov  [edi], dl

	inc  edi
	inc  bx
	cmp  bx, 256
	jnz  short ib@lt1

	add  eax, ebp
	inc  cx
	cmp  cx, 32
	jb   short ib@lt0

	popad
   
; Stacks for Radix Short (Max. polygons TOTFACES <> )
	mov  eax, (4096*4*16)+4
	add  eax, 4
	call _getmem
	jc   ib@exit
	and  al, 11111100b
	mov  stackbase, eax

; Tables for motion blur & transparency
	mov  eax, 64
	add  eax, 4
	call _getmem
	jc   ib@exit
	and  al, 11111100b
	mov  fadetab, eax

; Color tables for interpolation in FADEINIT & FADETRACE
	mov  eax, 256*3*4
	add  eax, 4
	call _getmem
	jc   ib@exit
	and  al, 11111100b
	mov  inccoltab, eax

	mov  eax, 256*3*4
	add  eax, 4
	call _getmem
	jc   ib@exit
	and  al, 11111100b
	mov  coltab, eax

; Virtual Screen
	mov  eax, 76800+4
	add  eax, 4
	call _getmem
	jc   ib@exit
	and  al, 11111100b
	mov  screen.vscreen, eax

; Initializes VS
	push edi ecx
	mov  edi, eax
	mov  ecx, 19200
	xor  eax, eax
	rep  stosd
	pop  ecx edi


; Initializes Motion Blur Table
	mov  initbuf, 1

ib@exit:
	ret
 ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDURE:     ³ INITPATH                                                 ±
;±----------------³----------------------------------------------------------±
;± FUNCTION:      ³ Starts the path of an object                             ±
;±----------------³----------------------------------------------------------±
;± PARAMETERS:    ³ EAX: Animation type                                      ±
;±                ³ EBX: Number of steps                                     ±
;±                ³ ECX: Time for all the motion (In seconds)                ±
;±                ³ EDX: Ptr to the Path dots                                ±
;±		  ³ EBP: Object number				     	     ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
align 16
INITPATH PROC

	pushad
	
	mov esi, TheWorld
	mov edi, [esi].obj[ebp*4] 		; EDI -> Object pointer
	mov [edi].adata.aflag, al
	mov [edi].adata.nsteps, bx
	mov [edi].adata.pathptr, edx

; Inits the data (The dirty motion stuff :-)
	xor  eax, eax
	mov  [edi].adata.cframe, eax
	mov  [edi].adata.cstep, ax
	mov  eax, screen.vgahz
	imul ecx	    		; Number of retrs for 
;	mov  edx, eax			; all the animation
;	shr  edx, 16
;	shl  eax, 16
	idiv ebx		   
	mov  [edi].adata.ftime, eax     ; Divided by NSteps = Steps by dot

; Inits object position and increment of pos.
	mov  esi, [edi].adata.pathptr
	mov  ebx, eax

	mov  eax, [esi].sdot.x
	mov  [edi].pos.x, eax
	mov  eax, [esi].sdot.y
	mov  [edi].pos.y, eax
	mov  eax, [esi].sdot.z
	mov  [edi].pos.z, eax

	mov  eax, [esi].srot.x
	mov  [edi].vd.x, eax
	mov  eax, [esi].srot.y
	mov  [edi].vd.y, eax
	mov  eax, [esi].srot.z
	mov  [edi].vd.z, eax

; Inits the first inc
	mov  cx, 3
ip@lp:	mov  eax, [esi+24].sdot.x
	sub  eax, [esi].sdot.x
	add  eax, UNO
	mov  edx, eax
	sar  edx, 16
	shl  eax, 16
	idiv ebx
	mov  [edi].adata.cincr.x, eax

	mov  eax, [esi+24].srot.x
	sub  eax, [esi].srot.x
	add  eax, UNO
	mov  edx, eax
	sar  edx, 16
	shl  eax, 16
	idiv ebx
	mov  [edi].adata.crot.x, eax

	add  esi, 4
	add  edi, 4
	dec  cx
	jnz  short ip@lp

	popad
	ret
 ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ TRACEPATH                                                ±
;±----------------³----------------------------------------------------------±
;± FUNCTION:      ³ Increments the path of an object                         ±
;±----------------³----------------------------------------------------------±
;± PARAMETERS:    ³ EBP: Object number				     	     ±
;±                ³ EBX: Raster count				     	     ±
;±----------------³----------------------------------------------------------±
;± OUT:		  ³ CF:1 ->  Animation finished				     ±
;±        	  ³ CF:0 ->  Umm... What can be this? =)		     ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
align 16
TRACEPATH PROC
	pushad

	mov  esi, TheWorld
	mov  esi, [esi].obj[ebp*4]

	xor  ebx, ebx
	mov  bx, timer.rcount			;!!!!!!!!!!

; Mov the object position
	mov  eax, [esi].adata.cincr.x
	imul eax, ebx
	add  [esi].pos.x, eax

	mov  eax, [esi].adata.cincr.y
	imul eax, ebx
	add  [esi].pos.y, eax

	mov  eax, [esi].adata.cincr.z
	imul eax, ebx
	add  [esi].pos.z, eax

; Mov the object rotaction
	mov  eax, [esi].adata.crot.x
	imul eax, ebx
	add  [esi].vd.x, eax

	mov  eax, [esi].adata.crot.y
	imul eax, ebx
	add  [esi].vd.y, eax

	mov  eax, [esi].adata.crot.z
	imul eax, ebx
	add  [esi].vd.z, eax

	xor  ebx, ebx
	mov  bx, timer.rcount

	shl  ebx, 16
	mov  eax, [esi].adata.cframe
	add  eax, ebx
	mov  [esi].adata.cframe, eax
	xor  ebx, ebx
	cmp  eax, [esi].adata.ftime
	jb   tp@end
	je   short tp@noup

	mov  ebx, eax
	sub  ebx, [esi].adata.ftime

tp@noup:xor  eax, eax
	mov  ax, word ptr [esi].adata.ftime
	
	add  ebx, eax
	mov  [esi].adata.cframe, ebx
	inc  [esi].adata.cstep

	mov  ebx, [esi].adata.ftime
	mov  edi, [esi].adata.pathptr
	xor  eax, eax
	mov  ax, [esi].adata.cstep
	mov  edx, eax			; Equal to mul by 24
	shl  eax, 4
	lea  edx, [edx*8]
	add  eax, edx
	add  edi, eax


	mov  eax, [edi].x
	mov  [esi].pos.x, eax
	mov  eax, [edi].y
	mov  [esi].pos.y, eax
	mov  eax, [edi].z
	mov  [esi].pos.z, eax

	mov  eax, [edi].srot.x
	mov  [esi].vd.x, eax
	mov  eax, [edi].srot.y
	mov  [esi].vd.y, eax
	mov  eax, [edi].srot.z
	mov  [esi].vd.z, eax

	mov  ax, [esi].adata.cstep
	cmp  ax, [esi].adata.nsteps
	jge  short tp@cf

	mov  cx, 3

tp@lp:	mov  eax, [edi+24].sdot.x
	sub  eax, [edi].sdot.x
	add  eax, UNO
	mov  edx, eax
	sar  edx, 16
	shl  eax, 16
	idiv ebx
	mov  [esi].adata.cincr.x, eax

	mov  eax, [edi+24].srot.x
	sub  eax, [edi].srot.x
	add  eax, UNO
	mov  edx, eax
	sar  edx, 16
	shl  eax, 16
	idiv ebx
	mov  [esi].adata.crot.x, eax

	add  esi, 4
	add  edi, 4
	dec  cx
	jnz  short tp@lp
		
tp@end: popad
	clc
	ret

tp@cf:	popad
	stc
	ret

 ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ SETBACKGND                                               ±
;±----------------³----------------------------------------------------------±
;± FUNCTION:      ³ Inits the the backgrnd (Image or black screen, or anyone)±
;±----------------³----------------------------------------------------------±
;± PARAMETERS:    ³ AL: Sets the background type:                            ±
;±        	  ³    0: Clear with color 0 the screen                      ±
;±        	  ³    1: Init image data and use it to clear the screen     ±
;±        	  ³       EDI: Ptr to the image               	     	     ±
;±        	  ³   XX: Don't clear the screen                             ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 SETBACKGND  PROC

	pushad
   
	mov  screen.backgnd, al
	cmp  al, 1
	jne  short sb@exit

	mov  screen.backgnd, 1
	mov  screen.bgptr, edi
	mov  word ptr screen.bgok, 0

sb@exit:
	popad
	ret
 ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ INITMAP                                                  ±
;±----------------³----------------------------------------------------------±
;± FUNCTION:      ³ Relocate a pixmap for Ram <-> Vga-modex copy             ±
;±----------------³----------------------------------------------------------±
;± PARAMETERS:    ³ EDI: Map to relocate                                     ±
;±                ³ ECX: Size in bytes of the map                            ±
;±----------------³----------------------------------------------------------±
;± OUT:		  ³ CF:1 -> Insuficient memory for the operation             ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 INITMAP  PROC

	pushad
	
	push _himembase          ; Preserves the memory used by this function

	mov  eax, ecx
	call _gethimem
	jc   short im@enomem
	mov  esi, eax
	xchg esi, edi
	
	push edi
	shr  ecx, 3		 ; Divides ecx by 4
	mov  ebx, esi
	xor  ebp, ebp

im@bpl:	mov  esi, ebx
	add  esi, ebp
	push ecx

im@inl:	mov  al, [esi]
	mov  [edi], al
	mov  al, [esi+4]
	mov  [edi+1], al

	add  esi, 8
	add  edi, 2
	dec  ecx
	jnz  short im@inl
	
	pop  ecx

	inc  ebp
	cmp  ebp, 4
	jne  short im@bpl		

	pop  edi
	mov  esi, ebx
	xchg esi, edi
	shl  ecx, 1
	rep  movsd

	pop _himembase
	popad
	clc
	ret

im@enomem:
	add esp, 4
	popad
	stc
	ret

 ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ INITTEXT                                                 ±
;±----------------³----------------------------------------------------------±
;± FUNCTION:      ³ Initialize a texture for the engine                      ±
;±----------------³----------------------------------------------------------±
;± PARAMETERS:    ³ EDI: Ptr to the map                                      ±
;±                ³ AL:  Number to asing to the texture                      ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 INITTEXT  PROC
	pushad
	
	mov   esi, TheWorld
	xor   ebx, ebx
	mov   bl, al
	mov   [esi].text.[ebx*4], edi

   	popad
        ret
 ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ LOADPICTURE                                              ±
;±----------------³----------------------------------------------------------±
;± FUNCTION:      ³ Initialize a texture for the engine                      ±
;±----------------³----------------------------------------------------------±
;± PARAMETERS:    ³ EDX: Ptr to the name of the file                         ±
;±		  ³ ECX: Number of bytes to load                             ±
;±----------------³----------------------------------------------------------±
;± OUT:		  ³ CF:1 -> Insuficient memory for the operation             ±
;±                ³ CF:0 -> Load ok!                                         ±
;±                ³  EAX: Ptr to the picture                                 ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 align 16
 LOADPICTURE  PROC
	pushad

; Lee el fichero
comment ‡
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	call _openfile
	jc   lp@end
	mov  ax, v86r_bx
	mov  handle, ax

	call _filesize
	jc   lp@end
	mov  ecx, eax
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
‡

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	mov  eax, ecx
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	call _gethimem
	jc   lp@end
	mov  [esp+28], eax	
	mov  edx, eax

	mov  ax, handle
	mov  v86r_bx, ax
	call _readfile
	jc   lp@end

	mov  ax, handle
	mov  v86r_bx, ax
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;	call _closefile
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
lp@end:	popad
	ret

 ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDURE:     ³ INITMORPH                                                ±
;±----------------³----------------------------------------------------------±
;± FUNCTION:      ³ Starts the path of an object                             ±
;±----------------³----------------------------------------------------------±
;± PARAMETERS:	  ³ EAX: Morph Identifier				     ±
;±                ³ EBX: Number of steps of sequence                         ±
;±                ³ ECX: Time for all the motion (In seconds)                ±
;±                ³ EDX: Ptr to the sequence                                 ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
align 4
valchorra	dd	?

align 16
INITMORPH PROC

	pushad
	
	mov   esi, TheWorld
	mov   edi, [esi].morph[eax*4] 		; EDI -> Object pointer

	mov   valchorra, edi

; Inits the data (The Dirty Motion Stuff)
	xor   eax, eax
	mov   [edi].Mcframe, eax
	mov   [edi].Mcstep, ax
	mov   [edi].numseq, bx
	mov   [edi].seqptr, edx


im@timeok:
	push  edx
	mov   eax, screen.vgahz
	imul  ecx	    		 ; Number of retraces for all the animation
	shl   ebx, 16
	idiv  ebx
	mov   [edi].Mftime, eax          ; Divided by NSteps = retraces/step
	pop   edx


; Inits increment of pos.
	mov   ebx, eax
	mov   esi, [edi].objdest
	mov   esi, [esi].lista
	movzx ebp, [esi].numdots

	mov   ecx, [edi].seqptr
	movzx eax, byte ptr [ecx] 
	mov   esi, [edi].Sptr[eax*4]

; Copies original vector data to the 'lista'
	pushad
	mov   edi, [edi].objdest
	mov   edi, [edi].lista
	mov   cx,  [edi].numdots
	add   edi, 2

im@cvl:
	mov  eax, [esi].vmPoint.x
	mov  [edi].Point.x, eax
	mov  eax, [esi].vmPoint.y
	mov  [edi].Point.y, eax
	mov  eax, [esi].vmPoint.z
	mov  [edi].Point.z, eax

	mov  eax, [esi].vmNormal.x
	mov  [edi].Normal.x, eax
	mov  eax, [esi].vmNormal.y
	mov  [edi].Normal.y, eax
	mov  eax, [esi].vmNormal.z
	mov  [edi].Normal.z, eax

	add  esi, size Vmorph
	add  edi, size Vertx

	dec  cx
	jnz  short im@cvl
	popad


	push ebp
	mov  ebp, valchorra
	cmp  [ebp].Mntype, GOURAUD
	je   valchorra0
	mov  valchorra, UNO
	pop  ebp
	jmp  short im@inloop

valchorra0:
	mov  valchorra, 0
	pop  ebp

im@inloop:
	movzx eax, byte ptr [ecx+1] 
	mov   edi, [edi].Sptr[eax*4]
; Inits the first inc
im@lv:	
	mov  cx,  3
im@lp:	mov  eax, [edi].vmPoint.x
	sub  eax, [esi].vmPoint.x
	add  eax, valchorra
	mov  edx, eax
	sar  edx, 16
	shl  eax, 16
	idiv ebx
	mov  [esi].iPoint.x, eax

	mov  eax, [edi].vmNormal.x
	sub  eax, [esi].vmNormal.x
	add  eax, valchorra
	mov  edx, eax
	sar  edx, 16
	shl  eax, 16
	idiv ebx
	mov  [esi].iNormal.x, eax

	add  esi, 4
	add  edi, 4
	dec  cx
	jnz  short im@lp

	add  esi, (size dot3d)*3
	add  edi, (size dot3d)*3

	dec  bp
	jnz  short im@lv

	popad
	ret
 ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ TRACEMORPH                                               ±
;±----------------³----------------------------------------------------------±
;± FUNCTION:      ³ Increments the morph of an object                        ±
;±----------------³----------------------------------------------------------±
;± PARAMETERS:    ³ EAX: Morph number				     	     ±
;±----------------³----------------------------------------------------------±
;± OUT:		  ³ CF:1 ->  Animation finished				     ±
;±        	  ³ CF:0 ->  Umm... What can be this? =)		     ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
align 4
temp		dd	?
temp2		dd	?
tm@ctr  	dw	?
tm@dirflag	db	0

align 16
TRACEMORPH PROC
	pushad

	mov  esi, TheWorld
	mov  ebp, [esi].morph[eax*4]
	push ebx

	mov   valchorra, ebp

	mov   edi, [ebp].objdest
	mov   edi, [edi].lista
	mov   cx,  [edi].numdots
	add   edi, size numdots

	movzx ebx, [ebp].Mcstep
	mov   eax, [ebp].seqptr
	movzx ebx, byte ptr [eax+ebx]
	mov   esi, [ebp].Sptr[ebx*4]

	pop  ebx
	
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
; Mov the vertx position
tm@vil:
	mov  eax, [esi].iPoint.x
	imul eax, ebx
	add  [edi].Point.x, eax

	mov  eax, [esi].iPoint.y
	imul eax, ebx
	add  [edi].Point.y, eax

	mov  eax, [esi].iPoint.z
	imul eax, ebx
	add  [edi].Point.z, eax

; Mov the vertx normal
	mov  eax, [esi].iNormal.x
	imul eax, ebx
	add  [edi].Normal.x, eax

	mov  eax, [esi].iNormal.y
	imul eax, ebx
	add  [edi].Normal.y, eax

	mov  eax, [esi].iNormal.z
	imul eax, ebx
	add  [edi].Normal.z, eax

	add  esi, size Vmorph
	add  edi, size Vertx
	dec  cx
	jnz  short tm@vil
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ


	shl  ebx, 16
	mov  eax, [ebp].Mcframe
	add  eax, ebx
        mov  [ebp].Mcframe, eax
	xor  ebx, ebx
	cmp  eax, [ebp].Mftime
	jb   tm@end
	je   short tm@noup

	mov  ebx, eax
	sub  ebx, [ebp].Mftime

tm@noup:
	xor  eax, eax
	mov  ax, word ptr [ebp].Mftime

	add  ebx, eax
	mov  [ebp].Mcframe, ebx
	inc  [ebp].Mcstep

	xor  eax, eax
	mov  ax, [ebp].Mcstep
	cmp  ax, [ebp].numseq
	jnb  tm@cf

; Get actual vector to the morph vertx
	mov   esi, [ebp].seqptr
	movzx ebx, byte ptr [esi+eax]
	mov   edx, [ebp].Sptr[ebx*4]
	mov   temp, edx

	push  edx

; Get next vector
	inc   eax
	movzx ebx, byte ptr [esi+eax]
	mov   edx, [ebp].Sptr[ebx*4]
	push  edx

; Initializes 
	mov   ebx, [ebp].Mftime
	mov   edi, [ebp].objdest
	mov   edi, [edi].lista
	mov   cx,  [edi].numdots
	push  cx
	add   edi, 2


	mov   temp, edi

	pop  cx
	pop  edi
	pop  esi


	mov  ebp, valchorra
	cmp  [ebp].Mntype, GOURAUD
	je   valchorra02
	mov  valchorra, UNO
	jmp  short tm@inloop

valchorra02:
	mov  valchorra, 0

tm@inloop:
	mov  ebp, temp

	I = 0

; Initializes nexts inc
tm@lv:	
	REPT 3
	mov  eax, [edi+I].vmPoint.x
	sub  eax, [ebp+I].Point.x
	add  eax, valchorra
	mov  edx, eax
	sar  edx, 16
	shl  eax, 16
	idiv ebx
	mov  [esi+I].iPoint.x, eax

	mov  eax, [edi+I].vmNormal.x
	sub  eax, [ebp+I].Normal.x
	add  eax, valchorra
	mov  edx, eax
	sar  edx, 16
	shl  eax, 16
	idiv ebx
	mov  [esi+I].iNormal.x, eax

	I    = I + 4
	ENDM
	
	add  esi, size Vmorph
	add  edi, size Vmorph
	add  ebp, size Vertx

	dec  cx
	jnz  tm@lv

;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
		
tm@end:
	popad
	clc
	ret

tm@cf:	popad
	xor  tm@dirflag, 1
	stc
	ret

 ENDP



;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ SETRFLAG                                                 ±
;±----------------³----------------------------------------------------------±
;± FUNCTION:      ³ Set the render flags                                     ±
;±----------------³----------------------------------------------------------±
;± PARAMETERS:    ³ AL:  Rflag                                               ±
;±        	  ³ BL:  Obj. number                                	     ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROC SETRFLAG
	pushad

	mov   esi, TheWorld
	movzx ebx, bl
	mov   edi, [esi].obj.[ebx*4]
	mov   [edi].rflag, al

 	popad

	ret
ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ WAITTIME                                                 ±
;±----------------³----------------------------------------------------------±
;± FUNCTION:      ³ Wait time (in seconds)                                   ±
;±----------------³----------------------------------------------------------±
;± PARAMETERS:    ³ AX: N§ de segundos....                                   ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PROC WAITTIME
	push esi edx

	push  timer.rcount
	movzx eax, ax
	mov   esi, screen.vgahz
	xchg  eax, esi
	imul  esi
	shrd  eax, edx, 16
	mov   timer.rcount, 0
wt@loop:cmp   ax, timer.rcount
	jne   short wt@loop
	pop   timer.rcount

        pop  edx esi
 	ret
ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ TESTCOPRO                                                ±
;±----------------³----------------------------------------------------------±
;± FUNCTION:      ³ Test the coprocesor                                      ±
;±----------------³----------------------------------------------------------±
;± RETURNS:       ³ AL:  Copro flag                                          ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
tc@value	dd	?
PROC TESTCOPRO

	finit
	fldpi
 
 	mov tc@value, 0
        fstp tc@value
	cmp tc@value, 40490fdbh
	jne short tc@nocopro

	xor al, al
	jmp short tc@exit

tc@nocopro:
	mov al, -1
tc@exit:
	ret
ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ MAKELIGHTTABLE                                           ±
;±----------------³----------------------------------------------------------±
;± FUNCTION:      ³ Generates a new light table                              ±
;±----------------³----------------------------------------------------------±
;± PARAMETRES:    ³ EBP: Incremento                                          ±
;±                ³ AX: Valor Inicial                                        ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
; A = CL
extrn light_table:byte
PROC NEWLIGHTTABLE

; Convierte el valor inicial en un fixed
	shl  eax, 16

; Inicia: Cl -> Valor del color
	xor  cx, cx
	xor  edi, edi

nt@lt1:	movzx dx, cl
	shl  edx, 16
	mov  esi, edx
	and  edx, 00011111b*UNO
	and  esi, 11100000b*UNO
	sub  edx, eax
	cmp  edx, 0
	jge  short nt@ltt1
	xor  edx, edx
nt@ltt1:cmp  edx, 31*UNO
	jle  short nt@ltt2
	mov  edx, 31*UNO
nt@ltt2:add  edx, esi
	shr  edx, 16
	mov  light_table[edi], dl


;ÄÄÄ Funcioncilla chorra pa que la piva tenga gouraud ÄÄÄÄÄ
	cmp   cl, 85
	jne   short nt@chorra1
	push  ebx
	movzx  bx, ch
	mov   goutab[bx], dl
	pop   ebx
nt@chorra1:
;ÄÄÄ Funcioncilla chorra pa que la piva tenga gouraud ÄÄÄÄÄ

	inc  edi
	inc  cl
	jnz  short nt@lt1

	sub  eax, ebp
	inc  ch
	cmp  ch, 32
	jne  short nt@lt1
		
	ret
ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDIMIENTO: ³ FADEINIT                                                ±
;±-----------------³---------------------------------------------------------±
;±  FUNCION:       ³ Realiza un fundido con la paleta                        ±
;±-----------------³---------------------------------------------------------±
;±  PARAMETROS:    ³ EDI: Buffer en donde est‚n los colores                  ±
;±                 ³ EAX: Valores RGB del color target			     ±
;±                 ³  CX: Duraci¢n del fade                                  ±
;±                 ³  BL: Tipo                                               ±
;±                 ³   0: Transforma la paleta del buffer al color (FADEOUT) ±
;±                 ³   1: Transforma la paleta del color al buffer  (FADEIN) ±
;±                 ³   2: Transforma la paleta a otra diferente  (FADEMORPH) ±
;±                 ³  BP: N£mero de colores a mover                          ±
;±                 ³  DL: Valor inicial de color en la paleta                ±
;±                 ³ ESI: (Fademorph) Paleta de origen                       ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FADEOUT   = 0
FADEIN    = 1
FADEMORPH = 2

align 4
fmpal	dd	?
paldir	dd	?
time	dd	?
red	dd	?
green	dd	?
blue	dd	?
ncols	dw	?
ftype	db	?
initial	db	?

align 16
; Procesos a realizar:
 FADEINIT PROC

	pushad

; Mueve todos los datos a variables
	mov   ncols, bp
	mov   initial, dl

	xor   edx, edx
	mov   dl, al
	shl   edx, 16
	mov   blue, edx

	xor   edx, edx
	mov   dl, ah
	shl   edx, 16
	mov   green, edx

	xor   ax, ax
	mov   red, eax

	mov   ftype, bl
	mov   paldir, edi
	mov   fmpal, esi

; Calcula en n§ de retrazados que deben producirse (FIXED!)
	mov   eax, ecx
	imul  screen.vgahz
	mov   time, edx

; Mueve los datos de la paleta a la tabla de valores a volcar
	cmp   ftype, FADEIN
	je    fi@002

	cmp   ftype, FADEMORPH
	je    fi@003

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;±±  RUTINA FADEOUT ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
fi@001:
; Mueve la paleta de color
	mov   esi, paldir
	xor   eax, eax
	mov   al, initial
	lea   eax, [eax*2+eax]
	add   esi, eax

 	mov   edi, coltab
	mov   cx, ncols

fi@movtab:
	xor   eax, eax
	mov   al, [esi]
	shl   eax, 16
	mov   [edi], eax

	xor   eax, eax
	mov   al, [esi+1]
	shl   eax, 16
	mov   [edi+4], eax

	xor   eax, eax
	mov   al, [esi+2]
	shl   eax, 16
	mov   [edi+8], eax

	add   esi, 3
	add   edi, 12
	dec   cx
	jnz   short fi@movtab

	mov   ebp, inccoltab
	mov   edi, offset red
	mov   esi, coltab
	mov   cx, ncols

fi@nextval:
	mov   eax, [edi]
	mov   ebx, [esi]
	sub   eax, ebx
	add   eax, UNO
	cdq
	idiv  time
	mov   [ebp], eax

	mov   eax, [edi+4]
	mov   ebx, [esi+4]
	sub   eax, ebx
	add   eax, UNO
	cdq
	idiv  time
	mov   [ebp+4], eax

	mov   eax, [edi+8]
	mov   ebx, [esi+8]
	sub   eax, ebx
	add   eax, UNO
	cdq
	idiv  time
	mov   [ebp+8], eax

	add   esi, 3*4
	add   ebp, 3*4
	dec   cx
	jnz   short fi@nextval


	jmp   fi@comp


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;±±  RUTINA FADEIN ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

fi@002:	mov   esi, offset red
	mov   edi, coltab
	mov   cx, ncols

fi@movtab002:
	mov   eax, [esi]
	mov   [edi], eax
	mov   eax, [esi+4]
	mov   [edi+4], eax
	mov   eax, [esi+8]
	mov   [edi+8], eax
	add   edi, 3*4
	dec   cx
	jnz   short fi@movtab002

; Calcula el incremento de cada color a su valor final.
	xor   eax, eax
	mov   esi, coltab
	mov   ebp, inccoltab
	mov   edi, paldir
	mov   al, initial
	lea   eax, [eax*2+eax]
	add   edi, eax
	mov   cx, ncols

fi@nextval002:
	xor   eax, eax
	mov   al, [edi]
	shl   eax, 16
	mov   ebx, [esi]
	sub   eax, ebx
	add   eax, UNO
	cdq
	idiv  time
	mov   [ebp], eax

	xor   eax, eax
	mov   al, [edi+1]
	shl   eax, 16
	mov   ebx, [esi+4]
	sub   eax, ebx
	add   eax, UNO
	cdq
	idiv  time
	mov   [ebp+4], eax

	xor   eax, eax
	mov   al, [edi+2]
	shl   eax, 16
	mov   ebx, [esi+8]
	sub   eax, ebx
	add   eax, UNO
	cdq
	idiv  time
	mov   [ebp+8], eax

	add   edi, 3
	add   esi, 3*4
	add   ebp, 3*4
	dec   cx
	jnz   short fi@nextval002

	jmp   fi@comp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;±±  RUTINA FADEMORPH ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

fi@003:	mov   esi, fmpal
	mov   edi, coltab
	mov   cx, ncols

; Suma el valor del color inicial al puntero a la paleta de origen
	xor   eax, eax
	mov   al, initial
	lea   eax, [eax*2+eax]
	add   esi, eax
	xor   eax, eax

fi@movtab003:
	mov   al, [esi]
	shl   eax, 16
	mov   [edi], eax

	mov   al, [esi+1]
	shl   eax, 16
	mov   [edi+4], eax

	mov   al, [esi+2]
	shl   eax, 16
	mov   [edi+8], eax

	add   esi, 3
	add   edi, 3*4
	dec   cx
	jnz   short fi@movtab003

; Calcula el incremento de cada color a su valor final.
	mov   esi, coltab
	mov   ebp, inccoltab
	mov   edi, paldir

	xor   eax, eax
	mov   al, initial
	lea   eax, [eax*2+eax]
	add   edi, eax
	mov   cx, ncols
	mov   ebx, time

fi@nextval003:
	xor   eax, eax
	mov   al, [edi]
	shl   eax, 16
	sub   eax, [esi]
	add   eax, UNO
	cdq
	idiv  ebx
	mov   [ebp], eax

	xor   eax, eax
	mov   al, [edi+1]
	shl   eax, 16
	sub   eax, [esi+4]
	add   eax, UNO
	cdq
	idiv  ebx
	mov   [ebp+4], eax

	xor   eax, eax
	mov   al, [edi+2]
	shl   eax, 16
	sub   eax, [esi+8]
	add   eax, UNO
	cdq
	idiv  ebx
	mov   [ebp+8], eax

	add   edi, 3
	add   esi, 3*4
	add   ebp, 3*4
	dec   cx
	jnz   short fi@nextval003


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;±±  CODIGO COMPARTIDO  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

fi@comp:
; Vuelca en pantalla la primera muestra
	mov   edi, coltab
        mov   dx, DAC_WRITE
	mov   al, initial
	mov   cx, ncols

	mov  timer.wfwpal, 2
	mov  timer.wpncol, cx
	mov  timer.wpnini, ax
	mov  timer.wpadd, edi

comment ‡
	call  WAITRETRACE2
   
	out   dx, al
	mov   dx, DAC_DATA

fi@01:	mov   eax, [edi]
	shr   eax, 16
	out   dx, al
	mov   eax, [edi+4]
	shr   eax, 16
	out   dx, al
	mov   eax, [edi+8]
	shr   eax, 16
	out   dx, al

	add   edi, 3*4
	dec   cx
	jnz   short fi@01
‡

	popad
	ret
  ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDIMIENTO: ³ FADETRACE                                               ±
;±-----------------³---------------------------------------------------------±
;±  FUNCION:       ³ Realiza el fade                                         ±
;±-----------------³---------------------------------------------------------±
;±  PAREMTROS      ³ EBX: N§ De retrazados producidos...                     ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
; Suma el valor de interpolaci¢n al color
; Actualiza la paleta en pantalla.
; Si producido el suficiente n£mero de retrazados, para la animaci¢n
 FADETRACE PROC
	pushad

	mov   eax, time
	sub   eax, ebx
	mov   time, eax
	jle   ft@endefect

	mov   esi, inccoltab
	mov   edi, coltab
	mov   cx, ncols

ft@incval:
	mov   eax, [esi]
	imul  eax, ebx
	add   [edi], eax

	mov   eax, [esi+4]
	imul  eax, ebx
	add   [edi+4], eax

	mov   eax, [esi+8]
	imul  eax, ebx
	add   [edi+8], eax

	add   esi, 3*4
	add   edi, 3*4
	dec   cx
	jnz   short ft@incval


; Vuelca en pantalla la primera muestra
   
        mov   edi, coltab
	mov   dx, DAC_WRITE
	mov   al, initial
	mov   cx, ncols

	mov  timer.wfwpal, 2
	mov  timer.wpncol, cx
	mov  timer.wpnini, ax
	mov  timer.wpadd, edi

comment ‡
	call  WAITRETRACE2

	out   dx, al
	mov   dx, DAC_DATA

ft@01:	mov   eax, [edi]
	shr   eax, 16
	out   dx, al

	mov   eax, [edi+4]
	shr   eax, 16
	out   dx, al

	mov   eax, [edi+8]
	shr   eax, 16
	out   dx, al

	add   edi, 3*4
	dec   cx
	jnz   short ft@01
‡
	jmp   ft@exit

ft@endefect:
	cmp   ftype, FADEIN
	je    ft@002

; C¢digo equivalente para ambos casos
	cmp   ftype, FADEMORPH
	je    ft@002

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;±± Vuelca en pantalla el color (fadeout) ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
        mov   dx, DAC_WRITE
	mov   al, initial
	mov   cx, ncols

	mov   ebx, red
	shr   ebx, 16
	mov   esi, green
	shr   esi, 16
	mov   ebp, blue
	shr   ebp, 16


;	mov   timer.wfwpal, 3
;	mov   timer.wpncol, cx
;	mov   timer.wpnini, ax
;	mov   timer.wpr, ebx
;	mov   timer.wpg, esi
;	mov   timer.wpb, ebp

;comment ‡

	call  WAITRETRACE2
   
	out   dx, al
	mov   dx, DAC_DATA

ft@volc:
	mov   ax, bx
	nop
	out   dx, al
	mov   ax, si
	nop
	out   dx, al
	mov   ax, bp
	nop
	out   dx, al

	dec   cx
	jnz   short ft@volc

;‡

	stc
	jmp   ft@exit

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; ±±± Vuelca en pantalla la paleta (fadein) ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± 
ft@002:
        xor   ebx, ebx
        mov   dx, DAC_WRITE
	mov   al, initial
	mov   bl, al
	lea   ebx, [ebx*2+ebx]
	mov   cx, ncols
	mov   esi, paldir
	add   esi, ebx


	mov   timer.wfwpal, 1
	mov   timer.wpncol, cx
	mov   timer.wpnini, ax
	mov   timer.wpadd, esi

comment ‡
	call  WAITRETRACE2
	out   dx, al
	mov   dx, DAC_DATA

ft@volc002:
	mov   al, [esi]
	nop
	out   dx, al
	mov   al, [esi+1]
	nop
	out   dx, al
	mov   al, [esi+2]
	nop
	out   dx, al

	add   esi, 3
	dec   cx
	jnz   short ft@volc002
‡

	stc

; Por fin el fin
ft@exit:
	popad
	ret
  ENDP


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ LOOKAT_Y                                                 ±
;±----------------³----------------------------------------------------------±
;± FUNCTION:      ³ Makes that camera looks to the objetive is selected path ±
;±----------------³----------------------------------------------------------±
;±  PAREMTROS     ³ EAX: N£mero de objeto                                    ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
align 4
;---------------------
var_x	dd	?
var_y	dd	?
angle	dd	?
;---------------------
align 16
LOOKAT_Y PROC

	pushad

	mov   ebp, TheWorld	 		; EDI ptrs to the object
	lea   esi, [ebp].camera
	lea   edi, [ebp].objetivo


;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
; Calculates Y angle... (plane X/Z)
; Y = arctan(x/z)

	mov   eax, [edi].pos.z
	sub   eax, [esi].pos.z
 	mov   var_x, eax

	mov   eax, [edi].pos.x
	sub   eax, [esi].pos.x
	mov   var_y, eax

	call  GETARC

	mov   eax, angle
   	mov   [esi].vd.y, eax


	popad

	ret

ENDP


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ LOOKAT_X                                                 ±
;±----------------³----------------------------------------------------------±
;± FUNCTION:      ³ Makes that camera looks to the objetive is selected path ±
;±----------------³----------------------------------------------------------±
;±  PAREMTROS     ³ EAX: N£mero de objeto                                    ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOOKAT_X PROC

; Calculates X angle...  (Y/Z)
; ­­­  Relativo al CROT (Scalado de la rotaci¢n) !!!

	pushad

	mov   ebp, TheWorld	 		; EDI ptrs to the object
	lea   esi, [ebp].camera
	lea   edi, [ebp].objetivo


;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
; Calculates Y angle... (plane X/Z)
; X = arctan(y/z)

	mov   eax, [edi].pos.z
	sub   eax, [esi].pos.z
 	mov   var_x, eax

	mov   eax, [edi].pos.y
	sub   eax, [esi].pos.y
	mov   var_y, eax

	call  GETARC

	mov   eax, angle
   	mov   [esi].vd.x, eax


	popad
	ret

ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ LOOKAT                                                   ±
;±----------------³----------------------------------------------------------±
;± FUNCTION:      ³ Makes that camera looks to the objetive is selected path ±
;±----------------³----------------------------------------------------------±
;±  PAREMTROS     ³ EAX: N£mero de objeto                                    ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LOOKAT PROC

; Calculates X angle...  (Y/Z)
; ­­­  Relativo al CROT (Scalado de la rotaci¢n) !!!

	pushad

	mov   ebp, TheWorld	 		; EDI ptrs to the object
	lea   esi, [ebp].camera
	lea   edi, [ebp].objetivo

;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
; Calculates X angle... (plane Y/Z)
; X = arctan(y/z)

	mov   eax, [edi].pos.z
	sub   eax, [esi].pos.z
 	mov   var_x, eax

	mov   eax, [edi].pos.y
	sub   eax, [esi].pos.y
	mov   var_y, eax

	call  GETARC

	mov   eax, angle
   	mov   [esi].vd.x, eax

;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
; Calculates Y angle... (plane X/Z)
; Y = arctan(x/z)

	mov   eax, [edi].pos.z
	sub   eax, [esi].pos.z
 	@abs  eax
 	mov   var_x, eax

	mov   eax, [edi].pos.x
	sub   eax, [esi].pos.x
	mov   var_y, eax

	call  GETARC

	mov   eax, angle
   	mov   [esi].vd.y, eax

;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ

	popad
	ret


ENDP


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ GETARC                                                   ±
;±----------------³----------------------------------------------------------±
;± FUNCTION:      ³ Devuelve la arcotangente de dos puntos                   ±
;±----------------³----------------------------------------------------------±
;±  PAREMTROS     ³ EAX: N£mero de objeto                                    ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
rad2rub	dd	85445669.0
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
GETARC PROC

	cmp   var_x, 0
	je    short ga@case0

	finit 
	fild  var_y	; X
	fild  var_x	; Z
	fpatan
	fld   rad2rub
	fmul
	fistp angle

	jmp   short ga@exit

ga@case0:
	mov   angle, 64*32*UNO

ga@exit:
	ret
ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;± PROCEDIMIENTO: ³ PUTPIXTRANS                                              ±
;±----------------³----------------------------------------------------------±
;± FUNCTION:      ³ Imprime en pantalla un dibujo con un nivel de transparen ±
;±----------------³----------------------------------------------------------±
;±  PARAMETROS    ³ ESI: Puntero al coeficiente fixed de transparencia       ±
;±                ³ EDI: Puntero al bitmap                                   ±
;±                ³ ECX: Tama¤o en bytes del fichero                         ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ppt@initialized	db	-1
ppt@tcoef	dd	?
ppt@bp		db	?
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
PUTPIXTRANS PROC

	pushad

	cmp   ppt@initialized, -1
	jne   short ppt@alreadydone

	call  INITMAP
	mov   ppt@initialized, 0


ppt@alreadydone:
;ÄÄÄÄ Initializes transparency table (32*2) ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	xor   ch, ch

	mov   ebp, [esi]		; ebp = transparencia... (0-65536)
	mov   esi, light_table2		; Toma prestada esta tabla

ppt@itt01:
	xor   cl, cl

; (AX) P  <->  B (BX)
ppt@itt02:
	xor   eax, eax
	mov   al, cl
	shl   eax, 16
	imul  ebp
	cmp   dl, 0
	jge   short ppt@t2
	xor   dl, dl
ppt@t2: cmp   dl, 31
	jle   short ppt@dataok
	mov   dl, 31

ppt@dataok:
	mov   [esi], dl

	inc   esi
	inc   cl
	cmp   cl, 32
	jb    short ppt@itt02

	mov   eax, 65536
	sub   eax, ebp
	mov   ebp, eax
	inc   ch
	cmp   ch, 2
	jb    short ppt@itt01

;----------------------------------------------------------------------------
	xor   ebx, ebx
	mov   esi, light_table2
	mov   ebp, screen.vscreen
	mov   cl, 10
	mov   ch, 80
	mov   ppt@bp, 4

ppt@loop0:
	push  ebp
	add   ebp, ((320*70)+100)/4

ppt@loop1:
	mov   bl, [ebp]
	mov   al, [esi+ebx+32]
	mov   bl, [edi]
	add   al, [esi+ebx]

	mov   bl, [ebp+1]
	mov   ah, [esi+ebx+32]
	mov   bl, [edi+1]
	add   ah, [esi+ebx]
	and   ax, 1f1fh

        mov   [ebp], ax
        add   edi, 2
	add   ebp, 2
	dec   cl
	jnz   short ppt@loop1

	add   ebp, (240)/4
	mov   cl, 10
	dec   ch
	jnz   short ppt@loop1

	mov   ch, 80
        pop   ebp
	add   ebp, 19200
	dec   ppt@bp
	jnz   short ppt@loop0

	popad
	ret
ENDP

;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
ends
end
