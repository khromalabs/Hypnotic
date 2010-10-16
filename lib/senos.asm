Ä [11] Programaci¢n de Demos (2:341/136.5) ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ R34.DEMOS.PROG Ä
 Msg  : 24 of 26                                                                
 From : Pedro Anton Alonso                  2:342/6.9       13 Apr 96  17:56:00 
 To   : Antonio Tejada Lacaci                                                   
 Subj : senos en 20 y pocos bytes...                                            
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Hello Antonio!

Jesus de Santos Garcia says to Antonio Tejada Lacaci:

JdSG>>> ¨¨24 bytes para precalcular los senos??
JdSG>>> Si es por el m‚todo de Taylor lo dudo mucho.
JdSG>>> Si es usando el copro lo dudo un poco menos.
AL>> .... conociendo a Mr. Shade ;) no creo que sea con el copro... :-?
AL>> ... JAVIER DONDE ESTAS, SACANOS DE DUDAS!!!!!!

No es con el copro, yo tenia un codigo que hacia eso, pero lo he buscado y no lo
encuentro ;'( es con incrementos, si mal no recuerdo, vino de uno de los
monstruitos vikingos, si lo encuentro lo pongo por aqu¡ O;)

ARGGGGGGGGGGGGGGGGGGGGHHHHHHHHHHHHHHHHHHHHHHHHH
Lo encontr‚!!!!!!! Por fin record‚ en que subdirectorio de mi HDD se encontraba 
la explicaci¢n O;)

Lo pongo en Ingles que no quiero problemas con la traducci¢n O;)

Here's some  explanation about the  sinus table generator in the ACE BBS advert.
The method used is a recursive sinus sythesis.  It's possible to compute all
sinus values with only the two previous ones and the value  of  cos(2ã/N) ,
where  n  is the number of values for one period.

It's as follow: Sin(K)=2.Cos(2ã/N).Sin(K-1)-Sin(K-2)
             or Cos(K)=2.Cos(2ã/N).Cos(K-1)-Cos(K-2)

 The last one is easiest to use , because the two first values of
 the cos table are 1 & cos(2ã/n) and with this two values you are
 able to build all the following...

Some simple code:
the cos table has 1024 values & ranges from -2^24 to 2^24

build_table:
lea    DI,cos_table
mov    CX,1022
mov    EBX,cos_table[4]
mov    EAX,EBX
@@calc:
imul   EBX
shrd   EAX,EDX,23
sub    EAX,[DI-8]
stosd
loop   @@calc

cos_table
dd     16777216     ; 2^24
dd     16776900     ; 2 ^24*cos(2ã/1024)
dd     1022 dup (?)

Y lamentablemente creo que son 30 bytes, o me equivoco? ;)

El vikingo en cuestion es: KarL/NoooN

Happy coding:  @@@@@--------------------------------------------.
             @@ | @@  @@@@  @@@@@@ @@@@@@@@  2:342/6.9          |
           @@   |    @@  @ @@  @@ @@ @@ @@   crom@sol.parser.es |
            @@@@@@--@@--- @@@@@@-@@-@@-@@---- Spanish Lords ----'

--- GoldED 2.40
 * Origin: Coders do it better (2:342/6.9)

