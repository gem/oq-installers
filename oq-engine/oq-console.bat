@echo off
setlocal
set mypath=%~dp0
set PATH=%PATH%;%COMMONPROGRAMFILES%\Python\2.7
set PYTHONPATH=pkgs
cmd /k
endlocal
