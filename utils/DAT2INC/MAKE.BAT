@echo off
if "%1" == "GNU" GOTO GNU

:WATCOM
wcl386 /l=pmodew /bt=dos c:\exobit\utils\dat2inc\dat2inc
del dat2inc.obj >> nul
GOTO END


:GNU
echo Compiling...
gcc dat2inc.c -o dat2inc
echo Stripping...
strip dat2inc
echo Generating executable...
coff2exe dat2inc
del dat2inc >> nul

:END
