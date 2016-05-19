@echo off
setlocal
set mypath=%~dp0
set PYTHONPATH=pkgs
"%COMMONPROGRAMFILES%\Python\2.7\python.exe" openquake.commonlib.commands %*
endlocal
