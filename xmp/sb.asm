; Xtended Module Player
;
; Low level routines for Soundblaster software mixing




    .386p


include pmode.inc                       ; PMode stuff
include xmp.inc                         ; XMP link data
include xmp_low.inc                     ; XMP link data

include debug.inc



; PUBLIC PROCEDURES
;public  sb_irq
public  sb_init
public  sb_stop
public  sb_load
public  sb_play
public  sb_end
public  sb_pss
public  sb_pse
;public  sb_timer
public  sb_detect
public  sb_csf
public  sb_csv
public  sb_csp





;CHNDATA = 24



BUFFSIZ = 4096                          ; DMA buffer size
FREQ    = 22050                         ; Playback/mixing frequency
DEFRAM  = 768                           ; Default reserved RAM (Kbs)
AMPL    = 1                             ; Amplification


VERT_RETRACE = 3DAh                     ; Direcci¢n Input Register #1


code32  segment para public use32
	assume cs:code32, ds:code32

channel Struc
;       cabeg   dd  ?                   ; Initial address
        caact   dd  ?                   ; Actual address (fixed)
        caend   dd  ?                   ; End address
        caloop  dd  ?                   ; Loop address
        cinc    dd  ?                   ; Increment (fixed)
        cvol    dd  ?                   ; Volume
        cflag   db  ?                   ; Flag
channel EndS                            ; 24-bytes per channel

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±±  DATA                                                                     ±±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

org 32
chan            db 32*32 dup(0)         ; Channel registers


; Soundblaster I/O ports
p_reset         dw  ?                   ; Reset
p_rdata         dw  ?                   ; Read data
p_wdata         dw  ?                   ; Write data
p_wstat         dw  ?                   ; Write status
p_avail         dw  ?                   ; Avaiable data

align 4
sstart          dd  64 dup(0)           ; Sampledata addresses
send            dd  64 dup(0)
sloop           dd  64 dup(0)
stype           db  64 dup(0)           ; Type flag


; IRQ/Misc stuff
ormsbirqvect    dd      ?               ; Old real mode SB IRQ vector
rmsbirqbuf      db      21 dup(?)       ; Buffer for rm SB IRQ callback code
irqexitval      db      43h             ; Value to set on exit from IRQ
irqm0tbl        dw      0C089h,0A0E6h   ; Opcodes for IRQ levels (0-7,8-15)
sbirqvaltbl     db      0,0,41h,43h,0,42h,0,44h,0,0,0,45h,46h,0,0,47h

align 4
dmasize0        dd      374  ;2244  ;2242
dmasize1        dd      374  ;2244  ;2242
;dmasize0         dd      400

buf0            dd      ?               ; 8-bit double-buffer
buf1            dd      ?
buf2            dd      ?               ; 32-bit temporal buffer

wavetbeg        dd      ?               ; Wavetable-reserved RAM
wavetpnt        dd      ?               ; Location
wavetcnt        dd      0               ; Location (from wavetbeg)

tblmul          dd      ?               ; IMUL table
tblsat          dd      ?               ; Amplify/saturation table


; Debugin' messys
mierda          db      "mierda!$"
punto           db      ".$"

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±±  CODE                                                                     ±±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±





;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ sb_detect:                                             ±
;±  FUNCTION:      ³ Detect Soundblaster                                    ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
align 16
sb_detect:

        mov  xmp_devmem, DEFRAM*1024    ; Gives DEFRAM kb of RAM for samples

        xor  al, al
        ret




;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ sb_init                                                ±
;±  FUNCTION:      ³ Initialize Soundblaster                                ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
align 16
sb_init PROC

        pushad


	mov  ax, xmp_devport            ; Initialize port variables
	add  ax, 6h
	mov  p_reset, ax

	mov  ax, xmp_devport
	add  ax, 0Ah
	mov  p_rdata, ax

	mov  ax, xmp_devport
	add  ax, 0Ch
	mov  p_wdata, ax
	mov  p_wstat, ax

	mov  ax, xmp_devport
	add  ax, 0Eh
	mov  p_avail, ax


	mov  dx, p_reset                ; Reset the DSP
	mov  al, 1
	out  dx, al

	call sb_wait                    ; Wait some milisecs
	call sb_wait

	mov  dx, p_reset
	mov  al, 0
	out  dx, al

	call sb_wait                    ; Wait some milisecs


	mov  dx, p_avail
;AHH_SIGUE1:
	in   al, dx
	test al, 1000000b
;       jz   NoSB


	mov  dx, p_rdata
;AHH_SIGUE2:
	in   al, dx
	cmp  al, 0AAh
;  	jne  NoSB




        mov  bl, xmp_devirq1
        cmp  bl, 2                      ; Set and enable IRQ
        jne  short $+4                  ; & install IRQ handle
        mov  bl, 9
        cmp  bl, 7
        seta al
        movzx eax,al
        mov  ax, irqm0tbl[eax*2]
        mov  irqm0, ax
        mov  edx, offset sb_irq
        call _setirqvect
        mov  edi, offset rmsbirqbuf
        call _rmpmirqset
        mov  ormsbirqvect, eax
        xor  al, al
        call _setirqmask


	mov  eax, BUFFSIZ*4             ; Get low mem for DMA buffers
	call _getlomem
	jc   NoSB

;       mov  buf0, eax
;       add  eax, BUFFSIZ
;       mov  buf1, eax

	add  eax, _code32a              ; Real addr
        add  ax, BUFFSIZ                ; Add size
        jnc  noalign0
        xor  ax, ax                     ; If it cross 64k bound, align it
        add  eax, 10000h
        sub  eax, _code32a
        mov  buf0, eax
        jmp  short aligned0
noalign0:                               ; If not, restore the old addr
        sub  eax, BUFFSIZ
        sub  eax, _code32a
        mov  buf0, eax
aligned0:
        add  eax, BUFFSIZ
        mov  buf1, eax


        mov  eax, BUFFSIZ*4 +8          ; Get mem for temp. buffer
	call _getmem
	jc   NoSB
        mov  buf2, eax


        mov  eax, xmp_devmem            ; Get mem for samples
        test eax, eax
        jnz  itsok
        mov  eax, DEFRAM*1024           ; If xmp_devmem=0 then
        mov  xmp_devmem, eax            ; get default value
itsok:
        call _getmem
        jc   NoSB
        mov  wavetbeg, eax
        mov  wavetpnt, eax


comment ‡
        mov  eax, 4000h                 ; 128k imul table
        call _getmem
        jc   NoSB
        mov  tblmul, eax

        mov  edi, eax                   ; Fill table
        mov  cl, 0
@next1:
        mov  ch, 0
@next2:
        mov  al, cl
        imul ch
        movsx eax, ax
        mov  [edi], eax
        add  edi, 4
        add  ch, 1
        jnc  @next2
        add  cl, 1
        jnc  @next1
‡


        popad
        ret

NoSB:
        @print mierda
        popad
        ret

sb_init ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ sb_play                                                ±
;±  FUNCTION:      ³ Set soundcard to start playing                         ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
align 16
sb_play:
        pushad

	mov  ebx, FREQ                  ; Convert freq
	mov  eax, 1000000
	xor  edx, edx
	idiv ebx
	mov  ebx, 256
	sub  ebx, eax

	mov  al, 40h                    ; Set frequency
	call wdsp
	mov  al, bl
	call wdsp


        mov  al, 0D1h
        call wdsp                       ; Speaker on



        mov  edi, buf2                  ; Initialize buf2 (if echo)
        mov  ecx, BUFFSIZ
        xor  eax, eax
        rep  stosd


;       call _XMP_Main

        call sb_smix

	mov  ecx, dmasize1              ; Sample size
	mov  esi, buf1
	call sb_dma

        mov  al, 0D4h
        call wdsp                       ; DMA on


        mov  eax, buf0                  ; Switch buffers
        mov  ebx, buf1
        mov  buf0, ebx
        mov  buf1, eax
        mov  eax, dmasize0
        mov  ebx, dmasize1
        mov  dmasize0, ebx
        mov  dmasize1, eax


;       call _XMP_Main

        call sb_smix



        popad
        ret


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ sb_end                                                 ±
;±  FUNCTION:      ³ Uninitialize Soundblaster                              ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
align 4
sb_end:

        pushad


	mov  al, 0D0h
        call wdsp                       ; DMA stop


        mov  bl, xmp_devirq1            ; Return control to old IRQ handler
        mov  eax, ormsbirqvect
        call _rmpmirqfree
        mov  al, 1
        call _setirqmask

        popad
        ret


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ sb_stop                                                ±
;±  FUNCTION:      ³ Stop music playback                                    ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
align 16
sb_stop:
        ret





;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ sb_load                                                ±
;±  FUNCTION:      ³ Copy sampledata to reserved memory                     ±
;±  ASSUME:        ³ s_* variables are set                                  ±
;±  OUTS:          ³ AL=1 if not enough IW memory                           ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;public  s_num                  n£mero
;public  s_start                direcci¢n
;public  s_size                 tama¤o
;public  s_loops                principio loop
;public  s_loopl                tama¤o loop
;public  s_type                 tipo de sample
;sstart          dd  64 dup(0)
;send            dd  64 dup(0)
;sloop           dd  64 dup(0)
;stype           db  64 dup(0)


align 16
sb_load PROC
        pushad


        movzx ebp, s_num
        cmp  ebp, 64
;       jae  err_noload

        mov  eax, wavetcnt              ; Start address
        mov  sstart[ebp*4], eax

        mov  al, s_type                 ; Type
        mov  stype[ebp], al

        xor  ecx, ecx
        test stype[ebp], 10000b         ; 16 bit sampledata?
        jz   short isnot16bit
        mov  cl, 1
isnot16bit:

        test stype[ebp], 11b            ; Looped sample?
        jnz  haveloop

        mov  eax, s_size                ; Size
        shr  eax, cl
        add  eax, sstart[ebp*4]
        mov  send[ebp*4], eax

        jmp  allright

haveloop:
        mov  eax, s_loops               ; Loop start
        shr  eax, cl
        add  eax, sstart[ebp*4]
        mov  sloop[ebp*4], eax

        mov  eax, s_loopl               ; Loop end (size)
        shr  eax, cl
        add  eax, sloop[ebp*4]
        mov  send[ebp*4], eax

allright:
        mov  edi, wavetpnt
        mov  esi, s_start
        mov  ecx, send[ebp*4]
        sub  ecx, sstart[ebp*4]
        add  wavetcnt, ecx              ; Actualize counter

        test stype[ebp], 10000b         ; 16 bit sampledata?
        jnz  is16bit

        rep  movsb                      ; Copy sample
        jmp  allright2

is16bit:

@convto8:
        mov  ax, [esi]                  ; Copy sample
        mov  [edi], ah
        inc  esi
        inc  esi
        inc  edi
        dec  ecx
        jnz  @convto8

allright2:

        mov  wavetpnt, edi

        popad
        xor  al, al
        ret


err_noload:
        popad
        mov  al, 1
        ret
        ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ sb_csf                                                 ±
;±  FUNCTION:      ³ Change sample frequency                                ±
;±  ASSUME:        ³ - AL  the channel number                               ±
;±                 ³ - s_*  variable are set                                ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
align 16
sb_csf:

        pushad
        movzx ebp, al
        shl  ebp, 5

        xor  edx, edx
        mov  eax, s_freq
        test eax, eax
        shld eax, edx, 8                ; Adjust 24/8 fixed point
        mov  ebx, FREQ
        div  ebx
        mov  [chan+ebp].cinc, eax

        popad
        ret



;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ sb_csv                                                 ±
;±  FUNCTION:      ³ Change sample volume                                   ±
;±  ASSUME:        ³ - AL  the channel number                               ±
;±                 ³ - s_*  variable are set                                ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
align 16
sb_csv:

        push eax ebp
        movzx ebp, al
        shl  ebp, 5

        movzx eax, s_vol
        shr  eax, 1
        mov  [chan+ebp].cvol, eax

        pop  ebp eax
        ret

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ sb_csp                                                 ±
;±  FUNCTION:      ³ Change sample panning (not used)                       ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
align 16
sb_csp:
        ret

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ sb_pse                                                 ±
;±  FUNCTION:      ³ Play sample end                                        ±
;±  ASSUME:        ³ - AL  the channel number                               ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
align 16
sb_pse:

        pushad
        movzx ebp, al
        shl  ebp, 5

        mov  [chan+ebp].cflag, 0

        popad
        ret


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ sb_pss                                                 ±
;±  FUNCTION:      ³ Play sample start                                      ±
;±  ASSUME:        ³ - AL  the channel number                               ±
;±                 ³ - s_*  variable are set                                ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
align 16
sb_pss:


        pushad
        movzx ebp, al
        shl  ebp, 5


        xor  edx, edx
        mov  eax, s_freq
        shld eax, edx, 8                ; Adjust 24/8 fixed point
        mov  ebx, FREQ
        div  ebx
        mov  [chan+ebp].cinc, eax

        movzx eax, s_vol
        shr  eax, 1
        mov  [chan+ebp].cvol, eax

        movzx ebx, s_num

        mov  eax, sstart[ebx*4]         ; Go to sample start
        add  eax, s_offset              ; Sample-offset (if any)
        shl  eax, 8
        mov  [chan+ebp].caact, eax

        mov  eax, sloop[ebx*4]          ; Repeat address
        shl  eax, 8
        mov  [chan+ebp].caloop, eax

        mov  eax, send[ebx*4]           ; End/loope address
        shl  eax, 8
        mov  [chan+ebp].caend, eax

        mov  al, stype[ebx]             ; Enable channel
        or   al, 100b
        mov  [chan+ebp].cflag, al


        popad
        ret


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ sb_irq                                                 ±
;±  FUNCTION:      ³ Handle the Soundblaster IRQ                            ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
irqm0   dw      ?                       ; Code previously set
align 4

sb_irq:

        pushad

;irqm0   dw      ?                       ; Code previously set

        push ds
;        sti                             ; Set flags
        cld

        mov  ds, cs:_seldata            ; Set PM data segment

        mov  dx, p_avail                ; Report to SB dsp
        in   al, dx

        mov  eax, buf0                  ; Switch buffers
        mov  ebx, buf1
        mov  buf0, ebx
        mov  buf1, eax
        mov  eax, dmasize0
        mov  ebx, dmasize1
        mov  dmasize0, ebx
        mov  dmasize1, eax


	mov  ecx, dmasize0               ; Sample size
	mov  esi, buf0
	call sb_dma

        mov  al, 20h                    ; Report to the IRQ chip
        out  20h, al

        sti


;       call _XMP_Main

        call sb_smix




        pop  ds
        popad
        sti                             ; VERY important
        iretd






;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ sb_smix                                                ±
;±  FUNCTION:      ³ Software mixing routine                                ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
temp    db      ?
align 16
sb_smix PROC
        pushad

        call _XMP_Main


        movzx ebx, s_bpm
        shl  ebx, 1
	add  ebx, 6

        xor  edx, edx
        mov  eax, FREQ*5
        div  ebx
        mov  dmasize1, eax

; Step 1: Initialize buf2
; ----------------------------------------------------------------------

        mov  edi, buf2
        mov  ecx, dmasize1
        xor  eax, eax
        rep  stosd

;@reverb:                                ; La pijada de turno...
;        mov  eax, [edi]                 ; ­­REVERB!! X-D
;        sar  eax, 1                     ; y FUNCIONA!! X-)
;        mov  [edi], eax
;        add  edi, 4
;        dec  ecx
;        jnz  @reverb


; Step 2: Add all channels to buf2
; ----------------------------------------------------------------------
        xor  edx, edx
        mov  ebp, wavetbeg              ; ebp-> reserved sample mem
;       mov  ebp, tblmul                ; ebp-> multiplication table

channel_new:
        shl  edx, 5                      ; edx-> sample number

        test [chan+edx].cflag, 100b
        jz   channel_end

        mov  esi, [chan+edx].caact
        mov  edi, buf2                  ; edi-> temp. buffer pointer
        mov  ecx, dmasize1              ; ecx-> number of bytes to mix
        xor  ebx, ebx
        mov  ebx, [chan+edx].cvol       ; ebx-> 16-bit signed volume

align 16
@channel_add:                           ; Main loop
        mov  eax, esi
        shr  eax, 8
        mov  al, [eax+ebp]
        imul bh
        movsx eax, ax
        add  [edi], eax

        add  esi, [chan+edx].cinc
        cmp  esi, [chan+edx].caend      ; Test for loop/sample end
        jae  limit_cross
limit_looped:
        add  edi, 4
        dec  ecx
        jnz  @channel_add

        mov  [chan+edx].caact, esi

channel_end:                            ; Next channel?
        shr  edx, 5
        inc  edx
        cmp  dl, xmp_devchann
        jnae channel_new

; Step 3: Move buf2 to buf0 (adjust & amplify)
; ----------------------------------------------------------------------
        mov  esi, buf2
        mov  edi, buf1
        mov  ecx, dmasize1
        xor  eax, eax

align 16
@adjust:                                ; It must be "tabled"...
        mov  eax, [esi]

        sar  eax, 8+AMPL                ; Reduce

        cmp  eax, 07Fh                  ; Prevent saturation
        jng  short adj1_ok
        mov  eax, 07Fh
adj1_ok:
        cmp  eax, -80h
        jnl  short adj2_ok
        mov  eax, -80h
adj2_ok:
        add  al, 80h                    ; Signed -> unsigned
        mov  [edi], al                  ; Ok, write it

        add  esi, 4
        inc  edi
        dec  ecx
        jnz  @adjust

        mov  ecx, 128                   ; Fill 32 bytes with last
        rep  stosb                      ; sample to prevent clicks


        popad
        ret




limit_cross:
        test [chan+edx].cflag, 11b
        jnz  short l_c_loop
        mov  [chan+edx].cflag, 0
        jmp  channel_end

l_c_loop:
        sub  esi, [chan+edx].caend      ; Keep fractional portion
        add  esi, [chan+edx].caloop     ; Go to loop position
        jmp  limit_looped



sb_smix ENDP


; Generic functions

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ sb_wait                                                ±
;±  FUNCTION:      ³ Wait some miliseconds                                  ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
align 16
sb_wait PROC

	push ax dx

	mov  dx, VERT_RETRACE
@wre1:  in   al, dx
	test al, 00001000b
	jnz  short @wre1
@wre2:  in   al, dx
	test al, 00001000b
	jz   short  @wre2


	pop  dx ax
	ret

sb_wait ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ sb_dma                                                 ±
;±  FUNCTION:      ³ Start a DMA transfer through SB                        ±
;±  ASSUME:        ³ - ESI is the sample address                            ±
;±                 ³ - EAX is the frequency                                 ±
;±                 ³ - ECX is the size of the sample                        ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

align 16
sb_dma  PROC

	pushad
;       push eax

	dec  ecx

	add  esi, _code32a	        ; ESI -> Real address
	mov  edi, esi		        ; EDI -> Offset
	shr  esi, 16	 	        ; ESI -> Segment
	mov  ax, si
	mov  dl, al
	mov  dh, 48h
	mov  ax, di
	mov  bl, xmp_devdma1
	mov  DMA_Channel, 1

	mov  DMAbaseAdd, di
	mov  DMApageReg, si

	call Prog_DMA

initDSP:
	mov  al, 14h                    ; Set playback type
	call wdsp
	mov  al, cl                     ; Set sample size
        call wdsp
        mov  al, ch
        call wdsp

sb_dma_exit:
	popad
	ret

ENDP


;Extracted from PCGPE.
;Credits for this BUGGY! rutine go to Draeden/VLA :?
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; This routine programs the DMAC for channels 0-7
;
; IN: [DMA_Channel], [DMAbaseAdd], [DMApageReg] must be setup
;       [DAMBaseAdd] =  Memory Address port
;
;     dh = mode
;     cx = length  
;
;     ax = address
;     dl = page
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
DMA_Channel	db	?
DMAbaseAdd	dw	?
DMApageReg	dw	?

PROC Prog_DMA
        push    bx
        mov     bx,ax


        cmp     DMA_Channel,4
        jb      @@DoDMA03

        mov     al, DMA_Channel
        out     0D4h,al         ; mask reg bit

        sub     al,al
        out     0D8h,al         ; clr byte ptr

        mov     al, DMA_Channel
        sub     al,4
        add     al,dh
        out     0D6h,al         ; set mode reg

        push    dx

        mov    al,bl
        out    02,al           ; set base address low
        mov    al,bh
        out    02,al           ; set base address high

	mov    al, cl
	out    03h, al
	mov    al, ch
	out    03h, al

        pop    dx

 	mov    al, dl
	out    083h, al


        mov     al, DMA_Channel
        and     al,00000011b
        out     0D4h,al         ; unmask (activate) dma channel
        pop     bx
        ret

@@DoDMA03:
        mov     al,4
        add     al, DMA_Channel
        out     0Ah,al          ; mask reg bit

        sub     al,al
        out     0Ch,al          ; clr byte ptr

        mov     al,dh
        add     al, DMA_Channel
        out     0Bh,al          ; set mode reg

        push    dx

        mov    al,bl
        out    02,al           ; set base address low
        mov    al,bh
        out    02,al           ; set base address high

	mov    al, cl
	out    03h, al
	mov    al, ch
	out    03h, al

        pop    dx

 	mov    al, dl
	out    083h, al


        mov     al, DMA_Channel
        out     0Ah,al          ; unmask (activate) dma channel
        pop     bx

        ret
ENDP


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ wdsp                                                   ±
;±  FUNCTION:      ³ Write a byte to SB DSP port                            ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
align 16
wdsp    PROC

	push ax bx dx

	mov  bl, al

        mov  dx, p_wstat
@wdsp_loop:
        in   al, dx
        test al, 80h
        jnz  short @wdsp_loop

        mov  dx, p_wdata
        mov  al, bl
        out  dx, al

	pop  dx bx ax
	ret
wdsp    ENDP



ends

end



