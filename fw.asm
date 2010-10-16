 
@movsbestia MACRO
        mov  al, [esi]
        test al, al
        jz $+4
        mov [edi], al

        inc esi
        inc edi

ENDM

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;       	          .=-úúúúúú---=---=---úúúúúúú-=.
;	                  : ARTISTIC HICOLOR FIREWORKS :
;	                  ú=-úúúúúú----===----úúúúúúú-=ú
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;
;   Copyleft (C) 1995, 1996 Exobit Productions International Corp.
;
;       main code by Mentat
;	aux code & libs by Khroma


    .386p                       ;-)
    locals
    jumps





code32  segment para public use32
	assume cs:code32, ds:code32






include pmode.inc                   ; PMode kernel
include structs.inc
include kb.inc
;include debug.inc

extrn WAITRETRACE:near, screen:ScreenINFO, timer:TimerINFO, WAITRETRACE2:near
extrn SETPAL:near, TheWorld:dword, SETMAT:near
extrn REFRESH:near
extrn IMAGEN:near
extrn CLS:near
extrn _XMP_Fire:near
extrn fuente:dword

extrn exptab1:dword, exptab2:dword, colortb:word,  colort2:word
extrn crtab1:word, crtab2:word


;public fntoff
public paleton
;public fuente


public FIREWORKS
public INITFWDATA

    @abs MACRO reg
 	cmp &reg, 0
 	jge short $+4
 	neg &reg
    ENDM



;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
; DATA
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; CONSTANTS

SXC             = 160*65536
SYC             = 120*65536

SXM             = 319
SYM             = 235

SCRSIZ          = 320 * 240
SCRLSIZ         = 320 * 60

SKIP            = 5





down            = 6*UNO
numsky          = 2000
numwat          = 1000

numstars        = numsky+numwat ; Number of stars
numfirew        = 40            ; Number of fireworks
numcred         = 27
numexpl         = 200           ; Max number of particles
maxexpl         = 200           ; Number of explossion table values

velsub          = 08000h


SEQU_ADDR       = 3C4h             ; Direcci¢n I/O del Sequence Controler

;GRAV            = 4*UNO
GRAV            = 1000h

; Fireworks styles
t_semilla3      = 1
t_estelaroj     = 2
t_estelaamr     = 3
t_secoroj       = 2
t_secovrd       = 4
t_secoamr       = 5
t_secomul1      = 6
t_secomul2      = 7


FIN1            = 7400
FIN2            = 8300

align 4
fntoffs dw      2b08h,2b08h,2b08h,2b08h,2b08h,2b08h,2b08h,2b08h,28a4h
        dw      29d6h,2b08h,2b08h,2640h,2772h,2b08h,2b08h,2b08h,2046h,2b08h
        dw      2b08h,2b08h,2b08h,2178h,2b08h,23dch,22aah,250eh,2b08h
        dw      2b08h,2b08h,2b08h,2b08h,2b08h,0000h,0132h,0264h,0396h
        dw      04c8h,05fah,072ch,085eh,0990h,0ac2h,0bf4h,0d26h,0e58h
        dw      0f8ah,11eeh,1320h,1452h,1584h,16b6h,17e8h,191ah,1a4ch
        dw      1b7eh,1cb0h,1de2h,1f14h,2b08h,2b08h,2b08h,2b08h,2b08h
        dw      2b08h,2b08h,2b08h,2b08h,2b08h,2b08h,2b08h,2b08h,2b08h
        dw      2b08h,2b08h,2b08h,2b08h,2b08h,2b08h,2b08h,2b08h,2b08h
        dw      2b08h,2b08h,2b08h,2b08h,2b08h,2b08h,2b08h,2b08h,2b08h
        dw      2b08h,2b08h,2b08h,2b08h,2b08h,2b08h,2b08h,2b08h,2b08h
        dw      2b08h,2b08h,2b08h,2b08h,2b08h,2b08h,2b08h,2b08h,2b08h
        dw      2b08h,2b08h,2b08h,2b08h,2b08h,2b08h,2b08h,2b08h,2b08h
        dw      2b08h,2b08h,2b08h,2b08h,2b08h,2b08h,2b08h,2b08h,2b08h
        dw      2b08h,2b08h,2b08h,2b08h,2b08h,2b08h,10bch



; TABLES








; VARIABLES

creditos        dd      ?

vacio           db      "",0
greet01         db      "    GREETZ TO   ", 0
greet02         db      " INCOGNITA      ", 0
greet03         db      "        IGUANA  ", 0
greet04         db      " DOSIS          ", 0
greet05         db      "         ALIEN  ", 0
greet06         db      " CRYSTAL SHADE  ", 0
greet07         db      "         ZORAN  ", 0
greet08         db      " THE BANNER     ", 0
greet09         db      "       MIRACLE  ", 0
greet10         db      " SPANISH LORDS  ", 0
greet11         db      "         TLOTB  ", 0
greet12         db      " CAPSULE        ", 0
greet13         db      "           MCD  ", 0
greet14         db      " TRITON         ", 0
greet15         db      "         NOOON  ", 0
greet16         db      " EMF            ", 0
greet17         db      "        ORANGE  ", 0
greet18         db      " OXIGENE        ", 0
greet19         db      "       COMPLEX  ", 0
greet20         db      "  SPECIAL THNX  ", 0
greet21         db      " TRAN           ", 0
greet22         db      "  TEMPLE PEOPLE ", 0
greet23         db      " PATUEL         ", 0
greet24         db      "         DRAKE  ", 0
greet25         db      " BITSPAWN       ", 0
 


greete1         db      "   (C) EXOBIT   ", 0
greete2         db      "      1996      ", 0

gencount        dd      0
blurcount       db      0


align 4
starsbuf	dd	0
firexpl         dd      0
tempv           dd      0


vstable         dd      0, 19200, 38400, 57600
bptable		db	0001b, 0010b, 0100b, 1000b
star_x		dw	0
star_y		dw	0
seed            dw      7264h

camera_var	dd	0
s_mat		matriz	?
vector		dot3d	?
align 4
fx1             firew   numfirew dup (?)
align 4

currfire        dd      0

paleton         dd      ?


;firexpl         explode numexpl dup (?)
;pal             db 768 dup (?)
;colortab        db 265 dup (?)
;scrptr          dd 0, 0, 0, 0



;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  CODE                                                                     ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ




;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;       Espacio para publicidad.
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°


;°°°°°°°BENGALAS°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
 final	db	?
 timerv dw	?
 align 16
 FIREWORKS:

	mov  timerv, bx
        call blur

;       pushad
;        call    creditsp
;        ret

        cmp  gencount, FIN2
        jnae nocf

	mov  final, 1
	jmp  sigue

nocf:	mov  final, 0

sigue:

        mov  esi, offset fx1
        mov  currfire, 0


othfire:

        mov  eax, [esi].f_ent
        cmp  eax, gencount
        ja   nextxp

        mov  edi, currfire
        imul edi, numexpl * (size explode)
        add  edi, firexpl
        mov  tempv, edi

        mov  eax, [esi].f_exp
        cmp  eax, gencount
        jb   nexttt



        xor dx, dx


aleatxp:                                ; Calculate aleatory explossion
        movzx ebx, [esi].f_np           ; particles data.
        cmp  bx, [esi].f_mnp
        jge  fireup
        add  [esi].f_np, 2
        mov  eax, size explode
        imul ebx
;       mov  edi, firexpl               ; 1st particle addr
        add  edi, eax                   ; Actual particle addr

novale1:

        call ALEAT
        and  eax, 0Fh
        mov  dh, al
        shl  dh, 4
        mov  cx, ax
        mov  ax, 1
        shl  ax, cl
        mov  cx, [esi].f_col
        and  cx, ax
        jz   short novale1
        add  dh, 0Dh
        mov  [edi].x_col, dx



        call ALEAT                      ; X initial speed
        shl  eax, 9
        mov  ebx, eax
        @abs ebx
        mov  [edi].x_vec.z, eax

        call ALEAT                      ; Y initial speed
        shl  eax, 9
        mov  edx, eax
        @abs edx
        add  ebx, edx
        mov  [edi].x_vec.y, eax


        call ALEAT                      ; Constant fall speed
        shl  eax, 2
        add  eax, down
        mov  [edi].x_dn, eax


        mov  edx, 128*3*UNO             ; Z initial speed
        sub  edx, ebx
        call ALEAT
        and  al, 100b
        test al, al
        jz   short noneg1
        neg  edx
noneg1: mov  [edi].x_vec.x, edx

        add  edi, size explode

novale2:

        call ALEAT
        and  eax, 0Fh
        mov  dh, al
        shl  dh, 4
        mov  cx, ax
        mov  ax, 1
        shl  ax, cl
        mov  cx, [esi].f_col
        and  cx, ax
        jz   short novale2
        add  dh, 0Dh
        mov  [edi].x_col, dx


        call ALEAT
        shl  eax, 9
        mov  ebx, eax
        @abs ebx
        mov  [edi].x_vec.z, eax

        call ALEAT                      ; Constant fall speed
        shl  eax, 2
        add  eax, down
        mov  [edi].x_dn, eax

        call ALEAT
        shl  eax, 9
        mov  edx, eax
        @abs edx
        add  ebx, edx
        mov  [edi].x_vec.y, eax

        mov  edx, 128*3*UNO
        sub  edx, ebx
        call ALEAT
        and  al, 100b
        test al, al
        jz   short noneg2
        neg  edx
noneg2: mov  [edi].x_vec.x, edx




fireup:

; y = ispd * time - (acel * time^2)/2


        movzx ebx, timerv
;       mov  ebx, 1

;       add  [esi].f_time, ebx
        mov  ebp, [esi].f_time


        mov  eax, GRAV
        imul eax, ebp
        sub  eax, [esi].f_ispd
        mov  [esi].f_spd.y, eax



        movzx ebp, timerv


        imul eax, ebp
        add  [esi].f_pos.y, eax

 	mov  eax, [esi].f_spd.x
        imul eax, ebp
        add  [esi].f_pos.x, eax

 	mov  eax, [esi].f_spd.z
        imul eax, ebp
        add  [esi].f_pos.z, eax


 	mov  ebx, [esi].f_pos.z
 	mov  eax, [esi].f_pos.x
 	mov  edx, [esi].f_pos.y


; 	mov  vector.x, eax
 	mov  vector.y, edx
 	mov  vector.z, ebx



; Traslada la coordenada X
;	mov  eax, vector.x   ; Punto_x = ((V.x * 256) / V.z) + x_centro
	mov  edx, eax
	sar  edx, 16
	shl  eax, 16
 	idiv ebx
	shl  eax, 8
	add  eax, SXC
	shr  eax, 16
	mov  star_x, ax
        mov  [esi].f_pan, ax
	cmp  ax, SXM
	jge  nexttt
	cmp  ax, 0
	jle  nexttt

; Traslada la coordenada Y
	mov  eax, vector.y   ; Punto_y = ((V.y * -256) / V.z) + y_centro
	mov  edx, eax
	sar  edx, 16
	shl  eax, 16
 	idiv ebx
	shl  eax, 8
	add  eax, SYC
	shr  eax, 16
	mov  star_y, ax
 	cmp  ax, SYM
	jge  nexttt
	cmp  ax, 0
	jle  nexttt

; Dibuja el fuego (1)

	xor  edi, edi		; Direcci¢n en memoria de v¡deo
	mov  di, star_y
	lea  edi, [edi+edi*4]	; EDI = EDI * (16*5) = EDI * 80
	shl  edi, 4
	xor  eax, eax
	mov  ax, star_x
        shr  eax, 2
	add  edi, eax
        add  edi, screen.vscreen

        mov  ax, star_x
        and  eax, 3
        add  edi, vstable[eax*4]


	mov  [edi], byte ptr 31


        movzx ebx, timerv
        add  [esi].f_time, ebx


;°°°°°°°PARTICULAS°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
nexttt:

;       mov  esi, offset fx1


        mov  edi, tempv

        mov  eax, [esi].f_exp           ; Mierda!
        cmp  eax, gencount
        jae  nextxp

	add  eax, 450
	cmp  eax, gencount
	jb   nextxp

        cmp  [esi].f_count, 0
        jne  truco
        call bang
truco:

;       mov  edi, firexpl
        movzx ecx, [esi].f_np
	sub  ecx, 2


;align 16
traceexpl:

        cmp  [esi].f_count, maxexpl
        jge  noexp

        push ecx
        movzx ecx, timerv


;@expl1:

        mov  eax, [edi].x_vec.x
        mov  edx, [edi].x_vec.y
        mov  ebx, [edi].x_vec.z

        imul eax, ecx
        imul edx, ecx
        imul ebx, ecx

        add  [edi].x_pos.x, eax         ; Explossion movement
        add  [edi].x_pos.z, ebx
        add  [edi].x_pos.y, edx

;        dec  ecx
;        jnz  @expl1


;       test ecx, ecx
;       jnz  short @expl
;       mov  ecx, 1



;  super-acojoneibol-reduction

        xor  ecx, ecx

@expl2:

        mov  ebp, [esi].f_count
;       lea  ebp, [ebp*4]
        add  ebp, ecx
        shl  ebp, 2
        add  ebp, [esi].f_tab
        mov  ebp, [ebp]


        inc  ecx


        mov  eax, [edi].x_vec.x
        imul ebp
        shrd eax, edx, 16
        sub  [edi].x_vec.x, eax
        mov  eax, [edi].x_vec.y
        imul ebp
        shrd eax, edx, 16
        sub  [edi].x_vec.y, eax
        mov  eax, [edi].x_vec.z
        imul ebp
        shrd eax, edx, 16
        sub  [edi].x_vec.z, eax

        cmp  cx, timerv
        jb   @expl2



        pop  ecx
;       jmp  noclred

noexp:
; Super Color Decrement
        xor  edx, edx
;       jmp  noclred


@coloop:

        mov  ebp, [esi].f_count
        add  ebp, edx
        mov  ebx, [esi].f_tab2
        mov  ax, [edi].x_col
        mov  ex, ax
        and  eax, 0FFFh                 ; Remove main color
        jz   noclred

        sub  ax, [ebx+ebp*2]
        js   subzero

        and  ex, 0F000h
        or   ax, ex
;       mov  ax, ex
        mov  [edi].x_col, ax

        inc  dx
        cmp  dx, timerv
        jnae short @coloop

        jmp  short noclred





;  Vaya idea X'DDDDDDDDDDDDDDDDDDDDD

eex     dd ?
ex      dw ?
eh      db ?
el      db 0

efx     dd ?
fx      dw ?
fh      db ?
fl      db ?

egx     dd ?
gx      dw ?
gh      db ?
gl      db ?

ehx     dd ?
hx      dw ?
hh      db ?
hl      db ?

eix     dd ?
ix      dw ?
ih      db ?
il      db ?

;  XXX"DDDDDDDDDDDDDDDDDDDDD


subzero:
        mov  [edi].x_col, 0

;       mov  bh, ah
;       xor  al, al
;       and  bh, 0F0h
;       and  ah, 00Fh
;       jz   short noclred
;       dec  ah
;       or   ah, bh
;       mov  [edi].x_col, ax



noclred:
        mov  eax, [edi].x_dn

        add  [edi].x_pos.y, eax         ; Fall

        mov  eax, [edi].x_pos.x
        mov  edx, [edi].x_pos.y
        mov  ebx, [edi].x_pos.z


 	mov  vector.x, eax
 	mov  vector.y, edx
 	mov  vector.z, ebx


; Traslada la coordenada X
;	mov  eax, vector.x   ; Punto_x = ((V.x * 256) / V.z) + x_centro
	mov  edx, eax
	sar  edx, 16
	shl  eax, 16
 	idiv ebx
	shl  eax, 8
	add  eax, SXC
	shr  eax, 16
	mov  star_x, ax
	cmp  ax, SXM
 	jg   nextpart
	cmp  ax, 0
	jl   nextpart

; Traslada la coordenada Y
	mov  eax, vector.y   ; Punto_y = ((V.y * -256) / V.z) + y_centro
	mov  edx, eax
	sar  edx, 16
	shl  eax, 16
 	idiv ebx
	shl  eax, 8
	add  eax, SYC
	shr  eax, 16
	mov  star_y, ax
 	cmp  ax, SYM
	jg   nextpart
	cmp  ax, 0
	jl   nextpart

; Dibuja la particula
;       push edi
	xor  ebp, ebp		; Direcci¢n en memoria de v¡deo
	mov  bp, star_y
	lea  ebp, [ebp+ebp*4]	; EDI = EDI * (16*5) = EDI * 80
	shl  ebp, 4
	xor  eax, eax
	mov  ax, star_x
	shr  eax, 2
	add  ebp, eax
;       add  ebp, screen.acceso
        add  ebp, screen.vscreen

;       mov  dx, SEQU_ADDR	; Seleccionamos en la VGA el Bit-plane
;	mov  al, 2		; adecuado
;	out  dx, al
;	mov  al, byte ptr star_x
;	and  eax, 3
;	inc  dx
;	mov  al, bptable[eax]
;	out  dx, al		; Lo escribimos en el Map-Register
        mov  ax, star_x
        and  eax, 3
        add  ebp, vstable[eax*4]


	mov  ax, [edi].x_col
;       mov  [ebp], byte ptr 9Ah
        mov  [ebp], ah

;       pop  edi






nextpart:



        add  edi, size explode
        dec  ecx
        jnz  traceexpl

;       inc  [esi].f_count
        movzx eax, timerv
;       mov  eax, 1
        add  [esi].f_count, eax
;‡


nextxp:

        inc  currfire
        add  esi, size firew
        cmp  currfire, numfirew
        jb   othfire




;°°°°°°°ESTRELLAS°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;       popad

;comment §

        mov  ecx, numstars
	mov  esi, starsbuf

;	mov  ebx, offset s_mat
;       mov  edi, camera_var
	add  edi, size dot3d

;       pushad
;	call SETMAT
;	popad


inidot:
; Copia los datos del vector
;	mov  edi, camera_var
	mov  eax, [esi].s_pos.x
	mov  ebx, [esi].s_pos.y
	mov  edx, [esi].s_pos.z

;       sub  eax, [edi].x
	mov  vector.x, eax
;	sub  ebx, 400
;	sub  ebx, [edi].y
	mov  vector.y, ebx
;	sub  edx, [edi].z
	mov  vector.z, edx


comment ‡
; Lo rota
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
	push ebx


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
‡

; Comprueba la Z
	mov  ebx, vector.z
	cmp  ebx, 65536
	jl   nexdot


; Traslada la coordenada X
	mov  eax, vector.x   ; Punto_x = ((V.x * 256) / V.z) + x_centro
;	sub  eax, camera.x
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
;	sub  eax, camera.y
 	sub  eax, -1500*UNO
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
	xor  edi, edi		; Direcci¢n en memoria de v¡deo
	mov  di, star_y
	lea  edi, [edi+edi*4]	; EDI = EDI * (16*5) = EDI * 80
	shl  edi, 4
	xor  eax, eax
	mov  ax, star_x
	shr  eax, 2
	add  edi, eax
;	add  edi, screen.acceso
        add  edi, screen.vscreen

;	mov  dx, SEQU_ADDR	; Seleccionamos en la VGA el Bit-plane
;	mov  al, 2		; adecuado
;	out  dx, al
;	mov  al, byte ptr star_x
;	and  eax, 3
;	inc  dx
;	mov  al, bptable[eax]
;	out  dx, al		; Lo escribimos en el Map-Register
        mov  ax, star_x
        and  eax, 3
        add  edi, vstable[eax*4]


	mov  ax, [esi].s_col
	mov  bl, ah
	mov  [edi], bl

; Compara el valor del color
	mov  bp, [esi].s_speed
        imul bp, timerv

	cmp  [esi].s_dir, 0
	jne  short ms@testmin

ms@testmax:
 	add  ax, bp
	cmp  ax, [esi].s_col2
	jle  short nexdot
	mov  ax, [esi].s_col2
	mov  [esi].s_dir, 1
	jmp  short nexdot


ms@testmin:
        sub  ax, bp
	cmp  ax, [esi].s_col1
	jge  short nexdot
	mov  ax, [esi].s_col1
	mov  [esi].s_dir, 0

; Loop
nexdot:	mov  [esi].s_col, ax
	add  esi, size star
	dec  cx
	jnz  inidot


wr2@loop:
	cmp   timer.wrt, 1
	je    short wr2@loop

        call REFRESH
        call credits

        call IMAGEN
;       call WAITRETRACE2

        movzx  ebx, timerv
        add  gencount, ebx
        inc  screen.fctr


	cmp   final, 1
	je    short exitstc
        clc
	ret               ; s'acab¢.

exitstc:
	stc
	ret

 ;ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; PROCEDIMIENTO:³ INITDATA
;---------------³-------------------------------------------------------------
; FUNCION:      ³ Inicia las estrellas (randomiza los valores)
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
 align 16
 INITDATA  PROC




; Inicia las posiciones
	mov  cx, numstars
	mov  edi, starsbuf

; Inicia los datos de cada estrella (siempre aleatorios)
is@loop1:
	call ALEAT
	shl  eax, 15
	mov  edx, eax
	@abs edx
	mov  ebx, edx
	mov  [edi].s_pos.x, eax

is@y1:	call ALEAT
	shl  eax, 15
	mov  edx, eax
	@abs edx
	add  ebx, edx
	mov  [edi].s_pos.y, eax

is@z1:	call ALEAT
	shl  eax, 15
	mov  edx, eax
	@abs edx
	add  ebx, edx
;       @abs eax
	mov  [edi].s_pos.z, eax

	cmp  ebx, 3000*3*UNO

      	jb   short is@loop1

	call ALEATU
	and  ax, 01111111b
	mov  [edi].s_speed, ax

is@col1:
	call ALEATU
	and  ax, 00000111b*256
	mov  [edi].s_col1, ax

is@col2:
	call ALEATU
	and  ax, 00001111b*256	; 1111b para rango 1-16
	jz   short is@col2
	cmp  ax, [edi].s_col1
	je   short is@col2
	mov  [edi].s_col2, ax


; Averigua la direcci¢n
; El color 2 debe ser siempre el mayor
	mov  ax, [edi].s_col1
	cmp  [edi].s_col2, ax
 	jb   short it@sub

; Si col2 es mayor...
      	mov  [edi].s_dir, 0
	mov  [edi].s_col, ax
	jmp  short it@color

; y si no, SWAP!
it@sub:
	mov  bx, [edi].s_col2
	mov  [edi].s_dir, 1
	mov  [edi].s_col2, ax
	mov  [edi].s_col1, bx
	mov  [edi].s_col, bx

it@color:
	add  edi, size star
	dec  cx
	jnz  is@loop1


comment ‡

; Inicia las posiciones
	mov  cx, numwat
;       mov  edi, starsbuf
;       add  edi, numsky * size star


; Inicia los datos de cada estrella (siempre aleatorios)
is@loop12:
	call ALEAT
	shl  eax, 15
	mov  edx, eax
	@abs edx
	mov  ebx, edx
	mov  [edi].s_pos.x, eax

;      	call ALEAT
;	shl  eax, 15
;	mov  edx, eax
;	@abs edx
;	add  ebx, edx
;	@abs eax
;	neg  eax
	mov  [edi].s_pos.y, 0

       	call ALEAT
	shl  eax, 15
	mov  edx, eax
	@abs edx
	add  ebx, edx
;       @abs eax
	mov  [edi].s_pos.z, eax

;	cmp  ebx, 50*UNO
;	jb   short is@loop12

	call ALEATU
	and  ax, 11111111b
	mov  [edi].s_speed, ax

is@col12:
	call ALEATU
	and  ax, 00000111b*256
        add  ah, 0B0h
	mov  [edi].s_col1, ax

is@col22:
	call ALEATU
	and  ax, 00000111b*256	; 1111b para rango 1-16
	jz   short is@col22
        add  ah, 0B0h
	cmp  ax, [edi].s_col1
	je   short is@col22
	mov  [edi].s_col2, ax


; Averigua la direcci¢n
; El color 2 debe ser siempre el mayor
	mov  ax, [edi].s_col1
	cmp  [edi].s_col2, ax
 	jb   short it@sub2

; Si col2 es mayor...
      	mov  [edi].s_dir, 0
	mov  [edi].s_col, ax
	jmp  short it@color2

; y si no, SWAP!
it@sub2:
	mov  bx, [edi].s_col2
	mov  [edi].s_dir, 1
	mov  [edi].s_col2, ax
	mov  [edi].s_col1, bx
	mov  [edi].s_col, bx

it@color2:
	add  edi, size star
	dec  cx
	jnz  is@loop12


‡

	CAMERA_Z = 1000*UNO

; Initialize fireworks
        mov  edi, offset fx1
	mov  [edi].f_pos.x, -1500*UNO
	mov  [edi].f_pos.y, 8000*UNO
	mov  [edi].f_pos.z, 5000*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
        mov  [edi].f_ispd, 30*UNO
	mov  [edi].f_spd.x, 05*UNO
	mov  [edi].f_spd.z, 0*UNO
        mov  [edi].f_ent, 090
        mov  [edi].f_exp, 350
        mov  [edi].f_tab, offset exptab1
        mov  [edi].f_tab2, offset crtab2
        mov  [edi].f_mnp, 100
        mov  [edi].f_col, 0100000010000000b



        mov  edi, offset fx1
        add  edi, size firew
	mov  [edi].f_pos.x,  500*UNO
	mov  [edi].f_pos.y, 8000*UNO
	mov  [edi].f_pos.z, 7000*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
	mov  [edi].f_ispd, 35*UNO
	mov  [edi].f_spd.x, -5*UNO
	mov  [edi].f_spd.z, 10*UNO
        mov  [edi].f_ent, 400
        mov  [edi].f_exp, 900
        mov  [edi].f_tab, offset exptab2
        mov  [edi].f_tab2, offset crtab1
        mov  [edi].f_mnp, 150
        mov  [edi].f_col, 0000001110000110b


        mov  edi, offset fx1
        add  edi, (size firew) * 2
	mov  [edi].f_pos.x,  700*UNO
	mov  [edi].f_pos.y, 9000*UNO
	mov  [edi].f_pos.z, 6500*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
	mov  [edi].f_ispd, 30*UNO
	mov  [edi].f_spd.x, -8*UNO
	mov  [edi].f_spd.z, 00*UNO
        mov  [edi].f_ent, 1020
        mov  [edi].f_exp, 1390
        mov  [edi].f_tab, offset exptab1
        mov  [edi].f_tab2, offset crtab1
        mov  [edi].f_mnp, 50
        mov  [edi].f_col, 0001110110000010b
        mov  [edi].f_col, 0000000000000110b

        mov  edi, offset fx1
        add  edi, (size firew) * 3
	mov  [edi].f_pos.x,  700*UNO
	mov  [edi].f_pos.y, 9000*UNO
	mov  [edi].f_pos.z, 6500*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
	mov  [edi].f_ispd, 30*UNO
	mov  [edi].f_spd.x, -9*UNO
	mov  [edi].f_spd.z, 00*UNO
        mov  [edi].f_ent, 1200
        mov  [edi].f_exp, 1500
        mov  [edi].f_tab, offset exptab1
        mov  [edi].f_tab2, offset crtab2
        mov  [edi].f_mnp, 50
        mov  [edi].f_col, 1111111111111100b
        mov  [edi].f_col, 0000000011000000b

        mov  edi, offset fx1
        add  edi, (size firew) * 4
	mov  [edi].f_pos.x, 100*UNO
	mov  [edi].f_pos.y, 9000*UNO
	mov  [edi].f_pos.z, 7000*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
	mov  [edi].f_ispd, 35*UNO
	mov  [edi].f_spd.x, 10*UNO
	mov  [edi].f_spd.z, 10*UNO
        mov  [edi].f_ent, 2000
        mov  [edi].f_exp, 2300
        mov  [edi].f_tab, offset exptab1
        mov  [edi].f_tab2, offset crtab1
        mov  [edi].f_mnp, 50
        mov  [edi].f_col, 0010000111000010b
        mov  [edi].f_col, 0011000000000110b


        mov  edi, offset fx1
        add  edi, (size firew) * 5
	mov  [edi].f_pos.x,  300*UNO
	mov  [edi].f_pos.y, 8000*UNO
	mov  [edi].f_pos.z, 6500*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
	mov  [edi].f_ispd, 30*UNO
	mov  [edi].f_spd.x, 04*UNO
	mov  [edi].f_spd.z, 00*UNO
        mov  [edi].f_ent, 2250
        mov  [edi].f_exp, 2550
        mov  [edi].f_tab, offset exptab1
        mov  [edi].f_tab2, offset crtab2
        mov  [edi].f_mnp, 200
        mov  [edi].f_col, 1111111111111000b
        mov  [edi].f_col, 0000111000000000b


        mov  edi, offset fx1
        add  edi, (size firew) * 6
	mov  [edi].f_pos.x, 1200*UNO
	mov  [edi].f_pos.y, 9000*UNO
	mov  [edi].f_pos.z, 6500*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
	mov  [edi].f_ispd, 32*UNO
	mov  [edi].f_spd.x, 05*UNO
	mov  [edi].f_spd.z, 00*UNO
        mov  [edi].f_ent, 3200
        mov  [edi].f_exp, 3550
        mov  [edi].f_tab, offset exptab1
        mov  [edi].f_tab2, offset crtab1
        mov  [edi].f_mnp, 100
        mov  [edi].f_col, 1111111111111110b
        mov  [edi].f_col, 0000010110000010b
        mov  [edi].f_col, 0011000000000000b

        mov  edi, offset fx1
        add  edi, (size firew) * 7
	mov  [edi].f_pos.x,  020*UNO
	mov  [edi].f_pos.y, 9000*UNO
	mov  [edi].f_pos.z, 6500*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
	mov  [edi].f_ispd, 35*UNO
	mov  [edi].f_spd.x, -8*UNO
	mov  [edi].f_spd.z, 00*UNO
        mov  [edi].f_ent, 5000
        mov  [edi].f_exp, 5310
        mov  [edi].f_tab, offset exptab1
        mov  [edi].f_tab2, offset crtab1
        mov  [edi].f_mnp, 200
        mov  [edi].f_col, 0010000000000000b
        mov  [edi].f_col, 0000101011100010b
        mov  [edi].f_col, 0000110000000000b

        mov  edi, offset fx1
        add  edi, (size firew) * 8
	mov  [edi].f_pos.x,  100*UNO
	mov  [edi].f_pos.y, 7000*UNO
	mov  [edi].f_pos.z, 6500*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
	mov  [edi].f_ispd, 30*UNO
	mov  [edi].f_spd.x,  7*UNO
	mov  [edi].f_spd.z, 00*UNO
        mov  [edi].f_ent, 4400
        mov  [edi].f_exp, 4800
        mov  [edi].f_tab, offset exptab1
        mov  [edi].f_tab2, offset crtab1
        mov  [edi].f_mnp, 200
        mov  [edi].f_col, 0010100111000000b
        mov  [edi].f_col, 0011000000000000b


        mov  edi, offset fx1
        add  edi, (size firew) * 9
	mov  [edi].f_pos.x, -1700*UNO
	mov  [edi].f_pos.y, 9000*UNO
	mov  [edi].f_pos.z, 6500*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
	mov  [edi].f_ispd, 35*UNO
	mov  [edi].f_spd.x, -5*UNO
	mov  [edi].f_spd.z, 05*UNO
        mov  [edi].f_ent, 5600
        mov  [edi].f_exp, 5860
        mov  [edi].f_tab, offset exptab1
        mov  [edi].f_tab2, offset crtab1
        mov  [edi].f_mnp, 200
        mov  [edi].f_col, 1100111111111110b
        mov  [edi].f_col, 0000000011000000b

        mov  edi, offset fx1
        add  edi, (size firew) * 10
	mov  [edi].f_pos.x,  500*UNO
	mov  [edi].f_pos.y, 9000*UNO
	mov  [edi].f_pos.z, 7000*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
	mov  [edi].f_ispd, 35*UNO
	mov  [edi].f_spd.x, -5*UNO
	mov  [edi].f_spd.z, 10*UNO
        mov  [edi].f_ent, 7100
        mov  [edi].f_exp, 7500
        mov  [edi].f_tab, offset exptab2
        mov  [edi].f_tab2, offset crtab1
        mov  [edi].f_mnp, 150
        mov  [edi].f_col, 0000001000000000b
        mov  [edi].f_col, 0000000000001100b


        mov  edi, offset fx1
        add  edi, (size firew) * 11
	mov  [edi].f_pos.x,  700*UNO
	mov  [edi].f_pos.y, 9000*UNO
	mov  [edi].f_pos.z, 6500*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
	mov  [edi].f_ispd, 30*UNO
	mov  [edi].f_spd.x, -8*UNO
	mov  [edi].f_spd.z, 00*UNO
        mov  [edi].f_ent, 7120
        mov  [edi].f_exp, 7470
        mov  [edi].f_tab, offset exptab1
        mov  [edi].f_tab2, offset crtab1
        mov  [edi].f_mnp, 200
        mov  [edi].f_col, 0001100000000010b


        mov  edi, offset fx1
        add  edi, (size firew) * 12
	mov  [edi].f_pos.x, -700*UNO
	mov  [edi].f_pos.y, 9000*UNO
	mov  [edi].f_pos.z, 6500*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
	mov  [edi].f_ispd, 30*UNO
	mov  [edi].f_spd.x, 3*UNO
	mov  [edi].f_spd.z, 00*UNO
        mov  [edi].f_ent, 7270
        mov  [edi].f_exp, 7590
        mov  [edi].f_tab, offset exptab1
        mov  [edi].f_tab2, offset crtab1
        mov  [edi].f_mnp, 200
        mov  [edi].f_col, 1111111111111100b

        mov  edi, offset fx1
        add  edi, (size firew) * 13
	mov  [edi].f_pos.x, 1000*UNO
	mov  [edi].f_pos.y, 9000*UNO
	mov  [edi].f_pos.z, 7000*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
	mov  [edi].f_ispd, 35*UNO
	mov  [edi].f_spd.x, 10*UNO
	mov  [edi].f_spd.z, 10*UNO
        mov  [edi].f_ent, 7350
        mov  [edi].f_exp, 7800
        mov  [edi].f_tab, offset exptab1
        mov  [edi].f_tab2, offset crtab2
        mov  [edi].f_mnp, 200
        mov  [edi].f_col, 0010000111000010b


        mov  edi, offset fx1
        add  edi, (size firew) * 14
	mov  [edi].f_pos.x,  300*UNO
	mov  [edi].f_pos.y, 9000*UNO
	mov  [edi].f_pos.z, 6500*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
	mov  [edi].f_ispd, 30*UNO
	mov  [edi].f_spd.x, -4*UNO
	mov  [edi].f_spd.z, 00*UNO
        mov  [edi].f_ent, 7120
        mov  [edi].f_exp, 7385
        mov  [edi].f_tab, offset exptab1
        mov  [edi].f_tab2, offset crtab2
        mov  [edi].f_mnp, 200
        mov  [edi].f_col, 1111111111111000b
        mov  [edi].f_col, 0000000000010000b


        mov  edi, offset fx1
        add  edi, (size firew) * 15
	mov  [edi].f_pos.x, -700*UNO
	mov  [edi].f_pos.y, 9000*UNO
	mov  [edi].f_pos.z, 6500*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
	mov  [edi].f_ispd, 35*UNO
	mov  [edi].f_spd.x, 05*UNO
	mov  [edi].f_spd.z, 00*UNO
        mov  [edi].f_ent, 7170
        mov  [edi].f_exp, 7490
        mov  [edi].f_tab, offset exptab1
        mov  [edi].f_tab2, offset crtab2
        mov  [edi].f_mnp, 100
        mov  [edi].f_col, 1111111111111110b
        mov  [edi].f_col, 0000010110000010b

        mov  edi, offset fx1
        add  edi, (size firew) * 16
	mov  [edi].f_pos.x,  020*UNO
	mov  [edi].f_pos.y, 9000*UNO
	mov  [edi].f_pos.z, 6500*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
	mov  [edi].f_ispd, 35*UNO
	mov  [edi].f_spd.x, -6*UNO
	mov  [edi].f_spd.z, 00*UNO
        mov  [edi].f_ent, 7120
        mov  [edi].f_exp, 7395
        mov  [edi].f_tab, offset exptab1
        mov  [edi].f_tab2, offset crtab2
        mov  [edi].f_mnp, 200
        mov  [edi].f_col, 0010000000000000b
        mov  [edi].f_col, 0000101011100010b

        mov  edi, offset fx1
        add  edi, (size firew) * 17
	mov  [edi].f_pos.x,  100*UNO
	mov  [edi].f_pos.y,  8000*UNO
	mov  [edi].f_pos.z, 6500*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
	mov  [edi].f_ispd, 30*UNO
	mov  [edi].f_spd.x,  7*UNO
	mov  [edi].f_spd.z, 00*UNO
        mov  [edi].f_ent, 7420
        mov  [edi].f_exp, 7700
        mov  [edi].f_tab, offset exptab1
        mov  [edi].f_tab2, offset crtab2
        mov  [edi].f_mnp, 200
        mov  [edi].f_col, 0010100111000000b
        mov  [edi].f_col, 1110000000000010b
        mov  [edi].f_col, 1100111111111110b


        mov  edi, offset fx1
        add  edi, (size firew) * 18
	mov  [edi].f_pos.x, -1700*UNO
	mov  [edi].f_pos.y, 9000*UNO
	mov  [edi].f_pos.z, 6500*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
	mov  [edi].f_ispd, 32*UNO
	mov  [edi].f_spd.x, -5*UNO
	mov  [edi].f_spd.z, 05*UNO
        mov  [edi].f_ent, 7400
        mov  [edi].f_exp, 7805
        mov  [edi].f_tab, offset exptab1
        mov  [edi].f_tab2, offset crtab2
        mov  [edi].f_mnp, 200
        mov  [edi].f_col, 1100111111111110b
        mov  [edi].f_col, 0000000011111010b

        mov  edi, offset fx1
        add  edi, (size firew) * 19
	mov  [edi].f_pos.x,  100*UNO
	mov  [edi].f_pos.y, 9000*UNO
	mov  [edi].f_pos.z, 6500*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
	mov  [edi].f_ispd, 30*UNO
	mov  [edi].f_spd.x, -7*UNO
	mov  [edi].f_spd.z, 00*UNO
        mov  [edi].f_ent, 7320
        mov  [edi].f_exp, 7700
        mov  [edi].f_tab, offset exptab1
        mov  [edi].f_tab2, offset crtab2
        mov  [edi].f_mnp, 200
        mov  [edi].f_col, 1100111111111110b



        mov  edi, offset fx1
        add  edi, (size firew) * 20
	mov  [edi].f_pos.x, -500*UNO
	mov  [edi].f_pos.y, 9000*UNO
	mov  [edi].f_pos.z, 5000*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
        mov  [edi].f_ispd, 35*UNO
	mov  [edi].f_spd.x, 05*UNO
	mov  [edi].f_spd.z, 10*UNO
        mov  [edi].f_ent, 070
        mov  [edi].f_exp, 500
        mov  [edi].f_tab, offset exptab1
        mov  [edi].f_tab2, offset crtab2
        mov  [edi].f_mnp, 100
        mov  [edi].f_col, 0101010101010100b



        mov  edi, offset fx1
        add  edi, (size firew) * 21
	mov  [edi].f_pos.x,  500*UNO
	mov  [edi].f_pos.y, 9000*UNO
	mov  [edi].f_pos.z, 7000*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
	mov  [edi].f_ispd, 35*UNO
	mov  [edi].f_spd.x, -5*UNO
	mov  [edi].f_spd.z, 8*UNO
        mov  [edi].f_ent, 3500
        mov  [edi].f_exp, 3700
        mov  [edi].f_tab, offset exptab2
        mov  [edi].f_tab2, offset crtab1
        mov  [edi].f_mnp, 150
        mov  [edi].f_col, 0010001010101110b


        mov  edi, offset fx1
        add  edi, (size firew) * 22
	mov  [edi].f_pos.x,  700*UNO
	mov  [edi].f_pos.y, 9000*UNO
	mov  [edi].f_pos.z, 6500*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
	mov  [edi].f_ispd, 30*UNO
	mov  [edi].f_spd.x, -8*UNO
	mov  [edi].f_spd.z, 00*UNO
        mov  [edi].f_ent, 6020
        mov  [edi].f_exp, 6390
        mov  [edi].f_tab, offset exptab1
        mov  [edi].f_tab2, offset crtab1
        mov  [edi].f_mnp, 50
        mov  [edi].f_col, 0001110110000010b
        mov  [edi].f_col, 0000001110110110b

        mov  edi, offset fx1
        add  edi, (size firew) * 23
	mov  [edi].f_pos.x,  700*UNO
	mov  [edi].f_pos.y, 9000*UNO
	mov  [edi].f_pos.z, 6500*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
	mov  [edi].f_ispd, 30*UNO
	mov  [edi].f_spd.x, -9*UNO
	mov  [edi].f_spd.z, 00*UNO
        mov  [edi].f_ent, 5200
        mov  [edi].f_exp, 5500
        mov  [edi].f_tab, offset exptab1
        mov  [edi].f_tab2, offset crtab2
        mov  [edi].f_mnp, 50
        mov  [edi].f_col, 1111111111111100b
        mov  [edi].f_col, 0000001110000110b

        mov  edi, offset fx1
        add  edi, (size firew) * 24
	mov  [edi].f_pos.x, 1000*UNO
	mov  [edi].f_pos.y, 9000*UNO
	mov  [edi].f_pos.z, 7000*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
	mov  [edi].f_ispd, 35*UNO
	mov  [edi].f_spd.x, 10*UNO
	mov  [edi].f_spd.z, 10*UNO
        mov  [edi].f_ent, 5000
        mov  [edi].f_exp, 5300
        mov  [edi].f_tab, offset exptab1
        mov  [edi].f_tab2, offset crtab1
        mov  [edi].f_mnp, 50
        mov  [edi].f_col, 0010000111000010b
        mov  [edi].f_col, 0111101110000110b


        mov  edi, offset fx1
        add  edi, (size firew) * 25
	mov  [edi].f_pos.x,  300*UNO
	mov  [edi].f_pos.y, 9000*UNO
	mov  [edi].f_pos.z, 6500*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
	mov  [edi].f_ispd, 30*UNO
	mov  [edi].f_spd.x, 04*UNO
	mov  [edi].f_spd.z, 00*UNO
        mov  [edi].f_ent, 3650
        mov  [edi].f_exp, 3890
        mov  [edi].f_tab, offset exptab1
        mov  [edi].f_tab2, offset crtab2
        mov  [edi].f_mnp, 200
        mov  [edi].f_col, 0000000000010000b


        mov  edi, offset fx1
        add  edi, (size firew) * 26
	mov  [edi].f_pos.x, -700*UNO
	mov  [edi].f_pos.y, 9000*UNO
	mov  [edi].f_pos.z, 6500*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
	mov  [edi].f_ispd, 35*UNO
	mov  [edi].f_spd.x, -5*UNO
	mov  [edi].f_spd.z, 00*UNO
        mov  [edi].f_ent, 0900
        mov  [edi].f_exp, 1220
        mov  [edi].f_tab, offset exptab1
        mov  [edi].f_tab2, offset crtab1
        mov  [edi].f_mnp, 100
        mov  [edi].f_col, 0000000000010000b

        mov  edi, offset fx1
        add  edi, (size firew) * 27
	mov  [edi].f_pos.x,  020*UNO
	mov  [edi].f_pos.y, 9000*UNO
	mov  [edi].f_pos.z, 6500*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
	mov  [edi].f_ispd, 33*UNO
	mov  [edi].f_spd.x, -8*UNO
	mov  [edi].f_spd.z, 00*UNO
        mov  [edi].f_ent, 300
        mov  [edi].f_exp, 610
        mov  [edi].f_tab, offset exptab1
        mov  [edi].f_tab2, offset crtab1
        mov  [edi].f_mnp, 200
        mov  [edi].f_col, 0010000000100000b


        mov  edi, offset fx1
        add  edi, (size firew) * 28
	mov  [edi].f_pos.x,  100*UNO
	mov  [edi].f_pos.y, 9000*UNO
	mov  [edi].f_pos.z, 6500*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
	mov  [edi].f_ispd, 30*UNO
	mov  [edi].f_spd.x,  7*UNO
	mov  [edi].f_spd.z, 02*UNO
        mov  [edi].f_ent, 7400
        mov  [edi].f_exp, 7710
        mov  [edi].f_tab, offset exptab1
        mov  [edi].f_tab2, offset crtab1
        mov  [edi].f_mnp, 200
        mov  [edi].f_col, 1110000000000010b


        mov  edi, offset fx1
        add  edi, (size firew) * 29
	mov  [edi].f_pos.x, -1700*UNO
	mov  [edi].f_pos.y, 9000*UNO
	mov  [edi].f_pos.z, 6500*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
	mov  [edi].f_ispd, 30*UNO
	mov  [edi].f_spd.x, -5*UNO
	mov  [edi].f_spd.z, 05*UNO
        mov  [edi].f_ent, 4680
        mov  [edi].f_exp, 4890
        mov  [edi].f_tab, offset exptab1
        mov  [edi].f_tab2, offset crtab2
        mov  [edi].f_mnp, 75
        mov  [edi].f_col, 1100111111111110b

        mov  edi, offset fx1
        add  edi, (size firew) * 30
	mov  [edi].f_pos.x,  500*UNO
	mov  [edi].f_pos.y, 9000*UNO
	mov  [edi].f_pos.z, 7000*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
	mov  [edi].f_ispd, 35*UNO
	mov  [edi].f_spd.x, -5*UNO
	mov  [edi].f_spd.z, 10*UNO
        mov  [edi].f_ent, 2100
        mov  [edi].f_exp, 2400
        mov  [edi].f_tab, offset exptab2
        mov  [edi].f_tab2, offset crtab1
        mov  [edi].f_mnp, 150
        mov  [edi].f_col, 0000001000000000b


        mov  edi, offset fx1
        add  edi, (size firew) * 31
	mov  [edi].f_pos.x,  700*UNO
	mov  [edi].f_pos.y, 9000*UNO
	mov  [edi].f_pos.z, 6500*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
	mov  [edi].f_ispd, 30*UNO
	mov  [edi].f_spd.x, -8*UNO
	mov  [edi].f_spd.z, 00*UNO
        mov  [edi].f_ent, 1120
        mov  [edi].f_exp, 1470
        mov  [edi].f_tab, offset exptab1
        mov  [edi].f_tab2, offset crtab2
        mov  [edi].f_mnp, 200
        mov  [edi].f_col, 0001110110000010b


        mov  edi, offset fx1
        add  edi, (size firew) * 32
	mov  [edi].f_pos.x,  700*UNO
	mov  [edi].f_pos.y, 9000*UNO
	mov  [edi].f_pos.z, 6500*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
	mov  [edi].f_ispd, 30*UNO
	mov  [edi].f_spd.x, -9*UNO
	mov  [edi].f_spd.z, 00*UNO
        mov  [edi].f_ent, 5270
        mov  [edi].f_exp, 5590
        mov  [edi].f_tab, offset exptab1
        mov  [edi].f_tab2, offset crtab1
        mov  [edi].f_mnp, 200
        mov  [edi].f_col, 1111111111111100b

        mov  edi, offset fx1
        add  edi, (size firew) * 33
	mov  [edi].f_pos.x, 1000*UNO
	mov  [edi].f_pos.y, 8000*UNO
	mov  [edi].f_pos.z, 7000*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
	mov  [edi].f_ispd, 35*UNO
	mov  [edi].f_spd.x, 10*UNO
	mov  [edi].f_spd.z, 10*UNO
        mov  [edi].f_ent, 2850
        mov  [edi].f_exp, 3100
        mov  [edi].f_tab, offset exptab1
        mov  [edi].f_tab2, offset crtab2
        mov  [edi].f_mnp, 200
        mov  [edi].f_col, 0010000111000010b


        mov  edi, offset fx1
        add  edi, (size firew) * 34
	mov  [edi].f_pos.x,  300*UNO
	mov  [edi].f_pos.y, 9000*UNO
	mov  [edi].f_pos.z, 6500*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
	mov  [edi].f_ispd, 30*UNO
	mov  [edi].f_spd.x, 04*UNO
	mov  [edi].f_spd.z, 00*UNO
        mov  [edi].f_ent, 1920
        mov  [edi].f_exp, 2285
        mov  [edi].f_tab, offset exptab1
        mov  [edi].f_tab2, offset crtab2
        mov  [edi].f_mnp, 100
        mov  [edi].f_col, 0011000000000000b


        mov  edi, offset fx1
        add  edi, (size firew) * 35
	mov  [edi].f_pos.x, -700*UNO
	mov  [edi].f_pos.y, 9000*UNO
	mov  [edi].f_pos.z, 6500*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
	mov  [edi].f_ispd, 35*UNO
	mov  [edi].f_spd.x, 05*UNO
	mov  [edi].f_spd.z, 00*UNO
        mov  [edi].f_ent, 3970
        mov  [edi].f_exp, 4190
        mov  [edi].f_tab, offset exptab1
        mov  [edi].f_tab2, offset crtab2
        mov  [edi].f_mnp, 100
        mov  [edi].f_col, 0010000110000010b

        mov  edi, offset fx1
        add  edi, (size firew) * 36
	mov  [edi].f_pos.x,  020*UNO
	mov  [edi].f_pos.y, 9000*UNO
	mov  [edi].f_pos.z, 6500*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
	mov  [edi].f_ispd, 35*UNO
	mov  [edi].f_spd.x, -8*UNO
	mov  [edi].f_spd.z, 00*UNO
        mov  [edi].f_ent, 7120
        mov  [edi].f_exp, 7395
        mov  [edi].f_tab, offset exptab1
        mov  [edi].f_tab2, offset crtab2
        mov  [edi].f_mnp, 200
        mov  [edi].f_col, 0000010000001010b

        mov  edi, offset fx1
        add  edi, (size firew) * 37
	mov  [edi].f_pos.x,  100*UNO
	mov  [edi].f_pos.y, 9000*UNO
	mov  [edi].f_pos.z, 6500*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
	mov  [edi].f_ispd, 30*UNO
	mov  [edi].f_spd.x,  7*UNO
	mov  [edi].f_spd.z, 00*UNO
        mov  [edi].f_ent, 7420
        mov  [edi].f_exp, 7790
        mov  [edi].f_tab, offset exptab1
        mov  [edi].f_tab2, offset crtab2
        mov  [edi].f_mnp, 200
        mov  [edi].f_col, 0011100000001100b


        mov  edi, offset fx1
        add  edi, (size firew) * 38
	mov  [edi].f_pos.x, -1700*UNO
	mov  [edi].f_pos.y, 9000*UNO
	mov  [edi].f_pos.z, 6500*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
	mov  [edi].f_ispd, 37*UNO
	mov  [edi].f_spd.x, -5*UNO
	mov  [edi].f_spd.z, 05*UNO
        mov  [edi].f_ent, 7400
        mov  [edi].f_exp, 7805
        mov  [edi].f_tab, offset exptab1
        mov  [edi].f_tab2, offset crtab2
        mov  [edi].f_mnp, 200
        mov  [edi].f_col, 1100111111111110b
        mov  [edi].f_col, 1100000000000000b

        mov  edi, offset fx1
        add  edi, (size firew) * 39
	mov  [edi].f_pos.x,  100*UNO
	mov  [edi].f_pos.y, 8000*UNO
	mov  [edi].f_pos.z, 6500*UNO+CAMERA_Z
        mov  [edi].f_time, 0
	mov  [edi].f_spd.y, 0
	mov  [edi].f_ispd, 30*UNO
	mov  [edi].f_spd.x,  7*UNO
	mov  [edi].f_spd.z, 00*UNO
        mov  [edi].f_ent, 7320
        mov  [edi].f_exp, 7800
        mov  [edi].f_tab, offset exptab1
        mov  [edi].f_tab2, offset crtab2
        mov  [edi].f_mnp, 200
        mov  [edi].f_col, 1000000000000010b



; CREDITOS -> definicion

	mov  edi, creditos

        mov  [edi].te_in, 0
        mov  [edi].te_pos, 239 * 10000h ;-17 * 100h
        mov  [edi].te_enc, 0
        mov  [edi].te_add, offset greet01

        add  edi, size texto*1
        mov  [edi].te_in, 250
        mov  [edi].te_pos, 239 * 10000h ;-17 * 100h
        mov  [edi].te_enc,0
        mov  [edi].te_add, offset greet02

        add  edi, size texto*1
        mov  [edi].te_in, 500
        mov  [edi].te_pos, 239 * 10000h ;-17 * 100h
        mov  [edi].te_enc,0
        mov  [edi].te_add, offset greet03

        add  edi, size texto*1
        mov  [edi].te_in, 750
        mov  [edi].te_pos, 239 * 10000h ;-17 * 100h
        mov  [edi].te_enc,0
        mov  [edi].te_add, offset greet04

        add  edi, size texto*1
        mov  [edi].te_in, 1000
        mov  [edi].te_pos, 239 * 10000h ;-17 * 100h
        mov  [edi].te_enc,0
        mov  [edi].te_add, offset greet05

        add  edi, size texto*1
        mov  [edi].te_in, 1250
        mov  [edi].te_pos, 239 * 10000h ;-17 * 100h
        mov  [edi].te_enc,0
        mov  [edi].te_add, offset greet06

        add  edi, size texto*1
        mov  [edi].te_in, 1500
        mov  [edi].te_pos, 239 * 10000h ;-17 * 100h
        mov  [edi].te_enc, 0
        mov  [edi].te_add, offset greet07

        add  edi, size texto*1
        mov  [edi].te_in, 1750
        mov  [edi].te_pos, 239 * 10000h ;-17 * 100h
        mov  [edi].te_enc,0
        mov  [edi].te_add, offset greet08

        add  edi, size texto*1
        mov  [edi].te_in, 2000
        mov  [edi].te_pos, 239 * 10000h ;-17 * 100h
        mov  [edi].te_enc,0
        mov  [edi].te_add, offset greet09

        add  edi, size texto*1
        mov  [edi].te_in, 2250
        mov  [edi].te_pos, 239 * 10000h ;-17 * 100h
        mov  [edi].te_enc,0
        mov  [edi].te_add, offset greet10

        add  edi, size texto*1
        mov  [edi].te_in, 2500
        mov  [edi].te_pos, 239 * 10000h ;-17 * 100h
        mov  [edi].te_enc,0
        mov  [edi].te_add, offset greet11

        add  edi, size texto*1
        mov  [edi].te_in, 2750
        mov  [edi].te_pos, 239 * 10000h ;-17 * 100h
        mov  [edi].te_enc,0
        mov  [edi].te_add, offset greet12

        add  edi, size texto*1
        mov  [edi].te_in, 3000
        mov  [edi].te_pos, 239 * 10000h ;-17 * 100h
        mov  [edi].te_enc, 0
        mov  [edi].te_add, offset greet13

        add  edi, size texto*1
        mov  [edi].te_in, 3250
        mov  [edi].te_pos, 239 * 10000h ;-17 * 100h
        mov  [edi].te_enc,0
        mov  [edi].te_add, offset greet14

        add  edi, size texto*1
        mov  [edi].te_in, 3500
        mov  [edi].te_pos, 239 * 10000h ;-17 * 100h
        mov  [edi].te_enc,0
        mov  [edi].te_add, offset greet15

        add  edi, size texto*1
        mov  [edi].te_in, 3750
        mov  [edi].te_pos, 239 * 10000h ;-17 * 100h
        mov  [edi].te_enc,0
        mov  [edi].te_add, offset greet16

        add  edi, size texto*1
        mov  [edi].te_in, 4000
        mov  [edi].te_pos, 239 * 10000h ;-17 * 100h
        mov  [edi].te_enc,0
        mov  [edi].te_add, offset greet17

        add  edi, size texto*1
        mov  [edi].te_in, 4250
        mov  [edi].te_pos, 239 * 10000h ;-17 * 100h
        mov  [edi].te_enc,0
        mov  [edi].te_add, offset greet18

        add  edi, size texto*1
        mov  [edi].te_in, 4500
        mov  [edi].te_pos, 239 * 10000h ;-17 * 100h
        mov  [edi].te_enc, 0
        mov  [edi].te_add, offset greet19

        add  edi, size texto*1
        mov  [edi].te_in, 4750+250
        mov  [edi].te_pos, 239 * 10000h ;-17 * 100h
        mov  [edi].te_enc,0
        mov  [edi].te_add, offset greet20

        add  edi, size texto*1
        mov  [edi].te_in, 5000+250
        mov  [edi].te_pos, 239 * 10000h ;-17 * 100h
        mov  [edi].te_enc,0
        mov  [edi].te_add, offset greet21

        add  edi, size texto*1
        mov  [edi].te_in, 5250+250
        mov  [edi].te_pos, 239 * 10000h ;-17 * 100h
        mov  [edi].te_enc,0
        mov  [edi].te_add, offset greet22

        add  edi, size texto*1
        mov  [edi].te_in, 5500+250
        mov  [edi].te_pos, 239 * 10000h ;-17 * 100h
        mov  [edi].te_enc,0
        mov  [edi].te_add, offset greet23

        add  edi, size texto*1
        mov  [edi].te_in, 5750+250
        mov  [edi].te_pos, 239 * 10000h ;-17 * 100h
        mov  [edi].te_enc,0
        mov  [edi].te_add, offset greet24

        add  edi, size texto*1
        mov  [edi].te_in, 6000+250
        mov  [edi].te_pos, 239 * 10000h ;-17 * 100h
        mov  [edi].te_enc, 0
        mov  [edi].te_add, offset greet25

        add  edi, size texto*1
        mov  [edi].te_in, 6750+305
        mov  [edi].te_pos, 239 * 10000h ;-17 * 100h
        mov  [edi].te_enc,0
        mov  [edi].te_add, offset greete1

        add  edi, size texto*1
        mov  [edi].te_in, 6950+305
        mov  [edi].te_pos, 239 * 10000h ;-17 * 100h
        mov  [edi].te_enc, 0
        mov  [edi].te_add, offset greete2

        ret

 ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; PROCEDIMIENTO:³ INITFWDATA
;---------------³-------------------------------------------------------------
; FUNCION:      ³ Inicia los datos necesarios para las estrellas
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
 align 16
 INITFWDATA PROC


; Initialize stars and fireworks
	mov  eax, (size star) * numstars
	add  eax, 4
        call _gethimem
;       jc   mierda
	and  al, 11111100b
	mov  starsbuf, eax

	mov  eax, (size explode) * numfirew * numexpl
	add  eax, 4
        call _gethimem
;       jc   mierda
	and  al, 11111100b
	mov  firexpl, eax


	mov  eax, (size texto) * numcred
	add  eax, 4
        call _gethimem
;       jc   mierda
	and  al, 11111100b
	mov  creditos, eax


; Initialize camera
 	mov  edi, TheWorld
 	lea  eax, [edi].camera
 	mov  camera_var, eax


; Initialize virtual screen
comment ‡
        mov  eax, SCRSIZ+4
	call _gethimem                  ; Allocate vscreen.
        jc   mierda
	and  al, 11111100b
        mov  edi, offset scrptr         ; Initialize ModeX virtual screen
        stosd                           ; addresses.
        add  eax, SCRLSIZ
        stosd
        add  eax, SCRLSIZ
        stosd
        add  eax, SCRLSIZ
        stosd
‡


        call INITDATA

        call prepblur

        mov  blurcount, 0
        mov  gencount, 0

        xor  eax, eax
	ret



mierda:
        mov  eax, -1
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

	pop  dx

	ret

ENDP

ALEATU PROC ;Unsigned!

	push dx
	xor  eax, eax

	mov  ax, seed
	mov  dx, 5d45h	; 31415621 and 0ffffh
	inc  ax
	mul  dx
	rol  ax, 2
	mov  seed, ax

	sub  ax, 32768
	pop  dx

	ret

ENDP




prepblur:               ; Generate a simple color transition table for
                        ; motion blur.

        ret




        xor  ecx, ecx
        mov  edi, offset colortb

@pbloop:
        mov  bl, cl
        mov  al, cl
        and  bl, 00Fh
        and  al, 0F0h
        shr  bl, 1
        or   al, bl
        stosb

        inc  ecx
        cmp  ecx, 0FFh
        jne  @pbloop

        ret





blur:                           ; Do motion blur.

        pushad

        cld
        cmp  blurcount, SKIP
        jb   notblur
        mov  edi, screen.vscreen
        xor  eax, eax
;       mov  ecx, 64
        mov  ecx, 1
        mov  edx, offset colortb

        mov  al, [edi]
        mov  ax, [edx+eax*2]

align 16
@mbloop:
        stosb
        mov  al, [edi]
        mov  ax, [edx+eax*2]
;       add  ecx, 64
        inc ecx

        REPT 63
        stosb
        mov  al, [edi]
        mov  ax, [edx+eax*2]
        ENDM

        cmp  ecx,  1200 ; SCRSIZ/64
        jnae @mbloop

;       inc blurcount

        mov  ax, SKIP
        sub  ax, timerv
        jns  short @notzer
        mov  blurcount, 0


@notzer:
        mov  blurcount, al

        popad
        ret

notblur:

        inc blurcount
;       mov blurcount, 0
        popad
        ret


; Motion blur table
bang:                                   ; ­Pimba!
        pushad

        push edi

        movzx ecx, [esi].f_np

adjust:                                 ; Adjust start positions
        mov  eax, [esi].f_pos.x
        mov  ebx, [esi].f_pos.y
        mov  edx, [esi].f_pos.z
        mov  [esi].f_count, 0           ; Time counter to 0


@adjloop:
        mov  [edi].x_pos.x, eax
        mov  [edi].x_pos.y, ebx
        mov  [edi].x_pos.z, edx
        add  edi, size explode
        dec  ecx
        jnz  short @adjloop

        movzx ecx, [esi].f_np

adjust2:                                 ; Adjust start positions

        pop edi

        mov  eax, [esi].f_spd.x
        mov  ebx, [esi].f_spd.y
        mov  edx, [esi].f_spd.z
        mov  [esi].f_count, 0           ; Time counter to 0


@adjloop2:
        add  [edi].x_vec.x, eax
        add  [edi].x_vec.y, ebx
        add  [edi].x_vec.z, edx
        add  edi, size explode
        dec  ecx
        jnz  short @adjloop2


        mov  ax, [esi].f_pan
        shl  ax, 7
        add  ax, 6500
        call _XMP_Fire


        popad
        ret



;----------------------------------------------------------------------
;----------------------------------------------------------------------
;----------------------------------------------------------------------
;----------------------------------------------------------------------
;----------------------------------------------------------------------
;----------------------------------------------------------------------


credits:
;        ret
	mov  edi, creditos
        mov  edx, numcred


credloop:
        mov  ax, [edi].te_in
        mov  ebx, gencount
        cmp  ax, bx
        jg   nolohagas

        mov  esi, [edi].te_add

        mov  eax, [edi].te_pos

        cmp  gencount, FIN1
        ja   short nosube

        mov  ebx, velsub
        movzx ecx, timerv
        imul ecx, ebx
        sub  eax, ecx

        cmp  eax, -17*10000h ;240*10000h
        jl   nolohagas

nosube:

        mov  [edi].te_pos, eax
        shr  eax, 16
        mov  star_y, ax
        call creditsi

nolohagas:
        add  edi, size texto
        dec  edx

        jnz  credloop

        ret


;----------------------------------------------------------------------
;----------------------------------------------------------------------

creditsi:
        pushad

        mov     ehx, esi
        mov     edi,screen.acceso
        movsx   eax,star_y
        lea     eax, [eax*4+eax]
        shl     eax, 4
        add     edi,eax
        mov     eex, 0
        mov     efx, 18

        mov     ebp, edi

        mov     egx, 0
        mov     eix, 0

        movsx   eax,star_y
        cmp     eax,0
        jnl     noclipup


        @abs    eax

        sub     efx, eax
        mov     egx, eax
        mov     edi,screen.acceso
        mov     ebp, edi


        jmp     nextli

noclipup:

        cmp     eax, 240-18
        jng     nextli
        sub     eax, 240-18
        sub     efx, eax
        mov     eix, eax



nextli:

;       xor     eax,eax
        xor     ebx,ebx
        mov     ebx, eex
        add     ebx, ehx
        xor     eax, eax
        mov     al, [ebx]


        test    al, al
        jz      fincredi
        sub     al,32


        xor     ebx, ebx
        mov     bx, fntoffs[eax*2]
        mov     esi,fuente
        add     esi,ebx

        mov     dx,SEQU_ADDR

        mov     edi,ebp
        mov     ax,0102h
        out     dx,ax
        mov     ecx,efx
        add     esi,egx
        add     esi,egx
        add     esi,egx
        add     esi,egx
        add     esi,egx
l1i:    @movsbestia
        @movsbestia
        @movsbestia
        @movsbestia
        @movsbestia
        add     edi,75
        loop    l1i
        add     esi, eix
        add     esi, eix
        add     esi, eix
        add     esi, eix
        add     esi, eix



        mov     edi,ebp
        mov     ax,0202h
        out     dx,ax
        mov     ecx,efx
        add     esi,egx
        add     esi,egx
        add     esi,egx
        add     esi,egx
l2i:
        @movsbestia
        @movsbestia
        @movsbestia
        @movsbestia
        add     edi,76
        loop    l2i
        add     esi, eix
        add     esi, eix
        add     esi, eix
        add     esi, eix

        mov     edi,ebp
        mov     ax,0402h
        out     dx,ax
        mov     ecx,efx
        add     esi,egx
        add     esi,egx
        add     esi,egx
        add     esi,egx
l3i:    ;movsd
        @movsbestia
        @movsbestia
        @movsbestia
        @movsbestia
        add     edi,76
        loop    l3i
        add     esi, eix
        add     esi, eix
        add     esi, eix
        add     esi, eix
        mov     edi,ebp
        mov     ax,0802h
        out     dx,ax
        mov     ecx,efx
        add     esi,egx
        add     esi,egx
        add     esi,egx
        add     esi,egx
l4i:    ;movsd
        @movsbestia
        @movsbestia
        @movsbestia
        @movsbestia
        add     edi,76
        loop    l4i
        add     esi, eix
        add     esi, eix
        add     esi, eix
        add     esi, eix

        add     ebp,5
        inc     eex

        jmp     nextli

fincredi:

;       call    IMAGEN
        popad
        ret



;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ

code32  ends
	end





