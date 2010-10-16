;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
; Definici줻 de los paths de HYPNOTIC
; 1995 Khroma & Mentat Manual Working ;))
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
CROT = 32

; MAXIMO VALOR DE ROTACION 1500!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


align 4
burseq1 db    0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0
        db    1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1
        db    0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0
        db    1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1
        db    0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0
        db    1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1
	db    0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0

smlseq  db    0,0,0,0,1,1,1,1,1,0,0,0

;-----------------------------------------------------------------------------

hyppat  dd    600*UNO,   0*UNO,    0*UNO, 255*UNO*CROT,   1*UNO*CROT,   0*UNO*CROT
        dd    480*UNO,   0*UNO,    0*UNO, 192*UNO*CROT,   1*UNO*CROT,   0*UNO*CROT
        dd    350*UNO,   0*UNO,    0*UNO, 128*UNO*CROT,   1*UNO*CROT,   0*UNO*CROT
        dd    200*UNO,   0*UNO,    0*UNO,  44*UNO*CROT,   1*UNO*CROT,   0*UNO*CROT
        dd    -30*UNO,   0*UNO,   20*UNO,  16*UNO*CROT,  12*UNO*CROT,   0*UNO*CROT
        dd    -15*UNO,   0*UNO,   40*UNO,  16*UNO*CROT,  38*UNO*CROT,   1*UNO*CROT
        dd      0*UNO,  40*UNO,   60*UNO,  16*UNO*CROT,  64*UNO*CROT,   3*UNO*CROT
        dd      0*UNO,   0*UNO,   80*UNO,  -5*UNO*CROT,  90*UNO*CROT,   5*UNO*CROT
        dd      0*UNO,   0*UNO,  -50*UNO, -15*UNO*CROT, 256*UNO*CROT,   8*UNO*CROT
        dd      0*UNO,   0*UNO, -150*UNO,  -8*UNO*CROT,  20*UNO*CROT,   5*UNO*CROT
        dd      0*UNO,   0*UNO, -250*UNO,  -4*UNO*CROT,   0*UNO*CROT,   0*UNO*CROT
        dd      0*UNO,   0*UNO, -200*UNO,   0*UNO*CROT,   0*UNO*CROT,   0*UNO*CROT
        dd      0*UNO,   0*UNO,  -50*UNO,   0*UNO*CROT,   0*UNO*CROT,   0*UNO*CROT
hyppat2	dd      0*UNO,   0*UNO,  -10*UNO,   0*UNO*CROT,   0*UNO*CROT,   0*UNO*CROT
	dd      0*UNO,   0*UNO,    0*UNO,   0*UNO*CROT,   0*UNO*CROT,   0*UNO*CROT
hyppat3	dd     -5*UNO,  -5*UNO,  200*UNO,   0*UNO*CROT,   0*UNO*CROT,   0*UNO*CROT
	dd     -6*UNO,  -6*UNO,  590*UNO,   0*UNO*CROT,   0*UNO*CROT,   5*UNO*CROT
	dd     -50*UNO,-50*UNO,  670*UNO,   0*UNO*CROT,   0*UNO*CROT,  20*UNO*CROT
	dd     -60*UNO,-65*UNO,  670*UNO,   0*UNO*CROT,   0*UNO*CROT, 100*UNO*CROT
	dd     -70*UNO,-65*UNO,  750*UNO,   0*UNO*CROT,   0*UNO*CROT, 400*UNO*CROT
hyppat4 dd     -80*UNO,-75*UNO,  800*UNO,   0*UNO*CROT,   0*UNO*CROT, 700*UNO*CROT
	dd    -160*UNO,-80*UNO, 1000*UNO,   0*UNO*CROT,   0*UNO*CROT,1200*UNO*CROT
	dd    -260*UNO,-135*UNO, 2500*UNO,   0*UNO*CROT,   0*UNO*CROT,1800*UNO*CROT

hyppat5	dd       0*UNO,  0*UNO,  -45*UNO,   0*UNO*CROT,  -2*UNO*CROT,   0*UNO*CROT
	dd       0*UNO,  0*UNO,  -45*UNO,   0*UNO*CROT,   2*UNO*CROT,   0*UNO*CROT

hyppat6	dd           0,      0,        0,        0,            0,            0
	dd       65535,      0,        0,        0,            0,            0

;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
; Escena n즡ero 1
; Target : PLANETOIDE

cam1    dd  000*UNO, 0160*UNO,-0800*UNO, 0, 0, 0
        dd  240*UNO, 0160*UNO,-0771*UNO, 0, 0, 0
        dd  472*UNO, 0160*UNO,-0651*UNO, 0, 0, 0
        dd  646*UNO, 0160*UNO,-0464*UNO, 0, 0, 0
        dd  753*UNO, 0160*UNO,-0232*UNO, 0, 0, 0
;4

flare1  dd  800*UNO,  0000*UNO,-2800*UNO, 0, 0, 0
        dd  753*UNO,  0232*UNO,-2800*UNO, 0, 0, 0
        dd  646*UNO,  0464*UNO,-2800*UNO, 0, 0, 0
        dd  472*UNO,  0651*UNO,-2800*UNO, 0, 0, 0
        dd  240*UNO,  0771*UNO,-2800*UNO, 0, 0, 0
        dd  000*UNO,  0800*UNO,-2800*UNO, 0, 0, 0
        dd -240*UNO,  0771*UNO,-2800*UNO, 0, 0, 0
        dd -472*UNO,  0651*UNO,-2800*UNO, 0, 0, 0
        dd -646*UNO,  0464*UNO,-2800*UNO, 0, 0, 0
        dd -753*UNO,  0232*UNO,-2800*UNO, 0, 0, 0
        dd -800*UNO,  0000*UNO,-2800*UNO, 0, 0, 0
        dd -753*UNO, -0232*UNO,-2800*UNO, 0, 0, 0
        dd -646*UNO, -0464*UNO,-2800*UNO, 0, 0, 0
        dd -472*UNO, -0651*UNO,-2800*UNO, 0, 0, 0
        dd -240*UNO, -0771*UNO,-2800*UNO, 0, 0, 0
        dd  000*UNO, -0800*UNO,-2800*UNO, 0, 0, 0
        dd  240*UNO, -0771*UNO,-2800*UNO, 0, 0, 0
        dd  472*UNO, -0651*UNO,-2800*UNO, 0, 0, 0
        dd  646*UNO, -0464*UNO,-2800*UNO, 0, 0, 0
        dd  753*UNO, -0232*UNO,-2800*UNO, 0, 0, 0
;19


planet1	dd  0350*UNO, 0100*UNO,-0350*UNO, 000*UNO*CROT,    0*UNO*CROT, 000*UNO*CROT
	dd  0350*UNO, 0100*UNO,-0350*UNO, 000*UNO*CROT,  768*UNO*CROT, 000*UNO*CROT
;1

objet1	dd -0200*UNO, 0000*UNO, 0800*UNO, 000*UNO*CROT, 000*UNO*CROT, 000*UNO*CROT
	dd -0350*UNO, 0000*UNO, 0200*UNO, 000*UNO*CROT, 000*UNO*CROT, 000*UNO*CROT

;1

; Escena n즡ero 2
; Target : PLANETOIDE

cam2    dd (-800*2+200)*UNO,  0000*UNO, (0000*2+200)*UNO, 0, 0, 0
        dd (-753*2+200)*UNO,  0025*UNO,(-0232*2+200)*UNO, 0, 0, 0
        dd (-646*2+200)*UNO,  0050*UNO,(-0464*2+200)*UNO, 0, 0, 0
        dd (-472*2+200)*UNO,  0075*UNO,(-0651*2+200)*UNO, 0, 0, 0
        dd (-240*2+200)*UNO,  0100*UNO,(-0771*2+200)*UNO, 0, 0, 0
        dd    (0*2+200)*UNO,  0125*UNO,(-0800*2+200)*UNO, 0, 0, 0
        dd   (80*2+200)*UNO,  0150*UNO,(-0700*2+200)*UNO, 0, 0, 0
        dd   (60*2+200)*UNO,  0175*UNO,(-0500*2+200)*UNO, 0, 0, 0

;7

flare2  dd  (240-200)*UNO, -0150*UNO,-0771*UNO, 0, 0, 0
        dd  (472-200)*UNO, -0100*UNO,-0651*UNO, 0, 0, 0
        dd  (646-200)*UNO, -0050*UNO,-0464*UNO, 0, 0, 0
        dd  (753-200)*UNO,  0000*UNO,-0232*UNO, 0, 0, 0
        dd  (800-200)*UNO,  0050*UNO, 0000*UNO, 0, 0, 0
        dd  (753-200)*UNO,  0100*UNO, 0232*UNO, 0, 0, 0
        dd  (646-200)*UNO,  0150*UNO, 0464*UNO, 0, 0, 0
        dd  (472-200)*UNO,  0200*UNO, 0651*UNO, 0, 0, 0
        dd  (240-200)*UNO,  0250*UNO, 0771*UNO, 0, 0, 0
        dd  (000-200)*UNO,  0300*UNO, 0800*UNO, 0, 0, 0
        dd (-240-200)*UNO,  0350*UNO, 0771*UNO, 0, 0, 0
        dd (-472-200)*UNO,  0400*UNO, 0651*UNO, 0, 0, 0
        dd (-646-200)*UNO,  0350*UNO, 0464*UNO, 0, 0, 0
        dd (-753-200)*UNO,  0300*UNO, 0232*UNO, 0, 0, 0
        dd (-800-200)*UNO,  0250*UNO, 0000*UNO, 0, 0, 0
        dd (-753-200)*UNO,  0200*UNO,-0232*UNO, 0, 0, 0
        dd (-646-200)*UNO,  0150*UNO,-0464*UNO, 0, 0, 0
        dd (-472-200)*UNO,  0050*UNO,-0651*UNO, 0, 0, 0
        dd (-240-200)*UNO,  0000*UNO,-0771*UNO, 0, 0, 0
        dd  (000-200)*UNO, -0050*UNO,-0800*UNO, 0, 0, 0
        dd  (240-200)*UNO, -0100*UNO,-0771*UNO, 0, 0, 0
        dd  (472-200)*UNO, -0150*UNO,-0651*UNO, 0, 0, 0
        dd  (646-200)*UNO, -0200*UNO,-0464*UNO, 0, 0, 0
        dd  (753-200)*UNO, -0150*UNO,-0232*UNO, 0, 0, 0
        dd  (800-200)*UNO, -0200*UNO, 0000*UNO, 0, 0, 0
        dd  (753-200)*UNO, -0250*UNO, 0232*UNO, 0, 0, 0
        dd  (646-200)*UNO, -0300*UNO, 0464*UNO, 0, 0, 0
        dd  (472-200)*UNO, -0250*UNO, 0651*UNO, 0, 0, 0
        dd  (240-200)*UNO, -0200*UNO, 0771*UNO, 0, 0, 0
        dd  (000-200)*UNO, -0120*UNO, 0800*UNO, 0, 0, 0
        dd (-240-200)*UNO, -0010*UNO, 0771*UNO, 0, 0, 0
        dd (-472-200)*UNO,  0130*UNO, 0651*UNO, 0, 0, 0
        dd (-646-200)*UNO,  0200*UNO, 0464*UNO, 0, 0, 0
        dd (-753-200)*UNO,  0350*UNO, 0232*UNO, 0, 0, 0
        dd (-800-200)*UNO,  0480*UNO, 0000*UNO, 0, 0, 0
        dd (-850-200)*UNO,  0550*UNO,-0232*UNO, 0, 0, 0
        dd (-950-200)*UNO,  0600*UNO,-0464*UNO, 0, 0, 0
        dd (-1000-200)*UNO, 0600*UNO,-0651*UNO, 0, 0, 0
        dd (-1025-200)*UNO, 0600*UNO,-0771*UNO, 0, 0, 0
        dd (-1050-200)*UNO, 0600*UNO,-0800*UNO, 0, 0, 0
        dd (-1075-200)*UNO, 0600*UNO,-0771*UNO, 0, 0, 0
        dd (-1100-200)*UNO, 0600*UNO,-0651*UNO, 0, 0, 0

;41


planet2 dd  0000*UNO, 0000*UNO,-0550*UNO, 000*UNO*CROT, 000*UNO*CROT, 000*UNO*CROT
	dd  0000*UNO, 0000*UNO,-0550*UNO, 000*UNO*CROT,1500*UNO*CROT, 000*UNO*CROT
;1

objet2	dd  0600*UNO, 0000*UNO, 0200*UNO, 000*UNO*CROT, 000*UNO*CROT, 000*UNO*CROT
	dd -0100*UNO, 0000*UNO,-0200*UNO, 000*UNO*CROT, 000*UNO*CROT, 000*UNO*CROT
	dd -0400*UNO, 0000*UNO,-0400*UNO, 000*UNO*CROT, 000*UNO*CROT, 000*UNO*CROT
;2


; Escena n즡ero 3
; Target : PLANETOIDE

cam4    dd 0000*UNO,  0000*UNO,-0600*UNO, 0, 0, 0
        dd 0000*UNO,  0000*UNO,-0400*UNO, 0, 0, 0
        dd 0000*UNO,  0000*UNO,-0300*UNO, 0, 0, 0
;2

flare4  dd  000*UNO,  0500*UNO, 0200*UNO, 0, 0, 0
        dd -000*UNO, -0500*UNO, 0120*UNO, 0, 0, 0
;1

planet4	dd  0000*UNO, 0000*UNO, 0000*UNO, 000*UNO*CROT, 000*UNO*CROT, 000*UNO*CROT
	dd  0000*UNO, 0000*UNO, 0000*UNO, 000*UNO*CROT,1024*UNO*CROT, 000*UNO*CROT

;1
objet4	dd  0000*UNO, 0000*UNO, 0000*UNO, 000*UNO*CROT, 000*UNO*CROT, 000*UNO*CROT
	dd  0000*UNO, 0000*UNO, 0000*UNO, 000*UNO*CROT, 000*UNO*CROT, 000*UNO*CROT
        dd  0000*UNO, 0000*UNO, 0000*UNO, 000*UNO*CROT, 000*UNO*CROT, 000*UNO*CROT
        dd  0005*UNO, 0000*UNO, 0000*UNO, 000*UNO*CROT, 000*UNO*CROT, 000*UNO*CROT
	dd  0010*UNO, 0000*UNO, 0000*UNO, 000*UNO*CROT, 000*UNO*CROT, 000*UNO*CROT
        dd  0025*UNO, 0000*UNO, 0000*UNO, 000*UNO*CROT, 000*UNO*CROT, 000*UNO*CROT
	dd  0050*UNO, 0000*UNO, 0000*UNO, 000*UNO*CROT, 000*UNO*CROT, 000*UNO*CROT
        dd  0100*UNO, 0000*UNO, 0000*UNO, 000*UNO*CROT, 000*UNO*CROT, 000*UNO*CROT
	dd  0200*UNO, 0000*UNO, 0000*UNO, 000*UNO*CROT, 000*UNO*CROT, 000*UNO*CROT
	dd  0350*UNO, 0000*UNO, 0000*UNO, 000*UNO*CROT, 000*UNO*CROT, 000*UNO*CROT
	dd  0500*UNO, 0000*UNO, 0000*UNO, 000*UNO*CROT, 000*UNO*CROT, 000*UNO*CROT
;9

;-----------------------------------------------------------------------------

Ppeace  dd -1000*UNO,  190*UNO, -6900*UNO,   0*UNO*CROT,   0*UNO,   (0+128)*UNO*CROT
        dd  1000*UNO,  190*UNO, -6900*UNO,   0*UNO*CROT,   0*UNO,(-256+128)*UNO*CROT

;-----------------------------------------------------------------------------
Pmale	dd  -2300*UNO,  400*UNO, -5000*UNO,  30*UNO*CROT, 256*UNO*CROT,   5*UNO*CROT
        dd   210*UNO,  -200*UNO, -5500*UNO,   0*UNO*CROT,   0*UNO*CROT,   0*UNO*CROT
        dd   215*UNO,  -380*UNO, -5800*UNO,  60*UNO*CROT,  30*UNO*CROT,  20*UNO*CROT
        dd   230*UNO,  -410*UNO, -6000*UNO, 120*UNO*CROT, 160*UNO*CROT,  40*UNO*CROT

	dd   255*UNO,  -620*UNO, -6000*UNO,  40*UNO*CROT, 130*UNO*CROT,  20*UNO*CROT
	dd   260*UNO,  -740*UNO, -6000*UNO,  90*UNO*CROT, 150*UNO*CROT,  40*UNO*CROT
        dd   260*UNO,  -910*UNO, -6000*UNO, 120*UNO*CROT, 200*UNO*CROT,  56*UNO*CROT
        dd   260*UNO, -1410*UNO, -6000*UNO, 140*UNO*CROT,-255*UNO*CROT,  26*UNO*CROT

;-----------------------------------------------------------------------------
Pfemale	dd  2000*UNO,   400*UNO, -6400*UNO, 256*UNO*CROT,  30*UNO*CROT,  10*UNO*CROT
        dd   500*UNO,  -340*UNO, -6300*UNO,   0*UNO*CROT,   0*UNO*CROT,   0*UNO*CROT
        dd   280*UNO,  -365*UNO, -6200*UNO,  60*UNO*CROT,  30*UNO*CROT,  20*UNO*CROT
        dd   240*UNO,  -370*UNO, -6050*UNO, 120*UNO*CROT, 160*UNO*CROT,  40*UNO*CROT

        dd   230*UNO,  -610*UNO, -6000*UNO,  30*UNO*CROT, 130*UNO*CROT,  20*UNO*CROT
        dd   230*UNO,  -760*UNO, -6000*UNO,  90*UNO*CROT, 150*UNO*CROT,  40*UNO*CROT
        dd   230*UNO,  -865*UNO, -6000*UNO, 130*UNO*CROT, 200*UNO*CROT,  56*UNO*CROT
        dd   230*UNO, -1310*UNO, -6000*UNO, 150*UNO*CROT,-255*UNO*CROT,  26*UNO*CROT

;-----------------------------------------------------------------------------
Pmorsmile dd   0*UNO, -800*UNO, -7000*UNO,  05*UNO*CROT, 200*UNO*CROT, -20*UNO*CROT
          dd   0*UNO,  800*UNO, -7000*UNO,  10*UNO*CROT, 760*UNO*CROT,-128*UNO*CROT

;-----------------------------------------------------------------------------
Pdevsmile dd  100*UNO, 1300*UNO, -6000*UNO,   0*UNO*CROT,   0*UNO*CROT, 100*UNO*CROT
          dd  100*UNO,-1300*UNO, -6000*UNO, 100*UNO*CROT,   0*UNO*CROT,  60*UNO*CROT
          dd 1500*UNO, 1300*UNO, -6000*UNO, 260*UNO*CROT,  30*UNO*CROT, -80*UNO*CROT

;-----------------------------------------------------------------------------
Pdo       dd -4000*UNO, 450*UNO, -5000*UNO,   0*UNO,     0*UNO,     0*UNO
          dd   450*UNO, 450*UNO, -5000*UNO,   0*UNO,     0*UNO,     0*UNO
          dd   450*UNO, 450*UNO, -5000*UNO,   0*UNO,     0*UNO,     0*UNO
          dd  4000*UNO, 450*UNO, -5000*UNO,   0*UNO,     0*UNO,     0*UNO

;-----------------------------------------------------------------------------
Pname     dd -600*UNO, 2300*UNO, -6500*UNO,   0*UNO,   0*UNO*CROT,  0*UNO*CROT
          dd -600*UNO,    0*UNO, -6500*UNO,   0*UNO, 738*UNO*CROT,  0*UNO*CROT
          dd -600*UNO,    0*UNO, -6500*UNO,   0*UNO, 738*2*UNO*CROT, 0*UNO*CROT
          dd -600*UNO,-2300*UNO, -6500*UNO,   0*UNO, 600*3*UNO*CROT, 0*UNO*CROT

;-----------------------------------------------------------------------------
Pname2	  dd -450*UNO, 2300*UNO, -6500*UNO,   0*UNO*CROT,   0*UNO*CROT,   0*UNO*CROT
          dd -450*UNO,    0*UNO, -6500*UNO,   0*UNO*CROT,738*UNO*CROT,   0*UNO*CROT
          dd -450*UNO,    0*UNO, -6500*UNO,   0*UNO*CROT,738*2*UNO*CROT, 0*UNO*CROT
          dd -450*UNO,-2300*UNO, -6500*UNO,   0*UNO*CROT,600*3*UNO*CROT, 0*UNO*CROT

;-----------------------------------------------------------------------------
Pname3	  dd -710*UNO, 2300*UNO, -6500*UNO,   0*UNO*CROT,   0*UNO*CROT,   0*UNO*CROT
          dd -710*UNO,    0*UNO, -6500*UNO,   0*UNO*CROT,738*UNO*CROT,   0*UNO*CROT
          dd -710*UNO,    0*UNO, -6500*UNO,   0*UNO*CROT,738*2*UNO*CROT, 0*UNO*CROT
          dd -710*UNO,-2300*UNO, -6500*UNO,   0*UNO*CROT,600*3*UNO*CROT, 0*UNO*CROT

;-----------------------------------------------------------------------------
; Escena de transici줻 del planeta a la c쟭ara...
;UNO = UNO * 4
;CROT = CROT / 4

Ppivcam0   dd   000*UNO,  0000*UNO, -0350*UNO, 0, 0, 0
	   dd   000*UNO,  0000*UNO, -1500*UNO, 0, 0, 0
	   dd   000*UNO,  0000*UNO, -1500*UNO, 0, 0, 0
	   dd   000*UNO,  0000*UNO, -1500*UNO, 0, 0, 0
	   dd   000*UNO,  0000*UNO, -1500*UNO, 0, 0, 0

Ppiva0 	   dd 15000*UNO, 08000*UNO, 15000*UNO, 0, 0, 0
 	   dd 10000*UNO, 06000*UNO, 14000*UNO, 0, 0, 0
 	   dd 03000*UNO, 03000*UNO, 12000*UNO, 0, 0, 0
 	   dd 01000*UNO, 02000*UNO, 11000*UNO, 0, 0, 0
 	   dd 00000*UNO, 01000*UNO, 09000*UNO, 0, 0, 0

Psize0	   db	4

Ppiva1     dd 00000*UNO,  1000*UNO, 9000*UNO,  0, 0, 0
 	   dd 00000*UNO,  0000*UNO, 6000*UNO,  0, 0, 0

Psize1	   db	1


; Aparece la chica
Ppiva2 	   dd 00000*UNO,     0*UNO, 6000*UNO,  0, 0, 0
 	   dd 00000*UNO,     0*UNO, 2000*UNO,  0, 0, 0

Psize2	   db	1

; Desaparece...
Ppiva3 	   dd 00000*UNO,    0*UNO,  2000*UNO,  0, 0, 0
 	   dd 00000*UNO,    0*UNO,  1500*UNO,  0, 0, 0

Psize3	   db	1

;-----------------------------------------------------------------------------
; Baile de la piva

PDcam0	   dd    000*UNO,    000*UNO,   000*UNO,   0,   0,   0
	   dd    000*UNO,    000*UNO,   000*UNO,   0,   0,   0

PDcam0size db 1

PDcam1	   dd    000*UNO,    000*UNO,   000*UNO,   0,   0,   0
	   dd    200*UNO,   -300*UNO,   600*UNO,   0,   0,   0

PDcam1size db 1

; Transici줻 1...
PDcam2 	   dd    200*UNO,   -300*UNO,   600*UNO,   0,   0,   0
	   dd    200*UNO,   -300*UNO,   600*UNO,   0,   0,   0

PDcam2size db 1


; Transici줻 3...
PDcam3	   dd    000*UNO,   -300*UNO,   600*UNO,   0,   0,   0
	   dd    000*UNO,   -300*UNO,   850*UNO, -10*UNO*CROT,   0,   0

PDcam3size db    1

; Transici줻 4...	              
PDcam4	   dd    000*UNO,   -300*UNO,   850*UNO, -10*UNO*CROT,   0,   0
	   dd    000*UNO,   -300*UNO,   850*UNO, -10*UNO*CROT,   0,   0

PDcam4size db	1

AV = 160
AVINC = 17 ;32

; Transici줻 5...
PDcam5	   dd     000*UNO,   AV*UNO,   300*UNO,   0,   0,   0
AV = AV - AVINC
	   dd   -1000*UNO,   AV*UNO,   500*UNO,   0,   0,   0
AV = AV - AVINC
	   dd   -1200*UNO,   AV*UNO,  1500*UNO,   0,   0,   0
AV = AV - AVINC
	   dd   -1000*UNO,   AV*UNO,  2500*UNO,   0,   0,   0
AV = AV - AVINC
	   dd     000*UNO,   AV*UNO,  2700*UNO,   0,   0,   0
AV = AV - AVINC
	   dd    1000*UNO,   AV*UNO,  2500*UNO,   0,   0,   0
AV = AV - AVINC
	   dd    1200*UNO,   AV*UNO,  1500*UNO,   0,   0,   0
AV = AV - AVINC
	   dd    1000*UNO,   AV*UNO,   500*UNO,   0,   0,   0
AV = AV - AVINC

	   dd     000*UNO,   AV*UNO,   300*UNO,   0,   0,   0
AV = AV - AVINC
	   dd   -1000*UNO,   AV*UNO,   500*UNO,   0,   0,   0
AV = AV - AVINC
	   dd   -1200*UNO,   AV*UNO,  1500*UNO,   0,   0,   0
AV = AV - AVINC
	   dd   -1000*UNO,   AV*UNO,  2500*UNO,   0,   0,   0
AV = AV - AVINC
	   dd     000*UNO,   AV*UNO,  2700*UNO,   0,   0,   0
AV = AV - AVINC
	   dd    1000*UNO,   AV*UNO,  2500*UNO,   0,   0,   0
AV = AV - AVINC
	   dd    1200*UNO,   AV*UNO,  1500*UNO,   0,   0,   0
AV = AV - AVINC
	   dd    1000*UNO,   AV*UNO,   500*UNO,   0,   0,   0
AV = AV - AVINC

	   dd     000*UNO,   AV*UNO,   300*UNO,   0,   0,   0
AV = AV - AVINC
	   dd   -1000*UNO,   AV*UNO,   500*UNO,   0,   0,   0
AV = AV - AVINC
	   dd   -1200*UNO,   AV*UNO,  1500*UNO,   0,   0,   0
AV = AV - AVINC
	   dd   -1000*UNO,   AV*UNO,  2500*UNO,   0,   0,   0
AV = AV - AVINC
	   dd     000*UNO,   AV*UNO,  2700*UNO,   0,   0,   0
AV = AV - AVINC
	   dd    1000*UNO,   AV*UNO,  2500*UNO,   0,   0,   0
AV = AV - AVINC
	   dd    1200*UNO,   AV*UNO,  1500*UNO,   0,   0,   0
AV = AV - AVINC
	   dd    1000*UNO,   AV*UNO,   500*UNO,   0,   0,   0
AV = AV - AVINC

	   dd     000*UNO,   AV*UNO,   300*UNO,   0,   0,   0
	   dd   -1000*UNO,   AV*UNO,   500*UNO,   0,   0,   0
	   dd   -1200*UNO,   AV*UNO,  1500*UNO,   0,   0,   0
	   dd   -1000*UNO,   AV*UNO,  2500*UNO,   0,   0,   0
	   dd     000*UNO,   AV*UNO,  2700*UNO,   0,   0,   0
	   dd    1000*UNO,   AV*UNO,  2500*UNO,   0,   0,   0
	   dd    1200*UNO,   AV*UNO,  1500*UNO,   0,   0,   0
	   dd    1000*UNO,   AV*UNO,   500*UNO,   0,   0,   0

	   dd     000*UNO,   AV*UNO,   300*UNO,   0,   0,   0
	   dd   -1000*UNO,   AV*UNO,   500*UNO,   0,   0,   0
	   dd   -1200*UNO,   AV*UNO,  1500*UNO,   0,   0,   0
	   dd   -1000*UNO,   AV*UNO,  2500*UNO,   0,   0,   0
	   dd     000*UNO,   AV*UNO,  2700*UNO,   0,   0,   0
	   dd    1000*UNO,   AV*UNO,  2500*UNO,   0,   0,   0
	   dd    1200*UNO,   AV*UNO,  1500*UNO,   0,   0,   0
	   dd    1000*UNO,   AV*UNO,   500*UNO,   0,   0,   0

	   dd     500*UNO,   AV*UNO,   300*UNO,   0,   0,   0
	   dd     100*UNO,   AV*UNO,   300*UNO,   0,   0,   0

PDcam5size db 41

PDcam6	   dd     000*UNO,   AV*UNO,   300*UNO,   0,   0,   0
	   dd     000*UNO, -450*UNO,   900*UNO,   0,   0,   0

PDcam6size db	1

PDcam7	   dd     000*UNO,       -450*UNO,   900*UNO,   0,   0,   0
	   dd     000*UNO,       -450*UNO,   900*UNO,   0,   0,   0

PDcam7size db	1

PDcam8	   dd     000*UNO,       -450*UNO,   900*UNO,   0,   0,   0
	   dd     000*UNO,       -100*UNO, -5000*UNO,   0,   0,   0
	   dd     000*UNO,          0*UNO, -15000*UNO,   0,   0,   0

PDcam8size db	2

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

PDpiva1    dd   0000*UNO,     0*UNO,  1500*UNO,  0*UNO*CROT, 0*UNO*CROT, 0*UNO*CROT
 	   dd   0000*UNO,     0*UNO,  1500*UNO,  0*UNO*CROT, 0*UNO*CROT, 0*UNO*CROT


PDlight1   dd   1200*UNO, -2000*UNO, -3500*UNO,      0,   0,   0
	   dd   1200*UNO, -2000*UNO, -3500*UNO,      0,   0,   0

; Secuencias principales
Taspa	  dd	53284*2
Tmeneito  dd    53284*2-45000
Tpown     dd    45284*2-18500

Taspa2meneito	dd    35284*2
Taspa2pown      dd    45284*2
Tmeneito2aspa   dd    45284*2
Tmeneito2pown   dd    49284*2
Tpown2meneito   dd    45284*2
Tpown2aspa      dd    45284*2


Paspa	  db	7,0,1,2,3,4,5,6,7           ; Baile 1 (Brazos)
Pmeneito  db    13,8,9,10,11,12,13	    ; Baile 2 (Meneito)
Ppown	  db    19,14,15,16,17,18,19        ; Baile 3 (Pown-Pown-Pown)


Paspasub1 db	7,0,1,2,3
Paspasub2 db	3,4,5,6,7

;7,0,1,2,3,4,5,6,7

Paspasub1size db	4
Paspasub2size db	4

Paspasize	db	8
Pmeneitosize	db	6
Ppownsize	db	6

Paspa2meneito	db  7,8,9,10,11,12,13            ; -> Meneito
Paspa2pown	db  7,20,21,14,15,16,17,18,19    ; -> Pown
Pmeneito2aspa   db  13,0,1,2,3,4,5,6,7           ; -> Aspa
Pmeneito2pown	db  13,7,20,21,14,15,16,17,18,19 ; -> Pown
Ppown2aspa	db  19,21,20,0,1,2,3,4,5,6,7     ; -> Aspa
Ppown2meneito	db  19,14,20,7,8,9,10,11,12,13   ; -> Aspa ?

Paspa2meneitosize	db	6
Paspa2pownsize	 	db	8
Pmeneito2aspasize	db	8
Pmeneito2pownsize	db	9
Ppown2aspasize	 	db	10
Ppown2meneitosize 	db	9


;UNO = UNO / 4
;CROT = CROT * 4
;-----------------------------------------------------------------------------

bur1	dd      0*UNO, 5600*UNO,0*UNO,  0,  0,  0
	dd      0*UNO,-5600*UNO,0*UNO,  0,  0,  0
	dd      0*UNO, 5600*UNO,0*UNO,  0,  0,  0
	dd      0*UNO,-5600*UNO,0*UNO,  0,  0,  0
	dd      0*UNO, 5600*UNO,0*UNO,  0,  0,  0
	dd      0*UNO,-5600*UNO,0*UNO,  0,  0,  0
	dd      0*UNO, 5600*UNO,0*UNO,  0,  0,  0
	dd      0*UNO,-5600*UNO,0*UNO,  0,  0,  0
	dd      0*UNO, 5600*UNO,0*UNO,  0,  0,  0
	dd      0*UNO,-5600*UNO,0*UNO,  0,  0,  0
	dd      0*UNO, 5600*UNO,0*UNO,  0,  0,  0
	dd   	0*UNO,-5600*UNO,0*UNO,  0,  0,  0
	dd      0*UNO, 5600*UNO,0*UNO,  0,  0,  0
	dd      0*UNO,-5600*UNO,0*UNO,  0,  0,  0
	dd      0*UNO, 5600*UNO,0*UNO,  0,  0,  0
	dd      0*UNO,-5600*UNO,0*UNO,  0,  0,  0
	dd      0*UNO, 5600*UNO,0*UNO,  0,  0,  0
	dd      0*UNO,-5600*UNO,0*UNO,  0,  0,  0
	dd      0*UNO, 5600*UNO,0*UNO,  0,  0,  0
	dd      0*UNO,-5600*UNO,0*UNO,  0,  0,  0
	dd      0*UNO, 5600*UNO,0*UNO,  0,  0,  0
	dd      0*UNO,-5600*UNO,0*UNO,  0,  0,  0
	dd      0*UNO, 5600*UNO,0*UNO,  0,  0,  0
	dd      0*UNO,-5600*UNO,0*UNO,  0,  0,  0
	dd      0*UNO, 5600*UNO,0*UNO,  0,  0,  0
	dd      0*UNO,-5600*UNO,0*UNO,  0,  0,  0
	dd      0*UNO, 5600*UNO,0*UNO,  0,  0,  0
	dd      0*UNO,-5600*UNO,0*UNO,  0,  0,  0
	dd      0*UNO, 5600*UNO,0*UNO,  0,  0,  0
	dd      0*UNO,-5600*UNO,0*UNO,  0,  0,  0
;-----------------------------------------------------------------------------

