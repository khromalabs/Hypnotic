; Xtended Module Player
;
; Low level routines for Interwave hadrware mixing




    .386p


include pmode.inc                       ; PMode stuff
include xmp.inc                         ; XMP link data
include xmp_low.inc                     ; XMP link data

include debug.inc



; PUBLIC PROCEDURES
;public  iw_irq
public  iw_init
public  iw_stop
public  iw_load
public  iw_play
public  iw_end
public  iw_pss
public  iw_pse
;public  iw_timer
public  iw_detect
public  iw_csf
public  iw_csv
public  iw_csp


; IW register set
;   general
LMALI           equ 43h                 ; Memory r/w address low
LMAHI           equ 44h                 ; Memory r/w address high
LMCI            equ 53h                 ; Memory control
UASBCI          equ 45h                 ; Timer control
UAT1I           equ 46h                 ; Timer 1 counter
UAT2I           equ 47h                 ; Timer 2 counter
URSTI           equ 4Ch                 ; Reset (GUS)

SAVI            equ 0Eh                 ; Active voices (GUS)
SVII            equ 0Fh                 ; IRQ-synth control
SVIRI           equ 1Fh                 ; idem (r/o)
SGMI            equ 19h                 ; Synth mode
SLFOBI          equ 1Ah                 ; LFOs parameters address

;   voice specific
SACI            equ 00h                 ; Address control
SFCI            equ 01h                 ; Frequency
SASHI           equ 02h                 ; Start address high
SASLI           equ 03h                 ; Start address low
SAEHI           equ 04h                 ; End address high
SAELI           equ 05h                 ; End address low
SVRI            equ 06h                 ; Volume ramp rate
SVSI            equ 07h                 ; Volume start
SVEI            equ 08h                 ; Volume end
SVLI            equ 09h                 ; Current volume level
SAHI            equ 0Ah                 ; Current address high
SALI            equ 0Bh                 ; Current address low
SROI            equ 0Ch                 ; Right volume
SVCI            equ 0Dh                 ; Volume control
SUAI            equ 10h                 ; Upper address
SEAHI           equ 11h                 ; Effect address high
SEALI           equ 12h                 ; Effect address low
SLOI            equ 13h                 ; Left volume
SEASI           equ 14h                 ; Effect channels selector
SMSI            equ 15h                 ; Mode selector
SEVI            equ 16h                 ; Effect volume
SFLFOI          equ 17h                 ; Frequency LFO
SVLFOI          equ 18h                 ; Volume LFO
SROFI           equ 1Bh                 ; Right final volume
SLOFI           equ 1Ch                 ; Left final volume
SEVFI           equ 1Dh                 ; Effect final volume




code32  segment para public use32
	assume cs:code32, ds:code32


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±±  DATA                                                                     ±±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±



; Interwave I/O ports
p_mix       dw      220h                ; Mixer control
p_pagsel    dw      322h                ; Page (channel) selector
p_regsel    dw      323h                ; Register selector
p_lodata    dw      324h                ; Data low byte port
p_hidata    dw      325h                ; Data high byte port
p_irqreg    dw      226h                ; IRQ status
p_dramrw    dw      327h                ; DRAM read/write port
p_timctl    dw      228h                ; Timer control
p_timdat    dw      229h                ; Timer data
p_irq       dw      22Bh                ; IRQ control


; IRQ stuff. Most integrally copied from Tran's demo Timeless
ormiwirqvect    dd      ?               ; Old real mode GF1 IRQ vector
rmiwirqbuf      db      21 dup(?)       ; Buffer for rm GF1 IRQ callback code
irqexitval      db      43h             ; Value to set on exit from IRQ
irqm0tbl        dw      0C089h,0A0E6h   ; Opcodes for IRQ levels (0-7,8-15)
iwirqvaltbl     db      0,0,41h,43h,0,42h,0,44h,0,0,0,45h,46h,0,0,47h

align 4
freqfactor      dd      44100

align 4
voltbl          dw      0100h           ; Volume table
                dw      0700h, 07ffh, 0880h, 08ffh, 0940h, 0980h, 09c0h, 09ffh, 0a20h
                dw      0a40h, 0a60h, 0a80h, 0aa0h, 0ac0h, 0ae0h, 0affh, 0b10h, 0b20h
                dw      0b30h, 0b40h, 0b50h, 0b60h, 0b70h, 0b80h, 0b90h, 0ba0h, 0bb0h
                dw      0bc0h, 0bd0h, 0be0h, 0bf0h, 0bffh, 0c08h, 0c10h, 0c18h, 0c20h
                dw      0c28h, 0c30h, 0c38h, 0c40h, 0c48h, 0c50h, 0c58h, 0c60h, 0c68h
                dw      0c70h, 0c78h, 0c80h, 0c88h, 0c90h, 0c98h, 0ca0h, 0ca8h, 0cb0h
                dw      0cb8h, 0cc0h, 0cc8h, 0cd0h, 0cd8h, 0ce0h, 0ce8h, 0cf0h, 0cf8h
                dw      0cffh, 0d04h, 0d08h, 0d0ch, 0d10h, 0d14h, 0d18h, 0d1ch, 0d20h
                dw      0d24h, 0d28h, 0d2ch, 0d30h, 0d34h, 0d38h, 0d3ch, 0d40h, 0d44h
                dw      0d48h, 0d4ch, 0d50h, 0d54h, 0d58h, 0d5ch, 0d60h, 0d64h, 0d68h
                dw      0d6ch, 0d70h, 0d74h, 0d78h, 0d7ch, 0d80h, 0d84h, 0d88h, 0d8ch
                dw      0d90h, 0d94h, 0d98h, 0d9ch, 0da0h, 0da4h, 0da8h, 0dach, 0db0h
                dw      0db4h, 0db8h, 0dbch, 0dc0h, 0dc4h, 0dc8h, 0dcch, 0dd0h, 0dd4h
                dw      0dd8h, 0ddch, 0de0h, 0de4h, 0de8h, 0dech, 0df0h, 0df4h, 0df8h
                dw      0dfch, 0dffh, 0e02h, 0e04h, 0e06h, 0e08h, 0e0ah, 0e0ch, 0e0eh
                dw      0e10h, 0e12h, 0e14h, 0e16h, 0e18h, 0e1ah, 0e1ch, 0e1eh, 0e20h
                dw      0e22h, 0e24h, 0e26h, 0e28h, 0e2ah, 0e2ch, 0e2eh, 0e30h, 0e32h
                dw      0e34h, 0e36h, 0e38h, 0e3ah, 0e3ch, 0e3eh, 0e40h, 0e42h, 0e44h
                dw      0e46h, 0e48h, 0e4ah, 0e4ch, 0e4eh, 0e50h, 0e52h, 0e54h, 0e56h
                dw      0e58h, 0e5ah, 0e5ch, 0e5eh, 0e60h, 0e62h, 0e64h, 0e66h, 0e68h
                dw      0e6ah, 0e6ch, 0e6eh, 0e70h, 0e72h, 0e74h, 0e76h, 0e78h, 0e7ah
                dw      0e7ch, 0e7eh, 0e80h, 0e82h, 0e84h, 0e86h, 0e88h, 0e8ah, 0e8ch
                dw      0e8eh, 0e90h, 0e92h, 0e94h, 0e96h, 0e98h, 0e9ah, 0e9ch, 0e9eh
                dw      0ea0h, 0ea2h, 0ea4h, 0ea6h, 0ea8h, 0eaah, 0each, 0eaeh, 0eb0h
                dw      0eb2h, 0eb4h, 0eb6h, 0eb8h, 0ebah, 0ebch, 0ebeh, 0ec0h, 0ec2h
                dw      0ec4h, 0ec6h, 0ec8h, 0ecah, 0ecch, 0eceh, 0ed0h, 0ed2h, 0ed4h
                dw      0ed6h, 0ed8h, 0edah, 0edch, 0edeh, 0ee0h, 0ee2h, 0ee4h, 0ee6h
                dw      0ee8h, 0eeah, 0eech, 0eeeh, 0ef0h, 0ef2h, 0ef4h, 0ef6h, 0ef8h
                dw      0efah, 0efch, 0efeh, 0effh, 0f01h, 0f02h, 0f03h, 0f04h, 0f05h
                dw      0f06h, 0f07h, 0f08h, 0f09h, 0f0ah, 0f0bh, 0f0ch, 0f0dh, 0f0eh
                dw      0f0fh, 0f10h, 0f11h, 0f12h, 0f13h, 0f14h, 0f15h, 0f16h, 0f17h
                dw      0f18h, 0f19h, 0f1ah, 0f1bh, 0f1ch, 0f1dh, 0f1eh, 0f1fh, 0f20h
                dw      0f21h, 0f22h, 0f23h, 0f24h, 0f25h, 0f26h, 0f27h, 0f28h, 0f29h
                dw      0f2ah, 0f2bh, 0f2ch, 0f2dh, 0f2eh, 0f2fh, 0f30h, 0f31h, 0f32h
                dw      0f33h, 0f34h, 0f35h, 0f36h, 0f37h, 0f38h, 0f39h, 0f3ah, 0f3bh
                dw      0f3ch, 0f3dh, 0f3eh, 0f3fh, 0f40h, 0f41h, 0f42h, 0f43h, 0f44h
                dw      0f45h, 0f46h, 0f47h, 0f48h, 0f49h, 0f4ah, 0f4bh, 0f4ch, 0f4dh
                dw      0f4eh, 0f4fh, 0f50h, 0f51h, 0f52h, 0f53h, 0f54h, 0f55h, 0f56h
                dw      0f57h, 0f58h, 0f59h, 0f5ah, 0f5bh, 0f5ch, 0f5dh, 0f5eh, 0f5fh
                dw      0f60h, 0f61h, 0f62h, 0f63h, 0f64h, 0f65h, 0f66h, 0f67h, 0f68h
                dw      0f69h, 0f6ah, 0f6bh, 0f6ch, 0f6dh, 0f6eh, 0f6fh, 0f70h, 0f71h
                dw      0f72h, 0f73h, 0f74h, 0f75h, 0f76h, 0f77h, 0f78h, 0f79h, 0f7ah
                dw      0f7bh, 0f7ch, 0f7dh, 0f7eh, 0f7fh, 0f80h, 0f81h, 0f82h, 0f83h
                dw      0f84h, 0f85h, 0f86h, 0f87h, 0f88h, 0f89h, 0f8ah, 0f8bh, 0f8ch
                dw      0f8dh, 0f8eh, 0f8fh, 0f90h, 0f91h, 0f92h, 0f93h, 0f94h, 0f95h
                dw      0f96h, 0f97h, 0f98h, 0f99h, 0f9ah, 0f9bh, 0f9ch, 0f9dh, 0f9eh
                dw      0f9fh, 0fa0h, 0fa1h, 0fa2h, 0fa3h, 0fa4h, 0fa5h, 0fa6h, 0fa7h
                dw      0fa8h, 0fa9h, 0faah, 0fabh, 0fach, 0fadh, 0faeh, 0fafh, 0fb0h
                dw      0fb1h, 0fb2h, 0fb3h, 0fb4h, 0fb5h, 0fb6h, 0fb7h, 0fb8h, 0fb9h
                dw      0fbah, 0fbbh, 0fbch, 0fbdh, 0fbeh, 0fbfh, 0fc0h, 0fc1h, 0fc2h
                dw      0fc3h, 0fc4h, 0fc5h, 0fc6h, 0fc7h, 0fc8h, 0fc9h, 0fcah, 0fcbh
                dw      0fcch, 0fcdh, 0fceh, 0fcfh, 0fd0h, 0fd1h, 0fd2h, 0fd3h, 0fd4h
                dw      0fd5h, 0fd6h, 0fd7h, 0fd8h, 0fd9h, 0fdah, 0fdbh, 0fdch, 0fddh
                dw      0fdeh, 0fdfh, 0fe0h, 0fe1h, 0fe2h, 0fe3h, 0fe4h, 0fe5h, 0fe6h
                dw      0fe7h, 0fe8h, 0fe9h, 0feah, 0febh, 0fech, 0fedh, 0feeh, 0fefh
                dw      0ff0h, 0ff1h, 0ff2h, 0ff3h, 0ff4h, 0ff5h, 0ff6h, 0ff7h, 0ff8h
                dw      0ff9h, 0ffah, 0ffbh, 0ffch, 0ffdh, 0ffeh, 0fffh



align 4
; Internal IW routines data

zerobuf         db  8 dup (0)           ; Zero buffer

loopstart       dd  32 dup(0)           ; One per channel
loopend         dd  32 dup(0)


sstart          dd  64 dup(0)           ; Sampledata addresses relatives to
send            dd  64 dup(0)           ; IW memory
sloop           dd  64 dup(0)
stype           db  64 dup(0)
;seffect         db  64 dup(1)           ; Mask of target fx channels



speed           dw  6                   ; Speed
bpm             dw  125                 ; Beats per minute

pvol            dw  32 dup(0)           ; Previous volume (used in vol. ramps)


;waddr          dd  1024*9              ; Actual IW address (load)
                                        ; 1Kb for LFO parameters
                                        ; 1Kb*8 for effects
iwaddr          dd  00000h              ; Actual IW address (load)

;msg01           db  '- $'
;msg02           db  'BPM: $'
;mkk             db  13,10,"estas inicializando la INTERWAVE!$"

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±±  CODE                                                                     ±±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Some I/O output macros

@outrb  MACRO regm, valm
	mov  dx, p_regsel               ; Select register
	mov  al, regm
	out  dx, al

	mov  dx, p_hidata               ; Send value
        mov  al, valm
	out  dx, al
        ENDM


@outrw  MACRO regn, valn
	mov  dx, p_regsel               ; Select register
	mov  al, regn
	out  dx, al

        mov  dx, p_lodata               ; Send value
        mov  ax, valn
	out  dx, ax
        ENDM

@outb   MACRO porto
        mov  dx, porto
        out  dx, al
        ENDM

@outw   MACRO portp
        mov dx, portp
        out dx, ax
        ENDM

;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ iw_detect:                                             ±
;±  FUNCTION:      ³ Detects Interwave card                                 ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
align 16
iw_detect:
        xor  al, al
        ret


        pushad
                                        ; Initialize port variables
        mov  ax, xmp_devport
        mov  p_mix, ax                  ; 2x0
        add  ax, 6
        mov  p_irqreg, ax               ; 2x6
        add  ax, 2
        mov  p_timctl, ax               ; 2x8
        inc  ax
        mov  p_timdat, ax               ; 2x9
        add  ax, 2
        mov  p_irq, ax                  ; 2xB

        mov  ax, xmp_devport
        add  ax,102h
        mov  p_pagsel, ax               ; 3x2
        inc  ax
        mov  p_regsel, ax               ; 3x3
        inc  ax
        mov  p_lodata, ax               ; 3x4
        inc  ax
        mov  p_hidata, ax               ; 3x5
        add  ax, 2
        mov  p_dramrw, ax               ; 3x7


        @outrb URSTI, 0                 ; Reset soundcard

        mov  edi, 2048*1024             ; Temporal!!!!
        mov  xmp_devmem, edi


        popad
        ret

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ iw_init:                                               ±
;±  FUNCTION:      ³ Initialize Interwave                                   ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
align 16
iw_init:

        pushad

                                        ; Initialize port variables
        mov  ax, xmp_devport
        mov  p_mix, ax                  ; 2x0
        add  ax, 6
        mov  p_irqreg, ax               ; 2x6
        add  ax, 2
        mov  p_timctl, ax               ; 2x8
        inc  ax
        mov  p_timdat, ax               ; 2x9
        add  ax, 2
        mov  p_irq, ax                  ; 2xB

        mov  ax, xmp_devport
        add  ax,102h
        mov  p_pagsel, ax               ; 3x2
        inc  ax
        mov  p_regsel, ax               ; 3x3
        inc  ax
        mov  p_lodata, ax               ; 3x4
        inc  ax
        mov  p_hidata, ax               ; 3x5
        add  ax, 2
        mov  p_dramrw, ax               ; 3x7

        @outrb URSTI, 00000001b         ; DAC dis/IRQ dis

        xor  eax, eax                   ; Initialize channels
@initchan:
        call iw_psi                     ; (play sample init)
        inc  al
        cmp  al, 31
        jne  @initchan

        @outrb URSTI, 00000011b         ; DAC enabled/IRQ dis
        @outrb SAVI, 32                 ; 32 voices
        @outrb SGMI, 00000001b          ; Enhaced mode
        @outrb SLFOBI, 0                ; LFOs disabled

        @outrb UASBCI, 0
        @outrb UAT2I, 0CCh


        mov   bl, xmp_devirq1
        cmp   bl, 2                     ; Set and enable IW IRQ (BL=IRQ num)
        jne   short $+4                 ; & install IRQ handle
        mov   bl, 9
        cmp   bl, 7
        seta  al
        movzx eax,al
        mov   ax, irqm0tbl[eax*2]
        mov   irqm0, ax
        mov   edx, offset iw_irq
        call  _setirqvect
        mov   edi, offset rmiwirqbuf
        call  _rmpmirqset
        mov   ormiwirqvect, eax
        xor   al, al
        call  _setirqmask


        popad
        clc
        ret



;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ iw_play                                                ±
;±  FUNCTION:      ³ Set soundcard to start playing                         ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
align 16
iw_play:
        pushad

        mov  ax, 900h
        int  31h
        push ax

;       call iw_sce

        mov  ax, s_bpm
        mov  bpm, ax
        mov  ax, s_speed
        mov  speed, ax

        mov  dx, p_mix
        mov  al, 00001100b
        out  dx, al

        @outrb UASBCI, 0
        @outrb UASBCI, 00001000b

                                        ; Again, make the timer2 start counting
        mov  dx, p_timctl               ; Timer control register
        mov  al, 4
        out  dx, al
        mov  dx, p_timdat               ; Timer data register
        mov  al, 00000010b
        out  dx, al

;       REPT 32
        mov  dx, p_regsel               ; Clear IRQ pending registers
        mov  al, SVII
        out  dx, al
        mov  dx, p_hidata
        in   al, dx
;       ENDM

        call iw_timer                   ; set the speed

        pop  ax
        int  31h

        popad
        ret



;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ iw_end                                                 ±
;±  FUNCTION:      ³ Uninit the Interwave                                   ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
align 16
iw_end:

        push eax bx dx

        mov  ax, 900h
        int  31h
        push ax

        @outrb SGMI, 0                  ; GUS comp. mode
        @outrb URSTI, 0                 ; Reset GUS
        call _delay2                    ; ...wait...
        @outrb URSTI, 1                 ; DAC dis/IRQ dis

        mov  dx, p_mix
        mov  al, 00001011b              ; Disable sound
        out  dx, al


        mov  bl, xmp_devirq1
        mov  eax, ormiwirqvect
        call _rmpmirqfree
        mov  al, 1
        call _setirqmask

        pop  ax
        int  31h



        pop  dx bx eax
        ret


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ iw_stop                                                ±
;±  FUNCTION:      ³ Stop music playback                                    ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
align 16
iw_stop:
        ret



;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ iw_irq                                                 ±
;±  FUNCTION:      ³ Handle the IW GF1 IRQ                                  ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
align 16
iw_irq:
        pushad

        mov al,20h                      ; Report to the IRQ chip
        out 20h,al

        irqm0   dw      ?               ; Code previously set

        push ds
        sti
        cld

        mov  ds, cs:_seldata            ; Set PMode data segment
;       mov  es, cs:_seldata
;       mov  fs, cs:_seldata
;       mov  gs, cs:_seldata

;       @print msg01

irq_in:

        xor  eax, eax
        mov  dx, p_irqreg                ; Get the cause of the IRQ
        in   al, dx

;       @printh eax


;       test al, 00100000b
;       jnz irq_wavet                   ; Wavetable event (not used)
        test al, 00000100b
        jnz  irq_timer                  ; Timer event
        test al, 00001000b
        jnz  irq_timer                  ; Timer event

        jmp  irq_end                    ; If cannot determine cause, abort



irq_timer:

        mov  dx, p_regsel                ; Make the IW timer run again
        mov  al, UASBCI                  ; Timer control register
        out  dx, al
        mov  dx, p_hidata
        xor  ax, ax
        out  dx, al
        mov  al, 8
        out  dx, al

        call iw_timer

        call _XMP_Main                  ; Proccess the partiture and effects

;       jmp  irq_end

irq_end:


        pop  ds
        popad

        sti                             ; VERY important
        iretd





;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ iw_load                                                ±
;±  FUNCTION:      ³ Load sampledata into the IW memory                     ±
;±  ASSUME:        ³ s_* variables are set                                  ±
;±  OUTS:          ³ AL=1 if not enough IW memory                           ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
align 16
iw_load:
	pushad

        ; 1st: test for var.space

        movzx ebp, s_num
        cmp  ebp, 64
;       jge  nogusmem

        ; 2nd: analyze & convert sample type reg (loops, bits)

        xor  eax, eax
        mov  al, s_type
        mov  ah, al
        mov  bl, al
        and  al, 10000b
        shr  al, 2                      ; 16 bit
        and  ah, 1b
        shl  ah, 3                      ; loop en
        and  bl, 10b
        shl  bl, 2                      ; loop en
        mov  bh, bl
        shl  bh, 1                      ; bidir loop
        or   ah, bl
        or   al, ah
        or   al, bh
;       or   al, 100000b                ; IRQ en
        mov stype[ebp], al              ; stype-> sample type

        test al, 1000b
        jz   noloop                     ; No -> go to noloop

        ; 3rd: adjust size and address variables

        mov  ecx, s_loops
        mov  ebx, s_loopl
        mov  edi, iwaddr                ; EDI -> start position

        mov  sstart[ebp*4], edi         ; sstart -> start position
        add  ecx, ebx                   ; ECX -> sample lenght
        mov  esi, ecx
        add  esi, edi
        mov  send[ebp*4], esi           ; send -> end position
        mov  ebx, s_loops
        add  ebx, edi
        mov  sloop[ebp*4], ebx          ; loop -> loop position


        mov  ebx, xmp_devmem
        cmp  esi, ebx
;       jg   nogusmem


        mov  esi, s_start               ; ESI -> pc ram sample location

; ECX, ESI & EDI are set.

        jmp  @sendbyte2

noloop:

        mov  ecx, s_size                ; ECX -> sample lenght
        mov  edi, iwaddr                ; EDI -> start position

        mov  sstart[ebp*4], edi
        mov  sloop[ebp*4], edi
        mov  ebx, ecx
        add  ebx, edi

        mov  send[ebp*4], ebx


        mov  ebx, xmp_devmem
        cmp  esi, ebx
;       jg   nogusmem

        mov  esi, s_start               ; ESI -> pc ram location

        ; 4th: send sampledata to soundcard mem

@sendbyte2:
        mov  ax, 900h
        int  31h
        push ax

        mov  al, stype[ebp]


cont1:

        call @poke


        mov  al, stype[ebp]
        test al, 11000b                 ; Is any loop defined?
        jz   short noloop1              ; No -> continue with the load

        mov  esi, s_loops
        add  esi, s_start
        mov  ecx, 8
        call @poke
        jmp  short cont3


noloop1:
        mov  ecx, 4
        mov  esi, offset zerobuf
        call @poke


cont3:

        mov  eax, edi
        mov  ebx, eax
        and  ebx, 1
        add  eax, ebx
        mov  iwaddr, eax                ; Prevent 16 bit samples to
                                        ; be loaded on impar address
;       @printmh mkk, eax

        mov  al, stype[ebp]
        test al, 100b                   ; 16 bit?
        jz   cont2
        mov  eax, sstart[ebp*4]         ; convert to 16 bit address
        shr  eax, 1
        mov  sstart[ebp*4], eax

        mov  eax, send[ebp*4]
        shr  eax, 1
        mov  send[ebp*4], eax

        mov  eax, sloop[ebp*4]
        shr  eax, 1
        mov  sloop[ebp*4], eax

cont2:



        pop  ax
        int  31h

        popad
        xor  al, al
        ret


;nogusmem2:
;       @printmh mkk, iwaddr
;       @printmh mkk, xmp_devmem
;       ret

nogusmem:
        popad
        mov  al, 1
        ret


align 16
@poke:
        test ecx, ecx
        jz   endload

        push ebx
        mov  dx, p_regsel               ; Choose the low_address register
	mov  al, LMALI
	out  dx, al
	mov  dx, p_lodata               ; Data port
	mov  eax, edi                   ; ax=GUS DRAM address low 16 bits
	out  dx, ax

	mov  dx, p_regsel               ; Choose high_address register
	mov  al, LMAHI
	out  dx, al
	mov  dx, p_hidata               ; Data port
	shr  eax, 16                    ; al=GUS DRAM address 4 bits+4 unused
	out  dx, al


        mov  dx, p_regsel               ; Read LMCI status
        mov  al, LMCI
        out  dx, al
        mov  dx, p_hidata
        in   al, dx
        mov  bl, al
        push ax
        or   bl, 1b                     ; Set "auto" flag
        @outrb LMCI, bl

;       add  edi, ecx
	mov  dx, p_dramrw               ; DRAM read/write port

@loadbyte:
	mov  al, [esi]                  ; Byte to send
	inc  esi                        ; inc the mem address
        inc  edi
	out  dx, al                     ; Here u r
	dec  ecx                        ; dec the length
	jnz  short @loadbyte


        pop  ax
        mov  bl, al
        @outrb LMCI, bl
        pop  ebx

endload:

        ret



;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ iw_csf                                                 ±
;±  FUNCTION:      ³ Change sample frequency                                ±
;±  ASSUME:        ³ - AL  the channel number                               ±
;±                 ³ - s_*  variable are set                                ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
align 16
iw_csf:

        pushad

        mov  dx, p_pagsel               ; Select channel from al
        out  dx, al

        mov  dx, p_regsel               ; Set the frequency from s_freq
        mov  al, SFCI
        out  dx, al
        mov  eax, s_freq
        call _freqconv
        mov  dx, p_lodata
        out  dx, ax

        popad
        ret


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ iw_csv                                                 ±
;±  FUNCTION:      ³ Change sample volume                                   ±
;±  ASSUME:        ³ - AL  the channel number                               ±
;±                 ³ - s_*  variable are set                                ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
align 16
iw_csv:

        pushad

        mov  dx, p_pagsel               ; Select channel from al
        out  dx, al
        jmp  iw_csv_3

iw_csv_2:
        pushad
iw_csv_3:


        movzx ebp, al

        xor  ebx, ebx

        mov  ax, s_vol
        cmp  ax, pvol[ebp*2]
        je   nochange

 	mov  dx, p_regsel
 	mov  al, SVCI                   ; Volume control
 	out  dx, al
	mov  dx, p_hidata
	mov  al, 00000011b              ; Ramp stop
	out  dx, al


 	mov  dx, p_regsel
  	mov  al, SVRI                   ; Volume ramp rate (max)
  	out  dx, al
        mov  dx, p_hidata
        mov  al, 63
  	out  dx, al


        mov  ax, s_vol
        cmp  ax, pvol[ebp*2]
        ja   volup


        mov  dx, p_regsel
 	mov  al, SVSI                   ; Volume ramp end (unused)
 	out  dx, al                     ; 15-12 exponent
 	mov  dx, p_hidata               ; 11-4 mantissa
  	mov  bx, s_vol
;       shr  bx, 7                      ; (table=9bits,x2 (words))
        shr  bx, 8
        mov  ax, voltbl[ebx*2]
        shr  ax, 4
        out  dx, al


  	mov  dx, p_regsel
 	mov  al, SVLI+80h               ; Current volume
 	out  dx, al
	mov  dx, p_hidata
        in   al, dx
        mov  bl, al

 	mov  dx, p_regsel
 	mov  al, SVEI                   ; Volume ramp start (unused)
        out  dx, al                     ; 7-4 exponent
 	mov  dx, p_hidata               ; 3-0 mantissa
        mov  al, bl
        out  dx, al


 	mov  dx, p_regsel
 	mov  al, SVCI                   ; Volume control
 	out  dx, al
	mov  dx, p_hidata
	mov  al, 01000000b              ; Ramp decreasing
	out  dx, al

        jmp  se_fini

volup:

  	mov  dx, p_regsel
 	mov  al, SVLI+80h               ; Current volume
 	out  dx, al
	mov  dx, p_hidata
        in   al, dx
        mov  bl, al

 	mov  dx, p_regsel
 	mov  al, SVSI                   ; Volume ramp start (unused)
        out  dx, al                     ; 7-4 exponent
 	mov  dx, p_hidata               ; 3-0 mantissa
        mov  al, bl
        out  dx, al


        mov  dx, p_regsel
 	mov  al, SVEI                   ; Volume ramp end
 	out  dx, al                     ; 15-12 exponent
 	mov  dx, p_hidata               ; 11-4 mantissa
  	mov  bx, s_vol
        shr  bx, 8
        mov  ax, voltbl[ebx*2]
        shr  ax, 4
        out  dx, al


 	mov  dx, p_regsel
 	mov  al, SVCI                   ; Volume control
 	out  dx, al
	mov  dx, p_hidata
	mov  al, 000b                   ; Ramp increasing
	out  dx, al


se_fini:


        mov ax, s_vol
        mov pvol[ebp*2], ax

nochange:


        popad
        ret


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ iw_csp                                                 ±
;±  FUNCTION:      ³ Change sample panning                                  ±
;±  ASSUME:        ³ - AL  the channel number                               ±
;±                 ³ - s_*  variable are set                                ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

align 16
iw_csp:


        push eax edx

        mov  dx, p_pagsel               ; Select channel from al
        out  dx, al

        mov  dx, p_regsel
        mov  al, SROI                   ; Panning position
        out  dx, al
        mov  dx, p_hidata
        mov  ax, s_pan
        shr  ax, 12                     ; (Range 0 - 15)
        out  dx, al

        pop  edx eax
        ret


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ iw_pse                                                 ±
;±  FUNCTION:      ³ Play sample end                                        ±
;±  ASSUME:        ³ - AL  the channel number                               ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
align 16
iw_pse:

        pushad

        movzx ebp, al
        xor  ebx, ebx

        mov  dx, p_pagsel
        out  dx, al


 	mov  dx, p_regsel
 	mov  al, SVEI                   ; Volume ramp end (pvol)
        out  dx, al                     ; 7-4 exponent
 	mov  dx, p_hidata               ; 3-0 mantissa
  	mov  bx, pvol[ebp*2]
        shr  bx, 8
        mov  ax, voltbl[ebx*2]
        shr  ax, 4
 	out  dx, al
        @outrb SVSI, 0
        @outrb SVRI, 63
        @outrb SVCI, 1000000b

        mov  pvol[ebp*2], 0
;       @outrb SMSI, 000000010b

        popad
        ret



;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ iw_pss                                                 ±
;±  FUNCTION:      ³ Play sample start                                      ±
;±  ASSUME:        ³ - AL  the channel number                               ±
;±                 ³ - s_*  variable are set                                ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
align 16
iw_pss:
        pushad

        mov  esi, eax
        movzx ebp, s_num


;       mov  eax, esi

        mov  dx, p_pagsel               ; Select channel from al
        out  dx, al

        @outrb SMSI, 10b                ; Mode selector (active voice)



;       mov  ecx, sstart[ebp*4]         ; Select bank
;       shr  ecx, 22
;       and  ecx, 3
        @outrb SUAI, 0

        mov  ecx, sloop[ebp*4]          ; Loop address
        mov  ebx, ecx
        shr  ebx, 7
        @outrw SASHI, bx
        mov  ebx, ecx
        shl  ebx, 9
        @outrw SASLI, bx

        mov  ecx, send[ebp*4]           ; End address
        mov  ebx, ecx
        shr  ebx, 7
        @outrw SAEHI, bx
        mov  ebx, ecx
        shl  ebx, 9
        @outrw SAELI, bx

        @outrb SACI, stype[ebp]         ; Sample type

        mov  ecx, sstart[ebp*4]         ; Current (start) address
        mov  edx, s_offset
        add  ecx, edx
        mov  ebx, ecx
        shr  ebx, 7
        @outrw SAHI, bx
        mov  ebx, ecx
        shl  ebx, 9
        @outrw SALI, bx

        mov  dx, p_regsel               ; Set the frequency from s_freq
        mov  al, SFCI
        out  dx, al
        mov  eax, s_freq
        call _freqconv
        mov  dx, p_lodata
        out  dx, ax

        mov  eax, esi                   ; Set volume
        call iw_csv_2

        mov  dx, p_regsel               ; Panning position
        mov  al, SROI
        out  dx, al
        mov  dx, p_hidata
        mov  ax, s_pan
        shr  ax, 12
        out  dx, al



        @outrb SMSI, 00001100b          ; Mode selector (active voice)

        @outrb SEASI, 010h              ; Effect acc. selector
        @outrw SEVFI, 1000h             ; Effects volume
        @outrw SEVI, 1000h

; FX            Signal
;-----------------------------------------
; 0             0       8      16      24
; 1             1       9      17      25
; 2             2      10      18      26
; 3             3      11      19      27
; 4             4      12      20      28
; 5             5      13      21      29
; 6             6      14      22      30
; 7             7      15      23      31


;       call iw_sce

        popad
        ret



;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ iw_psi                                                 ±
;±  FUNCTION:      ³ Play sample init                                       ±
;±  ASSUME:        ³ - AL  the channel number                               ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
align 16
iw_psi:
        pushad

        movzx ebp, al
        mov  pvol[ebp*2], 0

        @outb p_pagsel                  ; Select channel

        @outrb SMSI, 10b
        @outrw SASHI, 0
        @outrw SASLI, 0
        @outrw SAEHI, 0
        @outrw SAELI, 0
        @outrw SAHI, 0
        @outrw SALI, 0
        @outrw SEAHI, 0
        @outrw SEALI, 0
        @outrw SFCI, 0
        @outrb SFLFOI, 0
        @outrb SACI, 0
        @outrb SVSI, 0
        @outrb SVEI, 0
        @outrw SVLI, 0
        @outrb SVRI, 0
        @outrb SVCI, 111b
        @outrb SVLFOI, 0
        @outrw SROI, 0
        @outrw SROFI, 0
        @outrw SLOI, 0
        @outrw SLOFI, 0
        @outrw SEVI, 7000h
        @outrw SEVFI, 7000h
        @outrb SEASI, 010h


        popad
        ret

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ iw_sce                                                 ±
;±  FUNCTION:      ³ Set channel effect                                     ±
;±  ASSUME:        ³ - AL is the fx channel number (0 - 7)                  ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
align 16
BSIZE=01900h
DELAY=1800h
BASE=(1024*512)-BSIZE

iw_sce:
;       ret

        pushad
        mov  eax, 28


;       mov  esi, eax
;       movzx ebp, s_num

        mov  dx, p_pagsel               ; Select channel from al
        out  dx, al

        @outrb SMSI, 11b                ; Mode selector (active voice)

;       mov  ecx, sstart[ebp*4]         ; Select bank
;       shr  ecx, 22
;       and  ecx, 3
        @outrb SUAI, 0

        mov  ecx, BASE                       ; Loop address
        mov  ebx, ecx
        shr  ebx, 7
        @outrw SASHI, bx
        mov  ebx, ecx
        shl  ebx, 9
        @outrw SASLI, bx

        mov  ecx, BASE+BSIZE                  ; End address
        mov  ebx, ecx
        shr  ebx, 7
        @outrw SAEHI, bx
        mov  ebx, ecx
        shl  ebx, 9
        @outrw SAELI, bx

        @outrb SACI, 00001100b          ; Sample type

        mov  ecx, BASE+100                          ; Current (start) address
        mov  ebx, ecx
        shr  ebx, 7
        @outrw SAHI, bx
        mov  ebx, ecx
        shl  ebx, 9
        @outrw SALI, bx

        mov  ecx, BASE+DELAY                   ; Effect address
        mov  ebx, ecx
        shr  ebx, 7
        @outrw SEAHI, bx
        mov  ebx, ecx
        shl  ebx, 9
        @outrw SEALI, bx

        @outrw SFCI, 400h

;       mov  s_vol, 0FFFFh
;       mov  eax, esi                   ; Set volume
;       call iw_csv_2

        @outrb SVCI, 00000111b          ; ROLLOVER YES or NO???
        @outrb SVSI, 07Fh
        @outrb SVEI, 07Fh
        @outrw SVLI, 0FFFFh

        @outrb SROI, 8

        @outrb SMSI, 00001101b          ; Mode selector (active voice)

        @outrb SEASI, 010h              ; Effect acc. selector
        @outrw SEVFI, 1000h             ; Effects volume
        @outrw SEVI, 1000h


        popad
        ret

;-------------------------------------------------------------------------



;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ iw_timer                                               ±
;±  FUNCTION:      ³ Set the BPMs                                           ±
;±  ASSUME:        ³ - s_bpm variable set                                   ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
; Directly from Timeles...
align 16
iw_timer:

        push ax bx dx

        mov  ax, 900h
        int  31h
        push ax

        mov  bx, s_bpm
        xor  dx, dx
;       mov  ax, 3125
        mov  ax, 7812                   ; Magic divisor ;-)

        div  bx
        mov  bl, al
        neg  bl

        mov  dx, p_regsel               ; Send new data to the timer 2
        mov  al, UAT2I
        out  dx, al
        mov  dx, p_hidata
        mov  al, bl
        out  dx, al

        pop  ax
        int  31h                        ; restore interrupt flag

        pop  dx bx ax
        ret


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ _freqconv                                              ±
;±  FUNCTION:      ³ Translate Hz freq values to IW freq values             ±
;±  ASSUME:        ³ - EAX is the frequency in Hz                           ±
;±  OUTS:          ³ - AX contains the converted, IW frequency              ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
align 16
_freqconv:
        push edx
        shl  eax, 9
        mov  edx, freqfactor
        shr  edx, 1
        add  eax, edx
        xor  edx, edx
        div  dword ptr freqfactor
        shl  eax, 1
        pop  edx
        ret


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ _delay                                                 ±
;±  FUNCTION:      ³ Force a 22+ microseconds delay                         ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
align 16
_delay2:
	push ax dx
	mov  dx, p_dramrw
        REPT 35
        in   al, dx
        ENDM
        pop  dx ax
	ret


;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
code32  ends
	end


