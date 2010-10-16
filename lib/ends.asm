;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;±                     End Scroll - EXOBIT Productions                       ±
;±-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-±
;±                      1995 Khroma (A.K.A Rub‚n G¢mez)                      ±
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

  .386p				; I like it...

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  D e f i n i t i o n s
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 CRT_INDEX	equ	3D4h
 CRT_DATA	equ	3D5h   
 DAC_READ      	equ	3C7h
 DAC_WRITE     	equ	3C8h
 DAC_DATA      	equ	3C9h
 VERT_RETRACE  	equ	3DAh

 extrn WAITRETRACE:near

code32  segment para public use32
	assume cs:code32, ds:code32

  include pmode.inc			; I love it... =)

  counter	db	24
  flag		db	0

 extrn exologo:byte
 public TEXT_SCROLL

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;  PROC:          ³ SCROLL
;                 ³ 
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;-----------------------------------------------------------------------------
 TEXT_SCROLL PROC

; Init text-mode
 	mov v86r_ax, 3
 	mov ax, 10h
 	int 33h

; Init 50 lines color mode
 	mov v86r_ah, 11h
 	mov v86r_al, 12h
 	mov v86r_bl, 0
 	mov ax, 10h
 	int 33h

; Set cursor to...
 	mov v86r_ax, 200h
 	mov v86r_bh, 0
 	mov v86r_dh, 100
 	mov v86r_dl, 0
 	mov ax, 10h
 	int 33h

; Set the scroll
	mov dx, CRT_INDEX
        mov al, 8
	out dx, al
	mov dx, CRT_DATA
	mov al, 7
	out dx, al
	call WAITRETRACE

	@rlp edi, 0b8000h
	mov ebx, offset exologo
	add ebx, 24*80*2
	mov esi, ebx
	mov ebp, (80*2)/4
	mov ecx, ebp

	
@sloop:	rep movsd
        mov cl, 7
@vgalp: mov al, cl
	out dx, al
	xor flag, 1
	cmp flag, 0
	jnz short label
	call WAITRETRACE
label:	dec cl
	jns short @vgalp
		
	@rlp edi, 0b8000h
	sub  ebx, 80*2
	mov  esi, ebx
	add  ebp, (80*2)/4
	mov  ecx, ebp
	
	dec counter
	jns @sloop

	xor al, al
	out dx, al

; Restore the cursor...
 	mov v86r_ax, 200h
 	mov v86r_bh, 0
 	mov v86r_dh, 25
 	mov v86r_dl, 0
 	mov ax, 10h
 	int 33h

	ret
 ENDP

ends
end
