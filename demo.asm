;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
;ฑ))))))))((((((((((()))))    H Y P N O T I C    ))))))(((((((()))))))))))())ฑ
;ฑ-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=---=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-ฑ
;ฑ                        1996 Exobit Productions                            ฑ
;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ


  .386p
  locals

;DEBUG  = 1
MUZIK  = 1

EXOLOGO   	= 1
HYPLOGO   	= 1
BUBBLE	   	= 1
PICTURE   	= 1
PLANET	   	= 1
PIVA	   	= 1
PIVADANZE  	= 1
FIREWRK       	= 1

LIGHT	 = 220
CAMERA	 = 222
OBJETIVO = 224

BURBUJAS = 12
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
;  D e f i n i c i o n e s
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
code32  segment para public use32
	 assume cs:code32, ds:code32

    include pmode.inc
    include 3deng.inc
    include structs.inc
    include file.inc
    include kb.inc
    include argc.inc
    include debug.inc

    include xmp.inc

    public fuente
    public _main
    public DemoFlag
    public EXITDEMO
    public ALEAT
    public Tflareptr
    public ACtableptr
    public spinflag
    public rrcount
    public Teyepixptr
    public EYE_path

    extrn  FIREBALL:near
    extrn  INITSTARSDATA:near
    extrn  INITFWDATA:near
    extrn  FIREWORKS:near

    extrn  TEXT_SCROLL:near
    extrn  CLSIMG:near
    extrn  timer:TimerINFO
    extrn  screen:ScreenINFO
    extrn  direct:byte, tm@dirflag:byte
    extrn  paleton:dword
; Factor de oscuridad en el Motion Blur
    extrn  darkness:dword


    extrn  handle:byte
    extrn  initbuf:byte

    extrn  size_X:dword
    extrn  size_Y:dword


;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
;  D a t o s
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
; Datos 3D
align 4
include path.inc


oldhimembase	dd   ?
oldlomembase	dd   ?
palnul		dd   ?

EYE_path	dd   ?

; Paletas...
;exologo     	db	"inc\presents.col", 0
;hyplogo	db	"inc\hyplogo.col", 0
;skypal      	db	"inc\burbuja.col", 0
;picture	db	"inc\thebests.col", 0
;planetpal   	db	"inc\planeta.col", 0
;piva		db	"inc\piva.col", 0
;piva2		db	"inc\piva2.col", 0
;piva3		db	"inc\piva32.col", 0
;pa_file	db	"fworks1.col",0
;fu_file	db	"fuente.bin",0

rotpal		db	?


exologoptr	dd	?
hyplogoptr	dd	?
skypalptr	dd	?

currotpal  	dd	?
pictureptr	dd	?
planetpalptr	dd	?
pivaptr		dd	?
piva2ptr	dd	?
piva2aptr	dd	?
piva3ptr	dd	?
piva3aptr	dd	?
piva3bptr	dd	?
piva3cptr	dd	?
piva3dptr	dd	?
fuente          dd      ?

; Mensajes del programa
ENDmsg      db    "HYPNOTIC 1996-97 Copyright (c) EXOBIT", 13,10, "FINAL VERSION! CU in our next demo! ;-)",13,10, "$"
pmodetypes  db    "RAW $", "XMS $", "VCPI$", "DPMI??",13,10,"$"
mode_msg    db    13,10, " ๐ PMODE type: $"
lomem_msg   db    13,10, " þ Free low memory: $"
himem_msg   db    13,10, " þ Free extended memory: $"


novga_msg   db    13,10, "No VGA detected!", 13,10, "$"
nomem_msg   db    13,10, "Insuficient memory!", 13,10, "$"
noshp_msg00 db    13,10, "Data file not found!", 13,10, "$"
noshp_msg01 db    13,10, "Can't read the shape!", 13,10, "$"
noshp_msg03 db    13,10, "The file isn't a valid file!", 13,10, "$"
noshp_msg04 db    13,10, "Unknown error reading file!!!", 13,10, "$"
nocopro_msg db    13,10, "Math coprocesor not detected!", 13,10, "$"

DPMImsg     db    13,10, "Hey man, did you really think that this kind of stuff"
	    db    13,10, "will work under this shit? :->", 13,10
	    db    13,10, "Try it again in a DOS sesion, please ;)", 13,10, "$"

; Player msgs...
msg01	db 13,10,' þ XMP: Initializing instruments...$'
msgx03  db ' þ XMP: detecting soundcard...',13,10,'$'
msgx04	db '     Unable to detect variables, manual sound setup...',13,10,'$'
msgx10	db '     File is not a XM!',13,10,'$'
msgx11	db '     Not enough memory!',13,10,'$'
msgx12	db '     Too many channels!',13,10,'$'
msgx20	db '     Soundcard not found!',13,10,'$'
msgx21	db 13,10,'     Warning: Not enough wavetable mem!',13,10,'$'
msgxF0	db '     Unknown error!',13,10,'$'
msgs00  db '     No soundcard',13,10,'$'
msgs10  db '   o Gravis GF1',13,10,'$'
msgs11  db '   o AMD Interwave',13,10,'$'
msgs20  db '   o EMU8000',13,10,'$'
msgs80  db '   o Soundblaster',13,10,'$'
msgs81  db '   o Soundblaster Pro',13,10,'$'
msgs82  db '   o Soundblaster 16',13,10,'$'
msgs90  db '   o PAS 16',13,10,'$'
msgsA0  db '   o Gravis GF1 (soft. mixing)',13,10,'$'
msgsB0  db '   o Crystal codec',13,10,'$'
msgd1         db '        port: $'
msgd2   db 13,10,'         irq: $'
msgd3   db 13,10,'         dma: $'
msgd4   db 13,10,'     waveram: $'



; Setup data
soundmsg    db    13,10, "Sound:"
	    db    13,10, "   1)   GUS"
	    db    13,10, "   2)   GUS Plug'n'Play"
	    db    13,10, "   3)   Sound Blaster"
	    db    13,10, "   4)   No sound"
            db    13,10, "   Esc) Cancel", "$"
getprtmsg   db    13,10, "Select the baseport:"
	    db    13,10, "   1)   210h"
	    db    13,10, "   2)   220h"
	    db    13,10, "   3)   230h"
	    db    13,10, "   4)   240h"
	    db    13,10, "   5)   250h"
	    db    13,10, "   6)   260h"
            db    13,10, "   Esc) Cancel", "$"
getirqmsg   db    13,10, "Select the Irq:"
	    db    13,10, "   1)   1"
	    db    13,10, "   2)   3"
	    db    13,10, "   3)   5"
	    db    13,10, "   4)   7"
	    db    13,10, "   5)   11"
	    db    13,10, "   6)   12"
	    db    13,10, "   7)   15"
            db    13,10, "   Esc) Cancel", "$"
getdmamsg   db    13,10, "Select the Dma:"
	    db    13,10, "   1)   1"
	    db    13,10, "   2)   3"
	    db    13,10, "   3)   5"
	    db    13,10, "   4)   6"
	    db    13,10, "   5)   7"
            db    13,10, "   Esc) Cancel", "$"

cursor      db    13,10, ">", "$"
enter       db    13,10, '$'
Muzik       db    0

exomot_msg  db    13,10, " þ EXOMOTION: Initializing data...$"
press_msg   db    13,10, "Press a key...",13,10,"$"

ifdef DEBUG
npolys_msg  db    13,10, " þ Number of polys: $"
nverts_msg  db    13,10, " þ Number of verts: $"
tottime     db	  13,10, "Total secs:   $"
totframe    db	  13,10, "Total frames: $"
fmsxs	    db	  13,10, "Frames/sec:   $"
cardspeed   db	  13,10, "VGA Hz:       $"
endif

; Datos de los ficheros

; Para volver a usar la base quitar el comment
; y comentar los nombres de los ficheros
;
; - Revisar la carga del mod !
; - LOADPICTURE !
; - LOADOBJECT !
;comment 
; ออออออ  BASE DE DATOS อออออออออออออออ
exologo:
hyplogo:
skypal:
picture:
planetpal:
piva:
piva2:
piva3:
xm_file:
FExologo:
ACtable:
Fpicture:
Thyp1:
Thyp2:
Thyp3:
Teyemask:
Fsky:
Tsky:
Tsky2:
Tcasa:
Ttree:
Tsue12:
Tsue34:
Tmisc:
Tpiva12:
Tpiva34:
Tpiva56:
Tpiva78:
Tpivaf:
Sburbu:
Shyplog:
Shypeye:
Smale:
Smorsmile:
Sdevsmile:
Speace:
Sfemale:
S3dmotion:
Smuznplay:
Sart:
Skhroma:
Smentat:
Sartqvo:
Splanet:
Spiva:
database:
pa_file:
fu_file:
Teyepix:
 db	  "hypnotic.dat",0
;
;ออออออออออออออออออออออออออออออออออออออ


; Flags de la scena de las burbujas
align 4
fade	    db		?
seq	    db		?
peace	    db		?
male	    db		?
female	    db		?
morsmile    db		?
devsmile    db		?
code	    db		?
art	    db		?
music	    db		?
khroma	    db		?
artqvo	    db		?
mentat	    db		?
mentat2	    db		?
bubbletime  db		?
bubbletemp  db		?


Cseq   	    db		?
Lseq	    db		?

;Flags para el planeta
rot2flag    db		?

; Flag para el ojo de la escena del logo
eye	    db		?
eyepixpath  db		?

; Canciขn
;xm_file  db "temp\hyp2.xm",0

; Mapa de presentaciขn...
;ACtable      db	  "temp\pepe.dat",0
ACtableptr   dd	   ?

; Mapa de presentaciขn...
;FExologo    db	  "temp\presents.dat",0
FExologoptr dd	   ?

; Dibujo
;Fpicture    db	  "temp\thebests.dat",0
Fpictureptr dd	   ?

; Mapa de logo con Motion Blur... + ojo
;Thyp1       db	  "temp\env-hypc.dat",0
Thyp1ptr    dd	   ?
;Thyp2       db	  "temp\env-hypn.dat",0
Thyp2ptr    dd	   ?
Thyp3ptr    dd	   ?

;Teyemask    db	  "temp\mask.dat",0
Teyemaskptr dd	   ?

;Teyepix     db	  "temp\eye1.dat",0
Teyepixptr  dd	   ?

; Mapas de la escena de cielo
;Fsky	    db	  "temp\sky.dat",0
Fskyptr     dd	   ?
;Tsky	    db	  "temp\skymap.dat",0
Tskyptr     dd	   ?
;Tsky2	    db	  "temp\skymap2.dat",0
Tskyptr2    dd	   ?


; Mapas de la escena del mundo
;Tcasa	    db	  "temp\pl-house.dat",0
Tcasaptr    dd	   ?	; Casa
Ttechoptr   dd	   ?	; Techo
;Ttree	    db	  "temp\pl-tree.dat",0
Ttreeptr    dd	   ?	; Madera
Tarbolptr   dd	   ?	; Arbol
;Tsue12	    db	  "temp\pl-sue12.dat",0
Tsue1ptr    dd	   ?	; Suelo 1
Tsue2ptr    dd	   ?	; Suelo 2
;Tsue34	    db	  "temp\pl-sue34.dat",0
Tsue3ptr    dd	   ?	; Suelo 3
Tsue4ptr    dd	   ?	; Suelo 4
;Tmisc       db	  "temp\pl-misc.dat",0
Tcaminoptr  dd	   ?	; Camino
Tflareptr   dd	   ?	; Flare


; Mapas de la escena de la piva tia buena
;Tpiva12  db	  "temp\pv-head.dat",0
Tpiva1ptr dd	   ?	; Cara
Tpiva2ptr dd	   ?	; Pelo

;Tpiva34   db	  "temp\pv-tits.dat",0
Tpiva3ptr dd	   ?	; Short
Tpiva4ptr dd	   ?	; Espalda

;Tpiva56   db	  "temp\pv-butt.dat",0
Tpiva5ptr dd	   ?	; Pelvis & otras hierbas...
Tpiva6ptr dd	   ?	; Culo

;Tpiva78   db	  "temp\pv-misc.dat",0
Tpiva7ptr dd	   ?	; Piel
Tpiva8ptr dd	   ?	; Botas

;Tpivaf    db	  "temp\spiral.dat",0
Tpivafptr dd	   ?    ; Fondo en spiral...

spinflag  db	   ?

; M E S H E S
; อออออออออออ

;Shyplog   db "temp\hypnlog.shp",0
Nhyplog   db	?

;Shypeye   db "temp\hypneye.shp",0
Nhypeye   db	?

; Objeto Dummy utilizado para el mapa del ojo
Neyepix	  db	?

;Sburbu	  db "temp\burbu.shp",0
Nburbu	  db	BURBUJAS dup(?)
Mburbu	  db	BURBUJAS dup(?)

;Smale	  db "temp\male.shp",0
Nmale	  db	?

;Smorsmile db "temp\morsmiley.shp",0
Nmorsmile db	?
Mmorsmile db	?

;Sdevsmile db "temp\devsmiley.shp",0
Ndevsmile db	?

;Speace    db "temp\peace.shp",0
Npeace	  db	?

;Sfemale   db "temp\female.shp",0
Nfemale	  db	?

;S3dmotion db "temp\3dmotion.shp", 0
N3dmotion db	?

;Smuznplay db "temp\muznplay.shp",0
Nmuznplay db	?

;Sart      db "temp\art.shp",0
Nart	  db	?

;Skhroma   db "temp\khroma.shp", 0
Nkhroma	  db	?

;Smentat   db "temp\mentat.shp", 0
Nmentat	  db	?

;Sartqvo   db "temp\artqvo.shp", 0
Nartqvo	  db	?

;Splanet   db "temp\planet.shp",0
Nplanet	  db	?

;Spiva	  db "temp\piva.shp",0
Npiva	  db	?
Mpiva	  db	?


rrcount	  db	?
DemoFlag  db	?


vRtype    dw	?

;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
;  C ข d i g o
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
 _main:
	sti

; Presenta informaciขn acerca del sistema
	mov  DemoFlag, 0
	call _initkb

	@print mode_msg
	xor  eax, eax
	mov  al, _sysbyte0
	and  al, 3
	@print pmodetypes[eax+eax*4]
	cmp  al, 3
	jne  short testmem
	@print DPMImsg
	jmp  Dexit

testmem:
	call _lomemsize
	@printmd lomem_msg, eax
	mov  ebx, eax 
	call _himemsize
	@printmd himem_msg, eax
	@print enter

; Memoria requerida para la ejecuciขn de la demo...
	add  ebx, eax
	cmp  ebx, 3014656+495600
	jl   E_nomem

; Sitฃa el bufer en memoria baja (Por si las moscas)
	movzx eax, _filebuflen
	call  _getlomem
	jc    E_nomem
	mov   _filebufloc, eax


; Abre el archivo de datos
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	mov edx, offset database        ; Could the file be opened?
	call _openfile
	jc   print00                ; No -> jump to noopen
	mov  ax, v86r_bx
	mov  handle, al
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

	call TESTCOPRO
	test al, al
	jnz  E_nocop

; XMP initialization
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
ifndef MUZIK
  	jmp  NoMuzik
endif


; Mentat metiข mano el th 11 jul, 8:46 pm
; Mentat es un pelกn guarrillo l... (Khroma's appointment)
	@print msgx03
	call _XMP_Detect

	cmp  xmp_devtype, 0
	jne  detected

	@print msgx04

	call GETDATAGUS
	cmp  Muzik, 0
	je   NoMuzik
	jmp  MuzikRulez

detected:
	mov  Muzik, 1
        mov al, xmp_devtype
        cmp al, 10h
        je t10
        cmp al, 11h
        je t11
        cmp al, 20h
        je t20
        cmp al, 80h
        je t80
        cmp al, 81h
        je t81
        cmp al, 82h
        je t82
        cmp al, 90h
        je t90
        cmp al, 0A0h
        je tA0
        cmp al, 0B0h
        je tB0
        @print msgs00
        jmp spec

t10:    @print msgs10
        jmp spec
t11:    @print msgs11
        jmp spec
t20:    @print msgs20
        jmp spec
t80:    @print msgs80
        jmp spec
t81:    @print msgs81
        jmp spec
t82:    @print msgs82
        jmp spec
t90:    @print msgs90
        jmp spec
tA0:    @print msgsA0
        jmp spec
tB0:    @print msgsB0
        jmp spec

spec:
        movzx eax, xmp_devport
        @printmh msgd1, eax
        movzx eax, xmp_devirq1
        @printmd msgd2, eax
        movzx eax, xmp_devdma1
        @printmd msgd3, eax
        mov   eax, xmp_devmem
        @printmd msgd4, eax

	cmp   xmp_devtype, 80h
	je    short MuzikRulez

	cmp   xmp_devmem, 512*1024
	jge   short MuzikRulez
	@print msgx21
	@print press_msg
	call  _getch


MuzikRulez:
	call _XMP_Init

	test al, al
	jnz @xmperror
	@print msg01


; ฤฤ XM Reading Stuff ฤฤฤฤฤฤฤ
	mov edx, offset xm_file	        ; Could the file be opened?
	call _openfile	    
	jc   print00                    ; No -> jump to noopen

	call _filesize                  ; Once opened we've to obtain the size
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	mov  eax, 2098146+6400
	xor  bl,bl
	call _lseekfile
	mov eax, 614349
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	mov ebp, eax                    ; and store it in EBP to
	push _himembase
	call _gethimem                  ; allocate memory (high or low)
	pop  _himembase
	jc E_nomem                      ; Not enough -> jump to nomem

        mov edi, eax                    ; Save in EDI the file address
	mov edx, eax                    ; also in EDX
	mov ecx, ebp                    ; Store size in ECX

	push edi
	call _readfile                  ; Load whole file to mem
	pop edi
	jc noread                       ; If any error jump to noread

	call _closefile                 ; Close the file
; ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

	xor al, al
	call _XMP_Load

	test al, al
	jnz @xmperror

;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
NoMuzik:

; Inicia la animaciขn...
	@print exomot_msg

; ฤฤDatabase stuffฤฤฤฤฤฤฤฤฤฤฤ
	movzx ax, handle
	mov  v86r_bx, ax
	xor  eax, eax
	xor  bx, bx
	call _lseekfile
; ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

;อ PASO 1: LEER TODOS LOS OBJETOS EN MEMORIA ออออออออออออออออออออออออออออออออ
	mov  eax, _himembase
	mov  oldhimembase, eax
	mov  eax, _lomembase
	mov  oldlomembase, eax

        xor   eax, eax

; PUฅETERO BUG!!! จpor qu cojones ocurre esto? r:'-? :'(((
	mov   edx, offset Sburbu
	mov   ecx, 2648
        mov   al, 0
	call  LOADOBJECT
	jc    E_noshp

	xor   ecx, ecx
Burbloop:

	push  ecx
; ฤฤDatabase stuffฤฤฤฤฤฤฤฤฤฤฤ
	movzx ax, handle
	mov  v86r_bx, ax
	xor  eax, eax
	xor  bl, bl
	call _lseekfile
; ฤฤDatabase stuffฤฤฤฤฤฤฤฤฤฤฤ

	mov   ecx, 2648
	mov   edx, offset Sburbu
        mov   al, 0
	call  LOADOBJECT
	jc    E_noshp
	pop   ecx

	mov   Nburbu[ecx], al
	mov   Mburbu[ecx], bl

	inc   ecx
	cmp   ecx, BURBUJAS
	jb    short Burbloop


; ฤฤDatabase stuffฤฤฤฤฤฤฤฤฤฤฤ
	movzx ax, handle
	mov  v86r_bx, ax
	xor  eax, eax
	xor  bl, bl
	call _lseekfile
; ฤฤDatabase stuffฤฤฤฤฤฤฤฤฤฤฤ

; Dummy object for the eye scene
	mov   edx, offset Sburbu
	mov   ecx, 2648
        mov   al, 0
	call  LOADOBJECT
	jc    E_noshp
	mov   Neyepix, al
	movzx eax, al
	mov   edi, TheWorld
	mov   eax, [edi].obj[eax*4]
	mov   EYE_path, eax

	mov   edx, offset S3dmotion
	mov   ecx, 8376
        mov   al, 0
	call  LOADOBJECT
	jc    E_noshp
	mov   N3dmotion, al

	mov   edx, offset Sart
	mov   ecx, 3480
        mov   al, 0
	call  LOADOBJECT
	jc    E_noshp
	mov   Nart, al

	mov   edx, offset Smuznplay
	mov   ecx, 12552
        mov   al, 0
	call  LOADOBJECT
	jc    E_noshp
	mov   Nmuznplay, al

	mov   edx, offset Skhroma
	mov   ecx, 6312
        mov   al, 0
	call  LOADOBJECT
	jc    E_noshp
	mov   Nkhroma, al

	mov   edx, offset Sartqvo
	mov   ecx, 6296
        mov   al, 0
	call  LOADOBJECT
	jc    E_noshp
	mov   Nartqvo, al

	mov   edx, offset Smentat
	mov   ecx, 5768
        mov   al, 0
	call  LOADOBJECT
	jc    E_noshp
	mov   Nmentat, al

	mov   edx, offset Sdevsmile
	mov   ecx, 9248
        mov   al, 0
	call  LOADOBJECT
	jc    E_noshp
	mov   Ndevsmile, al

	mov   edx, offset Smorsmile
	mov   ecx, 4104
        mov   al, 0
	call  LOADOBJECT
	jc    E_noshp
	mov   Nmorsmile, al
	mov   Mmorsmile, bl

	mov   edx, offset Smale
	mov   ecx, 7880
        mov   al, 0
	call  LOADOBJECT
	jc    E_noshp
	mov   Nmale, al

	mov   edx, offset Sfemale
	mov   ecx, 5672
        mov   al, 0
	call  LOADOBJECT
	jc    E_noshp
	mov   Nfemale, al

	mov   edx, offset Shyplog
	mov   ecx, 21144
        mov   al, 0
	call  LOADOBJECT
	jc    E_noshp
	mov   Nhyplog, al

	mov   edx, offset Shypeye
	mov   ecx, 5416
        mov   al, 0
	call  LOADOBJECT
	jc    E_noshp
	mov   Nhypeye, al

	mov   edx, offset Speace
	mov   ecx, 6344
        mov   al, 0
	call  LOADOBJECT
	jc    E_noshp
	mov   Npeace, al

;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

;อ PASO 2: LEER TODOS LOS MAPAS EN MEMORIA ออออออออออออออออออออออออออออออออออ
;------------- Inicio -------------------------------------------------------
	lea   edx, Thyp1
	mov   ecx, 65536
	call  LOADPICTURE
	jc    E_nomem
	mov   Thyp1ptr, eax

	lea   edx, Thyp2
	mov   ecx, 65536
	call  LOADPICTURE
	jc    E_nomem
	mov   Thyp2ptr, eax


; Copia manual de los datos...
	mov   esi, eax
	mov   eax, 65536
	mov   ecx, eax
	shr   ecx, 2
	call  _gethimem
	mov   edi, eax
	mov   Thyp3ptr, eax
	rep   movsd

; Incrementa los valores de la textura (para el ojo)
	mov   ecx, 65536
	mov   edi, Thyp3ptr
m@loop: add   byte ptr [edi], 32
	inc   edi
	dec   ecx
	jnz   short m@loop

	lea   edx, Teyemask
	mov   ecx, 76800
	call  LOADPICTURE
	jc    E_nomem
	mov   Teyemaskptr, eax

	lea   edx, FExologo
	mov   ecx, 76800
	call  LOADPICTURE
	jc    E_nomem
	mov   FExologoptr, eax
	mov   edi, eax
	mov   ecx, 320*240
	call  INITMAP
	jc    E_nomem

;- Cielo -----------------------
	lea   edx, Fsky
	mov   ecx, 76800
	call  LOADPICTURE
	jc    E_nomem
	mov   Fskyptr, eax
	mov   edi, eax
	mov   ecx, 320*240
	call  INITMAP
	jc    E_nomem

	lea   edx, Tsky
	mov   ecx, 65536
	call  LOADPICTURE
	jc    E_nomem
	mov   Tskyptr, eax

	lea   edx, Tsky2
	mov   ecx, 65536
	call  LOADPICTURE
	jc    E_nomem
	mov   Tskyptr2, eax

	lea   edx, Fpicture
	mov   ecx, 76800
	call  LOADPICTURE
	jc    E_nomem
	mov   Fpictureptr, eax
	mov   edi, eax
	mov   ecx, 320*240
	call  INITMAP
	jc    E_nomem

; Paletas...
	lea   edx, exologo
	mov   ecx, 768
	call  LOADPICTURE
	jc    E_nomem
	mov   exologoptr, eax

	lea   edx, hyplogo
	mov   ecx, 768
	call  LOADPICTURE
	jc    E_nomem
	mov   hyplogoptr, eax

	lea   edx, skypal
	mov   ecx, 768
	call  LOADPICTURE
	jc    E_nomem
	mov   skypalptr, eax

	lea   edx, picture
	mov   ecx, 768
	call  LOADPICTURE
	jc    E_nomem
	mov   pictureptr, eax

	lea   edx, Teyepix
	mov   ecx, 6400
	call  LOADPICTURE
	jc    E_nomem
	mov   Teyepixptr, eax


;----------------------------------------------------
; Inicia la maskara usada para el dual-motion blur
	mov   edi, Teyemaskptr
	mov   ecx, 76800
	call  INITMAP
	jc    EXITDEMO

; Inicia los datos de la c mara, luz, y objetivo
	mov   edi, TheWorld
	lea   eax, [edi].light
	mov   [edi].obj[LIGHT*4], eax
	lea   eax, [edi].camera
	mov   [edi].obj[CAMERA*4], eax
	lea   eax, [edi].objetivo
	mov   [edi].obj[OBJETIVO*4], eax
;----------------------------------------------------
;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
ifdef  DEBUG
	call _lomemsize
	@printmd lomem_msg, eax
	call _himemsize
	@printmd himem_msg, eax
	@print enter
	@print press_msg
	call _getch

endif
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ


 ;Inicia la paleta
@palini:mov   eax, 768
        call  _getmem
        jc    E_nomem

        mov   palnul, eax

; Inicia el sistema
	call  TESTVGA
	jc    E_novga

 	mov   edi, palnul
	mov   ecx, 768/4
	xor   eax, eax
	rep   stosd

	call  SET320240
	call  INITTIMER

	mov   edi, palnul
	mov   al, 0
	mov   cx, 256
	call  SETPAL

	cmp   Muzik, 0
	je    short Muzik1


;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	call  _XMP_Play
	test  al, al
	jnz   @xmperror

Muzik1:
	mov   DemoFlag, 1

ifdef EXOLOGO
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ  PANTALLA DE PRESENTACION ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
	mov   xmp_flag, 0

	mov   edi, FExologoptr
	mov   al, 1
	call  SETBACKGND

	call  CLSIMG
	call  IMAGEN
	call  CLSIMG

	mov   timer.rcount, 0
	mov   xmp_flag, 0
; -- Wait -----------------------------
 	mov   ax, 1
 	call  WAITTIME
; -- Wait -----------------------------

; -- Exobit ---------------------
	mov   edi, exologoptr
	xor   eax, eax
	mov   ecx, (3*UNO)
	mov   bl, FADEIN
	mov   dl,0
	mov   bp, 64
	call  FADEINIT

p@finloop:
	call  IMAGEN
	xor   ebx, ebx
	mov   bx, timer.rcount
	call  FADETRACE
	jc    short p@efinloop
	sub   timer.rcount, bx
	jmp   short p@finloop
; -- Exobit ---------------------
p@efinloop:

; -- Wait -----------------------------
 	mov   ax, 1
 	call  WAITTIME
; -- Wait -----------------------------

; --- Presents ------------------------
	mov   edi, exologoptr
	xor   eax, eax
	mov   ecx, (2*UNO) - 32728
	mov   bl, FADEIN
	mov   dl,64
	mov   bp, 64
	call  FADEINIT

p@finloop2:
	call  IMAGEN
	xor   ebx, ebx
	mov   bx, timer.rcount
	call  FADETRACE
	jc    short p@efinloop2
	sub   timer.rcount, bx
	jmp   short p@finloop2
; --- Presents ------------------------
p@efinloop2:


; -- Wait -----------------------------
 	mov   ax, 1
 	call  WAITSONG
; -- Wait -----------------------------

	mov   timer.rcount, 0
; --- Hit 1 ---------------------------
	mov   esi, exologoptr
	mov   edi, esi
	add   esi, 128*3
	xor   eax, eax
	mov   ecx, 1*UNO+10000
	mov   bl, FADEMORPH
	xor   dl, dl
	xor   bp, 128
	call  FADEINIT

p@finlooph1:
	call  IMAGEN
	xor   ebx, ebx
	mov   bx, timer.rcount
	call  FADETRACE
	jc    short p@efinlooph1
	sub   timer.rcount, bx
	jmp   short p@finlooph1
; --- Hit 1 ---------------------------
p@efinlooph1:

; -- Wait -----------------------------
 	mov   ax, 2
 	call  WAITTIME
; -- Wait -----------------------------

	mov   timer.rcount, 0
; --- Off -----------------------------
	mov   edi, exologoptr
	xor   eax, eax
	mov   ecx, 2*UNO
	mov   bl, FADEOUT
	mov   dl, 0
	mov   bp, 128
	call  FADEINIT

p@foutloop:
	call  IMAGEN
	xor   ebx, ebx
	mov   bx, timer.rcount
	call  FADETRACE
	jc    short p@efoutloop
	sub   timer.rcount, bx
	jmp   short p@foutloop
; --- Off -----------------------------
p@efoutloop:

;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
endif

ifdef HYPLOGO
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;ฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐ MOTION BLUR ฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐ
	mov   vRtype, BLUR OR ENVMAP

	mov   eye, 0
	mov   fade, 0
	mov   eyepixpath, 0
	mov   darkness, 15000

	mov   edi, TheWorld
	lea   eax, [edi].camera
	mov   [eax].x, -15*UNO
	mov   [eax].y, -15*UNO
	mov   [eax].z, -500*UNO

	mov   edi, Thyp1ptr
	xor   al, al
        call  INITTEXT

	mov   edi, Thyp2ptr
	mov   al, 1
        call  INITTEXT

	mov   edi, Thyp3ptr
	mov   al, 2
	call  INITTEXT

	mov   al, 0
	call  SETBACKGND

	mov   ebx, 13
	mov   ecx, 26
	lea   edx, hyppat
	movzx ebp, Nhyplog
	call  INITPATH

	mov   al, 1
	mov   bl, Nhyplog
	call  SETRFLAG

	call  CLS
	call  IMAGEN

	mov   edi, hyplogoptr
	mov   cx, 32
	mov   al, 0
	call  SETPAL

	sub   screen.ymax, 1

	mov   timer.tfreq, 0
	mov   screen.fctr, 0
	mov   timer.rcount, 0
	mov   seq, 0
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
@pathl2:
	movzx ebx, timer.rcount
	mov   rrcount, bl
	mov   timer.rcount, 0

	mov   ax, vRtype
	call  RENDER
	call  IMAGEN

	movzx ebp, Nhyplog
	call  TRACEPATH
	jc    Ehyplogo

eye@Xtep:
	cmp   eye, 1
	jne   short @patheye
	movzx ebx, rrcount
	movzx ebp, Nhypeye
	call  TRACEPATH
	jnc   short @patheye
	mov   eye, 0

@patheye:
	cmp   eyepixpath, 1
	jne   short @pathlfade
	movzx ebx, rrcount
	movzx ebp, Neyepix
	call  TRACEPATH
	jnc   short @pathlfade
  
        mov   eyepixpath, 0

@pathlfade:
	cmp   fade, 1
	jne   short @pathloop
	movzx ebx, rrcount
	call  FADETRACE
	jnc   short @pathloop
	mov   fade, 0

@pathloop:
	cmp   xmp_flag, 2
	je    Ehyplogoflash

@pathlend:
	jmp   @pathl2
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
Ehyplogo:

	inc   seq
	cmp   seq, 1
	je    Ehyplogoeye1
	cmp   seq, 2
	je    Ehyplogoroll
	cmp   seq, 3
	je    Ehyplogofade
	jmp   Ehyplogoexit


; Se coloca la maskara y el ojo  en pantalla
Ehyplogoeye1:
	mov   esi, Teyemaskptr
	mov   edi, screen.vscreen
	mov   ecx, 19200
	rep   movsd

	mov   ax, BLUR OR ENVMAP
	call  RENDER

	mov   ebx, 1
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	mov   ecx, 3
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	lea   edx, hyppat2
	movzx ebp, Nhyplog
	call  INITPATH

	mov   ebx, 1
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	mov   ecx, 16
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	lea   edx, hyppat5
	movzx ebp, Nhypeye
	call  INITPATH
	mov   eye, 1

	mov   al, 1
	mov   bl, Nhypeye
	call  SETRFLAG

	mov   edi, hyplogoptr
	xor   eax, eax
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	mov   ecx, 2*UNO
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	mov   bl, FADEIN
	mov   dl, 32
	mov   bp, 32
	call  FADEINIT
	mov   fade, 1

	jmp   eye@Xtep

Ehyplogoroll:
	mov   ebx, 5
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	mov   ecx, 18
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	lea   edx, hyppat3
	movzx ebp, Nhyplog
	call  INITPATH
	mov   darkness, 6000

	jmp   eye@Xtep


; Aparece el ojo y fade al cielo
Ehyplogofade:
	mov   edi, hyplogoptr
	mov   ax, 36
	shl   eax, 16
	mov   ah, 50
	mov   al, 51
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	mov   ecx, (5*UNO) ;+ 16364
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	mov   bl, FADEOUT
	mov   bp, 64
	mov   dl, 0
	call  FADEINIT
	mov   fade, 1

	mov   ebx, 2
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	mov   ecx, 15
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	lea   edx, hyppat6
	movzx ebp, Neyepix
	call  INITPATH

	mov   ebx, 2
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	mov   ecx, 5
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	lea   edx, hyppat4
	movzx ebp, Nhyplog
	call  INITPATH


	mov   darkness, 50 
	mov   eyepixpath, 1
	mov   vRtype, BLUR OR ENVMAP OR EYE

	jmp   eye@Xtep


Ehyplogoflash:
	mov   xmp_flag, 0
	mov   edi, hyplogoptr
	mov   eax, 3f3f3fh
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	mov   ecx, UNO
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	mov   bl, FADEIN
	mov   dl, 0
	mov   bp, 64
	call  FADEINIT
	mov   fade, 1
	jmp   @pathlend

Ehyplogoexit:
	mov   al, 0
	mov   bl, Nhyplog
	call  SETRFLAG

	mov   al, 0
	mov   bl, Nhypeye
	call  SETRFLAG


	mov   ax, 1
	call  WAITSONG

	add   screen.ymax, 1


;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
endif


ifdef BUBBLE
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ  ESCENA DE LAS BURBUJAS ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
 RTYPE = ENVMAP OR TRANS


	sub   screen.ymax, 1

; Flags de la scena
	mov   fade, 0
	mov   seq, 0
	mov   peace, 0
	mov   male, 0
	mov   female, 0
	mov   devsmile, 0
	mov   morsmile, 0
	mov   code, 0
	mov   art, 0
	mov   music, 0
	mov   khroma, 0
	mov   artqvo, 0
	mov   mentat, 0
	mov   mentat2, 0
	mov   bubbletime, 5


	mov   edi, TheWorld
	lea   eax, [edi].camera
	mov   [eax].x, 0*UNO
	mov   [eax].y, 0*UNO
	mov   [eax].z, -8000*UNO

	mov   edi, Tskyptr
	xor   al, al
        call  INITTEXT
	mov   edi, Tskyptr2
	mov   al, 1
        call  INITTEXT


	mov   edi, Fskyptr
	mov   al, 1
	call  SETBACKGND

        xor   esi, esi
	xor   edi, edi


burpl:  mov   ax, 2
	call  ALEAT
	shl   eax, 15
	mov   bur1[edi].x, eax
	mov   bur1[edi+(size dot3d*2)].x, eax

	mov   ax, 2
	call  ALEAT
	shl   eax, 15
	mov   bur1[edi].z, eax
	mov   bur1[edi+(size dot3d*2)].z, eax

	test  esi, esi
	jz    noalea
	mov   ax, 13
	call  ALEAT
	add   eax, 8
	mov   ecx, eax
	jmp   inipath

noalea:	mov   ecx, 8


inipath:xor   eax, eax
        mov   ebx, 1
        lea   edx, bur1[edi]
        movzx ebp, Nburbu[esi]
        call  INITPATH

b@kaka1:
	xor   ax, ax
	call  ALEAT
	movzx ecx, ax
	shl   ecx, 5
	cmp   ecx, 15*UNO
	jbe   short b@kaka1
	mov   ebx, 50
	movzx eax, Mburbu[esi]
	lea   edx, burseq1
	call  INITMORPH

	mov   al, 1
	mov   bl, Nburbu[esi]
	call  SETRFLAG

	inc   esi
	add   edi, (size dot3d)*4

	cmp   esi, BURBUJAS
	jb    burpl
;-----------------------------------------------

	xor   eax, eax
	mov   ebx, 1
	mov   ecx, 9
	lea   edx, Ppeace
	movzx ebp, Npeace
	call  INITPATH


	xor   eax, eax
	mov   ebx, 2
	mov   ecx, 11
	lea   edx, Pdevsmile
	movzx ebp, Ndevsmile
	call  INITPATH

	xor   eax, eax
	mov   ebx, 1
	mov   ecx, 11
	lea   edx, Pmorsmile
	movzx ebp, Nmorsmile
	call  INITPATH
	mov   ebx, 11
	mov   ecx, 11*UNO
	lea   edx, smlseq
	movzx eax, Mmorsmile
	call  INITMORPH


	xor   eax, eax
	mov   ebx, 7
 	mov   ecx, 15
	lea   edx, Pmale
	movzx ebp, Nmale
	call  INITPATH

	xor   eax, eax
	mov   ebx, 7
	mov   ecx, 15
	lea   edx, Pfemale
	movzx ebp, Nfemale
	call  INITPATH

	xor   eax, eax
	mov   ebx, 3
	mov   ecx, 10
	lea   edx, Pdo
	movzx ebp, N3dmotion
	call  INITPATH

	xor   eax, eax
	mov   ebx, 3
	mov   ecx, 10
	lea   edx, Pdo
	movzx ebp, Nmuznplay
	call  INITPATH

	xor   eax, eax
	mov   ebx, 3
  	mov   ecx, 12
	lea   edx, Pdo
	movzx ebp, Nart
	call  INITPATH

	xor   eax, eax
        mov   ebx, 3
	mov   ecx, 12
	lea   edx, Pname
	movzx ebp, Nkhroma
	call  INITPATH

;	xor   eax, eax
;	mov   ebx, 3
;	mov   ecx, 12
;	lea   edx, Pname ;2
;	movzx ebp, Nmentat
;	call  INITPATH

	xor   eax, eax
	mov   ebx, 3
 	mov   ecx, 12
	lea   edx, Pname ;3
	movzx ebp, Nartqvo
	call  INITPATH


        mov   timer.rcount, 0

	mov   ax, RTYPE
	call  RENDER
	call  IMAGEN

	mov   edi, skypalptr
	mov   ax, 36
	shl   eax, 16
	mov   ah, 50
	mov   al, 51

	mov   ecx, 1*UNO
	mov   bl, FADEIN
	mov   bp, 128
	mov   dl, 0
	call  FADEINIT
	mov   fade, 1

;	mov   timer.tfreq, 0
;	mov   screen.fctr, 0
        mov   timer.rcount, 0
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
@pathl:	mov   ax, RTYPE
	call  RENDER
	call  IMAGEN


	xor   ecx, ecx
	mov   bx, timer.rcount
	mov   rrcount, bl

burendloop:
	movzx ebx, rrcount
	movzx ebp, Nburbu[ecx]
	call  TRACEPATH
	jc    evaluate

	movzx eax, Mburbu[ecx]
	movzx ebx, rrcount
	call  TRACEMORPH
	jc    evaluate

burendloop2:
	inc   ecx
	cmp   ecx, BURBUJAS
	jb    short burendloop

	cmp   peace, 1
	jne   Emale
	movzx ebp, Npeace
	movzx ebx, rrcount
	call  TRACEPATH
	jnc   short Emale
	mov   peace, 0
	mov   al, 0
	mov   bl, Npeace
	call  SETRFLAG

Emale:	cmp   male, 1
	jne   Efemale
	movzx ebp, Nmale
	movzx ebx, rrcount
	call  TRACEPATH
	jnc   short Efemale
	mov   male, 0
	mov   al, 0
	mov   bl, Nmale
	call  SETRFLAG

Efemale:cmp   female, 1
	jne   Emorsmile
	movzx ebp, Nfemale
	movzx ebx, rrcount
	call  TRACEPATH
	jnc   short Emorsmile
	mov   female, 0
	mov   al, 0
	mov   bl, Nfemale
	call  SETRFLAG

Emorsmile:
	cmp   morsmile, 1
	jne   Edevsmile
	movzx ebp, Nmorsmile
	movzx ebx, rrcount
	call  TRACEPATH
	jc    short Cmorsmile
	movzx eax, Mmorsmile
	movzx ebx, rrcount
	call  TRACEMORPH
	jnc   short Edevsmile
Cmorsmile:
	mov   morsmile, 0
	mov   al, 0
	mov   bl, Nmorsmile
	call  SETRFLAG

Edevsmile:
	cmp   devsmile, 1
	jne   Ecode
	movzx ebp, Ndevsmile
	movzx ebx, rrcount
	call  TRACEPATH
	jnc   short Ecode
	mov   devsmile, 0
	mov   al, 0
	mov   bl, Ndevsmile
	call  SETRFLAG

Ecode:	cmp   code, 1
	jne   Ekhroma
	movzx ebp, N3dmotion
	movzx ebx, rrcount
	call  TRACEPATH
	jnc   short Ekhroma
	mov   code, 0
	mov   al, 0
	mov   bl, N3dmotion
	call  SETRFLAG

Ekhroma:cmp   khroma, 1
	jne   Eart
	movzx ebp, Nkhroma
	movzx ebx, rrcount
	call  TRACEPATH
	jnc   short Eart
	mov   khroma, 0
	mov   al, 0
	mov   bl, Nkhroma
	call  SETRFLAG

Eart:	cmp   art, 1
	jne   Eartqvo
	movzx ebp, Nart
	movzx ebx, rrcount
	call  TRACEPATH
	jnc   short Eartqvo
	mov   art, 0
	mov   al, 0
	mov   bl, Nart
	call  SETRFLAG


Eartqvo:cmp   artqvo, 1
	jne   Ementat
        movzx ebp, Nartqvo
	movzx ebx, rrcount
	call  TRACEPATH
	jnc   short Ementat
	mov   artqvo, 0
	mov   al, 0
	mov   bl, Nartqvo
	call  SETRFLAG

Ementat:;cmp   mentat, 1
	;jne   Emusic
        ;movzx ebp, Nmentat
	;movzx ebx, rrcount
	;call  TRACEPATH
	;jnc   short Emusic
	;mov   mentat, 0
	;mov   al, 0
	;mov   bl, Nmentat
	;call  SETRFLAG

Emusic:	cmp   music, 1
	jne   Ementat2
	movzx ebx, rrcount
	movzx ebp, Nmuznplay
	call  TRACEPATH
	jnc   short Ementat2
	mov   music, 0
	mov   al, 0
	mov   bl, Nmuznplay
	call  SETRFLAG

Ementat2:
	cmp   mentat2, 1
	jne   Efade
	movzx ebx, rrcount
	movzx ebp, Nmentat
	call  TRACEPATH
	jnc   short Efade
	mov   mentat2, 0
	mov   al, 0
	mov   bl, Nmentat
	call  SETRFLAG

Efade:	cmp   fade, 1
	jne   short Eend
	movzx ebx, rrcount
	call  FADETRACE
	jnc   short Eend
	mov   fade, 0


Eend:	cmp   xmp_flag, 2
	je    bubbleflash
Eend11:
	mov   ax, timer.rcount
	xor   bx, bx
	mov   bl, rrcount
	sub   ax, bx
	mov   timer.rcount, ax

	jmp   @pathl
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
evaluate:

	test  ecx, ecx
	jz    nextthing

burp:
	pushad
	mov   esi, ecx
bliner:	mov   edx, esi
	imul  edx, (size dot3d*4)

	mov   ax, 2
	call  ALEAT
	shl   eax, 15
	mov   bur1[edx].x, eax
	mov   bur1[edx+(size dot3d*2)].x, eax

	mov   ax, 2
	call  ALEAT
	shl   eax, 15

	sub   eax, 700*UNO

	mov   bur1[edx].z, eax
	mov   bur1[edx+(size dot3d*2)].z, eax

	test  esi, esi
	jz    noalea2
	mov   ax, 13
	call  ALEAT
	add   eax, 8
	mov   ecx, eax
	jmp   inipath2

noalea2:
        movzx ecx, bubbletime
inipath2:
	xor   eax, eax
	mov   ebx, 1
	lea   edx, bur1[edx]
	movzx ebp, Nburbu[esi]
	call  INITPATH

b@kaka2:
	xor   ax, ax
	call  ALEAT
	movzx ecx, ax
	shl   ecx, 5
	cmp   ecx, 15*UNO
	jbe   short b@kaka2
	mov   ebx, 50
	movzx eax, Mburbu[esi]
	lea   edx, burseq1
	call  INITMORPH
	popad

	jmp   burendloop2

;---------------------------------
bubbleflash:
	mov   xmp_flag, 0

	pushad
	mov   esi, skypalptr
	mov   edi, esi
	add   esi, 64*3
	mov   ecx, 1*UNO
	mov   bl, FADEMORPH
	mov   bp, 64
	mov   dl, 0
	call  FADEINIT
	popad
	mov   fade, 1
	jmp   Eend11

; ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
nextthing:
	inc   seq

	cmp   seq, 1
	jne   short nextp2
	jmp   burp

nextp2:	cmp   seq, 2
	jne   nextp3
	mov   peace, 1
	mov   al, 1
	mov   bl, Npeace
	call  SETRFLAG
	jmp   burp


nextp3: cmp   seq, 3
	jne   short nextp4
	jmp   burp


nextp4: cmp   seq, 4
	jne   nextp5
	mov   al, 1
	mov   bl, Nmale
	call  SETRFLAG
	mov   al, 1
	mov   bl, Nfemale
	call  SETRFLAG
	mov   male, 1
	mov   female, 1
	jmp   burp

nextp5:	cmp   seq, 5
	jne   nextp6
	mov   al, 1
	mov   bl, Nmorsmile
	call  SETRFLAG
	mov   al, 1
	mov   bl, Ndevsmile
	call  SETRFLAG
	mov   morsmile, 1
	mov   devsmile, 1
	jmp   burp

nextp6:	cmp   seq, 6
	jne   short nextp7

	mov   al, bubbletime
	mov   bubbletemp, al
	mov   bubbletime, 1
	jmp   burp

nextp7:	cmp   seq, 7
	jne   short nextp8
	mov   al, bubbletemp
	mov   bubbletime, al
	jmp   burp

nextp8:	cmp   seq, 8
	jne   short nextp9
	mov   al, 1
	mov   bl, N3dmotion
	call  SETRFLAG
	mov   al, 1
	mov   bl, Nkhroma
	call  SETRFLAG
	mov   code, 1
	mov   khroma, 1
	jmp   burp


nextp9:	cmp   seq,9
	jne   short nextp10
	jmp   burp


nextp10:cmp   seq, 10
	jne   short nextp11
	mov   al, 1
	mov   bl, Nart
	call  SETRFLAG
	mov   al, 1
	mov   bl, Nartqvo
	call  SETRFLAG
	mov   art, 1
	mov   artqvo, 1
	jmp   burp

nextp11:cmp   seq,11
	jne   short nextp12
	jmp   burp


nextp12:cmp   seq, 12
	jne   short nextp13
	mov   al, 1
	mov   bl, Nmuznplay
	call  SETRFLAG
	mov   al, 1
	mov   bl, Nmentat
	call  SETRFLAG
	pushad
	mov   ebx, 3
 	mov   ecx, 11
	lea   edx, Pname
	movzx ebp, Nmentat
	call  INITPATH
	popad
	mov   music, 1
	mov   mentat2, 1
	jmp   burp

nextp13:cmp   seq,13
	jne   short nextp14
	mov   bubbletime, 3
	jmp   burp

nextp14:cmp   seq,14
	jne   short nextp15
	mov   bubbletime, 4
	pushad
	mov   edi, skypalptr
	mov   ax, 49
	shl   eax, 16
	mov   ah, 48
	mov   al, 48
	mov   ecx, 3*UNO
	mov   bl, FADEOUT
	mov   dl, 0
	mov   bp, 256
	call  FADEINIT
	popad
	mov   fade, 1
	jmp   burp

nextp15:
; Turns off all objects...
	xor   cx, cx
	mov   ch, Npeace
cobjloop:
	mov   al, 0
	mov   bx, cx
	call  SETRFLAG

	inc   cl
	cmp   cl, ch
	jne   short cobjloop


	add   screen.ymax, 1

;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
endif

ifdef PICTURE
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ  DIBUJILLO  ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
TIME1 = 1*UNO
TIME2 = 4
TIME3 = 1*UNO

	mov   timer.rcount, 0
	mov   xmp_flag, 0

	mov   edi, Fpictureptr
	mov   al, 1
	call  SETBACKGND

	call  CLSIMG
	call  IMAGEN
; -- Exobit ---------------------
	mov   edi, pictureptr
	mov   ax, 49     ; R16 G15 B16
	shl   eax, 16
	mov   ah, 48
	mov   al, 48
	mov   ecx, TIME1
	mov   bl, FADEIN
	mov   bp, 256
	mov   dl,0
	call  FADEINIT

pc@finloop:
	xor   ebx, ebx
	mov   bx, timer.rcount
	call  FADETRACE
	jc    short pc@efinloop
	sub   timer.rcount, bx
	jmp   short pc@finloop
; -- Exobit ---------------------
pc@efinloop:
endif

;อออ Wait y se leen los datos de la demo อออออออออออออออออออออออออออออออออออ
; Impide que al pulsar escape se pueda salir de la demo...
	mov   DemoFlag, 0
	call  RESETTIMER

	mov   eax, oldhimembase
	mov   _himembase, eax
	mov   eax, oldlomembase
	mov   _lomembase, eax

	mov   initbuf, 0

; Objetos parte ][
	mov   edx, offset Splanet
	mov   ecx, 61576
	mov   al, 1
	call  LOADOBJECT
	jc    E_noshp
	mov   Nplanet, al


	mov   edx, offset Spiva
	mov   ecx, 934664
        mov   al, 1
	call  LOADOBJECT
	jc    E_noshp
	mov   Npiva, al
	mov   Mpiva, bl

; Inicia los datos de la c mara, luz, y objetivo
	mov   edi, TheWorld
	lea   eax, [edi].light
	mov   [edi].obj[LIGHT*4], eax
	lea   eax, [edi].camera
	mov   [edi].obj[CAMERA*4], eax
	lea   eax, [edi].objetivo
	mov   [edi].obj[OBJETIVO*4], eax

;- Planeta -----------------------
	lea   edx, Tcasa
	mov   ecx, 32768
	call  LOADPICTURE
	jc    E_nomem
	mov   Tcasaptr, eax
	add   eax, 128
	mov   Ttechoptr, eax

	lea   edx, Tsue12
	mov   ecx, 32768
	call  LOADPICTURE
	jc    E_nomem
	mov   Tsue1ptr, eax
	add   eax, 128
	mov   Tsue2ptr, eax

	lea   edx, Tsue34
	mov   ecx, 32768
	call  LOADPICTURE
	jc    E_nomem
	mov   Tsue3ptr, eax
	add   eax, 128
	mov   Tsue4ptr, eax

	lea   edx, Ttree
	mov   ecx, 32768
	call  LOADPICTURE
	jc    E_nomem
	mov   Ttreeptr, eax
	add   eax, 128
	mov   Tarbolptr, eax

	lea   edx, Tmisc
	mov   ecx, 32768
	call  LOADPICTURE
	jc    E_nomem
	mov   Tcaminoptr, eax
	add   eax, 128
	mov   Tflareptr, eax


;-- La piva ----------------------
	lea   edx, Tpiva12
	mov   ecx, 32768
	call  LOADPICTURE
	jc    E_nomem
	mov   Tpiva1ptr, eax
	add   eax, 128
	mov   Tpiva2ptr, eax

	lea   edx, Tpiva34
	mov   ecx, 32768
	call  LOADPICTURE
	jc    E_nomem
	mov   Tpiva3ptr, eax
	add   eax, 128
	mov   Tpiva4ptr, eax

	lea   edx, Tpiva56
	mov   ecx, 32768
	call  LOADPICTURE
	jc    E_nomem
	mov   Tpiva5ptr, eax
	add   eax, 128
	mov   Tpiva6ptr, eax

	lea   edx, Tpiva78
	mov   ecx, 32768
	call  LOADPICTURE
	jc    E_nomem
	mov   Tpiva7ptr, eax
	add   eax, 128
	mov   Tpiva8ptr, eax

	lea   edx, Tpivaf
	mov   ecx, 76800
	call  LOADPICTURE
	jc    E_nomem
	mov   Tpivafptr, eax
	mov   edi, eax
	mov   ecx, 320*240
	call  INITMAP
	jc    E_nomem


	lea   edx, ACtable
	mov   ecx, 32768
	call  LOADPICTURE
	jc    E_nomem
	mov   ACtableptr, eax

; ฤ Paletas ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	lea   edx, picture
	mov   ecx, 768
	call  LOADPICTURE
	jc    E_nomem
	mov   pictureptr, eax

	lea   edx, planetpal
	mov   ecx, 768
	call  LOADPICTURE
	jc    E_nomem
	mov   planetpalptr, eax

	lea   edx, piva
	mov   ecx, 768
	call  LOADPICTURE
	jc    E_nomem
	mov   pivaptr, eax

	lea   edx, piva2
	mov   ecx, 768
	call  LOADPICTURE
	jc    E_nomem
	mov   piva2ptr, eax

	lea   edx, piva3
	mov   ecx, 768
	call  LOADPICTURE
	jc    E_nomem
	mov   piva3ptr, eax

	lea   edx, fu_file
	mov   ecx, 11322
	call  LOADPICTURE
	jc    E_nomem
	mov   fuente, eax

	lea   edx, pa_file
	mov   ecx, 768
	call  LOADPICTURE
	jc    E_nomem
	mov   paleton, eax

	lea   edx, piva2
	mov   ecx, 768
	call  LOADPICTURE
	jc    E_nomem
	mov   piva2aptr, eax

	lea   edx, piva2
	mov   ecx, 768
	call  LOADPICTURE
	jc    E_nomem
	mov   piva3aptr, eax
	
	lea   edx, piva2
	mov   ecx, 768
	call  LOADPICTURE
	jc    E_nomem
	mov   piva3bptr, eax

	lea   edx, piva2
	mov   ecx, 768
	call  LOADPICTURE
	jc    E_nomem
	mov   piva3cptr, eax

	lea   edx, piva2
	mov   ecx, 768
	call  LOADPICTURE
	jc    E_nomem
	mov   piva3dptr, eax


;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
ifdef  DEBUG
	call  SETTEXT
	call _lomemsize
	@printmd lomem_msg, eax
	call _himemsize
	@printmd himem_msg, eax
	@print enter
	@print press_msg
	call _getch
	call  SET320240

endif
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

	call  INITTIMER
; Volvemos a permitir salir al pulsar escape...
	mov   DemoFlag, 1


ifdef PICTURE

	mov   ax, TIME2
	call  WAITSONG


;อออ Wait y se leen los datos de la demo อออออออออออออออออออออออออออออออออออ
	mov   timer.rcount, 0
; --- Off -----------------------------
	mov   edi, pictureptr
	xor   eax, eax
	mov   ecx, TIME3
	mov   bl, FADEOUT
	mov   bp, 256
	mov   dl, 0
	call  FADEINIT

pc@foutloop:
	xor   ebx, ebx
	mov   bx, timer.rcount
	call  FADETRACE
	jc    short pc@efoutloop
	sub   timer.rcount, bx
	jmp   short pc@foutloop
; --- Off -----------------------------
pc@efoutloop:

;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
;----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
endif


ifdef PLANET
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ  ESCENA DEL PLANETA ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
 TIME1 = 13 ;5
 TIME2 = 26 ;5
 TIME3 = 13 ;5

	mov   vRtype, GOURAUD OR TEXTMAP OR CAMROT

	mov   edi, Tcasaptr
	xor   al, al
        call  INITTEXT
	mov   edi, Ttechoptr
	mov   al, 1
        call  INITTEXT
	mov   edi, Ttreeptr
	mov   al, 2
        call  INITTEXT
	mov   edi, Tarbolptr
	mov   al, 3
        call  INITTEXT
	mov   edi, Tcaminoptr
	mov   al, 4
        call  INITTEXT
	mov   edi, Tsue1ptr
	mov   al, 5
        call  INITTEXT
	mov   edi, Tsue2ptr
	mov   al, 6
        call  INITTEXT
	mov   edi, Tsue3ptr
	mov   al, 7
        call  INITTEXT
	mov   edi, Tsue4ptr
	mov   al, 8
        call  INITTEXT

	mov   ebp, 1*(UNO+40000)
	mov   ax, 33
	call  NEWLIGHTTABLE

	mov   al, 3
	call  SETBACKGND
	call  INITSTARSDATA


; Secuencia 1
        mov   seq, 0
        mov   rot2flag, 1

	mov   ebx, 1
	mov   ecx, TIME1
	lea   edx, planet1
	movzx ebp, Nplanet
	call  INITPATH

 	mov   ebx, 19
	mov   ecx, TIME1
	lea   edx, flare1
	mov   ebp, LIGHT
	call  INITPATH

 	mov   ebx, 4
	mov   ecx, TIME1
	lea   edx, cam1
	mov   ebp, CAMERA
	call  INITPATH

	mov   ebx, 1
	mov   ecx, TIME1
	lea   edx, objet1
	mov   ebp, OBJETIVO
	call  INITPATH

 	call  LOOKAT_Y

	mov   al, 1
	mov   bl, Nplanet
	call  SETRFLAG


;	mov   ax, vRtype
;       call  RENDER
;	call  IMAGEN

        mov   edi, planetpalptr
	xor   eax, eax
	mov   ecx, 2*UNO
	mov   bl, FADEIN
	mov   bp, 256
	mov   dl,0
	call  FADEINIT
	mov   fade, 1

	mov   timer.rcount, 0
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ


@pathl3:
 	call  LOOKAT_Y


	cmp   rot2flag, 1
	jne   short pl@render
	mov   esi, TheWorld
	lea   esi, [esi].camera
	mov   [esi].vd.x, -10*32*UNO
	mov   [esi].vd.z, 10*32*UNO

pl@render:
	mov   ax, vRtype
 	call  RENDER
	call  IMAGEN

	mov   bx, timer.rcount
	mov   rrcount, bl

	movzx ebx, rrcount
	movzx ebp, Nplanet
	call  TRACEPATH
	jc    endplanet


	movzx ebx, rrcount
	mov   ebp, CAMERA
	call  TRACEPATH
	jc    endplanet

	movzx ebx, rrcount
	mov   ebp, LIGHT
	call  TRACEPATH
	jc    endplanet

	movzx ebx, rrcount
	mov   ebp, OBJETIVO
	call  TRACEPATH
	jc    endplanet

	cmp   fade, 1
	jne   short doloopplanet
	movzx ebx, rrcount
	call  FADETRACE
	jnc   short doloopplanet
	mov   fade, 0


doloopplanet:
	mov   ax, timer.rcount
	xor   bx, bx
	mov   bl, rrcount
	sub   ax, bx
	mov   timer.rcount, ax

	jmp   @pathl3

;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
endplanet:
	inc   seq
	cmp   seq, 1
	je    short Pseq1

	cmp   seq, 2
	je    Pseq2
	cmp   seq, 3
	je    endplanet2

Pseq1:
	mov   vRtype, GOURAUD OR TEXTMAP OR CAMROT OR FLARE

	mov   ebx, 1
	mov   ecx, TIME2
	lea   edx, planet2
	movzx ebp, Nplanet
	call  INITPATH

	mov   ebx, 41
	mov   ecx, TIME2
	lea   edx, flare2
	mov   ebp, LIGHT
	call  INITPATH

	mov   ebx, 7
	mov   ecx, TIME2
	lea   edx, cam2
	mov   ebp, CAMERA
	call  INITPATH

	mov   ebx, 2
	mov   ecx, TIME2
	lea   edx, objet2
	mov   ebp, OBJETIVO
	call  INITPATH


	jmp   @pathl3

Pseq2:
	mov   rot2flag, 0

	mov   ebx, 1
	mov   ecx, TIME3
	lea   edx, planet4
	movzx ebp, Nplanet
	call  INITPATH

	mov   ebx, 1
	mov   ecx, TIME3
	lea   edx, flare4
	mov   ebp, LIGHT
	call  INITPATH

	mov   ebx, 2
	mov   ecx, TIME3
	lea   edx, cam4
	mov   ebp, CAMERA
	call  INITPATH

	mov   ebx, 10
	mov   ecx, TIME3
	lea   edx, objet4
	mov   ebp, OBJETIVO
	call  INITPATH


	jmp   @pathl3


endplanet2:
	mov   al, 0
	mov   bl, Nplanet
	call  SETRFLAG

; Y las im genes de fondo
; ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
endif

ifdef PIVA
;ฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐ ESTRELLA Y APARICION DE LA CHICA ฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐ
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
 RTYPE = RAW OR NOSORT OR FLARE; OR NOROT
 TIME0     = 6  ; Aparece
 TIME1     = 9  ; Se acerca
 TIME2     = 9  ; Aparece la chica
 TIME3     = 4  ; Desaparece
 TIMEMORPH = 45284*2

	mov   seq, 0
	mov   khroma, 0
	mov   direct, 0
	mov   tm@dirflag, 0

	mov   edi, pivaptr
	mov   al, 0
	mov   cx, 256
	call  SETPAL

	mov   al, 0
	call  SETBACKGND

ifndef PLANET
	call  INITSTARSDATA
endif
	call  INITSTAR

	mov   al, 1
	mov   bl, Npiva
	call  SETRFLAG

	mov   size_Y, 2150*UNO
	mov   size_X, 2150*UNO

	movzx ebx, Paspasub1size
	mov   ecx, TIMEMORPH
	movzx eax, Mpiva
	lea   edx, Paspasub1
	call  INITMORPH

       	movzx ebx, Psize0
	mov   ecx, TIME0
	lea   edx, Ppivcam0
	mov   ebp, CAMERA
	call  INITPATH

	movzx ebx, Psize0
 	mov   ecx, TIME0
	lea   edx, Ppiva0
	movzx ebp, Npiva
	call  INITPATH

	movzx ebx, Psize0
 	mov   ecx, TIME0
	lea   edx, Ppiva0
	mov   ebp, LIGHT
	call  INITPATH


	mov   timer.rcount, 0
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
@pathl4:

	mov   ax, RTYPE
	call  RENDER
	call  IMAGEN

        mov   bx, timer.rcount
	mov   rrcount, bl

	movzx ebx, rrcount
	movzx ebp, Npiva
	call  TRACEPATH
	jc    starseq

	movzx ebx, rrcount
	mov   ebp, LIGHT
	call  TRACEPATH
	jc    starseq

@pathl4morph:
	movzx ebx, rrcount
	movzx eax, Mpiva
	call  TRACEMORPH
	jc    newmorph

@pathl4fade:
	cmp   fade, 1
	jne   short loop4
	movzx ebx, rrcount
	call  FADETRACE
	jnc   short loop4
	mov   fade, 0

loop4:
	mov   ax, timer.rcount
	xor   bx, bx
	mov   bl, rrcount
	sub   ax, bx
	mov   timer.rcount, ax
	jmp   @pathl4
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
starseq:
	inc   seq


	cmp   seq, 2
	je    pivaintro2
	cmp   seq, 3
	je    pivaintro3
	cmp   seq, 4
	je    endpivaintro

	movzx ebx, Psize1
 	mov   ecx, TIME1
	lea   edx, Ppiva1
	movzx ebp, Npiva
	call  INITPATH

	movzx ebx, Psize1
	mov   ecx, TIME1
  	lea   edx, Ppiva1
	mov   ebp, LIGHT
	call  INITPATH

	jmp   @pathl4morph

pivaintro2:
	movzx ebx, Psize2
 	mov   ecx, TIME2
	lea   edx, Ppiva2
	movzx ebp, Npiva
	call  INITPATH

	movzx ebx, Psize2
	mov   ecx, TIME2
  	lea   edx, Ppiva2
	mov   ebp, LIGHT
	call  INITPATH

        mov   edi, pivaptr
	xor   eax, eax
	mov   bl, FADEOUT
        mov   bp, 32*4
        mov   dl, 32*2
	mov   ecx, (TIME2-2)*UNO
	call  FADEINIT
	mov   fade, 1

	mov   spinflag, 1

	jmp   @pathl4morph

pivaintro3:
	movzx ebx, Psize3
 	mov   ecx, TIME3
	lea   edx, Ppiva3
	movzx ebp, Npiva
	call  INITPATH

	movzx ebx, Psize3
	mov   ecx, TIME3
  	lea   edx, Ppiva3
	mov   ebp, LIGHT
	call  INITPATH

; Prepara la paleta en negros para el fade-off
	mov   edi, pivaptr
	xor   eax, eax
	add   edi, (32*2)*3
	mov   ecx, ((32*4)*3)/4
	rep   stosd

        mov   edi, pivaptr
	mov   eax, (63*65536)+(63*256)+(63)
	mov   bl, FADEOUT
        mov   bp, 256
        mov   dl, 0
	mov   ecx, ((TIME3)*UNO) - 32768
	call  FADEINIT
	mov   fade, 1

	jmp   @pathl4


newmorph:
	xor  khroma, 1

	cmp  khroma, 0
	je   short khroma2

	movzx ebx, Paspasub1size
	mov   ecx, TIMEMORPH
	movzx eax, Mpiva
	lea   edx, Paspasub1
	call  INITMORPH
	jmp   @pathl4fade

khroma2:
	movzx ebx, Paspasub2size
	mov   ecx, TIMEMORPH
	movzx eax, Mpiva
	lea   edx, Paspasub2
	call  INITMORPH
	jmp   @pathl4fade


endpivaintro:


;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
endif



ifdef PIVADANZE
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;ฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐ  B A I L E  ฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐ
 RTYPE = GOURAUD OR TEXTMAP OR CAMROT; OR NOROT
 TIME      = 200
 TIMECAM   = 3
 TIMECAM2  = 15 ;21
 TIMECAM3  = 7

	mov   seq, 0
	mov   Cseq, 0
	mov   fade, 1
	mov   rotpal, 0

; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;	call  _XMP_Play
;	test  al, al
;	jnz   @xmperror

	mov   ax, 1
	call  WAITSONG

	mov   edi, Tpiva1ptr
	xor   eax, eax
        call  INITTEXT

	mov   edi, Tpiva2ptr
	mov   al, 1
        call  INITTEXT

	mov   edi, Tpiva3ptr
	mov   al, 2
        call  INITTEXT

	mov   edi, Tpiva4ptr
	mov   al, 3
        call  INITTEXT

	mov   edi, Tpiva5ptr
	mov   al, 4
        call  INITTEXT

	mov   edi, Tpiva6ptr
	mov   al, 5
	call  INITTEXT

	mov   edi, Tpiva7ptr
	mov   al, 6
        call  INITTEXT

	mov   edi, Tpiva8ptr
	mov   al, 7
        call  INITTEXT

	mov   al, 1
	mov   edi, Tpivafptr
	call  SETBACKGND
	call  CLSIMG
	call  IMAGEN
	call  CLSIMG

	mov   ebx, 1
 	mov   ecx, TIME
	lea   edx, PDpiva1
	movzx ebp, Npiva
	call  INITPATH

	mov   ebx, 1
	mov   ecx, TIME
  	lea   edx, PDlight1
	mov   ebp, LIGHT
	call  INITPATH

       	movzx ebx, PDcam0size
	mov   ecx, TIMECAM
	lea   edx, PDcam0
	mov   ebp, CAMERA
	call  INITPATH

       	mov   ebx, 1
	mov   ecx, TIME
	lea   edx, PDpiva1
	mov   ebp, OBJETIVO
	call  INITPATH

	movzx ebx, Paspasize
	mov   ecx, Taspa
	movzx eax, Mpiva
	lea   edx, Paspa
	call  INITMORPH

	mov   al, 1
	mov   bl, Npiva
	call  SETRFLAG

	mov   ebp, 1*UNO+9000
	mov   ax, 33 ;31
	call  NEWLIGHTTABLE

	mov   fade, 1
	mov   edi, piva3ptr
	mov   eax, (63*65536)+(63*256)+(63)
	mov   ecx, 2*UNO
	mov   bl, FADEIN
	mov   bp, 256
	mov   dl, 0
	call  FADEINIT


	mov   timer.rcount, 0
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
@pathl5:
	call  LOOKAT_Y

	mov   ax, RTYPE
	call  RENDER
	call  IMAGEN

	mov   bx, timer.rcount
	mov   rrcount, bl

	movzx ebx, rrcount
	movzx ebp, Npiva
	call  TRACEPATH
	jc    pseq

 	movzx ebx, rrcount
	movzx eax, Mpiva
	call  TRACEMORPH
	jc    pseq

@path5cam:
	movzx ebx, rrcount
	mov   ebp, CAMERA
	call  TRACEPATH
	jc    cseq

@path5light:
	movzx ebx, rrcount
	mov   ebp, LIGHT
	call  TRACEPATH
	jc    cseq

@path5obj:
 	movzx ebx, rrcount
	mov   ebp, OBJETIVO
	call  TRACEPATH
	jc    cseq

@path5fade:
	cmp   fade, 1
	jne   short @path5morph
	movzx ebx, rrcount
	call  FADETRACE
	jnc   short loop501
	mov   fade, 0

@path5morph:
loop501:
	cmp   rotpal, 1
	jne   short loop50
	mov   edi, currotpal
	call  rotpal1

loop50:
	cmp   xmp_flag, 1
	je    pv@spira0

loop5:
	cmp   xmp_flag, 2
	je    pv@flashinit

loop5f2:
	cmp   xmp_flag, 3
	je    pv@strobersinit

loop5f3:
	cmp   xmp_flag, 4
	je    pv@spira2

loop5f4:
	cmp   xmp_flag, 5
	je    pv@spira3

loop5f5:
	cmp   xmp_flag, 6
	je    pv@spira4

loop5f6:
	cmp   xmp_flag, 7
	je    pv@spira2

loop5f7:
	cmp   xmp_flag, 8
	je    pv@spira5

loop5b:

	mov   ax, timer.rcount
	xor   bx, bx
	mov   bl, rrcount
	sub   ax, bx
	mov   timer.rcount, ax
	jmp   @pathl5

;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
pseq:
	inc   seq
; -----------------------------
        cmp   seq, 6
        jbe   aspa
; -----------------------------
        cmp   seq, 7
        jbe   aspa2meneito
; -----------------------------
        cmp   seq, 20
        jbe   meneito
; -----------------------------
        cmp   seq, 21
        jbe   meneito2pown
; -----------------------------
        cmp   seq, 33
        jbe   pown
; -----------------------------
        cmp   seq, 34
        jbe   pown2meneito
; -----------------------------
        cmp   seq, 45
        jbe   meneito
; -----------------------------
        cmp   seq, 46
        jbe   meneito2aspa
; -----------------------------
        cmp   seq, 60
        jbe   aspa
; -----------------------------

        jmp   baileend

;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
; SECUENCIAS
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
; Brazos en aspa...
aspa:
	movzx ebx, Paspasize
  	mov   ecx, Taspa
	movzx eax, Mpiva
	lea   edx, Paspa
	call  INITMORPH
	jmp   @path5cam


; Meneito
meneito:
	movzx ebx, Pmeneitosize
 	mov   ecx, Tmeneito
 	movzx eax, Mpiva
	lea   edx, Pmeneito
	call  INITMORPH
        jmp   @path5cam

; Pown
pown:
	movzx ebx, Ppownsize
	mov   ecx, Tpown
	movzx eax, Mpiva
	lea   edx, Ppown
	call  INITMORPH
	jmp   @path5cam


; Transiciขn Aspa-Meneito
aspa2meneito:
	movzx ebx, Paspa2meneitosize
	mov   ecx, Taspa2meneito
	movzx eax, Mpiva
	lea   edx, Paspa2meneito
	call  INITMORPH
	jmp   @path5cam

; Transiciขn Meneito-Aspa
meneito2aspa:
	movzx ebx, Pmeneito2aspasize
	mov   ecx, Tmeneito2aspa
	movzx eax, Mpiva
	lea   edx, Pmeneito2aspa
	call  INITMORPH
	jmp   @path5cam

; Transiciขn Meneito-Pown
meneito2pown:
	movzx ebx, Pmeneito2pownsize
	mov   ecx, Tmeneito2pown
	movzx eax, Mpiva
	lea   edx, Pmeneito2pown
	call  INITMORPH
	jmp   @path5cam

; Transiciขn Pown-Meneito
pown2meneito:
	movzx ebx, Ppown2meneitosize
	mov   ecx, Tpown2meneito
	movzx eax, Mpiva
	lea   edx, Ppown2meneito
	call  INITMORPH
	jmp   @path5cam

; Transiciขn Aspa-Pown
aspa2pown:
	movzx ebx, Paspa2pownsize
	mov   ecx, Taspa2pown
	movzx eax, Mpiva
	lea   edx, Paspa2pown
	call  INITMORPH
	jmp   @path5cam

; Transiciขn Pown-Aspa
pown2aspa:
	movzx ebx, Ppown2aspasize
	mov   ecx, Tpown2aspa
	movzx eax, Mpiva
	lea   edx, Ppown2aspa
	call  INITMORPH
	jmp   @path5cam


;ฤฤฤฤฤ Secuencia de la c mara ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
cseq:
	inc   Cseq

	cmp   Cseq, 3
	jbe   camrot0

	cmp   Cseq, 4
	jbe   camrot1

	cmp   Cseq, 7
	jbe   camrot2

	cmp   Cseq, 8
	jbe   camrot3

	cmp   Cseq, 13
	jbe   camrot4

	cmp   Cseq, 14
	jbe   camrot5

	cmp   Cseq, 15
	jbe   camrot6

	cmp   Cseq, 16
	jbe   camrot7

	cmp   Cseq, 17
	jbe   camrot8

	jmp   baileend


camrot0:
       	movzx  ebx, PDcam0size
	mov   ecx, TIMECAM
	lea   edx, PDcam0
	mov   ebp, CAMERA
	call  INITPATH
	jmp   @path5fade

camrot1:
       	movzx  ebx, PDcam1size
	mov   ecx, TIMECAM
	lea   edx, PDcam1
	mov   ebp, CAMERA
	call  INITPATH
	jmp   @path5fade

camrot2:
       	movzx   ebx, PDcam2size
	mov   ecx, TIMECAM
	lea   edx, PDcam2
	mov   ebp, CAMERA
	call  INITPATH
	jmp   @path5fade


camrot3:
       	movzx   ebx, PDcam3size
	mov   ecx, TIMECAM
	lea   edx, PDcam3
	mov   ebp, CAMERA
	call  INITPATH
	jmp   @path5fade


camrot4:
       	movzx   ebx, PDcam4size
	mov   ecx, TIMECAM
	lea   edx, PDcam4
	mov   ebp, CAMERA
	call  INITPATH
	jmp   @path5fade

camrot5:
       	movzx ebx, PDcam5size
	mov   ecx, TIMECAM2
	lea   edx, PDcam5
	mov   ebp, CAMERA
	call  INITPATH

	mov   fade, 1
	mov   edi, piva2ptr
	xor   eax, eax
	mov   ecx, 6*UNO
	mov   bl, FADEIN
	mov   bp, 64
	mov   dl, 0
	call  FADEINIT
        mov   rotpal, 1
	mov   eax, piva2ptr
	mov   currotpal, eax

	jmp   loop5b
;	jmp   @path5fade

camrot6:
       	movzx ebx, PDcam6size
	mov   ecx, TIMECAM 
	lea   edx, PDcam6
	mov   ebp, CAMERA
	call  INITPATH
	jmp   @path5fade

camrot7:
       	movzx ebx, PDcam7size
	mov   ecx, TIMECAM
	lea   edx, PDcam7
	mov   ebp, CAMERA
	call  INITPATH
	jmp   @path5fade

camrot8:
       	movzx ebx, PDcam8size
	mov   ecx, TIMECAM3
	lea   edx, PDcam8
	mov   ebp, CAMERA
	call  INITPATH

	mov   fade, 1
	mov   edi, currotpal
	xor   eax, eax
	mov   ecx, TIMECAM3*UNO
	mov   bl, FADEOUT
	mov   bp, 256
	mov   dl, 0
	call  FADEINIT
	jmp   @path5fade

pv@flashinit:
	mov   fade, 1
	mov   edi, piva3ptr
	mov   eax, 3f3f3fh
	mov   ecx, 20000
	mov   bl, FADEIN
	mov   bp, 256
	mov   dl, 0
	call  FADEINIT
	mov   xmp_flag, 0
	jmp   loop5b



pv@strobersinit:
	mov   fade, 1
	mov   esi, piva2aptr
	mov   edi, piva3ptr
	mov   ecx, 16000
	mov   bl, FADEMORPH
	mov   bp, 256
	mov   dl, 0
	call  FADEINIT
	mov   xmp_flag, 0
	jmp   loop5b


pv@spira0:
;	mov   fade, 1
;	mov   edi, piva2ptr
;	xor   eax, eax
;	mov   ecx, 6*UNO
;	mov   bl, FADEIN
;	mov   bp, 256
;	mov   dl, 0
;	call  FADEINIT
;	mov   rotpal, 1
;	mov   eax, piva2ptr
;	mov   currotpal, eax
;	mov   xmp_flag, 0
	jmp   loop5b


pv@spira2:
	mov   fade, 1
	mov   edi, piva3aptr
	mov   eax, 3f3f3fh
	mov   ecx, 32768
	mov   bl, FADEIN
	mov   bp, 256
	mov   dl, 0
	call  FADEINIT
	mov   eax, piva3aptr
	mov   currotpal, eax
	mov   xmp_flag, 0
	jmp   loop5b

pv@spira3:
	mov   fade, 1
	mov   edi, piva3bptr
	mov   eax, 3f3f3fh
	mov   ecx, 32768
	mov   bl, FADEIN
	mov   bp, 256
	mov   dl, 0
	call  FADEINIT
	mov   eax, piva3bptr
	mov   currotpal, eax
	mov   xmp_flag, 0
	jmp   loop5b


pv@spira4:
	mov   fade, 1
	mov   edi, piva3cptr
	mov   eax, 3f3f3fh
	mov   ecx, 32768
	mov   bl, FADEIN
	mov   bp, 256
	mov   dl, 0
	call  FADEINIT
	mov   eax, piva3cptr
	mov   currotpal, eax
	mov   xmp_flag, 0
	jmp   loop5b

pv@spira5:
	mov   fade, 1
	mov   edi, piva3dptr
	mov   eax, 3f3f3fh
	mov   ecx, 32768
	mov   bl, FADEIN
	mov   bp, 256
	mov   dl, 0
	call  FADEINIT
	mov   eax, piva3dptr
	mov   currotpal, eax
	mov   xmp_flag, 0
	jmp   loop5b


baileend:
;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
endif


ifdef FIREWRK
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ  FUEGOS ARTIFICIALES ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
	mov timer.rcount, 0

        call INITFWDATA
        test eax, eax
        jnz  EXITDEMO

;----- Unrolled loop -------------------------
	I = 0
	mov  edi, screen.vscreen
	mov  ecx, (4800*4) / 8
	xor  eax, eax

	I = 0
	align 16
fw@clsRAWloop:
	REPT 8
	mov  [edi+I], eax
	I = I + 4
	ENDM	
	add  edi, 8*4
	dec  cx
	jnz  fw@clsRAWloop
;----- Unrolled loop -------------------------

	mov  fade, 1
        mov  edi, paleton
	xor  eax, eax
	mov  ecx, 2*UNO
	mov  bl, FADEIN
	mov  dl, 0
	mov  bp, 256
	call FADEINIT
	mov  khroma, 0

infloop:
        movzx ebx, timer.rcount
	mov   timer.rcount, 0
	push  ebx
        call  FIREWORKS
	pop   ebx
        jc    fworks2

fwdofade:
	cmp   fade, 1
	jne   short fwloop
;	EBX = Rastertime...
	call  FADETRACE
	jnc   short fwloop
	mov   fade, 0

fwloop:
	jmp   short infloop


fworks2:
	cmp  fade, 1
	je   short fwdofade
	cmp  khroma, 1
	je   EXITDEMO
	mov  fade, 1
        mov  edi, paleton
	xor  eax, eax
	mov  ecx, 3*UNO
	mov  bl, FADEOUT
	mov  dl, 0
	mov  bp, 256
	call FADEINIT
	mov  khroma, 1
	jmp  short fwloop


;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
endif


dycierre:
	call  EXITDEMO

;=== ERRORS 3D ENGINE =======================================================
E_nocop: @print nocopro_msg
	 jmp Dexit
;-----------------------------------------------------------------------------
E_nomem: @print nomem_msg
	 jmp Dexit
;-----------------------------------------------------------------------------
E_novga: @print novga_msg
	 jmp Dexit
;-----------------------------------------------------------------------------
E_noshp: test ax, ax
	 jz   short print00
	 cmp  ax, 1
	 je   short print01
	 cmp  ax, 2
	 je   short print02
	 cmp  ax, 3
	 je   short print03
	 jmp  short print04

print00: @print noshp_msg00
	 jmp Dexit
print01: @print noshp_msg01
	 jmp Dexit
print02: @print nomem_msg
	 jmp Dexit
print03: @print noshp_msg03
	 jmp Dexit
print04: @print noshp_msg04
	 jmp Dexit
;=============================================================================

;=== ERRORS XM Player ========================================================
;-----------------------------------------------------------------------------
@xmperror:
	cmp al, 010h
	je xmpe10
	cmp al, 011h
	je xmpe11
	cmp al, 012h
	je xmpe12
	cmp al, 020h
	je xmpe20
	cmp al, 021h
	je xmpe21
	jmp xmpeF0
;-----------------------------------------------------------------------------
nopara:
	@print msg01
	jmp Dexit
;-----------------------------------------------------------------------------
noread:
	@print noshp_msg04
	jmp Dexit
;-----------------------------------------------------------------------------
xmpe10:
	@print msgx10
	jmp Dexit
xmpe11:
	@print msgx11
	jmp Dexit
xmpe12:
	@print msgx12
	jmp Dexit
xmpe20:
	@print msgx20
	jmp Dexit
xmpe21:
	@print msgx21
	jmp Dexit
xmpeF0:
	@print msgxF0
;=============================================================================


;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
;ฑ----------------ณ----------------------------------------------------------ฑ
;ฑ----------------ณ----------------------------------------------------------ฑ
;ฑ PROCEDIMIENTO: ล GETDATAGUS                                               ฑ
;ฑ----------------ณ----------------------------------------------------------ฑ
;ฑ----------------ณ----------------------------------------------------------ฑ
;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
gdg_string	db	" K$"
gdg_char	db	1,3,5,7,11,12,15
gdg_dma		db	1,3,5,6,7

PROC GETDATAGUS
	pushad


loopsm:
	@print soundmsg
	@print cursor
	call   _getch
	movzx  ax, al
	cmp    al, 14
	je     Dexit
        mov    gdg_string[1], al
	@print gdg_string
	@print enter
	sub    al, 48
	cmp    al, 1
	jb     short loopsm
	cmp    al, 4
	jg     short loopsm
	jl     short musicon
	mov    Muzik, 0
	popad
        ret

; Hay mฃsica... seleccionamos el chip...
musicon:
	mov    Muzik, 1
	cmp    al, 1
	je     short gus
	cmp    al, 2
	je     short guspnp
	cmp    al, 3
	je     short sb

gus:
	mov   xmp_devtype, 10h
	jmp   short looppm
guspnp:
	mov   xmp_devtype, 11h
	jmp   short looppm

sb:
	mov   xmp_devtype, 80h
	jmp   short looppm


; Pilla los datos...
looppm:
	@print getprtmsg
	@print cursor
	call   _getch
	cmp    al, 14
	je     Dexit
	movzx  ax, al
	mov    gdg_string[1], al
	@print gdg_string
	@print enter
	sub    al, 48
	cmp    al, 1
	jb     short looppm
	cmp    al, 6
	jg     short looppm
	shl    ax, 4
	add    ax, 200h
	mov    xmp_devport, ax
	movzx  eax, xmp_devport

loopim:
	@print getirqmsg
	@print cursor
	call   _getch
	cmp    al, 14
	je     Dexit
	movzx  eax, al
	mov    gdg_string[1], al
	@print gdg_string
	@print enter
	sub    al, 48
	cmp    al, 1
	jb     short loopim
	cmp    al, 7
	jg     short loopim
	dec    al
	mov    al, gdg_char[eax]
	mov    xmp_devirq1, al
	mov    xmp_devirq2, al

loopdm:
	@print getdmamsg
	@print cursor
	call   _getch
	cmp    al, 14
	je     Dexit
	movzx  eax, al
	mov    gdg_string[1], al
	@print gdg_string
	@print enter
	sub    al, 48
	cmp    al, 1
	jb     short loopdm
	cmp    al, 5
	jg     short loopdm
	dec    al
	mov    al, gdg_dma[eax]
	mov    xmp_devdma1, al
	mov    xmp_devdma2, al

	popad
	ret
ENDP

;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
;ฑ----------------ณ----------------------------------------------------------ฑ
;ฑ----------------ณ----------------------------------------------------------ฑ
;ฑ PROCEDIMIENTO: ล ALEATORIO                                                ฑ
;ฑ----------------ณ----------------------------------------------------------ฑ
;ฑ----------------ณ----------------------------------------------------------ฑ
;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
seed            dw      723Bh    ; Necesitar s inicializarlo con algo
align 16
                                 ; para que no se repita; ver m s abajo
ALEAT PROC
    push bx cx dx
    mov cl, al

    mov  ax, seed
    mov  dx,5d45h		 ;31415621 and 0ffffh
    inc  ax
    mul  dx
    rol  ax, 2
    mov  seed,ax

    mov bx, ax
    shr bx, cl                   ; 0 a 2048

    mov ax, 0FFFFh
    inc cl
    shr ax, cl

    sub ax, bx                   ; -1024 a 1024
    movsx eax, ax

    pop dx cx bx
    ret

ENDP

;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
;ฑ----------------ณ----------------------------------------------------------ฑ
;ฑ PROCEDIMIENTO: ณ Initstar                                                 ฑ
;ฑ----------------ณ----------------------------------------------------------ฑ
;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
extrn light_table2:dword
;-----------------------------------------------------------------------------
align 16
PROC INITSTAR

; Inicia los datos del fuego y sobreescribe el flare
	call FIREBALL

; Inicia la tabla de los fuegos...
	xor  ax, ax
	xor  esi, esi
	mov  edi, light_table2

loop1:
	xor  ecx, ecx
	xor  ebx, ebx
	mov  bp, ax
	mov  dx, ax
	push bp
	shr  bp, 1
	shr  dx, 2
	add  bp, dx
	pop  dx
	shr  dx, 3
	add  bp, dx
	add  bp, dx

loop2:
	mov  bx, cx
	and  bx, 00011111b		;31
	add  bx, bp

	cmp  bx, 63
	jle  short is@t02
	mov  bx, 63

is@t02:
	cmp  bx, 0
	jge  short is@t03
	xor  bx, bx
is@t03:

	mov  [edi+esi], ebx

	inc  esi
	inc  cx
	cmp  cx, 256
	jne  short loop2

	inc  ax
	cmp  ax, 64
	jb   short loop1

	ret
ENDP


;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
;ฑ----------------ณ----------------------------------------------------------ฑ
;ฑ----------------ณ----------------------------------------------------------ฑ
;ฑ PROCEDIMIENTO: ล EXITDEMO                                                 ฑ
;ฑ----------------ณ----------------------------------------------------------ฑ
;ฑ----------------ณ----------------------------------------------------------ฑ
;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
EXITDEMO PROC

	call  RESETTIMER

	cmp   Muzik, 0
	je    short Muzik2
	call  _XMP_End

Muzik2:
	call  SETTEXT
	@print ENDmsg
	@print enter


; Presenta informaciขn acerca de la tarjeta, animaciขn, etc.

ifdef DEBUG
	mov  eax, timer.tfreq
	mov  edx, eax
	shl  eax, 16
	shr  edx, 16
	mov  ebx, PITFREQ
	idiv ebx
	mov  ebx, eax
	mov  eax, screen.fctr
	mov  edx, eax
	shl  eax, 16
	shr  edx, 16
	idiv ebx

	@print totframe
	mov ecx, screen.fctr
	@printd ecx

	@print tottime
	movzx edx, bx
	shr ebx, 16
	@printd ebx
	@printd edx

	@print fmsxs
	@printd eax

	@print cardspeed
	mov  eax, screen.vgahz
	shr  eax, 16
	@printd eax
	@print enter
endif

ed@nodiv:
Dexit:
	call _resetkb
	jmp  _exit

ENDP

;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
;in:    EDI = palete pointer
;out:   none
extrn   coltab:dword, inccoltab:dword
rotpal1 PROC
        pushad

	cmp    fade, 1
	je     fadetype

	push   edi
	add    edi, 3
        mov    esi, edi
        add    esi, 3

        movzx  ax, [edi]
        push   ax
        movzx  ax, [edi+1]
        push   ax
        movzx  ax, [edi+2]
        push   ax

        mov   ecx, 62*3
        rep   movsb

        pop   ax
        mov   [edi+2], al
        pop   ax
        mov   [edi+1], al
        pop   ax
        mov   [edi], al

	pop   edi
	mov   al, 1
	mov   ecx, 63
	call  SETPAL

        popad
        ret

;---------------------------------------------------------------
; Fade...
fadetype:

	mov    edi, inccoltab
	mov    bp, 2
	jmp    short rp@do1

rp@do2:
	mov    edi, coltab

rp@do1:
	add    edi, 3*4
        mov    esi, edi
        add    esi, 3*4

	mov    eax, [edi]
	push   eax
	mov    eax, [edi+(1*4)]
	push   eax
	mov    eax, [edi+(2*4)]
	push   eax

        mov    ecx, 62*3
        rep    movsd
	      
        pop    eax
        mov    [edi+(2*4)], eax
        pop    eax
        mov    [edi+(1*4)], eax
        pop    eax
        mov    [edi], eax
	      
	dec    bp
	jnz    short rp@do2
 	      
	mov    esi, coltab
	mov    edi, currotpal
	mov    ecx, 768

rp@copypal:
	mov    eax, [esi]
	shr    eax, 16
	mov    [edi], al
	add    esi, 4
	add    edi, 1
	dec    cx
	jnz    short rp@copypal

        popad
        ret

 ENDP

;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
;ฑ----------------ณ----------------------------------------------------------ฑ
;ฑ----------------ณ----------------------------------------------------------ฑ
;ฑ PROCEDIMIENTO: ล WAITSONG                                                 ฑ
;ฑ----------------ณ----------------------------------------------------------ฑ
;ฑ----------------ณ- AX: Tiempo a esperar manualmente -----------------------ฑ
;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
WAITSONG PROC

	cmp   Muzik, 0
	je    short ws@timerwait

ws@xmwait:
	cmp   xmp_flag, 0
	je    short ws@xmwait
	mov   xmp_flag, 0
	jmp   short ws@letsgo

ws@timerwait:
 	call  WAITTIME

ws@letsgo:
	ret

ENDP
ends
;=============================================================================
;ฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐ
;ฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐ
end
