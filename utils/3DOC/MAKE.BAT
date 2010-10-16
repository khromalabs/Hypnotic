@echo off
if "%1" == "GNU" GOTO GNU

:WATCOM
wcl386 /l=pmodew /bt=dos /fp3 /ox c:\exobit\utils\3doc\3doc
del 3doc.obj >> nul
GOTO END


:GNU
echo Compiling...
gcc 3doc.c -o 3doc
echo Stripping...
strip 3doc
echo Generating executable...
coff2exe 3doc
del 3doc >> nul

:END

