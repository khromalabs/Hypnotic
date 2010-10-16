;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
;ฑ                        <<  H Y P N O T I C  >>                            ฑ
;ฑ-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-ฑ
;ฑ                         1996 Exobit Productions                           ฑ
;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ


  .386p
  locals

DEBUG  = 1
MUZIK  = 1

EXOLOGO = 1
HYPLOGO = 1
BUBBLE	= 1
PLANET	= 1
DANCER	= 1

BURBUJAS = 10
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

ifdef MUZIK
    include xmp.inc
endif

    public _main
    extrn  TEXT_SCROLL:near
    extrn  CLSIMG:near
    extrn  timer:TimerINFO
    extrn  screen:ScreenINFO

    extrn  hyplogo:near
    extrn  exologo:near
    extrn  planetpal:near
    extrn  skypal:near
    extrn  dancer:near

;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
;  D a t o s
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
; Paletas...
align 4

palbuf      dd   0
palnul      dd   0

; Datos 3D
include path.inc
camera      dot3d   ?


; Mensajes del programa
pmodetypes  db    "RAW $", "XMS $", "VCPI$", "DPMI??",13,10,"$"
mode_msg    db    13,10, " ๐ PMODE type: $"
lomem_msg   db    13,10, " þ Free low memory: $"
himem_msg   db    13,10, " þ Free extended memory: $"

novga_msg   db    13,10, "No VGA detected!", 13,10, "$"
nomem_msg   db    13,10, "Insuficient memory!", 13,10, "$"
noshp_msg00 db    13,10, "Shape file not found!", 13,10, "$"
noshp_msg01 db    13,10, "Can't read the shape!", 13,10, "$"
noshp_msg03 db    13,10, "The file isn't a shape file!", 13,10, "$"
noshp_msg04 db    13,10, "Unknow error reading shape!!!", 13,10, "$"


DPMImsg     db    13,10, "Hey man, did you really think that this kind of stuff"
	    db    13,10, "will work with this shit? :)", 13,10
	    db    13,10, "Install a XMS or EMS server, please ;)", 13,10, "$"

; Setup data
soundmsg    db    13,10, "Sound:"
	    db    13,10, "   1)   GUS"
	    db    13,10, "   2)   No sound"
            db    13,10, "   Esc) Cancel", "$"
getprtmsg   db    13,10, "Enter GUS baseport:"
	    db    13,10, "   1)   210h"
	    db    13,10, "   2)   220h"
	    db    13,10, "   3)   230h"
	    db    13,10, "   4)   240h"
	    db    13,10, "   5)   250h"
	    db    13,10, "   6)   260h"
            db    13,10, "   Esc) Cancel", "$"
getirqmsg   db    13,10, "Enter GUS Irq:"
	    db    13,10, "   1)   1"
	    db    13,10, "   2)   3"
	    db    13,10, "   3)   5"
	    db    13,10, "   4)   7"
	    db    13,10, "   5)   11"
	    db    13,10, "   6)   12"
	    db    13,10, "   7)   15"
            db    13,10, "   Esc) Cancel", "$"
cursor      db    13,10, ">", "$"
enter       db    13,10, '$'
Muzik       db    0

ifdef DEBUG
npolys_msg  db    13,10, " þ Number of polys: $"
nverts_msg  db    13,10, " þ Number of verts: $"
tottime     db	  13,10, "Total secs:   $"
totframe    db	  13,10, "Total frames: $"
fmsxs	    db	  13,10, "Frames/sec:   $"
cardspeed   db	  13,10, "VGA Hz:       $"
endif


; Datos de los ficheros
xm_file     db    "player\hypdemo.xm", 0

; Mapa de la piva...
FCara       db	  "temp\caratext.dat",0
FCaraptr    dd	   ?

; Mapa de presentaciขn...
FExologo    db	  "temp\exologo.dat",0
FExologoptr dd	   ?

; Mapa de logo con Motion Blur...
Thyp1       db	  "temp\env-hypc.dat",0
Thyp1ptr    dd	   ?
Thyp2       db	  "temp\env-hypn.dat",0
Thyp2ptr    dd	   ?

; Mapas de la escena de cielo
Fsky	    db	  "temp\sky.dat",0
Fskyptr     dd	   ?
Tsky	    db	  "temp\skymap.dat",0
Tskyptr     dd	   ?
Tsky2	    db	  "temp\skymap2.dat",0
Tskyptr2    dd	   ?


; Flags de la scena
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

; Flags de la scena
bailaor     db		?


; Mapas de la escena del mundo
FSpace	    db	  "temp\space2.dat",0
FSpaceptr   dd	   ?
Tcasa	    db	  "temp\pl-home.dat",0
Tcasaptr    dd	   ?
Ttecho	    db	  "temp\pl-tech.dat",0
Ttechoptr   dd	   ?
Ttree	    db	  "temp\pl-tree1.dat",0
Ttreeptr    dd	   ?
Tarbol	    db	  "temp\pl-sue5.dat",0
Tarbolptr   dd	   ?
Tcamino	    db	  "temp\pl-camn.dat",0
Tcaminoptr  dd	   ?
Tsue1	    db	  "temp\pl-sue1.dat",0
Tsue1ptr    dd	   ?
Tsue2	    db	  "temp\pl-sue2.dat",0
Tsue2ptr    dd	   ?
Tsue3	    db	  "temp\pl-sue3.dat",0
Tsue3ptr    dd	   ?
Tsue4	    db	  "temp\pl-sue4.dat",0
Tsue4ptr    dd	   ?


; Mapas de la escena del bailaข :)
Tdancer1    db	  "temp\env-fblu.dat",0
Tdancer1ptr dd	   ?
Tdancer1b   db	  "temp\env-fred.dat",0
Tdancer1ptrb dd	   ?

Tdancer2    db	  "temp\env-bblu.dat",0
Tdancer2ptr dd	   ?
Tdancer2b   db	  "temp\env-bred.dat",0
Tdancer2ptrb dd	   ?




; M E S H E S
Sbug     db "temp\burbu.shp",0
Nbug     db	?

Shyplog  db "temp\hypnlog.shp",0
Nhyplog  db	?

Sburbu	  db "temp\burbu.shp",0
Nburbu	  db	BURBUJAS dup(?)
Mburbu	  db	BURBUJAS dup(?)

Smale     db "temp\male.shp",0
Nmale	  db	?

Smorsmile db "temp\morsmiley.shp",0
Nmorsmile db	?
Mmorsmile db	?

Sdevsmile db "temp\devsmiley.shp",0
Ndevsmile db	?

Speace    db "temp\peace.shp",0
Npeace	  db	?

Sfemale   db "temp\female.shp",0
Nfemale	  db	?

S3dmotion db "temp\3dmotion.shp", 0
N3dmotion db	?

Smuznplay db "temp\muznplay.shp",0
Nmuznplay db	?

Sart      db "temp\art.shp",0
Nart	  db	?

Skhroma	  db "temp\khroma.shp", 0
Nkhroma	  db	?

Smentat	  db "temp\darkment.shp", 0
Nmentat	  db	?

Smentat2  db "temp\darkment.shp", 0
Nmentat2  db	?


Sartqvo   db "temp\artqvo.shp", 0
Nartqvo	  db	?

Splanet   db "temp\planet.shp",0
Nplanet	  db	?

Sdancer   db "temp\dancer.shp",0
Ndancer	  db	?
Mdancer   db	?


rrcount	  db	?


ifdef MUZIK
msg01	db 13,10,'Initializing instruments...',13,10,'$'
msg02	db 'Clean exit. Hope it runs OK.',13,10,'$'

msgr00	db 'Reading file...',13,10,'$'
msgr01	db ' _readfile:     file succesfully loaded',13,10,13,10,'$'
msgr10	db ' _getmem:       not enough mem to read file',13,10,'$'
msgr11	db ' _getlomem:     not enough low mem for buffers',13,10,'$'
msgr20	db ' _openfile:     file does not exist',13,10,'$'
msgr21	db ' _readfile:     error reading file',13,10,'$'

msgx00	db 'Starting music system...',13,10,'$'
msgx01	db ' _XMP: soundcard initialized',13,10,'$'
msgx02	db ' _XMP: module loaded on soundcard',13,10,13,10,'$'
msgx10	db ' _XMP: file is not a XM',13,10,'$'
msgx11	db ' _XMP: not enough memory',13,10,'$'
msgx12	db ' _XMP: too many channels',13,10,'$'
msgx20	db ' _XMP: soundcard not found',13,10,'$'
msgx21	db ' _XMP: not enough wavetable mem',13,10,'$'
msgxF0	db ' _XMP: unknown error',13,10,'$'
endif


;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
;  C ข d i g o
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
 _main:
	sti

; Presenta informaciขn acerca del sistema
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
	call _himemsize
	@printmd himem_msg, eax
	@print enter

; Sitฃa el bufer en memoria baja (Por si las moscas)
	movzx eax, _filebuflen
	call _getlomem
	jc  E_nomem
	mov _filebufloc, eax


; XMP initialization
ifdef MUZIK
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
;	call _XMP_Detect
	call GETDATAGUS
	cmp  Muzik, 0
	je   NoMuzik

	@print msg01
	mov xmp_devtype, 10h            ; Settings for GUS
	mov xmp_devmem, 1024*1024       ; 1Mb

	call _XMP_Init

	test al, al
	jnz @xmperror


; ฤฤ XM Reading Stuff ฤฤฤฤฤฤฤ
	mov edx, offset xm_file	        ; Could the file be opened?
	call _openfile
	jc noopen                       ; No -> jump to noopen

	call _filesize                  ; Once opened we've to obtain the size
	mov ebp, eax                    ; and store it in EBP to
	push _himembase
	call _gethimem                  ; allocate memory (high or low)
	pop  _himembase
	jc nomem                        ; Not enough -> jump to nomem

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
endif
NoMuzik:

;อ PASO 1: LEER TODOS LOS MAPAS EN MEMORIA ออออออออออออออออออออออออออออออออออ

; ฤฤฤฤ Fondos ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	lea   edx, FCara
	call  LOADPICTURE
	jc    E_nomem
	mov   FCaraptr, eax
	mov   edi, eax
	mov   ecx, 320*240
	call  INITMAP
	jc    E_nomem

	lea   edx, FExologo
	call  LOADPICTURE
	jc    E_nomem
	mov   FExologoptr, eax
	mov   edi, eax
	mov   ecx, 320*240
	call  INITMAP
	jc    E_nomem


	lea   edx, Fsky
	call  LOADPICTURE
	jc    E_nomem
	mov   Fskyptr, eax
	mov   edi, eax
	mov   ecx, 320*240
	call  INITMAP
	jc    E_nomem


	lea   edx, FSpace
	call  LOADPICTURE
	jc    E_nomem
	mov   FSpaceptr, eax
	mov   edi, eax
	mov   ecx, 320*240
	call  INITMAP
	jc    E_nomem

; ฤฤฤฤ Texturas ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	lea   edx, Thyp1
	call  LOADPICTURE
	jc    E_nomem
	mov   Thyp1ptr, eax

	lea   edx, Thyp2
	call  LOADPICTURE
	jc    E_nomem
	mov   Thyp2ptr, eax
	clc

	lea   edx, Tsky
	call  LOADPICTURE
	jc    E_nomem
	mov   Tskyptr, eax

	lea   edx, Tsky2
	call  LOADPICTURE
	jc    E_nomem
	mov   Tskyptr2, eax

	lea   edx, Tcasa
	call  LOADPICTURE
	jc    E_nomem
	mov   Tcasaptr, eax

	lea   edx, Ttecho
	call  LOADPICTURE
	jc    E_nomem
	mov   Ttechoptr, eax

	lea   edx, Ttree
	call  LOADPICTURE
	jc    E_nomem
	mov   Ttreeptr, eax

	lea   edx, Tarbol
	call  LOADPICTURE
	jc    E_nomem
	mov   Tarbolptr, eax

	lea   edx, Tcamino
	call  LOADPICTURE
	jc    E_nomem
	mov   Tcaminoptr, eax

	lea   edx, Tsue1
	call  LOADPICTURE
	jc    E_nomem
	mov   Tsue1ptr, eax

	lea   edx, Tsue2
	call  LOADPICTURE
	jc    E_nomem
	mov   Tsue2ptr, eax

	lea   edx, Tsue3
	call  LOADPICTURE
	jc    E_nomem
	mov   Tsue3ptr, eax

	lea   edx, Tsue4
	call  LOADPICTURE
	jc    E_nomem
	mov   Tsue4ptr, eax

	lea   edx, Tdancer2
	call  LOADPICTURE
	jc    E_nomem
	mov   Tdancer2ptr, eax

	lea   edx, Tdancer1
	call  LOADPICTURE
	jc    E_nomem
	mov   Tdancer1ptr, eax

;	lea   edx, Tdancer2b
;	call  LOADPICTURE
;	jc    E_nomem
;	mov   Tdancer2ptrb, eax

;	lea   edx, Tdancer1b
;	call  LOADPICTURE
;	jc    E_nomem
;       mov   Tdancer1ptrb, eax

;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

;อ PASO 2: LEER TODOS LOS OBJETOS EN MEMORIA ออออออออออออออออออออออออออออออออ
         xor   eax, eax

; PUฅETERO BUG!!! จpor qu cojones ocurre esto? :-? :'(((
	mov   edx, offset Sbug
        mov   al, 0
	call  LOADOBJECT
	jc    E_noshp
;	mov   Nbug, al
; PUฅETERO BUG!!!


	mov   edx, offset Smale
        mov   al, 0
	call  LOADOBJECT
	jc    E_noshp
	mov   Nmale, al

	mov   edx, offset S3dmotion
        mov   al, 0
	call  LOADOBJECT
	jc    E_noshp
	mov   N3dmotion, al


	mov   edx, offset Smuznplay
        mov   al, 0
	call  LOADOBJECT
	jc    E_noshp
	mov   Nmuznplay, al

	mov   edx, offset Sart
        mov   al, 0
	call  LOADOBJECT
	jc    E_noshp
	mov   Nart, al

	mov   edx, offset Skhroma
        mov   al, 0
	call  LOADOBJECT
	jc    E_noshp
	mov   Nkhroma, al

	mov   edx, offset Smentat
        mov   al, 0
	call  LOADOBJECT
	jc    E_noshp
	mov   Nmentat, al

	mov   edx, offset Sartqvo
        mov   al, 0
	call  LOADOBJECT
	jc    E_noshp
	mov   Nartqvo, al

	mov   edx, offset Smorsmile
        mov   al, 0
	call  LOADOBJECT
	jc    E_noshp
	mov   Nmorsmile, al
	mov   Mmorsmile, bl

	mov   edx, offset Sdevsmile
        mov   al, 0
	call  LOADOBJECT
	jc    E_noshp
	mov   Ndevsmile, al

	mov   edx, offset Splanet
        mov   al, 1
	call  LOADOBJECT
	jc    E_noshp
	mov   Nplanet, al


	mov   edx, offset Sfemale
        mov   al, 0
	call  LOADOBJECT
	jc    E_noshp
	mov   Nfemale, al

	mov   edx, offset Sdancer
        mov   al, 0
	call  LOADOBJECT
	jc    E_noshp
	mov   Ndancer, al
	mov   Mdancer, bl

	mov   edx, offset Speace
        mov   al, 0
	call  LOADOBJECT
	jc    E_noshp
	mov   Npeace, al


	xor   ecx, ecx
Burbloop:
	mov   edx, offset Sburbu
        mov   al, 0
	call  LOADOBJECT
	jc    E_noshp
	mov   Nburbu[ecx], al
	mov   Mburbu[ecx], bl

	inc   ecx
	cmp   ecx, BURBUJAS
	jb    short Burbloop


	mov   edx, offset Shyplog
        mov   al, 0
	call  LOADOBJECT
	jc    E_noshp
	mov   Nhyplog, al
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	call _lomemsize
	@printmd lomem_msg, eax
	call _himemsize
	@printmd himem_msg, eax
	@print enter
	call _getch
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

 ;Inicia la paleta
@palini:mov   eax, 768*2
        call  _getmem
        jc    E_nomem

        mov   palbuf, eax
        add   eax, 768
        mov   palnul, eax

; Inicia el sistema
	call  TESTVGA
	jc    E_novga

	mov   edi, palbuf
	mov   al, 0
	mov   ah, 255
	call  GETPAL
	call  FADEOUT
	mov   edi, palnul
	mov   al, 0
	mov   ah, 255
	call  GETPAL

	call  SET320240

	mov   edi, palnul
	call  SETPAL
	call  INITTIMER


	mov   edi, TheWorld

ifdef MUZIK
	cmp   Muzik, 0
	je    short Muzik1

	call _XMP_Play
	test al, al
	jnz @xmperror
endif
Muzik1:

ifdef EXOLOGO
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ  PANTALLA DE PRESENTACION ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
;	mov   xmp_flag, 0

	mov   edi, FExologoptr
	mov   al, 1
	call  SETBACKGND

	call  CLSIMG
	call  IMAGEN

        lea   edi, exologo
	mov   al, 0
	mov   ah, 255
	call  FADEIN

        cmp   Muzik, 0
        je    short pitwait1

xmwait1:
	cmp   xmp_flag, 0
	je    short xmwait1
	mov   xmp_flag, 0
        jmp   short letsgo1

pitwait1:
 	mov   ax, 5
 	mov   ax, 11
 	call  WAITTIME


letsgo1:
        lea   edi, exologo
	mov   al, 0
	mov   ah, 255
	call  FADEOUT


        cmp   Muzik, 0
        je    short letsgo2

xmwait2:
	cmp   xmp_flag, 0
	je    short xmwait2
	mov   xmp_flag, 0

letsgo2:


;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
endif

ifdef HYPLOGO
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;ฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐ MOTION BLUR ฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐ
 RTYPE = BLUR OR ENVMAP

	mov   camera.x, 0*UNO
	mov   camera.y, 0*UNO
	mov   camera.z, -400*UNO

	mov   edi, Thyp1ptr
	xor   al, al
        call  INITTEXT

	mov   edi, Thyp2ptr
	mov   al, 1
        call  INITTEXT

	mov   al, 0
	call  SETBACKGND

	mov   ebx, 15
;	mov   ecx, 30
	mov   ecx, 24
	lea   edx, hyppat
	movzx ebp, Nhyplog
	call  INITPATH

	mov   al, 1
	mov   bl, Nhyplog
	call  SETRFLAG

        lea   edi, camera
	mov   al, RTYPE
	call  RENDER
	call  IMAGEN

        lea   edi, hyplogo
	mov   al, 0
	mov   ah, 255
;	call  FADEIN
	call  SETPAL

	mov   timer.tfreq, 0
	mov   screen.fctr, 0
	mov   timer.rcount, 0
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
@pathl2:lea   edi, camera
	mov   al, RTYPE
	call  RENDER
	call  IMAGEN

	xor   ecx, ecx
	movzx ebx, rrcount

	movzx ebp, Nhyplog
	call  TRACEPATH

	mov   timer.rcount, 0
	jnc   short @pathl2
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
        lea   edi, hyplogo
	mov   al, 0
	mov   ah, 255
	call  FADEOUT

	mov   al, 0
	mov   bl, Nhyplog
	call  SETRFLAG


        cmp   Muzik, 0
        je    short letsgo3

xmwait3:
	cmp   xmp_flag, 0
	je    short xmwait3
	mov   xmp_flag, 0

letsgo3:



;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
endif


ifdef BUBBLE
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ  ESCENA DE LAS BURBUJAS ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
 RTYPE = ENVMAP OR TRANS

; Flags de la scena
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


	mov   camera.x, 0*UNO
	mov   camera.y, 0*UNO
	mov   camera.z, -8000*UNO

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

noalea:	;mov   ecx, 6
        mov   ecx, 1


inipath:xor   eax, eax
        mov   ebx, 1
        lea   edx, bur1[edi]
        movzx ebp, Nburbu[esi]
        call  INITPATH

	mov   ecx, 30
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
;	mov   ecx, 9
	mov   ecx, 9
	lea   edx, Ppeace
	movzx ebp, Npeace
	call  INITPATH


	xor   eax, eax
	mov   ebx, 2
;	mov   ecx, 15
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
	mov   ecx, 11
	lea   edx, smlseq
	movzx eax, Mmorsmile
	call  INITMORPH


	xor   eax, eax
	mov   ebx, 7
;	mov   ecx, 17
 	mov   ecx, 15
	lea   edx, Pmale
	movzx ebp, Nmale
	call  INITPATH

	xor   eax, eax
	mov   ebx, 7
;       mov   ecx, 17
	mov   ecx, 15
	lea   edx, Pfemale
	movzx ebp, Nfemale
	call  INITPATH

	xor   eax, eax
	mov   ebx, 3
;	mov   ecx, 12
	mov   ecx, 10
	lea   edx, Pdo
	movzx ebp, N3dmotion
	call  INITPATH

	xor   eax, eax
	mov   ebx, 3
;	mov   ecx, 12
	mov   ecx, 10
	lea   edx, Pdo
	movzx ebp, Nmuznplay
	call  INITPATH

	xor   eax, eax
	mov   ebx, 3
;	mov   ecx, 14
  	mov   ecx, 12
	lea   edx, Pdo
	movzx ebp, Nart
	call  INITPATH

	xor   eax, eax
        mov   ebx, 3
;	mov   ecx, 11
	mov   ecx, 12
	lea   edx, Pname
	movzx ebp, Nkhroma
	call  INITPATH

	xor   eax, eax
	mov   ebx, 3
;	mov   ecx, 14
	mov   ecx, 12
	lea   edx, Pname2
	movzx ebp, Nmentat
	call  INITPATH

	xor   eax, eax
	mov   ebx, 3
;	mov   ecx, 14
 	mov   ecx, 12
	lea   edx, Pname3
	movzx ebp, Nartqvo
	call  INITPATH


	lea   edi, camera
	mov   al, RTYPE
	call  RENDER
	call  IMAGEN

        lea   edi, skypal
	mov   al, 0
	mov   ah, 255
	call  FADEIN

;	mov   timer.tfreq, 0
;	mov   screen.fctr, 0
        mov   timer.rcount, 0
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
@pathl:	lea   edi, camera
	mov   al, RTYPE
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
	call  TRACEMORPH
	jc    evaluate

burendloop2:
	inc   ecx
	cmp   ecx, BURBUJAS
	jb    short burendloop

	cmp   peace, 1
	jne   Emale
	movzx ebp, Npeace
	call  TRACEPATH
	jnc   short Emale
	mov   peace, 0
	mov   al, 0
	mov   bl, Npeace
	call  SETRFLAG

Emale:	cmp   male, 1
	jne   Efemale
	movzx ebp, Nmale
	call  TRACEPATH
	jnc   short Efemale
	mov   male, 0
	mov   al, 0
	mov   bl, Nmale
	call  SETRFLAG

Efemale:cmp   female, 1
	jne   Emorsmile
	movzx ebp, Nfemale
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
	call  TRACEPATH
	jc    short Cmorsmile
	movzx eax, Mmorsmile
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
	call  TRACEPATH
	jnc   short Ecode
	mov   devsmile, 0
	mov   al, 0
	mov   bl, Ndevsmile
	call  SETRFLAG

Ecode:	cmp   code, 1
	jne   Ekhroma
	movzx ebp, N3dmotion
	call  TRACEPATH
	jnc   short Ekhroma
	mov   code, 0
	mov   al, 0
	mov   bl, N3dmotion
	call  SETRFLAG

Ekhroma:cmp   khroma, 1
	jne   Eart
	movzx ebp, Nkhroma
	call  TRACEPATH
	jnc   short Eart
	mov   khroma, 0
	mov   al, 0
	mov   bl, Nkhroma
	call  SETRFLAG

Eart:	cmp   art, 1
	jne   Eartqvo
	movzx ebp, Nart
	call  TRACEPATH
	jnc   short Eartqvo
	mov   art, 0
	mov   al, 0
	mov   bl, Nart
	call  SETRFLAG


Eartqvo:cmp   artqvo, 1
	jne   Ementat
        movzx ebp, Nartqvo
	call  TRACEPATH
	jnc   short Ementat
	mov   artqvo, 0
	mov   al, 0
	mov   bl, Nartqvo
	call  SETRFLAG

Ementat:cmp   mentat, 1
	jne   Emusic
        movzx ebp, Nmentat
	call  TRACEPATH
	jnc   short Emusic
	mov   mentat, 0
	mov   al, 0
	mov   bl, Nmentat
	call  SETRFLAG

Emusic:	cmp   music, 1
	jne   Ementat2
	movzx ebp, Nmuznplay
	call  TRACEPATH
	jnc   short Ementat2
	mov   music, 0
	mov   al, 0
	mov   bl, Nmuznplay
	call  SETRFLAG

Ementat2:
	cmp   mentat2, 1
	jne   Eend
	movzx ebp, Nmentat
	call  TRACEPATH
	jnc   short Eend
	mov   mentat2, 0
	mov   al, 0
	mov   bl, Nmentat
	call  SETRFLAG

Eend:	mov   ax, timer.rcount
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
	shl   eax, 14
	mov   bur1[edx].z, eax
	mov   bur1[edx+(size dot3d*2)].z, eax


	test  esi, esi
	jz    noalea2
	mov   ax, 13
	call  ALEAT
	add   eax, 8
	mov   ecx, eax
	jmp   inipath2

noalea2: ;mov   ecx, 6
        mov ecx, 5
inipath2:
	xor   eax, eax
	mov   ebx, 1
	lea   edx, bur1[edx]
	movzx ebp, Nburbu[esi]
	call  INITPATH

	mov   ecx, 30
	mov   ebx, 50
	movzx eax, Mburbu[esi]
	lea   edx, burseq1
	call  INITMORPH
	popad

	jmp   burendloop2


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
	jmp   burp

nextp7:	cmp   seq, 7
	jne   short nextp8
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
	mov   bl, Nmentat
	call  SETRFLAG
	mov   al, 1
	mov   bl, Nartqvo
	call  SETRFLAG
	mov   art, 1
	mov   artqvo, 1
	mov   mentat, 1
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
;	mov   ecx, 12
 	mov   ecx, 11
	lea   edx, Pname
	movzx ebp, Nmentat
	call  INITPATH
	popad
	mov   mentat, 0
	mov   music, 1
	mov   mentat2, 1
	jmp   burp

nextp13:cmp   seq,13
	jne   short nextp14
	jmp   burp

nextp14:
;       lea   edi, skypal
;	mov   al, 0
;	mov   ah, 255
;	call  FADEOUT

; Turns off bubbles...
	mov   ecx, 0
cbubbleloop:
	mov   al, 0
	mov   bl, Nburbu[ecx]
	call  SETRFLAG
	inc   ecx
	cmp   ecx, BURBUJAS
	jne   cbubbleloop
	mov   al, 0
	mov   bl, Nmentat
	call  SETRFLAG
	mov   al, 0
	mov   bl, Nmuznplay
	call  SETRFLAG

;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
endif

ifdef PLANET
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ  ESCENA DEL PLANETA ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
 RTYPE = GOURAUD OR TEXTMAP
        mov   seq, 0

	mov   camera.x, 0*UNO
	mov   camera.y, 0*UNO
	mov   camera.z, -2000*UNO


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

	mov   edi, FSpaceptr
	mov   al, 1
	call  SETBACKGND

	mov   ebx, 5
;	mov   ecx, 30
	mov   ecx, 20
	lea   edx, planet
	movzx ebp, Nplanet
	call  INITPATH

	mov   edi, TheWorld
	lea   eax, [edi].light
	mov   [edi].obj[200*4], eax

	mov   ebx, 8+4+4
;	mov   ecx, 30
	mov   ecx, 19
	lea   edx, luzmov
	mov   ebp, 200
	call  INITPATH

	mov   al, 1
	mov   bl, Nplanet
	call  SETRFLAG

	lea   edi, camera
	mov   al, RTYPE
        call  RENDER
 	call  CLSIMG
	call  IMAGEN

        cmp   Muzik, 0
        je    short letsgo4

xmwait4:
	cmp   xmp_flag, 0
	je    short xmwait4
	mov   xmp_flag, 0

letsgo4:
        lea   edi, planetpal
	mov   al, 0
	mov   ah, 255
;	call  FADEIN
	call  SETPAL

;	mov   timer.tfreq, 0
;	mov   screen.fctr, 0
	mov   timer.rcount, 0
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
@pathl3:lea   edi, camera
	mov   al, RTYPE
 	call  RENDER
	call  IMAGEN

        xor   ecx, ecx
	mov   bx, timer.rcount
	mov   rrcount, bl

	movzx ebx, rrcount
	movzx ebp, Nplanet
	call  TRACEPATH
	jc    endplanet

	cmp   seq, 1
	jne   doloopplanet
	movzx ebx, rrcount
	mov   ebp, 200
	call  TRACEPATH
	jc    endplanet2

doloopplanet:
	mov   ax, timer.rcount
	xor   bx, bx
	mov   bl, rrcount
	sub   ax, bx
	mov   timer.rcount, ax

	jnc   short @pathl3
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
endplanet:
	inc   seq
	cmp   seq, 2
	je    short endplanet2

	mov   ebx, 5
;	mov   ecx, 30
	mov   ecx, 19
	lea   edx, planet2
	movzx ebp, Nplanet
	call  INITPATH

	jmp   @pathl3

 
endplanet2:
	mov   al, 0
	mov   bl, Nplanet
	call  SETRFLAG

        lea   edi, planetpal
	mov   al, 0
	mov   ah, 255
	call  FADEOUT


; Y las im genes de fondo
; ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
; --------------------------------------------------------------------------
; --------------------------------------------------------------------------
; --------------------------------------------------------------------------
; --------------------------------------------------------------------------
; --------------------------------------------------------------------------
endif

ifdef DANCER
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
; ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ  ESCENA DEL DANCER  ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
 RTYPE = ENVMAP

        cmp   Muzik, 0
        je    short letsgo5

xmwait5:
	cmp   xmp_flag, 0
	je    short xmwait5
	mov   xmp_flag, 0

letsgo5:


	mov   seq, 0

	mov   camera.x, 0*UNO
	mov   camera.y, 0*UNO
	mov   camera.z, -1000*UNO

	mov   al, 0
	call  SETBACKGND
	call  CLSIMG
	call  IMAGEN

	mov   edi, Tdancer1ptr
	mov   al, 9 
        call  INITTEXT

	mov   edi, Tdancer2ptr
	mov   al, 1
        call  INITTEXT

	mov   ebx, 1
 	mov   ecx, 60
;       mov   ecx, 13
	lea   edx, Pdancer
	movzx ebp, Ndancer
	call  INITPATH

; Se pone de pie
	mov   ebx, 8
; 	mov   ecx, 5
  	mov   ecx, 11
	movzx eax, Mdancer
	lea   edx, Seqdancer0
	call  INITMORPH

	mov   al, 1
	mov   bl, Ndancer
	call  SETRFLAG

	lea   edi, camera
	mov   al, RTYPE
	call  RENDER
	call  IMAGEN

        lea   edi, dancer
	mov   al, 0
	mov   ah, 255
	call  FADEIN

;	mov   bailaor, 8

;	mov   timer.tfreq, 0
;	mov   screen.fctr, 0
	mov   timer.rcount, 0
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
loop4:
@pathl4:lea   edi, camera
	mov   al, RTYPE
	call  RENDER
	call  IMAGEN

	xor   ecx, ecx
	mov   bx, timer.rcount
	mov   rrcount, bl

	movzx ebx, rrcount

	movzx ebp, Ndancer
	call  TRACEPATH
	jc    short pseq
	movzx eax, Mdancer
	call  TRACEMORPH
	jc    short pseq

;loop4:
	mov   ax, timer.rcount
	xor   bx, bx
	mov   bl, rrcount
	sub   ax, bx
	mov   timer.rcount, ax

	jmp   @pathl4

;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ


; Baile
pseq:
	inc   seq
	cmp   seq, 20
	je    dycierre

        cmp   seq, 1
        je    baile1
        cmp   seq, 6
        jb    baile1
        cmp   seq, 7
        jb    baile2
        cmp   seq, 13
        jb    baile1
        cmp   seq, 15
        jb    baile2
        jmp   baile3


baile0:
	mov   ebx, 8
; 	mov   ecx, 5
  	mov   ecx, 2
	movzx eax, Mdancer
	lea   edx, Seqdancer1
	call  INITMORPH
	jmp   loop4



baile1:

	mov   ebx, 8
;	mov   ecx, 4
 	mov   ecx, 2
 	movzx eax, Mdancer
	lea   edx, SeqdancerA
	call  INITMORPH
	jmp   loop4



baile2:	mov   ebx, 8
;	mov   ecx, 5
	mov   ecx, 2
	movzx eax, Mdancer
	lea   edx, SeqdancerC
	call  INITMORPH

	mov   ebx, 4
 	mov   ecx, 2
	lea   edx, Pdancer2
	movzx ebp, Ndancer
	call  INITPATH

	jmp   loop4


baile3:	mov   ebx, 8
;	mov   ecx, 5
	mov   ecx, 2
	movzx eax, Mdancer
	lea   edx, SeqdancerD
	call  INITMORPH

	mov   ebx, 4
 	mov   ecx, 2
;       mov   ecx, 13
	lea   edx, Pdancer2
	movzx ebp, Ndancer
	call  INITPATH

	jmp   loop4



dycierre:
        lea   edi, dancer
	mov   al, 0
	mov   ah, 255
	call  FADEOUT
	call  CLSIMG
	call  IMAGEN

;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
endif									     

	push  timer.tfreq


	call  RESETTIMER


ifdef MUZIK
	cmp   Muzik, 0
	je    short Muzik2
	call  _XMP_End
endif

Muzik2:
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	call  SETTEXT
;	call  TEXT_SCROLL
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	@print enter


; Presenta informaciขn acerca de la tarjeta, animaciขn, etc.
	pop  eax

ifdef DEBUG
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

	jmp   Dexit

;=== ERRORS 3D ENGINE =======================================================
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

ifdef MUZIK
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
;	cmp al, 022h
;	je xmpe22
	jmp xmpeF0
;-----------------------------------------------------------------------------
nopara:
	@print msg01
	jmp Dexit
;-----------------------------------------------------------------------------
nolowmem:
	@print msgr11
	jmp Dexit
;-----------------------------------------------------------------------------
noopen:
	@print msgr20
	jmp Dexit
;-----------------------------------------------------------------------------
nomem:
	@print msgr10
	jmp Dexit
;-----------------------------------------------------------------------------
noread:
	@print msgr21
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
;xmpe22:
;	@print msgx22
;	jmp Dexit
xmpeF0:
	@print msgxF0
;=============================================================================
endif

Dexit:
	call _resetkb
	jmp  _exit


;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
;ฑ----------------ณ----------------------------------------------------------ฑ
;ฑ----------------ณ----------------------------------------------------------ฑ
;ฑ PROCEDIMIENTO: ล GETDATAGUS                                               ฑ
;ฑ----------------ณ----------------------------------------------------------ฑ
;ฑ----------------ณ----------------------------------------------------------ฑ
;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
gdg_string	db	" K$"
gdg_char	db	1,3,5,7,11,12,15

PROC GETDATAGUS
	pushad


loopsm:
	@print soundmsg
	@print cursor
	call   _getch
	movzx  ax, al
	cmp    al, 14
	je     short Dexit
        mov    gdg_string[1], al
	@print gdg_string
	@print enter
	sub    al, 48
	cmp    al, 1
	jb     short loopsm
	je     short musicon
	cmp    al, 2
	jg     short loopsm
	mov    Muzik, 0
	popad
        ret

musicon:
	mov    Muzik, 1

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

	popad
	ret
ENDP
;=============================================================================
;ฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐ
;ฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐ
;ฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐ

;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
;ฑ----------------ณ----------------------------------------------------------ฑ
;ฑ----------------ณ----------------------------------------------------------ฑ
;ฑ PROCEDIMIENTO: ล ALEATORIO                                                ฑ
;ฑ----------------ณ----------------------------------------------------------ฑ
;ฑ----------------ณ----------------------------------------------------------ฑ
;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
seed            dw      723Bh    ; Necesitar s inicializarlo con algo
                                 ; para que no se repita; ver m s abajo
ALEAT PROC
    push bx cx
    mov cl, al

    mov ax, seed
    add ax, ax
    jnc short aleat_1
    xor ax, 2293h                   ; Este es el polinomio generador de CRC
aleat_1:
    mov seed, ax
    mov bx, ax
    shr bx, cl                      ; 0 a 2048

    mov ax, 0FFFFh
    inc cl
    shr ax, cl

    sub ax, bx                      ; -1024 a 1024
    movsx eax, ax

    pop cx bx
    ret

ENDP
ends
end
