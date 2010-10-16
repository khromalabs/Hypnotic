; -----------------------------------------------------------------------
;      Super-Incredible Textmode XM Player (tm)
;             version 1.0
;             by Mentat/EXOBiT
;             1995-97 rapapauer
; -----------------------------------------------------------------------


        .386p




; Include files
include pmode.inc                       ; PMode kernel
include debug.inc                       ; Debug tools
include argc.inc                        ; Command-line argument handling
include file.inc                        ; File handling
include xmp.inc                         ; XMP


; ASCII characters
cr      = 13                            ; Enter
lf      = 10                            ; Line feed
zz      = 36                            ; ASCIIZ end character ($)

DEFRAM  = 768


code32  segment para public use32
	assume cs:code32, ds:code32

public _main


;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
;ฑฑ  DATA                                                                     ฑฑ
;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ

; Messages
m_init          db      "   -----------------------------------------------------------------------",cr,lf
                db      "        Super-Incredible Textmode XM Player =:o ",cr,lf
                db      "               version 1.0",cr,lf
                db      "               by Mentat/EXOBiT",cr,lf
                db      "   -----------------------------------------------------------------------",cr,lf
                db      cr,lf,cr,lf,zz


m_end           db      cr,lf
                db      "   (-)  Returning to DOS...",cr,lf,zz
m_read          db      "   (-)  Reading file...",cr,lf,zz




m_e_par         db      "   (!)  Error: a filename is needed.",cr,lf
                db      "        Syntax: player song.xm",cr,lf,zz

m_e_ram         db      "   (!)  Error: not enough free mem",cr,lf,zz
m_e_low         db      "   (!)  Error: not enough free low mem for buffers",cr,lf,zz

m_e_fi1         db      "   (!)  Error: file not found",cr,lf,zz
m_e_fi2         db      "   (!)  Error: cannot read file",cr,lf,zz
m_e_fi3         db      "   (!)  Error: file is not a XM",cr,lf,zz


m_xmi2          db      "   (-)  Loading samples...",cr,lf,zz
m_xmi3          db      "   (-)  Playback start",cr,lf,zz
m_xmt0          db      "   (-)  Detecting soundcard...",cr,lf,zz
m_xmt10         db      "        o Gravis GF1                   ",cr,lf,zz
m_xmt11         db      "        o AMD Interwave                ",cr,lf,zz
m_xmt20         db      "        o EMU8000 (AWE32)              ",cr,lf,zz
m_xmt80         db      "        o Soundblaster                 ",cr,lf,zz
m_xmt81         db      "        o Soundblaster Pro             ",cr,lf,zz
m_xmt82         db      "        o Soundblaster 16              ",cr,lf,zz
m_xmt90         db      "        o Pro Audio Spectrum 16        ",cr,lf,zz
m_xmtA0         db      "        o Gravis GF1 (soft. mixing)    ",cr,lf,zz
m_xmtB0         db      "        o Crystal codec                ",cr,lf,zz
m_xmtp          db      "              port: $"
m_xmti         db cr,lf,"              irq:  $"
m_xmtd         db cr,lf,"              dma:  $"
m_xmtr         db cr,lf,"              ram:  $"
m_xmtz          db       cr,lf,zz

m_e_sc1         db      "   (!)  Error: no soundcard",cr,lf,zz
m_e_sc2         db      "   (!)  Error: XMP internal crash (no mem?)",cr,lf,zz
m_e_sc3         db      "   (!)  Warning: not enough soundcard ram for samples",cr,lf,zz
m_e_sc4         db      "   (!)  Error: too many channels",cr,lf,zz


xmname          db      80h dup (?)     ; File name
xmsize          dd      ?               ; File size
xmaddr          dd      ?               ; File addr

exitcode        dd      0               ; Exit code

;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
;ฑฑ  CODE                                                                     ฑฑ
;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ

;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
; Init program

_main:

	sti
        cld

        @print m_init                   ; Title message


	xor  al, al                     ; Check command-line parameters
	mov  edx, offset xmname
	call _cchekstr
	jc   err_nopara

	movzx eax, _filebuflen          ; Initialize file buffer
	call _getlomem
	jc   err_nolowmem
	mov  _filebufloc, eax


;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
; Read XM

        @print m_read

	mov  edx, offset xmname         ; Open file
	call _openfile
	jc   err_noopen

; Try to load the xm on high mem first. If file is loaded on
; low ram, you may leave not enough free for dma buffers.

	call _filesize                  ; File size?
	mov  xmsize, eax
	call _gethimem                  ; Allocate mem
;       jnc  ok_high
;       call _getmem                    ; Allocate low mem (if not high)
        jc  err_nomem
;ok_high:
        mov  xmaddr, eax

        mov  edx, xmaddr                ; Read file
        mov  ecx, xmsize
        call _readfile
        jc   err_noread

        call _closefile                 ; Close file

;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
; Play XM

        @print m_xmt0                   ; Detecting soundcard
        call _XMP_Detect
	cmp  xmp_devtype, 0
	je   err_nocard
        mov  al, xmp_devtype
        cmp  al, 010h
        je   t10
        cmp  al, 011h
        je   t11
        cmp  al, 020h
        je   t20
        cmp  al, 080h
        je   t80
        cmp  al, 081h
        je   t81
        cmp  al, 082h
        je   t82
        cmp  al, 090h
        je   t90
        cmp  al, 0A0h
        je   tA0
        cmp  al, 0B0h
        je   tB0
        jmp  err_nocard

t10:    @print m_xmt10
        jmp  spec
t11:    @print m_xmt11
        jmp  spec
t20:    @print m_xmt20
        jmp  spec
t80:    @print m_xmt80
        mov  xmp_devmem, DEFRAM*1024
        jmp  spec
t81:    @print m_xmt81
        mov  xmp_devmem, DEFRAM*1024
        jmp  spec
t82:    @print m_xmt82
        mov  xmp_devmem, DEFRAM*1024
        jmp  spec
t90:    @print m_xmt90
        jmp  spec
tA0:    @print m_xmtA0
        jmp  spec
tB0:    @print m_xmtB0
        jmp  spec

spec:
        movzx eax, xmp_devport
        @printmh m_xmtp, eax
        movzx eax, xmp_devirq1
        @printmd m_xmti, eax
        movzx eax, xmp_devdma1
        @printmd m_xmtd, eax
        mov  eax, xmp_devmem
        @printmd m_xmtr, eax
        @print m_xmtz

        call _XMP_Init                  ; Init player
        test al, al
        jnz  err_noinit


        @print m_xmi2
        mov  edx, xmaddr                ; Load XM on soundcard
        xor  al, al
        call _XMP_Load
        test al, al
        jnz  err_noinit

        call _XMP_Play
        test al, al
        jnz  err_noinit
        @print m_xmi3

@playloop:
        cmp  xmp_flag, 3                ; Check for xm end
        je   exitloop

        mov  ax, gs:[41Ah]              ; Check for keypress
 	cmp  ax, gs:[41Ch]
	je   @playloop
        mov  gs:[41Ch], ax


exitloop:
        call _XMP_End



;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
; Quit program
finish:
	@print m_end                    ; End banner
        mov  eax, exitcode
	jmp  _exit                      ; Quit


;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
; Error handling
err_nopara:                             ; No comm-lin parameters
        @print m_e_par
        mov  exitcode, 1
        jmp  finish

err_nomem:                              ; No mem
        @print m_e_ram
        mov  exitcode, 1
        jmp  finish

err_nolowmem:                           ; No low mem
        @print m_e_low
        mov  exitcode, 1
        jmp  finish

err_noopen:                             ; Can't open file
        @print m_e_fi1
        mov  exitcode, 1
        jmp  finish

err_noread:                             ; Can't read file
        @print m_e_fi2
        mov  exitcode, 1
        jmp  finish

err_nocard:                             ; No soundcard
        @print m_e_sc1
        mov  exitcode, 1
        jmp  finish

err_noinit:                             ; No soundcard (?)
        @print m_e_sc2
        mov  exitcode, 1
        jmp  finish

;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
code32  ends
	end

