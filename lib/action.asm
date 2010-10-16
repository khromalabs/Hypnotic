;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±                             THE EXOBIT... DEMO                            ±
;±-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-±
;±                         1996 Exobit Productions                           ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


  .386p
  locals

 DEBUG = 1
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  D e f i n i c i o n e s
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;code32  segment para public use32
; 	 assume cs:code32, ds:code32

    include pmodedvt.inc
    include 3deng.inc
    include structs.inc
    include file.inc
    include kb.inc
    include argc.inc
    include debug.inc

    public _main
    extrn  TEXT_SCROLL:near
    extrn  timer:TimerINFO
    extrn  screen:ScreenINFO
    extrn  image:byte, FADEOUTW:near, FADEINW:near

    extrn  VTBeginSync:near, VTWaitForStart:near, InitMusic:near
    extrn  VTSetSoundVolume:near, VTDisconnectTimer:near

    
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  D a t o s
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Paletas...
align 4

paldisk	label byte
include pal.inc

pal2   	label byte
include scr.inc

palbuf      dd   0
palnul      dd   0

; Datos 3D
include path.inc
camera      dot3d   ?


; Mensajes del programa
pmodetypes  db    "RAW $", "XMS $", "VCPI$", "DPMI$"
mode_msg    db    13,10, " ğ PMODE type: $"
lomem_msg   db    13,10, " ş Free low memory: $"
himem_msg   db    13,10, " ş Free extended memory: $"
fin_msg     db    "ACTION: 1996 By Ş<hçémà oŸ äXéá1â", 13,10,13,10,"$"
greet_msg   db    "Greets & thanx to:", 13,10,"JCAB for DemoVT & Laxity/Kefrens for checknobback",13,10,"And for TRAN for PMODE, of coz!$"


nodvt_msg   db	  13,10, "DemoVT no detected!", 13,10, "$"
novga_msg   db    13,10, "No VGA detected!", 13,10, "$" 
nomem_msg   db    13,10, "Insuficient memory!", 13,10, "$"
noshp_msg00 db    13,10, "Shape file not found!", 13,10, "$"
noshp_msg01 db    13,10, "Can't read the shape!", 13,10, "$"
noshp_msg03 db    13,10, "The file isn't a shape file!", 13,10, "$"
noshp_msg04 db    13,10, "Unknow error reading shape!!!", 13,10, "$"
enter       db    13,10, '$'


ifdef DEBUG
npolys_msg  db    13,10, " ş Number of polys: $"
nverts_msg  db    13,10, " ş Number of verts: $"
tottime     db	  13,10, "Total secs:   $"
totframe    db	  13,10, "Total frames: $"
fmsxs	    db	  13,10, "Frames/sec:   $"
cardspeed   db	  13,10, "VGA Hz:       $"
endif


; Datos de los ficheros
obj1	    db	  ?
act   	    db	  "shapes\action.shp", 0
duck        db    "shapes\duck.shp", 0
nave        db    "shapes\tie.shp", 0
torus       db    "shapes\torus.shp", 0
jarron	    db    "shapes\jarron2.shp", 0
maskara	    db    "shapes\achooo.shp", 0

;Dibujos
pres	    db	  "pic\pres.raw",0
pptr 	    dd	  ?
F1	    db	  "pic\f1.raw",0
F1ptr	    dd	  ?
F2	    db	  "pic\f2.raw",0
F2ptr	    dd	  ?

Env1	    db	  "pic\3d2.raw",0
E1ptr	    dd	  ?
Env2	    db	  "pic\3d3.raw",0
E2ptr	    dd	  ?
Env3	    db	  "pic\back4.raw",0
E3ptr	    dd	  ?
Env4	    db	  "pic\sunmap.raw",0
E4ptr	    dd	  ?

action      db	  "pic\env5.raw",0

Rtype	    db	  ?

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  C ¢ d i g o
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 _main:
	sti

; Presenta informaci¢n acerca del sistema
	@print mode_msg
	xor eax, eax
	mov al, _sysbyte0
	and al, 3
	@print pmodetypes[eax+eax*4]
	call _lomemsize
	@printmd lomem_msg, eax
	call _himemsize
	@printmd himem_msg, eax
	@print enter

; Sit£a el bufer en memoria baja (Por si las moscas)
	movzx eax, _filebuflen
	call _getlomem
	jc  E_nomem
	mov _filebufloc, eax


;Inicia la paleta
@palini:mov   eax, 768*2
	call  _getmem
	jc    E_nomem

	mov   palbuf, eax
	add   eax, 768
	mov   palnul, eax

; Y las im genes de fondo
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	mov   edi, offset image
	mov   ecx, 320*240
	call  INITMAP
	jc    E_nomem

	mov   edx, offset F1
	call  LOADPICTURE
	jc    E_nomem
	mov   F1ptr, eax
	mov   edi, eax
	mov   ecx, 320*240
	call  INITMAP
	jc    E_nomem

	mov   edx, offset F2
	call  LOADPICTURE
	jc    E_nomem
	mov   F2ptr, eax
	mov   edi, eax
	mov   ecx, 320*240
	call  INITMAP
	jc    E_nomem

	mov   edx, offset pres
	call  LOADPICTURE
	jc    E_nomem
	mov   pptr, eax
	mov   edi, eax
	mov   ecx, 320*240
	call  INITMAP
	jc    E_nomem
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ


; Ahora el shape
	call  GETOBJMEM
	jc    E_nomem
	mov   obj1, al

	mov   edx, offset act
        mov   al, obj1
	mov   bl, 0
	call  LOADOBJECT
	jc    E_noshp

	mov   edx, offset action
	call  LOADPICTURE
	jc    E_nomem
	mov   edi, eax
	xor   al, al
	call  INITTEXT
  	mov   al, 1 
	call  INITTEXT

; Inicia el sistema
	call  TESTVGA
	jc    E_novga
	call  _initkb


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

	mov   al, 1
	mov   edi, pptr
	call  SETBACKGND

	mov   edi, palnul
	mov   al, 0
	mov   ah, 255
	call  SETPAL
	call  INITTIMER

        mov   camera.x, 0
	mov   camera.y, 0
	mov   camera.z, -400*65536

	mov   edi, TheWorld
	mov   [edi].light.x, 80*65536
	mov   [edi].light.y, 80*65536
	mov   [edi].light.z, 100*65536

; Here starts the render...
	xor   eax, eax
	mov   ebx, 19
	mov   ecx, 27
	lea   edx, pathini
	xor   ebp, ebp
	call  INITPATH

	mov   edi, offset camera
	mov   al, ENVMAP
	call  RENDER
	call  IMAGEN


; Comprueba la presencia del DEMOVT
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	call    InitMusic
	or      dl,dl
	jz      Nodvt

	call  VTDisconnectTimer
	mov   al, 255
	call  VTSetSoundVolume
	call  VTBeginSync
	call  VTWaitForStart
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Nodvt:	
	lea   edi, paldisk
	mov   al, 0
	mov   ah, 255
	call  FADEIN

	mov   timer.tfreq, 0
	mov   screen.fctr, 0
        mov   timer.rcount, 0

	mov   Rtype, ENVMAP
	call  RENDERLOOP


        lea   edi, paldisk
        mov   al, 0
	mov   ah, 255
 	call  FADEOUTW

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	mov   al, 1
	mov   edi, offset image
	call  SETBACKGND

	mov   edx, offset duck
        mov   al, obj1
	mov   bl, 0
	call  LOADOBJECT
	jc    E_noshp

	mov   edx, offset Env3
	call  LOADPICTURE
	jc    E_nomem
	mov   edi, eax
	xor   al, al
	call  INITTEXT
  	mov   al, 1 
	call  INITTEXT

	xor   eax, eax
	mov   ebx, 19
	mov   ecx, 15
	lea   edx, path2
	xor   ebp, ebp
	call  INITPATH

	mov   edi, offset camera
	mov   al, ENVMAP
	call  RENDER
	call  IMAGEN

        lea   edi, paldisk
 	call  FADEINW

	mov   Rtype, ENVMAP
	call  RENDERLOOP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	mov   edx, offset torus
        mov   al, obj1
	mov   bl, 0
	call  LOADOBJECT
	jc    E_noshp

	xor   eax, eax
	mov   ebx, 16
	mov   ecx, 12
	lea   edx, path3
	xor   ebp, ebp
	call  INITPATH

	mov   edi, offset camera
	mov   al, ENVMAP
	call  RENDER
	call  IMAGEN

	mov   Rtype, ENVMAP
	call  RENDERLOOP

        lea   edi, paldisk
 	call  FADEINW
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	mov   al, 1
	mov   edi, F2ptr
	call  SETBACKGND

	mov   edx, offset jarron
        mov   al, obj1
	mov   bl, 0
	call  LOADOBJECT
	jc    E_noshp

	mov   edx, offset Env4
	call  LOADPICTURE
	jc    E_nomem
	mov   edi, eax
	xor   al, al
	call  INITTEXT
  	mov   al, 1 
	call  INITTEXT

	xor   eax, eax
	mov   ebx, 16
	mov   ecx, 16
	lea   edx, path4
	xor   ebp, ebp
	call  INITPATH

	mov   edi, offset camera
	mov   al, ENVMAP
	call  RENDER
	call  IMAGEN

        lea   edi, pal2
 	call  FADEINW

	mov   Rtype, ENVMAP
	call  RENDERLOOP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	mov   edx, offset nave
        mov   al, obj1
	mov   bl, 0
	call  LOADOBJECT
	jc    E_noshp

	xor   eax, eax
	mov   ebx, 16
	mov   ecx, 16
	lea   edx, path4
	xor   ebp, ebp
	call  INITPATH

	mov   edi, offset camera
	mov   al, ENVMAP
	call  RENDER
	call  IMAGEN

	mov   Rtype, ENVMAP
	call  RENDERLOOP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	mov   al, 1
	mov   edi, F1ptr
	call  SETBACKGND

	mov   edx, offset torus
        mov   al, obj1
	mov   bl, 0
	call  LOADOBJECT
	jc    E_noshp

	mov   edx, offset Env1
	call  LOADPICTURE
	jc    E_nomem
	mov   edi, eax
	xor   al, al
	call  INITTEXT

	mov   edx, offset Env2
	call  LOADPICTURE
	jc    E_nomem
	mov   edi, eax
  	mov   al, 1 
	call  INITTEXT

	xor   eax, eax
	mov   ebx, 19
	mov   ecx, 11
	lea   edx, path2
	xor   ebp, ebp
	call  INITPATH

	mov   edi, offset camera
	mov   al, ENVMAP
	call  RENDER
	call  IMAGEN

        lea   edi, paldisk
 	call  FADEINW

	mov   Rtype, ENVMAP
	call  RENDERLOOP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
        lea   edi, paldisk
 	call  FADEINW

	mov   edx, offset maskara
        mov   al, obj1
	mov   bl, 1
	call  LOADOBJECT
	jc    E_noshp

	xor   eax, eax
	mov   ebx, 16
	mov   ecx, 15
	lea   edx, path5
	xor   ebp, ebp
	call  INITPATH

	mov   edi, offset camera
	mov   al, GOUMAP
	call  RENDER
	call  IMAGEN

	mov   Rtype, GOUMAP
	call  RENDERLOOP
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
        lea   edi, paldisk
 	call  FADEOUT

	call  TEXT_SCROLL
	call  RESETTIMER
	call  _resetkb
	@print enter
	@print greet_msg

	jmp   _exit
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;=== ERRORES =================================================================
;-----------------------------------------------------------------------------
E_nomem: @print nomem_msg
	 jmp _exit
;-----------------------------------------------------------------------------
E_novga: @print novga_msg
	 jmp _exit
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
	 jmp _exit
print01: @print noshp_msg01
	 jmp _exit
print02: @print nomem_msg
	 jmp _exit
print03: @print noshp_msg03
	 jmp _exit
print04: @print noshp_msg04
	 jmp _exit
;=============================================================================
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

RENDERLOOP:
        mov   timer.rcount, 0
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
_@pathl:lea   edi, camera
	mov   al, Rtype
	call  RENDER
	call  IMAGEN

	xor   ebp, ebp
	call  TRACEPATH

	mov   timer.rcount, 0
	jnc   short _@pathl
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
	ret
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
ends
end
