;
;   Copyleft (C) 1995, 1996 Exobit Productions International Corp.
;
;       main code by Mentat
;
;    (what a cooperation work, man!) ;)))
;


    .386p                       ;-)
    locals
    jumps


public exptab1
public exptab2
public crtab1
public crtab2
public colortb
public colort2


code32  segment para public use32
	assume cs:code32, ds:code32



align 4
exptab1 dd 06000h, 02000h, 02000h, 06000h, 06000h, 06000h
        dd 00000h, 00000h, 00000h, 00000h, 00000h, 01000h
        dd 01000h, 01000h, 01000h, 01000h, 01000h, 01000h
        dd 01000h, 01000h, 01000h, 01000h, 01000h, 01000h
        dd 00800h, 00800h, 00800h, 00800h, 00800h, 00800h
        dd 00800h, 00800h, 00800h, 00800h, 00800h, 00800h
        dd 00800h, 00800h, 00800h, 00800h, 00800h, 00800h
        dd 00800h, 00800h, 00800h, 00800h, 00800h, 00800h
        dd 00800h, 00800h, 00800h, 00800h, 00800h, 00800h
        dd 00800h, 00800h, 00800h, 00800h, 00800h, 00800h
        dd 01800h, 01800h, 01800h, 01800h, 01800h, 01800h
        dd 01800h, 01800h, 01800h, 01800h, 01800h, 01800h
        dd 01800h, 01800h, 01800h, 01800h, 01800h, 01800h
        dd 01800h, 01800h, 01800h, 01800h, 01800h, 01800h
        dd 01800h, 01800h, 01800h, 01800h, 01800h, 01800h
        dd 01800h, 01800h, 01800h, 01800h, 01800h, 01800h
        dd 01800h, 01800h, 01800h, 01800h, 01800h, 01800h
        dd 01800h, 01800h, 01800h, 01800h, 01800h, 01800h
        dd 01800h, 01800h, 01800h, 01800h, 01800h, 01800h
        dd 01800h, 01800h, 01800h, 01800h, 01800h, 01800h
        dd 04000h, 04000h, 04000h, 04000h, 04000h, 04000h
        dd 04000h, 04000h, 04000h, 04000h, 04000h, 04000h
        dd 04000h, 04000h, 04000h, 04000h, 04000h, 04000h
        dd 04000h, 04000h, 04000h, 04000h, 04000h, 04000h
        dd 04000h, 04000h, 04000h, 04000h, 04000h, 04000h
        dd 04000h, 04000h, 04000h, 04000h, 04000h, 04000h
        dd 04000h, 04000h, 04000h, 04000h, 04000h, 04000h
        dd 04000h, 04000h, 04000h, 04000h, 04000h, 04000h
        dd 04000h, 04000h, 04000h, 04000h, 04000h, 04000h
        dd 04000h, 04000h, 04000h, 04000h, 04000h, 04000h
        dd 04000h, 04000h, 04000h, 04000h, 04000h, 04000h
        dd 04000h, 04000h, 04000h, 04000h, 04000h, 04000h
        dd 04000h, 04000h, 04000h, 04000h, 04000h, 04000h
        dd 04000h, 04000h, 04000h, 04000h, 04000h, 04000h
        dd 04000h, 04000h, 04000h, 04000h, 04000h, 04000h
        dd 08000h, 0A000h, 10000h

align 4
exptab2 dd 03000h, 04400h, 04000h, 06000h, 06000h, 06000h
        dd 00000h, 00000h, 00000h, 00000h, 00000h, 01000h
        dd 01000h, 01000h, 01000h, 01000h, 01000h, 01000h
        dd 01000h, 01000h, 01000h, 01000h, 01000h, 01000h
        dd 00800h, 00800h, 00800h, 00800h, 00800h, 00800h
        dd 00800h, 00800h, 00800h, 00800h, 00800h, 00800h
        dd 00800h, 00800h, 00800h, 00800h, 00800h, 00800h
        dd 00800h, 00800h, 00800h, 00800h, 00800h, 00800h
        dd 00800h, 00800h, 00800h, 00800h, 00800h, 00800h
        dd 00800h, 00800h, 00800h, 00800h, 00800h, 00800h
        dd 00800h, 00800h, 00800h, 00800h, 00800h, 00800h
        dd 01800h, 01800h, 01800h, 01800h, 01800h, 01800h
        dd 01800h, 01800h, 01800h, 01800h, 01800h, 01800h
        dd 01800h, 01800h, 01800h, 01800h, 01800h, 01800h
        dd 01800h, 01800h, 01800h, 01800h, 01800h, 01800h
        dd 04000h, 04000h, 04000h, 04000h, 04000h, 04000h
        dd 04000h, 04000h, 04000h, 04000h, 04000h, 04000h
        dd 04000h, 04000h, 04000h, 04000h, 04000h, 04000h
        dd 04000h, 04000h, 04000h, 04000h, 04000h, 04000h
        dd 04000h, 04000h, 04000h, 04000h, 04000h, 04000h
        dd 04000h, 04000h, 04000h, 04000h, 04000h, 04000h
        dd 04000h, 04000h, 04000h, 04000h, 04000h, 04000h
        dd 04000h, 04000h, 04000h, 04000h, 04000h, 04000h
        dd 04000h, 04000h, 04000h, 04000h, 04000h, 04000h
        dd 04000h, 04000h, 04000h, 04000h, 04000h, 04000h
        dd 04000h, 04000h, 04000h, 04000h, 04000h, 04000h
        dd 04000h, 04000h, 04000h, 04000h, 04000h, 04000h
        dd 04000h, 04000h, 04000h, 04000h, 04000h, 04000h
        dd 04000h, 04000h, 04000h, 04000h, 04000h, 04000h
        dd 04000h, 04000h, 04000h, 04000h, 04000h, 04000h
        dd 04000h, 04000h, 04000h, 04000h, 04000h, 04000h
        dd 04000h, 04000h, 04000h, 04000h, 04000h, 04000h
        dd 04000h, 04000h, 04000h, 04000h, 04000h, 04000h
        dd 04000h, 04000h, 04000h, 04000h, 04000h, 04000h
        dd 04000h, 04000h, 04000h, 04000h, 04000h, 04000h
        dd 04000h, 04000h, 04000h, 04000h, 04000h, 04000h
        dd 08000h, 0A000h, 10000h

align 4
crtab1: dw 0001h, 0001h, 0001h, 0001h, 0001h, 0001h, 0001h, 0001h
        dw 0001h, 0001h, 0001h, 0001h, 0001h, 0001h, 0001h, 0001h
        dw 0001h, 0001h, 0001h, 0001h, 0001h, 0001h, 0001h, 0001h
        dw 0001h, 0001h, 0001h, 0001h, 0001h, 0001h, 0001h, 0001h
        dw 0001h, 0001h, 0001h, 0001h, 0001h, 0001h, 0001h, 0001h
        dw 0001h, 0001h, 0001h, 0001h, 0001h, 0001h, 0001h, 0001h
        dw 0002h, 0002h, 0001h, 0002h, 0002h, 0002h, 0002h, 0002h
        dw 0002h, 0002h, 0001h, 0002h, 0002h, 0002h, 0002h, 0002h
        dw 0002h, 0002h, 0001h, 0002h, 0002h, 0002h, 0002h, 0002h
        dw 0002h, 0002h, 0001h, 0001h, 0001h, 0001h, 0001h, 0001h
        dw 0002h, 0002h, 0001h, 0002h, 0002h, 0002h, 0002h, 0002h
        dw 0002h, 0002h, 0001h, 0002h, 0002h, 0002h, 0002h, 0002h
        dw 0002h, 0002h, 0001h, 0002h, 0002h, 0002h, 0002h, 0002h
        dw 0004h, 0004h, 0004h, 0004h, 0004h, 0004h, 0004h, 0004h
        dw 0004h, 0004h, 0004h, 0004h, 0004h, 0004h, 0004h, 0004h
        dw 0004h, 0004h, 0004h, 0004h, 0004h, 0004h, 0004h, 0004h
        dw 0004h, 0004h, 0004h, 0004h, 0004h, 0004h, 0004h, 0004h
        dw 0008h, 0008h, 0008h, 0008h, 0008h, 0008h, 0008h, 0008h
        dw 0008h, 0008h, 0008h, 0008h, 0008h, 0008h, 0008h, 0008h
        dw 0008h, 0008h, 0008h, 0008h, 0008h, 0008h, 0008h, 0008h
        dw 0008h, 0008h, 0008h, 0008h, 0008h, 0008h, 0008h, 0008h
        dw 0008h, 0008h, 0008h, 0008h, 0008h, 0008h, 0008h, 0008h
        dw 0020h, 0020h, 0020h, 0020h, 0020h, 0020h, 0020h, 0020h
        dw 0020h, 0020h, 0020h, 0020h, 0020h, 0020h, 0020h, 0020h
        dw 0020h, 0020h, 0020h, 0020h, 0020h, 0020h, 0020h, 0020h
        dw 0020h, 0020h, 0020h, 0020h, 0020h, 0020h, 0020h, 0020h
        dw 0020h, 0020h, 0020h, 0020h, 0020h, 0020h, 0020h, 0020h
        dw 0020h, 0020h, 0020h, 0020h, 0020h, 0020h, 0020h, 0020h
        dw 0020h, 0020h, 0020h, 0020h, 0020h, 0020h, 0020h, 0020h
        dw 0020h, 0020h, 0020h, 0020h, 0020h, 0020h, 0020h, 0020h
        dw 0020h, 0020h, 0020h, 0020h, 0020h, 0020h, 0020h, 0020h

align 4
crtab2: dw 0008h, 0008h, 0001h, 0001h, 0001h, 0001h, 0001h, 0001h
        dw 0001h, 0001h, 0001h, 0001h, 0001h, 0001h, 0001h, 0001h
        dw 0001h, 0001h, 0001h, 0001h, 0001h, 0001h, 0001h, 0001h
        dw 0001h, 0001h, 0001h, 0001h, 0001h, 0001h, 0001h, 0001h
        dw 0001h, 0001h, 0001h, 0001h, 0001h, 0001h, 0001h, 0001h
        dw 0001h, 0001h, 0008h, 0008h, 0008h, 0011h, 0011h, 0011h
        dw 0012h, 0010h, 0011h, 0012h, 0012h, 0012h, 0012h, 0011h
        dw 0012h, 0010h, 0011h, 0012h, 0012h, 0012h, 0012h, 0011h
        dw 0012h, 0010h, 0011h, 0012h, 0012h, 0012h, 0012h, 0011h
        dw 0012h, 0010h, 0011h, 0012h, 0012h, 0012h, 0012h, 0011h
        dw 0012h, 0010h, 0011h, 0012h, 0012h, 0012h, 0012h, 0011h
        dw 0012h, 0010h, 0011h, 0012h, 0012h, 0012h, 0012h, 0011h
        dw 0012h, 0010h, 0011h, 0012h, 0012h, 0012h, 0012h, 0011h
        dw 0012h, 0010h, 0011h, 0012h, 0012h, 0012h, 0012h, 0011h
        dw 0012h, 0010h, 0011h, 0012h, 0012h, 0012h, 0012h, 0011h
        dw 0020h, 0020h, 0020h, 0020h, 0020h, 0020h, 0020h, 0020h
        dw 0020h, 0020h, 0020h, 0020h, 0020h, 0020h, 0020h, 0020h
        dw 0020h, 0020h, 0020h, 0020h, 0020h, 0020h, 0020h, 0020h
        dw 0020h, 0020h, 0020h, 0020h, 0020h, 0020h, 0020h, 0020h
        dw 0020h, 0020h, 0020h, 0020h, 0020h, 0020h, 0020h, 0020h
        dw 0020h, 0020h, 0020h, 0020h, 0020h, 0020h, 0020h, 0020h
        dw 0020h, 0020h, 0020h, 0020h, 0020h, 0020h, 0020h, 0020h
        dw 0020h, 0020h, 0020h, 0020h, 0020h, 0020h, 0020h, 0020h
        dw 0020h, 0020h, 0020h, 0020h, 0020h, 0020h, 0020h, 0020h


align 4
colortb dw 000h, 000h, 001h, 001h, 002h, 002h, 003h, 003h
        dw 004h, 004h, 005h, 005h, 006h, 006h, 007h, 007h

        dw 000h, 000h, 011h, 014h, 012h, 016h, 013h, 018h
        dw 015h, 01Ah, 017h, 01Ch, 019h, 01Eh, 01Bh, 01Dh

        dw 000h, 000h, 021h, 021h, 022h, 022h, 023h, 023h
        dw 024h, 024h, 025h, 025h, 026h, 026h, 027h, 027h

        dw 000h, 000h, 031h, 031h, 032h, 032h, 033h, 033h
        dw 034h, 034h, 035h, 035h, 036h, 036h, 037h, 037h

        dw 000h, 000h, 041h, 042h, 043h, 046h, 04Ch, 04Ah
        dw 04Dh, 044h, 059h, 047h, 04Bh, 045h, 048h, 049h

        dw 000h, 000h, 051h, 051h, 052h, 052h, 053h, 053h
        dw 054h, 054h, 055h, 055h, 056h, 056h, 057h, 057h

        dw 000h, 000h, 061h, 061h, 062h, 062h, 063h, 063h
        dw 064h, 064h, 065h, 065h, 066h, 066h, 067h, 067h

        dw 000h, 000h, 071h, 071h, 072h, 072h, 073h, 073h
        dw 074h, 074h, 075h, 075h, 076h, 076h, 077h, 077h

        dw 000h, 000h, 081h, 081h, 082h, 082h, 083h, 083h
        dw 084h, 084h, 085h, 085h, 086h, 086h, 087h, 087h

        dw 000h, 000h, 091h, 092h, 093h, 094h, 095h, 096h
        dw 097h, 098h, 099h, 09Ah, 09Bh, 09Ch, 09Dh, 09Eh

        dw 000h, 000h, 0A1h, 0A1h, 0A2h, 0A2h, 0A3h, 0A3h
        dw 0A4h, 0A4h, 0A5h, 0A5h, 0A6h, 0A6h, 0A7h, 0A7h

        dw 000h, 000h, 0B1h, 0B1h, 0B2h, 0B2h, 0B3h, 0B3h
        dw 0B4h, 0B4h, 0B5h, 0B5h, 0B6h, 0B6h, 0B7h, 0B7h

        dw 000h, 000h, 0C1h, 0C1h, 0C2h, 0C2h, 0C3h, 0C3h
        dw 0C4h, 0C4h, 0C5h, 0C5h, 0C6h, 0C6h, 0C7h, 0C7h

        dw 000h, 000h, 0D1h, 0D1h, 0D2h, 0D2h, 0D3h, 0D3h
        dw 0D4h, 0D4h, 0D5h, 0D5h, 0D6h, 0D6h, 0D7h, 0D7h

        dw 000h, 000h, 0E1h, 0E1h, 0E2h, 0E2h, 0E3h, 0E3h
        dw 0E4h, 0E4h, 0E5h, 0E5h, 0E6h, 0E6h, 0E7h, 0E7h

        dw 000h, 000h, 0F1h, 0F1h, 0F2h, 0F2h, 0F3h, 0F3h
        dw 0F4h, 0F4h, 0F5h, 0F5h, 0F6h, 0F6h, 0F7h, 0F7h


align 4
colort2 dw 000h, 001h, 002h, 003h, 004h, 005h, 006h, 007h
        dw 008h, 009h, 00Ah, 00Bh, 00Ch, 00Dh, 00Eh, 00Fh

        dw 000h, 000h, 011h, 014h, 012h, 016h, 013h, 018h
        dw 015h, 01Ah, 017h, 01Ch, 019h, 01Eh, 01Bh, 01Dh

        dw 000h, 000h, 021h, 021h, 022h, 022h, 023h, 023h
        dw 024h, 024h, 025h, 025h, 026h, 026h, 027h, 027h

        dw 000h, 000h, 031h, 031h, 032h, 032h, 033h, 033h
        dw 034h, 034h, 035h, 035h, 036h, 036h, 037h, 037h

        dw 000h, 000h, 041h, 042h, 043h, 046h, 04Ch, 04Ah
        dw 04Dh, 044h, 059h, 047h, 04Bh, 045h, 048h, 049h

        dw 000h, 000h, 051h, 051h, 052h, 052h, 053h, 053h
        dw 054h, 054h, 055h, 055h, 056h, 056h, 057h, 057h

        dw 000h, 000h, 061h, 061h, 062h, 062h, 063h, 063h
        dw 064h, 064h, 065h, 065h, 066h, 066h, 067h, 067h

        dw 000h, 000h, 071h, 071h, 072h, 072h, 073h, 073h
        dw 074h, 074h, 075h, 075h, 076h, 076h, 077h, 077h

        dw 000h, 000h, 081h, 081h, 082h, 082h, 083h, 083h
        dw 084h, 084h, 085h, 085h, 086h, 086h, 087h, 087h

        dw 000h, 000h, 091h, 092h, 093h, 094h, 095h, 096h
        dw 097h, 098h, 099h, 09Ah, 09Bh, 09Ch, 09Dh, 09Eh

        dw 000h, 000h, 0A1h, 0A1h, 0A2h, 0A2h, 0A3h, 0A3h
        dw 0A4h, 0A4h, 0A5h, 0A5h, 0A6h, 0A6h, 0A7h, 0A7h

        dw 000h, 000h, 0B1h, 0B1h, 0B2h, 0B2h, 0B3h, 0B3h
        dw 0B4h, 0B4h, 0B5h, 0B5h, 0B6h, 0B6h, 0B7h, 0B7h

        dw 000h, 000h, 0C1h, 0C1h, 0C2h, 0C2h, 0C3h, 0C3h
        dw 0C4h, 0C4h, 0C5h, 0C5h, 0C6h, 0C6h, 0C7h, 0C7h

        dw 000h, 000h, 0D1h, 0D1h, 0D2h, 0D4h, 0D5h, 0D6h
        dw 0D6h, 0D8h, 0D8h, 0DAh, 0DBh, 0DCh, 0DDh, 0DEh

        dw 000h, 000h, 0E1h, 0E1h, 0E2h, 0E4h, 0E5h, 0E6h
        dw 0E6h, 0E8h, 0E8h, 0EAh, 0EBh, 0ECh, 0EDh, 0EEh

        dw 000h, 000h, 0F1h, 0F1h, 0F2h, 0F4h, 0F5h, 0F6h
        dw 0F6h, 0F8h, 0F8h, 0FAh, 0FBh, 0FCh, 0FDh, 0FEh


;様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様�

code32  ends
	end


