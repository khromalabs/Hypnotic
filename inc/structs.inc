;�����������������������������������������������������������������������������
;                           ESTRUCTURAS EXOMOTION                            
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;                        1995 Khroma (AKA Rub�n G�mez)                       
;�����������������������������������������������������������������������������
  

;�����������������������������������������������������������������������������
; DEFINICIONES
;�����������������������������������������������������������������������������
  PITFREQ   equ    1234DDh      ; Frecuencia del Timer
  MAXFACES  equ    2560         ; N�mero m�ximo de caras de 1 objeto
  MAXVERT   equ    2560         ; N�mero m�ximo de v�rtices de 1 objeto
  MAXOBJ    equ    256          ; N�mero m�ximo de objetos
  MAXTEXT   equ    256          ; N�mero m�ximo de texturas
  TOTFACES  equ    2560         ; N�mero m�ximo de caras (total)
  UNO	    =	   65536	; Valor unitario en punto fixed

;�����������������������������������������������������������������������������
; FLAGS PARA LA ANIMACION
;�����������������������������������������������������������������������������
  NOLOOP    equ    0000b	; No hay repeticiones en ciclo de animaci�n
  LOOPCYCLE equ    0001b	; Ejemm...
  PINGPONG  equ    0010b	; Traslaci�n, rotaci�n & n�icator ,n�icalsarT

;�����������������������������������������������������������������������������
; TIPOS DE RENDER
;�����������������������������������������������������������������������������
  EYE       equ  100000000000b
  NOROT     equ  010000000000b
  NOSORT    equ  001000000000b
  FLARE     equ  000100000000b
  CAMROT    equ  000010000000b
  RAW	    equ  000001000000b
  TRANS     equ  000000100000b
  BLUR      equ  000000010000b
  CLIP	    equ  000000001000b
  GOURAUD   equ  000000000100b
  TEXTMAP   equ  000000000010b
  ENVMAP    equ  000000000001b

;�����������������������������������������������������������������������������
; ESTRUCTURAS
;�����������������������������������������������������������������������������
; Estructura de informaci�n del modo de v�deo  
  ScreenINFO STRUC 
    oldvideo    db      3
    xmax        dw      ?         ; L�mite DOWN-RIGHT
    ymax        dw      ?
    xtot        dw      ?         ; N�mero total de pixels
    ytot        dw      ?
    xbpn        dw      ?
    acceso      dd      ?	  ; Posici�n de inicio de la p�gina
    pagina      db	?	  ; N�mero de p�gina activada
    fctr	dd 	?         ; Contador de Frames
    vgahz   	dd	?	  ; Velocidad de la VGA (en Khz Y FIXED)

    blurtab 	dd	?	  ; Tabla para motion blur

    backgnd	db	0	  ; 1: Hay una imagen de fondo; 0: No la hay
    bgok  	db	?	  ; Indica si las pantallas se han iniciado
           	db	?
    vscreen	dd	?	  ; Pantalla virtual
    bgptr	dd	?	  ; Puntero a la imagen (si la hay)
    cls 	dd	?	  ; Coordenas temporales de intercambio
           	dd	?
    miny	dd	?	  ; 1� linea a refrescar en pantalla (P. 0&1)
           	dd	?	   
    maxy	dd	?	  ; Ultima l�nea		     (P. 0&1)
           	dd	?	   
    clscolval	db	?
  ScreenINFO ENDS
  
; Informaci�n acerca del timer  
  TimerINFO STRUC
    rcount  dw	?                  ; Contador temp. de retrazado de pantalla
    ticks   dw	?                  ; Numero de ticks por int.
    tfreq   dd	?                  ; Numero total de ticks producidos
    wsync   dw	?		   ; Indica si debemos esperar un frame
    wrt     db	?	  	   ; Flag indica el switch de una pantalla

    wfwpal  db	?		   ; Indica si hay asignaci�n de paleta en espera
    wpncol  dw	?		   ; N� de colores a escribir
    wpnini  dw	?		   ; Color inicial
    wpadd   dd	?		   ; Direcci�n del buffer

    wpr     dd	?		   ; Direcci�n del buffer
    wpg     dd	?		   ; Direcci�n del buffer
    wpb     dd	?		   ; Direcci�n del buffer
  TimerINFO ENDS

; Vector 3d
  dot3d STRUC
	x       dd      ?
	y       dd      ?
	z       dd      ?
  dot3d ENDS

; Un pixel
  dot2d STRUC
	x       dd      ?
	y       dd      ?
  dot2d ENDS

; Un pixel en la textura
  tex2d STRUC
	u       dd      ?
	v       dd      ?
  tex2d ENDS

; Vector de rotaci�n
  vrot  STRUC
	x       dd      ?
	y       dd      ?
	z       dd      ?
  vrot  ENDS

; Una matriz
  matriz STRUC
	x0      dd      ?
	x1      dd      ?
	x2      dd      ?
	y0      dd      ?
	y1      dd      ?
        y2      dd      ?
	z0      dd      ?
	z1      dd      ?
	z2      dd      ?
	xy0	dd	?
	xy1	dd	?
        xy2	dd	?
  matriz ENDS

; Un pol�gono (Definido a base de punteros)
  polyidx STRUC
	dotinx  dd      ?,?,?
	color	dw	?
	pflag	dw	?
  polyidx ENDS

; El campo de estrellas de la escena del planeta
  star	STRUC
	s_pos   dot3d   ?,?,?
	s_col1	dw	?
	s_col2	dw	?
	s_inc	dd	?
	s_speed	dw	?
	s_dir	dw	?
	s_col	dw	?
  star	ENDS


; Lista de v�rtices
  Vertx STRUC
	Point   dot3d   ?		; The point...
	Normal  dot3d   ?		; Normal to the vector...
	Map     tex2d   ?		; Texture coordinates...
	Point2  dot3d   ?		; Point Rotated
	Normal2 dot3d   ?		; Normal Rotated
	Normor  dot3d   ?		; Normal for morphing...
	Pixel   dot2d   ?		; Pixel Coordinates...
	Shade   dd	?		; Shading level...
  Vertx ENDS

  Vlist STRUC
	numdots dw      ?
	Vertex  Vertx   MAXVERT dup(?)
  Vlist ENDS

; Vertices para un morph
  Vmorph STRUC
	vmPoint   dot3d   ?		; El punto
	vmNormal  dot3d   ?		; Normal al vector
	iPoint    dot3d   ?		; Interpolaci�n para el v�rtice
	iNormal   dot3d   ?		; Interpolaci�n para la normal
  Vmorph ENDS

; Structura de Morphing
  SMorph STRUC
	numsteps dw     ?		; N�mero de mallas en el morphing
	Mntype	 dd	?		; Atributo de las normales...
	Mftime	 dd	?		; Fms * malla (Fixed)
	Mcstep	 dw	?		; Paso actual...
	Mcframe  dd	?		; Frame actual...

	numseq   dw     ?		; N�mero de puntos de la secuencia
	seqptr   dd     ?		; Puntero a la secuencia...
	objdest  dd     ?		; Puntero al objeto a renderizar..
	Sptr     dd	32 dup(?)	; Puntero a las estructuras de v�rtices
  SMorph  ENDS


; Cuerpo de un objeto, con referencia a un Vlist
  body  STRUC
	numfaces dw      ?
	face     polyidx MAXFACES dup(?)
  body  ENDS

; Lista final de punteros a las estructuras de vectores
  trpols STRUC
	numpols  dw      ?
	poly     dd	 TOTFACES dup(?)
  trpols ENDS

; Datos para la animaci�n de objetos
  dotinf STRUC
	sdot     dot3d	?		; Target point
	srot     vrot	?		; Rotation vector
  dotinf ENDS

  anidat STRUC
	aflag	 db	?		; Atributo de la animaci�n
	nsteps	 dw	?		; N� de pasos (puntos) de la animaci�n
	ftime	 dd	?		; Fms * punto (Fixed)
	pathptr  dd	?		; Ptr al path (dotinf * N� PUNTOS)

	cstep	 dw	?		; Current Step
	cframe   dd	?		;    ""   Frame
	cincr	 dot3d	?		;    ""   increment
	crot 	 dot3d	?		;    ""   Rot.
  anidat  ENDS
  
; Definici�n de un objeto  
  object STRUC
	pos     dot3d   ?
	vd      vrot    ?
	mg      matriz  ?
	adata   anidat	?
	rflag   db      ?
	fig     dd      ?		; Puntero a los datos de los pol�gonos
	lista   dd	?		; Puntero a la lista de v�rtices
  object ENDS

; Lista de punteros a cada objeto  
  world STRUC
	numobjs   dd      ?
	nummorphs dd      ?
	light     object  ?
	lightn    dot3d   ?
	lightv    dot3d   ?
	flare	  polyidx ?
	camera    object  ?
	objetivo  object  ?
	text      dd      MAXTEXT dup(?)
	obj       dd      MAXOBJ  dup(?)
	morph     dd      MAXOBJ  dup(?)
  world ENDS


  firew STRUC
        f_pos   dot3d   ?
        f_spd   dot3d   ?
        f_ispd  dd      ?
        f_count dd      ?
        f_time  dd      ?
        f_ent   dd      ?
        f_exp   dd      ?
        f_tab   dd      ?
        f_tab2  dd      ?
        f_np    dw      ?
        f_mnp   dw      ?
        f_col   dw      ?
	f_pan	dw	?
        f_rel1  db      ?
        f_rel2  db      ?
  firew ENDS


  explode STRUC
        x_pos   dot3d   ?
        x_vec   dot3d   ?
        x_dn    dd      ?
        x_col   dw      ?
        x_nada  dw      ?
  explode ENDS

  texto   STRUC
  	te_in	dw	?
	te_enc  dw	?
	te_pos	dd	?
	te_add	dd	?
  texto	  ENDS