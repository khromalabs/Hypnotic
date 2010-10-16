@echo off
call c:\comm\te\te.bat
move c:\comm\files\exobit.zip c:\exobit\exobit.zip
move  exobit.exe temp.exe
pkunzip exobit.zip exobit.exe
move  exobit.exe exobitf.exe
move  temp.exe exobit.exe
del    exobit.zip
