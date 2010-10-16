;              Exobit Audio System v0.5P (peta)
;
;
; (C) Copyleft 1996 Mentat of EXOBIT.
;
; Main module and pattern processor


    .386p                           ;-)





; CONSTANTS:


; Limits
MAXCHANN    equ 32                  ; Max total voices
MAXSNGCHANN equ 32                  ; Max song channels
MAXRESCHANN equ 8                   ; Max reserved channels

MAXINST     equ 64                  ; Max instrument number
MAXSAMP     equ 0Fh                 ; Max sample number


; Error codes
EC_FILETYPE equ 010h                ; File is not a XM
EC_MEM      equ 011h                ; Not enough mem
EC_CHANN    equ 012h                ; Too many channels
EC_DEVICE   equ 020h                ; Soundcard not found
EC_WTRAM    equ 021h                ; Not enough card mem
EC_UNKN     equ 0F0h                ; Unknown error


; ascii
cr          equ 13                  ; Enter
lf          equ 10                  ; Line feed
zz          equ 36                  ; ASCIIZ end character ($)




; STRUCTURES:
; Inst: instrument structure of FT2 XM file
; Sample: sample header

sample  Struc
    sname       db  22 dup(?)           ; Name
    ssize       dd  ?                   ; Data size
    snum        db  ?                   ; Sample number
    sloops      dd  ?                   ; Loop start position
    sloopl      dd  ?                   ; Loop length
    svolume     db  ?                   ; Volume
    sftune      db  ?                   ; Finetune (-16 to +15)
    stype       db  ?                   ; Type: (XM)
                                        ;  bit 0,1: no loop, forward loop,
                                        ;           pingpong loop
                                        ;  bit 4: 16 bit
    spanning    db  ?                   ; Panning position
    srelnote    db  ?                   ; Relative note
;    reserved02  db  7 dup(?)
sample  EndS


Inst    Struc
	keymap      db  96 dup(?)           ; Note/#sample map
    volepos     dw  12 dup(?)           ; Vol envelope points
	volerate    dd  12 dup(?)           ; Vol envelope rates
	panepos     dw  12 dup(?)           ; Pan envelope points
	panerate    dd  12 dup(?)           ; Pan envelope rates
	name        db  22 dup(?)           ; Instrument name
	numvolp     db  ?                   ; # of vol envelope points
	numpanp     db  ?                   ; # of pan envelope points
	volsust     db  ?                   ; Volume sustain point
	volloops    db  ?                   ; Volume loop start point
	volloope    db  ?                   ; Volume loop end point
	pansust     db  ?                   ; Panning sustain point
	panloops    db  ?                   ; Panning loop start point
	panloope    db  ?                   ; Panning loop end point
	voltype     db  ?                   ; Volume envelope type:
     									;  bit 0 : envelope on/off
										;  bit 1 : sustain on/off
										;  bit 2 : loop on/off
 	pantype     db  ?                   ; Panning envelope type
	vibtype     db  ?                   ; Vibrato type
	vibsweep    db  ?                   ; Vibrato sweep
	vibdepth    db  ?                   ; Vibrato depth
	vibrate     db  ?                   ; Vibrato rate
	volfade     dw  ?                   ; Volume fadeout
    sampnum     db  ?                   ; Number of samples
    samp        sample 16 dup(?)        ; The 16 sample headers
    reserved01  db 105 dup (?)          ; to fit in 1024 bytes per inst
;   reserved01  db 282 dup (?)          ; to fit in 1024 bytes per inst
;    reserved01  db (1024 - 230 - (size sample)*16) dup(?)   ; to fit in 1024 bytes per inst
Inst    EndS



; PUBLIC DATA / PROCEDURES:

                                        ; Song data
public xmp_sngname                      ;   Name
public xmp_snglen                       ;   Lenght
public xmp_sngchann                     ;   Channels
public xmp_snginst                      ;   # instruments
                                        ; Digital playback data
public xmp_digchann                     ;   Reserved channels
                                        ; Sound device data
public xmp_devtype                      ;   Device type
public xmp_devport                      ;   Base port
public xmp_devirq1                      ;   1st IRQ
public xmp_devirq2                      ;   2nd IRQ
public xmp_devdma1                      ;   1st DMA
public xmp_devdma2                      ;   2nd DMA
public xmp_devmem                       ;   Wavetable RAM
public xmp_devchann                     ;   Total active voices
                                        ; Misc
public xmp_status                       ;   Status flag (byte)
public xmp_flag                         ;   Pattern flag (byte)

; Sample data interchange variables

public  s_num
public  s_start
public  s_size
public  s_loops
public  s_loopl
public  s_type

public  s_offset
public  s_freq
public  s_vol
public  s_pan

public  s_speed
public  s_bpm


; Main routines

public  _XMP_Init
public  _XMP_Detect
public  _XMP_Load
public  _XMP_Play
public  _XMP_Stop
public  _XMP_Prog
public  _XMP_End
public  _XMP_Fire
public  _XMP_Main

include pmode.inc                       ; Main PMode stuff
include debug.inc                       ; Some debug utilities

include gus.inc                         ; Lowlevel GUS routines
;include awe.inc                         ; Lowlevel AWE32 routines
include iw.inc                          ; Lowlevel GUS PnP routines
include sb.inc                          ; Lowlevel SB routines


code32  segment para public use32
	assume cs:code32, ds:code32


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±±  DATA                                                                     ±±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±



align 4
; Mem
datasize        dd      ?               ; File size
dataaddr        dd      ?               ; Loaded file start address
instaddr        dd      ?               ; Instr start address
pattaddr        dd      ?               ; Pattern start address



; Strings (DOS variable detection, XM checking)
headr1          db 'Extended Module:'   ; XM header



align 4
; XM init settings
sngname         db      21 dup (0)      ; Module name (last byte 0)
snglen          db      0               ; Pattern seq lenght
sngrestart      db      0               ; Restart position
sngchann        db      0               ; # of channels
sngpatt         db      0               ; # of patterns
sngins          db      0               ; # of instruments
sngftable       db      1               ; Freq table flag (0=amiga, 1=linear)
sngspeed        dw      6               ; default tempo
sngbpm          dw      125             ; default BPMs



; Public variables set
xmp_sngname     dd      0
xmp_snglen      db      0
xmp_sngchann    db      0
xmp_snginst     db      0
xmp_digchann    db      0
xmp_devtype     db      0
xmp_devport     dw      0
xmp_devirq1     db      0
xmp_devirq2     db      0
xmp_devdma1     db      0
xmp_devdma2     db      0
xmp_devmem      dd      0
xmp_status      db      0
xmp_flag        db      0
xmp_devaddr     dd      0
xmp_devchann    db      0


align 4
; Partiture dynamic data / misc
;channel individual
acflag          db      32 dup (0)      ; Actual sample flag
acins           db      32 dup (0)      ; Actual instrument
acnins          db      32 dup (0)      ; Next instrument
acsam           db      32 dup (0)      ; Actual sample
acnote          db      32 dup (0)      ; Actual note (for ramps, multisample, etc)
;acfreq          dd      32 dup (0)      ; Actual channel frequency value
acfvol          dw      32 dup (0)      ; Actual fadeout volume
acfrate         dw      32 dup (0)      ; Actual fadeout rate
acpvol          db      32 dup (0)      ; Actual pattern volume
acevol          dd      32 dup (0)      ; Actual envelope volume
acppan          db      32 dup (0)      ; Actual pattern panning
acepan          dd      32 dup (0)      ; Actual envelope panning
acevpos         dw      32 dup (0)      ; Actual vol env position
aceppos         dw      32 dup (0)      ; Actual pan env position
acevpnt         db      32 dup (0)      ; Actual vol env point
aceppnt         db      32 dup (0)      ; Actual pan env point
acrnote         db      32 dup (0)      ; Actual relative note
acftune         db      32 dup (0)      ; Actual channel finetune
acfx            db      32 dup (0)      ; Actual effect
acfxv1          db      32 dup (0)      ; Effect variable 1 (byte)
acfxv2          dw      32 dup (0)      ; Effect variable 2 (word)
acfv            db      32 dup (0)      ; Actual effect (volume column)
acfvv1          db      32 dup (0)      ; Effect variable 1 (byte) (vc)
acfvv2          dw      32 dup (0)      ; Effect variable 2 (word) (vc)


acper           dw      32 dup (0)      ; Actual PERIOD
acporta         dw      32 dup (0)      ; Actual period fx3 "target"
acvloop         dd      32 dup (0)      ; Actual volume loop
acploop         dd      32 dup (0)      ; Actual panning loop


nze_10          db      32 dup (0)      ; Last nonzero value for fx
nze_20          db      32 dup (0)      ; Last nonzero value for fx
nze_30          db      32 dup (0)      ; Last nonzero value for fx
nze_302         dw      32 dup (0)      ; Last nonzero value for fx
nze_40          db      32 dup (0)      ; Last nonzero value for fx
nze_50          db      32 dup (0)      ; Last nonzero value for fx
nze_60          db      32 dup (0)      ; Last nonzero value for fx
nze_70          db      32 dup (0)      ; Last nonzero value for fx
nze_90          db      32 dup (0)      ; Last nonzero value for fx
nze_A0          db      32 dup (0)      ; Last nonzero value for fx
nze_E1          db      32 dup (0)      ; Last nonzero value for fx
nze_E2          db      32 dup (0)      ; Last nonzero value for fx
nze_EA          db      32 dup (0)      ; Last nonzero value for fx
nze_EB          db      32 dup (0)      ; Last nonzero value for fx
nze_H0          db      32 dup (0)      ; Last nonzero value for fx
nze_P0          db      32 dup (0)      ; Last nonzero value for fx
nze_R0          db      32 dup (0)      ; Last nonzero value for fx
nze_X1          db      32 dup (0)      ; Last nonzero value for fx
nze_X2          db      32 dup (0)      ; Last nonzero value for fx

;general
acgvol          db      40h             ; General volume
acspeed         dw      ?               ; Actual speed
acbpm           dw      ?               ; Actual BPM
acvoices        db      0               ; Actual active voices
acpat           db      0               ; Actual pattern
acpos           db      0               ; Actual row
acadd           dd      0               ; Actual position

;misc
acsn            db      0               ; Acutal sample
acin            db      0               ; Actuan instrument
errorcod        db      0               ; Error code to be returned on ret
timecount       dw      0               ; Time counter

;pattern
align 4
pattbl          db      256 dup (0)     ; Pattern order table
patadd          dd      256 dup (0)     ; Pattern start address
patlen          db      256 dup (0)     ; Pattern lenght
patchg          db      0               ; Position change flag


; Sample data interchange
align 4
s_start         dd      0               ; Start address
s_size          dd      0               ; End address
s_loops         dd      0               ; Loop start address
s_loopl         dd      0               ; Loop end address
s_offset        dd      0               ; Offset
s_freq          dd      0               ; Frequency
s_vol           dw      0               ; Volume
s_pan           dw      0               ; Panning
s_type          db      0               ; Type
s_num           db      0               ; Number

s_speed         dw      6               ; Song speed
s_bpm           dw      125             ; BPMs

; Loader temporal variables
loadin          db      0               ; Current instrument number
loadsn          db      0               ; Current sample number
loadtsn         db      0               ; Current "total" sample number

align 4
                                        ; Log table for linear period
lintab	dw	16726,16741,16756,16771,16786,16801,16816,16832,16847,16862,16877,16892,16908,16923,16938,16953
	    dw	16969,16984,16999,17015,17030,17046,17061,17076,17092,17107,17123,17138,17154,17169,17185,17200
	    dw	17216,17231,17247,17262,17278,17293,17309,17325,17340,17356,17372,17387,17403,17419,17435,17450
	    dw	17466,17482,17498,17513,17529,17545,17561,17577,17593,17608,17624,17640,17656,17672,17688,17704
	    dw	17720,17736,17752,17768,17784,17800,17816,17832,17848,17865,17881,17897,17913,17929,17945,17962
	    dw	17978,17994,18010,18027,18043,18059,18075,18092,18108,18124,18141,18157,18174,18190,18206,18223
	    dw	18239,18256,18272,18289,18305,18322,18338,18355,18372,18388,18405,18421,18438,18455,18471,18488
	    dw	18505,18521,18538,18555,18572,18588,18605,18622,18639,18656,18672,18689,18706,18723,18740,18757
	    dw	18774,18791,18808,18825,18842,18859,18876,18893,18910,18927,18944,18961,18978,18995,19013,19030
	    dw	19047,19064,19081,19099,19116,19133,19150,19168,19185,19202,19220,19237,19254,19272,19289,19306
	    dw	19324,19341,19359,19376,19394,19411,19429,19446,19464,19482,19499,19517,19534,19552,19570,19587
	    dw	19605,19623,19640,19658,19676,19694,19711,19729,19747,19765,19783,19801,19819,19836,19854,19872
	    dw	19890,19908,19926,19944,19962,19980,19998,20016,20034,20052,20071,20089,20107,20125,20143,20161
    	dw	20179,20198,20216,20234,20252,20271,20289,20307,20326,20344,20362,20381,20399,20418,20436,20455
    	dw	20473,20492,20510,20529,20547,20566,20584,20603,20621,20640,20659,20677,20696,20715,20733,20752
	    dw	20771,20790,20808,20827,20846,20865,20884,20902,20921,20940,20959,20978,20997,21016,21035,21054
    	dw	21073,21092,21111,21130,21149,21168,21187,21206,21226,21245,21264,21283,21302,21322,21341,21360
	    dw	21379,21399,21418,21437,21457,21476,21496,21515,21534,21554,21573,21593,21612,21632,21651,21671
    	dw	21690,21710,21730,21749,21769,21789,21808,21828,21848,21867,21887,21907,21927,21946,21966,21986
	    dw	22006,22026,22046,22066,22086,22105,22125,22145,22165,22185,22205,22226,22246,22266,22286,22306
    	dw	22326,22346,22366,22387,22407,22427,22447,22468,22488,22508,22528,22549,22569,22590,22610,22630
	    dw	22651,22671,22692,22712,22733,22753,22774,22794,22815,22836,22856,22877,22897,22918,22939,22960
    	dw	22980,23001,23022,23043,23063,23084,23105,23126,23147,23168,23189,23210,23230,23251,23272,23293
	    dw	23315,23336,23357,23378,23399,23420,23441,23462,23483,23505,23526,23547,23568,23590,23611,23632
    	dw	23654,23675,23696,23718,23739,23761,23782,23804,23825,23847,23868,23890,23911,23933,23954,23976
	    dw	23998,24019,24041,24063,24084,24106,24128,24150,24172,24193,24215,24237,24259,24281,24303,24325
    	dw	24347,24369,24391,24413,24435,24457,24479,24501,24523,24545,24567,24590,24612,24634,24656,24679
	    dw	24701,24723,24746,24768,24790,24813,24835,24857,24880,24902,24925,24947,24970,24992,25015,25038
    	dw	25060,25083,25105,25128,25151,25174,25196,25219,25242,25265,25287,25310,25333,25356,25379,25402
	    dw	25425,25448,25471,25494,25517,25540,25563,25586,25609,25632,25655,25678,25702,25725,25748,25771
    	dw	25795,25818,25841,25864,25888,25911,25935,25958,25981,26005,26028,26052,26075,26099,26123,26146
        dw	26170,26193,26217,26241,26264,26288,26312,26336,26359,26383,26407,26431,26455,26479,26502,26526
	    dw	26550,26574,26598,26622,26646,26670,26695,26719,26743,26767,26791,26815,26839,26864,26888,26912
	    dw	26937,26961,26985,27010,27034,27058,27083,27107,27132,27156,27181,27205,27230,27254,27279,27304
    	dw	27328,27353,27378,27402,27427,27452,27477,27502,27526,27551,27576,27601,27626,27651,27676,27701
    	dw	27726,27751,27776,27801,27826,27851,27876,27902,27927,27952,27977,28003,28028,28053,28078,28104
    	dw	28129,28155,28180,28205,28231,28256,28282,28307,28333,28359,28384,28410,28435,28461,28487,28513
    	dw	28538,28564,28590,28616,28642,28667,28693,28719,28745,28771,28797,28823,28849,28875,28901,28927
    	dw	28953,28980,29006,29032,29058,29084,29111,29137,29163,29190,29216,29242,29269,29295,29322,29348
    	dw	29375,29401,29428,29454,29481,29507,29534,29561,29587,29614,29641,29668,29694,29721,29748,29775
    	dw	29802,29829,29856,29883,29910,29937,29964,29991,30018,30045,30072,30099,30126,30154,30181,30208
    	dw	30235,30263,30290,30317,30345,30372,30400,30427,30454,30482,30509,30537,30565,30592,30620,30647
    	dw	30675,30703,30731,30758,30786,30814,30842,30870,30897,30925,30953,30981,31009,31037,31065,31093
    	dw	31121,31149,31178,31206,31234,31262,31290,31319,31347,31375,31403,31432,31460,31489,31517,31546
    	dw	31574,31602,31631,31660,31688,31717,31745,31774,31803,31832,31860,31889,31918,31947,31975,32004
    	dw	32033,32062,32091,32120,32149,32178,32207,32236,32265,32295,32324,32353,32382,32411,32441,32470
    	dw	32499,32529,32558,32587,32617,32646,32676,32705,32735,32764,32794,32823,32853,32883,32912,32942
    	dw	32972,33002,33031,33061,33091,33121,33151,33181,33211,33241,33271,33301,33331,33361,33391,33421

                                        ; Amiga period table
amitab  dw      907,900,894,887,881,875,868,862,856,850,844,838
        dw      832,826,820,814,808,802,796,791,785,779,774,768
        dw      762,757,752,746,741,736,730,725,720,715,709,704
        dw      699,694,689,684,678,675,670,665,660,655,651,646
        dw      640,636,632,628,623,619,614,610,604,601,597,592
        dw      588,584,580,575,570,567,563,559,555,551,547,543
        dw      538,535,532,528,524,520,516,513,508,505,502,498
        dw      494,491,487,484,480,477,474,470,467,463,460,457


                                        ; Vibrato effect table (sine wave)
vibtab	db        0, 24, 49, 74, 97,120,141,161
	    db      180,197,212,224,235,244,250,253
	    db      255,253,250,244,235,224,212,197
	    db      180,161,141,120, 97, 74, 49, 24



;Debugging-purpose msgs
mx              db  cr,lf,cr,lf,'  SONG STRUCTURE',cr,lf,'--------------------------------',0,zz
mx1             db  cr,lf,' * Module name:          ',0,zz
mx2             db  cr,lf,' * Song lenght:          ',0,zz
mx3             db  cr,lf,' * Number of channels:   ',0,zz
mx4             db  cr,lf,' * Number of patterns:   ',0,zz
mx5             db  cr,lf,' * Number of instruments:',0,zz
mx6             db  cr,lf,' * Default tempo:        ',0,zz
mx7             db  cr,lf,' * Default BPMs:         ',0,zz
mxn             db  cr,lf,'                           ',0,zz

mt              db  cr,lf,cr,lf,'  PATTERN STRUCTURE',cr,lf,'--------------------------------',0,zz
mt1             db  cr,lf,' + Pattern lenght:       ',0,zz
mt2             db  cr,lf,' + Pattern size:         ',0,zz

mi              db  cr,lf,cr,lf,'  INSTRUMENT STRUCTURE',cr,lf,'--------------------------------',0,zz
mi1             db  cr,lf,' + Instrumnt name:       ',0,zz
mi2             db  cr,lf,' + Number of samples:    ',0,zz
mi3             db  cr,lf,' + Samples:              ',0,zz
mi4             db  cr,lf,' + Precalculating vol envelope:',0,zz
mi5             db  cr,lf,' + Precalculating pan envelope:',0,zz
mi6             db  cr,lf,'       delta position:  ',0,zz
mi7             db        '       increment:       ',0,zz
mi8             db  cr,lf,'   - Sample name:  ',0,zz
mi9             db  cr,lf,'   - Sample size:  ',0,zz



ma              db  cr,lf,0,zz
mp              db  '.',0,zz
mp2             db  'o',0,zz
msgpp           db  '*', 0
mkk             db  cr, lf, 0, zz


; Lowlevel hardware procedures
sc_irq          dd offset nul
sc_init         dd offset nul
sc_load         dd offset nul
sc_play         dd offset nul
sc_stop         dd offset nul
sc_timer        dd offset nul
sc_pss          dd offset nul
sc_pse          dd offset nul
sc_end          dd offset nul
sc_csp          dd offset nul
sc_csv          dd offset nul
sc_csf          dd offset nul



; XM Player error codes (always in AL)
;
;  AL 1xh - file/mem error
;    * AL 10h - file is not a XM
;    * AL 11h - not enough mem
;    * AL 12h - too many channels
;  AL 2xh - soundcard error
;    * AL 20h - soundcard not found
;    * AL 21h - not enough card mem
;  AL F0h - unknown error

; About volume and panning accuracy: these variables are 16-bit wide
; for finer granularity. GF1 has only 16 panning positions, but I hope
; EMU and Interwave to have some more ;-)


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±±  CODE                                                                     ±±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±



;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ



;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ _XMP_Init                                              ±
;±  FUNCTION:      ³ Initializes soundcard                                  ±
;±  ASSUME:        ³ - device variables are set                             ±
;±  OUTS:          ³ - AX = errorcode (if any), or 0                        ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

_XMP_Init:

    pushad

    mov errorcod, 0

;    mov eax, size inst
;    @printmh mkk, eax
;    @printmh mkk, eax

    mov al, xmp_devtype


;   jmp gus

    cmp al, 10h                 ; Ultrasound
    je  gus


    cmp al, 11h                 ; Interwave
    je  gusp


    cmp al, 80h                 ; Soundblaster
    je  sb
    cmp al, 81h
    je  sb
    cmp al, 82h
    je  sb
    cmp al, 83h
    je  sb
    cmp al, 84h
    je  sb
    cmp al, 20h
    je  sb



    jmp nocard


gus:
    mov sc_init, offset gus_init
    mov sc_load, offset gus_load
    mov sc_play, offset gus_play
    mov sc_stop, offset gus_stop
;    mov sc_timer, offset gus_timer
    mov sc_pss, offset gus_pss
    mov sc_pse, offset gus_pse
    mov sc_end, offset gus_end
    mov sc_csp, offset gus_csp
    mov sc_csf, offset gus_csf
    mov sc_csv, offset gus_csv
    jmp init

;awe:
;    mov sc_init, offset awe_init
;    mov sc_load, offset awe_load
;    mov sc_play, offset awe_play
;    mov sc_stop, offset awe_stop
;    mov sc_end, offset awe_end
;    mov sc_pss, offset awe_pss
;    mov sc_pse, offset awe_pse
;    mov sc_end, offset awe_end
;    jmp init

gusp:
    mov sc_init, offset iw_init
    mov sc_load, offset iw_load
    mov sc_play, offset iw_play
    mov sc_stop, offset iw_stop
    mov sc_end, offset iw_end
    mov sc_pss, offset iw_pss
    mov sc_pse, offset iw_pse
    mov sc_end, offset iw_end
    mov sc_csp, offset iw_csp
    mov sc_csf, offset iw_csf
    mov sc_csv, offset iw_csv
    jmp init

sb:
    mov sc_init, offset sb_init
    mov sc_load, offset sb_load
    mov sc_play, offset sb_play
    mov sc_stop, offset sb_stop
    mov sc_end, offset sb_end
    mov sc_pss, offset sb_pss
    mov sc_pse, offset sb_pse
    mov sc_end, offset sb_end
    mov sc_csp, offset sb_csp
    mov sc_csf, offset sb_csf
    mov sc_csv, offset sb_csv
;    jmp init


init:

    call sc_init                ; Initialize soundcard

    mov eax, MAXINST*1024       ; Allocate mem for inst/samp headers (64K)
    call _getmem
    jc nomem0
    mov instaddr, eax


    mov eax, 256*1024           ; Allocate mem for patterndata (256K)
    call _getmem
    jc nomem0
    mov pattaddr, eax


    mov al, xmp_status          ; Status -> init
    or al, 1
    mov xmp_status, al
    mov errorcod, 0


endinit:

    popad
    mov al, errorcod
	ret


nocard:
    mov al, xmp_status          ; Status -> not init
    and al, 11111110b
    mov xmp_status, al
    mov errorcod, 20h
    jmp endinit

nomem0:
    mov al, xmp_status          ; Status -> not init
    and al, 11111110b
    mov xmp_status, al
    mov errorcod, EC_MEM        ; Not enough mem
    jmp endinit





;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ _XMP_Load                                              ±
;±  FUNCTION:      ³ Start XM Player sound engine                           ±
;±  ASSUME:        ³ - EDX is the pointer to the loaded XM file             ±
;±                 ³ - AL is the number of channels to reserve              ±
;±                 ³ - The player must be stopped b4 calling this!          ±
;±  OUTS:          ³ - if any error AL will be set, if not it will be 0     ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; A short explanation:
; The XM file structure seems to be not very defined. Offset
; changes are usual, and the txt file provided with FT2 missed a
; pair of deatils.
;
; But there's no problem, 'cause at the begining of each structure
; (song, pattern, instrument, sample) there is a header lenght
; field that really helps... but make the code a bit more difficult
; to read. I usually put these lenghts into the stack or auxiliar
; variables to make more regs avaiable.



_XMP_Load:


	pushad


                                ; Initialize variables
    mov errorcod, 0             ; Error code (0 for now)
    mov xmp_digchann, al        ; Reserved channels
    mov dataaddr, edx           ; Data address, given in EDX
    mov s_num, 0                ; Interchange sample number


    mov bl, xmp_status          ; Test if initialized
    test bl, 00000001b
    jz @uerror                  ; Already init!


                                ; Look if the dude reserved too many
    cmp al, MAXRESCHANN         ; channels
    jg @toomany



	mov esi, edx                ; Look for XM header
	mov edi, offset headr1
	mov ecx, 15
	repe cmpsb                  ; Is it OK?
	jne @noxm                   ; No -> oh, I'm sorry...




	mov esi, dataaddr
	add esi, 17
	mov edi, offset sngname     ; Store the song name for general use
    mov xmp_sngname, edi        ; Pointer to name string
	mov ecx, 20
	rep movsb



;---------------------
 ;   pushad
;    @print mx
;    @print mx1
;    mov esi, xmp_sngname
;    mov ecx, 10
;    mov edi, offset mxn
;    rep movsw
;    @print mxn
;    popad
;---------------------


                                ; Now ESI will be the memory pointer

	mov esi, dataaddr           ; Copy data to variables
	add esi, 60

	mov eax, [esi]              ; Header size
    add eax, esi                ; pos. of beginning of next filed
    add esi, 4
    mov ebp, eax


;----------------------------
;    xor eax, eax
;----------------------------
	mov ax, [esi]
	add esi, 2
	mov snglen, al              ; Song sequence leght
;----------------------------
;    @printmh mx2, eax
;----------------------------


	mov ax, [esi]
	add esi, 2
	mov sngrestart, al          ; Restart pattern


;----------------------------
;    xor eax, eax
;----------------------------
	mov ax, [esi]
	add esi, 2
    cmp ax, MAXSNGCHANN
    jg @toomany
	mov sngchann, al            ; Number of channels
	mov xmp_sngchann, al
	mov xmp_devchann, al
 	mov acvoices, al
;----------------------------
;    @printmh mx3, eax
;----------------------------

;    mov dl, xmp_digchann
;    add al, dl                  ; Check if the number of cahnnels in use
;    cmp al, MAXCHANN            ; is under the max number
;    jg @toomany
;   mov xmp_devchann, al



;----------------------------
;    xor eax, eax
;----------------------------
	mov ax, [esi]
	add esi, 2
	mov sngpatt, al             ; Number of patterns
;----------------------------
;    @printmh mx4, eax
;----------------------------


;----------------------------
;    xor eax, eax
;----------------------------
	mov ax, [esi]
	add esi, 2
	mov sngins, al              ; Number of instruments
;----------------------------
;    @printmh mx5, eax
;----------------------------


	mov ax, [esi]
	add esi, 2
	mov sngftable, al           ; Amiga-linear freq table flag byte


;----------------------------
;    xor eax, eax
;----------------------------
	mov ax, [esi]
	add esi, 2
	mov sngspeed, ax            ; Speed
;    mov acspeed, ax
;----------------------------
;    @printmh mx6, eax
;----------------------------


	mov ax, [esi]
	add esi, 2
	mov sngbpm, ax              ; BPMs
;   mov acbpm, ax
;----------------------------
;    @printmh mx7, eax
;----------------------------


	mov edi, offset pattbl
	mov ecx, 256
	rep movsb                   ; That will copy the pattern sequence
                                ; to a predefined memory zone


;---------------------
;    @print mt
;---------------------


    mov esi, ebp                ; Restore saved position

    xor ecx, ecx
    xor edx, edx                ; Pattern counter
    xor eax, eax
    mov edi, pattaddr

@pattern:
    cmp dl, sngpatt
    je @nopatt


    mov ebx, [esi]
    add ebx, esi
    add esi, 5
    mov cx, [esi]
    mov patlen[edx], cl         ; Pattern lenght (rows)
;----------------------------
;    @printmh mt1, ecx
;----------------------------
    mov patadd[edx*4], edi
    add esi, 2
    mov cx, [esi]               ; Size of patterndata
;----------------------------
;    @printmh mt2, ecx
;----------------------------
    mov esi, ebx
    rep movsb                   ; Copy patterndata to allocated zone


;    add esi, ecx

    inc edx
    jmp @pattern

@nopatt:

    xor eax, eax
    mov al, pattbl[0]
    mov edi, patadd[eax]
;    mov acadd, edi              ; First pattern address
    mov acpat, 0
    mov acpos, 0

    xor edx, edx                ; EDX = instr counter (0)

;---------------------
;    @print mi
;---------------------

    mov ebp, esi                ; Store mem position
    mov loadin, 0



@instr:

    mov esi, ebp


    movzx bx, sngins            ; Total instruments
    cmp dx, bx
    je @sefini

;---------------------
;    @print m4
;---------------------

    mov eax, [esi]              ; Instr header size
    add eax, esi                ; Pointer to first samp of curr instr or next instr
    mov ebp, eax                ; Stored mem position
    add esi, 4


    mov loadin, dl
    shl edx, 10
    mov ebx, instaddr
    add ebx, edx                ; EBX=pointer to current instrads struc

    lea edi, [ebx].name
    mov ecx, 11
    rep movsw                   ; Copy the instrument name
    inc esi                     ; + 1 (inst type, always 0)

;---------------------
;    pushad
;    @print mi1
;    lea esi, [ebx].name
;    mov ecx, 11
;    mov edi, offset mxn
;    rep movsw
;    @print mxn
;    popad
;---------------------



    xor eax, eax
    mov ax, [esi]               ; AX = number of samples in instr
    add esi, 2
;---------------------
;    @printmh mi2, eax
;---------------------
    lea edi, [ebx].sampnum
    mov [edi], al
    test ax, ax                 ; If 0 then proccess next instr
    jz @nextinstr
;    jz @nothing
    mov loadsn, al


    mov eax, [esi]              ; sample header size
    add esi, 4

    lea edi, [ebx].keymap       ; Key map (96 bytes)
    mov ecx, 24
    rep movsd

    push eax ebp edx



;///////////////////////////////////////////////////////
; ENVELOPES: precalculate increments and 'tick periods'
;///////////////////////////////////////////////////////



; Volume Envelope
;/////////////////

;-----------------------------
;    @print mi4
;-----------------------------

    push esi
    xor ecx, ecx                ; ECX = current point
    xor edx, edx                ; DX = previous volume
    xor ebp, ebp                ; EBP = previous position

    mov eax, 1
    add esi, 2                  ; read first volume
    lea edi, [ebx].volepos[ecx*2]
    mov [edi], ax
;-----------------------------
;    @printmh mi6, eax
;-----------------------------

    mov dx, [esi]
    add esi, 2
    shl edx, 16
    lea edi, [ebx].volerate[ecx*4]
    mov [edi], edx              ; Delta volume per pos.
;-----------------------------
;    @printmh mi7, edx
;-----------------------------

    mov ecx, 1


conv_volenv:                    ; Process vol envelope - precalculate increment
    xor eax, eax
    mov ax, [esi]               ; Read position
    cmp eax, ebp
    jng conv_volend

    add esi, 2
    push eax                    ; Save old value on stack
    sub eax, ebp                ; Delta position -> eax
    lea edi, [ebx].volepos[ecx*2]
    mov [edi], ax
;-----------------------------
;    @printmh mi6, eax
;-----------------------------
    mov ebp, eax

    xor eax, eax
    mov ax, [esi]               ; EAX = vol
    add esi, 2
    shl eax, 16                 ;
    push eax
    push ebx
    sub eax, edx                ; EAX -> delta volume
    mov ebx, ebp                ; divisor
    cdq
    idiv ebx                    ; EAX = vol increment!
    pop ebx
    lea edi, [ebx].volerate[ecx*4]
    mov [edi], eax              ; Volume increment per pos.
;-----------------------------
;    @printmh mi7, eax
;-----------------------------

    pop edx                     ; Previous volume
    pop ebp                     ; Previous position
    inc cl
    cmp cl, 11
    jne conv_volenv

conv_volend:
    pop esi
    add esi, 48



; Panning Envelope
;//////////////////

;-----------------------------
;    @print mi5
;-----------------------------


    push esi
    xor ecx, ecx                ; ECX = current point
    xor edx, edx                ; DX = previous panning
    xor ebp, ebp                ; EBP = previous position

    mov eax, 1
    add esi, 2                  ; read first panning
    lea edi, [ebx].panepos[ecx*2]
    mov [edi], ax
;-----------------------------
;    @printmh mi6, eax
;-----------------------------

    mov dx, [esi]
    add esi, 2
    shl edx, 16
    lea edi, [ebx].panerate[ecx*4]
    mov [edi], edx              ; Delta panning per pos.
;-----------------------------
;    @printmh mi7, edx
;-----------------------------

    mov ecx, 1


conv_panenv:                    ; Process pan envelope - precalculate increment
    xor eax, eax
    mov ax, [esi]               ; Read position
    cmp eax, ebp
    jng conv_panend

    add esi, 2
    push eax                    ; Save old value on stack
    sub eax, ebp                ; Delta position -> eax
    lea edi, [ebx].panepos[ecx*2]
    mov [edi], ax
;-----------------------------
;    @printmh mi6, eax
;-----------------------------
    mov ebp, eax

    xor eax, eax
    mov ax, [esi]               ; EAX = pan
    add esi, 2
    shl eax, 16                 ; dividendo
    push eax
    push ebx
    sub eax, edx                ; EAX -> delta panning
    mov ebx, ebp                ; divisor
    cdq
    idiv ebx                    ; EAX = pan increment!
    pop ebx
    lea edi, [ebx].panerate[ecx*4]
    mov [edi], eax              ; Delta panning per pos.
;-----------------------------
;    @printmh mi7, eax
;-----------------------------

    pop edx                     ; Previous panning
    pop ebp                     ; Previous position
    inc cl
    cmp cl, 11
    jne conv_panenv

conv_panend:
    pop esi
    add esi, 48

;///////////////////////////////////////////////////////







    pop edx ebp eax

    lea edi, [ebx].numvolp
    mov ecx, 4
    rep movsd                   ; copy rest of variables

    add esi, 2                  ; reserved

    xor edx, edx                ; DX = sample counter
;    mov s_num, 0

    mov esi, ebp

;---------------------
;    @print mi3
;---------------------


@sample:

    push esi


    lea edi, [ebx].samp[edx].ssize
    mov ecx, [esi]
    mov [edi], ecx              ; Size of sampledata
    add esi, 4
;---------------------
;    @printmh mi9, ecx
;---------------------

    lea edi, [ebx].samp[edx].sloops
    mov ecx, [esi]
    mov [edi], ecx              ; Loop start
    add esi, 4

    lea edi, [ebx].samp[edx].sloopl
    mov ecx, [esi]
    mov [edi], ecx              ; Loop lenght
    add esi, 4

    lea edi, [ebx].samp[edx].svolume
    mov cl, [esi]
    mov [edi], cl               ; Default volume
    inc esi

    lea edi, [ebx].samp[edx].sftune
    mov cl, [esi]
    mov [edi], cl               ; Finetune
    inc esi

    lea edi, [ebx].samp[edx].stype
    mov cl, [esi]
    mov [edi], cl               ; Type (loop type, 8 or 16 bit)
;   mov s_type, cl
    inc esi

    lea edi, [ebx].samp[edx].spanning
    mov cl, [esi]
    mov [edi], cl
    inc esi                     ; Panning position

    lea edi, [ebx].samp[edx].srelnote
    mov cl, [esi]
    mov [edi], cl
    inc esi                     ; Relative note

    inc esi                     ; Reserved



    lea edi, [ebx].samp[edx].sname
    mov ecx, 11
    rep movsw                   ; Name

;---------------------
;     pushad
;     @print mi8
;     lea esi, [ebx].samp[edx].sname
;     mov ecx, 11
;     mov edi, offset mxn
;     rep movsw
;     @print mxn
;     popad
;---------------------


    pop esi                     ; ESI = Pointer to samp header init
    add esi, eax                ; EAX = sample header size

    mov ebp, esi



    movzx ecx, loadsn
    imul ecx, size sample
    add edx, size sample
    cmp edx, ecx                ; comp # of samples with current sample
    jb  @sample                 ; if not ready goto next sample
                                ; if true load the samples into the GUS
    xor edx, edx

@loadsample:

    lea edi, [ebx].samp[edx].ssize
    mov ecx, [edi]
    test ecx, ecx
    jz @noload
    mov s_size, ecx

    mov s_start, esi

    lea edi, [ebx].samp[edx].sloops
    mov ecx, [edi]
    mov s_loops, ecx

    lea edi, [ebx].samp[edx].sloopl
    mov ecx, [edi]
    mov s_loopl, ecx

    mov cl, acsn
    lea edi, [ebx].samp[edx].snum
    mov [edi], cl
    inc cl
    mov acsn, cl

                               ; Convert sampledata

    lea edi, [ebx].samp[edx].stype
    mov cl, [edi]
    test cl, 10000b
    jnz short conv16

    mov ecx, s_size
    call _convertdelta8
    jmp short convend


conv16:

    mov ecx, s_size
    call _convertdelta16

convend:
;---------------------
;    @printh ecx
;---------------------

    lea edi, [ebx].samp[edx].stype
    mov cl, [edi]
    mov s_type, cl

    mov cl, al
    call sc_load

    test al, al                 ; Test if not enogh mem.
    jnz @nowtmem

    mov al, cl

    mov cl, s_num
    inc cl
    mov s_num, cl

    mov ecx, s_size
    add esi, ecx


@noload:

    mov ebp, esi

    movzx ecx, loadsn
    imul ecx, size sample
    add edx, size sample
    cmp edx, ecx                ; comp # of samples with current sample
    jb  @loadsample             ; if not ready load next sample




@nextinstr:
    xor edx, edx
    mov dl, loadin
    inc dl                      ; Actual instrument counter
;    mov loadin, dl
    cmp dl, MAXINST             ; Ignore instruments if more
    je @sefini                  ; than maximum
    jmp @instr

;@nothing:
;    mov ebp, esi
;    jmp short @nextinstr


@sefini:

    mov errorcod, 0

    mov al, xmp_status
    or al, 00000010b
    mov xmp_status, al



@endload:


	popad
    mov al, errorcod
    ret




; errors
@noxm:
    mov errorcod, EC_FILETYPE
    jmp @endload

@nomem:
    mov errorcod, EC_MEM
    jmp @endload

@toomany:
    mov errorcod, EC_CHANN
    jmp @endload

@nowtmem:
    mov errorcod, EC_WTRAM
    jmp @endload

@uerror:
    mov errorcod, EC_UNKN
    jmp @endload















;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ _XMP_Play                                              ±
;±  FUNCTION:      ³ Start/continue playing                                 ±
;±  ASSUME:        ³ - All speed varibles must be set                       ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

_XMP_Play:

    pushad

    mov errorcod, 0

    mov bl, xmp_status          ; Test if initialized/xm loaded
    test bl, 00000001b
    jz @playerr

    test bl, 00000010b
    jz @playerr


    mov ax, sngbpm
    mov bx, sngspeed
    mov s_bpm, ax
    mov acbpm, ax
    mov s_speed, bx
    mov acspeed, bx

    xor eax, eax
    xor edx, edx
    mov acgvol, 40h
    mov acpat, al
    mov acpos, al
    mov dl, pattbl[eax]
    mov eax, patadd[edx*4]
    mov acadd, eax


    call sc_play

    mov al, xmp_status
    or al, 00000100b
    mov xmp_status, al

;   xor cx, cx
    mov timecount, 1

endplay:

    popad
    mov al, errorcod
    ret

@playerr:
    mov errorcod, EC_UNKN
    jmp endplay




;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ _XMP_End                                               ±
;±  FUNCTION:      ³ Restore old hardware status/IRQ handlers               ±
;±                 ³ Call this to disable the XM Player                     ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


_XMP_End:

    pushad

    mov xmp_status, 0

    call sc_end

    xor eax, eax                ; Zero all variables
    mov snglen, al
    mov sngrestart, al
    mov sngchann, al
    mov sngpatt, al
    mov sngins, al
    mov sngftable, al
    mov sngspeed, ax
    mov sngbpm, ax
    mov edi, offset sngname
    mov ecx, 21
    rep movsb
    mov edi, offset pattbl
    mov ecx, 64
    rep movsd

    popad
    xor al, al
    ret

; Routines not yet developed

_XMP_Stop:
_XMP_Prog:
    mov al, EC_UNKN
    ret






; AUXILIAR ROUTINES:

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ _convertdelta-8                                        ±
;±  FUNCTION:      ³ Converts 8bit sampledata from delta to normal values   ±
;±  ASSUME:        ³ - ESI: sample address                                  ±
;±                 ³ - ECX: sample lenght                                   ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

_convertdelta8:

    pushad

    xor bl, bl

@cd8loop:
    test ecx, ecx
    jz cd8end
    mov al, [esi]
    add al, bl
    mov [esi], al
    mov bl, al
    inc esi
    dec ecx
    jmp @cd8loop


cd8end:
    popad
    ret


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ _convertdelta-16                                       ±
;±  FUNCTION:      ³ Converts 16bit sampledata from delta to normal values  ±
;±  ASSUME:        ³ - ESI: sample address                                  ±
;±                 ³ - ECX: sample lenght (bytes)                           ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

_convertdelta16:
    pushad


;    and cl, 11111110b

    xor bx, bx

@cd16loop:
    test ecx, ecx
    jz cd16end
    mov ax, [esi]
    add ax, bx
    mov [esi], ax
    mov bx, ax
    add esi, 2
    sub ecx, 2
    jmp @cd16loop


cd16end:
    popad
    ret




;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ _getlinfreq                                            ±
;±  FUNCTION:      ³ Gets the linear frequence of a note                    ±
;±  ASSUME:        ³ - AL is the note                                       ±
;±                 ³ - AH is the finetune                                   ±
;±  OUTS:          ³ - s_freq variable set                                  ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
; Implemented by Khroma ;)

 _getlinfreq:

;	push ebx ecx edx esi
    pushad

;  Period = 10*12*16*4 - Note*16*4 - FineTune/2;
	movsx ebx, ah		; BX is the finetune
	mov   edx, 7680
	xor   ah, ah
	shl   ax, 4+2
	cwde
	sub   edx, eax
	sar   ebx, 1
	sub   edx, ebx		; DX is the period

;  Frequency = 8363*2^((6*12*16*4 - Period) / (12*16*4));
	mov   eax, 7680
	sub   eax, edx
	cdq
	mov   ebx, 768
 	idiv  ebx
	xor   ebx, ebx
	mov   ebx, edx
	mov   esi, eax
	xor   eax, eax
	mov   ax, lintab[ebx*2]
	shl   eax, 2
	mov   ecx, 7
	sub   ecx, esi
	shr   eax, cl

	mov   s_freq, eax
    popad
;	pop esi edx ecx ebx
	ret

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ _getlinfreq2                                           ±
;±  FUNCTION:      ³ Gets the linear frequence of a PERIOD                  ±
;±  ASSUME:        ³ - AX is the period                                     ±
;±  OUTS:          ³ - s_freq variable set                                  ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
; Implemented by Khroma ;)

 _getlinfreq2:

    pushad

;  Frequency = 8363*2^((6*12*16*4 - Period) / (12*16*4));

    movzx edx, ax
	mov   eax, 7680
	sub   eax, edx
	cdq
	mov   ebx, 768
 	idiv  ebx
	xor   ebx, ebx
	mov   ebx, edx
	mov   esi, eax
	xor   eax, eax
	mov   ax, lintab[ebx*2]
	shl   eax, 2
	mov   ecx, 7
	sub   ecx, esi
	shr   eax, cl

	mov   s_freq, eax
    popad
	ret




;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ _XMP_Main                                              ±
;±  FUNCTION:      ³ Partiture processing                                   ±
;±                 ³ Must be called by the timer procedure                  ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

_XMP_Main:

    pushad

    mov cx, timecount               ; Tick counter
    mov dx, acspeed
    dec dx

    cmp cx, dx
    jne effect                      ; Time to proccess effects and envelopes

    mov timecount, 0



; Temporal pattern proccessing, effects not implemented yet

    mov al, acpos
;---------------------------
;      @print mp2
;---------------------------
    inc al                          ; Next row
    mov acpos, al                   ; Save current row

    mov patchg, 0

    xor ecx, ecx                    ; ECX: channel counter
    mov esi, acadd                  ; ESI: patterndata actual base



read:
@loop_read:

    mov al, acfx[ecx]
    test al, al
    jz begin
    cmp al, 0FFh
    je short undo_arp
    jmp begin

undo_arp:                           ; Undo arpegio effects
    xor eax, eax
    mov ax, acfxv2[ecx*2]
    mov acper[ecx*2], ax
    jmp begin


begin:

    xor edx, edx                    ; Init some vars & regs
    mov s_offset, 0



    mov dl, [esi]
    inc esi
;    cmp dl, 10000000b               ; If nothing to do, try next
;    je fx_read_end
    test dl, 10000000b              ; Compression?
    jnz note_read

    mov dl, 0FFh                    ; If not, set all columns
    dec esi
                                    ; DH maskable byte:
                                    ;   0 - start new note
                                    ;   1 - new pat volume
                                    ;   2 - new pat panning
                                    ;   3 - new period
                                    ;   4 - end of note
                                    ;   5 - new finetune
                                    ;   6 - new env. pos
                                    ;   7 - new per. detune




note_read:                          ; Note column

    test dl, 1b
    jz short instr_read

    mov al, [esi]                   ; note
    inc esi
    test al, al                     ; Nothing?
    jz instr_read                   ; Do nothing!
    cmp al, 61h                     ; end of note?
    je short note_read_eon

    mov acnote[ecx], al
    or dh, 1
    jmp short instr_read

note_read_eon:
    or dh, 10000b






instr_read:                         ; Instrument column
;    mov acnins[ecx], 0
    test dl, 10b
    jz short vol_read
    mov al, [esi]                   ; instrument #
    inc esi
    test al, al
    jz short vol_read

    dec al
    mov acnins[ecx], al
    or dh, 10b






vol_read:                           ; Volume column
    test dl, 100b
    jz vol_read_end

;    xor eax, eax
    mov ah, [esi]
    inc esi                         ; (not implemented)
    cmp ah, 10h
    jb fx1_read
    cmp ah, 50h
    jbe short vol_read_vol
    cmp ah, 60h                     ; Invalid value
    jb fx1_read
    cmp ah, 70h
    jb short vol_read_voldn
    cmp ah, 80h
    jb short vol_read_volup
    cmp ah, 90h
    jb short vol_read_fvsdn
    cmp ah, 0A0h
    jb short vol_read_fvsup
    cmp ah, 0B0h
    jb short vol_read_vibsp
    cmp ah, 0C0h
    jb short vol_read_vib
    cmp ah, 0D0h
    jb short vol_read_pan

    jmp vol_read_end



vol_read_vol:                       ; Set volume
    sub ah, 10h
    mov acfv[ecx], 0FFh
    mov acfvv1[ecx], ah
    jmp short fx1_read

vol_read_voldn:                     ; Volume slide up
    sub ah, 60h
    mov acfv[ecx], 1
    mov acfvv1[ecx], ah
    jmp short fx1_read

vol_read_volup:                     ; Volume slide down
    sub ah, 70h
    mov acfv[ecx], 2
    mov acfvv1[ecx], ah
    jmp short fx1_read

vol_read_fvsdn:                     ; Fine volume slide up
    sub ah, 80h
    mov acfv[ecx], 3
    mov acfvv1[ecx], ah
    jmp short fx1_read

vol_read_fvsup:                     ; Fine volume slide down
    sub ah, 90h
    mov acfv[ecx], 4
    mov acfvv1[ecx], ah
    jmp short fx1_read

vol_read_vibsp:                     ; Set vibrato speed
    jmp vol_read_end

vol_read_vib:                       ; Vibrato
    jmp vol_read_end

vol_read_pan:                       ; Set panning position
    sub ah, 0C0h
    mov acfv[ecx], 8
    mov acfvv1[ecx], ah
    jmp short fx1_read

vol_read_end:
    mov acfv[ecx], 0
    mov acfvv1[ecx], 0
    mov acfvv2[ecx*2], 0
    jmp short fx1_read





fx1_read:                           ; Effect type column
    xor eax, eax

    test dl, 1000b
    jz short fx2_read

    mov ah, [esi]
    inc esi                         ; Store fx number on AH


fx2_read:                           ; Effect value column
    test dl, 10000b
    jz fx2_read1
    mov al, [esi]
    inc esi                         ; (not implemented)
fx2_read1:
;    test dl, 1000b
;    jz read_end
                                    ; Determine effect:
    test ah, ah
    jz fx_read_arpeg
    cmp ah, 01h
    je fx_read_portaup
    cmp ah, 02h
    je fx_read_portadn
    cmp ah, 03h
    je fx_read_toneport
    cmp ah, 08h
    je fx_read_pan
    cmp ah, 09h
    je fx_read_offset
    cmp ah, 0Ah
    je fx_read_volslid
    cmp ah, 0Bh
;    je fx_read_posjmp
    cmp ah, 0Ch
    je fx_read_vol
    cmp ah, 0Dh
    je fx_read_pbreak
    cmp ah, 0Eh
    je short fx_read_ext
    cmp ah, 0Fh
    je fx_read_speed
    cmp ah, 10h
    je fx_read_gvol
    cmp ah, 11h
    je fx_read_gvslide
    cmp ah, 14h
;    je fx_read_keyoff
    cmp ah, 15h
    je fx_read_setenv
    cmp ah, 19h
    je fx_read_panslid
    cmp ah, 1Ah
    je fx_read_setflag

    mov acfx[ecx], 0
    mov acfxv1[ecx], 0
    mov acfxv2[ecx*2], 0
    jmp read_end

fx_read_ext:
    mov bl, al
    shr bl, 4
    cmp bl, 5
    je fx_read_ftune
    cmp bl, 9
    je fx_read_retrig
    cmp bl, 0Ah
    je fx_read_fvsup
    cmp bl, 0Bh
    je fx_read_fvsdn
    cmp bl, 0Ch
    je fx_read_cut
    cmp bl, 0Dh
    je fx_read_delay
    jmp fx_read_end


fx_read_arpeg:                      ;*Effect 0: arpeggio
    test al, al
    jz fx_read_end
    mov acfx[ecx], 0FFh
    mov acfxv1[ecx], al
    mov acfxv2[ecx*2], 0
    jmp read_end

fx_read_portaup:                    ;*Effect 1: portamento up
    mov acfx[ecx], 1
    mov acfxv1[ecx], al
    mov acfxv2[ecx*2], 0
    jmp read_end

fx_read_portadn:                    ;*Effect 2: portamento down
    mov acfx[ecx], 2
    mov acfxv1[ecx], al
    mov acfxv2[ecx*2], 0
    jmp read_end

fx_read_toneport:                   ;*Effect 3: tone portamento
    mov acfx[ecx], 3
    xor ah, ah
    mov acfxv1[ecx], ah
    mov acfxv2[ecx*2], ax
    and dh, 0FEh
    jmp read_end

fx_read_pan:                        ;*Effect 8: set panning position
    mov acfx[ecx], 8
    mov acfxv1[ecx], al
    mov acfxv2[ecx*2], 0
    jmp read_end

fx_read_offset:                     ;*Effect 9: sample offset
    xor ebx, ebx
    mov bl, al
    shl ebx, 8
    mov s_offset, ebx
    jmp fx_read_end

fx_read_volslid:                    ;*Effect A: volume slide
    mov acfx[ecx], 0Ah
    mov acfxv1[ecx], al
    mov acfxv2[ecx*2], 0
    jmp read_end

fx_read_posjmp:                     ;*Effect B: position jump
;    movzx ebx, al
;    mov acpos, 0
;    mov acpat, al
;    mov eax, patadd[ebx]
;    mov acadd, eax
    jmp fx_read_end

fx_read_vol:                        ;*Effect C: set volume
    mov acfx[ecx], 0Ch
    mov acfxv1[ecx], al
    mov acfxv2[ecx*2], 0
    jmp read_end

fx_read_pbreak:                     ;*Effect D: pattern break
    mov acpos, 0
;    mov acpos, al                  ; (param. not implemented yet)
    movzx ebx, acpat
    inc bl                          ; next pattern
    cmp bl, snglen                  ; end of song?
    jne fx_read_pbreak_nes
    xor bx, bx
    mov bl, sngrestart              ; restart pattern
fx_read_pbreak_nes:                 ; not end of song
    movzx edx, pattbl[ebx]
    mov esi, patadd[edx*4]
    mov acpat, bl                   ; save current pattern
    mov acadd, esi                  ; save current mem position
    mov patchg, 1
    jmp fx_read_end


fx_read_ftune:                      ;*Effect E5: set finetune
    and al, 0Fh
    mov acftune[ecx], al
    or dh, 100000b
    jmp fx_read_end

fx_read_retrig:                     ;*Effect E9: retrig note
    and al, 0Fh
    jz fx_read_end
    mov acfx[ecx], 0E9h
    mov acfxv1[ecx], al
    mov acfxv2[ecx*2], 0
    jmp read_end

fx_read_fvsup:                      ;*Effect EA: fine volume slide up
    mov acfx[ecx], 0EAh
    mov acfxv1[ecx], al
    mov acfxv2[ecx*2], 0
    jmp read_end

fx_read_fvsdn:                      ;*Effect EB: fine volume slide down
    mov acfx[ecx], 0EBh
    mov acfxv1[ecx], al
    mov acfxv2[ecx*2], 0
    jmp read_end

fx_read_cut:                        ;*Effect EC: note cut
    and al, 0Fh
    mov acfx[ecx], 0ECh
    mov acfxv1[ecx], al
    mov acfxv2[ecx*2], 0
    jmp read_end

fx_read_delay:                      ;*Effect ED: note delay
    and al, 0Fh
    mov acfx[ecx], 0EDh
    mov acfxv1[ecx], al
    mov acfxv2[ecx*2], 0
    jmp read_end

fx_read_speed:                      ;*Effect F: set speed/BPMs
    xor ah, ah
    cmp al, 32
    jb fx_read_sspeed
    mov acbpm, ax
    mov s_bpm, ax
    jmp read_end
fx_read_sspeed:
    mov acspeed, ax
    mov s_speed, ax
    jmp fx_read_end

fx_read_gvol:                       ;*Effect G: set global volume
    cmp al, 40h
    jna short fx_read_gvol1
    mov al, 40h
fx_read_gvol1:
    mov acgvol, al
    jmp fx_read_end

fx_read_gvslide:                    ;*Effect H: global volume slide
    mov acfx[ecx], 11h
    mov acfxv1[ecx], al
    mov acfxv2[ecx*2], 0
    jmp read_end

fx_read_keyoff:                     ;*Effect K: keyoff
    mov acfx[ecx], 14h
    mov acfxv1[ecx], al             ; tick count
    mov acfxv2[ecx*2], 0
    jmp read_end

fx_read_setenv:                     ;*Effect L: set envelope point
;    or dh, 1000000b
    jmp fx_read_end

fx_read_panslid:                    ;*Effect P: panning slide
    mov acfx[ecx], 19h
    mov acfxv1[ecx], al
    mov acfxv2[ecx*2], 0
    jmp short read_end

fx_read_setflag:                    ;*Effect Q: set player flag (XMP only!)
    mov xmp_flag, al                ; with the mu6.
    jmp short fx_read_end


fx_read_end:
    xor ax, ax
    mov acfx[ecx], al
    mov acfxv1[ecx], al
    mov acfxv2[ecx*2], ax
    jmp short read_end


;align 4
read_end:

    call process




    mov ah, acfv[ecx]               ; some volme column effects...
    test ah, ah
    jz fx1
    cmp ah, 0FFh
    je vol1_vol
    cmp ah, 3
    je vol1_fvsdn
    cmp ah, 4
    je vol1_fvsup
    cmp ah, 8
    je vol1_pan
    jmp fx1



vol1_vol:                           ; Set volume
;    @print mp
    mov ah, acfvv1[ecx]
    mov acpvol[ecx], ah             ; Pattern sample volume
;    or dh, 10b
    jmp vol1_end


vol1_fvsdn:                         ; Fine volume slide up
    mov ah, acfvv1[ecx]
    mov al, acpvol[ecx]
    cmp ah, al                      ; (should not be negative)
    jbe short vol1_fvsdn1
    xor ax, ax
vol1_fvsdn1:
    sub al, ah
    mov acpvol[ecx], al
;    or dh, 10b
    jmp vol1_end

vol1_fvsup:                         ; Fine volume slide down
    mov ah, acfvv1[ecx]
    mov al, acpvol[ecx]
    add al, ah
    cmp al, 40h                     ; (should not be > 40h)
    jbe short vol1_fvsup1
    mov al, 40h
vol1_fvsup1:
    mov acpvol[ecx], al
;    or dh, 10b
    jmp vol1_end


vol1_pan:                           ; Set panning position
    mov ah, acfvv1[ecx]
    shl ah, 4
    mov acppan[ecx], ah
    jmp vol1_end

vol1_end:
    mov acfv[ecx], 0
    mov acfvv1[ecx], 0
    mov acfvv2[ecx*2], 0





fx1:

    mov al, acfx[ecx]               ; Process some effects
    test al, al
    jz  fx1_end
    cmp al, 3
    je fx1_toneport
    cmp al, 8
    je fx1_pan
    cmp al, 0Ch
    je fx1_vol
    cmp al, 0EAh
    je fx1_fvsdn
    cmp al, 0EBh
    je fx1_fvsup


fx1_toneport:
    mov al, acflag[ecx]
    test al, al
    jz fx1_end
    mov al, acnote[ecx]             ; prepare new 'target'
    add al, acrnote[ecx]
    dec al
    mov ah, acftune[ecx]
    push ebx edx
;Period = 10*12*16*4 - Note*16*4 - FineTune/2;
	movsx ebx, ah		            ; BX is the finetune
	mov edx, 7680
    and eax, 0FFh                   ; crop low 8 bits
	shl ax, 6                       ; *64
	sub edx, eax
 	sar ebx, 1
	sub edx, ebx		            ; DX is the period
    mov acporta[ecx*2], dx          ; Period for tone portamento
    pop edx ebx
    jmp fx1_end

fx1_fvsup:                          ;*Effect EA: fine volume slide up
    mov al, acfxv1[ecx]
    and al, 0Fh
    mov ah, acpvol[ecx]
    add al, ah
    cmp al, 40h                     ; (should not be > 40h)
    jng short fx1_fvsup1
    mov al, 40h
fx1_fvsup1:
    mov acpvol[ecx], al
;    or dh, 10b
    jmp fx1_clear

fx1_fvsdn:                          ;*Effect EB: fine volume slide down
    mov al, acfxv1[ecx]
    and al, 0Fh
    mov ah, acpvol[ecx]
    cmp al, ah                      ; (result should not be negative)
    jb short fx1_fvsdn1
    xor ax, ax
fx1_fvsdn1:
    sub ah, al
    mov acpvol[ecx], ah
;    or dh, 10b
    jmp fx1_clear

fx1_pan:                            ;*Effect 8: set panning position
    mov al, acfxv1[ecx]
    mov acppan[ecx], al
;    or dh, 100b
    jmp fx1_clear

fx1_vol:                            ;*Effect C: set volume
    mov al, acfxv1[ecx]
    mov acpvol[ecx], al
;    or dh, 10b
    jmp fx1_clear

fx1_clear:
    xor ax, ax
    mov acfx[ecx], al
    mov acfxv1[ecx], al
    mov acfxv2[ecx*2], ax

fx1_end:




    call process2




nxt1:
    inc cl
    cmp cl, sngchann                ; More channels to proccess?
    jne @loop_read

    mov bl, patchg
    test bl, bl
    jnz endmain

    mov al, acpos
    movzx ecx, acpat
    movzx edx, pattbl[ecx]
    mov bl, patlen[edx]             ; Should not be 0...
    cmp al, bl                      ; More rows in current pattern?
    jb finito
    inc cl                          ; Next pattern
    cmp cl, snglen                  ; End of song?
    jne nes
    xor ecx, ecx
    mov cl, sngrestart              ; Restart pattern
nes:                                ; Not end of song
    movzx edx, pattbl[ecx]
    mov esi, patadd[edx*4]
    mov acpat, cl                   ; Save current pattern
    mov acpos, 0                    ; Row=0
finito:                             ;-)
    mov acadd, esi                  ; Save current mem position
    jmp endmain
















effect:                             ; No pattern read, process effects

    inc cx
    mov timecount, cx
;---------------------
;    @print mp
;---------------------

    xor ecx, ecx
@loop_fx:
    xor edx, edx                    ; Init some vars & regs

                                    ; Volume column
    mov al, acfv[ecx]
    test al, al                     ; No effect -> do nothing
    jz fxcol
    cmp al, 1
    je vol_voldn
    cmp al, 2
    je vol_volup
    jmp fxcol


vol_voldn:
    mov ah, acfvv1[ecx]
    mov al, acpvol[ecx]
    cmp ah, al                      ; (should not be negative)
    jbe short vol_voldn1
    xor ax, ax
vol_voldn1:
    sub al, ah
    mov acpvol[ecx], al
;    or dh, 10b
    jmp fxcol

vol_volup:
    mov ah, acfvv1[ecx]
    mov al, acpvol[ecx]
    add al, ah                      ; (should not be negative)
    cmp al, 40h
    jg short vol_volup1
    mov acpvol[ecx], al
;    or dh, 10b
    jmp fxcol
vol_volup1:
    mov acpvol[ecx], 40h
;    or dh, 10b
    jmp fxcol




fxcol:
                                    ; Effect column
    mov al, acfx[ecx]
    test al, al                     ; No effect -> do nothing
    jz fx_end
    cmp al, 0FFh
    je fx_arp
    cmp al, 001h
    je fx_portaup
    cmp al, 002h
    je fx_portadn
    cmp al, 003h
    je fx_toneport
    cmp al, 00Ah
    je fx_volslid
    cmp al, 0E9h
;    je fx_retrig
    cmp al, 0ECh
;    je fx_notecut
    cmp al, 0EDh
;    je fx_delay
    cmp al, 011h
    je fx_gvslid
    cmp al, 014h
;    je fx_keyoff
    cmp al, 019h
;    je fx_panslid
    jmp fx_end


fx_arp:                             ; ARPEGGIO
    xor eax, eax
    mov ax, timecount
    mov dl, 3
    div dl
    test ah, ah                     ; AH=rest
    jz fx_arp_0
    cmp ah, 2
    je fx_arp_2
    mov ax, acper[ecx*2]
    mov acfxv2[ecx*2], ax
    xor bh, bh
    mov bl, acfxv1[ecx]
    and bl, 0F0h
    shl bx, 2
    sub ax, bx
    mov acper[ecx*2], ax
    jmp fx_end
fx_arp_2:
    mov ax, acfxv2[ecx*2]
    mov acper[ecx*2], ax
    xor bh, bh
    mov bl, acfxv1[ecx]
    and bl, 0Fh
    shl bx, 6
    sub ax, bx
    mov acper[ecx*2], ax
    jmp fx_end
fx_arp_0:
    mov ax, acfxv2[ecx*2]
    mov acper[ecx*2], ax
    jmp fx_end


fx_portaup:                         ; PORTAMENTO UP
    movzx ax, acfxv1[ecx]
    mov bx, acper[ecx*2]
    shl ax, 2
    sub bx, ax
    mov acper[ecx*2], bx
    jmp fx_end


fx_portadn:                         ; PORTAMENTO DOWN
    movzx ax, acfxv1[ecx]
    mov bx, acper[ecx*2]
    shl ax, 2
    add bx, ax
    mov acper[ecx*2], bx
    jmp fx_end


fx_toneport:
    mov bx, acporta[ecx*2]
    test bx, bx
    jz fx_end
    mov ax, acper[ecx*2]
    cmp ax, bx
    jb fx_toneport_up
    sub ax, acfxv2[ecx*2]
    sub ax, acfxv2[ecx*2]
    sub ax, acfxv2[ecx*2]
    sub ax, acfxv2[ecx*2]
    cmp ax, bx
    ja short fx_toneport_dn1
    mov ax, bx
fx_toneport_dn1:
    mov acper[ecx*2], ax
    jmp fx_end
fx_toneport_up:
    add ax, acfxv2[ecx*2]
    add ax, acfxv2[ecx*2]
    add ax, acfxv2[ecx*2]
    add ax, acfxv2[ecx*2]
    cmp ax, bx
    jna short fx_toneport_up1
    mov ax, bx
fx_toneport_up1:
    mov acper[ecx*2], ax
    jmp fx_end


fx_volslid:                         ; VOLUME SLIDE
    mov al, acfxv1[ecx]
    test al, 0F0h
    jz short fx_volslid_dn
    shr al, 4
    mov ah, acpvol[ecx]
    add ah, al
    cmp ah, 40h                     ; (should not be > 40h)
    jg short fx_volslid_up1
    mov acpvol[ecx], ah
    jmp fx_end
fx_volslid_up1:
    mov acpvol[ecx], 40h
    jmp fx_end
fx_volslid_dn:
    mov ah, acpvol[ecx]
    cmp al, ah                      ; (result should not be negative)
    jbe short fx_volslid_dn1
    xor ax, ax
fx_volslid_dn1:
    sub ah, al
    mov acpvol[ecx], ah
    jmp fx_end

fx_retrig:
    mov al, acfxv1[ecx]
    dec al
    mov acfxv1[ecx], al
    test al, al
    jnz fx_retrig_no
    mov ax, acfxv2[ecx*2]
    mov acfxv1[ecx], al
    or dh, 1
fx_retrig_no:
    jmp fx_end


fx_gvslid:                          ; GENERAL VOLUME SLIDE
    mov al, acfxv1[ecx]
    test al, 0F0h
    jz short fx_gvslid_dn
    shr al, 4
    mov ah, acgvol
    add ah, al
    cmp ah, 40h                     ; (should not be > 40h)
    jg short fx_gvslid_up1
    mov acgvol, ah
    jmp fx_end
fx_gvslid_up1:
    mov acgvol, 40h
    jmp fx_end
fx_gvslid_dn:
    mov ah, acgvol
    cmp al, ah                      ; (result should not be negative)
    jbe short fx_gvslid_dn1
    xor ax, ax
fx_gvslid_dn1:
    sub ah, al
    mov acgvol, ah
    jmp fx_end







fx_end:

    call process
    call process2


nxt_fx:
    inc cl
    cmp cl, sngchann                ; More channels to proccess?
    jne @loop_fx


    jmp endmain




















; INPUT VALUES:     DH flag byte, ECX channel number, ac* var set.
; OUTPUT:           Nope.
_nnote:
process:
;    pushad

;instr:                             ; INSTRUMENT NUMBER
    xor ebx, ebx
    xor eax, eax
    mov bl, acnins[ecx]
    test dh, 1
    jz short nonwnot
    cmp bl, acins[ecx]
    je short nonwnot
    mov acins[ecx], bl
    or dh, 10b

nonwnot:
    cmp bl, sngins
;    ja short instr_invalid
    shl ebx, 10
    add ebx, instaddr               ; EBX = Instr. base address pointer
    lea edi, [ebx].sampnum
    mov al, [edi]
    test al, al
    jnz short note

instr_invalid:
    mov acflag[ecx], al             ; if no samples then channel->inactive
    test dh, 1
    jz proc_end                     ; if not new note, go next channel
    mov al, cl                      ; if new note stop channel b4
;    call sc_pse
    jmp proc_end


note:                               ; NEW NOTE
    test dh, 1
    jz endofnote

    push edx
    xor eax, eax
    xor edx, edx
    mov al, acnote[ecx]
    dec al
    lea edi, [ebx].keymap[eax]
    mov dl, [edi]
    mov acsam[ecx], dl              ; * Sample number (instr)
    lea edi, [ebx].sampnum
    mov al, [edi]
    dec al
    cmp dl, al
    ja note_dischann
    imul edx, size sample           ; EDX = sample pointer
    mov ebp, edx
;---------------------------
;    xor ebp, ebp                   ; OJO: detr s de cada .samp va [ebp]
;---------------------------
    pop edx

    test dh, 100000b
    jnz note_newft
    lea edi, [ebx].samp[ebp].sftune
    mov ah, [edi]
    mov acftune[ecx], ah            ; Finetune
note_newft:
    lea edi, [ebx].samp[ebp].srelnote
    mov al, [edi]                   ; Relative note
    mov acrnote[ecx], al            ;
    add al, acnote[ecx]             ; Pattern note
    dec al

    push ebx edx
;Period = 10*12*16*4 - Note*16*4 - FineTune/2;
	movsx ebx, ah		            ; BX is the finetune
	mov edx, 7680
    and eax, 0FFh                   ; crop low 8 bits
;	xor ah, ah
	shl ax, 6                       ; *64
;	cwde
	sub edx, eax
 	sar ebx, 1
;	shr ebx, 1
	sub edx, ebx		            ; DX is the period
    mov acper[ecx*2], dx            ; Period
    pop edx ebx

    lea edi, [ebx].samp[ebp].snum
    mov al, [edi]                   ; * Sample number (soundcard)
    mov s_num, al

    test dh, 10b
    jz short note_nni

    xor eax, eax
    lea edi, [ebx].voltype          ; * Sample flag
    mov al, [edi]
    lea edi, [ebx].pantype
    mov ah, [edi]
    and al, 1
    shl al, 3                       ; vol env
    and ah, 1
    shl ah, 4                       ; panning env.
    or al, 1                        ; active
    or al, ah
    mov acflag[ecx], al


    mov acfvol[ecx*2], 0FFFFh       ; * Fadeout volume/rate
    lea edi, [ebx].volfade
    mov ax, [edi]
    mov acfrate[ecx*2], ax

    lea edi, [ebx].samp[ebp].svolume
    mov al, [edi]                   ; * Default sample/pattern volume
    mov acpvol[ecx], al

    lea edi, [ebx].samp[ebp].spanning
    mov al, [edi]                   ; * Default sample/pattern panning
    mov acppan[ecx], al



note_nni:
    mov acevpnt[ecx], 0             ; * Envelopes positions -> 0
    mov aceppnt[ecx], 0
    mov acevpos[ecx*2], 1
    mov aceppos[ecx*2], 1
    mov acevol[ecx*4], 0
    mov acepan[ecx*4], 0
    jmp short endofnote

note_dischann:
    pop edx
    mov acflag[ecx], 0              ; if AL=0 then channel->inactive
    mov al, cl
;    call sc_pse                     ; end sample




endofnote:
    test dh, 10000b
    jz short nnote_end
    mov al, acflag[ecx]
    test al, 1000b
    jnz short endofnote_env
    test al, al
    jz short nnote_end
    mov acflag[ecx], 0
    mov al, cl
;    call sc_pse
    jmp short nnote_end

endofnote_env:
    and al, 11111001b               ; clear sustains
    or al, 10000000b                ; set end of note
    mov acflag[ecx], al

nnote_end:
;    popad
    ret













; INPUT VALUES:     DH flag byte, ECX channel number, ac* var set.
; OUTPUT:           Nope.

_envs_prc:
process2:
;    pushad


;volume:                             ; VOLUME PROCESSING
;------------------------------
;    jmp volume_simple
;------------------------------
    xor eax, eax
    mov ebp, ebx                    ; EBP -> instr. header pointer
    mov al, acflag[ecx]
    test al, al                     ; Inactive?
    jz proc_end

    test al, 1000b                  ; No envelope?
    jz volume_simple
    test al, 10b                    ; Sustain volume?
    jnz volume_process
    test al, 100000b                ; End of envelope?
    jnz volume_fade

    xor eax, eax
    mov al, acevpnt[ecx]
    lea edi, [ebp].volerate[eax*4]
    mov ebx, [edi]
    mov eax, acevol[ecx*4]
    add eax, ebx                    ; Add stored delta value
    mov acevol[ecx*4], eax


    xor eax, eax
    mov ax, acevpos[ecx*2]          ; Tick-position counter (0=new point)
    dec ax
    mov acevpos[ecx*2], ax
    test ax, ax                     ; New point?
    jnz volume_fade                  ; no -> process fadeout

volume_newp:
    xor eax, eax
    mov al, acevpnt[ecx]
    inc al
    mov acevpnt[ecx], al
    lea edi, [ebp].volepos[eax*2]   ; 'Prepare' new point
    mov bx, [edi]
    mov acevpos[ecx*2], bx

    lea edi, [ebp].volloops
    mov ah, [edi]
    cmp al, ah
    je short volume_loops
volume_cont:
    lea edi, [ebp].numvolp
    mov ah, [edi]
    cmp ah, al
    je volume_endp
    lea edi, [ebp].volloope
    mov ah, [edi]
    inc ah
    cmp ah, al
    je volume_loope
    lea edi, [ebp].volsust
    mov ah, [edi]
    inc ah
    cmp ah, al
    jne volume_fade

volume_sust:                        ; Sustain
    lea edi, [ebp].voltype
    mov ah, [edi]
    test ah, 10b                    ; sustain env set?
    jz volume_fade
    mov bl, acflag[ecx]
    test bl, 10000000b              ; end of note?
    jnz volume_fade                 ; yes -> pass
    or bl, 10b                      ; no -> set sustain
    mov acflag[ecx], bl
    jmp volume_fade                 ; not eon! correct as below

volume_loops:                       ; Loop start point
    mov ebx, acevol[ecx*4]
    mov acvloop[ecx*4], ebx
    jmp volume_cont


volume_loope:
    lea edi, [ebp].voltype
    mov ah, [edi]
    test ah, 100b                   ; loop env set?
    jz volume_fade
    lea edi, [ebp].volloops
    mov al, [edi]
    mov acevpnt[ecx], al
    xor ah, ah
    lea edi, [ebp].volepos[eax*2]   ; 'Prepare' new point
    mov ax, [edi]
    mov acevpos[ecx*2], ax
    mov eax, acvloop[ecx*4]
    mov acevol[ecx*4], eax
    jmp short volume_fade

volume_endp:
    mov bl, acflag[ecx]
    or bl, 100000b                  ; set end of vol env
    mov acflag[ecx], bl
;    jmp short volume_fade


volume_fade:                        ; Fadeout
    mov al, acflag[ecx]
    test al, 10000000b              ; End of note reached?
    jz short volume_process         ; no -> no fadeout
    mov ax, acfvol[ecx*2]
    mov bx, acfrate[ecx*2]
    cmp ax, bx
    ja short volume_fade1           ; Zero reached?
    mov acfvol[ecx*2], 0
    mov acevol[ecx*4], 0
    mov acpvol[ecx], 0
;    mov s_vol, 0
    mov acflag[ecx], 0              ; yes -> set as inactive
;    mov cl, al
;    call sc_pse
;    jmp panning
    jmp short volume_process
volume_fade1:
    sub ax, bx
    mov acfvol[ecx*2], ax

volume_process:                     ; Calculate final volume
    push edx
    xor edx, edx
    xor eax, eax
    xor ebx, ebx
    mov al, acpvol[ecx]             ; pattern vol (6 bits)
    mov bl, acgvol                  ; global vol (6 bits)
    imul eax, ebx                   ; EAX -> 12 bits (+1)
    mov ebx, acevol[ecx*4]          ; envelope vol (32 bits fixed, 64.0 max)
    shr ebx, 16                     ; envelope vol -> 6 bits
    imul eax, ebx                   ; EAX -> 18 bits (+1)
    movzx ebx, acfvol[ecx*2]        ; fadeout vol (16 bits)
    shr ebx, 3                      ; fadeout -> 13 bits
    imul eax, ebx                   ; EAX -> 31 bits (+1)

    test eax, eax
    jz volume_process1
    dec eax                         ; "por si las moscas" :-)
    shr eax, 15                     ; EAX -> 16 bits
volume_process1:
    mov s_vol, ax                   ; Voila!
;-------------------------------
;    @printmh mkk, eax
;-------------------------------
    pop edx
    jmp short panning


volume_simple:
    xor eax, eax
    xor ebx, ebx
    mov al, acpvol[ecx]             ; EAX -> 6 bits (+1)
    mov bl, acgvol
    imul eax, ebx                   ; EAX -> 12 bits (+1)
    shl eax, 4                      ; EAX -> 16 bits (+1)
    test eax, eax
    jz volume_simple1
    dec eax                         ; "por si las moscas" :-)
volume_simple1:
    mov s_vol, ax
    jmp short panning









panning:                            ; PANNING PROCESSING
    mov al, acflag[ecx]
    test al, 10000b                 ; No envelope?
    jz panning_simple
    test al, 100b                   ; Sustain panning?
    jnz panning_process
    test al, 1000000b               ; End of envelope?
    jnz panning_process

    xor eax, eax
    mov al, aceppnt[ecx]
    lea edi, [ebp].panerate[eax*4]
    mov ebx, [edi]
    mov eax, acepan[ecx*4]
    add eax, ebx                    ; Add stored delta value
    mov acepan[ecx*4], eax


    xor eax, eax
    mov ax, aceppos[ecx*2]          ; Tick-position counter (0=new point)
    dec ax
    mov aceppos[ecx*2], ax
    test ax, ax                     ; New point?
    jnz panning_fade                  ; no -> process fadeout

panning_newp:
    xor eax, eax
    mov al, aceppnt[ecx]
    inc al
    mov aceppnt[ecx], al
    xor ebx, ebx
    lea edi, [ebp].panepos[eax*2]   ; 'Prepare' new point
    mov bx, [edi]
    mov aceppos[ecx*2], bx

    lea edi, [ebp].panloops
    mov ah, [edi]
    cmp al, ah
;    je short panning_loops
panning_cont:
    lea edi, [ebp].numpanp
    mov ah, [edi]
    cmp ah, al
    je panning_endp
    lea edi, [ebp].panloope
    mov ah, [edi]
    inc ah
    cmp ah, al
;    je panning_loope

    lea edi, [ebp].pansust
    mov ah, [edi]
    inc ah
    cmp ah, al
    jne panning_fade

panning_sust:                        ; Sustain
    lea edi, [ebp].pantype
    mov ah, [edi]
    test ah, 10b                    ; sustain env set?
    jz panning_fade
    mov bl, acflag[ecx]
    test bl, 10000000b              ; end of note?
    jnz panning_fade                ; yes -> pass
    or bl, 100b                     ; no -> set sustain
    mov acflag[ecx], bl
    jmp panning_fade                ; not eon! correct as below

panning_loops:                      ; Loop start point
    mov ebx, acepan[ecx*4]
    mov acploop[ecx*4], ebx
    jmp panning_cont


panning_loope:
    lea edi, [ebp].pantype
    mov ah, [edi]
    test ah, 100b                   ; loop env set?
    jz panning_fade
    lea edi, [ebp].panloops
    mov al, [edi]
    mov aceppnt[ecx], al
    xor ah, ah
    lea edi, [ebp].panepos[eax*2]   ; 'Prepare' new point
    mov ax, [edi]
    mov aceppos[ecx*2], ax
    mov eax, acploop[ecx*4]
    mov acepan[ecx*4], eax
    jmp short panning_fade

panning_endp:
    mov bl, acflag[ecx]
    or bl, 1000000b                 ; set end of pan env
    mov acflag[ecx], bl
;    jmp short panning_fade


panning_fade:
panning_process:                    ; Calculate final panning
; FinalPan = pan + (EnvelopePan - 32)*(128 - abs(pan-128))/32
    push edx
    xor edx, edx
    xor eax, eax
    xor ebx, ebx
    mov ebx, acepan[ecx*4]
    shr ebx, 16
    cmp ebx, 040h
    jna kk1
    mov ebx, 040h
kk1:
    sub ebx, 32                     ; -20h...

    movzx eax, acppan[ecx]
    sub eax, 128
    jns nosigned                    ; abs...
    neg eax
nosigned:
    mov edx, 128
    sub edx, eax
    mov eax, edx
    imul eax, ebx
    sar eax, 5                      ; /32...
    movzx ebx, acppan[ecx]
    add eax, ebx
    shl eax, 8
;    @printmh mkk, eax
    mov s_pan, ax
    pop edx
    jmp short frequency


panning_simple:
    xor al, al
    mov ah, acppan[ecx]
    mov s_pan, ax



frequency:                          ; Should also process vibrato...
    mov ax, acper[ecx*2]
    call _getlinfreq2



final:

    test dh, 1
    jz short final_nnn

    mov al, cl
    call sc_pss
    jmp short proc_end

final_nnn:
    mov al, cl
    call sc_csv
    call sc_csp
    call sc_csf

proc_end:
;    popad
    ret








endmain:
    popad
    ret

L5      db      'INTERWAVE',0
L6      db      'ULTRASND',0
L7      db      'BLASTER',0
LA      db      'ein?',0
LB      db      'ULTRA16',0

_XMP_Detect:    pushad
                xor     esi,esi
                mov     ebx,dword ptr _pspa ;+ 0C87AH
                sub     ebx,dword ptr _code32a ;+ 7B01H
                add     ebx,0000002cH
                mov     si,word ptr [ebx]
                shl     esi,04H
                sub     esi,dword ptr _code32a ;+7BC8H
                xor     cl,cl
                xor     eax,eax
                mov     ebx,esi
                mov     edi,offset L5
                call    near ptr L447
                jb      short L428
                mov     cl,01H
L428:           mov     edi,offset L6
                call    near ptr L447
                jb      short L429
                add     cl,10H
                mov     byte ptr xmp_devtype,cl
;               mov     byte ptr xmp_devtype,11h
                call    near ptr L438
                mov     word ptr xmp_devport,ax
                jb      short L429
                call    near ptr L438
                mov     byte ptr xmp_devdma1,al
                jb      short L429
                call    near ptr L438
                jb      short L429
                call    near ptr L438
                mov     byte ptr xmp_devirq1,al
                test    al,al
                jb      short L429
                call    near ptr gus_detect
                jmp     near ptr L436
L429:           ;jmp     near ptr L437
                mov     edi,offset L7
                call    near ptr L447
                jb      near ptr L437
                mov     byte ptr xmp_devtype,80H
L430:           mov     al,byte ptr [ebx]
                inc     ebx
                test    al,al
                je      short L435
                and     al,0dfH
                cmp     al,41H
                jne     short L431
                call    near ptr L438
                mov     word ptr xmp_devport,ax
                jae     short L430
                jmp     short L435
L431:           cmp     al,49H
                jne     short L432
                call    near ptr L438
                mov     byte ptr xmp_devirq1,al
                jae     short L430
                jmp     short L435
L432:           cmp     al,44H
                jne     short L433
                call    near ptr L438
                mov     byte ptr xmp_devdma1,al
                jae     short L430
                jmp     short L435
L433:           cmp     al,54H
                jne     short L430
                call    near ptr L438
                pushf
                cmp     al,03H
                jb      short L434
                mov     byte ptr xmp_devtype,81H
                cmp     al,05H
                jb      short L434
                mov     byte ptr xmp_devtype,82H
                cmp     al,07H
                jb      short L434
                mov     byte ptr xmp_devtype,20H
L434:           popf
                jae     short L430
L435:           xor     ax,ax
                cmp     word ptr xmp_devport,ax
                je      short L437
                cmp     byte ptr xmp_devirq1,al
                je      short L437
                cmp     byte ptr xmp_devdma1,al
                je      short L437
L436:           popad
                ret
L437:           xor     eax,eax         ; no se ha encontrado nada (?)
                mov     byte ptr xmp_devtype,al
                mov     word ptr xmp_devport,ax
                mov     byte ptr xmp_devdma1,al
                mov     byte ptr xmp_devdma2,al
                mov     byte ptr xmp_devirq1,al
                mov     byte ptr xmp_devirq2,al
                mov     dword ptr xmp_devmem,eax
                popad
                ret

L438:           push    ecx             ; Funcion (?)
                push    edi
                xor     eax,eax
                xor     ecx,ecx
                xor     edi,edi
L439:           mov     al,byte ptr [ebx]
                inc     ebx
                cmp     al,20H
                je      short L439
                jmp     short L441
L440:           mov     al,byte ptr [ebx]
                inc     ebx
                inc     edi
L441:           test    al,al
                je      short L443
                cmp     al,20H
                je      short L445
                cmp     al,2cH
                je      short L445
                and     al,0dfH
                cmp     al,40H
                jb      short L442
                add     al,09H
L442:           and     al,0fH
                shl     ecx,04H
                add     ecx,eax
                jmp     short L440
L443:           cmp     edi,00000002H
                jne     short L444
                mov     ax,cx
                shr     al,04H
                and     ecx,0000000fH
                push    cx
                mov     cl,0aH
                mul     cl
                pop     cx
                add     cx,ax
L444:           mov     eax,ecx
                pop     edi
                pop     ecx
                stc
                ret
L445:           cmp     edi,00000002H
                jne     short L446
                mov     ax,cx
                shr     al,04H
                and     ecx,0000000fH
                push    cx
                mov     cl,0aH
                mul     cl
                pop     cx
                add     cx,ax
L446:           mov     eax,ecx
                pop     edi
                pop     ecx
                clc
                ret
L447:           push    esi             ; deteccion
                push    ax
L448:           mov     ebx,edi
L449:           mov     al,byte ptr [esi]
                inc     esi
                test    al,al
                je      short L452
                cmp     al,byte ptr [ebx]
                jne     short L450
                inc     ebx
                jmp     short L449
L450:           cmp     al,3dH
                jne     short L451
                mov     al,byte ptr [ebx]
                test    al,al
                je      short L453
                inc     ebx
                jmp     short L449
L451:           mov     al,byte ptr [esi]
                inc     esi
                test    al,al
                jne     short L451
                jmp     short L448
L452:           stc
                jmp     short L454
L453:           mov     ebx,esi
                clc
L454:           pop     ax
                pop     esi
                ret

L455:           add     byte ptr [ecx],al
                add     al,byte ptr [ebx]

;L456:           add     byte ptr [eax],al
;                add     byte ptr [eax],al

align 4
fire_chnn	dd	0


_XMP_Fire:      mov     word ptr s_pan, ax
                mov     dword ptr s_freq, 00001964H
                mov     byte ptr s_num, 05H
                mov     dword ptr s_offset, 0
                mov     word ptr s_vol, 0FFFFh
                mov     ebx, fire_chnn
                mov     eax, ebx
 		push    ebx
                call    sc_pss
		pop     ebx
                inc     ebx
                cmp     ebx, 3
                jbe     short L457
                xor     ebx, ebx
L457:           mov     fire_chnn, ebx

                ret

;L458:           ret

L459            DB      31H,9aH         ;,66H,53H,66H,51H
aleat:          push    bx              ; =
                push    cx              ; =
                push    dx
                mov     cl,al
                mov     ax,word ptr L459
                add     ax,ax
                jae     short L461
                xor     ax,2293H
L461:           rol     ax,02H
                mov     word ptr L459,ax
                mov     bx,ax
                shr     bx,cl
                mov     ax,0ffffH
                inc     cl
                shr     ax,cl
                sub     ax,bx
                movsx   eax,ax
                pop     dx
                pop     cx
                pop     bx
                ret




;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±  PROCEDURE:     ³ _sc_*                                                  ±
;±  FUNCTION:      ³ Dummy lowlevel procedures                              ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
nul:
    ret





;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
code32  ends
	end

;----------------------------------------------------------------------------
;       LEGAL
;----------------------------------------------------------------------------
; XMP and Xtended Module Player are trademarks of Exobit inc.
;
; XMP module may be used and distributed freely under the follow conditions:
;
;   1 - It may not be modified. If you wanna use a modified version of the
;       program you should get written permission of the autor. You're not
;       allowed to distribute a modified version of the module.
;   2 - You will not gain any money by distributing it.
;   3 - It will not be used for commercial purposes. This version of XMP
;       can be olnly used on public domain software.

;


;----------------------------------------------------------------------------
;       THANX STUFF
;----------------------------------------------------------------------------
;
;   Many thanx Tran!! I always use the PMode extender, & I've also
;   adapted some code from Timeless.

;   Special thanx to Triton for the FT2. XM rulez!


;   Thanx to Advanced Gravis/Forte Technologies for
;   support coders work.


;   This routines were built not from the scratcht but from a tiny
;   soundblaster raw-sample player from Khroma. I think the .386p
;   header is all that remain intact, but always thanx.


;   My best vomit is dedicated to Creativeless (aka dma xfer noise)
;                       & also to Micro$oft (aka general protection fault)
;
;  ... Windows 95 doesn't multitask, it multisucks.
;   Let's radikal ;-)
