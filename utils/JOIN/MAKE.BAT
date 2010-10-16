@echo off
wcl386 /l=pmodew /bt=dos /fp3 /ox c:\exobit\utils\join\join.c
del join.obj >> nul
