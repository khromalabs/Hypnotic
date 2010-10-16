;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;                   RUTINAS PARA EL MANEJO DEL PIT (TIMER)                  
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;                       1995 Khroma (A.K.A Rub‚n G¢mez)                     
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

  .386p
  jumps

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  D e f i n i c i o n e s
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    include pmode.inc
    include structs.inc

    public  INITTIMER
    public  RESETTIMER
    public  timer

    extrn WAITRETRACE:near, screen:ScreenINFO, CallMusic:near


  DAC_WRITE    = 3C8h             ; Direcci¢n DAC-Write
  DAC_DATA     = 3C9h             ; Registro de datos DAC


code16  segment para public use16
	assume cs:code16, ds:code16

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; PROCEDIMIENTO:³ rmirq8
;---------------³-------------------------------------------------------------
; FUNCION:      ³ Actualiza los contadores en el modo real
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
 align 4
 rftimer  dd	?

 align 16
 RMIRQ8 PROC
	sti
	push ax ds si bx

	mov  ax, word ptr cs:rftimer+2
	mov  ds, ax
	mov  si, word ptr cs:rftimer

	mov  [si].wrt, 0
	inc  [si].rcount
	xor  ax, ax
	mov  bx, ax
	mov  ax, [si].ticks
	add  word ptr [si].tfreq, ax
	adc  word ptr [si].tfreq+2, bx

	inc  [si].wsync
	cmp  [si].wsync, 512
	jne  short @nosync
	mov  [si].wsync, 0

	cli
	push dx
	mov  al, 34h
	out  43h, al
	mov  dx, 3DAh
@wrloop:in   al, dx
	test al, 00001000b
	jz   short @wrloop
	pop  dx
	mov  al, byte ptr [si].ticks
	out  40h, al
	mov  al, byte ptr [si].ticks+1
	out  40h, al
	sti

@nosync:pop  bx si ds
	mov  al, 20h
	out  20h, al
	pop  ax

	iret
 ENDP
ends

code32  segment para public use32
	assume cs:code32, ds:code32

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  D a t o s
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  ormivtm    dd   ?
  opmivtm    dd   ?
  pm2rmref   dw	  rftimer,code16
  rmirqadx   dw	  RMIRQ8,code16


  timer      TimerINFO  ?

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  C ¢ d i g o
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; PROCEDIMIENTO:³ INITTIMER
;---------------³-------------------------------------------------------------
; FUNCION:      ³ Reprograma la velocidad del TIMER, y desv¡a la IRQ
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
 align 16
 INITTIMER  PROC
 	mov  ax, 900h
 	int  31h
 	push ax

; Obtiene la velocidad de los retrazados en pantalla
	call getframetime
	mov  timer.ticks, ax

	mov   eax, PITFREQ
	mov   edx, eax
	shl   eax, 16
	shr   edx, 16
	movzx ebx, timer.ticks
	idiv  ebx
	mov   screen.vgahz, eax

; Inicia la IRQ, modo real
@irq8init:
	movzx esi, word ptr pm2rmref
	movzx edi, word ptr pm2rmref+2
	shl  edi, 4
	add  edi, esi
	sub  edi, _code32a
	lea  eax, timer
	add  eax, _code32a
	mov  ebx, eax
	shr  eax, 4
	and  ebx, 1111b
	mov  [edi], bx
	mov  [edi+2], ax
	mov  eax, dword ptr rmirqadx
	xchg eax, gs:[8*4]
	mov  ormivtm, eax
	
; Inicia la IRQ en modo protegido
@irq0init:
	xor  bl, bl
	call _getirqvect
	mov  opmivtm,edx
	mov  edx,offset IRQ0PM
	call _setirqvect

	mov  timer.wfwpal, 0

; Cambia la velocidad del Timer (0)
timerinit:
	mov bx, timer.ticks

	cli
	mov al, 34h
	out 43h, al
	call WAITRETRACE
	mov al, bl
	out 40h, al
	mov al, bh
	out 40h, al
	sti

	xor  eax, eax
	mov  timer.wsync, ax
	mov  timer.rcount, ax
	mov  timer.tfreq, eax
	mov  screen.fctr, eax

	pop  ax
	int  31h

	ret
 ENDP


;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; PROCEDIMIENTO: ³ RESETTIMER
;----------------³------------------------------------------------------------
; FUNCION:	 ³ Dejamos todo como estaba
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
 align 16
 RESETTIMER  PROC
 	mov  ax, 900h
 	int  31h
 	push ax

; Restaura la velocidad del PIT
	cli
	mov al, 34h
	out 43h, al
	xor al, al
	out 40h, al
	out 40h, al
	sti

; Restaura los antiguos handlers
	mov eax, ormivtm
	mov gs:[8*4], eax
	xor bl,bl
	mov edx, opmivtm
	call _setirqvect

	pop  ax
	int  31h

	ret
 ENDP


;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; PROCEDIMIENTO:³ getframetime
;---------------³-------------------------------------------------------------
; FUNCION:      ³ Calcula el tiempo de retrazado de un frame       
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
 align 16
 getframetime PROC
	push edx 

	cli
	mov dx, 3DAh

loop1:  in al,dx		; Waits for v. retrace init
	test al,8
	jnz short loop1
loop2:  in al,dx	        ; Waits for v. retrace end
	test al,8
	jz short loop2

	mov al,34h		; Gets the time between the next retrace
	out 43h,al
	xor al,al
	out 40h,al
	out 40h,al

loop3:  in al,dx		; We are on the init of a v retrace
	test al,8
	jnz short loop3
loop4:  in al,dx
	test al,8
	jz short loop4

	xor al,al
	out 43h,al
	in al,40h
	mov ah,al
	in al,40h
	xchg al,ah
	neg ax
	sti

	pop edx
	ret

 ENDP


;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; PROCEDIMIENTO:³ IRQ0TM
;---------------³-------------------------------------------------------------
; FUNCION:      ³ Nueva IRQ para el timer
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
 align 16
 IRQ0PM PROC
	sti
        push eax ds
	mov  ds, _seldata

	mov  timer.wrt, 0
	inc  timer.rcount

	xor  eax, eax
	mov  ax, timer.ticks
	add  timer.tfreq, eax
	
        inc  timer.wsync
	cmp  timer.wsync, 512
	jne   short nowait
	mov  timer.wsync, 0

	cli
	push dx
	mov al, 34h
	out 43h, al
	mov  dx, 3DAh
wrloop: in   al, dx
	test al, 00001000b
	jz   short  wrloop
	pop  dx

	mov al, byte ptr timer.ticks
	out 40h, al
	mov al, byte ptr timer.ticks+1
	out 40h, al

;   	sti

nowait:
	cmp timer.wfwpal, 0
	je  i0@exit

;	cli
	push dx ax
	mov  dx, 3DAh
wrloop2: in   al, dx
	test al, 00001000b
	jz   short  wrloop2
	pop  ax dx
;	sti


	cmp timer.wfwpal, 1
	je  short i0@wrpl

	cmp timer.wfwpal, 2
	je  short i0@wrp32

	cmp timer.wfwpal, 3
	je  i0@wrprgb

	mov timer.wfwpal, 0
	jmp  i0@exit

i0@wrpl:
   
        push  cx dx edi

	mov  cx, timer.wpncol
	mov  ax, timer.wpnini
	mov  edi, timer.wpadd


	mov  dx, DAC_WRITE
	out  dx, al
	mov  dx, DAC_DATA

i0@wrpl@01:
	mov  al, [edi]
	nop
	out  dx, al
	mov  al, [edi+1]
	nop
	out  dx, al
	mov  al, [edi+2]
	nop
	out  dx, al
	add  edi, 3
	dec  cx
	jnz  short i0@wrpl@01


        pop  edi dx cx
	mov  timer.wfwpal, 0

	jmp  i0@exit


i0@wrp32:
	push  cx dx edi

	mov  cx, timer.wpncol
	mov  ax, timer.wpnini
	mov  edi, timer.wpadd

;	push  eax
;	movzx eax, al
;	lea   eax, [eax*2+eax]		;EAX = EAX * 3
;	shl   eax, 2	  		;EAX = EAX * 4
;	add   edi, eax
;	pop   eax
	
	mov   dx, DAC_WRITE
	out   dx, al
	mov   dx, DAC_DATA

i0@wrp32@01:
	mov  eax, [edi]
	shr  eax, 16
	out  dx, al
	mov  eax, [edi+4]
	shr  eax, 16
	out  dx, al
	mov  eax, [edi+8]
	shr  eax, 16
	out  dx, al

	add  edi, 3*4
	dec  cx
	jnz  short i0@wrp32@01

	pop  edi dx cx
	mov  timer.wfwpal, 0

	jmp  short i0@exit


i0@wrprgb:
	push  ebx ecx edx esi ebp

	mov  cx, timer.wpncol
	mov  ax, timer.wpnini
	mov  ebx, timer.wpr
	mov  esi, timer.wpg
	mov  ebp, timer.wpb


	out   dx, al
	mov   dx, DAC_DATA

i0@wrprgb@01:
	mov   ax, bx
	nop
	out   dx, al
	mov   ax, si
	nop
	out   dx, al
	mov   ax, bp
	nop
	out   dx, al

	dec   cx
	jnz   short i0@wrprgb@01

	mov  timer.wfwpal, 0

	pop   ebp esi edx ecx ebx


i0@exit:
	mov  al, 20h
	out  20h, al
	sti


	pop  ds eax
	iretd
 ENDP

ends
end
