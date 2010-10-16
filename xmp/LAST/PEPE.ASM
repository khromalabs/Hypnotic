retf            MACRO   POP_COUNT
                LOCAL   DUMMY
                DUMMY   PROC FAR
                RET     POP_COUNT
                DUMMY   ENDP
                ENDM
.386p
                NAME    gus
                EXTRN   _dosputdec :BYTE
                EXTRN   _dosputhex :BYTE
                EXTRN   _dosputmsg :BYTE
                EXTRN   _videoputmsg :BYTE
                EXTRN   _XMP_Main :BYTE
                EXTRN   s_speed :BYTE
                EXTRN   s_bpm :BYTE
                EXTRN   s_type :BYTE
                EXTRN   s_pan :BYTE
                EXTRN   s_vol :BYTE
                EXTRN   s_freq :BYTE
                EXTRN   s_offset :BYTE
                EXTRN   s_loopl :BYTE
                EXTRN   s_loops :BYTE
                EXTRN   s_size :BYTE
                EXTRN   s_start :BYTE
                EXTRN   s_num :BYTE
                EXTRN   _XMP_End :BYTE
                EXTRN   _XMP_Prog :BYTE
                EXTRN   _XMP_Stop :BYTE
                EXTRN   _XMP_Play :BYTE
                EXTRN   _XMP_Load :BYTE
                EXTRN   _XMP_Init :BYTE
                EXTRN   _XMP_Detect :BYTE
                EXTRN   xmp_flag :BYTE
                EXTRN   xmp_status :BYTE
                EXTRN   xmp_devchann :BYTE
                EXTRN   xmp_devaddr :BYTE
                EXTRN   xmp_devmem :BYTE
                EXTRN   xmp_devdma2 :BYTE
                EXTRN   xmp_devdma1 :BYTE
                EXTRN   xmp_devirq2 :BYTE
                EXTRN   xmp_devirq1 :BYTE
                EXTRN   xmp_devport :BYTE
                EXTRN   xmp_devtype :BYTE
                EXTRN   xmp_digchann :BYTE
                EXTRN   xmp_snginst :BYTE
                EXTRN   xmp_snglen :BYTE
                EXTRN   xmp_sngchann :BYTE
                EXTRN   xmp_sngname :BYTE
                EXTRN   _freeselector :BYTE
                EXTRN   _getselector :BYTE
                EXTRN   _rmpmirqfree :BYTE
                EXTRN   _rmpmirqset :BYTE
                EXTRN   _setirqmask :BYTE
                EXTRN   _getirqmask :BYTE
                EXTRN   _exit :BYTE
                EXTRN   _ret :BYTE
                EXTRN   _himemsize :BYTE
                EXTRN   _lomemsize :BYTE
                EXTRN   _gethimem :BYTE
                EXTRN   _getlomem :BYTE
                EXTRN   _getmem :BYTE
                EXTRN   _exitcode :BYTE
                EXTRN   _setselector :BYTE
                EXTRN   _irqmode :BYTE
                EXTRN   _sysbyte0 :BYTE
                EXTRN   _setirqvect :BYTE
                EXTRN   _getirqvect :BYTE
                EXTRN   _code32a :BYTE
                EXTRN   _code16a :BYTE
                EXTRN   _pspa :BYTE
                EXTRN   _himemtop :BYTE
                EXTRN   _himembase :BYTE
                EXTRN   _lomemtop :BYTE
                EXTRN   _lomembase :BYTE
                EXTRN   _selzero :BYTE
                EXTRN   _seldata :BYTE
                EXTRN   _selcode :BYTE
                EXTRN   v86r_gs :BYTE
                EXTRN   v86r_fs :BYTE
                EXTRN   v86r_es :BYTE
                EXTRN   v86r_ds :BYTE
                EXTRN   v86r_bp :BYTE
                EXTRN   v86r_di :BYTE
                EXTRN   v86r_si :BYTE
                EXTRN   v86r_dx :BYTE
                EXTRN   v86r_cx :BYTE
                EXTRN   v86r_bx :BYTE
                EXTRN   v86r_ax :BYTE
                EXTRN   v86r_dl :BYTE
                EXTRN   v86r_dh :BYTE
                EXTRN   v86r_cl :BYTE
                EXTRN   v86r_ch :BYTE
                EXTRN   v86r_bl :BYTE
                EXTRN   v86r_bh :BYTE
                EXTRN   v86r_al :BYTE
                EXTRN   v86r_ah :BYTE
                EXTRN   v86r_ebp :BYTE
                EXTRN   v86r_edi :BYTE
                EXTRN   v86r_esi :BYTE
                EXTRN   v86r_edx :BYTE
                EXTRN   v86r_ecx :BYTE
                EXTRN   v86r_ebx :BYTE
                EXTRN   v86r_eax :BYTE
code32          SEGMENT PARA PUBLIC USE32 ''
                ASSUME  CS:code32 ,DS:DGROUP,SS:DGROUP
                PUBLIC  gus_detect 
                PUBLIC  gus_init 
                PUBLIC  gus_play 
                PUBLIC  gus_end 
                PUBLIC  gus_stop 
                PUBLIC  gus_load 
                PUBLIC  gus_csf 
                PUBLIC  gus_csv 
                PUBLIC  gus_csp 
                PUBLIC  gus_pse 
                PUBLIC  gus_pss 
L1:             and     byte ptr [edx],al
L2:             and     al,byte ptr [ebx]
L3:             and     eax,dword ptr [ebx]
L4:             and     al,03H
L5              DB      25H,03H,26H,02H,27H
                DB      03H,28H
                DB      02H,29H
                add     ch,byte ptr [ebx]
                DB      02H,00H
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                inc     ebx
                mov     eax,eax
                out     0a0H,al
                add     byte ptr [eax],al
                inc     ecx
                inc     ebx
                add     byte ptr +0H[edx],al
                inc     esp
                add     byte ptr [eax],al
                add     byte ptr +46H[ebp],al
                add     byte ptr [eax],al
                inc     edi
                xchg    ebx,ebx
L10:            add     byte ptr [eax],al
                add     byte ptr [eax],al
                inc     esp
                lodsb   
                add     byte ptr [eax],al
                enter   00a0H,00H
                mov     ebx,0dd000096H
                lea     eax,[eax]
                add     ah,bh
                test    dword ptr [eax],eax
                add     dh,ch
                jle     short L11
L11:            add     byte ptr -27ffff88H[esi],dl
                jb      short L12
L12:            add     byte ptr -24ffff93H[edi],bl
                push    647d0000H
                add     byte ptr [eax],al
                js      short L14
                add     byte ptr [eax],al
                ret     005cH
                add     byte ptr +59H[edx],dl
                add     byte ptr [eax],al
                and     dl,byte ptr +0H[esi]
                add     byte ptr [ecx],ch
                push    ebx
                add     byte ptr [eax],al
                push    eax
                add     byte ptr [eax],al
                int     3
                dec     ebp
                add     byte ptr [eax],al
                pop     ebp
                dec     ebx
                add     byte ptr [eax],al
                add     byte ptr [ecx],al
                add     byte ptr [edi],al
                inc     dword ptr [edi]
                or      byte ptr [eax],0ffH
                or      byte ptr +9H[eax],al
                or      byte ptr [ecx],0c0H
                or      edi,edi
                or      dword ptr [eax],esp
                or      al,byte ptr +0aH[eax]
                pushad  
                or      al,byte ptr -3ff55ff6H[eax]
                or      ah,al
                or      bh,bh
                or      dl,byte ptr [eax]
                or      esp,dword ptr [eax]
                or      esi,dword ptr [eax]
                or      eax,dword ptr +0bH[eax]
                push    eax
                or      esp,dword ptr +0bH[eax]
                jo      short L13
                or      byte ptr [ebx],90H
                or      esp,dword ptr -3ff44ff5H[eax]
                or      edx,eax
L13:            or      esp,eax
                or      esi,eax
                or      edi,edi
                DB      0bH,08H
                or      al,10H
                or      al,18H
                or      al,20H
                or      al,28H
                or      al,30H
                or      al,38H
                or      al,40H
                or      al,48H
                or      al,50H
                or      al,58H
                or      al,60H
                or      al,68H
                or      al,70H
                or      al,78H
                or      al,80H
                or      al,88H
                or      al,90H
                or      al,98H
                or      al,0a0H
                or      al,0a8H
                or      al,0b0H
                or      al,0b8H
                or      al,0c0H
                or      al,0c8H
                or      al,0d0H
                or      al,0d8H
                or      al,0e0H
                or      al,0e8H
                or      al,0f0H
                or      al,0f8H
                or      al,0ffH
                or      al,04H
                or      eax,0d0c0d08H
                adc     byte ptr [0d180d14H],cl
                sbb     al,0dH
                and     byte ptr [0d280d24H],cl
                sub     al,0dH
                xor     byte ptr [0d380d34H],cl
                cmp     al,0dH
                inc     eax
                or      eax,0d480d44H
                dec     esp
                or      eax,0d540d50H
                pop     eax
                or      eax,0d600d5cH
                or      eax,0d6c0d68H
                jo      short L15
                je      short L16
                js      short L17
                jl      short L18
                or      byte ptr [0d880d84H],8cH
L15             DB      0dH,90H,0dH,94H,0dH
                cwde    
L18:            or      eax,0da00d9cH
                movsb   
                or      eax,0dac0da8H
                mov     al,0dH
                mov     ah,0dH
                mov     eax,0c00dbc0dH
                or      eax,0dc80dc4H
                int     3
                or      eax,0dd40dd0H
                fmul    dword ptr [0de00ddcH]
                in      al,0dH
                call    near ptr L1-0ff21266H
                or      eax,0df80df4H
                cld     
                or      eax,0e020dffH
                add     al,0eH
                push    es
                push    cs
                or      byte ptr [esi],cl
                or      cl,byte ptr [esi]
                or      al,0eH
                push    cs
                push    cs
                adc     byte ptr [esi],cl
                adc     cl,byte ptr [esi]
                adc     al,0eH
                push    ss
                push    cs
                sbb     byte ptr [esi],cl
                sbb     cl,byte ptr [esi]
                sbb     al,0eH
                push    ds
                push    cs
                and     byte ptr [esi],cl
                and     cl,byte ptr [esi]
                and     al,0eH
                push    cs
                sub     byte ptr [esi],cl
                sub     cl,byte ptr [esi]
                sub     al,0eH
                push    cs
                xor     byte ptr [esi],cl
                xor     cl,byte ptr [esi]
                xor     al,0eH
                push    cs
                cmp     byte ptr [esi],cl
                cmp     cl,byte ptr [esi]
                cmp     al,0eH
                push    cs
                inc     eax
                push    cs
                inc     edx
                push    cs
                inc     esp
                push    cs
                inc     esi
                push    cs
                dec     eax
                push    cs
                dec     edx
                push    cs
                dec     esp
                push    cs
                dec     esi
                push    cs
                push    eax
                push    cs
                push    edx
                push    cs
                push    esp
                push    cs
                push    esi
                push    cs
                pop     eax
                push    cs
                pop     edx
                push    cs
                pop     esp
                push    cs
                pop     esi
                push    cs
                pushad  
                push    cs
                bound   ecx,dword ptr [esi]
                push    cs
                push    cs
                push    6c0e6a0eH
                push    cs
                outsb   
                push    cs
                jo      short L19
                jb      short L20
                je      short L21
                jbe     short L22
                js      short L23
                jp      short L24
                jl      short L25
                jle     short L26
L19             DB      80H,0eH,82H
                push    cs
L21:            test    byte ptr [esi],cl
L22:            xchg    cl,byte ptr [esi]
L23:            mov     byte ptr [esi],cl
L24:            mov     cl,byte ptr [esi]
L25:            mov     word ptr [esi],cs
L26:            mov     cs,word ptr [esi]
                nop     
                push    cs
                xchg    eax,edx
                push    cs
                xchg    eax,esp
                push    cs
                xchg    eax,esi
                push    cs
                cwde    
                push    cs
                call    far ptr 0a00eH:9e0e9c0eH
                push    cs
                mov     byte ptr [0a60ea40eH],al
                push    cs
                test    al,0eH
                stosb   
                push    cs
                lodsb   
                push    cs
                scasb   
                push    cs
                mov     al,0eH
                mov     dl,0eH
                mov     ah,0eH
                mov     dh,0eH
                mov     eax,0bc0eba0eH
                push    cs
                mov     esi,0c20ec00eH
                push    cs
                les     ecx,pword ptr [esi]
                mov     byte ptr [esi],0c8H
                push    cs
                retf    0cc0eH
                push    cs
                into    
                push    cs
                ror     byte ptr [esi],1
                ror     byte ptr [esi],cl
                aam     
                ?????
                push    cs
                fmul    dword ptr [esi]
                fimul   dword ptr [esi]
                fmul    qword ptr [esi]
                fimul   word ptr [esi]
                loopne  L27
                loop    L28
                in      al,0eH
                out     0eH,al
                call    near ptr L1-13f11371H
                push    cs
                out     dx,al
                push    cs
L27:            lock    push     cs
L28:            repne   push     cs
                halt    
                push    cs
                ?????
                push    cs
                clc     
                push    cs
                cli     
                push    cs
                cld     
                push    cs
                dec     byte ptr [esi]
                dec     dword ptr [esi]
                add     dword ptr [edi],ecx
                add     cl,byte ptr [edi]
                add     ecx,dword ptr [edi]
                add     al,0fH
                add     eax,070f060fH
                invd    
                wbinvd  
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                mov     edi,
                and     dword ptr [edi],ecx
                and     cl,byte ptr [edi]
                and     ecx,dword ptr [edi]
                and     al,0fH
                and     eax,270f260fH
                mov     dword ptr [edi],ecx
                sub     dword ptr [edi],ecx
                sub     cl,byte ptr [edi]
                sub     ecx,dword ptr [edi]
                sub     al,0fH
                sub     eax,2f0f2e0fH
                wrmsr   
                rdtsc   
                rdmsr   
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                jo      near ptr L1-7df07b58H
                jae     near ptr L1-7af07852H
                jbe     near ptr L1-77f0754cH
                jns     near ptr L1-74f07246H
                jl      near ptr L1-71f06f40H
                jg      near ptr L1-6ef06c3aH
                setb    byte ptr [edi]
                xchg    eax,ebx
                sete    byte ptr [edi]
                xchg    eax,ebp
                setbe   byte ptr [edi]
                xchg    eax,edi
                sets    byte ptr [edi]
                cdq     
                setp    byte ptr [edi]
                wait    
                setl    byte ptr [edi]
                popfd   
                setle   byte ptr [edi]
                lahf    
                push    fs
                pop     fs
                cpuid   
                bt      dword ptr [edi],ecx
                movsb   
                shld    dword ptr [edi],ecx,cl
                cmpsb   
                ?????
                push    gs
                pop     gs
                rsm     
                bts     dword ptr [edi],ecx
                lodsb   
                shrd    dword ptr [edi],ecx,cl
                scasb   
                imul    ecx,dword ptr [edi]
                mov     al,0fH
                mov     cl,0fH
                mov     dl,0fH
                mov     bl,0fH
                mov     ah,0fH
                mov     ch,0fH
                mov     dh,0fH
                mov     bh,0fH
                mov     eax,0ba0fb90fH
                btc     dword ptr [edi],ecx
                mov     esp,0be0fbd0fH
                movsx   ecx,word ptr [edi]
                ror     byte ptr [edi],0c1H
                ?????
                ?????
                ?????
                ?????
                ?????
                cmpxchg8b       dword ptr [edi]
                enter   0c90fH,0fH
                retf    0cb0fH
                bswap   esp
                bswap   ebp
                bswap   esi
                bswap   edi
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                ?????
                sldt    word ptr [eax]
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
L29:            add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                DB      00H,00H
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
L31:            add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
L32:            add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                DB      00H,00H
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
L34:            add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                DB      00H,00H
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                push    es
                add     byte ptr +0H[ebp],bh
L36:            add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                add     byte ptr [eax],al
                sub     eax,50422420H
                dec     ebp
                cmp     ah,byte ptr [eax]
                and     al,0dH
                or      ah,byte ptr +73H[ebp]
                je      short L38
                jae     short L37
                imul    ebp,dword ptr +69H[esi],6c616963H
                imul    edi,dword ptr +61H[edx],206f646eH
                insb    
                popad   
                and     byte ptr +55H[edi],al
                push    ebx
                DB      21H,24H,60H
                mov     ax,word ptr xmp_devport
                test    ax,ax
                DB      0fH,84H,0fdH,01H,00H,00H
                mov     word ptr L1+5329H,ax
                add     ax,0006H
                mov     word ptr L1+4b5d0000H,ax
                add     ax,0002H
                mov     word ptr L1+88007ffH,ax
                inc     ax
                mov     word ptr L1+9c00980H,ax
                add     ax,0002H
                mov     word ptr L1+0a800a60H,ax
                mov     ax,word ptr xmp_devport
                add     ax,0102H
                DB      66H,0a3H,02H,00H,00H,00H
                inc     ax
                mov     word ptr L1-7ff48ff5H,ax
                inc     ax
                mov     word ptr L1-3ff44ff5H,ax
                inc     ax
                mov     word ptr L1-0f40ff5H,ax
                add     ax,0002H
                mov     word ptr L1+280c200cH,ax
                mov     dx,word ptr L1+0c400c38H
                mov     al,4cH
                out     dx,al
                mov     dx,word ptr L1+0c680c60H
                mov     al,00H
                out     dx,al
                mov     dx,word ptr L1+0c900c88H
                mov     al,4cH
                out     dx,al
                mov     dx,word ptr L1+0cb80cb0H
                mov     al,07H
                out     dx,al
                mov     dx,word ptr L1+0ce00cd8H
                mov     al,44H
                out     dx,al
                mov     dx,word ptr L1+0d040cffH
                mov     al,00H
                out     dx,al
                mov     dx,word ptr L1+0d180d14H
                mov     al,43H
                out     dx,al
                mov     dx,word ptr L1+0d2c0d28H
                mov     ax,0000H
                out     dx,ax
                mov     dx,word ptr L1+480d440dH
                mov     al,0aaH
                out     dx,al
                mov     dx,word ptr L1+5c0d580dH
                mov     al,44H
                out     dx,al
                mov     dx,word ptr L1+700d6c0dH
                mov     al,00H
                out     dx,al
                mov     dx,word ptr L1-7bf27ff3H
                mov     al,43H
                out     dx,al
                mov     dx,word ptr L1-67f26bf3H
                mov     ax,0000H
                out     dx,ax
                mov     dx,word ptr L1+0db00dacH
                in      al,dx
                cmp     al,0aaH
                jne     near ptr L40
                mov     dx,word ptr L1+0dd00dccH
                mov     al,44H
                out     dx,al
                mov     dx,word ptr L1+0de40de0H
                mov     al,00H
                out     dx,al
                mov     dx,word ptr L1+0df80df4H
                mov     al,43H
                out     dx,al
                mov     dx,word ptr L1+0e060e04H
                mov     ax,0000H
                out     dx,ax
                mov     dx,word ptr L1+140e120eH
                xor     al,al
                out     dx,al
                mov     ebx,00000004H
L39:            mov     dx,word ptr L1+0e220e20H
                mov     al,44H
                out     dx,al
                mov     dx,word ptr L1+0e2c0e2aH
                mov     al,bl
                out     dx,al
                mov     dx,word ptr L1+0e360e34H
                mov     al,43H
                out     dx,al
                mov     dx,word ptr L1+0e400e3eH
                mov     ax,0000H
                out     dx,ax
                mov     dx,word ptr L1+4e0e4c0eH
                mov     al,0aaH
                out     dx,al
                mov     dx,word ptr L1+580e560eH
                mov     al,44H
                out     dx,al
                mov     dx,word ptr L1+620e600eH
                mov     al,bl
                out     dx,al
                mov     dx,word ptr L1+6c0e6a0eH
                mov     al,43H
                out     dx,al
                mov     dx,word ptr L1+760e740eH
                mov     ax,0000H
                out     dx,ax
                mov     dx,word ptr L1+0e820e80H
                in      al,dx
                cmp     al,0aaH
                jne     short L40
                mov     dx,word ptr L1+0e8e0e8cH
                mov     al,44H
                out     dx,al
                mov     dx,word ptr L1+0e980e96H
                mov     al,00H
                out     dx,al
                mov     dx,word ptr L1+0ea20ea0H
                mov     al,43H
                out     dx,al
                mov     dx,word ptr L1+0eac0eaaH
                mov     ax,0000H
                out     dx,ax
                mov     dx,word ptr L1-45f147f2H
                in      al,dx
                test    al,al
                jne     short L40
                add     bx,0004H
                cmp     bx,00ffH
                jb      near ptr L39
L40:            shl     ebx,10H
                mov     dword ptr xmp_devmem,ebx
                mov     dx,word ptr L1+0edc0edaH
                mov     al,4cH
                out     dx,al
                mov     dx,word ptr L1+0ee60ee4H
                mov     al,00H
                out     dx,al
L41:            popad   
                ret     
gus_init:       pushad  
                mov     ax,word ptr xmp_devport
                mov     word ptr L1-7f109f2H,ax
                add     ax,0006H
                mov     word ptr L1+10eff0eH,ax
                add     ax,0002H
                mov     word ptr L1+60f050fH,ax
                inc     ax
                mov     word ptr L1+0a0f090fH,ax
                add     ax,0002H
                mov     word ptr L1+0f0f0e0fH,ax
                mov     ax,word ptr xmp_devport
                add     ax,0102H
                mov     word ptr L1+0f160f15H,ax
                inc     ax
                mov     word ptr L1+0f1a0f19H,ax
                inc     ax
                mov     word ptr L1+0f1e0f1dH,ax
                inc     ax
                mov     word ptr L1+0f220f21H,ax
                add     ax,0002H
                mov     word ptr L1+0f270f26H,ax
                mov     dx,word ptr L1+2b0f2a0fH
                mov     al,4cH
                out     dx,al
                mov     dx,word ptr L1+300f2f0fH
                mov     al,00H
                out     dx,al
                mov     dx,word ptr L1+350f340fH
                mov     al,4cH
                out     dx,al
                mov     dx,word ptr L1+3a0f390fH
                mov     al,07H
                out     dx,al
                mov     dx,word ptr L1+3f0f3e0fH
                mov     al,0eH
                out     dx,al
                mov     dx,word ptr L1+440f430fH
                mov     al,0dfH
                out     dx,al
                xor     al,al
L42:            call    near ptr L59
                inc     al
                cmp     al,1fH
                jne     short L42
                mov     dx,word ptr L1+0f4f0f4eH
                mov     al,45H
                out     dx,al
                DB      66H,8bH,15H,08H,00H,00H,00H
                mov     al,00H
                out     dx,al
                mov     dx,word ptr L1+0f590f58H
                mov     al,47H
                out     dx,al
                mov     dx,word ptr L1+0f5e0f5dH
                mov     al,0ccH
                out     dx,al
                mov     bl,byte ptr xmp_devirq1
                cmp     bl,02H
                jne     short L44
                mov     bl,09H
L44:            cmp     bl,07H
                seta    al
                movzx   eax,al
                mov     ax,word ptr L1+0f6e0f6dH[eax*2]
                mov     word ptr L1+0f710f70H,ax
                mov     edx,offset L1+740f730fH
                call    dword ptr _setirqvect
                mov     edi,offset L1+790f780fH
                call    near ptr _rmpmirqset
                mov     dword ptr L1+7e0f7d0fH,eax
                xor     al,al
                call    near ptr _setirqmask
                mov     dx,word ptr L1-7af07bf1H
                mov     al,0eH
                out     dx,al
                mov     dx,word ptr L1-75f076f1H
                mov     al,0c0H
                out     dx,al
                mov     dword ptr L1+0f8e0f8dH,00000008H
                mov     edi,00000000H
                mov     ecx,00000008H
                mov     esi,offset L1-67f068f1H
                call    near ptr L55
                popad   
                ret     
gus_play:       pushad  
                mov     ax,word ptr s_bpm
                mov     word ptr L1+0fa10fa0H,ax
                mov     ax,word ptr s_speed
                mov     word ptr L1-58f059f1H,ax
                movzx   edx,byte ptr xmp_devchann
                cmp     dl,0eH
                jae     short L45
                mov     dl,0eH
L45:            sub     dl,0eH
                mov     eax,dword ptr L1+0fb20fb1H[edx*4]
                mov     dword ptr L1-4af04bf1H,eax
                movzx   ebx,byte ptr xmp_devchann
                cmp     bl,0eH
                jae     short L46
                mov     bl,0eH
L46:            dec     bl
                or      bl,0c0H
                mov     dx,word ptr L1+0fc10fc0H
                mov     al,0eH
                out     dx,al
                mov     dx,word ptr L5
                mov     al,bl
                out     dx,al
                mov     dx,word ptr L1
                mov     al,0cH
                out     dx,al
                mov     dx,word ptr L3
                mov     al,45H
                out     dx,al
                mov     dx,word ptr L5
                xor     al,al
                out     dx,al
                mov     dx,word ptr L3
                mov     al,45H
                out     dx,al
                mov     dx,word ptr L5
                mov     al,08H
                out     dx,al
                mov     dx,word ptr L7
                mov     al,04H
                out     dx,al
                mov     dx,word ptr L8
                mov     al,02H
                out     dx,al
                mov     dx,word ptr L3
                mov     al,8fH
                out     dx,al
                mov     dx,word ptr L5
                in      al,dx
                mov     dx,word ptr L3
                mov     al,8fH
                out     dx,al
                mov     dx,word ptr L5
                in      al,dx
                mov     dx,word ptr L3
                mov     al,8fH
                out     dx,al
                mov     dx,word ptr L5
                in      al,dx
                mov     dx,word ptr L3
                mov     al,4cH
                out     dx,al
                mov     dx,word ptr L5
                mov     al,03H
                out     dx,al
                mov     dx,word ptr L3
                mov     al,8fH
                out     dx,al
                mov     dx,word ptr L5
                in      al,dx
                mov     dx,word ptr L3
                mov     al,8fH
                out     dx,al
                mov     dx,word ptr L5
                in      al,dx
                mov     dx,word ptr L3
                mov     al,8fH
                out     dx,al
                mov     dx,word ptr L5
                in      al,dx
                mov     dx,word ptr L3
                mov     al,8fH
                out     dx,al
                mov     dx,word ptr L5
                in      al,dx
                mov     dx,word ptr L3
                mov     al,8fH
                out     dx,al
                mov     dx,word ptr L5
                in      al,dx
                call    near ptr L60
                popad   
                ret     
gus_end:        push    eax
                push    bx
                push    dx
                mov     dx,word ptr L3
                mov     al,4cH
                out     dx,al
                mov     dx,word ptr L5
                xor     al,al
                out     dx,al
                mov     dx,word ptr L1
                mov     al,0bH
                out     dx,al
                mov     bl,byte ptr xmp_devirq1+0c15H
                mov     eax,dword ptr L9
                call    near ptr _rmpmirqfree
                mov     al,01H
                call    near ptr _setirqmask
                pop     dx
                pop     bx
                pop     eax
                ret     
gus_stop:       ret     
                xchg    ebx,ebx
                pushad  
                mov     al,20H
                out     20H,al
                add     byte ptr [eax],al
                push    ds
                sti     
                cld     
                mov     ds,word ptr cs:_seldata
                xor     eax,eax
                mov     dx,word ptr L1-1bfeabd5H
                in      al,dx
                test    al,04H
                jne     short L47
                test    al,08H
                jne     short L47
                jmp     short L48
L47:            mov     dx,word ptr L1+545de401H
                mov     al,45H
                out     dx,al
                mov     dx,word ptr L1-1bfeab91H
                xor     ax,ax
                out     dx,al
                mov     al,08H
                out     dx,al
                call    near ptr L60
                call    near ptr _XMP_Main
                jmp     short L48
L48:            pop     ds
                popad   
                sti     
                iretd   
gus_load:       pushad  
                movzx   ebp,byte ptr s_num
                cmp     ebp,00000040H
                xor     eax,eax
                mov     al,byte ptr s_type
                mov     ah,al
                mov     bl,al
                and     al,10H
                shr     al,02H
                and     ah,01H
                shl     ah,03H
                and     bl,02H
                shl     bl,02H
                mov     bh,bl
                shl     bh,1
                or      ah,bl
                or      al,ah
                or      al,bh
                mov     byte ptr ds:L1-4a1afeacH[ebp],al
                test    al,08H
                je      short L49
                mov     ecx,dword ptr s_loops
                mov     ebx,dword ptr s_loopl
                mov     edi,dword ptr L1-131afeacH
                mov     dword ptr ds:L1+3e60154H[ebp*4],edi
                add     ecx,ebx
                mov     esi,ecx
                add     esi,edi
                mov     dword ptr ds:L1+8158b66H[ebp*4],esi
                mov     ebx,dword ptr s_loops
                add     ebx,edi
                mov     dword ptr ds:L1+4cb00000H[ebp*4],ebx
                mov     ebx,dword ptr xmp_devmem
                cmp     esi,ebx
                mov     esi,dword ptr s_start
                jmp     short L50
L49:            mov     ecx,dword ptr s_size
                mov     edi,dword ptr L1+8158b66H
                mov     dword ptr ds:L1-74991200H[ebp*4],edi
                mov     dword ptr ds:L1-11bc5000H[ebp*4],edi
                mov     ebx,ecx
                add     ebx,edi
                mov     dword ptr ds:L1+660000b8H[ebp*4],ebx
                mov     ebx,dword ptr xmp_devmem
                cmp     esi,ebx
                mov     esi,dword ptr s_start
L50:            mov     ax,0900H
                int     31H
                push    ax
                mov     al,byte ptr ds:L33[ebp]
                test    al,04H
                je      short L51
                mov     eax,dword ptr ds:L1-50000000H[ebp*4]
                mov     ebx,dword ptr L1+6158b66H
                shr     ebx,12H
                inc     ebx
                shl     ebx,12H
                cmp     eax,ebx
                jbe     short L51
                push    ecx
                mov     ecx,dword ptr ds:L1+0faa3cecH[ebp*4]
                sub     ecx,dword ptr ds:L1+158b6600H[ebp*4]
                add     ecx,ebx
                sub     eax,dword ptr ds:L1+158b66eeH[ebp*4]
                add     eax,ebx
                mov     dword ptr ds:L1+158b66eeH[ebp*4],ebx
                mov     dword ptr ds:L1+66ee43b0H[ebp*4],eax
                mov     dword ptr ds:L1-479a0000H[ebp*4],ecx
                mov     edi,ebx
                pop     ecx
L51:            call    near ptr L55
                mov     al,byte ptr ds:L1-44113fceH[ebp]
                test    al,18H
                je      short L52
                mov     esi,dword ptr s_loops
                add     esi,dword ptr s_start
                mov     ecx,00000008H
                call    near ptr L55
                jmp     short L53
L52:            mov     ecx,00000004H
                mov     esi,offset L1-749911bdH
                call    near ptr L55
L53:            mov     eax,edi
                and     al,0e0H
                add     eax,00000020H
                mov     dword ptr L43,eax
                mov     al,byte ptr ds:L1+158b66eeH[ebp]
                test    al,04H
                je      short L54
                mov     eax,dword ptr ds:L1+8158bH[ebp*4]
                call    near ptr L62
                mov     dword ptr ds:L1-50000000H[ebp*4],eax
                mov     eax,dword ptr ds:L30[ebp*4]
                call    near ptr L62
                mov     dword ptr ds:L43[ebp*4],eax
                mov     eax,dword ptr ds:L1-7499b98bH[ebp*4]
                call    near ptr L62
                mov     dword ptr ds:L1+8158bH[ebp*4],eax
L54:            pop     ax
                int     31H
                sti     
                popad   
                xor     al,al
                ret     
                popad   
                mov     al,01H
                ret     
L55:            jcxz    L56
                mov     dx,word ptr L4
                mov     al,43H
                out     dx,al
                mov     dx,word ptr L1+0c158b66H
                mov     eax,edi
                out     dx,ax
                mov     dx,word ptr L1-3c7c99f1H
                mov     al,44H
                out     dx,al
                mov     dx,word ptr L1-0b17df1H
                shr     eax,10H
                out     dx,al
                mov     dx,word ptr L1+6600001eH
                mov     al,byte ptr [esi]
                out     dx,al
                dec     ecx
                inc     edi
                inc     esi
                jmp     short L55
L56:            clc     
                ret     
gus_csf:        pushad  
                mov     dx,word ptr L1+0b00000H
                out     dx,al
                mov     dx,word ptr L1+0a16766H
                mov     al,01H
                out     dx,al
                mov     eax,dword ptr s_freq
                call    near ptr L61
                mov     dx,word ptr L1+5660000H
                out     dx,ax
                popad   
                ret     
gus_csv:        pushad  
                mov     dx,word ptr L1-5c99bf9aH
                out     dx,al
                mov     dx,word ptr L1+20566H
                mov     al,89H
                out     dx,al
                mov     dx,word ptr L1+0a16766H
                in      ax,dx
                shr     ax,04H
                mov     cx,ax
                movzx   ebx,word ptr s_vol
                shr     bx,08H
                mov     ax,word ptr L4[ebx*2]
                mov     bx,ax
                cmp     bx,cx
                je      near ptr L58
                mov     dx,word ptr L1+66000000H
                mov     al,0dH
                out     dx,al
                mov     dx,word ptr L1+66ee4cb0H
                in      al,dx
                or      al,03H
                out     dx,al
                call    near ptr L63
                out     dx,al
                mov     dx,word ptr L1-50000000H
                mov     al,06H
                out     dx,al
                mov     dx,word ptr L1-50000000H
                mov     al,3fH
                out     dx,al
                cmp     bx,cx
                ja      short L57
                mov     dx,word ptr L1+158b66eeH
                mov     al,07H
                out     dx,al
                mov     dx,word ptr L1-173fcd12H
                mov     ax,bx
                shr     ax,04H
                out     dx,al
                mov     dx,word ptr L1+4158bH
                mov     al,08H
                out     dx,al
                mov     dx,word ptr L1+8158bH
                mov     ax,cx
                shr     ax,04H
                out     dx,al
                mov     dx,word ptr L1-11b85000H
                mov     al,0dH
                out     dx,al
                mov     dx,word ptr L1-11335000H
                mov     al,40H
                out     dx,al
                call    near ptr L63
                out     dx,al
                jmp     short L58
L57:            mov     dx,word ptr L1-3f68f0f9H
                mov     al,07H
                out     dx,al
                mov     dx,word ptr L1+2e45H
                mov     ax,cx
                shr     ax,04H
                out     dx,al
                mov     dx,word ptr L1+16ff6700H
                mov     al,08H
                out     dx,al
                mov     dx,word ptr L1+0e800H
                mov     ax,bx
                shr     ax,04H
                out     dx,al
                mov     dx,word ptr L1+66000000H
                mov     al,0dH
                out     dx,al
                mov     dx,word ptr L1+66ee0eb0H
                xor     al,al
                out     dx,al
                call    near ptr L63
                out     dx,al
L58:            popad   
                ret     
gus_csp:        push    eax
                push    edx
                mov     dx,word ptr L1-41000000H
                out     dx,al
                mov     dx,word ptr L35
                mov     al,0cH
                out     dx,al
                mov     dx,word ptr L1+386e8H
                mov     ax,word ptr s_pan
                shr     ax,0cH
                out     dx,al
                pop     edx
                pop     eax
                ret     
gus_pse:        mov     word ptr s_vol,0000H
                call    near ptr gus_csv
                ret     

gus_pss:        pushad  
                movzx   ebx,al
                mov     dx,word ptr s_vol
                mov     word ptr s_vol,0000H
                call    near ptr gus_csv
                mov     word ptr s_vol,dx
                movzx   ebp,byte ptr s_num
                mov     dx,word ptr L1-3401f14dH
                mov     al,80H
                out     dx,al
                mov     dx,word ptr L3
                in      al,dx
                or      al,03H
                push    ax
                mov     dx,word ptr L3
                mov     al,00H
                out     dx,al
                mov     dx,word ptr L5
                pop     ax
                out     dx,al
                call    near ptr L63
                out     dx,al
                mov     eax,dword ptr s_freq+0e601H
                call    near ptr L61
                push    ax
                mov     dx,word ptr L3
                mov     al,01H
                out     dx,al
                mov     dx,word ptr L4
                pop     ax
                out     dx,ax
                mov     dx,word ptr L3
                mov     al,0cH
                out     dx,al
                mov     dx,word ptr L5
                mov     ax,word ptr s_pan+3340H
                shr     ax,0cH
                out     dx,al
                mov     ecx,dword ptr ds:L29[ebp*4]
                mov     edx,dword ptr s_offset+0c001H
                add     ecx,edx
                mov     dx,word ptr L3
                mov     al,0bH
                out     dx,al
                mov     dx,word ptr L4
                mov     eax,ecx
                shl     eax,09H
                out     dx,ax
                call    near ptr L63
                out     dx,ax
                mov     dx,word ptr L3
                mov     al,0aH
                out     dx,al
                mov     dx,word ptr L4
                mov     eax,ecx
                shr     eax,07H
                out     dx,ax
                call    near ptr L63
                out     dx,ax
                mov     ecx,dword ptr ds:L32[ebp*4]
                mov     dx,word ptr L3
                mov     al,02H
                out     dx,al
                mov     dx,word ptr L4
                mov     eax,ecx
                shr     eax,07H
                out     dx,ax
                mov     dx,word ptr L3
                mov     al,03H
                out     dx,al
                mov     dx,word ptr L4
                mov     eax,ecx
                shl     eax,09H
                out     dx,ax
                mov     ecx,dword ptr ds:L31[ebp*4]
                mov     dx,word ptr L3
                mov     al,04H
                out     dx,al
                mov     dx,word ptr L4
                mov     eax,ecx
                shr     eax,07H
                out     dx,ax
                mov     dx,word ptr L3
                mov     al,05H
                out     dx,al
                mov     dx,word ptr L4
                mov     eax,ecx
                shl     eax,09H
                out     dx,ax
                mov     eax,ebx
                call    near ptr gus_csv
                mov     dx,word ptr L3
                mov     al,00H
                out     dx,al
                mov     al,byte ptr ds:L34[ebp]
                mov     dx,word ptr L5
                out     dx,al
                call    near ptr L63
                out     dx,al
                sti     
                popad   
                ret     



L59:            pushad  
                movzx   ebp,al
                mov     word ptr ds:L36[ebp*2],0000H
                mov     dx,word ptr L2
                out     dx,al
                mov     dx,word ptr L3
                mov     al,06H
                out     dx,al
                mov     dx,word ptr L5
                mov     al,00H
                out     dx,al
                mov     dx,word ptr L3
                mov     al,07H
                out     dx,al
                mov     dx,word ptr L5
                mov     al,00H
                out     dx,al
                mov     dx,word ptr L3
                mov     al,08H
                out     dx,al
                mov     dx,word ptr L5
                mov     al,00H
                out     dx,al
                mov     dx,word ptr L3
                mov     al,09H
                out     dx,al
                mov     dx,word ptr L4
                mov     ax,0000H
                out     dx,ax
                call    near ptr L63
                out     dx,al
                mov     dx,word ptr L3
                mov     al,0cH
                out     dx,al
                mov     dx,word ptr L5
                mov     al,08H
                out     dx,al
                mov     dx,word ptr L3
                mov     al,0dH
                out     dx,al
                mov     dx,word ptr L5
                mov     al,42H
                out     dx,al
                call    near ptr L63
                out     dx,al
                mov     dx,word ptr L3
                mov     al,00H
                out     dx,al
                mov     dx,word ptr L5
                mov     al,07H
                out     dx,al
                call    near ptr L63
                out     dx,al
                mov     dx,word ptr L3
                mov     al,02H
                out     dx,al
                mov     dx,word ptr L4
                mov     ax,0000H
                out     dx,ax
                mov     dx,word ptr L3
                mov     al,03H
                out     dx,al
                mov     dx,word ptr L4
                mov     ax,0000H
                out     dx,ax
                mov     dx,word ptr L3
                mov     al,0aH
                out     dx,al
                mov     dx,word ptr L4
                mov     ax,0000H
                out     dx,ax
                call    near ptr L63
                out     dx,ax
                mov     dx,word ptr L3
                mov     al,0bH
                out     dx,al
                mov     dx,word ptr L4
                mov     ax,0000H
                out     dx,ax
                call    near ptr L63
                out     dx,ax
                mov     dx,word ptr L3
                mov     al,04H
                out     dx,al
                mov     dx,word ptr L4
                mov     ax,0000H
                out     dx,ax
                mov     dx,word ptr L3
                mov     al,05H
                out     dx,al
                mov     dx,word ptr L4
                mov     ax,0000H
                out     dx,ax
                popad   
                ret     
L60:            push    ax
                push    bx
                push    dx
                mov     bx,word ptr s_bpm+158bH
                xor     dx,dx
                mov     ax,1e84H
                div     bx
                mov     bl,al
                neg     bl
                mov     dx,word ptr L3
                mov     al,47H
                out     dx,al
                mov     dx,word ptr L5
                mov     al,bl
                out     dx,al
                pop     dx
                pop     bx
                pop     ax
                ret     
L61:            push    edx
                xor     edx,edx
                shl     eax,0aH
                div     dword ptr L10
                pop     edx
                ret     
L62:            push    edx
                mov     edx,eax
                shr     eax,1
                and     eax,0001ffffH
                and     edx,000c0000H
                or      eax,edx
                pop     edx
                ret     
L63:            push    ax
                push    dx
                mov     dx,word ptr L6
                in      al,dx
                in      al,dx
                in      al,dx
                in      al,dx
                in      al,dx
                in      al,dx
                in      al,dx
                pop     dx
                pop     ax
                ret     
*** warning: Label 'L6' emitted using ORG. File may not assemble. ***
                ORG     0000000cH
L6              LABEL   NEAR
*** warning: Label 'L7' emitted using ORG. File may not assemble. ***
                ORG     0000000eH
L7              LABEL   NEAR
*** warning: Label 'L8' emitted using ORG. File may not assemble. ***
                ORG     00000010H
L8              LABEL   NEAR
*** warning: Label 'L9' emitted using ORG. File may not assemble. ***
                ORG     00000014H
L9              LABEL   NEAR
*** warning: Label 'L14' emitted using ORG. File may not assemble. ***
                ORG     000000d6H
L14             LABEL   NEAR
*** warning: Label 'L16' emitted using ORG. File may not assemble. ***
                ORG     0000015dH
L16             LABEL   NEAR
*** warning: Label 'L17' emitted using ORG. File may not assemble. ***
                ORG     0000015fH
L17             LABEL   NEAR
*** warning: Label 'L20' emitted using ORG. File may not assemble. ***
                ORG     00000216H
L20             LABEL   NEAR
*** warning: Label 'L30' emitted using ORG. File may not assemble. ***
                ORG     00000615H
L30             LABEL   NEAR
*** warning: Label 'L33' emitted using ORG. File may not assemble. ***
                ORG     00000815H
L33             LABEL   NEAR
*** warning: Label 'L35' emitted using ORG. File may not assemble. ***
                ORG     000008b9H
L35             LABEL   NEAR
*** warning: Label 'gus_detect' emitted using ORG. File may not assemble. ***
                ORG     0000094bH
gus_detect      LABEL   NEAR
*** warning: Label 'L37' emitted using ORG. File may not assemble. ***
                ORG     00000955H
L37             LABEL   NEAR
*** warning: Label 'L38' emitted using ORG. File may not assemble. ***
                ORG     00000994H
L38             LABEL   NEAR
*** warning: Label 'L43' emitted using ORG. File may not assemble. ***
                ORG     00000c15H
L43             LABEL   NEAR
code32          ENDS

                END
