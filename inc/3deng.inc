;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
; Library EXOMOTION
; 1996 Copyright (C) Khroma (AKA Rub굈 G줺ez)
; All Rights Reserved
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

; VGA Procedures
extrn SET320200:near, SET320240:near, SET320400:near, IMAGEN:near
extrn TESTVGA:near, GETPAL:near, SETPAL:near, FADEINIT:near, FADETRACE:near
extrn SETTEXT:near, CLS:near, SCREENON:near, SCREENOFF:near, SETPIXEL:near

; Fade types
FADEOUT   equ 0
FADEIN    equ 1
FADEMORPH equ 2

; RENDER Procedures
extrn SETMAT:near, ROTAR:near, RENDER:near, LOADOBJECT:near, SETRFLAG:near
extrn TRACEPATH:near, INITPATH:near, SETBACKGND:near, INITMAP:near
extrn INITTEXT:near, LOADPICTURE:near, INITMORPH:near, TRACEMORPH:near
extrn WAITTIME:near, NEWLIGHTTABLE:near, LOOKAT:near, LOOKAT_X:near
extrn LOOKAT_Y:near, PUTPIXTRANS:near

extrn TheWorld:dword

; PIT rutines
extrn INITTIMER:near, RESETTIMER:near

; MATH COPROCESOR detection
extrn  TESTCOPRO:near

