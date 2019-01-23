@echo off
rem
rem $Header: $
rem


del /s *.~*  2> nul
del /s *.obj 2> nul
del /s *.ddp 2> nul
del /s *.dcu 2> nul
del /s *.hpp 2> nul
del /s *.map 2> nul
del /s *.tds 2> nul
del /s *.obj 2> nul
del /s *.dsm 2> nul
del /s *.$$$ 2> nul
del /s *.#?? 2> nul
del /s *.pch 2> nul
del /s *.*.orig 2> nul
del bin\inmem???.rem 2> nul

for /r %%f in (bin\*.log*) do (
    echo CLEAN LOG: %%f
    echo. > %%f 
)